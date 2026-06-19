---
name: go-patterns
description: Apply idiomatic Go backend patterns from prompts such as "go-patterns", "/go-patterns", "implement Go code", "review Go code", "refactor Go package", "design Go module", or when Codex is planning, implementing, testing, or reviewing Go backend changes. Use when Codex should apply practical Go judgment for error handling, context propagation, interface design, package organization, dependency injection, concurrency, zero-value design, testing patterns, performance tradeoffs, and anti-patterns while following the repository's existing conventions.
---

# Go Patterns

## Principle

Go code should be boring in the best way: predictable, explicit, and easy to read.

Prefer the repository's established patterns first. Use these patterns as judgment, not as rigid rules. Do not introduce a pattern just because it is common; use it when it reduces real complexity or makes behavior clearer.

## Error Handling

- Return errors explicitly; do not use `panic` for normal control flow.
- Wrap errors with operation and useful identifiers using `%w`.
- Use `errors.Is` for sentinel errors and `errors.As` for typed/domain errors.
- Do not ignore errors unless the error is truly irrelevant and the reason is obvious or documented.
- Keep error handling near the failing operation.

Example:

```go
func LoadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("load config %s: %w", path, err)
    }

    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("parse config %s: %w", path, err)
    }

    return &cfg, nil
}
```

## Context Usage

- Pass `context.Context` as the first parameter for request-scoped work.
- Do not store context in structs.
- Propagate cancellation and timeout to DB, HTTP, RPC, workers, and long-running operations.
- Call `defer cancel()` when creating a derived context with cancellation or timeout.
- Do not pass `nil` context; use `context.Background()` or `context.TODO()` deliberately.

## Interface Design

- Prefer small interfaces defined at the consumer boundary.
- Accept interfaces when the function only needs behavior, not a concrete type.
- Return concrete types unless hiding implementation is part of the API design.
- Do not create interfaces before there is a real abstraction need.
- Avoid large provider-side interfaces that mirror entire structs.

Heuristic: if there is only one implementation and no useful test seam, a concrete type may be simpler.

## Package Organization

- Follow existing repository layout before introducing a new layout.
- Keep package names short, lowercase, and non-redundant.
- Avoid vague dumping-ground packages like `utils`, `common`, or `helpers` unless the repo already has a clear convention for them.
- Use `internal/` for code that should not be imported outside the module.
- Use `pkg/` only for APIs that are intentionally reusable/public.
- Keep package ownership clear: handlers adapt transport, services own business logic, repositories own persistence when that pattern exists locally.

## Dependency Injection

- Avoid global mutable state for DBs, clients, config, loggers, and repositories.
- Prefer explicit constructor injection when dependencies are required.
- Keep constructors simple; do not introduce DI containers unless the project already uses them.
- Accept dependencies as narrow interfaces at the consumer side when it improves tests or ownership.

Example:

```go
type Service struct {
    users UserStore
}

type UserStore interface {
    GetUser(ctx context.Context, id string) (*User, error)
}

func NewService(users UserStore) *Service {
    return &Service{users: users}
}
```

## Concurrency

- Start goroutines only when their lifecycle is clear.
- Avoid goroutine leaks by honoring context cancellation.
- Use channels for coordination and `sync.Mutex` for straightforward shared state.
- Use `errgroup` when multiple goroutines should fail or cancel together.
- Avoid unbounded goroutine creation.
- Close channels from the sender side only.
- Be explicit about buffering and backpressure.

## Zero-Value Design

- Prefer types whose zero value is safe or useful.
- If zero value cannot be useful, provide a clear constructor and document invariants through code.
- Guard nil maps, nil functions, and nil pointers when the type appears reusable.
- Avoid hidden required initialization that causes surprising panics.

## Testing Patterns

- Use table-driven tests for input/output variation.
- Test behavior and contracts, not private implementation details.
- Use `t.Helper()` in test helpers.
- Use subtests with `t.Run` for scenarios and table cases.
- Use `t.Cleanup()` for resources and `t.TempDir()` for temporary filesystem state.
- Use `httptest` for HTTP handlers and API behavior.
- Use golden files under `testdata/` when expected output is large or intentionally stable.
- Keep tests isolated and deterministic.
- Clean up files, database rows, goroutines, servers, and mocks.
- Use integration tests for persistence, API handlers, and cross-service behavior when unit tests cannot prove the contract.
- Keep fixtures readable; do not hide important setup behind overly clever helpers.
- Avoid `time.Sleep` in tests when channels, contexts, fake clocks, polling with deadline, or explicit synchronization can prove the behavior.
- Prefer small local fakes or interfaces at consumer boundaries over over-mocking every dependency.
- Use benchmarks only for performance-sensitive code or when comparing alternatives.
- Use fuzz tests for parsers, validators, codecs, boundary-heavy input, and other input surfaces where random exploration can find bugs.
- Treat coverage as a signal for changed behavior, not a universal percentage target unless the repository enforces one.

Table-driven test shape:

```go
func TestValidateStatus(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        wantErr bool
    }{
        {name: "active", input: "active"},
        {name: "empty", input: "", wantErr: true},
    }

    for _, tt := range tests {
        tt := tt
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateStatus(tt.input)
            if tt.wantErr {
                if err == nil {
                    t.Fatal("expected error, got nil")
                }
                return
            }
            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }
        })
    }
}
```

Test helper shape:

```go
func newTestServer(t *testing.T) *Server {
    t.Helper()
    srv := NewServer(testConfig())
    t.Cleanup(func() {
        _ = srv.Close()
    })
    return srv
}
```

Use `t.Parallel()` only when tests are independent and do not share mutable global state, ports, databases, environment variables, or package-level configuration.

## Performance

- Do not optimize prematurely.
- Prefer standard library helpers over custom implementations.
- Preallocate slices when size is known and it improves clarity or avoids obvious allocation churn.
- Use `strings.Builder` or `strings.Join` for string assembly in loops.
- Use `sync.Pool` only when allocation pressure is proven or already established in the repository.
- Do not trade readability for micro-optimization without measurement.

## Patterns To Use Carefully

- Functional options: useful for constructors with many optional settings; avoid for simple types.
- Embedding: useful for composition; avoid when it makes method ownership unclear.
- Generics: useful when they remove real duplication without hiding behavior; avoid clever type gymnastics.
- Interfaces for tests: useful at consumer boundaries; avoid mock-driven architecture.

## Anti-Patterns

Avoid:

- `panic` for recoverable errors
- naked returns in long functions
- storing `context.Context` in structs
- global mutable state
- package-level init with side effects
- large interfaces
- `utils` packages without clear ownership
- goroutines without cancellation or ownership
- ignored errors
- broad incidental refactors in feature PRs
- `//nolint` without a narrow linter and reason

## Review Guidance

When reviewing Go code, prioritize:

1. correctness, error handling, and context propagation
2. API and package ownership clarity
3. concurrency lifecycle and leak prevention
4. testability and behavior-focused tests
5. maintainability and idiomatic simplicity
6. performance only when relevant to the change

Use `go-lint-workflow` for lint/tooling decisions and `coding-standard` for broader Go/Rust quality principles.
