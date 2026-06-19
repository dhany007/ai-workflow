#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/sync-from-codex.sh [options] [skill ...]

Copy Codex skills and notes into this project.

Options:
  --source DIR       Source skills directory (default: ~/.codex/skills)
  --target DIR       Target skills directory (default: ./skills)
  --notes-source DIR Source notes directory (default: ~/.codex/notes)
  --notes-target DIR Target notes directory (default: ./notes)
  --skip-notes       Do not sync notes
  --notes-only       Sync notes without syncing skills
  --include-system   Also copy .system skills
  --delete           Delete target files that no longer exist in source
  -n, --dry-run      Show what would be copied without changing files
  -h, --help         Show this help

Examples:
  scripts/sync-from-codex.sh
  scripts/sync-from-codex.sh review-pr tech-plan
  scripts/sync-from-codex.sh --notes-only
  scripts/sync-from-codex.sh --skip-notes review-pr
  scripts/sync-from-codex.sh --dry-run --include-system
EOF
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd -- "$script_dir/.." && pwd)"

source_dir="${HOME}/.codex/skills"
target_dir="${project_root}/skills"
notes_source_dir="${HOME}/.codex/notes"
notes_target_dir="${project_root}/notes"
sync_skills=1
sync_notes=1
include_system=0
delete_extra=0
dry_run=0
skills=()

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
    --notes-source)
      if [[ $# -lt 2 ]]; then
        echo "error: --notes-source requires a directory" >&2
        exit 2
      fi
      notes_source_dir="$2"
      shift 2
      ;;
    --notes-target)
      if [[ $# -lt 2 ]]; then
        echo "error: --notes-target requires a directory" >&2
        exit 2
      fi
      notes_target_dir="$2"
      shift 2
      ;;
    --skip-notes)
      sync_notes=0
      shift
      ;;
    --notes-only)
      sync_skills=0
      sync_notes=1
      shift
      ;;
    --include-system)
      include_system=1
      shift
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
    --)
      shift
      while (($#)); do
        skills+=("$1")
        shift
      done
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      skills+=("$1")
      shift
      ;;
  esac
done

if ((sync_skills)) && [[ ! -d "$source_dir" ]]; then
  echo "error: source directory does not exist: $source_dir" >&2
  exit 1
fi

mkdir_args=(-p "$target_dir")
if ((sync_skills == 0)); then
  :
elif ((dry_run)); then
  printf 'Would ensure target directory exists: %s\n' "$target_dir"
else
  mkdir "${mkdir_args[@]}"
fi

rsync_args=(-a)
if ((delete_extra)); then
  rsync_args+=(--delete)
fi
if ((dry_run)); then
  rsync_args+=(--dry-run --itemize-changes)
fi

copy_skill() {
  local name="$1"
  local src="${source_dir}/${name}"
  local dst="${target_dir}/${name}/"

  if [[ ! -d "$src" ]]; then
    echo "warning: skill not found, skipped: $name" >&2
    return 0
  fi

  if [[ ! -f "${src}/SKILL.md" ]]; then
    echo "warning: missing SKILL.md, skipped: $name" >&2
    return 0
  fi

  printf 'Syncing %s\n' "$name"
  rsync "${rsync_args[@]}" "$src/" "$dst"
}

sync_notes_dir() {
  if ((sync_notes == 0)); then
    return 0
  fi

  if [[ ! -d "$notes_source_dir" ]]; then
    echo "warning: notes source directory not found, skipped: $notes_source_dir" >&2
    return 0
  fi

  if ((dry_run)); then
    printf 'Would ensure notes target directory exists: %s\n' "$notes_target_dir"
  else
    mkdir -p "$notes_target_dir"
  fi

  printf 'Syncing notes\n'
  rsync "${rsync_args[@]}" "$notes_source_dir/" "$notes_target_dir/"
}

if ((sync_skills)); then
  if ((${#skills[@]} == 0)); then
    while IFS= read -r -d '' skill_path; do
      skill_name="$(basename "$skill_path")"
      if [[ "$skill_name" == ".system" && "$include_system" -eq 0 ]]; then
        continue
      fi
      if [[ "$skill_name" == .* && "$skill_name" != ".system" ]]; then
        continue
      fi
      copy_skill "$skill_name"
    done < <(find "$source_dir" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
  else
    for skill_name in "${skills[@]}"; do
      if [[ "$skill_name" == ".system" && "$include_system" -eq 0 ]]; then
        echo "warning: .system skipped; pass --include-system to copy it" >&2
        continue
      fi
      copy_skill "$skill_name"
    done
  fi
fi

sync_notes_dir
