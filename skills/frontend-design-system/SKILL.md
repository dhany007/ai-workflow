---
name: frontend-design-system
description: Apply design-system guidance to reusable web UI primitives, design tokens, variants, themes, responsive behavior, and component documentation. Use for browser interfaces; use react-native-patterns for native component and StyleSheet systems.
---

# Frontend Design System

Use this skill when UI work should become a reusable, consistent component or when a change affects shared styling, tokens, variants, or visual language. Treat a design system as production infrastructure for UI behavior, not a decorative layer.

Primary references when current behavior is uncertain:

- Storybook docs - https://storybook.js.org/docs
- W3C Design Tokens Community Group - https://www.w3.org/community/design-tokens/
- Tailwind CSS docs - https://tailwindcss.com/docs/installation/using-vite
- React docs - https://react.dev/learn

## Orientation

Before creating or changing shared UI, inspect:

- Existing components, primitives, variant helpers, CSS modules, theme files, token files, and Storybook/stories if present.
- Naming conventions for sizes, intents, tones, density, radius, spacing, shadows, typography, and motion.
- Accessibility primitives for labels, focus rings, dialogs, menus, tabs, tooltips, and form fields.
- Framework constraints: server/client boundaries, CSS-in-JS, Tailwind, CSS variables, module CSS, design tokens, or native styles.
- Existing visual states: hover, focus, active, disabled, loading, selected, invalid, empty, error, and skeleton.

Prefer improving existing primitives over adding parallel components.

## Component Decisions

- Add a shared component only when reuse, consistency, or behavior complexity justifies it.
- Keep one-off product layouts local; promote only stable patterns.
- Separate primitive behavior from page-specific copy, data fetching, and business logic.
- Expose props that represent product meaning, not raw internal CSS implementation.
- Model variants with clear names and typed unions when using TypeScript.
- Avoid boolean prop piles; prefer `variant`, `size`, `tone`, `density`, or composed components when the matrix grows.

## Tokens And Styling

- Use existing tokens for color, spacing, typography, radius, elevation, and motion.
- Introduce new tokens only when a repeated semantic need exists.
- Prefer semantic token names such as `danger`, `surface`, `muted`, `accent`, or `focus` over one-off color names.
- Keep responsive behavior encoded in layout primitives or component rules, not duplicated at every call site.
- Support dark mode or theme switching only through the repo's established theme mechanism.
- Do not hard-code brand colors, magic spacing, or fragile z-index values when token equivalents exist.

## States And Behavior

- Define all expected states before implementation: default, hover, focus, active, disabled, loading, selected, invalid, empty, and error.
- Preserve stable dimensions for controls, lists, and repeated items to avoid layout shifts.
- Keep icons, labels, helper text, and loading indicators from resizing controls unexpectedly.
- Ensure disabled and loading states communicate both visual state and actual interaction behavior.
- For forms, align labels, descriptions, errors, required markers, and validation state with shared form primitives.

## Accessibility Contract

- Use `accessibility` for semantic HTML, focus management, labels, ARIA, and keyboard behavior.
- Shared components must have accessible names, visible focus states, and keyboard behavior appropriate to their role.
- Icon-only buttons must require or derive accessible labels.
- Do not hide focus outlines unless the replacement is equally visible.
- Treat accessibility defects in shared primitives as high-blast-radius bugs.

## Documentation And Tests

- Add or update stories/examples when the repo uses Storybook or similar documentation.
- Include examples for important variants and states, not every impossible combination.
- Test behavior at the right layer: unit/component tests for props and interaction, visual tests for regression-prone appearance, E2E for integrated flows.
- Document constraints in code only when they prevent misuse that is not obvious from types or examples.

## Anti-Patterns

- Creating a new `Button`, `Modal`, or `Input` beside an existing usable primitive.
- Encoding page-specific business rules into shared components.
- Adding variants that are just arbitrary style overrides.
- Making a token for every value before it repeats.
- Building visual-only custom controls without keyboard and screen reader behavior.
- Letting component APIs mirror class names instead of product intent.

## Review Guidance

When reviewing design-system work, lead with reuse boundaries, variant clarity, token alignment, accessibility behavior, responsive stability, and whether the component API will stay understandable as product usage grows.
