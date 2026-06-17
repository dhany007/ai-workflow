# AI Workflow

This repository stores Codex skills and supporting scripts for AI-assisted development workflows.

## Project Structure

```text
.
├── scripts/
│   └── sync-from-codex.sh
└── skills/
    ├── coding-standard/
    ├── pr-summary/
    ├── review-feature/
    ├── review-pr/
    ├── solve-conflict-pr/
    ├── tdd-workflow/
    └── tech-plan/
```

## Skills

Available skills in the `skills/` directory:

- `coding-standard`: coding standards for Go and Rust projects.
- `pr-summary`: generates pull request titles and descriptions from local changes.
- `review-feature`: reviews local changes before a pull request is created.
- `review-pr`: reviews GitHub pull requests.
- `solve-conflict-pr`: resolves GitHub pull request merge conflicts and validates the result.
- `tdd-workflow`: implements backend Go/Rust changes using test-driven development.
- `tech-plan`: creates backend technical implementation plans before coding.

Each skill lives in its own directory and should include at least a `SKILL.md` file.

## Sync from Local Codex

Use this script to copy skills from `~/.codex/skills` into this project's `skills/` directory:

```bash
scripts/sync-from-codex.sh
```

By default, the script:

- reads from `~/.codex/skills`;
- copies into `./skills`;
- copies user skills only;
- skips the `.system` directory;
- does not delete extra files in the target directory.

### Dry Run

Preview changes without writing files:

```bash
scripts/sync-from-codex.sh --dry-run
```

### Sync Specific Skills

```bash
scripts/sync-from-codex.sh review-pr tech-plan
```

### Include System Skills

To also copy `.system` skills:

```bash
scripts/sync-from-codex.sh --include-system
```

### Mirror Target with Source

Use `--delete` when the target skill directory should match the source exactly and files that no longer exist in the source should be removed from the target:

```bash
scripts/sync-from-codex.sh --delete
```

Use this option carefully because it can delete files inside the target skill directory.

## Script Options

```text
Usage: scripts/sync-from-codex.sh [options] [skill ...]

Options:
  --source DIR       Source skills directory (default: ~/.codex/skills)
  --target DIR       Target skills directory (default: ./skills)
  --include-system   Also copy .system skills
  --delete           Delete files in the target skill that no longer exist in source
  -n, --dry-run      Show what would be copied without changing files
  -h, --help         Show help
```

## Development Notes

- Do not edit `.system` unless this project intentionally needs to store system skills.
- Run `scripts/sync-from-codex.sh --dry-run` before large syncs.
- After changing the shell script, validate its syntax with:

```bash
bash -n scripts/sync-from-codex.sh
```
