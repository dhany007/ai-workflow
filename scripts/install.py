#!/usr/bin/env python3
"""Install this checkout into the current user's Codex, including Ponytail."""

import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


REPO_ROOT = Path(__file__).resolve().parent.parent
PONYTAIL_REPO = "https://github.com/DietrichGebert/ponytail.git"


def run_codex(codex, *args):
    result = subprocess.run(
        [codex, "plugin", *args], check=True, capture_output=True, text=True,
        encoding="utf-8",
    )
    return json.loads(result.stdout)


def ensure_ponytail(codex):
    marketplaces = run_codex(codex, "marketplace", "list", "--json")
    marketplace = next(
        (item for item in marketplaces["marketplaces"] if item["name"] == "ponytail"),
        None,
    )
    if marketplace is None:
        subprocess.run(
            [codex, "plugin", "marketplace", "add", PONYTAIL_REPO], check=True
        )
    else:
        source = marketplace.get("marketplaceSource", {})
        if source.get("source") != PONYTAIL_REPO or source.get("sourceType") != "git":
            raise ValueError(
                "Marketplace 'ponytail' does not point to the official Git repository. "
                "Resolve the name conflict in Codex before retrying."
            )

    def installed_plugin():
        plugins = run_codex(codex, "list", "--marketplace", "ponytail", "--json")
        return next(
            (item for item in plugins["installed"]
             if item.get("pluginId") == "ponytail@ponytail"
             and item.get("installed") and item.get("enabled")),
            None,
        )

    plugin = installed_plugin()
    if plugin is None:
        run_codex(codex, "add", "ponytail@ponytail", "--json")
        plugin = installed_plugin()
    if plugin is None:
        raise ValueError("Codex did not confirm that Ponytail is installed and enabled.")
    print("Ponytail installed and enabled (version {}).".format(plugin["version"]))


def install_files(repo, destination, dry_run=False):
    changes = []
    counts = {}
    for category in ("skills", "agents", "notes"):
        source = repo / category
        if not source.is_dir():
            raise ValueError("Missing repository directory: {}".format(source))
        if category == "skills":
            skill_dirs = sorted(p for p in source.iterdir() if p.is_dir() and not p.name.startswith("."))
            if not skill_dirs or any(not (p / "SKILL.md").is_file() for p in skill_dirs):
                raise ValueError("Every skill directory must contain SKILL.md.")
            files = [f for skill in skill_dirs for f in skill.rglob("*") if f.is_file()]
            counts[category] = len(skill_dirs)
        else:
            files = sorted(source.glob("*.toml")) if category == "agents" else sorted(source.rglob("*"))
            files = [f for f in files if f.is_file()]
            counts[category] = len(files)
        for file in files:
            relative = Path(category) / file.relative_to(source)
            target = destination / relative
            # Do not follow an existing destination link outside the chosen Codex home.
            if not target.resolve().is_relative_to(destination):
                raise ValueError("Destination escapes Codex home: {}".format(target))
            if target.exists() and not target.is_file():
                raise ValueError("Expected a file at: {}".format(target))
            if not target.exists() or file.read_bytes() != target.read_bytes():
                changes.append((file, target, relative))

    print("Install {} skills, {} agents, {} note files into {}".format(
        counts["skills"], counts["agents"], counts["notes"], destination
    ))
    print("{} files need copying.".format(len(changes)))
    if dry_run:
        print("Dry run: no files, plugins, or configuration were changed.")
        return

    backup = None
    for source, target, relative in changes:
        if target.exists():
            if backup is None:
                backup_parent = destination / "backups"
                backup_parent.mkdir(parents=True, exist_ok=True)
                backup = Path(tempfile.mkdtemp(
                    prefix="ai-workflow-{}-".format(datetime.now().strftime("%Y%m%d-%H%M%S")),
                    dir=backup_parent,
                ))
            backup_file = backup / relative
            backup_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(target, backup_file)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        if source.read_bytes() != target.read_bytes():
            raise OSError("Copy verification failed: {}".format(target))
    if backup:
        print("Previous files backed up to {}".format(backup))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Preview local file installation without running Codex or changing anything")
    args = parser.parse_args(argv)
    destination = Path(os.environ.get("CODEX_HOME") or Path.home() / ".codex").expanduser().resolve()
    if destination == REPO_ROOT or destination.is_relative_to(REPO_ROOT) or REPO_ROOT.is_relative_to(destination):
        parser.error("Codex home and the repository must be separate, non-overlapping directories.")
    try:
        if not args.dry_run:
            required = {name: shutil.which(name) for name in ("codex", "node", "git")}
            missing = [name for name, executable in required.items() if executable is None]
            if missing:
                raise ValueError("Install these commands and add them to PATH first: " + ", ".join(missing))
            # Fail on unsupported CLI versions before copying any workflow files.
            run_codex(required["codex"], "marketplace", "list", "--json")
        install_files(REPO_ROOT, destination, args.dry_run)
        if not args.dry_run:
            ensure_ponytail(required["codex"])
            print("AI Workflow installation complete. Restart Codex and start a new chat.")
            print("For automatic Ponytail hooks, open /hooks in Codex CLI and review/trust them.")
            print("Embedded Ponytail principles in the three workflow skills work without hooks.")
        return 0
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        print("Installation failed: {}".format(error), file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError) and error.stderr:
            print(error.stderr.strip(), file=sys.stderr)
        print("Installation may be partial; fix the error and rerun the same command. Existing unrelated files are preserved.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
