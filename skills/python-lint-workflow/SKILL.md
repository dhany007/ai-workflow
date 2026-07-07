---
name: python-lint-workflow
description: Run and interpret Python linting, formatting, import, type-checking, packaging, and validation failures from prompts such as "python-lint-workflow", "/python-lint-workflow", "lint Python", "fix Ruff", "fix Black", "fix mypy", "fix Pyright", "pytest import error", "Python typecheck failed", "pre-commit failed", "resolve Python lint", or when Codex is implementing, refactoring, testing, or reviewing Python code that needs scoped Ruff, Black, isort, mypy, Pyright, pyright, pyproject, tox, nox, pre-commit, or CI validation. Use when Codex should run repository-configured commands, classify failures, apply minimal fixes, and separate new issues from baseline debt.
---

# Python Lint Workflow

Use this skill to run and resolve Python quality checks pragmatically. Follow the repository's configured tools and Python version before applying generic Python preferences.

Primary references when current behavior is uncertain:

- Ruff docs - https://docs.astral.sh/ruff/
- mypy docs - https://mypy.readthedocs.io/en/stable/
- pytest docs - https://docs.pytest.org/en/stable/

## Orientation

Before running or changing anything, inspect:

- `pyproject.toml`, `setup.cfg`, `tox.ini`, `.pre-commit-config.yaml`, `mypy.ini`, `ruff.toml`, `pytest.ini`, and CI workflow files.
- Python version hints: `.python-version`, `.tool-versions`, Dockerfile, `requires-python`, or CI matrix.
- Dependency manager: `uv`, Poetry, Hatch, PDM, pip-tools, pip, tox, nox, or virtualenv conventions.
- Existing import layout: `src/` layout, namespace packages, package `__init__.py`, generated code, and tests.
- Existing skills that should pair with this one: `python-patterns`, `effective-python`, and `python-testing`.

Do not introduce a new lint/type tool unless the task explicitly asks for setup.

## Command Selection

- Prefer repo scripts such as `make lint`, `make test`, `tox`, `nox`, `uv run`, `poetry run`, or documented commands.
- If no wrapper exists, use configured tools directly: Ruff, Black, mypy, Pyright, pytest, or pre-commit.
- Start with the failing command or the narrowest file-level equivalent.
- Avoid broad auto-formatting the whole repo unless the repo already does that as the standard workflow.

## Failure Classes

### Ruff And Formatting

- Use auto-fix only when the rule is mechanical and low risk.
- Read non-mechanical diagnostics before changing behavior.
- Keep import sorting aligned with the configured tool; do not hand-roll import sections.
- Avoid disabling rules inline unless there is a clear, local reason that future maintainers can understand.

### Black Or Formatter Drift

- Let the configured formatter decide layout.
- Do not mix unrelated formatting churn into a functional change if scoped formatting is possible.
- If formatting reveals a large baseline, report it instead of reformatting unrelated files.

### Type Checking

- Prefer improving annotations, narrowing, and data modeling over `# type: ignore`.
- Use `typing.Protocol`, `TypedDict`, dataclasses, Pydantic models, or small domain types when they match local style.
- Keep `Any` at external boundaries and narrow as soon as practical.
- Add `# type: ignore[...]` only when the tool is wrong or a dependency lacks types, and include the narrow error code when supported.
- Coordinate with `effective-python` for API design and maintainability questions.

### Import And Packaging Errors

- Distinguish missing dependency, wrong execution root, package layout issue, circular import, optional dependency, and generated artifact problems.
- Prefer fixing package/module structure over mutating `sys.path` in production code.
- Keep test-only path helpers inside test config or fixtures when the repo already uses them.

### Pytest And Pre-Commit

- Use `python-testing` for test behavior, fixtures, mocks, flaky tests, and RED/GREEN loops.
- For pre-commit, identify the hook and run only the failing hook when possible.
- Do not update hook versions or dependency locks unless the failure requires it or the user asked.

## Validation

- Rerun the narrow failing command after the fix.
- Run adjacent checks when the change touches shared code, public types, package config, or imports.
- Separate new failures from existing baseline debt in the final report.
- Record the command and outcome clearly.

## Anti-Patterns

- Hiding type failures with broad `Any`, blanket `ignore`, or untyped wrappers.
- Changing Python versions, dependency managers, or global config to fix one diagnostic.
- Reformatting unrelated files during a small fix.
- Adding runtime imports only to satisfy type checkers when `TYPE_CHECKING` would avoid cycles.
- Treating lint failures as style-only when they indicate dead code, unsafe calls, mutable defaults, or import side effects.

## Review Guidance

When reviewing Python lint fixes, lead with whether the change preserves runtime behavior, improves or preserves type clarity, respects the configured toolchain, and avoids sweeping unrelated churn.
