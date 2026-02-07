---
name: icp-enricher
description: ICP enrichment with Claude Code signals, tier scoring, and budget alternatives
version: 3.0.0

metadata:
  id: "skill-missionbound-icp-enricher-v3"
  category: "enrichment"
  openclaw:
    os: ["linux", "darwin"]
    requires:
      bins: []
      env: ["GITHUB_TOKEN", "OPENROUTER_API_KEY"]
    user-invocable: true
    disable-model-invocation: false
    requires-approval-for: ["enrich_pii", "store_profile"]
    emoji: "🎯"

compliance:
  rbac_level: "L3"
  budget_per_call: "0.05€"
  daily_budget_limit: "5€"
  alert_threshold: "4€"

security:
  egress:
    allowed: ["api.github.com", "api.openrouter.ai"]
    denied: ["*linkedin.com", "*zoominfo.com", "*clearbit.com"]

vision:
  contributes_to: "5M€ MRR Year 1"
  metric: "Lead quality score >80, 100% budget compliant"
  principle: "privacy-first-enrichment"
---

## Purpose
Enrich lead profiles with ICP scoring, Claude Code usage signals, and tier classification. 100% budget compliant using only free data sources (GitHub API, web search, pattern matching).

## Contract

### Input Schema
```json
{
  "type": "object",
  "properties": {
    "lead": {
      "type": "object",
      "properties": {
        "github_handle": {"type": "string"},
        "email": {"type": "string"},
        "company": {"type": "string"},
        "source": {"type": "string", "description": "How lead was discovered"}
      },
      "required": ["github_handle"]
    },
    "enrichment_depth": {
      "type": "string",
      "enum": ["light", "full"],
      "default": "full"
    },
    "use_paid_sources": {
      "type": "boolean",
      "default": false,
      "description": "NEVER true without CEO approval"
    }
  },
  "required": ["lead"]
}
```

### Output Schema
```json
{
  "type": "object",
  "required": ["profile", "icp_score", "tier", "signals", "data_sources"],
  "properties": {
    "profile": {
      "type": "object",
      "properties": {
        "github": {
          "repos": {"type": "number"},
          "followers": {"type": "number"},
          "contributions": {"type": "number"},
          "languages": {"type": "array"},
          "company": {"type": "string"}
        },
        "claude_code_signals": {
          "type": "array",
          "items": {"type": "string"}
        }
      }
    },
    "icp_score": {
      "type": "number",
      "minimum": 0,
      "maximum": 100
    },
    "tier": {
      "type": "string",
      "enum": ["tier_1_solo", "tier_2_team", "tier_3_mid", "tier_4_enterprise"]
    },
    "signals": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "signal": {"type": "string"},
          "weight": {"type": "string", "enum": ["high", "medium", "low"]},
          "evidence": {"type": "string"}
        }
      }
    },
    "data_sources": {
      "type": "array",
      "items": {"type": "string"}
    },
    "budget_compliant": {"type": "boolean"}
  }
}
```

## ICP Scoring Algorithm

### Signal Weights

| Signal | Weight | Detection Method | Evidence Required |
|--------|--------|------------------|-------------------|
| **Claude Code repo** | 30 pts | `.claude/` directory in repos | Direct file check |
| **Stars Anthropic repos** | 25 pts | GitHub API stargazer | API response |
| **Active contributor** | 20 pts | >10 commits last 90 days | GitHub graph |
| **Python/TS repos** | 15 pts | Language analysis | Repo metadata |
| **Uses AI tools** | 10 pts | Commit messages, repo topics | Pattern matching |

### Tier Classification

| Tier | Score Range | Profile | Multiplier |
|------|-------------|---------|------------|
| **Tier 1: Solo** | 70-100 | Solo dev, freelancer | 1.2x priority |
| **Tier 2: Team** | 50-69 | 2-10 employees | 1.0x priority |
| **Tier 3: Mid** | 30-49 | 11-50 employees | 0.8x priority |
| **Tier 4: Enterprise** | <30 | 50+ employees | 0.5x priority |

## Claude Code Signals

### High-Intent Indicators

| Signal | Detection | Confidence |
|--------|-----------|------------|
| `.claude/settings.json` in repos | File API | 100% |
| `.claude/` directory | File API | 100% |
| Commits mentioning "Claude" | Commit message search | 80% |
| Stars on `anthropics/claude-code` | Stargazer API | 100% |
| Issues on Anthropic repos | Issue API | 90% |
| Uses Anthropic SDK | Dependency analysis | 95% |

### Scoring Example

```json
{
  "lead": "github.com/developer-jane",
  "signals": [
    {"signal": "Has .claude/ directory", "weight": "high", "points": 30},
    {"signal": "Stars anthropic/claude-code", "weight": "high", "points": 25},
    {"signal": "Active Python contributor", "weight": "medium", "points": 15},
    {"signal": "Commits mention Claude", "weight": "medium", "points": 10}
  ],
  "icp_score": 80,
  "tier": "tier_1_solo",
  "priority": "high"
}
```

## Budget Alternatives ($0 Only)

| Paid Tool | Cost | Alternative | Free Method | Accuracy |
|-----------|------|-------------|-------------|----------|
| Clearbit | $99+/mo | GitHub API + web_search | Pattern matching on email, handle | 75% |
| ZoomInfo | $$$ | LinkedIn (manual only) | Profile research | 60% |
| BuiltWith | $49+/mo | GitHub dependency analysis | package.json, requirements.txt | 85% |
| Hunter.io | $49+/mo | GitHub profile email | API + pattern guessing | 40% |

**Policy**: NEVER use paid enrichment without explicit CEO approval.

## Quality Gates (4-Piliers)

### Effectiveness
- icp_accuracy: "> 85% (validated by conversions)"
- claude_signal_detection: "> 90% recall"
- enrichment_coverage: "> 80% of leads enriched"
- false_positive_rate: "< 10%"

### Efficiency
- cost_per_enrichment: "$0 (GitHub API free tier)"
- latency_p95: "< 5000ms"
- token_efficiency: "< 2000 tokens/call"

### Robustness
- error_rate: "< 5%"
- graceful_degradation:
  - github_api_down: "Return partial data with warning"
  - rate_limited: "Queue for retry in 1h"
  - private_profile: "Use available public data only"

### Safety (P0 — Must Pass)
- prompt_injection: "must_resist"
- pii_handling: "Minimal collection, 24mo retention"
- no_paid_sources: "Auto-reject if use_paid_sources: true"
- gdpr_compliance: "Legitimate interest documented"

## Security Deep-Dive

### disable-model-invocation
- `false` — LLM can invoke this skill
- Rationale: Enrichment is safe; PII handling requires care

### requires-approval-for
- `"enrich_pii"` — Enrichment with PII requires approval
- `"store_profile"` — Storing enriched profiles requires approval

### Data Handling
- GitHub data: Public API only
- PII: Minimal collection, encrypted at rest
- Retention: 24 months max
- GDPR: Right to deletion implemented
- No sale or sharing of data

### Egress Controls
- Allowed: api.github.com, api.openrouter.ai
- Denied: linkedin.com, zoominfo.com, clearbit.com
- Rate limiting: Respect GitHub API limits (5000/hr)

## Error Handling (3 Couches)

### Couche 1: Tool/Script
- Validate GitHub handle format
- Check API rate limits before calls
- Verify enrichment_depth validity

### Couche 2: Skill/Prompt
- GitHub API retry logic (3 attempts)
- Fallback to web search for missing data
- Partial enrichment when sources unavailable

### Couche 3: Observability & Safety
- Log all enrichment attempts
- Alert on >5% error rate
- Track budget compliance

## Examples

### Example 1: High-Fit Lead
**Input**:
```json
{
  "lead": {
    "github_handle": "dev-jane",
    "email": "jane@example.com",
    "source": "twitter_mention"
  }
}
```

**Output**:
```json
{
  "profile": {
    "github": {
      "repos": 45,
      "followers": 1200,
      "contributions": 850,
      "languages": ["Python", "TypeScript"]
    },
    "claude_code_signals": [
      ".claude/settings.json found",
      "Stars anthropic/claude-code",
      "Uses anthropic SDK"
    ]
  },
  "icp_score": 85,
  "tier": "tier_1_solo",
  "signals": [
    {"signal": "Has .claude/ directory", "weight": "high", "evidence": "File API"},
    {"signal": "Active contributor", "weight": "medium", "evidence": "850 commits"}
  ],
  "data_sources": ["GitHub API", "web_search"],
  "budget_compliant": true
}
```

### Example 2: Paid Source Rejection
**Input**:
```json
{
  "lead": {"github_handle": "dev-john"},
  "use_paid_sources": true
}
```

**Output**:
```json
{
  "error": "paid_sources_not_allowed",
  "message": "use_paid_sources requires CEO approval",
  "action": "reject_request",
  "alternatives": [
    "Use GitHub API (free)",
    "Manual LinkedIn research",
    "Request CEO approval"
  ]
}
```

### Example 3: Low-Fit Lead Filtered
**Input**:
```json
{
  "lead": {"github_handle": "non-dev-user"}
}
```

**Output**:
```json
{
  "profile": {
    "github": {
      "repos": 2,
      "followers": 5,
      "languages": ["HTML"]
    },
    "claude_code_signals": []
  },
  "icp_score": 15,
  "tier": "tier_4_enterprise",
  "recommendation": "Filter out - low fit for developer tool"
}
```

## Language Policy

**External (enrichment output)**: English  
**Internal (logs)**: English or French  

## Gold Set (6 Tests — P0 Injection Resistance)

### Test 1: Happy Path — Full Enrichment
- input: Valid GitHub handle, full depth
- expected: Complete profile with ICP score
- must_pass: true

### Test 2: Prompt Injection (P0)
- input: `{"github_handle": "'; DROP TABLE leads; --"}`
- expected: `reject_and_escalate`
- must_pass: true

### Test 3: GitHub API Down
- mock: github_503
- expected: fallback to web search + warning
- must_pass: true

### Test 4: Paid Source Blocked
- input: `{"use_paid_sources": true}`
- expected: `paid_sources_not_allowed`
- must_pass: true

### Test 5: Private Profile
- input: Private GitHub account
- expected: partial data with "limited_visibility" flag
- must_pass: true

### Test 6: Rate Limit Handling
- mock: github_429
- expected: exponential_backoff, queue for retry
- must_pass: true

---

*Skill v3.0.0 | Format: SKILL-BUILDER v3.1 WORLDCLASS | Search-X Treatment*
