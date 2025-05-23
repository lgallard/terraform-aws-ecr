# Versioning Strategy

This Terraform module follows [Semantic Versioning](https://semver.org/) principles to ensure a clear and predictable versioning scheme.

## Version Format

Versions are formatted as `MAJOR.MINOR.PATCH` (e.g., `1.2.3`).

### Version Components

- **MAJOR version**: Incremented for incompatible API changes that require users to update their module configurations
- **MINOR version**: Incremented when new functionality is added in a backward-compatible manner
- **PATCH version**: Incremented for backward-compatible bug fixes and small improvements

## Version Update Criteria

### MAJOR Version Updates (X.y.z)

A major version is incremented when:

- Input variable names are changed or removed
- Output names are changed or removed
- Default values for required variables are changed
- Terraform minimum version requirement is increased significantly
- AWS provider minimum version requirement is increased significantly
- Resource or module behavior changes in a way that requires user configuration changes

**Example**: Changing `name` to `repository_name` in variables or increasing the minimum Terraform version from 1.x to 2.x

### MINOR Version Updates (x.Y.z)

A minor version is incremented when:

- New features or functionality are added in a backward-compatible way
- New input variables are added with reasonable defaults
- New outputs are added
- New examples or documentation are added
- Existing functionality is enhanced without breaking changes

**Example**: Adding support for new ECR features, adding optional variables with defaults

### PATCH Version Updates (x.y.Z)

A patch version is incremented when:

- Bug fixes are implemented
- Documentation is corrected or improved
- Code refactoring occurs with no functionality changes
- Dependencies are updated without requiring user configuration changes

**Example**: Fixing variable descriptions, correcting examples, enhancing inline documentation

## Release Process

This module uses [Release Please](https://github.com/googleapis/release-please) for automating the release process:

1. Commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/) standard:
   - `feat:` for new features (MINOR version bump)
   - `fix:` for bug fixes (PATCH version bump)
   - `feat!:` or `fix!:` or any type with `!` for breaking changes (MAJOR version bump)
   - `docs:` for documentation updates (no version bump)
   - `chore:` for maintenance tasks (no version bump)
   - `refactor:` for code refactoring (PATCH version bump if behavior might be affected)

2. When commits are pushed to the main branch, Release Please:
   - Analyzes commit messages since the last release
   - Updates the CHANGELOG.md file
   - Determines the next version number
   - Creates a release PR or publishes a release

## For Contributors

When contributing to this module, please follow these guidelines:

1. Use the Conventional Commits format for your commit messages
2. Document any breaking changes clearly in the commit message body
3. Update examples to reflect your changes
4. Test your changes against multiple Terraform versions if possible
5. Update documentation accordingly

## Pre-release Versions

For experimental features or significant changes, pre-release versions may be tagged using the `-pre.N` suffix (e.g., `1.0.0-pre.1`). These versions:

- Are not considered stable for production use
- May contain experimental features
- May introduce breaking changes before the final release