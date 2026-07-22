#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/sync-agents-from-codex.sh [options]

Copy personal Codex custom-agent TOML files into this project.

Options:
  --source DIR  Source agents directory (default: ~/.codex/agents)
  --target DIR  Target agents directory (default: ./agents)
  --delete      Delete target TOML files that no longer exist in source
  -n, --dry-run Show what would be copied without changing files
  -h, --help    Show this help

Examples:
  scripts/sync-agents-from-codex.sh
  scripts/sync-agents-from-codex.sh --dry-run
  scripts/sync-agents-from-codex.sh --delete
EOF
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd -- "$script_dir/.." && pwd)"

source_dir="${HOME}/.codex/agents"
target_dir="${project_root}/agents"
delete_extra=0
dry_run=0

while (($#)); do
  case "$1" in
    --source)
      if [[ $# -lt 2 ]]; then
        echo "error: --source requires a directory" >&2
        exit 2
      fi
      source_dir="$2"
      shift 2
      ;;
    --target)
      if [[ $# -lt 2 ]]; then
        echo "error: --target requires a directory" >&2
        exit 2
      fi
      target_dir="$2"
      shift 2
      ;;
    --delete)
      delete_extra=1
      shift
      ;;
    -n|--dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! -d "$source_dir" ]]; then
  echo "warning: agents source directory not found, skipped: $source_dir" >&2
  exit 0
fi

if ((dry_run)); then
  printf 'Would ensure target directory exists: %s\n' "$target_dir"
else
  mkdir -p "$target_dir"
fi

rsync_args=(-a --include='*.toml' --exclude='*')
if ((delete_extra)); then
  rsync_args+=(--delete)
fi
if ((dry_run)); then
  rsync_args+=(--dry-run --itemize-changes)
fi

printf 'Syncing custom agents\n'
rsync "${rsync_args[@]}" "$source_dir/" "$target_dir/"
