---
name: accessibility
description: Apply practical web accessibility guidance from prompts such as "accessibility", "/accessibility", "a11y review", "make this UI accessible", "fix keyboard navigation", "review ARIA", "WCAG", "screen reader", "focus management", or when Codex is implementing, testing, or reviewing user interfaces, forms, modals, dialogs, menus, tabs, navigation, tables, media, color, contrast, semantic HTML, keyboard behavior, accessible names, and dynamic UI announcements. Use when Codex should prioritize semantic HTML, keyboard support, focus management, labels, ARIA only when needed, WCAG-aligned behavior, and testable accessibility outcomes.
---

# Accessibility

Use this skill when UI behavior must work for keyboard users, screen reader users, low-vision users, motion-sensitive users, and people using assistive technology. Accessibility is product behavior, not a final polish pass.

Primary references when current behavior is uncertain:

- WCAG 2.2 Quick Reference - https://www.w3.org/WAI/WCAG22/quickref/
- WAI-ARIA Authoring Practices Guide - https://www.w3.org/WAI/ARIA/apg/
- MDN Accessibility - https://developer.mozilla.org/en-US/docs/Web/Accessibility

## Repository Orientation

Before editing UI, inspect the local project shape:

- Existing design-system components, shared form fields, dialogs, menus, tabs, tables, tooltips, and routing primitives.
- Test setup for Testing Library, Playwright, Cypress, axe, Storybook, or design-system accessibility checks.
- Styling tokens for color, focus rings, disabled states, motion, spacing, and target sizes.
- Framework conventions for server/client components, hydration, portals, and route changes.

Prefer fixing or reusing shared primitives when the issue is systemic. Keep one-off fixes local when the component is truly isolated.

## Semantic HTML First

- Prefer native elements: `button`, `a`, `input`, `select`, `textarea`, `label`, `fieldset`, `legend`, `table`, `th`, `nav`, `main`, and headings.
- Use links for navigation and buttons for actions.
- Keep heading order meaningful; do not choose headings only for visual size.
- Preserve accessible names for controls through visible text, `aria-label`, `aria-labelledby`, or associated labels.
- Avoid replacing native controls with custom div/span widgets unless the design-system already provides a correct pattern.

## Keyboard And Focus

- Every interactive control must be reachable and operable by keyboard.
- Preserve visible focus indicators with enough contrast and a stable shape.
- Use logical tab order from DOM structure. Avoid positive `tabindex`.
- Manage focus for dialogs, popovers, route transitions, validation errors, and destructive confirmations.
- Escape should close dismissible overlays when that matches the component pattern.
- Do not trap focus unless the UI is modal; release focus back to a sensible trigger when it closes.

## Forms And Errors

- Associate labels with inputs. Use `fieldset` and `legend` for grouped choices.
- Mark required fields in both visual and programmatic ways when the distinction matters.
- Connect errors and help text with `aria-describedby` or the repo's form-field primitive.
- Make validation messages specific, persistent enough to read, and reachable after submit.
- Do not rely on placeholder text as the only label.

## ARIA Use

- Prefer semantic HTML before ARIA. ARIA should enhance semantics, not patch broken interaction behavior.
- Follow WAI-ARIA APG patterns for dialogs, tabs, menus, comboboxes, accordions, tooltips, and disclosure widgets.
- Keep role, state, and keyboard behavior aligned. A `role="button"` also needs button-like keyboard handling.
- Do not add redundant or conflicting roles to native elements.
- Use live regions sparingly for async status, toasts, search results, and background updates that users need to know about.

## Visual, Motion, And Content

- Check text/background contrast, focus contrast, disabled states, and icon-only controls.
- Do not use color alone to communicate status, errors, required fields, or selected state.
- Support zoom and responsive layouts without clipping, overlap, or hidden controls.
- Respect reduced-motion preferences for animations that can distract or disorient.
- Keep hit targets practical for touch and pointer use.
- Ensure images, icons, and charts have appropriate text alternatives or are hidden when decorative.

## Dynamic UI Patterns

- Dialogs: focus the dialog or first meaningful control, label the dialog, trap focus while open, restore focus on close.
- Menus and popovers: use the repo's proven primitive when available; align keyboard behavior with the chosen pattern.
- Tabs: keep selected state, focus behavior, and panel relationships coherent.
- Tables: use table semantics for tabular data, scoped headers, and captions or surrounding context.
- Toasts and async states: expose important status without interrupting unrelated work.
- Loading states: keep names and layout stable; avoid controls changing meaning while focused.

## Testing

- Prefer tests that query by role, label text, placeholder only when appropriate, visible text, or accessible name.
- Add keyboard-flow tests for dialogs, menus, forms, and custom controls.
- Use axe or equivalent when already configured, but do not treat automated checks as complete coverage.
- For high-risk UI, manually verify keyboard-only operation, focus order, focus restoration, and screen reader names where practical.

## Anti-Patterns

- Clickable `div` or `span` with no keyboard behavior.
- Icon-only controls without accessible names.
- Removing outlines without an equivalent visible focus indicator.
- `aria-hidden` on focusable or important content.
- Disabled-looking controls that remain interactive, or disabled controls without a discoverable reason.
- Modal overlays that leave background content reachable by keyboard.
- Custom widgets that copy visuals but not behavior.

## Review Guidance

When reviewing accessibility, lead with issues that block operation, hide information, break focus, mislabel controls, or create WCAG-aligned user harm. Provide concrete fixes tied to the component pattern already used in the repository.
