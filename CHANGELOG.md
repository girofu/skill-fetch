# Changelog

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
