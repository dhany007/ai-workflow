---
name: frontend-build-resolver
description: Resolve web frontend lint, typecheck, test, dev-server, bundler, SSR, CSS, or production build failures with a minimal scoped fix. Use for browser apps; use react-native-patterns for Metro, native build, and React Native runtime failures.
---

# Frontend Build Resolver

Use this skill to diagnose and fix frontend validation failures with a narrow, evidence-first loop. Prefer the repository's configured package manager, scripts, framework, TypeScript version, and test runner over generic commands.

Primary references when current behavior is uncertain:

- React docs - https://react.dev/learn
- Next.js docs - https://nextjs.org/docs
- Vite guide - https://vite.dev/guide/
- TypeScript docs - https://www.typescriptlang.org/docs/
- Testing Library docs - https://testing-library.com/docs/
- Playwright docs - https://playwright.dev/docs/intro

## Orientation

Before changing files, inspect:

- `package.json` scripts and package manager hints.
- Lockfiles: `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, or `bun.lockb`.
- Node/runtime hints: `.nvmrc`, `.node-version`, `engines`, Dockerfile, CI workflow.
- `tsconfig*.json`, framework config, Vite/Next config, ESLint/Biome/Prettier config, PostCSS/Tailwind config, and test config.
- The exact failing command and whether it is local, CI-only, or triggered by a specific file.

Do not update dependencies, regenerate lockfiles, or rewrite config unless the failure points there or the user asked for it.

## Resolution Loop

1. Reproduce the smallest failing command when practical.
2. Read the first meaningful error, not only the last line.
3. Classify the failure: typecheck, lint, build/bundler, SSR/hydration, test, CSS pipeline, env/config, dependency resolution, or generated artifacts.
4. Read the owning files and nearby patterns.
5. Apply the smallest fix that preserves user-facing behavior unless behavior is the bug.
6. Rerun the focused command. Broaden validation only when the fix touches shared code.
7. If unrelated baseline failures remain, report them separately and do not refactor around them.

## Failure Classes

### Typecheck

- Prefer fixing the real contract over adding `any`, broad casts, or non-null assertions.
- Use `typescript-patterns` when the issue involves API boundaries, generics, unions, React props, async result types, or generated clients.
- Check whether the error is caused by missing generated types, stale build artifacts, path aliases, module resolution, or incompatible library versions.

### Lint And Format

- Follow the repo's tool: ESLint, Biome, Prettier, framework lint, or custom scripts.
- Keep auto-fixes scoped to touched files when possible.
- Treat rules about hooks, accessibility, import boundaries, unused exports, and unsafe types as correctness signals before style signals.

### Build And Bundler

- For Vite/Webpack/Turbopack/Rollup errors, identify whether the issue is module format, aliasing, dynamic import, CSS processing, asset path, environment variable exposure, or plugin order.
- For Next.js, distinguish server/client component boundaries, route conventions, metadata, dynamic rendering, caching, and edge/runtime constraints.
- For production-only errors, check tree shaking, SSR-only globals, browser-only APIs, environment variables, and minification-sensitive code.

### SSR And Hydration

- Look for nondeterministic render output: dates, random values, locale formatting, browser-only state, layout measurements, and storage reads during render.
- Move browser-only reads into effects or client-only boundaries consistent with the framework.
- Preserve semantic HTML and stable markup; do not silence hydration warnings without addressing the mismatch.

### Tests

- For Testing Library failures, inspect accessible roles/names and real user behavior before changing selectors.
- For Vitest/Jest failures, check module mocks, fake timers, async `act`, environment setup, and test isolation.
- For Playwright/Cypress failures, separate app failure, timing issue, selector fragility, network mock drift, viewport issue, and browser dependency issue.
- Prefer fixing the product behavior or test setup over weakening assertions.

### CSS And Assets

- Check PostCSS/Tailwind versions, config file names, content scanning, CSS module conventions, font/image imports, and asset path handling.
- Avoid one-off CSS fixes that bypass design-system tokens unless the project has no token system.

## Validation

- Use the same package manager already used by the repo.
- Start with the failing command, then run adjacent checks only when the change has broader impact.
- If install or network access is required, ask for approval through the available command mechanism.
- Summarize final evidence with the command, result, and any remaining baseline issue.

## Anti-Patterns

- Deleting lockfiles to "fix" dependency issues without proof.
- Installing a new package for a failure that can be fixed with existing tooling.
- Replacing strict type errors with `any`.
- Disabling lint rules globally to pass one file.
- Changing test assertions until they match broken behavior.
- Broad config rewrites during a local component fix.

## Review Guidance

When reviewing a frontend build fix, lead with whether the root cause is actually resolved, whether validation was scoped correctly, and whether the change hides errors through casts, disabled rules, weakened tests, or dependency churn.
