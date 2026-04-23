# Project Context

## Vision

`skill-fetch` is a cross-platform skill discovery and installation tool for AI coding agents. It searches 9 registries in parallel (SkillsMP, GitHub, Anthropic Skills, ClawSkillHub, skills.sh, PolySkill, SkillHub, Skills Directory), scores results, runs a 6-category security scan, and installs skills into the correct per-agent directory. Target agents: Claude Code, Cursor, Codex, Gemini CLI, Windsurf, Amp.

## Current Priorities

1. **Install reliability** — installed skills must be complete and functional (full bundle, not partial). Integrity verifiable via SHA-256.
2. **Security hygiene** — maintain and improve the 6-category scan (especially prompt-injection coverage) as new attack patterns emerge.
3. **Cross-platform parity** — ensure install paths, tool-name mappings, and fallback strategies stay correct as agents evolve.
4. **Onboarding friction** — keep Quick Start ≤3 steps; detect and recover from missing API keys / missing MCP server automatically.

## Success Metrics

- Zero broken installs (skill downloaded but missing files it references)
- Zero silent "too few results" (always query all 9 sources; report per-source status)
- Every public skill directory layout (including `assets/`, `templates/`, `prompts/`, `data/`, `examples/`, `scripts/*.{sh,py,js,ts}`) installs correctly
- API key configuration works without manual JSON editing (`/fetch-skill-config`)

## Areas

| Area | Status | Notes |
|------|--------|-------|
| `skills/skill-fetch/SKILL.md` | Stable, high-scrutiny | Entry point; hook-facing behavior. Changes need care. |
| `skills/skill-fetch/references/*.md` | Active | Progressive-disclosure references. Keep each file focused. |
| `skills/skill-fetch/scripts/*.sh` | Stable | Must pass ShellCheck `--severity=warning`. |
| `install.sh` / `install.py` | Stable | Bootstrap for non-plugin installs. Smoke-tested in CI. |
| `commands/*.md` | Stable | Thin command wrappers that delegate to the skill. |
| `.claude-plugin/` | Stable | Plugin manifest for Claude Code marketplace. |
| `.github/workflows/ci.yml` | Stable | ShellCheck + frontmatter + installer smoke test. |

## Contribution Guidelines

- Never hardcode subdirectory names or file extensions in install logic — skills bundle arbitrary content.
- Never hardcode source-specific lookups into SKILL.md when a reference file will do; keep SKILL.md thin (progressive disclosure).
- Every new shell script must pass ShellCheck at `--severity=warning`.
- API keys must never appear on command lines — always via bundled script + config file.
- User-facing interactions stay plain-text (no `AskUserQuestion`); show 5 results per page with `c` to continue.
- When adding a new source, fire it in parallel with all others — never gate later sources on earlier results.

## Tone

Technical, concise, actionable. Prefer terse PR descriptions with a clear test plan over long narratives. Use concrete numbers when possible (file counts, query counts, hit rates).

## Out of Scope

- Merging external PRs (intent is extracted; the maintainer agent implements the fix).
- Long-running background services, MCP server hosting, or API proxying. This repo ships a client/installer, not a registry.
- Skill authoring helpers or skill-writing templates — covered by separate skills.
