---
name: python-patterns
description: Apply idiomatic Python backend and application patterns from prompts such as "python-patterns", "/python-patterns", "implement Python code", "review Python code", "refactor Python package", "design Python module", or when Codex is planning, implementing, testing, or reviewing Python changes. Use when Codex should apply practical Python judgment for typing, API boundaries, error handling, data modeling, package organization, dependency management, async/concurrency, testing patterns, tooling, performance tradeoffs, and anti-patterns while following the repository's existing conventions.
---

# Python Patterns

## Principle

Python code should be obvious at the call site, explicit at boundaries, and easy to test.

Prefer the repository's established patterns first. Use these patterns as judgment, not as rigid rules. Do not introduce a framework, tool, dependency, or abstraction just because it is common; use it when it removes real complexity or makes behavior clearer.

## Repository Orientation

- Inspect `pyproject.toml`, lockfiles, package manager config, test config, and existing modules before choosing tools or layout.
- Follow the Python version declared by the project before using newer syntax such as `X | None`, `typing.Self`, `StrEnum`, `TaskGroup`, or `ExceptionGroup`.
- Prefer `python -m <tool>` when invoking project tools if that matches local convention or avoids environment ambiguity.
- Do not add Black, Ruff, mypy, Pyright, pytest, Pydantic, FastAPI, Poetry, uv, or other tooling unless the repo already uses it or the user approves.
- Keep edits scoped to the requested behavior; avoid broad formatting, import churn, or package reshuffles unless required.

## Typing and API Boundaries

- Add type annotations to public functions, methods, dataclasses, service boundaries, and complex helpers.
- Let trivial local variables be inferred unless an annotation clarifies intent or fixes type narrowing.
- Prefer built-in generics (`list[str]`, `dict[str, int]`) when the supported Python version allows them.
- Prefer `collections.abc` abstractions (`Iterable`, `Iterator`, `Mapping`, `Sequence`, `Callable`) at input boundaries when concrete containers are unnecessary.
- Use `Protocol` for structural behavior when multiple implementations or tests need a real contract.
- Use `TypedDict`, dataclasses, Pydantic models, or domain objects instead of untyped `dict[str, Any]` at important boundaries.
- Keep `Any`, `cast`, and `# type: ignore` narrow, local, and justified.
- Return `None` deliberately; prefer explicit option-like return types and clear caller handling over sentinel ambiguity.
- Avoid boolean parameter traps in public APIs when enums, literals, separate methods, or small config objects make intent clearer.

Example:

```python
from collections.abc import Mapping


def display_name(user: Mapping[str, str]) -> str:
    first = user.get("first_name", "").strip()
    last = user.get("last_name", "").strip()
    return " ".join(part for part in (first, last) if part)
```

## Error Handling

- Raise specific exceptions for recoverable failures; do not use bare `except`.
- Chain exceptions with `raise ... from exc` when translating infrastructure errors into domain or application errors.
- Keep error messages actionable and include useful identifiers such as paths, IDs, remote operation names, or config keys.
- Do not silently swallow errors. If best-effort behavior is intended, make it explicit and log at the right boundary.
- Prefer simple APIs such as `mapping.get(key, default)` for ordinary lookup defaults; use EAFP when it makes the happy path clearer or avoids race-prone prechecks.
- Validate data at trust boundaries: external input, config, environment variables, request payloads, database rows, files, and third-party responses.
- Do not use `assert` for runtime validation in production code; assertions can be optimized away.
- Preserve cancellation semantics in async code; avoid broad `except Exception` around task bodies unless cancellation and cleanup are handled deliberately.

Example:

```python
from pathlib import Path
import json


class ConfigError(Exception):
    pass


def load_config(path: Path) -> dict[str, object]:
    try:
        raw = path.read_text(encoding="utf-8")
        return json.loads(raw)
    except FileNotFoundError as exc:
        raise ConfigError(f"config file not found: {path}") from exc
    except json.JSONDecodeError as exc:
        raise ConfigError(f"invalid JSON config: {path}") from exc
```

## Data Modeling

- Use dataclasses for lightweight internal records, especially when behavior is modest and validation is simple.
- Use `field(default_factory=...)` for mutable defaults.
- Prefer `frozen=True` when values should be immutable and identity mutation would be surprising.
- Use Pydantic or the repository's validation library for external payloads, settings, and data with coercion or rich validation needs when already present.
- Use `Enum`, `StrEnum`, `Literal`, or constrained domain types for finite states and values that should not be arbitrary strings.
- Avoid passing loosely shaped dictionaries through multiple layers; convert them near the boundary into named types.
- Keep model validation close to construction so invalid states do not travel through the system.

## Functions, Classes, and Modules

- Prefer small functions with explicit inputs and outputs.
- Keep side effects at clear boundaries: CLI entrypoints, handlers, repositories, adapters, workers, and integration layers.
- Avoid import-time side effects such as network calls, database connections, logging configuration, and environment mutation.
- Avoid global mutable state for clients, configuration, caches, registries, or clocks unless the project has a deliberate pattern for it.
- Inject dependencies through constructors or function parameters when it improves ownership, tests, or clarity.
- Use classes when state, invariants, or protocol implementation justify them; use functions or modules for stateless behavior.
- Keep decorators simple and transparent; preserve metadata with `functools.wraps`.
- Avoid clever comprehensions, metaprogramming, monkeypatching, or dynamic imports when straightforward code is clearer.

## Package Organization

- Follow existing repository layout before introducing a new layout.
- Prefer `src/` layout for new packages when the project already uses it or when starting a distributable package.
- Keep package and module names short, lowercase, and purpose-specific.
- Avoid vague dumping-ground modules like `utils`, `common`, or `helpers` unless the repo already has clear ownership for them.
- Keep `__init__.py` exports explicit and stable; avoid hiding heavy imports or side effects there.
- Separate transport adapters, domain logic, persistence, configuration, and CLI concerns when the repo already has those boundaries.
- Avoid circular imports by moving shared types to clear ownership modules or by narrowing dependencies.

## IO and Resources

- Prefer `pathlib.Path` for filesystem paths.
- Use context managers for files, locks, transactions, temporary directories, clients, and other owned resources.
- Specify text encodings for file IO, usually `encoding="utf-8"`.
- Use `tempfile` or pytest's `tmp_path` for temporary filesystem state.
- Do not log secrets, tokens, passwords, session cookies, private keys, or full unredacted request/response bodies.
- Keep logging configuration at application entrypoints, not library modules.

## Async and Concurrency

- Use async only when the surrounding stack or operation is genuinely asynchronous.
- Do not block the event loop with `time.sleep`, blocking HTTP clients, filesystem-heavy work, or CPU-heavy loops; use async equivalents or an executor when appropriate.
- Share async clients/sessions according to the library's lifecycle guidance instead of creating a new client for every request.
- Apply timeouts to network calls, external services, and long-running waits.
- Keep task ownership clear; await spawned tasks, collect failures, and avoid unbounded fan-out.
- Use `asyncio.TaskGroup` when supported and appropriate; otherwise handle `gather` results and exceptions deliberately.
- Use `ThreadPoolExecutor` for blocking IO only when needed, and `ProcessPoolExecutor` for CPU-bound work only when serialization and process startup costs are acceptable.
- Protect multiprocessing entrypoints with `if __name__ == "__main__":` when code may run on platforms that require it.
- Avoid holding locks across `await`.

## Testing Patterns

- Test behavior and contracts, not private implementation details.
- Use pytest conventions when the repo uses pytest; otherwise follow the existing test framework.
- Use parametrized tests for input/output variation.
- Use fixtures when they clarify setup, but keep important scenario details visible in the test.
- Use `tmp_path`, `monkeypatch`, `caplog`, fake clocks, local fakes, and in-memory adapters for deterministic tests when available.
- Use `pytest.raises(..., match=...)` or specific assertions to prove expected failures.
- Mock at system boundaries, not every internal function call.
- Prefer local fakes over sprawling mocks when behavior matters.
- Keep tests isolated from real network, user home directories, system time, environment variables, global state, and shared databases unless they are explicit integration tests.
- Avoid `time.sleep` in tests when polling with deadlines, fake time, events, queues, or explicit synchronization can prove behavior.
- Use integration tests for persistence, API handlers, CLI flows, workers, and cross-module contracts when unit tests cannot prove the behavior.
- Treat coverage as a signal for changed behavior, not a universal percentage target unless the repository enforces one.

Pytest shape:

```python
import pytest


@pytest.mark.parametrize(
    ("raw", "want"),
    [
        ("Alice Smith", "alice-smith"),
        (" Alice  Smith ", "alice-smith"),
    ],
)
def test_slugify_normalizes_names(raw: str, want: str) -> None:
    assert slugify(raw) == want


def test_load_config_reports_invalid_json(tmp_path: Path) -> None:
    path = tmp_path / "config.json"
    path.write_text("{", encoding="utf-8")

    with pytest.raises(ConfigError, match="invalid JSON config"):
        load_config(path)
```

## Tooling and Dependency Management

- Read `pyproject.toml`, `setup.cfg`, `tox.ini`, `noxfile.py`, `pytest.ini`, `mypy.ini`, `.pre-commit-config.yaml`, lockfiles, and CI before choosing validation commands.
- Use the repository's package manager: uv, Poetry, PDM, pip-tools, pip, conda, or another established workflow.
- Do not edit lockfiles by hand.
- Do not install or upgrade dependencies without user approval when network access or dependency churn is involved.
- Run the narrowest relevant validation first, then broaden when the change affects shared behavior.
- If Ruff, Black, isort, mypy, Pyright, Pyre, pylint, tox, nox, pre-commit, or coverage is configured, use the configured command rather than inventing a parallel one.
- Avoid adding `# noqa`, `# type: ignore`, or lint disables unless the reason is narrow and local.

## Performance

- Do not optimize prematurely.
- Prefer clear Python first; measure before introducing complexity.
- Use generator expressions and iterators for streaming or large data, but return concrete collections when callers need them.
- Use set and dict membership for repeated lookups.
- Use `"".join(...)` or `io.StringIO` for repeated string assembly.
- Precompute or cache only when the data is stable and invalidation is clear.
- Use `__slots__`, frozen dataclasses, vectorized libraries, multiprocessing, or C-extension-backed libraries only when they fit the project and the performance need is real.
- Avoid making type-heavy or micro-optimized code obscure for small wins.

## Patterns To Use Carefully

- Dataclass validation: useful for simple invariants; use richer validation libraries when boundary coercion and error reporting matter.
- Decorators: useful for cross-cutting behavior; avoid hiding control flow, IO, retries, or authorization decisions.
- Context managers: useful for resource lifecycles; make cleanup reliable with `try`/`finally` when writing custom managers.
- Dependency injection: useful for clients, repositories, clocks, and config; avoid container frameworks unless already established.
- Dynamic typing: useful at edges and plugin systems; avoid letting `Any` leak through core business logic.
- Caching: useful for expensive pure operations; avoid stale data, unbounded memory growth, and hidden cross-test state.

## Anti-Patterns

Avoid:

- mutable default arguments
- bare `except` or broad exception handling without re-raise, logging, or a documented fallback
- `pass` in exception handlers that hides failures
- `assert` for production input validation
- `from module import *`
- import-time side effects
- global mutable clients, config, caches, clocks, or registries
- print debugging in library code
- stringly typed states that should be enums or domain types
- large untyped dictionaries passed through multiple layers
- `time.sleep` in async code or deterministic tests
- unbounded task, thread, or process creation
- adding dependencies or tools without checking existing project conventions
- broad incidental refactors in feature PRs
- `# noqa`, `# type: ignore`, or disabled checks without a narrow reason

## Review Guidance

When reviewing Python code, prioritize:

1. correctness, boundary validation, and error handling
2. API clarity, typing, and data modeling
3. package/module ownership and side-effect boundaries
4. async/concurrency lifecycle, blocking behavior, and timeouts
5. behavior-focused tests and deterministic fixtures
6. dependency, tooling, and environment consistency
7. maintainability and idiomatic simplicity
8. performance only when relevant to the change
