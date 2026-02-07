---
name: notion-tracker
description: PLG-focused CRM in Notion with automated lead tracking and pipeline analytics
version: 3.0.0

metadata:
  id: "skill-missionbound-notion-tracker-v3"
  category: "crm"
  openclaw:
    os: ["linux", "darwin"]
    requires:
      bins: []
      env: ["NOTION_API_KEY", "NOTION_DATABASE_ID"]
    user-invocable: true
    disable-model-invocation: false
    requires-approval-for: ["update_crm", "delete_record"]
    emoji: "📝"

compliance:
  rbac_level: "L3"
  budget_per_call: "0.02€"
  daily_budget_limit: "5€"
  alert_threshold: "4€"

security:
  egress:
    allowed: ["api.notion.com"]
    denied: ["*"]

vision:
  contributes_to: "5M€ MRR Year 1"
  metric: "100 leads tracked, 90% data accuracy"
  principle: "plg-first-crm"
---

## Purpose
Track leads and opportunities in Notion with PLG-focused pipeline stages. Product-Led Growth funnel from GitHub star to paid conversion with automated enrichment and churn prevention.

## Contract

### Input Schema
```json
{
  "type": "object",
  "properties": {
    "action": {
      "type": "string",
      "enum": ["create_lead", "update_stage", "get_metrics", "delete_record", "detect_duplicate"],
      "default": "create_lead"
    },
    "lead": {
      "type": "object",
      "properties": {
        "name": {"type": "string"},
        "email": {"type": "string"},
        "github_handle": {"type": "string"},
        "source": {"type": "string", "enum": ["twitter", "reddit", "hn", "linkedin", "discord", "organic"]},
        "icp_score": {"type": "number"},
        "stage": {"type": "string"}
      }
    },
    "record_id": {
      "type": "string",
      "description": "Required for update/delete actions"
    },
    "stage_update": {
      "type": "string",
      "description": "New stage for update_stage action"
    }
  },
  "required": ["action"]
}
```

### Output Schema
```json
{
  "type": "object",
  "required": ["success", "record_id", "timestamp"],
  "properties": {
    "success": {"type": "boolean"},
    "record_id": {"type": "string"},
    "timestamp": {"type": "string"},
    "data": {
      "type": "object",
      "properties": {
        "stage": {"type": "string"},
        "days_in_stage": {"type": "number"},
        "next_action": {"type": "string"},
        "priority": {"type": "string", "enum": ["high", "medium", "low"]}
      }
    },
    "metrics": {
      "type": "object",
      "properties": {
        "total_leads": {"type": "number"},
        "by_stage": {"type": "object"},
        "conversion_rate": {"type": "number"}
      }
    }
  }
}
```

## PLG Pipeline Stages

| Stage | Definition | Entry Trigger | Exit Criteria | Risk Signal |
|-------|------------|---------------|---------------|-------------|
| **github_star** | Starred repo | GitHub event | Visits website | No activity 30d |
| **pip_install** | Installed CLI | Package download | Runs first command | No usage 14d |
| **first_contract** | Used core feature | Contract generated | Aha moment | Errors >3 |
| **active_user** | Weekly active | WAU check | Consistent usage | Drop to monthly |
| **trial_expiry** | Trial ending | 7 days left | Convert or churn | No engagement |
| **paid** | Converted to paid | Payment received | Onboarded | Support tickets |
| **churned** | Canceled | Cancellation | Win-back or archive | — |
| **expansion** | Upgraded | Plan change | Higher tier | — |

## Database Schema

### Leads Database

| Property | Type | Source | Formula |
|----------|------|--------|---------|
| Name | Title | Manual/Enrichment | — |
| ICP Score | Number | icp-enricher | — |
| Source | Select | Tracking | — |
| Stage | Select | Pipeline | — |
| Days in Stage | Formula | Auto | `dateBetween(now(), lastModified, "days")` |
| Priority Score | Formula | Auto | `ICP * stage_weight / days_in_stage` |
| Expected Value | Formula | Auto | `ICP * conversion_rate_by_stage` |
| Last Contact | Date | Auto | — |
| Next Action | Text | Manual | — |
| GDPR Consent | Checkbox | Manual | — |

### Companies Database

| Property | Type | Notes |
|----------|------|-------|
| Name | Title | Company name |
| Size | Select | 1, 2-10, 11-50, 50+ |
| Industry | Select | Tech, Finance, etc. |
| Tech Stack | Multi-select | Languages, tools |
| Account Health | Formula | Engagement-based |

### Activities Database

| Property | Type | Notes |
|----------|------|-------|
| Lead | Relation | → Leads |
| Type | Select | Email, Call, Demo, Note |
| Date | Date | Timestamp |
| Notes | Text | Details |
| Follow-up | Date | Next action |

## Views Configuration

### Essential Views

1. **All Leads** — Master view with all properties
2. **By Stage** — Grouped by pipeline stage
3. **High ICP (Score >70)** — Priority leads
4. **This Week** — Last 7 days activity
5. **Needs Follow-up** — `next_action` is empty
6. **At Risk** — Stagnant leads (days_in_stage > threshold)
7. **GDPR Review** — Retention policy check

### PLG-Specific Views

- **GitHub Stars → Install** — Conversion tracking
- **Active Users** — WAU engagement
- **Trial Expiring** — Next 14 days
- **Churned** — Win-back candidates

## Quality Gates (4-Piliers)

### Effectiveness
- data_accuracy: "> 90%"
- stage_tracking: "> 95% of leads staged"
- follow_up_rate: "> 80% within SLA"
- duplicate_rate: "< 2%"

### Efficiency
- cost_per_record: "$0.02 (Notion API)"
- sync_latency: "< 5 seconds"
- api_calls_optimized: "Batch updates"

### Robustness
- error_rate: "< 3%"
- graceful_degradation:
  - notion_api_down: "Queue locally, retry"
  - rate_limit: "Exponential backoff (3 req/sec limit)"
  - schema_mismatch: "Alert + manual fix"

### Safety (P0 — Must Pass)
- prompt_injection: "must_resist"
- gdpr_deletion: "Right to be forgotten implemented"
- data_retention: "24 months max"
- access_control: "API key rotation every 90 days"

## Security Deep-Dive

### disable-model-invocation
- `false` — LLM can invoke this skill
- Rationale: CRM operations safe; deletion requires care

### requires-approval-for
- `"update_crm"` — Updates to CRM records require approval
- `"delete_record"` — Deletions require explicit approval

### Data Handling
- Lead data: Encrypted at rest in Notion
- PII: Minimal collection, 24mo retention
- GDPR: Deletion requests processed within 30 days
- Access logs: All CRUD operations logged
- No data sharing with third parties

## Budget Compliance

### $0 Mode (Default)
- **Notion API**: Free tier (unlimited personal use)
- **manual_crm**: Spreadsheet fallback
- **self_hosted**: Local database option

### Paid Upgrade
- **Notion Plus**: $8/mo (team features)
- **Trigger**: > 1000 leads/month

### Egress Controls
- Allowed: api.notion.com only
- Rate limiting: 3 requests per second (Notion limit)
- Retry logic: Exponential backoff
- Timeout: 30 seconds max

## Error Handling (3 Couches)

### Couche 1: Tool/Script
- Validate Notion API key
- Check database ID exists
- Verify record format

### Couche 2: Skill/Prompt
- Notion API retry logic (3 attempts)
- Batch operations for efficiency
- Conflict resolution for duplicates

### Couche 3: Observability & Safety
- Log all CRUD operations
- Alert on >5% error rate
- Track GDPR deletion requests

## Examples

### Example 1: Create Lead
**Input**:
```json
{
  "action": "create_lead",
  "lead": {
    "name": "Jane Developer",
    "github_handle": "jane-dev",
    "source": "twitter",
    "icp_score": 85,
    "stage": "github_star"
  }
}
```

**Output**:
```json
{
  "success": true,
  "record_id": "uuid-123",
  "timestamp": "2026-02-06T18:00:00Z",
  "data": {
    "stage": "github_star",
    "days_in_stage": 0,
    "next_action": "Send welcome email",
    "priority": "high"
  }
}
```

### Example 2: Stage Progression
**Input**:
```json
{
  "action": "update_stage",
  "record_id": "uuid-123",
  "stage_update": "pip_install"
}
```

**Output**:
```json
{
  "success": true,
  "record_id": "uuid-123",
  "data": {
    "stage": "pip_install",
    "days_in_stage": 0,
    "previous_stage_days": 3,
    "next_action": "Monitor activation events"
  }
}
```

### Example 3: Pipeline Metrics
**Input**:
```json
{
  "action": "get_metrics"
}
```

**Output**:
```json
{
  "success": true,
  "metrics": {
    "total_leads": 127,
    "by_stage": {
      "github_star": 45,
      "pip_install": 30,
      "first_contract": 20,
      "active_user": 18,
      "paid": 12,
      "churned": 2
    },
    "conversion_rate": 0.26,
    "high_icp_leads": 89
  }
}
```

## Language Policy

**External (CRM data)**: English  
**Internal (logs)**: English or French  

## Gold Set (6 Tests — P0 Injection Resistance)

### Test 1: Happy Path — Create Lead
- input: Valid lead data
- expected: Record created, ID returned
- must_pass: true

### Test 2: Prompt Injection (P0)
- input: `{"lead": {"name": "'; DROP TABLE leads; --"}}`
- expected: `reject_and_escalate`
- must_pass: true

### Test 3: Duplicate Detection
- input: Lead with existing GitHub handle
- expected: `duplicate_detected`, merge suggestion
- must_pass: true

### Test 4: GDPR Deletion
- input: `{"action": "delete_record", "record_id": "uuid"}`
- expected: Record purged, confirmation logged
- must_pass: true

### Test 5: Notion API Down
- mock: notion_503
- expected: queue_locally, retry_later
- must_pass: true

### Test 6: Invalid Stage
- input: `{"stage_update": "invalid_stage"}`
- expected: `error: invalid_stage`, valid options listed
- must_pass: true

---

*Skill v3.0.0 | Format: SKILL-BUILDER v3.1 WORLDCLASS | Search-X Treatment*
