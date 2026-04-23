# Decision Log

Decisions recorded here are the project-level calls: scope, policy, architecture, closures. One line per entry minimum; add rationale when the "why" is non-obvious.

## 2026-04

### [PR:1] Merged — Download full skill bundle, not just SKILL.md
**Date:** 2026-04-23
**Decision:** Replaced hardcoded `SKILL.md` + `references/*.md` + `scripts/*.sh` install logic with full git-tree enumeration via `scripts/fetch-skill-bundle.sh`.
**Reasoning:** Any skill that ships `.py`/`.js` scripts, or uses subdirs beyond `references/`/`scripts/` (e.g., `assets/`, `templates/`, `prompts/`, `data/`), was silently broken on install. End-to-end test against `anthropics/skills/skills/pdf` confirmed: old flow → 1 file, new flow → 12 files with correct subtree. Treats the skill as its directory, not as `SKILL.md`.

### [PR:2] Merged — Initialize `.github/maintainer/` state
**Date:** 2026-04-23
**Decision:** Bootstrapped per-repo state (config, context, decisions, patterns, standing rules, contributor notes, run ledger) so future `open-source-maintainer` runs have a persistent home.
**Reasoning:** Stage 0 of the maintainer workflow requires this folder. Seeding it at the same time as the first real substantive change (PR:1) keeps initial context honest — the decision and pattern entries reference real work, not placeholders.

### [PR:3] Merged — Docs + version bump for 1.4.1
**Date:** 2026-04-23
**Decision:** Bumped `.claude-plugin/plugin.json` to `1.4.1`, added CHANGELOG entry, updated README Features and File Structure (the latter was already missing two reference files that exist on disk — fixed at the same time).
**Reasoning:** Release-ready state for `v1.4.1`. Version is tracked only in `plugin.json`; other installers don't embed versions.

### Cut release `v1.4.1 — Full skill bundle install`
**Date:** 2026-04-23
**Decision:** Published annotated tag `v1.4.1` on commit `0dd3e2b` (tip of main after #1 + #2 + #3) and a public GitHub Release with notes derived from the CHANGELOG 1.4.1 section. URL: <https://github.com/girofu/skill-fetch/releases/tag/v1.4.1>.
**Reasoning:** The fix in #1 materially changes install behavior for skills with non-trivial bundles. Cutting a patch release (not a minor) because the change aligns user-facing behavior with what was already promised — skills were supposed to install as directories; previously they installed as a single file. Plugin marketplace consumers tracking `skill-fetch@latest` will pick this up automatically on next plugin update.
**Follow-up:** Monitor issues for 24–48h for any edge cases in unusual skill repo layouts (e.g., SKILL.md at repo root, branch names with `/`, private repos requiring auth).
