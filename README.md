# skill-fetch

> Cross-platform skill discovery and installation for AI coding agents

Search, score, and install AI agent skills from **9 registries** in parallel — works across **Claude Code, Cursor, Codex, Gemini CLI, Windsurf, and Amp**.

## Quick Start

1. **Install** — pick any method from [Installation](#installation) below
2. **Set up API keys** — run `/fetch-skill-config` (interactive, recommended) or [configure manually](#️-setup-api-keys)
3. **Search & install skills** — `/fetch-skill react native animation`

## Features

- **9 Search Sources** — SkillsMP (semantic + keyword), GitHub, Anthropic Skills, ClawSkillHub, skills.sh, PolySkill, SkillHub, Skills Directory
- **Cross-Platform** — Works on 6+ AI coding agents with automatic tool adaptation
- **Multi-Variant AI Search** — 3 query variants fired in parallel, improving recall significantly
- **Quality Scoring** — 0-100 composite score: Relevance (40) + Freshness (25) + Community (20) + Trust (15) + External Bonus (5)
- **Security Labels** — 5 trust tiers: Official, Verified, Partial, Unverified, Security Concerns
- **6-Category Security Scan** — Destructive commands, RCE, data exfiltration, system modification, obfuscation, prompt injection
- **Prompt Injection Detection** — 5 sub-categories (PI-1~PI-5): direct override, hidden role markers, encoding tricks, indirect injection, social engineering
- **Integrity Verification** — SHA-256 hash recorded at install, tamper detection on future loads
- **Paginated Results** — Browse 5 at a time with `c` to continue; install by number from any page
- **Local/Global Install** — Choose project-level or user-level installation (mandatory prompt)
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

## ⚙️ Setup API Keys

> **Important:** API keys unlock the full 9-source search. Without them, only Sources 3-8 are available (still useful, but fewer results).

### Interactive Setup (Recommended)

Run `/fetch-skill-config` in Claude Code. It will:
- Show which keys are currently configured
- Walk you through setting each key with links to get them
- Automatically install the SkillsMP MCP server if needed
- Write everything to `~/.claude/skills/.fetch-config.json`

### Manual Setup

### 🔑 SkillsMP API Key (Sources 1-2) — Recommended

SkillsMP provides the **best semantic search** with AI-powered matching. Get your free API key:

1. Go to **[skillsmp.com](https://skillsmp.com)** and create an account
2. Copy your API key
3. Register the MCP server:

```bash
claude mcp add --scope user skillsmp -- npx -y skillsmp-mcp-server --env SKILLSMP_API_KEY=your_key_here
```

4. **Restart Claude Code** — SkillsMP tools will be available in the next session

### 🔑 SkillHub & Skills Directory (Sources 8-9) — Optional

For additional coverage, create `~/.claude/skills/.fetch-config.json`:

```json
{
  "SKILLSMP_API_KEY": "your-skillsmp-key",
  "SKILLHUB_API_KEY": "sk-sh-your-key-here",
  "SKILLS_DIRECTORY_API_KEY": "sk_live_your-key-here"
}
```

> Sources 3-8 work **without any API keys**. Source 9 (Skills Directory) requires a key.

---

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
   │ + Anthropic    │    │    + PolySkill   │
   └───────┬───────┘    └────────┬────────┘
           │                     │
   ┌───────┴───────┐    ┌───────┴────────┐
   │  ClawSkillHub │    │  skills.sh     │
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
              │  Security     │
              │  Scan (A-F)   │
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
              │  → Hash       │
              └───────────────┘
```

> **Cross-platform note:** SkillsMP sources require the MCP server + API key (see [API Key Setup](#api-key-setup)). On other platforms, the flow starts from GitHub + supplementary sources.

## Search Sources

| # | Source | Method | Type | Availability |
|---|--------|--------|------|-------------|
| 1 | SkillsMP (semantic) | `skillsmp_ai_search` MCP × 3 variants | Primary | Claude Code + MCP |
| 2 | SkillsMP (keyword) | `skillsmp_search` MCP | Primary | Claude Code + MCP |
| 3 | GitHub | `gh search code --filename SKILL.md` (primary) + `gh search repos` (supplementary) | Primary | All agents |
| 4 | Anthropic Skills | `gh search code` in `anthropics/skills` | Official | All agents |
| 5 | ClawSkillHub | `npx -y clawhub search` | Supplementary | Agents with npx |
| 6 | skills.sh | HTTP API / WebFetch | Supplementary | All agents |
| 7 | PolySkill | `npx -y @polyskill/cli search` (single keyword) | Supplementary | Agents with npx |
| 8 | SkillHub | Bundled shell script (API) or CLI fallback | Supplementary | All agents |
| 9 | Skills Directory | Bundled shell script (API) | Supplementary | Configured agents |

All sources are searched **in parallel**. Sources fail gracefully — if any is unavailable, the search continues with remaining sources.

## API Key Setup

> See [⚙️ Setup API Keys](#️-setup-api-keys) above for detailed instructions.

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

## Security

### Security Labels

| Label | Criteria |
|-------|----------|
| 🔒 Official | From `anthropics/skills` repo |
| 🔒 Verified | SkillsMP stars ≥ 50 + securityGrade A/B + scan clean |
| ⚠️ Partial | Lower stars but scan clean, or standard frontmatter present |
| ⚠️ Unverified | Direct URL or no external signals |
| ⚠️ Security Concerns | Scan found issues or securityGrade D/F |

### 6-Category Security Scan

All skills are scanned before (or immediately after) installation:

| Category | Name | Severity |
|----------|------|----------|
| A | Destructive Commands | Critical |
| B | Remote Code Execution | Critical |
| C | Data Exfiltration | High |
| D | System Modification | High |
| E | Obfuscation | Medium |
| F | Prompt Injection (5 sub-types) | High |

### Integrity Verification

After installation, SHA-256 hashes are recorded for all skill files. On future loads, hashes are compared to detect tampering.

### Permissions Declaration (Advisory)

Skills may optionally declare their required permissions (`network`, `filesystem-write`, `shell-commands`, `external-urls`) in SKILL.md frontmatter. The scanner flags mismatches between declared and actual behavior.

## File Structure

```
skill-fetch/
├── .claude-plugin/
│   └── plugin.json                   # Claude Code plugin manifest
├── commands/
│   ├── fetch-skill.md               # /fetch-skill slash command
│   └── fetch-skill-config.md        # /fetch-skill-config API key setup
├── skills/
│   └── skill-fetch/
│       ├── SKILL.md                  # Main skill (cross-platform)
│       ├── references/
│       │   ├── search-sources.md     # Source-specific commands & dedup rules
│       │   ├── quality-signals.md    # Scoring algorithm + security labels
│       │   ├── interaction-patterns.md # Output templates, security scan, prompt injection
│       │   └── platform-adapters.md  # Cross-platform tool mapping
│       └── scripts/
│           ├── fetch-skillhub.sh     # SkillHub API search (reads key from config)
│           └── fetch-skills-directory.sh # Skills Directory API search
├── install.sh                        # Universal bash installer
├── install.py                        # Python installer
├── CHANGELOG.md                      # Version history
├── README.md                         # This file
└── LICENSE                           # MIT
```

## Requirements

**Minimum (any agent):**
- Shell with `curl` or `WebFetch` for HTTP-based searches

**Full experience (Claude Code):**
- SkillsMP MCP server + API key from [skillsmp.com](https://skillsmp.com) (see [API Key Setup](#api-key-setup))
- GitHub CLI (`gh`) for GitHub and Anthropic Skills search
- Node.js for npx-based searches (ClawSkillHub, PolySkill, SkillHub CLI)
- `~/.claude/skills/.fetch-config.json` for SkillHub and Skills Directory APIs (optional)

## License

MIT
