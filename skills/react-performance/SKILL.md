---
name: react-performance
description: Apply React and Next.js frontend performance review patterns from prompts such as "react-performance", "/react-performance", "optimize React performance", "fix slow React page", "reduce React bundle", "review rendering performance", "fix React waterfall", "improve Core Web Vitals", or when Codex is implementing, reviewing, or refactoring React, TSX, Next.js, Remix, route, data fetching, Suspense, hydration, bundle, rendering, list, animation, and interaction performance. Use when Codex should prioritize measured user impact, remove waterfalls, reduce unnecessary client JavaScript, avoid render cascades, and choose scoped validation without premature optimization.
---

# React Performance

## Principle

Optimize the user journey first: remove obvious waterfalls, avoid unnecessary JavaScript, keep interactions responsive, and measure before adding complexity.

Prefer the repository's existing framework, bundler, data layer, profiler, analytics, Web Vitals, and CI performance checks. Do not add bundle analyzers, performance libraries, virtualization, service workers, React Compiler, or caching layers unless the repo already uses them or the user approves.

## References

- React purity and render model: https://react.dev/reference/rules/components-and-hooks-must-be-pure
- You Might Not Need an Effect: https://react.dev/learn/you-might-not-need-an-effect
- Suspense: https://react.dev/reference/react/Suspense
- Server Components: https://react.dev/reference/rsc/server-components

Use Next.js, Remix, Vite, TanStack Query, SWR, router, and deployment-provider docs when those tools own the performance behavior.

## Repository Orientation

- Inspect `package.json`, lockfile, framework config, bundler config, route structure, server/client boundaries, data fetching layer, image/font/script handling, and existing monitoring before changing performance code.
- Identify the performance goal: LCP, INP, CLS, TTFB, bundle size, hydration cost, slow interaction, slow route transition, expensive render, or flaky loading.
- Prefer the smallest change that improves the measured or plausible bottleneck.
- Do not turn every component into memoized code. Manual optimization has maintenance cost.
- Validate with the repo's existing tools before adding new ones.

## Priority Order

1. Correctness and accessibility must remain intact.
2. Remove data and code waterfalls.
3. Reduce unnecessary client JavaScript and hydration work.
4. Fix high-frequency render cascades and expensive components.
5. Improve long-list, layout, media, animation, and script behavior.
6. Micro-optimize JavaScript only after the bigger issues are handled.

## Waterfalls and Data Loading

- Start independent async work in parallel and await together.
- Move awaits into the branch that needs the result.
- Short-circuit cheap synchronous conditions before expensive async work.
- In server-capable frameworks, split independent async subtrees so the framework can stream or parallelize them.
- Place Suspense boundaries close enough to reveal useful content progressively, but reserve layout space to avoid jank.
- Avoid sequential per-item fetches; batch or parallelize with backpressure when appropriate.
- Use request-level deduplication/caching only when the framework or data layer supports it safely.

## Bundle and Client JavaScript

- Keep Server Components or server-rendered code on the server when supported.
- Mark Client Components only where interactivity requires it.
- Avoid importing server-only modules, heavy libraries, or broad barrel exports into client bundles.
- Prefer direct imports for heavy component libraries when local bundler behavior benefits from them.
- Dynamically import route-local heavy UI such as charts, editors, maps, code highlighters, and rarely used dialogs.
- Load third-party scripts after critical rendering unless they are required for the initial user journey.
- Remove unused dependencies and duplicate packages only after checking lockfile and bundler evidence.

## Rendering and Re-Renders

- Keep render pure and avoid state updates from effects for derived values.
- Put state as low in the tree as practical.
- Split context by concern and update frequency.
- Subscribe to the smallest external-store slice needed by the component.
- Memoize only when props are usually stable and render work is meaningful.
- Stabilize callbacks only when identity is passed to memoized children, context, or effect dependencies.
- Avoid defining components inside components when it remounts child state or defeats reconciliation.
- Use stable domain keys for lists; avoid array indexes when item identity can change.

## Lists, Layout, and Visual Stability

- Virtualize long or expensive lists when rendering visible rows is the bottleneck.
- Reserve image, media, ad, skeleton, and async content dimensions to avoid layout shift.
- Use framework image/font/script primitives when the repo already relies on them.
- Use CSS containment or `content-visibility` only when browser support and layout constraints are acceptable.
- Respect reduced motion and avoid animation that blocks input.
- Prefer transform/opacity animations for frequent visual changes.
- Keep modal, menu, and focus-management performance tied to accessibility behavior.

## Client Data and Mutations

- Use the repo's cache library for deduplication, retries, stale state, mutation invalidation, and optimistic updates.
- Avoid rolling custom global caches in components.
- Disable or tune retries in user-blocking flows when retries cause poor feedback.
- Keep optimistic updates reversible and scoped.
- Abort obsolete client requests for rapidly changing inputs when the data layer does not handle it.
- Use transitions or deferred values for non-urgent UI updates when React version and UX fit.

## Server and RSC Performance

- Apply this section only when the framework supports server rendering or React Server Components.
- Keep secrets, database calls, and large data processing on the server.
- Pass minimal serializable props to Client Components.
- Avoid duplicate serialization of the same large payload to many client islands.
- Authenticate and authorize Server Functions/Actions before doing work.
- Avoid mutable module-level request state on the server.
- Defer non-critical analytics, logging, or cache warming only with framework-supported APIs.

## Measurement and Validation

- Use production builds for meaningful performance checks when possible.
- Prefer existing repo commands: build, preview, analyze, Lighthouse, Web Vitals, browser traces, React Profiler, or CI perf checks.
- Common command shapes, only when configured:

```bash
pnpm build
pnpm analyze
pnpm test
pnpm playwright test
```

- Report what was measured, what improved, and what remains uncertain.
- If measurement is not feasible, explain the reasoning and the likely bottleneck clearly.

## Anti-Patterns

Avoid:

- optimizing before preserving correctness and accessibility
- sequential awaits for independent work
- moving everything into Client Components
- broad barrel imports that inflate client bundles
- global context for high-frequency state
- blanket memoization
- derived state updated in effects
- fixed sleeps or loading hacks that hide real latency
- suppressing hydration warnings broadly
- importing large libraries for small utilities
- adding performance tooling or dependencies without repo convention or approval
- micro-optimizing loops while ignoring network, bundle, and render costs

## Review Guidance

When reviewing React performance, prioritize:

1. waterfalls and blocking data dependencies
2. client bundle size and hydration scope
3. server/client boundary mistakes
4. high-frequency re-render cascades
5. Suspense/loading/error placement and layout stability
6. slow interactions, long lists, animations, and media
7. cache, retry, and mutation behavior
8. JavaScript micro-performance only in proven hot paths

Use `react-patterns` for component design and `react-testing` for behavior coverage around performance-sensitive UI changes.
