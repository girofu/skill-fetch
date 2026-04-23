# Changelog

## [1.4.1] - 2026-04-23

### Fixed

- **Partial skill downloads — install the directory, not the file**: Install logic previously hardcoded `SKILL.md` + `references/*.md` + `scripts/*.sh`, so skills shipping any other subdirs (`assets/`, `templates/`, `prompts/`, `data/`, `examples/`) or non-`.sh` scripts (`*.py`, `*.js`, `*.ts`) were installed with missing files and silently broken. Example: `anthropics/skills/skills/pdf` ships 9 Python scripts that were all dropped. The install flow now enumerates the full skill root via the git tree API and downloads every file, preserving the subtree layout.

### Added

- **`scripts/fetch-skill-bundle.sh`** — parses GitHub `blob`/`tree`/`raw.githubusercontent.com` URLs, enumerates the full skill root via `git/trees/{ref}?recursive=1`, and downloads every file preserving directory structure. When given a `SKILL.md` URL it auto-derives the parent dir as the skill root.
- **`.github/maintainer/`** — per-repo state (config, context, decisions, patterns, standing rules, contributor notes, run ledger) for the `open-source-maintainer` triage workflow. No user-facing behavior change.

### Changed

- **`installation-guide.md` §3d** — GitHub source and Direct URL source (when pointing at a GitHub file) both use tree enumeration via the bundle helper instead of hardcoded subdirs/extensions. Direct URLs to GitHub files now bring sibling files along.
- **SKILL.md Step 4 — "Digest the Installed Bundle"** — walks the full installed tree; verifies bundle completeness against relative paths referenced by SKILL.md.
- **Security scan scope** — `find -type f` walks the complete bundle. Categories now apply to `*.md` throughout the tree (A-F), `*.sh`/`*.bash`/`*.zsh`/`*.py`/`*.js`/`*.ts` (A-E), and `*.json`/`*.yaml`/`*.toml` (D, F).
- **Integrity hashing** — SHA-256 recorded for every file in the installed bundle, not just `SKILL.md` + `references/*.md` + `scripts/*.sh`.

## [1.4.0] - 2026-03-23

### Added

- Community health files: CONTRIBUTING.md, SECURITY.md, CODE_OF_CONDUCT.md
- Issue templates (bug report, feature request) and PR template
- GitHub Actions CI: ShellCheck, SKILL.md frontmatter validation, installer smoke test
- README badges (license, release, stars, CI status)

## [1.3.3] - 2026-03-22

### Changed

- **SKILL.md rewrite (351→~180 lines)**: Three core improvements to boost 9-source compliance from ~60% to >90%:
  1. **GATE pattern replaces MANDATORY warnings** — Step 2 requires outputting POST-SEARCH checklist; Step 2.5 has PREREQUISITE check that blocks progression without it
  2. **Action Checklist with inline STOP** — Sources listed as checkable items with STOP barriers after items 2 and 7, placed where LLM most likely short-circuits
  3. **Deduplicated content** — Platform Compatibility table, cross-platform paths, search results template, security scan details, scoring formula breakdown, and Step 0/0.5 details moved to reference files
- **Installation scope GATE** — Step 3c now has a structural PREREQUISITE check requiring G/L reply before Step 3d proceeds
- **Metadata JSON schema moved to `references/search-sources.md`** — Removed from SKILL.md Step 3f, consolidated with source documentation
- **Prompt engineering polish** (15 targeted changes, net +1 line):
  - P1: Added correct/wrong `<example>` pairs at SEARCH GATE and SCOPE GATE (few-shot)
  - P2: Reduced emphasis points from 8+ to 3 (SEARCH GATE, SCOPE GATE, STOP barrier) — prevents attention dilution
  - P3: Rewrote negative instructions as positive (`Do NOT skip 3-9` → `Continue: sources 3-9 now`)
  - P4: Added WHY to key constraints (SkillsMP <30%, G/L persistence semantics)
  - P5: Removed redundant content (tagline, Completion section, `"check mentally"`, duplicate round strategy)
  - P6: Disambiguated GATE labels (`SEARCH GATE` vs `SCOPE GATE`)
  - P7: Strategic repetition of 9-source rule (Critical Rules #1 + Step 2 + Step 2.5 verify)

## [1.3.2] - 2026-03-21

### Fixed

- **SkillsMP MCP tools not loading**: Tools were deferred and had namespaced names (`mcp__skillsmp__skillsmp_search`). Step 0 now instructs to run `ToolSearch("skillsmp")` first to load deferred tools before checking availability. Added note about namespaced tool names.
- **Skills Directory query with spaces fails (exit code 3)**: URL encoding now uses `node encodeURIComponent` (primary), `python3 urllib.parse.quote` (fallback), or space-to-`+` replacement (last resort). Previously `curl` would truncate URL at spaces.
- **SkillHub script injection risk**: Replaced `sed`-based JSON escaping with `node JSON.stringify()` for safe query encoding in POST body. Handles all special characters including newlines, quotes, and backslashes.

## [1.3.1] - 2026-03-21

### Fixed

- **External sources skipped during search**: LLM would fire only SkillsMP (sources 1-2), get results, then skip GitHub/ClawhHub/skills.sh/PolySkill/SkillHub/Skills Directory (sources 3-9). Added COMMON FAILURE MODE warning and POST-SEARCH CHECKLIST to enforce all 9 sources are queried every time.
- **Ambiguous round strategy**: "≥1 result → stop" was misinterpreted as "stop after first source returns results". Clarified that the rule applies to **rounds** (not individual sources) — within a single round, ALL 9 sources must be queried.

### Changed

- **Step 2 table format**: Added Source column for clarity (SkillsMP AI, GitHub repos, ClawhHub, etc.)
- **Mandatory post-search checklist**: Must output `Sources queried: [1] ✅ [2] ✅ [3] ✅/❌ ...` before proceeding to scoring. If sources 3-7 are all ❌, must go back and fire them.

## [1.3.0] - 2026-03-20

### Added — Security Assessment System

- **Security Labels (§6)**: 5-tier trust labels (Official, Verified, Partial, Unverified, Security Concerns) with priority-based assignment flow
- **6-Category Security Scan**: Categories A (Destructive Commands), B (Remote Code Execution), C (Data Exfiltration), D (System Modification), E (Obfuscation), F (Prompt Injection)
- **Prompt Injection Detection**: 5 sub-categories (PI-1 Direct Override, PI-2 Hidden Role Markers, PI-3 Encoding Tricks, PI-4 Indirect Injection, PI-5 Social Engineering) with false positive handling
- **Integrity Verification**: SHA-256 hash recorded at installation for all skill files; tamper detection on future loads
- **Permissions Declaration**: Advisory `permissions` field in SKILL.md frontmatter; scanner flags mismatches between declared and actual behavior
- **SkillsMP Post-Install Scan**: Trust-but-verify model — SkillsMP skills now undergo security scan after installation

### Fixed

- **Command Injection in fetch-skillhub.sh**: User input now escaped with `sed` before embedding in JSON payload
- **URL Injection in fetch-skills-directory.sh**: User input now URL-encoded with `python3 urllib.parse.quote` before embedding in query string

### Changed

- **Scan Scope Expanded**: Security scan now covers `SKILL.md` + `references/*.md` + `scripts/*.sh` (previously SKILL.md only)
- **Metadata Schema Extended**: `.fetch-metadata.json` now includes `integrity`, `securityLabel`, and `scanResult` fields
- **Security Review Scope**: Renamed from "GitHub Security Review" to "Security Review (ALL Sources)" — all sources are now scanned, not just GitHub

## [1.2.0] - 2026-03-19

### Added

- 9-source parallel search (SkillsMP, GitHub, Anthropic Skills, ClawSkillHub, skills.sh, PolySkill, SkillHub, Skills Directory)
- Bundled API scripts for SkillHub and Skills Directory (no API key exposure)
- Security labels (Official, Verified, Partial, Unverified, Security Concerns)
- External Bonus scoring dimension (0-5) from PolySkill, SkillHub, Skills Directory
- PolySkill single-keyword search fix
- GitHub search fix (removed restrictive "skill SKILL.md" suffix)

## [1.0.1] - 2026-03-18

### Added

- Initial release with 7 registries
- Quality scoring algorithm (0-100)
- Cross-platform support (Claude Code, Cursor, Codex, Gemini CLI, Windsurf, Amp)
- Paginated results with 5 per page
- Local/global installation with scope selection
