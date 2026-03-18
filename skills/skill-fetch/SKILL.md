---
name: skill-fetch
description: >
  Search, discover, and install AI agent skills from 7 registries (SkillsMP, GitHub,
  CCPM, ClawSkillHub, skills.sh, prompts.chat) with multi-variant search, quality scoring,
  pagination, and local/global installation. Use when the user asks to "fetch skill",
  "install skill", "search for a skill", or when a hook outputs "MISSING EXTERNAL SKILL".
user-invocable: true
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "WebFetch", "shell", "read_file", "write_file", "execute_command", "fetch", "curl"]
---

# Skill Fetch

Search, score, and install agent skills from multiple registries in parallel.

## When to Use

- A skill-eval hook outputs "MISSING EXTERNAL SKILL"
- The current task requires domain expertise not available locally
- The user runs `/fetch-skill [query]` or `/fetch-skill [URL]`

## Critical Rules

1. **Never use `skillsmp_get_skill_content` to preview before deciding** — search descriptions are sufficient. Only use as a fallback if installation fails.
2. **Stop on first results, continue only on zero** (max 5 rounds) — any round with ≥1 result proceeds to analysis.
3. **Only the user can decide to skip** — the LLM must never skip installation on its own.
4. **Always use plain-text interaction** — do not use AskUserQuestion. Output analysis and wait for the user to reply with a number or command.
5. **Show up to 5 results per page** — with full analysis (content, pros, cons, repo URL) so the user can make an informed decision.

## Platform Compatibility

This skill works across multiple AI coding agents. Use the platform-appropriate tool:

| Operation | Claude Code | Cursor | Codex | Gemini CLI | Windsurf | Amp |
|-----------|-------------|--------|-------|------------|----------|-----|
| Read file | `Read` | `read_file` | `read_file` | `ReadFile` | `read_file` | `ReadFile` |
| Write file | `Write` | `write_to_file` | `write_file` | `WriteFile` | `write_to_file` | `WriteFile` |
| Edit file | `Edit` | `replace_in_file` | `patch_file` | `EditFile` | `replace_in_file` | `EditFile` |
| Search files | `Glob` | `list_files` | `glob` | `ListFiles` | `list_files` | `Glob` |
| Run command | `Bash` | `execute_command` | `shell` | `RunCommand` | `execute_command` | `Shell` |
| Web fetch | `WebFetch` | `fetch` | N/A | `WebFetch` | `fetch` | N/A |
| Ask user | Plain text output | Plain text output | Plain text output | Plain text output | Plain text output | Plain text output |

> **Note:** If a tool is marked N/A, use `Bash`/`shell` with `curl` as fallback.
> **Auto-detection:** The skill adapts automatically — use whichever tool names your agent provides.

## Procedure

### Step 1: Determine Search Keywords and Source

**URL mode:** If `$ARGUMENTS` is a URL (starts with `https://github.com/...` or any `https://`), skip directly to Step 3 installation flow.

**Search mode:**
- **Has `$ARGUMENTS`**: Use directly as search terms
- **No search terms** (auto-triggered): Prefer `Suggested search terms` from hook output, otherwise extract 2-3 queries from task context

### Step 2: Parallel Search (stop on first results, max 5 rounds)

**Fire all available sources in parallel, merge and deduplicate:**

#### Sources 1-2: SkillsMP (Primary — Claude Code with SkillsMP MCP only)

> **Cross-platform note:** SkillsMP tools (`skillsmp_ai_search`, `skillsmp_search`) are only available when the SkillsMP MCP server is configured. If unavailable, skip to Sources 3-7 which work on all platforms.

1. **`skillsmp_ai_search`** (semantic search) — AI understands intent, but results are non-deterministic.
   **Must use 2-3 query variants in parallel**, merge and deduplicate, to compensate for single-search randomness:
   - Variant A: Original query (e.g., `testing React Native mobile app`)
   - Variant B: Reorder keywords or use synonyms (e.g., `React Native test automation framework`)
   - Variant C: Focus on core technology (e.g., `React Native Jest testing library`)
   Merging results from 3 calls significantly improves recall.
2. **`skillsmp_search`** (keyword search) — Exact match, stable results, sorted by stars. Serves as a stable baseline for AI search.

#### Source 3: GitHub (Supplementary)
3. **`gh search repos`** — `gh search repos "{query} claude skill" --json name,description,url,stargazersCount,updatedAt --limit 5 --sort stars`. If results include collection repos (e.g., awesome-agent-skills), use `gh api` to search their tree for SKILL.md files containing `{query}`.

#### Source 4: CCPM Registry (Supplementary)
4. **`npx @daymade/ccpm search`** — `npx @daymade/ccpm search "{query}" --limit 5`. Returns skill name, description, tags. Skip this source if npx fails.

#### Source 5: ClawSkillHub (Supplementary)
5. **`npx -y clawhub search`** — `npx -y clawhub search "{query}"`. Returns slug, description. Skip this source if npx fails.

#### Source 6: skills.sh (Supplementary)
6. **WebFetch skills.sh API** — Verified API endpoint:
   ```
   WebFetch("https://skills.sh/api/search?q={query}&limit=5",
            prompt="Extract skill names, sources (owner/repo), install counts, and URLs from the JSON response")
   ```
   Returns JSON `{ skills: [{ name, source, installs, id }] }`. Each result URL is `https://skills.sh/{id}`.
   Skip this source if the API returns an error or times out.

   **curl fallback** (when WebFetch is unavailable):
   ```bash
   curl -s "https://skills.sh/api/search?q={query}&limit=5"
   ```

#### Source 7: prompts.chat (Supplementary)
7. **WebFetch prompts.chat MCP endpoint** — prompts.chat provides a Streamable HTTP MCP endpoint:
   - **Remote MCP URL**: `https://prompts.chat/api/mcp`
   - **Available tool**: `search_prompts` (searches prompts, including skills category), `get_prompt` (get details)
   - **No `search_skills` tool** — use `search_prompts` and filter for skills-related results
   - If prompts.chat MCP server is configured in `.mcp.json`, call `search_prompts({"query": "{query}", "limit": 5})` directly
   - If MCP is not configured, use WebFetch: `WebFetch("https://prompts.chat/skills?q={query}", prompt="Extract skill names, descriptions, IDs, and authors")`
   - Skip this source if both methods fail

   **curl fallback** (when WebFetch is unavailable):
   ```bash
   curl -s "https://prompts.chat/skills?q={query}"
   ```

#### Execution Strategy
- **Fire all sources in parallel** (don't wait for each other), merge results
- Sources 4-7 are supplementary; any failure does not affect the overall flow
- If only sources 1-3 are available, behavior is the same as before

#### Deduplication Rules
After merging all source results, deduplicate:
1. **Same-name skill** appearing in multiple sources → keep the version with highest stars/installs, tag all sources
2. **Same GitHub repo** appearing in multiple registries → merge into one entry, tag as `[SkillsMP + CCPM]` etc.
3. **Highly similar descriptions but different names** → keep both but mark as potentially duplicate in analysis

**≥1 result (from any source) → stop and proceed to analysis.** Only continue to next round if all sources return 0 results.

| Round | Strategy | Example |
|-------|----------|---------|
| 1 | Hook-suggested / original search terms | `react native animation` |
| 2 | Synonyms or broader category | `react native ui effects` |
| 3 | Split (core technology name) | `reanimated` |
| 4 | Related alternatives | `motion`, `gesture` |
| 5 | Most generalized category | `react native` |

### Step 2.5: Scoring and Ranking

Calculate a quality score (0-100) for each deduplicated result. See `references/quality-signals.md` for details.

**Scoring formula:** `Total = Relevance(0-40) + Freshness(0-25) + Community(0-20) + Trust(0-15)`

**Supplementary lookup:** For the top 5 results, use `gh api repos/{owner}/{repo} --jq '{pushed_at,stargazers_count}'` to get update time and GitHub stars. Skip lookup for high-star (≥50) results with precisely matching descriptions. Maximum 3 `gh api` calls.

**Grade labels:** `🟢 85+` Strongly Recommended | `🟢 70-84` Recommended | `🟡 55-69` Worth Considering | `🟡 40-54` Marginal | `🔴 <40` Not Recommended

### Step 3: Analyze, Select, Install

#### 3a. Display Comparison Analysis (plain-text)

Sort all deduplicated results by quality score. Maintain the full sorted list. Display 5 per page (1-5, 6-10, 11-15...):

```
🔍 Found {N} relevant skills, showing {start}-{end} of {N}:

{start}. {skill-name} [{source}] 🟢 {score}/100 | ⭐{stars} | Updated: {YYYY-MM}
   📦 {githubUrl or skillsmp URL}
   Content: {what the skill provides}
   Pros: {match with current task, coverage}
   Cons: {limitations or gaps}

{start+1}. {skill-name-2} [{source}] 🟡 {score}/100 | ⭐{stars} | Updated: {YYYY-MM}
   📦 {repo URL}
   ...

...5 items per page...

💡 Recommendation: #{N} {skill-name-X} ({score}/100 🟢)
   Reason: {1-2 sentences explaining why it best fits the need}

---
Reply with a number to install (e.g., `1`), comma-separated for multiple (e.g., `1,3`)
Reply `c` or "continue" to see next 5 ({end+1}-{end+5})
Reply "skip" to end search
```

**Pagination rules:**
- First page shows items 1-5 with recommendation
- User replies `c` or "continue" → show next 5 (6-10), ranking continues, no re-search
- Can keep paging until list is exhausted; last page shows "All {N} results displayed"
- User can reply with a number on any page (numbers are global, e.g., `7` on page 2 = item #7)
- Recommendation is only shown on the first page

**Scoring formula** (see `references/quality-signals.md`):
- Relevance (0-40): LLM judges description-to-task semantic match
- Freshness (0-25): Time since `pushed_at`
- Community (0-20): Star count (log scale)
- Trust (0-15): Source credibility

**Analysis principles:**
- Sort by total score descending; break ties by relevance first
- Each header line shows score and color grade (🟢/🟡/🔴)
- Add `⚠️` for skills not updated in 6+ months; add `⚠️ Unreviewed` for GitHub sources
- When multiple skills have different strengths, explain the differences so the user can decide

#### 3b. Wait for User Reply

- **Number** (e.g., `1` or `7`) → Install the selected skill (global numbering, works across pages)
- **Multiple** (e.g., `1,3`) → Install multiple skills
- **`c` or "continue"** → Show next 5 results (ranking continues, no re-search)
- **"skip"** → Output `External skill fetch: user chose to skip installation.` and continue task
- **New keywords** → Return to Step 2 and re-search

#### 3c. Choose Installation Location

Before installing, ask the user for installation scope (if not already specified):

```
📦 Install location:
  [G] Global (available to all projects) → ~/.claude/skills/{skill-name}/
  [L] Local (this project only) → .claude/skills/{skill-name}/
Default: G (Global)
```

**Installation path reference:**

| Scope | Path | Use Case |
|-------|------|----------|
| Global | `~/.claude/skills/{skill-name}/` | General skills (shared across projects) |
| Local | `{project-root}/.claude/skills/{skill-name}/` | Project-specific skills (travels with repo) |

**Claude Code Skill Discovery order** (first found wins):
1. `{project}/.claude/skills/` — Project local
2. `~/.claude/skills/` — User global

**Cross-platform skill directories:**

| Agent | Global Path | Local Path |
|-------|-------------|------------|
| Claude Code | `~/.claude/skills/{name}/` | `.claude/skills/{name}/` |
| Cursor | `~/.cursor/skills/{name}/` | `.cursor/skills/{name}/` |
| Codex | `~/.codex/skills/{name}/` | `.codex/skills/{name}/` |
| Gemini CLI | `~/.gemini/skills/{name}/` | `.gemini/skills/{name}/` |
| Windsurf | `~/.windsurf/skills/{name}/` | `.windsurf/skills/{name}/` |
| Amp | `~/.amp/skills/{name}/` | `.amp/skills/{name}/` |

**Auto-detection:** Check which agent directories exist and install to the detected agent's path. If multiple agents are detected, ask the user which to install for.

#### 3d. Execute Installation

**SkillsMP source:** Use `skillsmp_install_skill`. If it doesn't support the target path: use `skillsmp_get_skill_content` to get content → security review → write to target path.

**GitHub source:**
1. Use `gh api` or `WebFetch` to get SKILL.md from the repo (search for `**/SKILL.md`)
2. **Security review** (required for GitHub sources): Scan for dangerous commands (`rm -rf`, `curl | sh`, unknown URLs)
3. If security concerns are found, inform the user of the risks and wait for confirmation
4. Write to `{skill-name}/SKILL.md` at the target path
5. If the repo contains `references/` or `scripts/`, download them to corresponding subdirectories

**Direct URL source:**
1. `WebFetch` to get content (supports raw GitHub URLs, Gist URLs)
2. Security review same as GitHub source
3. Write to `{skill-name}/SKILL.md` at the target path

#### 3e. Post-Installation Verification

After installation, run the following checks to ensure the skill can be discovered:

1. **File existence check**: Use Glob to confirm `{target-path}/{skill-name}/SKILL.md` exists
2. **Frontmatter check**: Read the first 10 lines of SKILL.md, confirm valid `---` frontmatter (with `name` and `description`)
3. **Conflict check**: Confirm no same-name skill exists at the other installation path (avoid local/global conflicts)

On verification failure, output specific errors with fix suggestions.

#### 3f. Update Metadata

Read and update `~/.claude/skills/.fetch-metadata.json`:
```json
{
  "skill-name": {
    "source": "skillsmp|github|url",
    "query": "<search terms or URL>",
    "scope": "global|local",
    "path": "<actual installation path>",
    "installedAt": "<ISO>"
  }
}
```

#### 3g. Activate and Confirm

1. **Claude Code:** Call `Skill("{skill-name}")` to load and activate
2. **Other agents:** The skill is available immediately after file installation — no activation step needed
3. Inform the user of installed skill name, path, source, and scope
4. Output: "Installed {skill-name}. Ready to use? Reply 'confirm' or 'skip'."
5. Wait for user confirmation before continuing with the original task

### Step 4: Digest Reference Materials

Installed skills may contain a `references/` subdirectory.

1. Use Glob to check for `references/`
2. Only read files **directly relevant to the current task** (check first 30 lines for relevance)
3. Summarize key knowledge for use in subsequent planning
4. Skip if no `references/` exists

After completion, output: `External skill installed successfully: {skill-name}`

## Completion Phrases

- Success: `External skill installed successfully: {name}`
- Skipped: `External skill fetch: user chose to skip installation.`

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| The search results have enough info | Reading ≠ installing. Future sessions won't have this knowledge. |
| One search with no results is enough | Different keywords yield different results. Search at least 5 rounds. |
| This skill doesn't look relevant | You cannot judge on the user's behalf. Let the user decide. |
| I can answer directly without a skill | External skills have more complete domain knowledge and best practices. |
| The main file info is sufficient | The main file is a summary; references contain implementation details. |
| GitHub source is unsafe so skip it | Do a security review and let the user decide. Don't skip on your own. |
| SkillsMP alone is enough | Search multiple sources in parallel. GitHub has more community skills. |

## Red Flags

Stop immediately and follow the procedure when these thoughts arise:
- "The search results have enough information already"
- "Let me read the skill content first to decide whether to install"
- "Installation is overkill for this task"
- "One search with no results means there's nothing relevant"
- "GitHub sources are unreliable, just use SkillsMP"

## Additional Resources

- **`references/interaction-patterns.md`** — Output templates, user reply handling, security review
- **`references/quality-signals.md`** — Quality assessment dimensions, lookup methods, ranking algorithm
