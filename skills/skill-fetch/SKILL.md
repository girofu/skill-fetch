---
name: skill-fetch
description: >
  This skill should be used when the user asks to "fetch skill", "install skill",
  "search for a skill", or when a hook outputs "MISSING EXTERNAL SKILL".
  Searches 9 registries (SkillsMP, GitHub, Anthropic Skills, ClawSkillHub, skills.sh,
  PolySkill, SkillHub, Skills Directory) with multi-variant search, quality scoring,
  security labels, pagination, and local/global installation.
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "WebFetch", "shell", "read_file", "write_file", "execute_command", "fetch", "curl"]
---

# Skill Fetch

## When to Use

- A skill-eval hook outputs "MISSING EXTERNAL SKILL"
- The current task requires domain expertise not available locally
- The user asks to "fetch skill", "search for a skill", or "install a skill"

## Critical Rules

1. **Fire all 9 sources before scoring** — SkillsMP indexes <30% of skills. GitHub, PolySkill, and SkillHub each contain unique skills not found elsewhere. Never proceed to scoring until all 9 sources have returned or failed.
2. **Only the user decides to skip** — present results and wait. Never skip installation autonomously.
3. **Ask G or L before every install** — global skills persist across projects; local skills travel with the repo. Display the scope menu and wait for the user's reply.
4. **Use plain-text interaction** — output analysis directly. Do not use AskUserQuestion.

> **Cross-platform:** This skill adapts to any AI coding agent. See `references/platform-adapters.md` for tool mapping and installation paths.

## Procedure

### Prerequisites

**SkillsMP MCP (Claude Code only):** Run `ToolSearch("skillsmp")` to load deferred tools. If no `skillsmp_*` tool is found, run `claude mcp add --scope user skillsmp -- npx -y skillsmp-mcp-server`, inform user it will be available next session, and continue with sources 3-9. Non-Claude Code agents: skip SkillsMP entirely.

**API keys (optional):** Read `~/.claude/skills/.fetch-config.json` if it exists. Keys: `SKILLHUB_API_KEY` (Source 8 REST), `SKILLS_DIRECTORY_API_KEY` (Source 9). Sources 1-8 work without keys. Source 9 requires a key.

**URL mode:** If `$ARGUMENTS` starts with `https://`, skip directly to Step 3 installation.

### Step 1: Determine Search Keywords

- **Has `$ARGUMENTS`**: Use directly as search terms
- **No search terms** (auto-triggered): Prefer `Suggested search terms` from hook output, else extract 2-3 queries from task context

### Step 2: Query ALL 9 Sources

Fire ALL 9 sources in ONE pass. SkillsMP indexes <30% of available skills; GitHub, PolySkill, and SkillHub each have unique skills not found elsewhere.

Execute every item:

```
[] [1] SkillsMP AI -> skillsmp_ai_search x 3 query variants (parallel)
[] [2] SkillsMP KW -> skillsmp_search(query)
-- Continue: sources 3-9 now. SkillsMP covers <30% of skills. --
[] [3] GitHub -> gh search code "{query}" --filename SKILL.md --json path,repository --limit 5 (primary); gh search repos "{query}" --json name,description,url,stargazersCount,updatedAt --limit 5 --sort stars (supplementary)
[] [4] Anthropic -> gh search code "{query}" --repo anthropics/skills --filename SKILL.md --limit 5
[] [5] ClawhHub -> npx -y clawhub search "{query}"
[] [6] skills.sh -> WebFetch("https://skills.sh/api/search?q={query}&limit=5") or curl
[] [7] PolySkill -> npx -y @polyskill/cli search "{single_keyword}" --limit 5
-- Sources 8-9 complete the search. --
[] [8] SkillHub -> bash scripts/fetch-skillhub.sh "{query}" or npx fallback
[] [9] Skills Dir -> bash scripts/fetch-skills-directory.sh "{query}" (skip if no API key)
```

> See `references/search-sources.md` for detailed parameters, response formats, query variants, and fallback commands.

**SEARCH GATE — Output this checklist before proceeding:**

```
POST-SEARCH: [1]Y/N [2]Y/N [3]Y/N [4]Y/N [5]Y/N [6]Y/N [7]Y/N [8]Y/N [9]Y/N
```

**If [3]-[7] are ALL N, go back and fire them NOW.**

<example type="correct">
POST-SEARCH: [1]Y [2]Y [3]Y [4]N [5]Y [6]Y [7]Y [8]Y [9]N
7/9 sources queried. Sources 4,9 failed (acceptable). Proceed to scoring.
</example>

<example type="wrong">
POST-SEARCH: [1]Y [2]Y [3]N [4]N [5]N [6]N [7]N [8]N [9]N
WRONG. Only SkillsMP queried. Go back and fire sources 3-9.
</example>

After all sources return, deduplicate (see `references/search-sources.md`) then proceed to Step 2.5.

Round strategy (max 5): ALL 9 sources must fire within one round. Start a new round only if ALL 9 return 0 results.

### Step 2.5: Score and Rank

Verify: the POST-SEARCH checklist must appear in your output above. If it doesn't, go back to Step 2.

**Formula:** `Total = Relevance(0-40) + Freshness(0-25) + Community(0-20) + Trust(0-15) + External Bonus(0-5)` -> 0-100

**Supplementary lookup:** For top 5 results, `gh api repos/{owner}/{repo} --jq '{pushed_at,stargazers_count}'`. Skip for high-star (>=50) results. Max 3 calls.

**Grades:** `G 85+` Strongly Recommended | `G 70-84` Recommended | `Y 55-69` Worth Considering | `Y 40-54` Marginal | `R <40` Not Recommended

> See `references/quality-signals.md` for scoring breakdown, security labels, and sorting rules.

### Step 3: Present, Select, Install

#### 3a. Display Results

Sort by score descending. Show 5 per page:

```
Found {N} skills, showing {start}-{end}:

1. {name} [{source}] G {score}/100 | *{stars} | Updated: {YYYY-MM} | {security-label}
   {URL}
   Content: {what it provides}   Pros: {match}   Cons: {gaps}

Recommendation: #{N} {name} ({score}/100) -- {reason}
---
Reply: number to install, `c` for next page, "skip" to end
```

> See `references/interaction-patterns.md` for full template, analysis principles, and pagination rules.

#### 3b. User Reply

- **Number** -> install | **Multiple** (e.g., `1,3`) -> install all | **`c`** -> next page | **"skip"** -> end | **New keywords** -> re-search

#### 3c. Choose Installation Scope

**SCOPE GATE — Display this menu and wait for reply. Never auto-select.**

```
Install location:
  [G] Global -> ~/.claude/skills/{name}/
  [L] Local  -> .claude/skills/{name}/
Reply G or L.
```

Global skills persist across projects; local skills travel with the repo. Only the user knows which is appropriate.

<example>
Agent: Install location: [G] Global [L] Local -- Reply G or L.
User: L
Agent: Installing to .claude/skills/react-testing/...
</example>

Verify: the user's G or L reply must appear above before proceeding to 3d.

> See `references/platform-adapters.md` for cross-platform paths and agent detection.

#### 3d. Execute Installation

**SkillsMP source:** `skillsmp_install_skill` -> post-install security scan (Categories A-F) -> warn if findings.

**GitHub source:** Download `SKILL.md` + `references/*.md` + `scripts/*.sh` via `gh api`/`WebFetch` -> pre-install security scan (Categories A-F) -> write on clean/confirmed.

**Direct URL:** `WebFetch` content -> pre-install scan -> write on clean/confirmed.

> See `references/interaction-patterns.md` for security scan categories, severity actions, and findings format.

#### 3e. Verify Installation

1. Glob confirm `{path}/{name}/SKILL.md` exists
2. Read first 10 lines — valid `---` frontmatter with `name` and `description`
3. No same-name conflict at the other scope
4. SHA-256 integrity hash for all files -> record in metadata

#### 3f. Update Metadata

Read/update `~/.claude/skills/.fetch-metadata.json` with source, scope, path, installedAt, integrity hashes, securityLabel, scanResult.

> See `references/search-sources.md` for metadata JSON schema and integrity hash commands.

#### 3g. Activate

- **Claude Code:** `Skill("{name}")` to load
- **Other agents:** Available immediately after file write
- Output: `Installed {name}. Ready to use? Reply 'confirm' or 'skip'.`

### Step 4: Digest References

If installed skill has `references/`, read only files relevant to current task (check first 30 lines). Skip if none.

Output: `External skill installed successfully: {name}`

## References

- **`references/search-sources.md`** — Source commands, error handling, dedup, metadata schema
- **`references/quality-signals.md`** — Scoring dimensions, security labels, ranking
- **`references/interaction-patterns.md`** — Output templates, security review, prompt injection detection
- **`references/platform-adapters.md`** — Cross-platform tool mapping, installation paths, fallbacks
- **`scripts/fetch-skillhub.sh`** — SkillHub API search script
- **`scripts/fetch-skills-directory.sh`** — Skills Directory API search script
