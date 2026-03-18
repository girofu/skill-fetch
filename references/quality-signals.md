# Quality Signals & Scoring Algorithm

## Scoring Formula

**Total = Relevance (0-40) + Freshness (0-25) + Community (0-20) + Trust (0-15) = 0-100**

### 1. Relevance (0-40) — Most Important

LLM scores based on semantic match between skill description and current task:

| Score | Level | Criteria |
|-------|-------|----------|
| 40 | Exact match | Description directly mentions the task's technology name AND specific use case (e.g., searching "react native animation" → description mentions "Reanimated" + "animation") |
| 30 | Strong match | Description covers the task's core domain (e.g., searching "animation" → description mentions "React Native" + "UI motion") |
| 20 | Partial match | Description covers a related but broader domain (e.g., searching "animation" → description mentions "React Native development") |
| 10 | Weak match | Indirectly related (e.g., searching "animation" → description mentions "mobile app development") |

### 2. Freshness (0-25)

Based on `pushed_at` (GitHub repo last push time):

| Score | Time Range |
|-------|-----------|
| 25 | < 1 month |
| 20 | 1-3 months |
| 15 | 3-6 months |
| 8 | 6-12 months |
| 0 | > 12 months |

**When update time is unavailable:** Assign 10 points (middle value).

### 3. Community Validation (0-20)

Based on stars (take higher of SkillsMP stars and GitHub stars):

| Score | Stars Range |
|-------|------------|
| 20 | ≥ 1,000 |
| 15 | 100-999 |
| 12 | 50-99 |
| 8 | 10-49 |
| 4 | 1-9 |
| 0 | 0 |

**Note:** For individual skills within high-star collection repos (e.g., awesome-agent-skills 11k stars), use the repo's stars but apply a 30% discount (since stars are for the entire collection, not the individual skill).

### 4. Source Credibility (0-15)

| Score | Source |
|-------|--------|
| 15 | SkillsMP + stars ≥ 50 |
| 10 | SkillsMP + stars < 50 |
| 8 | GitHub repo (has SKILL.md frontmatter) |
| 5 | GitHub repo (no standard frontmatter) |
| 3 | Direct URL |

## Grade Labels

| Score Range | Grade | Label | Description |
|------------|-------|-------|-------------|
| 85-100 | S | `🟢 Strongly Recommended` | High match, actively maintained, community validated |
| 70-84 | A | `🟢 Recommended` | Good match, reliable source |
| 55-69 | B | `🟡 Worth Considering` | Partial match or one weakness |
| 40-54 | C | `🟡 Marginal` | Match quality or reliability questionable |
| 0-39 | D | `🔴 Not Recommended` | Low match or severely outdated |

## Display Format

Each search result shows score in a single-line header:

```
1. skill-name [SkillsMP] 🟢 82/100 | ⭐392 | Updated: 2026-03
```

Optional detailed breakdown in the analysis:

```
   Score: Relevance 40 + Freshness 20 + Community 15 + Trust 10 = 85/100 🟢 Strongly Recommended
```

## Sorting Rules

1. **Sort by total score descending**
2. On tie, higher relevance wins
3. Still tied, more recently updated wins

## Lookup Efficiency

Not every result needs a `gh api` lookup. Skip when:

- **SkillsMP stars ≥ 50 and description precisely matches** → assign high score directly
- **SkillsMP stars = 0 and description is vague** → unlikely to score high even with lookup, skip
- **Only look up results ranked 3-7** (top 2 are usually clear, lower ones are unlikely to be selected)

Target: **Maximum 3 `gh api` calls**, avoid wasting time on results that won't be selected.
