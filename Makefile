SYNC_SCRIPT := scripts/sync-from-codex.sh
AGENT_SYNC_SCRIPT := scripts/sync-agents-from-codex.sh
SKILLS ?=

.PHONY: help sync dry-run sync-skills sync-agents sync-notes sync-system sync-delete validate

help:
	@printf '%s\n' 'Available targets:'
	@printf '  %-14s %s\n' 'sync' 'Sync skills, agents, and notes from ~/.codex'
	@printf '  %-14s %s\n' 'dry-run' 'Preview sync changes without writing files'
	@printf '  %-14s %s\n' 'sync-skills' 'Sync skills only; optionally pass SKILLS="review-pr tech-plan"'
	@printf '  %-14s %s\n' 'sync-agents' 'Sync custom agent TOML files only'
	@printf '  %-14s %s\n' 'sync-notes' 'Sync notes only'
	@printf '  %-14s %s\n' 'sync-system' 'Sync skills, agents, notes, and .system skills'
	@printf '  %-14s %s\n' 'sync-delete' 'Mirror source to target with --delete'
	@printf '  %-14s %s\n' 'validate' 'Validate shell script syntax'

sync:
	$(SYNC_SCRIPT) $(SKILLS)
	$(AGENT_SYNC_SCRIPT)

dry-run:
	$(SYNC_SCRIPT) --dry-run $(SKILLS)
	$(AGENT_SYNC_SCRIPT) --dry-run

sync-skills:
	$(SYNC_SCRIPT) --skip-notes $(SKILLS)

sync-agents:
	$(AGENT_SYNC_SCRIPT)

sync-notes:
	$(SYNC_SCRIPT) --notes-only

sync-system:
	$(SYNC_SCRIPT) --include-system $(SKILLS)
	$(AGENT_SYNC_SCRIPT)

sync-delete:
	$(SYNC_SCRIPT) --delete $(SKILLS)
	$(AGENT_SYNC_SCRIPT) --delete

validate:
	bash -n $(SYNC_SCRIPT)
	bash -n $(AGENT_SYNC_SCRIPT)
