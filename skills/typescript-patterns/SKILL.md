---
name: typescript-patterns
description: Apply practical TypeScript type-design and code-quality patterns from prompts such as "typescript-patterns", "/typescript-patterns", "implement TypeScript", "review TS/TSX", "fix type error", "improve type safety", "design TypeScript API", or when Codex is planning, implementing, testing, or reviewing TypeScript, TSX, React props, hooks, generated clients, API boundaries, async code, or strict-mode-aware code. Use when Codex should apply safe narrowing, discriminated unions, useful generics, runtime boundary validation, maintainable API types, and repository-aligned TypeScript tooling.
---

# TypeScript Patterns

Use this skill to make TypeScript code safer, clearer, and easier to change without turning the type system into ceremony. Follow the repository's installed TypeScript version, `tsconfig`, framework, and lint rules before introducing new conventions.

Primary references when current behavior is uncertain:

- TypeScript Handbook: Everyday Types - https://www.typescriptlang.org/docs/handbook/2/everyday-types.html
- TypeScript Handbook: Narrowing - https://www.typescriptlang.org/docs/handbook/2/narrowing.html
- TypeScript `strict` option - https://www.typescriptlang.org/tsconfig/strict.html

## Repository Orientation

Before changing TypeScript, inspect the local project shape:

- `package.json` scripts for `typecheck`, `lint`, `test`, and `build`.
- `tsconfig*.json` for `strict`, module target, JSX mode, path aliases, and included files.
- Existing ESLint, Biome, Prettier, framework, and generated-type conventions.
- Current patterns for API clients, schema validators, form models, React props, and error/result handling.

Prefer existing local conventions when they are sound. If a convention is unsafe, make the smallest improvement that fits the surrounding code.

## Type Design

- Let TypeScript infer obvious local variables; annotate public APIs, exported functions, callbacks, component props, and data crossing module boundaries.
- Prefer `unknown` over `any` at untrusted boundaries, then narrow or validate before use.
- Model finite states with unions, especially discriminated unions for async states, UI variants, domain events, and result-like flows.
- Use optional properties intentionally. Distinguish "not provided" from "provided as undefined" when API behavior depends on it.
- Prefer precise literal unions over broad `string` values when the set of allowed values is known.
- Use `readonly` for data that should not be mutated, especially props, config, and lookup tables.
- Keep exported types stable and readable. Avoid clever conditional or mapped types unless they remove real duplication or encode an important invariant.

## Narrowing And Boundaries

- Validate external data from network, storage, environment variables, URL params, `postMessage`, JSON parsing, and user-controlled inputs.
- Narrow with `typeof`, `instanceof`, `in`, equality checks, discriminants, schema validators, or focused user-defined type guards.
- Treat `as` casts as a last resort. If a cast is unavoidable, keep it local and explain the boundary it protects.
- Do not hide unsafe values behind non-null assertions. Prefer explicit guards, early returns, or invariant checks.
- For generated API types, do not duplicate hand-written versions unless the local abstraction intentionally reshapes the contract.

## Functions And APIs

- Design function signatures around the caller's mental model, not around current implementation details.
- Avoid boolean traps in public APIs; use named options or discriminated unions when behavior branches are meaningful.
- Return explicit domain values for expected states. Throw only for exceptional or locally conventional error behavior.
- Use `Promise<T>` precisely. Avoid losing failure semantics in `Promise<any>` or untyped async wrappers.
- Use overloads sparingly. Prefer unions or generics when they produce clearer call sites.
- Keep generic type parameters meaningful. If `T` appears only once, it is probably not carrying useful information.

## React And TSX

- Define component props as explicit object types or interfaces consistent with the repo style.
- Use discriminated prop unions for mutually exclusive variants, modes, and controlled/uncontrolled forms.
- Type `children` only when the component actually accepts children; use `ReactNode` for renderable content.
- Type events from the element being handled, such as `React.ChangeEvent<HTMLInputElement>`.
- Avoid passing `any` through component props, hook returns, context values, or form state.
- For `forwardRef`, imperative handles, and polymorphic components, follow existing design-system patterns; do not invent a broad abstraction for one component.

## Tooling And Validation

- Do not change strictness flags broadly unless the task is specifically about TypeScript configuration.
- When possible, run the narrowest configured validation first, such as `pnpm typecheck`, `npm run typecheck`, `yarn typecheck`, `tsc --noEmit`, or the repo's documented equivalent.
- If validation fails, separate new errors from pre-existing baseline errors before changing unrelated files.
- Keep generated files and lockfiles untouched unless the task requires regenerating them.

## Anti-Patterns

- `any` as a convenience instead of a temporary boundary.
- Large exported utility types that nobody can read at call sites.
- Type assertions that contradict runtime behavior.
- Parallel hand-written API types that drift from generated or schema-derived contracts.
- Using enums, classes, or namespaces where the repo consistently uses unions, plain objects, and modules.
- Making the compiler happy while preserving an invalid runtime state.

## Review Guidance

When reviewing TypeScript, lead with risks that can create runtime bugs, contract drift, unreachable UI states, unsafe casts, or confusing public APIs. Mention style-only concerns only after correctness and maintainability issues.
