# skill-fetch

> Multi-registry skill discovery and installation for Claude Code

Search, score, and install AI agent skills from **7 registries** in parallel — with quality scoring, pagination, and local/global installation.

## Features

- **7 Search Sources** — SkillsMP (semantic + keyword), GitHub, CCPM, ClawSkillHub, skills.sh, prompts.chat
- **Multi-Variant AI Search** — 2-3 query variants fired in parallel to compensate for non-deterministic AI search, improving recall by ~2.4x
- **Quality Scoring** — 0-100 composite score: Relevance (40) + Freshness (25) + Community (20) + Trust (15)
- **Paginated Results** — Browse 5 at a time with `c` to continue; install by number from any page
- **Local/Global Install** — Choose project-level (`.claude/skills/`) or user-level (`~/.claude/skills/`)
- **Security Review** — GitHub sources are scanned for dangerous commands before installation
- **Deduplication** — Same skill across registries is merged; similar descriptions are flagged

## Quick Start

### Install as a Claude Code skill

```bash
# Option 1: Using skills CLI
npx skills add girofu/skill-fetch

# Option 2: Manual installation
git clone https://github.com/girofu/skill-fetch.git
cp -r skill-fetch ~/.claude/skills/skill-fetch
```

### Usage

```
# Search for skills
/fetch-skill react native animation

# Install from URL
/fetch-skill https://github.com/owner/repo

# Auto-triggered by skill-eval hook
# (no manual invocation needed)
```

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

## Search Sources

| # | Source | Method | Type |
|---|--------|--------|------|
| 1 | SkillsMP (semantic) | `skillsmp_ai_search` MCP | Primary |
| 2 | SkillsMP (keyword) | `skillsmp_search` MCP | Primary |
| 3 | GitHub | `gh search repos` | Primary |
| 4 | CCPM | `npx @daymade/ccpm search` | Supplementary |
| 5 | ClawSkillHub | `npx -y clawhub search` | Supplementary |
| 6 | skills.sh | `WebFetch` API | Supplementary |
| 7 | prompts.chat | `WebFetch` / MCP | Supplementary |

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

## User Interaction

```
🔍 Found 22 relevant skills, showing 1-5 of 22:

1. detox [SkillsMP] 🟢 85/100 | ⭐160 | Updated: 2026-02
   📦 https://github.com/partme-ai/full-stack-skills
   Content: Complete Detox E2E testing framework guide
   Pros: High stars, focused on Detox E2E
   Cons: E2E only, no unit tests

2. react-native-testing [SkillsMP + skills.sh] 🟢 82/100 | ⭐84 + 📥306
   📦 https://github.com/pluginagentmarketplace/custom-plugin-react-native
   Content: Jest + Testing Library + Detox E2E + CI/CD
   Pros: Most comprehensive — unit + component + E2E
   Cons: May be too general

...

💡 Recommendation: #2 react-native-testing (82/100 🟢)

---
Reply number to install, `c` for next 5, or "skip"
```

## File Structure

```
skill-fetch/
├── SKILL.md                           # Main skill instructions
├── references/
│   ├── quality-signals.md             # Scoring algorithm details
│   └── interaction-patterns.md        # Output templates & UX patterns
└── README.md                          # This file
```

## Requirements

- **Claude Code** with MCP tools (SkillsMP)
- **GitHub CLI** (`gh`) for GitHub search and API calls
- **Node.js** for npx-based registry searches (CCPM, ClawSkillHub)
- **WebFetch** tool for skills.sh and prompts.chat APIs

## License

MIT
