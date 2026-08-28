---
name: figma-to-code
description: Implement a supplied Figma frame in the current web project with Figma fidelity, repository-native patterns, an approval-required plan, and visual validation. Use when a user supplies a Figma node or frame link and asks to build it as code; do not use for Figma-only design edits.
---

# Figma To Code

Implement the specified Figma node in the current project. The Figma frame is the source of truth for its matching viewport or variant; preserve the project's existing UI system and behavior.

## Required inputs and boundaries

- Require a Figma URL that identifies the target node or frame (normally a `node-id` query parameter). If it is missing or cannot be resolved, ask for the exact link; do not select a frame by guesswork.
- Treat the request as an implementation request, not authorization to change routes, APIs, state management, validation, preview, submission behavior, dependencies, or configuration beyond what the approved plan requires.
- Preserve unrelated work already present in the worktree.
- This skill is an orchestration layer over `figma:figma-design-to-code`. Load and follow that skill before calling its Figma design-context tools.

## Discovery before any mutation

1. Use `get_design_context` for the exact supplied Figma node or frame, then use `get_screenshot` for that same target. Inspect any assets, component bindings, variables, and responsive variants shown by Figma.
2. Inspect the repository read-only: application structure, routing, existing components and design tokens, assets, styling conventions, state and data-fetching patterns, form behavior, and relevant unit, type, lint, and Playwright test patterns.
3. Do not edit files, apply patches, install packages, create or update tests, or change configuration during this phase.

If Figma access, an asset, a target variant, or the local application needed for validation is unavailable, explain the specific gap in the plan and stop for direction. Do not replace missing evidence with an invented design or behavior.

## Approval-required implementation plan

Before changing any file, present a concrete plan containing:

- files to add or modify;
- existing components, tokens, assets, and conventions to reuse;
- desktop, tablet, and mobile layout rules, including the source Figma variant for each;
- exact responsive breakpoints, grid columns, dimensions, wrapping, scrolling, and overflow behavior;
- validation commands and the intended Figma and mobile viewport Playwright coverage; and
- every proposed deviation from Figma, with reason and visual or behavioral impact.

Do not infer intermediate breakpoints, alter grid counts, reorder sections, hide content, or substitute different responsive behavior. When Figma does not show a responsive variant, keep the desktop frame unchanged at its intended viewport and propose the separate mobile strategy explicitly for approval.

Wait for explicit approval of the plan. Approval applies only to the plan presented: a later scope, breakpoint, responsive-behavior, or visual-deviation change requires a revised plan and fresh approval.

## Implementation and verification after approval

- Implement only the approved plan, reusing repository-native components, tokens, assets, routing, API contracts, state management, validation, preview, and submit behavior.
- Add or update tests only where the repository has a relevant test pattern or where the approved plan calls for them.
- Run focused unit, type, lint, and build checks relevant to the changed code.
- Use the repository's Playwright setup to test the Figma viewport and an approved mobile viewport. If Playwright is absent, this must have been surfaced and approved in the plan before adding or configuring it.
- Capture the resulting screenshots and compare them with the Figma reference. Report validation evidence and all remaining differences, distinguishing approved deviations from unexpected ones.
