---
name: react-patterns
description: Apply practical React frontend engineering patterns from prompts such as "react-patterns", "/react-patterns", "implement React component", "review React code", "refactor TSX", "fix hooks", "design React state", "build React UI", or when Codex is planning, implementing, testing, or reviewing React, JSX, TSX, hooks, component composition, forms, accessibility, client/server boundaries, data fetching, and state management. Use when Codex should produce maintainable React 18/19 code while following the repository's framework, router, styling, state, data, testing, linting, and TypeScript conventions.
---

# React Patterns

## Principle

React UI should be declarative, accessible, predictable, and easy to change.

Prefer the repository's existing framework and conventions first: Next.js, Remix, React Router, TanStack Router, Vite, CRA, design system, styling approach, state library, data-fetching library, test runner, lint config, and supported React/TypeScript versions. Use these patterns as judgment, not as rigid rules.

## References

Use official/current docs as the baseline when details matter:

- React components and hooks purity: https://react.dev/reference/rules/components-and-hooks-must-be-pure
- Rules of Hooks: https://react.dev/reference/rules/rules-of-hooks
- You Might Not Need an Effect: https://react.dev/learn/you-might-not-need-an-effect
- Managing State: https://react.dev/learn/managing-state
- Suspense: https://react.dev/reference/react/Suspense
- Server Components: https://react.dev/reference/rsc/server-components

React features differ by version and framework. Check `package.json`, lockfiles, framework docs, and runtime constraints before using React 19 APIs, Server Components, Server Functions, React Compiler, or framework-specific form/data patterns.

## Repository Orientation

- Inspect `package.json`, lockfile, `tsconfig`, bundler/framework config, ESLint config, test config, routes, design system, and existing components before changing patterns.
- Follow local naming, file organization, styling, component export, provider, and test conventions.
- Do not introduce Redux, Zustand, Jotai, TanStack Query, SWR, React Hook Form, Tailwind, CSS-in-JS, Storybook, Playwright, or new UI libraries unless the repo already uses them or the user approves.
- Keep changes scoped. Avoid broad component rewrites, styling churn, or state-management migration unless the request requires it.
- Prefer TypeScript for new React code when the repo uses TS/TSX.

## Component Design

- Keep render pure: calculate JSX from props, state, and context without side effects.
- Do not mutate props, state, context values, or module-level values during render.
- Derive render-only values during render instead of storing them in state.
- Use event handlers for user-triggered effects and `useEffect` for synchronization with external systems.
- Compose with `children`, named slots, component props, or small components before introducing context or global state.
- Keep components small enough to scan, but avoid splitting every DOM fragment into a component.
- Use semantic HTML before ARIA roles.
- Make loading, empty, error, disabled, pending, and unauthorized states explicit where users can encounter them.

## Hooks Discipline

- Call hooks only at the top level of React functions or custom hooks.
- Keep dependency arrays honest; do not silence hook lint rules without a narrow reason.
- Use functional state updates when the next value depends on the previous value.
- Extract a custom hook when it names reusable stateful behavior, not merely to hide complexity.
- Clean up subscriptions, timers, observers, event listeners, and async work when the lifecycle requires it.
- Avoid `useEffect` for derived data, event-specific logic, or resetting state when keys or render-time derivation solve the problem.
- Use `useMemo` and `useCallback` only when identity stability or expensive calculation matters for this component tree. Do not memoize by reflex.
- Use refs for imperative DOM access or mutable values that should not cause re-renders.

## State Management

Choose the narrowest state owner that satisfies the UI:

```text
single component -> local state
nearby components -> lift to nearest common parent
many distant consumers, low-frequency changes -> context
high-frequency shared state -> external store if already used or approved
server-derived data -> framework loader/RSC/TanStack Query/SWR based on repo convention
```

- Store minimal state. Prefer IDs and derived selections over duplicated objects.
- Avoid keeping server data, cache data, and local UI data in the same state bucket.
- Split contexts by concern and update frequency.
- Keep provider scope as small as practical.
- Prefer reducers when many related transitions must preserve invariants.

## Data Fetching

- Follow the framework's data model first: server loaders, route loaders, Server Components, Server Functions, or client cache library.
- Avoid ad hoc `useEffect` plus `fetch` for shared application data when the repo already has a data layer.
- Handle loading, empty, error, retry, and stale states deliberately.
- Abort or ignore obsolete client requests when the user can change inputs quickly.
- Keep request parameters and cache keys stable and explicit.
- Do not leak secrets into Client Components or browser bundles.

## Forms and Mutations

- Use native form semantics when possible: labels, validation attributes, submit buttons, disabled/pending states, and `aria-describedby` for errors.
- Use controlled inputs when each keystroke drives UI, formatting, validation, or dependent state.
- Use uncontrolled inputs/FormData when the value is only needed on submit.
- Use React 19 `useActionState`, `useFormStatus`, or `useOptimistic` only when the project version and framework support the pattern.
- Use a form library only for real complexity: dynamic arrays, multi-step flows, complex validation, touched/dirty tracking, or heavy integrations.
- Validate at the trust boundary and display field-level errors close to the relevant control.
- Keep optimistic UI reversible and clear when a mutation fails.

## Server and Client Boundaries

- Use Server Components only when the framework supports them.
- Keep Client Components small and interactive; keep data-heavy and secret-bearing work on the server.
- Pass only serializable props from Server Components to Client Components.
- Do not import server-only modules into Client Components.
- Compose Server Components into Client islands through `children` or framework-supported boundaries.
- Authenticate and authorize Server Functions or Server Actions like public endpoints.
- Be deliberate about hydration mismatches; suppress them only on known divergent leaf nodes.

## Accessibility

- Prefer semantic elements: `button`, `a`, `form`, `label`, `fieldset`, `nav`, `main`, `header`, `footer`, `section`.
- Every interactive control must be keyboard reachable and have a visible or accessible name.
- Inputs need labels. Icon-only buttons need accessible names.
- Manage focus for modals, drawers, menus, route transitions, validation errors, and destructive confirmations.
- Respect reduced-motion preferences for animation-heavy UI.
- Use ARIA to supplement semantic HTML, not to replace it.
- Test with accessible queries and browser checks when behavior matters.

## TypeScript

- Type component props explicitly and keep prop shapes meaningful.
- Use discriminated unions for variant-driven components and state machines.
- Avoid broad `React.FC` defaults if local convention prefers plain functions.
- Prefer `React.ReactNode` for renderable children and precise event types for handlers.
- Keep generic components readable at call sites.
- Avoid `any`, broad casts, and non-null assertions unless the boundary is narrow and justified.

## Styling and Design Systems

- Follow the repo's styling system before adding a new one.
- Build reusable components around behavior and accessibility, not only appearance.
- Keep visual variants explicit and finite.
- Avoid hidden layout coupling between parent and child components.
- Preserve responsive constraints and text wrapping for real content.
- Do not create decorative UI that competes with task completion in operational apps.

## Performance

- Do not optimize prematurely; profile or identify a plausible hot path first.
- Use stable keys from domain IDs, not array indexes, when list identity matters.
- Keep expensive calculations pure and memoize only when they are expensive or identity-sensitive.
- Avoid unnecessary context fan-out and high-frequency global state.
- Virtualize long lists only when row count and row cost justify it.
- Split large routes and heavy components using the repo's bundler/framework conventions.
- Use `react-performance` for dedicated waterfall, bundle, rendering, and interaction reviews.

## Anti-Patterns

Avoid:

- side effects during render
- storing derived render values in state
- mutating props or state directly
- conditional hooks or hooks inside loops
- blanket `useMemo` / `useCallback`
- global state for local UI concerns
- unlabelled controls and clickable non-buttons
- importing server-only code into browser bundles
- raw client fetch effects for shared server state when a data layer exists
- suppressing lint, type, or hydration warnings without a narrow reason
- broad styling or state-management rewrites in feature work

## Review Guidance

When reviewing React code, prioritize:

1. user-visible correctness and state consistency
2. render purity, hooks rules, and effect necessity
3. accessibility and semantic HTML
4. server/client/data boundary safety
5. component API clarity and TypeScript contracts
6. testability and behavior-focused coverage
7. maintainability within the existing design system
8. performance only when relevant to the changed path
