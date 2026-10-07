# Contributing to PascalMath Studio

## Prerequisites

- Free Pascal (FPC) 3.2+
- Lazarus 3.x
- Git

## Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Implement changes following the coding standards below
4. Write tests for all new mathematical functionality
5. Ensure all existing tests pass
6. Submit a pull request against `main`

## Coding Standards

- Strong typing — always declare types explicitly
- Small cohesive units — one responsibility per unit
- No duplicated mathematical logic — reuse core modules
- Document public interfaces with comments
- No unnecessary global state

## Mathematical Correctness

Mathematical correctness takes priority over visual polish.

- Every mathematical subsystem must have tests
- Floating-point tests must use appropriate tolerances (absolute or relative)
- Never silently return an incorrect result — raise a typed error instead
- Document domain assumptions for all transformations

## Commit Messages

Use conventional commit prefixes:

```
feat(phase-XX): description
fix(module): description
test(module): description
docs(section): description
refactor(module): description
build(tool): description
ci(workflow): description
```

## Branch Protection

The `main` branch requires:
- Passing CI (compilation + tests)
- Pull request review

## License

By contributing you agree your contributions are licensed under the MIT License.
