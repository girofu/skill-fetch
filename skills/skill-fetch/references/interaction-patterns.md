# Interaction Patterns Reference

## Search Results Display Template

Analysis results are output as plain-text, showing up to 5 relevant skills per page:

```
🔍 Found {N} relevant skills, showing {start}-{end} of {N}:

1. {skill-name-1} [{source}] 🟢 {score}/100 | ⭐{stars} | Updated: {YYYY-MM}
   📦 {repo URL}
   Content: {what the skill provides}
   Pros: {match with current task, coverage}
   Cons: {limitations or gaps}

2. {skill-name-2} [{source}] 🟡 {score}/100 | ⭐{stars} | Updated: {YYYY-MM} | ⚠️ Unverified
   📦 {repo URL}
   Content: ...
   Pros: ...
   Cons: ...

3. ...
4. ...
5. ...

💡 Recommendation: #N {skill-name-X} ({score}/100 🟢)
   Reason: {why it best fits the need, 1-2 sentences}

---
Reply with a number to install (e.g., `1`), comma-separated for multiple (e.g., `1,3`)
Reply `c` or "continue" to see next 5
Reply "skip" to end search
```

## Analysis Principles

- `[SkillsMP]` / `[GitHub]` / `[skills.sh]` / `[ClawSkillHub]` / `[Anthropic]` / `[PolySkill]` / `[SkillHub]` / `[SkillsDir]` tags mark the source
- Content descriptions are based on search result descriptions, not full skill previews
- Pros/cons are analyzed based on match with the **current task**
- Security labels applied per `quality-signals.md` §6: `🔒 Official`, `🔒 Verified`, `⚠️ Partial`, `⚠️ Unverified`, `⚠️ Security Concerns`
- When multiple skills have different strengths, explain the differences so the user can choose
- Recommendations are based on task relevance, not absolute skill quality

## User Reply Handling

| Reply | Action |
|-------|--------|
| Number (e.g., `1`) | Install that skill |
| Multiple (e.g., `1,3`) | Install multiple skills in order |
| `c` or "continue" | Show next 5 results (ranking continues) |
| "skip" | Output skip phrase, continue task |
| New keywords | Return to Step 2, re-search |

## Post-Installation Confirmation Template

```
✅ Installed {skill-name} (source: {source})
   Path: ~/.claude/skills/{skill-name}/
   Scope: Global / Local
   Usage: Auto-detected by skill-eval hook, or manually via Skill("{skill-name}")

Ready to use this skill? Reply "confirm" or "skip".
```

## No Results Template

```
Searched 5 rounds across all registries but found no relevant skills.

Options:
1. Provide new keywords for another search
2. Continue the task without installing a skill

Reply 1 or 2.
```

## GitHub Security Review

GitHub-sourced skills are not platform-reviewed. Scan before installation:

**Check items:**
- `rm -rf`, `rm -r /` and other destructive commands
- `curl | sh`, `wget | bash` and other remote execution
- Unknown URL `fetch`, `curl`, `wget` calls
- System file modifications (`/etc/`, `~/.ssh/`, `~/.bashrc`)
- Writes to paths outside the skill directory

**When concerns are found:**
```
⚠️ Security review found the following risks:
- {specific risk description}

Install anyway? Reply "confirm install" or "skip".
```

## Cross-Platform Considerations

### Tool Name Adaptation

When outputting instructions to the user, use generic descriptions rather than platform-specific tool names:

- Instead of "Use the Read tool" → "Read the file"
- Instead of "Run Bash command" → "Run the following command"
- Instead of "Use WebFetch" → "Fetch from the URL" (with curl fallback noted)

### Platform-Specific Post-Installation

**Claude Code:**
```
✅ Installed {skill-name} (source: {source})
   Path: ~/.claude/skills/{skill-name}/
   Scope: Global
   Activation: Skill("{skill-name}") or auto-detected by hooks
```

**Cursor / Windsurf:**
```
✅ Installed {skill-name} (source: {source})
   Path: ~/.cursor/skills/{skill-name}/ (or ~/.windsurf/skills/{skill-name}/)
   The skill is now available in your agent's context.
```

**Codex / Gemini CLI / Amp:**
```
✅ Installed {skill-name} (source: {source})
   Path: ~/.codex/skills/{skill-name}/ (or ~/.gemini/ or ~/.amp/)
   The skill file is ready. Reference it in your agent configuration if needed.
```

### Source Availability by Platform

| Source | Claude Code | Cursor | Codex | Gemini | Windsurf | Amp |
|--------|------------|--------|-------|--------|----------|-----|
| SkillsMP (MCP) | ✅ | ⚠️ MCP config needed | ❌ | ❌ | ⚠️ MCP config needed | ❌ |
| GitHub (gh CLI) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Anthropic Skills (gh) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| ClawSkillHub (npx) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| skills.sh (HTTP) | ✅ | ✅ | ⚠️ curl | ✅ | ✅ | ⚠️ curl |
| PolySkill (HTTP/CLI) | ✅ | ✅ | ⚠️ curl | ✅ | ✅ | ⚠️ curl |
| SkillHub (HTTP/CLI) | ✅ | ✅ | ⚠️ curl | ✅ | ✅ | ⚠️ curl |
| Skills Directory (HTTP) | ✅ | ✅ | ⚠️ curl | ✅ | ✅ | ⚠️ curl |

Legend: ✅ Native support | ⚠️ With fallback/config | ❌ Not available

## Rationalization Table

Common excuses for skipping steps and why they are wrong:

| Excuse | Reality |
|--------|---------|
| The search results have enough info | Reading ≠ installing. Future sessions won't have this knowledge. |
| One search with no results is enough | Different keywords yield different results. Search at least 5 rounds. |
| This skill doesn't look relevant | Cannot judge on the user's behalf. Let the user decide. |
| Can answer directly without a skill | External skills have more complete domain knowledge and best practices. |
| The main file info is sufficient | The main file is a summary; references contain implementation details. |
| GitHub source is unsafe so skip it | Do a security review and let the user decide. Do not skip autonomously. |
| SkillsMP alone is enough | Search multiple sources in parallel. GitHub has more community skills. |
| Only searched some sources | ALL 9 sources must fire in parallel. Supplementary sources often have unique results not on SkillsMP. |
| "SkillsMP + GitHub is enough, other sources are redundant" | PolySkill/SkillHub/Skills Directory provide unique quality and security signals not available from search alone. |
| "Anthropic Skills is just another GitHub repo" | It's the official source with highest trust (15/15). Always search it. |
| "Security scanning is unnecessary overhead" | The ClawHavoc incident (1,184 malicious skills) proved otherwise. Security signals protect users. |
| "Default is Global, no need to ask" | The user MUST choose. Default is a suggestion, not permission to skip. |

## Red Flags

Stop immediately and follow the procedure when these thoughts arise:
- "The search results have enough information already"
- "Let me read the skill content first to decide whether to install"
- "Installation is overkill for this task"
- "One search with no results means there's nothing relevant"
- "GitHub sources are unreliable, just use SkillsMP"
- "SkillsMP results are enough, I'll skip the other sources"
- "Let me start with SkillsMP first, then search others if needed"
- "SkillsMP + GitHub covers everything, the new sources won't add anything"
- "Security labels are just noise, let me skip them"
- "The default is Global so I'll just install there without asking"
