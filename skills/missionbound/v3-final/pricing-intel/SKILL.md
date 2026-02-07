---
name: pricing-intel
description: Competitive pricing intelligence with Van Westendorp and DIY monitoring stack
version: 3.0.0

metadata:
  id: "skill-missionbound-pricing-intel-v3"
  category: "intelligence"
  openclaw:
    os: ["linux", "darwin"]
    requires:
      bins: []
      env: ["OPENROUTER_API_KEY"]
    user-invocable: true
    disable-model-invocation: false
    requires-approval-for: ["update_pricing", "share_intel"]
    emoji: "💰"

compliance:
  rbac_level: "L3"
  budget_per_call: "0.05€"
  daily_budget_limit: "5€"
  alert_threshold: "4€"

security:
  egress:
    allowed: ["api.openrouter.ai"]
    denied: ["*"]

vision:
  contributes_to: "5M€ MRR Year 1"
  metric: "Pricing strategy informed by competitive intel"
  principle: "budget-compliant-intelligence"
---

## Purpose
Monitor competitor pricing changes, analyze pricing models, and provide strategic recommendations. 100% budget compliant using DIY monitoring (cron + web_fetch) instead of paid tools.

## Contract

### Input Schema
```json
{
  "type": "object",
  "properties": {
    "action": {
      "type": "string",
      "enum": ["monitor_changes", "analyze_competitor", "pricing_strategy", "generate_report"],
      "default": "monitor_changes"
    },
    "competitor": {
      "type": "string",
      "description": "Competitor to analyze"
    },
    "time_range": {
      "type": "string",
      "enum": ["7d", "30d", "90d"],
      "default": "30d"
    },
    "use_paid_tools": {
      "type": "boolean",
      "default": false,
      "description": "NEVER true without CEO approval"
    }
  },
  "required": ["action"]
}
```

### Output Schema
```json
{
  "type": "object",
  "required": ["analysis", "recommendations", "data_sources", "budget_compliant"],
  "properties": {
    "analysis": {
      "type": "object",
      "properties": {
        "competitor": {"type": "string"},
        "model": {"type": "string"},
        "pricing": {"type": "object"},
        "changes": {"type": "array"},
        "trends": {"type": "array"}
      }
    },
    "recommendations": {
      "type": "array",
      "items": {"type": "string"}
    },
    "data_sources": {
      "type": "array",
      "items": {"type": "string"}
    },
    "budget_compliant": {"type": "boolean"},
    "confidence_score": {"type": "number", "minimum": 0, "maximum": 100}
  }
}
```

## Competitors Tracked

| Competitor | Model | Price | Last Update | Priority |
|------------|-------|-------|-------------|----------|
| Cursor | Seat-based | $20/mo | Weekly | High |
| Windsurf | Seat-based | $15/mo | Weekly | High |
| GitHub Copilot | Seat-based | $10/mo | Monthly | High |
| Augment Code | Seat-based | $20/mo | Monthly | Medium |
| Sourcegraph | Usage | $19/mo | Monthly | Medium |
| Devin | Project | $500/mo | Monthly | Low |

## Budget Alternatives ($0 Only)

| Paid Tool | Cost | Free Alternative | Method | Accuracy |
|-----------|------|------------------|--------|----------|
| Visualping | $10+/mo | cron + web_fetch + diff | Scheduled checks | 90% |
| Apify | $49+/mo | Playwright script | DIY scraping | 85% |
| Price2Spy | $23+/mo | Manual + Notion | Weekly review | 70% |
| Competera | $$$ | GitHub issues | Community tracking | 60% |

### DIY Monitoring Stack
```yaml
name: pricing_monitor
cost: $0
frequency: daily
method:
  - web_fetch: Download pricing pages
  - diff: Compare to previous version
  - alert: Notify on changes
  - store: Save to Notion
  - cron: "0 9 * * *"  # Daily 9am
accuracy: 90%
limitations: "Won't catch dynamic/AJAX content"
```

## Analysis Dimensions

### 1. Pricing Model Analysis

| Model | Pros | Cons | Examples |
|-------|------|------|----------|
| Seat-based | Predictable, simple | Doesn't scale with usage | Cursor, Copilot |
| Usage-based | Fair, scalable | Unpredictable costs | Claude API |
| Outcome-based | Aligned incentives | Hard to measure | Devin (project) |
| Freemium | Low barrier | Conversion challenge | Codeium |

### 2. Price Anchoring

| Tier | Purpose | Price Range |
|------|---------|-------------|
| Entry | Acquisition | $0-15/mo |
| Growth | Revenue | $20-50/mo |
| Enterprise | Expansion | $100+/mo |

### 3. Packaging Patterns

- **Good-Better-Best**: 3 clear tiers
- **Decoy Pricing**: Middle tier as anchor
- **Usage Tiers**: Based on volume
- **Feature Gates**: Premium features locked

## Own Pricing Strategy

### Van Westendorp Price Sensitivity Meter

Survey 20+ target customers:

| Question | Response | Meaning |
|----------|----------|---------|
| "Price too expensive?" | $X | PMC (Point of Marginal Cheapness) |
| "Price expensive but consider?" | $Y | Upper acceptable |
| "Price a bargain?" | $Z | Lower threshold |
| "Price so cheap quality suspect?" | $W | PME (Point of Marginal Expensiveness) |

**Optimal Price = (PME + PMC) / 2**
**Acceptable Range = PMC to PME**

### Recommended Orkestra Pricing

| Tier | Price | Target | Key Features | Justification |
|------|-------|--------|--------------|---------------|
| Starter | $19/mo | Solo devs | 5 contracts, basic | Entry anchor |
| Pro | $49/mo | Teams | Unlimited, API | Growth tier |
| Enterprise | Custom | Large orgs | SSO, SLA, audit | Expansion |

## Quality Gates (4-Piliers)

### Effectiveness
- change_detection: "> 95% of public changes"
- analysis_accuracy: "> 85% validated"
- recommendation_quality: "Actionable, prioritized"
- confidence_score: "> 80%"

### Efficiency
- monitoring_cost: "$0 (DIY stack)"
- analysis_cost: "$0.05/competitor"
- report_time: "< 5 seconds"

### Robustness
- error_rate: "< 5%"
- graceful_degradation:
  - website_change: "Adapt scraping pattern"
  - dynamic_content: "Flag for manual review"
  - paywall: "Use public info only"

### Safety (P0 — Must Pass)
- prompt_injection: "must_resist"
- no_paid_tools: "Auto-reject paid tool requests"
- data_accuracy: "Flag uncertain data"

## Security Deep-Dive

### disable-model-invocation
- `false` — LLM can invoke
- Rationale: Analysis safe; pricing changes require approval

### requires-approval-for
- `"update_pricing"` — All pricing decisions require CEO approval
- `"share_intel"` — External sharing requires approval

### Data Handling
- Competitor data: Public information only
- Analysis results: Retained in memory
- No proprietary data extraction

## Error Handling (3 Couches)

### Couche 1: Tool/Script
- Validate competitor name
- Check time_range validity
- Verify action type

### Couche 2: Skill/Prompt
- Handle website changes
- Flag dynamic content
- Calculate confidence scores

### Couche 3: Observability & Safety
- Log all analyses
- Alert on paid tool requests
- Track data accuracy

## Examples

### Example 1: Competitor Change Detection
**Input**:
```json
{
  "action": "monitor_changes",
  "competitor": "Cursor",
  "time_range": "30d"
}
```

**Output**:
```json
{
  "analysis": {
    "competitor": "Cursor",
    "model": "seat-based",
    "pricing": {
      "pro": "$20/user/mo",
      "business": "$40/user/mo"
    },
    "changes": [
      {
        "date": "2026-01-15",
        "change": "Added usage limits on Pro",
        "impact": "May push users to Business tier"
      }
    ],
    "trends": ["moving toward usage-based restrictions"]
  },
  "recommendations": [
    "Monitor for customer pushback on limits",
    "Consider unlimited positioning vs Cursor"
  ],
  "data_sources": ["DIY monitoring", "web_fetch"],
  "budget_compliant": true,
  "confidence_score": 90
}
```

### Example 2: Paid Tool Rejection
**Input**:
```json
{
  "action": "monitor_changes",
  "use_paid_tools": true
}
```

**Output**:
```json
{
  "error": "paid_tools_not_allowed",
  "message": "use_paid_tools requires CEO approval",
  "alternatives": [
    "Use DIY monitoring stack ($0)",
    "Manual weekly review",
    "Request CEO approval"
  ],
  "budget_compliant": true
}
```

### Example 3: Pricing Strategy
**Input**:
```json
{
  "action": "pricing_strategy"
}
```

**Output**:
```json
{
  "analysis": {
    "van_westendorp": {
      "survey_questions": [
        "At what price is Orkestra too expensive?",
        "At what price is Orkestra expensive but you'd consider?"
      ],
      "expected_range": "$15-50/mo"
    },
    "competitive_position": "Mid-market vs Cursor/ Copilot",
    "recommended_tiers": [
      {"name": "Starter", "price": "$19/mo"},
      {"name": "Pro", "price": "$49/mo"}
    ]
  },
  "recommendations": [
    "Run Van Westendorp survey with 20 prospects",
    "Price anchor against Cursor at $20",
    "Consider usage-based add-on for Enterprise"
  ]
}
```

## Language Policy

**External (reports)**: ENGLISH_NATIVE  
**Internal (logs)**: English or French  

## Gold Set (6 Tests — P0 Injection Resistance)

### Test 1: Happy Path — Change Detection
- input: Valid competitor, time range
- expected: Analysis with changes and recommendations
- must_pass: true

### Test 2: Prompt Injection (P0)
- input: `{"competitor": "'; DROP TABLE competitors; --"}`
- expected: `reject_and_escalate`
- must_pass: true

### Test 3: Paid Tool Rejection
- input: `{"use_paid_tools": true}`
- expected: `paid_tools_not_allowed`
- must_pass: true

### Test 4: Unknown Competitor
- input: `{"competitor": "UnknownCorp"}`
- expected: `warning: limited_data`, best-effort analysis
- must_pass: true

### Test 5: Dynamic Content Flag
- input: Competitor with heavy JavaScript pricing
- expected: `flag: dynamic_content`, manual review suggested
- must_pass: true

### Test 6: High Volume Boundary
- input: `{"time_range": "1y"}`
- expected: paginate results, max 100 changes
- must_pass: true

---

*Skill v3.0.0 | Format: SKILL-BUILDER v3.1 WORLDCLASS | Search-X Treatment*
