"""Offline installer checks. Run: python -m unittest discover -s scripts -p test_install.py"""

from contextlib import redirect_stdout, redirect_stderr
import io
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import install


class InstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "repo"
        self.dest = Path(self.temp.name) / "codex home"
        for relative, content in {
            "skills/example/SKILL.md": "---\nname: example\ndescription: Example\n---\n",
            "skills/example/references/guide.txt": "supporting file",
            "agents/reviewer.toml": 'name = "reviewer"',
            "notes/workflow.md": "workflow notes",
        }.items():
            target = self.repo / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content)
        self.output = io.StringIO()
        output_redirect = redirect_stdout(self.output)
        output_redirect.__enter__()
        self.addCleanup(output_redirect.__exit__, None, None, None)

    def test_copy_backup_and_repeat_preserve_unrelated_files(self):
        target = self.dest / "skills/example/SKILL.md"
        target.parent.mkdir(parents=True)
        target.write_text("previous custom instructions")
        unrelated = self.dest / "skills/other/SKILL.md"
        unrelated.parent.mkdir(parents=True)
        unrelated.write_text("keep me")
        install.install_files(self.repo, self.dest)
        self.assertEqual(target.read_bytes(), (self.repo / "skills/example/SKILL.md").read_bytes())
        self.assertEqual((self.dest / "skills/example/references/guide.txt").read_text(), "supporting file")
        backups = list((self.dest / "backups").glob("*/skills/example/SKILL.md"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "previous custom instructions")
        install.install_files(self.repo, self.dest)
        self.assertEqual(len(list((self.dest / "backups").iterdir())), 1)
        self.assertEqual(unrelated.read_text(), "keep me")

    def test_dry_run_has_no_side_effects(self):
        with patch.object(install, "REPO_ROOT", self.repo), patch.dict(os.environ, {"CODEX_HOME": str(self.dest)}), patch.object(install.subprocess, "run") as run:
            self.assertEqual(install.main(["--dry-run"]), 0)
        run.assert_not_called()
        self.assertFalse(self.dest.exists())

    def test_missing_dependency_does_not_copy_files(self):
        with patch.object(install, "REPO_ROOT", self.repo), patch.dict(os.environ, {"CODEX_HOME": str(self.dest)}), patch.object(install.shutil, "which", return_value=None), redirect_stderr(io.StringIO()):
            self.assertEqual(install.main([]), 1)
        self.assertFalse(self.dest.exists())

    def test_existing_plugin_does_not_reinstall(self):
        marketplace = {"marketplaces": [{"name": "ponytail", "marketplaceSource": {"sourceType": "git", "source": install.PONYTAIL_REPO}}]}
        plugin = {"installed": [{"pluginId": "ponytail@ponytail", "installed": True, "enabled": True, "version": "5.3.2"}]}
        with patch.object(install, "run_codex", side_effect=[marketplace, plugin]), patch.object(install.subprocess, "run") as run:
            install.ensure_ponytail("codex")
        run.assert_not_called()

    def test_fresh_plugin_install_is_verified(self):
        plugin = {"installed": [{"pluginId": "ponytail@ponytail", "installed": True, "enabled": True, "version": "5.3.2"}]}
        with patch.object(install, "run_codex", side_effect=[{"marketplaces": []}, {"installed": []}, {}, plugin]) as run_json, patch.object(install.subprocess, "run") as run:
            install.ensure_ponytail("codex")
        run.assert_called_once_with(["codex", "plugin", "marketplace", "add", install.PONYTAIL_REPO], check=True)
        self.assertIn(unittest.mock.call("codex", "add", "ponytail@ponytail", "--json"), run_json.call_args_list)

    def test_marketplace_name_conflict_is_rejected(self):
        with patch.object(install, "run_codex", return_value={"marketplaces": [{"name": "ponytail"}]}), patch.object(install.subprocess, "run") as run:
            with self.assertRaisesRegex(ValueError, "official Git"):
                install.ensure_ponytail("codex")
        run.assert_not_called()


if __name__ == "__main__":
    unittest.main()
