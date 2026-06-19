SYNC_SCRIPT := scripts/sync-from-codex.sh
SKILLS ?=

.PHONY: help sync dry-run sync-skills sync-notes sync-system sync-delete validate

help:
	@printf '%s\n' 'Available targets:'
	@printf '  %-14s %s\n' 'sync' 'Sync skills and notes from ~/.codex'
	@printf '  %-14s %s\n' 'dry-run' 'Preview sync changes without writing files'
	@printf '  %-14s %s\n' 'sync-skills' 'Sync skills only; optionally pass SKILLS="review-pr tech-plan"'
	@printf '  %-14s %s\n' 'sync-notes' 'Sync notes only'
	@printf '  %-14s %s\n' 'sync-system' 'Sync skills, notes, and .system skills'
	@printf '  %-14s %s\n' 'sync-delete' 'Mirror source to target with --delete'
	@printf '  %-14s %s\n' 'validate' 'Validate shell script syntax'

sync:
	$(SYNC_SCRIPT) $(SKILLS)

dry-run:
	$(SYNC_SCRIPT) --dry-run $(SKILLS)

sync-skills:
	$(SYNC_SCRIPT) --skip-notes $(SKILLS)

sync-notes:
	$(SYNC_SCRIPT) --notes-only

sync-system:
	$(SYNC_SCRIPT) --include-system $(SKILLS)

sync-delete:
	$(SYNC_SCRIPT) --delete $(SKILLS)

validate:
	bash -n $(SYNC_SCRIPT)
