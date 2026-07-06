---
name: python-testing
description: Apply practical Python testing strategy from prompts such as "python-testing", "/python-testing", "write Python tests", "add pytest coverage", "test this Python change", "fix flaky Python test", "review Python tests", "use TDD for Python", or when Codex is implementing, refactoring, debugging, or reviewing Python code that needs focused unit, integration, API, CLI, async, database, filesystem, or regression tests. Use when Codex should choose pytest or repository-standard test patterns, write behavior-focused tests, prove RED/GREEN when appropriate, design fixtures, use mocks and fakes at boundaries, manage deterministic test state, and run scoped validation while following existing project conventions.
---

# Python Testing

## Principle

Python tests should prove useful behavior with the least fragile setup possible.

Prefer the repository's existing test framework, fixture style, naming, markers, package manager, and validation commands. Use these patterns as judgment, not as rigid rules. Do not add pytest, pytest plugins, coverage tools, mocks, databases, or test infrastructure unless the repo already uses them or the user approves.

## Repository Orientation

- Inspect `pyproject.toml`, `pytest.ini`, `setup.cfg`, `tox.ini`, `noxfile.py`, `.pre-commit-config.yaml`, CI config, lockfiles, and existing tests before adding or changing tests.
- Identify the project test runner: pytest, unittest, Django test runner, tox, nox, uv, Poetry, PDM, pip, or a custom script.
- Match existing test layout before creating new directories such as `tests/unit`, `tests/integration`, or `tests/e2e`.
- Match existing async test tools before using `pytest.mark.asyncio`, AnyIO, Trio, Django async tests, or framework-specific clients.
- Do not edit lockfiles by hand or install test dependencies without approval.
- Keep test changes scoped to the behavior under work; avoid broad suite reshaping or fixture rewrites unless required.

## Test Strategy

- Test behavior and contracts, not private implementation details.
- Cover the changed behavior first: happy path, meaningful edge cases, failure paths, and regression cases.
- Prefer focused unit tests for pure logic and service behavior.
- Use integration tests when behavior depends on persistence, framework routing, serialization, external adapters, workers, transactions, or cross-module contracts.
- Use API/client/CLI tests when the public interface is the contract.
- Use regression tests for bugs: the test should fail before the fix and pass after the fix.
- Avoid testing third-party libraries directly; test how project code uses them when the integration is meaningful.
- Keep tests deterministic and independent from real network, wall-clock timing, user home directories, shared environment variables, global state, and shared databases unless the test is explicitly integration-scoped.

## TDD and RED/GREEN

- Use TDD when the user asks for it, when fixing a bug, when implementing behavior from a plan, or when a small RED/GREEN loop will reduce risk.
- Write or update the focused test before production code when practical.
- Prove a valid RED state before implementation:
  - the intended test is selected
  - the failure is caused by missing behavior or the reported bug
  - the failure is not unrelated setup breakage, syntax errors, missing dependencies, or legacy suite debt
- Implement the smallest production change that makes the test pass.
- Prove GREEN with the same focused command, then broaden validation when the touched surface warrants it.
- Refactor only while tests are green, then rerun focused tests.
- Do not require universal TDD for tiny mechanical edits, generated files, or changes where the repo has a different explicit workflow.

## Pytest Patterns

- Use pytest idioms when the repo uses pytest; otherwise follow the existing framework.
- Prefer clear test names that describe behavior, for example `test_rejects_expired_token`.
- Use `pytest.mark.parametrize` for input/output matrices and boundary cases.
- Use `pytest.raises(..., match=...)` for expected exceptions when the error message or classification is part of the contract.
- Use `tmp_path` for filesystem tests and write text with explicit `encoding="utf-8"` when encoding matters.
- Use `monkeypatch` for environment variables, module attributes, and lightweight dependency replacement.
- Use `caplog` only when log output is part of observable behavior.
- Use `freezegun`, fake clocks, or project clock abstractions only when already available; otherwise prefer injecting time providers or asserting relative behavior without sleeps.
- Avoid unnecessary test classes. Use classes only when grouping improves readability or matches the local style.

Pytest shape:

```python
from pathlib import Path

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

## Fixtures

- Keep fixtures boring and readable; important scenario details should remain visible in the test.
- Prefer function-scoped fixtures by default.
- Use broader fixture scopes only for expensive immutable resources or integration setup with clear isolation.
- Use `yield` fixtures for resources requiring cleanup.
- Keep `autouse` fixtures rare and local; they can hide state changes and make failures hard to understand.
- Put shared fixtures in the nearest useful `conftest.py`; avoid root-level fixture dumping grounds.
- Avoid fixtures that return many unrelated values. Use small dataclasses, builders, or explicit helper functions when that makes intent clearer.
- Reset environment variables, global config, caches, registries, temporary files, database rows, and background tasks in cleanup.

Fixture shape:

```python
@pytest.fixture
def user_repo(tmp_path: Path) -> UserRepository:
    repo = UserRepository(tmp_path / "users.sqlite")
    repo.migrate()
    return repo
```

## Mocks, Fakes, and Patching

- Mock at system boundaries: HTTP clients, queues, email/SMS providers, object storage, clocks, payment providers, subprocesses, and external APIs.
- Prefer local fakes or in-memory adapters when behavior matters more than call counting.
- Use dependency injection where the project supports it; avoid patching deep internals just to reach a seam.
- Patch where the object is looked up, not where it was originally defined.
- Use `autospec=True` or `spec_set` when mocking Python objects whose API should be enforced.
- Assert meaningful effects and returned behavior before call-count minutiae.
- Keep mocks local to the test or fixture that needs them.
- Avoid brittle tests that mirror implementation order, private helper calls, or exact internal call sequences.

Boundary fake shape:

```python
class FakeMailer:
    def __init__(self) -> None:
        self.sent: list[Email] = []

    def send(self, email: Email) -> None:
        self.sent.append(email)


def test_sends_welcome_email() -> None:
    mailer = FakeMailer()
    service = SignupService(mailer=mailer)

    service.signup("alice@example.com")

    assert [email.to for email in mailer.sent] == ["alice@example.com"]
```

## Async and Concurrency Tests

- Use the repository's async test runner and framework client.
- Await spawned tasks or otherwise prove their lifecycle; do not leave background tasks running after a test.
- Avoid `time.sleep` and long real-time waits. Prefer fake time, events, queues, barriers, polling with deadlines, or explicit synchronization.
- Do not use blocking clients inside async tests unless the framework explicitly supports it.
- Test timeout, cancellation, retry, and partial failure behavior when async code changes those contracts.
- Avoid holding locks across awaits in test helpers and fakes.
- Clean up async clients, sessions, servers, task groups, and event-loop resources.

## IO, API, CLI, and Database Tests

- Filesystem: use `tmp_path`; avoid writing to the repository, home directory, or global temp paths unless the repo pattern requires it.
- Environment: use `monkeypatch.setenv` / `delenv`; do not leak env changes across tests.
- Network: avoid real network in unit tests. Use local test servers, framework clients, mocked transports, or fakes.
- API tests: assert status code, stable response shape, important headers, auth/permission behavior, and error contracts.
- CLI tests: use the repo's CLI test helper, Click/Typer runner, subprocess harness, or focused `main()` adapter tests as locally appropriate.
- Database tests: isolate rows, schemas, transactions, and connection state. Roll back or clean up deterministically.
- Migrations/backfills: test idempotency, rollback assumptions, representative legacy rows, and empty-state behavior when relevant.

## Coverage and Validation

- Treat coverage as a signal for changed behavior, not a universal percentage target.
- Follow repository-enforced coverage thresholds if they exist.
- Do not invent an 80% or 100% target unless the user or repo requires it.
- Use focused commands first, for example:

```bash
python -m pytest tests/path/test_file.py::test_name
python -m pytest tests/path/test_file.py -k "case_name"
```

- Broaden validation when behavior affects shared modules, public APIs, persistence, async workers, or framework integration.
- Use configured commands from `pyproject.toml`, tox, nox, Makefile, task runner, pre-commit, or CI rather than inventing parallel commands.
- If coverage tooling is configured, prefer the repo command. Do not install `pytest-cov`, `coverage`, or plugins without approval.
- Report test commands run, failures found, and any relevant untested risk.

## Flake Prevention

- Avoid real sleeps, real clocks, random order dependence, real network, shared mutable globals, hidden fixture state, and order-sensitive mocks.
- Seed randomness when randomness is part of the test.
- Keep tests independent under repeated runs and parallel execution when the repo uses xdist or another parallel runner.
- Use unique resource names for files, ports, database rows, buckets, queues, and cache keys.
- Prefer polling with a deadline over fixed sleeps when waiting for eventual behavior.
- Mark slow, integration, external-service, or destructive tests according to existing marker conventions.

## Anti-Patterns

Avoid:

- tests that only prove mocks were called without proving behavior
- patching private helpers instead of testing public behavior
- broad `autouse` fixtures that mutate global state invisibly
- shared mutable fixtures without reset
- real network calls in unit tests
- writing to the repo tree, user home, or shared temp files
- `time.sleep` for synchronization
- swallowing exceptions in tests instead of using `pytest.raises`
- asserting exact log strings unless log text is a public contract
- duplicating production logic inside expected values
- large fixture factories that hide the scenario being tested
- coverage percentage changes without meaningful behavioral coverage
- adding pytest plugins or test dependencies without checking repo convention and user approval
- broad incidental rewrites of unrelated tests

## Review Guidance

When reviewing Python tests, prioritize:

1. changed behavior is actually covered
2. failure paths and boundary contracts are tested
3. tests are deterministic, isolated, and not order-dependent
4. fixtures are readable and clean up state
5. mocks/fakes are used at appropriate boundaries
6. async, time, network, filesystem, and database behavior cannot leak or flake
7. validation commands match repository tooling
8. coverage gaps are reported honestly without chasing arbitrary percentages

Use `python-patterns` for production-code design and broader Python idioms when implementing the behavior under test.
