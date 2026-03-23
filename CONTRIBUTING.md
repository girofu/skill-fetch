# Contributing to skill-fetch

Thank you for your interest in contributing to skill-fetch! This document provides guidelines for contributing to the project.

## Table of Contents

- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)
- [Development Setup](#development-setup)
- [Adding a New Search Source](#adding-a-new-search-source)
- [Commit Conventions](#commit-conventions)
- [Pull Request Process](#pull-request-process)
- [Code Style](#code-style)

## Reporting Bugs

Please use the GitHub Issue templates to report bugs. When filing a bug report, include:

- **Agent type**: The AI coding agent you are using (e.g., Claude Code, Cursor, Windsurf)
- **Query statement**: The exact `/fetch-skill` query you ran (e.g., `/fetch-skill react testing`)
- **Error message**: The full error output or unexpected behavior description
- **Expected behavior**: What you expected to happen
- **Actual behavior**: What actually happened
- **Environment**: OS, agent version, plugin version

Open a bug report at: https://github.com/girofu/skill-fetch/issues/new?template=bug_report.md

## Suggesting Features

Use the Feature Request template to suggest new features:

https://github.com/girofu/skill-fetch/issues/new?template=feature_request.md

Please describe the use case, the proposed solution, and any alternatives you have considered.

## Development Setup

1. **Fork and clone** the repository:

   ```bash
   git clone https://github.com/<your-username>/skill-fetch.git
   cd skill-fetch
   ```

2. **Install as a Claude Code plugin** using one of two methods:

   - Via plugin marketplace command (recommended):
     ```
     /plugin marketplace add /path/to/skill-fetch
     /plugin install skill-fetch@skill-fetch
     ```

   - Or manually copy to skills directory:
     ```bash
     cp -r skills/skill-fetch ~/.claude/skills/skill-fetch
     ```

3. **Test the installation** by running a search query in Claude Code:

   ```
   /fetch-skill testing
   ```

   Verify that results appear from all 9 search sources. Each source should be represented in the output. If any source returns no results or an error, check the source configuration in `skills/skill-fetch/references/search-sources.md`.

## Adding a New Search Source

To add a new registry or source to the skill discovery pipeline:

1. **Document the source** in `skills/skill-fetch/references/search-sources.md`:
   - Source name and URL
   - API endpoint or scraping method
   - Authentication requirements (if any)
   - Rate limits and usage policies
   - Example response format

2. **Add the source to the search checklist** in `skills/skill-fetch/SKILL.md` under Step 2:
   - Follow the existing checklist item format
   - Include the source name, search method, and expected result format
   - Add security label guidance for skills from this source

3. **Update the README.md** Search Sources table:
   - Add a new row with: Source name, Type, Auth Required, Notes

4. **Update CHANGELOG.md**:
   - Add an entry under `[Unreleased]` with `feat: add <source-name> as search source`

5. Submit a pull request following the [PR Process](#pull-request-process) below.

## Commit Conventions

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | When to use |
|--------|-------------|
| `feat:` | New feature or search source |
| `fix:` | Bug fix |
| `docs:` | Documentation changes only |
| `refactor:` | Code change that is not a bug fix or feature |
| `chore:` | Build process, dependency updates, tooling |

Examples:

```
feat: add npm registry as search source
fix: handle rate limit errors from GitHub API gracefully
docs: clarify security label definitions in README
refactor: extract pagination logic into shared helper
chore: update ShellCheck CI version to 0.9.0
```

## Pull Request Process

1. **Fork** the repository and create a **feature branch** from `main`:

   ```bash
   git checkout -b feat/my-new-source
   ```

2. **Make your changes** following the code style guidelines below.

3. **Ensure ShellCheck passes** for any shell scripts:

   ```bash
   shellcheck skills/skill-fetch/*.sh
   ```

4. **Update CHANGELOG.md** with a summary of your changes under `[Unreleased]`.

5. **Submit a PR to `main`** with:
   - A clear title following Conventional Commits format
   - A description of the change and motivation
   - Reference to any related issues (e.g., `Closes #42`)

6. A maintainer will review your PR within a reasonable timeframe. Please be patient and responsive to feedback.

## Code Style

### Shell Scripts

- Always begin scripts with `set -euo pipefail` to fail fast on errors, unset variables, and pipe failures
- Use `shellcheck`-compatible syntax
- Prefer `[[ ]]` over `[ ]` for conditionals
- Quote all variable expansions: `"${variable}"`
- Use meaningful variable names in SCREAMING_SNAKE_CASE for constants, snake_case for locals

### Markdown

- Use ATX-style headings (`#`, `##`, `###`) — do not use Setext-style underlines
- Use fenced code blocks with language identifiers
- Keep lines under 120 characters where practical
- Use a single blank line between sections

### API / Node.js Scripts

- Use `JSON.stringify()` and `JSON.parse()` for all JSON handling to prevent injection
- Never concatenate user input directly into shell commands or JSON strings
- Handle errors explicitly — do not silently ignore rejections
