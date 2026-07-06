---
name: react-testing
description: Apply behavior-focused React testing strategy from prompts such as "react-testing", "/react-testing", "test this React component", "write RTL tests", "fix flaky React test", "review React tests", "test custom hook", "mock React network requests", or when Codex is adding, debugging, or reviewing tests for React components, hooks, pages, forms, async UI, accessibility behavior, network interactions, and frontend user flows. Use when Codex should choose repository-standard Vitest/Jest/Testing Library/MSW/Playwright/Cypress patterns, write user-centered assertions, avoid brittle implementation tests, and run focused validation.
---

# React Testing

## Principle

React tests should prove what users can see and do, with the smallest reliable test layer.

Prefer the repository's existing test runner, DOM environment, helper wrappers, provider setup, network mocking approach, accessibility tooling, and E2E framework. Do not add Vitest, Jest, React Testing Library, MSW, axe, Playwright, Cypress, or coverage tooling unless the repo already uses it or the user approves.

## References

- Testing Library query priority: https://testing-library.com/docs/queries/about/
- user-event guidance: https://testing-library.com/docs/user-event/intro/
- MSW docs: https://mswjs.io/docs/

Use framework-specific docs for Next.js, Remix, React Router, TanStack Router, Storybook, Playwright, or Cypress when the repo uses those tools.

## Repository Orientation

- Inspect `package.json`, lockfile, test config, setup files, `test-utils`, existing mocks, CI, and examples before adding tests.
- Identify runner and environment: Vitest, Jest, jsdom, happy-dom, real browser component tests, Playwright, Cypress, or framework-specific test tools.
- Match local file naming, co-location, provider wrappers, mock reset, and assertion style.
- Prefer focused test commands before full-suite runs.
- Keep tests scoped to changed behavior; avoid large fixture or helper rewrites unless required.

## Test Strategy

- Test user behavior and observable outcomes, not component internals.
- Use component tests for forms, controls, rendering branches, async states, hooks, and provider-bound UI.
- Use hook tests when the hook exposes meaningful behavior independent of a component.
- Use Playwright/Cypress for full navigation flows, layout-sensitive behavior, browser APIs not modeled by jsdom, drag/drop, clipboard, downloads, popups, iframes, cross-origin behavior, and visual regression.
- Use regression tests for bugs: prove the bug fails first when practical, then fix.
- Cover happy path, important edge cases, loading, empty, error, disabled, pending, permission, and retry states when relevant.
- Avoid testing third-party component libraries directly; test your integration and user-facing behavior.

## React Testing Library

- Prefer accessible queries in this order: role/name, label text, placeholder when appropriate, visible text, display value, alt text, title, then test ID as a last resort.
- Use `screen` unless local scoping with `within` is clearer.
- Use `getBy*` for elements that must already exist, `queryBy*` for absence, and `findBy*` for async appearance.
- Use `userEvent.setup()` per test and `await` user interactions.
- Use `fireEvent` only for low-level events not covered by `userEvent`.
- Assert visible text, accessible state, form values, navigation effects, callback effects, or network-visible outcomes.
- Avoid `container.querySelector` unless semantic queries cannot express the user contract.

Example shape:

```tsx
test("submits the email change form", async () => {
  const user = userEvent.setup();
  const onSubmit = vi.fn();
  renderWithProviders(<EmailForm onSubmit={onSubmit} />);

  await user.type(screen.getByLabelText(/email/i), "ada@example.com");
  await user.click(screen.getByRole("button", { name: /save/i }));

  expect(onSubmit).toHaveBeenCalledWith({ email: "ada@example.com" });
});
```

## Providers and Test Utilities

- Use the repo's existing `renderWithProviders` or equivalent helper.
- Build wrappers from the same provider stack users get in production: router, query client, theme, i18n, auth, feature flags, form context, and state stores.
- Create fresh query clients, stores, routers, and caches per test unless shared immutable setup is intentional.
- Disable retries in test query clients when retry timing would make tests slow or flaky.
- Keep important scenario details visible in the test instead of hiding everything in factories.
- Reset mocks, timers, DOM, local storage, session storage, server handlers, and global state between tests.

## Network and Data Mocking

- Mock at the network or adapter boundary rather than mocking every hook or child component.
- Prefer MSW when the repo uses it because components and data libraries exercise realistic request behavior.
- Make unhandled requests fail loudly in unit/component tests when local convention supports it.
- Override handlers per test for error, empty, slow, and retry states.
- Avoid real network in component tests unless explicitly integration-scoped.
- Keep server data and client UI state separate in setup so tests can exercise loading and mutation behavior.

## Async UI

- Use `findBy*`, `waitFor`, or `waitForElementToBeRemoved` for async DOM changes.
- Do not use fixed sleeps for UI timing.
- Use fake timers only when the repo has a stable pattern for timers; restore them reliably.
- Assert intermediate states when they are user-visible: loading, pending, optimistic, disabled, rollback, retry, and error.
- Clean up subscriptions, observers, pending promises, and mock servers.
- Treat `act` warnings as bugs in the test or component; do not ignore them.

## Custom Hooks

- Test hooks through their public return API.
- Wrap hooks with the same providers they require.
- Use `act` for direct state-changing hook calls when needed.
- Prefer a small test component when the hook behavior is easier to prove through user interactions.
- Avoid testing hook implementation details such as internal state variables or effect counts.

## Accessibility Tests

- Accessible queries are the first accessibility check.
- Add axe/jest-axe/vitest-axe checks only when the repo already uses them or the user approves.
- Use browser/E2E checks for focus traps, keyboard navigation, reduced motion, responsive layout, and contrast where jsdom is insufficient.
- Assert labels, names, roles, descriptions, focus movement, and keyboard behavior for interactive components.

## TDD and Coverage

- Use RED/GREEN/refactor when the user asks, when fixing a bug, or when the behavior is risky enough to benefit from test-first work.
- Prove RED with a focused test that fails for the intended reason.
- Implement the smallest UI/code change needed for GREEN.
- Treat coverage as a signal for changed behavior, not a universal percentage target.
- Follow repo-enforced thresholds if they exist. Do not invent thresholds in a project that does not enforce them.

## Focused Commands

Use repo commands first. Common shapes:

```bash
npm test -- path/to/component.test.tsx
pnpm test path/to/component.test.tsx
pnpm vitest run path/to/component.test.tsx
pnpm jest path/to/component.test.tsx
pnpm playwright test path/to/spec.ts
```

Do not install or switch test runners without approval.

## Anti-Patterns

Avoid:

- testing implementation details instead of behavior
- mocking React, hooks, or child components by default
- assertions that only prove a mock was called
- brittle snapshots of rendered DOM
- fixed sleeps for async UI
- hidden global provider state shared across tests
- unhandled network calls that silently hit real services
- broad test helper rewrites during feature work
- skipping tests without explaining the blocking condition
- asserting exact DOM structure when users do not depend on it

## Review Guidance

When reviewing React tests, prioritize:

1. user behavior and visible outcomes are covered
2. accessibility queries and keyboard-relevant behavior are used
3. async, network, and provider state are deterministic
4. mocks and fakes sit at appropriate boundaries
5. tests cover loading, empty, error, pending, and failure states when relevant
6. test helpers are readable and reset state
7. test commands match repository tooling
8. coverage gaps are reported honestly without arbitrary thresholds
