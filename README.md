# skill-fetch

> Cross-platform skill discovery and installation for AI coding agents

Search, score, and install AI agent skills from **9 registries** in parallel — works across **Claude Code, Cursor, Codex, Gemini CLI, Windsurf, and Amp**.

## Features

- **9 Search Sources** — SkillsMP (semantic + keyword), GitHub, Anthropic Skills, ClawSkillHub, skills.sh, PolySkill, SkillHub, Skills Directory
- **Cross-Platform** — Works on 6+ AI coding agents with automatic tool adaptation
- **Multi-Variant AI Search** — 3 query variants fired in parallel, improving recall significantly
- **Quality Scoring** — 0-100 composite score: Relevance (40) + Freshness (25) + Community (20) + Trust (15) + External Bonus (5)
- **Security Labels** — `Official`, `Verified`, `Partial`, `Unverified`, `Security Concerns` per source
- **Paginated Results** — Browse 5 at a time with `c` to continue; install by number from any page
- **Local/Global Install** — Choose project-level or user-level installation (mandatory prompt)
- **Security Review** — GitHub sources are scanned for dangerous commands before installation
- **Deduplication** — Same skill across registries is merged; similar descriptions are flagged
- **Bundled API Scripts** — Pre-built shell scripts for SkillHub and Skills Directory APIs (no API key exposure)

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

# Cursor
cp -r skill-fetch/skills/skill-fetch ~/.cursor/skills/skill-fetch

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
   │ Anthropic     │    │  ClawSkillHub  │
   │ Skills (official) │ │               │
   └───────┬───────┘    └───────┬────────┘
           │                     │
   ┌───────┴───────┐    ┌───────┴────────┐
   │  skills.sh    │    │  PolySkill     │
   └───────┬───────┘    └───────┬────────┘
           │                     │
   ┌───────┴───────┐    ┌───────┴────────┐
   │  SkillHub     │    │ Skills         │
   │  (API script) │    │ Directory      │
   └───────┬───────┘    └───────┬────────┘
           │                     │
           └──────────┬──────────┘
                      ▼
              ┌───────────────┐
              │  Deduplicate  │
              │  Score & Rank │
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
| 1 | SkillsMP (semantic) | `skillsmp_ai_search` MCP × 3 variants | Primary |
| 2 | SkillsMP (keyword) | `skillsmp_search` MCP | Primary |
| 3 | GitHub | `gh search repos` | Primary |
| 4 | Anthropic Skills | `gh search code` in `anthropics/skills` | Official |
| 5 | ClawSkillHub | `npx -y clawhub search` | Supplementary |
| 6 | skills.sh | HTTP API / WebFetch | Supplementary |
| 7 | PolySkill | `npx -y @polyskill/cli search` (single keyword) | Supplementary |
| 8 | SkillHub | Bundled shell script (API) or CLI fallback | Supplementary |
| 9 | Skills Directory | Bundled shell script (API) | Supplementary |

All sources are searched **in parallel**. Sources fail gracefully — if any is unavailable, the search continues with remaining sources.

## API Key Setup (Optional)

Sources 8-9 provide enhanced results with API keys. Create `~/.claude/skills/.fetch-config.json`:

```json
{
  "SKILLHUB_API_KEY": "sk-sh-your-key-here",
  "SKILLS_DIRECTORY_API_KEY": "sk_live_your-key-here"
}
```

The bundled scripts in `scripts/` read keys from this config file automatically — API keys are never exposed in command-line arguments.

Sources 1-7 work without any API keys.

## Quality Scoring

Each result receives a composite score (0-100):

| Dimension | Weight | How |
|-----------|--------|-----|
| Relevance | 0-40 | LLM judges description-to-task semantic match |
| Freshness | 0-25 | Time since last GitHub push |
| Community | 0-20 | Star count (log scale) |
| Trust | 0-15 | Source credibility tier |
| External Bonus | 0-5 | Security/quality signals from PolySkill, SkillHub, Skills Directory |

**Grade labels:**

| Score | Label |
|-------|-------|
| 85+ | 🟢 Strongly Recommended |
| 70-84 | 🟢 Recommended |
| 55-69 | 🟡 Worth Considering |
| 40-54 | 🟡 Marginal |
| <40 | 🔴 Not Recommended |

**Security labels:**

| Label | Meaning |
|-------|---------|
| 🔒 Official | From `anthropics/skills` repo |
| 🔒 Verified | Verified by registry |
| ⚠️ Partial | Some verification |
| ⚠️ Unverified | Community source, no verification |
| ⚠️ Security Concerns | Flagged by security scan |

## File Structure

```
skill-fetch/
├── .claude-plugin/
│   └── plugin.json                  # Claude Code plugin manifest
├── commands/
│   └── fetch-skill.md               # /fetch-skill slash command
├── skills/
│   └── skill-fetch/
│       ├── SKILL.md                 # Main skill (cross-platform)
│       ├── references/
│       │   ├── search-sources.md    # Source-specific commands & config
│       │   ├── quality-signals.md   # Scoring algorithm details
│       │   ├── interaction-patterns.md  # Output templates, rationalization table
│       │   └── platform-adapters.md # Cross-platform tool mapping
│       └── scripts/
│           ├── fetch-skillhub.sh    # SkillHub API search (reads key from config)
│           └── fetch-skills-directory.sh  # Skills Directory API search
├── install.sh                       # Universal bash installer
├── install.py                       # Python installer
├── README.md
└── LICENSE                          # MIT
```

## Requirements

**Minimum (any agent):**
- Shell with `curl` or `WebFetch` for HTTP-based searches

**Full experience (Claude Code):**
- SkillsMP MCP server for registry search (`claude mcp add skillsmp -- npx -y skillsmp-mcp-server`)
- GitHub CLI (`gh`) for GitHub and Anthropic Skills search
- Node.js for npx-based searches (ClawSkillHub, PolySkill, SkillHub CLI)
- `~/.claude/skills/.fetch-config.json` for SkillHub and Skills Directory APIs (optional)

## Changelog

### v1.2.0
- **9 registries** — Added Anthropic Skills, PolySkill, SkillHub, Skills Directory (replaced CCPM, prompts.chat)
- **Bundled API scripts** — `scripts/fetch-skillhub.sh` and `scripts/fetch-skills-directory.sh` prevent API key exposure
- **Security labels** — Official, Verified, Partial, Unverified, Security Concerns
- **External Bonus** — New scoring dimension (0-5) from PolySkill, SkillHub, Skills Directory signals
- **GitHub search fix** — Removed restrictive "skill SKILL.md" suffix that caused 0 results
- **PolySkill fix** — Single-keyword search (multi-word queries return 0)
- **Description format** — Third-person per skill-development best practices
- **Progressive disclosure** — Rationalization Table and Red Flags moved to references/

### v1.0.1
- Initial release with 7 registries

## License

MIT
