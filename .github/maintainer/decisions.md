# Decision Log

Decisions recorded here are the project-level calls: scope, policy, architecture, closures. One line per entry minimum; add rationale when the "why" is non-obvious.

## 2026-04

### [PR:1] Opened — Download full skill bundle, not just SKILL.md
**Date:** 2026-04-23
**Decision:** Replaced hardcoded `SKILL.md` + `references/*.md` + `scripts/*.sh` install logic with full git-tree enumeration via `scripts/fetch-skill-bundle.sh`.
**Reasoning:** Any skill that ships `.py`/`.js` scripts, or uses subdirs beyond `references/`/`scripts/` (e.g., `assets/`, `templates/`, `prompts/`, `data/`), was silently broken on install. End-to-end test against `anthropics/skills/skills/pdf` confirmed: old flow → 1 file, new flow → 12 files with correct subtree. Treats the skill as its directory, not as `SKILL.md`.
