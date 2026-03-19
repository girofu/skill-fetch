# Search Sources — Detailed Reference

Complete instructions for each of the 7 search sources used by skill-fetch.

## Sources 1-2: SkillsMP (Primary — Claude Code with SkillsMP MCP only)

> **Cross-platform note:** SkillsMP tools (`skillsmp_ai_search`, `skillsmp_search`) are only available when the SkillsMP MCP server is configured. If unavailable, skip to Sources 3-7 which work on all platforms.

### Source 1: `skillsmp_ai_search` (semantic search)

AI understands intent, but results are non-deterministic.
**Must use 2-3 query variants in parallel**, merge and deduplicate, to compensate for single-search randomness:
- Variant A: Original query (e.g., `testing React Native mobile app`)
- Variant B: Reorder keywords or use synonyms (e.g., `React Native test automation framework`)
- Variant C: Focus on core technology (e.g., `React Native Jest testing library`)

Merging results from 3 calls significantly improves recall.

### Source 2: `skillsmp_search` (keyword search)

Exact match, stable results, sorted by stars. Serves as a stable baseline for AI search.

```
skillsmp_search(query)
```

## Source 3: GitHub

```bash
gh search repos "{query} claude skill" --json name,description,url,stargazersCount,updatedAt --limit 5 --sort stars
```

If results include collection repos (e.g., awesome-agent-skills), use `gh api` to search their tree for SKILL.md files containing `{query}`.

## Source 4: CCPM Registry

```bash
npx @daymade/ccpm search "{query}" --limit 5
```

Returns skill name, description, tags. Skip this source if npx fails.

## Source 5: ClawSkillHub

```bash
npx -y clawhub search "{query}"
```

Returns slug, description. Skip this source if npx fails.

## Source 6: skills.sh

**WebFetch (preferred):**
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

## Source 7: prompts.chat

prompts.chat provides a Streamable HTTP MCP endpoint:
- **Remote MCP URL**: `https://prompts.chat/api/mcp`
- **Available tool**: `search_prompts` (searches prompts, including skills category), `get_prompt` (get details)
- **No `search_skills` tool** — use `search_prompts` and filter for skills-related results

**If prompts.chat MCP server is configured in `.mcp.json`:**
```
search_prompts({"query": "{query}", "limit": 5})
```

**If MCP is not configured, use WebFetch:**
```
WebFetch("https://prompts.chat/skills?q={query}",
         prompt="Extract skill names, descriptions, IDs, and authors")
```

**curl fallback** (when WebFetch is unavailable):
```bash
curl -s "https://prompts.chat/skills?q={query}"
```

## Deduplication Rules

After merging all source results, deduplicate:
1. **Same-name skill** appearing in multiple sources → keep the version with highest stars/installs, tag all sources
2. **Same GitHub repo** appearing in multiple registries → merge into one entry, tag as `[SkillsMP + CCPM]` etc.
3. **Highly similar descriptions but different names** → keep both but mark as potentially duplicate in analysis

## Round Strategy (max 5 rounds)

**≥1 result (from any source) → stop and proceed to analysis.** Only continue to next round if all sources return 0 results.

| Round | Strategy | Example |
|-------|----------|---------|
| 1 | Hook-suggested / original search terms | `react native animation` |
| 2 | Synonyms or broader category | `react native ui effects` |
| 3 | Split (core technology name) | `reanimated` |
| 4 | Related alternatives | `motion`, `gesture` |
| 5 | Most generalized category | `react native` |
