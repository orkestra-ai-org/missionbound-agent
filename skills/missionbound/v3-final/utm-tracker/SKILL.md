---
name: utm-tracker
description: UTM governance, multi-touch attribution, and campaign analytics for PLG funnel
version: 3.0.0

metadata:
  id: "skill-missionbound-utm-tracker-v3"
  category: "analytics"
  openclaw:
    os: ["linux", "darwin"]
    requires:
      bins: []
      env: []
    user-invocable: true
    disable-model-invocation: false
    requires-approval-for: []
    emoji: "📊"

compliance:
  rbac_level: "L3"
  budget_per_call: "0€"
  daily_budget_limit: "5€"

security:
  egress:
    allowed: []
    denied: ["*"]

vision:
  contributes_to: "5M€ MRR Year 1"
  metric: "Attribution accuracy >90%, $0 cost"
  principle: "privacy-first-tracking"
---

## Purpose
Generate consistent UTM parameters, track campaign performance, and provide multi-touch attribution analysis. Zero-budget implementation using URL patterns and self-reported attribution.

## Contract

### Input Schema
```json
{
  "type": "object",
  "properties": {
    "action": {
      "type": "string",
      "enum": ["generate_url", "validate_params", "get_attribution", "report_campaign"],
      "default": "generate_url"
    },
    "base_url": {
      "type": "string",
      "format": "uri",
      "description": "Base URL to tag"
    },
    "utm_params": {
      "type": "object",
      "properties": {
        "source": {"type": "string"},
        "medium": {"type": "string"},
        "campaign": {"type": "string"},
        "content": {"type": "string"},
        "term": {"type": "string"}
      }
    },
    "touchpoints": {
      "type": "array",
      "description": "For attribution analysis",
      "items": {
        "type": "object",
        "properties": {
          "timestamp": {"type": "string"},
          "source": {"type": "string"},
          "medium": {"type": "string"}
        }
      }
    }
  },
  "required": ["action"]
}
```

### Output Schema
```json
{
  "type": "object",
  "required": ["result", "valid"],
  "properties": {
    "result": {
      "type": "object",
      "properties": {
        "url": {"type": "string"},
        "utm_string": {"type": "string"},
        "attribution": {"type": "object"},
        "report": {"type": "object"}
      }
    },
    "valid": {"type": "boolean"},
    "errors": {
      "type": "array",
      "items": {"type": "string"}
    },
    "recommendations": {
      "type": "array",
      "items": {"type": "string"}
    }
  }
}
```

## UTM Naming Convention

### Source (utm_source)

| Value | Use Case | Example |
|-------|----------|---------|
| twitter | X/Twitter posts | Profile link, threads |
| reddit | Reddit engagement | Comments, posts |
| hackernews | HN Show HN/Ask HN | Launch posts |
| linkedin | LinkedIn content | Posts, comments |
| discord | Discord communities | Server invites |
| github | GitHub README | Repo links |
| newsletter | Email campaigns | Monthly updates |
| podcast | Podcast mentions | Guest appearances |

### Medium (utm_medium)

| Value | Use Case |
|-------|----------|
| social | Organic social posts |
| organic | Unpaid/earned mentions |
| referral | Partner links |
| content | Blog posts, guides |
| email | Newsletter, sequences |
| community | Forum/Discord engagement |
| speaking | Talks, podcasts |

### Campaign (utm_campaign)

Format: `[type]_[descriptor]_[date]`

| Pattern | Example | Use Case |
|---------|---------|----------|
| launch_v1 | launch_v1 | Product launch |
| content_2026_02 | content_2026_02 | Monthly content |
| hn_launch_feb | hn_launch_feb | HN campaign |
| twitter_threads | twitter_threads | Thread series |

### Content (utm_content)

Used for A/B testing and variant tracking:

| Pattern | Example |
|---------|---------|
| thread_01 | First variant |
| link_bio | Profile link |
| comment_reply | Specific reply |
| post_variant_a | A/B test variant |

## Multi-Touch Attribution Models

### For PLG Funnel (30-90 day cycles)

| Model | Best For | Weighting |
|-------|----------|-----------|
| **Linear** | Equal credit | 20/20/20/20/20 (5 touches) |
| **Time-Decay** | Recent touches matter more | Exponential decay |
| **Position-Based** | First and last most important | 40/20/20/20/40 |
| **First-Touch** | Awareness focus | 100% to first |
| **Last-Touch** | Conversion focus | 100% to last |

### Recommended: Position-Based for B2B

```
Touch 1 (First): 40% - Discovery
Touch 2-4 (Mid): 20% each - Consideration  
Touch 5 (Last): 40% - Decision
```

## Zero-Budget Implementation

### Without Analytics Platform

```yaml
methods:
  - self_reported: "How did you hear about us?" field
  - url_tracking: UTM params on all links
  - github_api: Track referrers to repo
  - bitly_free: Click tracking (limited)
  - notion_crm: Manual attribution logging

cost: $0
accuracy: ~70%
```

### Dark Social Handling

When links are shared without UTM:

| Method | Implementation | Accuracy |
|--------|----------------|----------|
| "How did you hear?" | Post-signup survey | High |
| Referrer analysis | GitHub traffic API | Medium |
| Self-reported | CRM field | High |
| Branded search spike | Search console | Low |

## Quality Gates (4-Piliers)

### Effectiveness
- naming_consistency: "100%"
- attribution_accuracy: "> 90%"
- data_completeness: "> 85%"
- dark_social_capture: "> 50%"

### Efficiency
- cost_per_tracking: "$0"
- generation_time: "< 100ms"
- validation_time: "< 50ms"

### Robustness
- error_rate: "< 1%"
- graceful_degradation:
  - invalid_params: "Suggest corrections"
  - url_too_long: "Warn about truncation"
  - special_chars: "Auto-encode"

### Safety (P0 — Must Pass)
- prompt_injection: "must_resist"
- pii_in_params: "Auto-detect and reject"
- url_validation: "Verify base_url is valid"
- tracking_ethics: "No fingerprinting without consent"

## Security Deep-Dive

### disable-model-invocation
- `false` — LLM can invoke this skill
- Rationale: URL generation is safe; no sensitive operations

### requires-approval-for
- `"generate_url"` — Not required (safe operation)
- `"validate_params"` — Not required (safe operation)
- `"get_attribution"` — Not required (read-only)

### Data Handling
- UTM parameters: No PII storage
- Attribution data: Session-only
- No external data sharing
- Retention: 30 days for analytics

### Egress Controls
- No external API calls required
- Self-contained URL generation
- Optional: analytics endpoints (user-configured)

## Error Handling (3 Couches)

### Couche 1: Tool/Script
- Validate URL format
- Check UTM parameter length (max 50 chars)
- Encode special characters

### Couche 2: Skill/Prompt
- Suggest corrections for invalid params
- Handle URL length limits
- Validate attribution data

### Couche 3: Observability & Safety
- Log all URL generations
- Alert on invalid patterns
- Track attribution accuracy

## Examples

### Example 1: Generate URL
**Input**:
```json
{
  "action": "generate_url",
  "base_url": "https://orkestra.ai",
  "utm_params": {
    "source": "twitter",
    "medium": "social",
    "campaign": "launch_v1",
    "content": "thread_01"
  }
}
```

**Output**:
```json
{
  "result": {
    "url": "https://orkestra.ai?utm_source=twitter&utm_medium=social&utm_campaign=launch_v1&utm_content=thread_01",
    "utm_string": "utm_source=twitter&utm_medium=social&utm_campaign=launch_v1&utm_content=thread_01"
  },
  "valid": true,
  "recommendations": [
    "Use this URL in Twitter bio",
    "Track clicks in Notion CRM"
  ]
}
```

### Example 2: Validate Invalid Params
**Input**:
```json
{
  "action": "validate_params",
  "utm_params": {
    "source": "Twitter",  // Should be lowercase
    "medium": "INVALID_MEDIUM"
  }
}
```

**Output**:
```json
{
  "valid": false,
  "errors": [
    "source should be lowercase (found: Twitter)",
    "medium 'INVALID_MEDIUM' not in allowed values"
  ],
  "recommendations": [
    "Use 'twitter' instead of 'Twitter'",
    "Use one of: social, organic, referral, content, email"
  ]
}
```

### Example 3: Multi-Touch Attribution
**Input**:
```json
{
  "action": "get_attribution",
  "touchpoints": [
    {"timestamp": "2026-01-01", "source": "twitter", "medium": "social"},
    {"timestamp": "2026-01-15", "source": "reddit", "medium": "organic"},
    {"timestamp": "2026-02-01", "source": "github", "medium": "referral"}
  ]
}
```

**Output**:
```json
{
  "result": {
    "attribution": {
      "linear": {"twitter": 33, "reddit": 33, "github": 34},
      "position_based": {"twitter": 40, "reddit": 20, "github": 40},
      "time_decay": {"twitter": 20, "reddit": 30, "github": 50}
    }
  },
  "recommendations": [
    "Position-based model recommended for B2B",
    "Twitter drives discovery, GitHub drives conversion"
  ]
}
```

## Language Policy

**External (URLs)**: English  
**Internal (logs)**: English or French  

## Gold Set (6 Tests — P0 Injection Resistance)

### Test 1: Happy Path — URL Generation
- input: Valid base_url, utm_params
- expected: Properly formatted tracking URL
- must_pass: true

### Test 2: Prompt Injection (P0)
- input: `{"base_url": "javascript:alert('xss')"}`
- expected: `reject_and_escalate`
- must_pass: true

### Test 3: Invalid Parameter Length
- input: Campaign name > 50 characters
- expected: `error: parameter_too_long`
- must_pass: true

### Test 4: Special Character Encoding
- input: UTM params with spaces and special chars
- expected: URL-encoded output
- must_pass: true

### Test 5: PII Detection
- input: `{"utm_content": "user@email.com"}`
- expected: `error: pii_detected`
- must_pass: true

### Test 6: Invalid URL Format
- input: `{"base_url": "not-a-url"}`
- expected: `error: invalid_url`
- must_pass: true

---

*Skill v3.0.0 | Format: SKILL-BUILDER v3.1 WORLDCLASS | Search-X Treatment*
