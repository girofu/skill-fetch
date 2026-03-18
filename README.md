# skill-fetch

> Cross-platform skill discovery and installation for AI coding agents

Search, score, and install AI agent skills from **7 registries** in parallel — works across **Claude Code, Cursor, Codex, Gemini CLI, Windsurf, and Amp**.

## Features

- **7 Search Sources** — SkillsMP (semantic + keyword), GitHub, CCPM, ClawSkillHub, skills.sh, prompts.chat
- **Cross-Platform** — Works on 6+ AI coding agents with automatic tool adaptation
- **Multi-Variant AI Search** — 2-3 query variants fired in parallel, improving recall by ~2.4x
- **Quality Scoring** — 0-100 composite score: Relevance (40) + Freshness (25) + Community (20) + Trust (15)
- **Paginated Results** — Browse 5 at a time with `c` to continue; install by number from any page
- **Local/Global Install** — Choose project-level or user-level installation
- **Security Review** — GitHub sources are scanned for dangerous commands before installation
- **Deduplication** — Same skill across registries is merged; similar descriptions are flagged

## Installation

Choose the method that fits your setup:

### Option 1: Plugin (Best experience, Claude Code)

```bash
# Add the marketplace and install
/plugin marketplace add girofu/skill-fetch
/plugin install skill-fetch
```

Provides auto-updates, `/fetch-skill` command, and full plugin integration.

### Option 2: npx skills add (Node.js)

```bash
npx skills add girofu/skill-fetch
```

Works with Claude Code, Cursor, and Codex.

### Option 3: curl | sh (Universal, zero dependencies)

```bash
curl -fsSL https://raw.githubusercontent.com/girofu/skill-fetch/main/install.sh | bash
```

Auto-detects installed agents and installs for all of them. Specify a single agent:

```bash
curl -fsSL https://raw.githubusercontent.com/girofu/skill-fetch/main/install.sh | bash -s -- --agent claude
```

### Option 4: Python installer

```bash
python3 -c "$(curl -fsSL https://raw.githubusercontent.com/girofu/skill-fetch/main/install.py)"
```

Or download and run:

```bash
curl -fsSL https://raw.githubusercontent.com/girofu/skill-fetch/main/install.py -o install.py
python3 install.py --agent cursor
```

### Option 5: Manual (git clone)

```bash
git clone https://github.com/girofu/skill-fetch.git
# Claude Code
cp -r skill-fetch/skills/skill-fetch ~/.claude/skills/skill-fetch
cp -r skill-fetch/references ~/.claude/skills/skill-fetch/references

# Cursor
cp -r skill-fetch/skills/skill-fetch ~/.cursor/skills/skill-fetch
cp -r skill-fetch/references ~/.cursor/skills/skill-fetch/references

# Other agents: replace ~/.cursor/ with ~/.codex/, ~/.gemini/, ~/.windsurf/, or ~/.amp/
```

## Supported Agents

| Agent | Plugin | npx | curl/sh | Python | Manual |
|-------|--------|-----|---------|--------|--------|
| Claude Code | ✅ | ✅ | ✅ | ✅ | ✅ |
| Cursor | — | ✅ | ✅ | ✅ | ✅ |
| Codex | — | ✅ | ✅ | ✅ | ✅ |
| Gemini CLI | — | — | ✅ | ✅ | ✅ |
| Windsurf | — | ✅ | ✅ | ✅ | ✅ |
| Amp | — | — | ✅ | ✅ | ✅ |

## Usage

```
# Search for skills (Claude Code)
/fetch-skill react native animation

# Install from URL
/fetch-skill https://github.com/owner/repo

# Auto-triggered by skill-eval hook
# (no manual invocation needed)
```

In other agents, the skill activates automatically when referenced in context.

## How It Works

```
┌─────────────────────────────────────────────────────┐
│                   User Query                         │
│              "testing React Native"                  │
└──────────────────────┬──────────────────────────────┘
                       │
        ┌──────────────┼──────────────────┐
        ▼              ▼                  ▼
   ┌─────────┐   ┌──────────┐      ┌──────────┐
   │SkillsMP │   │SkillsMP  │      │SkillsMP  │
   │AI Var A  │   │AI Var B  │      │AI Var C  │
   └────┬─────┘   └────┬─────┘      └────┬─────┘
        │              │                  │
        └──────┬───────┘──────────┬───────┘
               ▼                  ▼
   ┌───────────────┐    ┌─────────────────┐
   │ SkillsMP KW   │    │    GitHub        │
   └───────┬───────┘    └────────┬────────┘
           │                     │
   ┌───────┴───────┐    ┌───────┴────────┐
   │  CCPM + Claw  │    │ skills.sh +    │
   │  SkillHub     │    │ prompts.chat   │
   └───────┬───────┘    └───────┬────────┘
           │                     │
           └──────────┬──────────┘
                      ▼
              ┌───────────────┐
              │  Deduplicate  │
              │  & Score      │
              │  (0-100)      │
              └───────┬───────┘
                      ▼
              ┌───────────────┐
              │  Display 5    │
              │  per page     │
              └───────┬───────┘
                      ▼
              ┌───────────────┐
              │  User picks   │
              │  → Install    │
              └───────────────┘
```

> **Cross-platform note:** SkillsMP sources (top of diagram) are only available with the SkillsMP MCP server. On other platforms, the flow starts from GitHub + supplementary sources.

## Search Sources

| # | Source | Method | Type | Availability |
|---|--------|--------|------|-------------|
| 1 | SkillsMP (semantic) | `skillsmp_ai_search` MCP | Primary | Claude Code + MCP |
| 2 | SkillsMP (keyword) | `skillsmp_search` MCP | Primary | Claude Code + MCP |
| 3 | GitHub | `gh search repos` / `curl` | Primary | All agents |
| 4 | CCPM | `npx @daymade/ccpm search` | Supplementary | Agents with npx |
| 5 | ClawSkillHub | `npx -y clawhub search` | Supplementary | Agents with npx |
| 6 | skills.sh | HTTP API / `curl` | Supplementary | All agents |
| 7 | prompts.chat | HTTP / MCP | Supplementary | All agents |

Supplementary sources fail gracefully — if any is unavailable, the search continues with remaining sources.

## Quality Scoring

Each result receives a composite score (0-100):

| Dimension | Weight | How |
|-----------|--------|-----|
| Relevance | 0-40 | LLM judges description-to-task semantic match |
| Freshness | 0-25 | Time since last GitHub push |
| Community | 0-20 | Star count (log scale) |
| Trust | 0-15 | Source credibility tier |

**Grade labels:**

| Score | Grade | Label |
|-------|-------|-------|
| 85+ | S | 🟢 Strongly Recommended |
| 70-84 | A | 🟢 Recommended |
| 55-69 | B | 🟡 Worth Considering |
| 40-54 | C | 🟡 Marginal |
| <40 | D | 🔴 Not Recommended |

## File Structure

```
skill-fetch/
├── .claude-plugin/
│   └── plugin.json                  # Claude Code plugin manifest
├── commands/
│   └── fetch-skill.md               # /fetch-skill slash command
├── skills/
│   └── skill-fetch/
│       └── SKILL.md                 # Main skill (cross-platform)
├── references/
│   ├── quality-signals.md           # Scoring algorithm details
│   ├── interaction-patterns.md      # Output templates & UX patterns
│   └── platform-adapters.md         # Cross-platform tool mapping
├── install.sh                       # Universal bash installer
├── install.py                       # Python installer
├── README.md                        # This file
└── LICENSE                          # MIT
```

## Requirements

**Minimum (any agent):**
- Shell with `curl` for GitHub search and file download

**Full experience (Claude Code):**
- SkillsMP MCP server for registry search
- GitHub CLI (`gh`) for enhanced GitHub search
- Node.js for npx-based registry searches (CCPM, ClawSkillHub)
- WebFetch tool for skills.sh and prompts.chat APIs

## License

MIT
