---
name: effective-python
description: Apply deeper Effective Python style judgment from prompts such as "effective-python", "/effective-python", "make this Python more effective", "review Python idioms", "improve Python API design", "refactor Python for maintainability", or when Codex is reviewing or refining Python code beyond basic style. Use when Codex should improve Python API clarity, data modeling, iteration, resource management, exceptions, typing, protocols, object design, imports, concurrency, performance tradeoffs, and maintainability while following repository conventions and the active Python version.
---

# Effective Python

## Principle

Effective Python code makes intent obvious, keeps boundaries explicit, and uses Python's strengths without turning idioms into cleverness.

Follow repository conventions and the declared Python version first. Treat this skill as deeper review and refinement guidance that complements `python-patterns`, not as a replacement for local style or framework rules.

## Scope

Use this skill when the task is about improving Python quality after the basic design is clear:

- API shape and call-site readability
- refactoring Python that works but feels awkward
- replacing brittle dynamic code with explicit structure
- choosing dataclasses, protocols, functions, classes, or modules
- improving iteration, resource handling, error translation, and imports
- reviewing performance tradeoffs without premature optimization

For broad implementation guidance, use `python-patterns`. For test strategy, use `python-testing`.

## API Design

- Design APIs around clear call sites.
- Prefer explicit names over comments that explain ambiguous parameters.
- Avoid boolean traps in public functions when separate methods, enums, literals, or config objects communicate intent better.
- Keep return types predictable. Avoid returning unrelated shapes from the same function.
- Use `None` deliberately and make caller handling clear.
- Use sentinel objects only when `None` is a valid value and the distinction matters.
- Prefer small, composable functions over functions with many optional modes.
- Make expensive, stateful, or IO-heavy behavior visible in the API name or boundary.

Example:

```python
_MISSING = object()


def get_setting(name: str, default: object = _MISSING) -> object:
    if name in settings:
        return settings[name]
    if default is not _MISSING:
        return default
    raise KeyError(name)
```

## Data Modeling

- Convert loosely shaped external data into named types near the boundary.
- Use dataclasses for simple internal records with clear invariants.
- Use `frozen=True` when mutation would make reasoning harder.
- Use `Enum`, `StrEnum`, `Literal`, or small value objects for finite states and easy-to-confuse values.
- Use Pydantic or the repository's validation library for external payloads, settings, and coercion-heavy validation when already present.
- Keep validation close to construction.
- Avoid passing large `dict[str, Any]` values through core logic.
- Prefer composition over inheritance unless the subtype relationship is real and useful.

## Iteration and Collections

- Use comprehensions for simple transformations; expand to loops when filtering, branching, side effects, or error handling becomes non-obvious.
- Use generators and iterators for streaming or large inputs.
- Return concrete collections when callers need random access, length, reuse, or stable snapshots.
- Use `dict`, `set`, `Counter`, `defaultdict`, and `heapq` when they express the data problem clearly.
- Avoid materializing large intermediate lists only to iterate once.
- Use `enumerate`, `zip`, `sorted(key=...)`, and unpacking when they make intent clearer.
- Use assignment expressions sparingly and only when they improve readability.

## Exceptions and Resource Management

- Raise specific exceptions and translate lower-level errors at domain or application boundaries.
- Chain exceptions with `raise ... from exc` when preserving cause helps diagnosis.
- Do not use exceptions for ordinary successful alternatives when a clear return type is simpler.
- Use context managers for files, clients, locks, transactions, temporary directories, and other resources.
- When writing custom context managers, make cleanup reliable with `try` / `finally`.
- Avoid import-time IO, network calls, logging configuration, and global client construction.
- Keep library code from calling `sys.exit`, printing, or configuring root logging.

## Typing as Design

- Use types to document contracts that matter, not to decorate every local variable.
- Prefer `collections.abc` input abstractions such as `Iterable`, `Sequence`, `Mapping`, and `Callable` when concrete containers are unnecessary.
- Use `Protocol` when behavior matters more than concrete inheritance.
- Use overloads only when they accurately model real call shapes and improve callers.
- Keep `Any`, `cast`, and `# type: ignore` narrow and justified.
- Do not contort simple runtime code only to satisfy a type checker; improve the model or add a focused boundary adapter.
- Respect the project's configured type checker and strictness level.

Protocol shape:

```python
from typing import Protocol


class Clock(Protocol):
    def now(self) -> datetime:
        ...


def expires_at(clock: Clock, ttl: timedelta) -> datetime:
    return clock.now() + ttl
```

## Object Design

- Use functions for stateless behavior.
- Use classes when state, invariants, lifecycle, or protocol implementation justify them.
- Keep constructors simple. Put complex creation behind named constructors or builders only when they clarify real complexity.
- Prefer dependency injection for clients, repositories, clocks, random sources, and configuration when it improves tests or ownership.
- Avoid broad base classes, mixins, metaclasses, descriptors, and monkeypatching unless the project already uses them for a clear reason.
- Keep properties cheap and unsurprising. Use methods for expensive, IO-heavy, or failure-prone work.
- Make mutation explicit. Avoid hidden mutation through shared defaults, cached globals, or reused mutable fixtures.

## Imports and Modules

- Keep module imports boring and acyclic.
- Prefer explicit imports over wildcard imports.
- Avoid heavy work in `__init__.py`; keep package exports deliberate.
- Split modules by ownership and domain when files become hard to scan.
- Avoid `utils` dumping grounds unless the repository already has a clear convention.
- Move shared behavior to a named module only when the abstraction is real.
- Keep CLI, framework, persistence, domain, and external-service adapters separated when the project already has those boundaries.

## Concurrency and Async

- Use async only when the stack or operation is genuinely asynchronous.
- Do not block event loops with blocking HTTP clients, heavy filesystem work, CPU-bound loops, or `time.sleep`.
- Keep task ownership and cancellation behavior clear.
- Share async clients or sessions according to library lifecycle guidance.
- Avoid unbounded task, thread, or process fan-out.
- Use processes for CPU-bound work only when serialization and startup cost are acceptable.
- Keep locks and shared mutable state small and obvious.

## Performance Judgment

- Prefer clear Python first, then measure.
- Use generators, streaming, indexing structures, caching, or vectorized libraries only when they fit the measured problem.
- Avoid micro-optimizations that make code harder to reason about.
- Use `__slots__`, caching, multiprocessing, C-extension-backed libraries, or batch APIs only when the need is real and lifecycle/invalidation is clear.
- Check algorithmic complexity before tuning syntax.

## Anti-Patterns

Avoid:

- clever one-liners that hide business logic
- large functions with many optional modes
- public APIs with ambiguous booleans or shape-shifting returns
- untyped dictionaries flowing through core logic
- catching broad exceptions without a narrow fallback
- context managers that fail to clean up on exceptions
- import-time side effects
- inheritance where composition would be clearer
- global mutable clients, config, registries, caches, clocks, or random sources
- async wrappers around blocking code
- type ignores or casts that mask a poor boundary model
- broad refactors that do not improve the requested behavior

## Review Guidance

When applying Effective Python judgment, prioritize:

1. call-site clarity and stable API contracts
2. explicit data models and boundary validation
3. error translation and resource lifecycle
4. typing that improves contracts without obscuring runtime behavior
5. simple object design and dependency ownership
6. readable iteration and collection choices
7. import/module ownership and side-effect boundaries
8. performance only when the change or production path warrants it
