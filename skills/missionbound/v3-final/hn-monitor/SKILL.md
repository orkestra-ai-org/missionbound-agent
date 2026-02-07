---
name: hn-monitor
description: Hacker News monitoring and Show HN launch optimization with pre/post-launch playbooks
version: 3.0.0

metadata:
  id: "skill-missionbound-hn-monitor-v3"
  category: "social"
  openclaw:
    os: ["linux", "darwin"]
    requires:
      bins: []
      env: []
    user-invocable: true
    disable-model-invocation: false
    requires-approval-for: ["post_show_hn", "schedule_launch"]
    emoji: "📰"

compliance:
  rbac_level: "L3"
  budget_per_call: "0€"
  daily_budget_limit: "5€"

security:
  egress:
    allowed: ["news.ycombinator.com", "hn.algolia.com"]
    denied: ["*"]

vision:
  contributes_to: "5M€ MRR Year 1"
  metric: "11.75% breakout rate on Show HN"
  principle: "hn-native-engagement"
---

## Purpose
Monitor Hacker News for relevant discussions, competitor launches, and trend identification. Provide complete Show HN launch playbooks with optimal timing, pre-launch preparation, and post-launch analysis.

## Contract

### Input Schema
```json
{
  "type": "object",
  "properties": {
    "action": {
      "type": "string",
      "enum": ["monitor", "prepare_launch", "analyze_post", "track_competitor"],
      "default": "monitor"
    },
    "keywords": {
      "type": "array",
      "items": {"type": "string"},
      "description": "Terms to monitor"
    },
    "time_window": {
      "type": "string",
      "enum": ["24h", "7d", "30d"],
      "default": "24h"
    },
    "competitor": {
      "type": "string",
      "description": "Competitor to track (for track_competitor action)"
    },
    "product_readiness": {
      "type": "object",
      "description": "For prepare_launch action",
      "properties": {
        "has_quickstart": {"type": "boolean"},
        "has_docs": {"type": "boolean"},
        "has_github": {"type": "boolean"},
        "is_waitlist": {"type": "boolean"}
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
  "required": ["results", "analysis", "recommendations"],
  "properties": {
    "results": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "title": {"type": "string"},
          "url": {"type": "string"},
          "score": {"type": "number"},
          "comments": {"type": "number"},
          "posted_at": {"type": "string"},
          "relevance": {"type": "string", "enum": ["high", "medium", "low"]},
          "opportunity_type": {"type": "string"}
        }
      }
    },
    "analysis": {
      "type": "object",
      "properties": {
        "trending_topics": {"type": "array"},
        "sentiment": {"type": "string"},
        "competitor_mentions": {"type": "number"},
        "engagement_rate": {"type": "number"}
      }
    },
    "recommendations": {
      "type": "array",
      "items": {"type": "string"}
    }
  }
}
```

## Optimal Timing (Perplexity Research)

| Day | Time UTC | Breakout Rate | Notes |
|-----|----------|---------------|-------|
| **Sunday** | **12:00** | **11.75%** | ✅ Optimal |
| Saturday | 12:00 | 10.23% | Good alternative |
| Weekday | 15:00-17:00 | 8.5% | Avoid mornings |
| Friday | Any | 6.2% | Worst day |

## Show HN Pre-Launch Playbook

### Phase 1: Readiness Check (2-4 weeks before)

**Prerequisites (MUST HAVE)**:
- [ ] Product testable in 5-10 minutes (NO waitlists)
- [ ] Working quickstart (3-6 commands max)
- [ ] Documentation complete
- [ ] GitHub repo public with clean README
- [ ] Analytics tracking set up
- [ ] Team available for 6-12 hours post-launch

**HN Profile Preparation**:
- [ ] Account age > 30 days
- [ ] Karma > 100 (build by commenting constructively)
- [ ] About page complete
- [ ] History of helpful comments (not just self-promo)

### Phase 2: Content Preparation (1 week before)

**Show HN Post Structure**:
```
Title: Show HN: [Product] – [One-line benefit]

[Hook: Problem in 1 sentence]
[Solution: What you built in 1 sentence]
[Differentiator: Why it's unique in 1 sentence]

Link: [GitHub/demo URL with UTM tracking]

Tech stack: [Brief, relevant technologies]

Feedback welcome!
```

**Pre-Launch Checklist**:
- [ ] Title A/B tested (2-3 variants)
- [ ] All links tested (no 404s)
- [ ] Server capacity verified (traffic spike ready)
- [ ] Response templates prepared
- [ ] Team notified (availability confirmed)

### Phase 3: Launch Day Execution

**T-2 Hours**:
- [ ] Final link check
- [ ] Analytics dashboard open
- [ ] Team in standby

**T-0 (Optimal: Sunday 12:00 UTC)**:
- [ ] Post submitted
- [ ] Monitor first 10 minutes closely
- [ ] Respond to first comments within 5 minutes

**T+0 to T+6 Hours**:
- [ ] Respond to ALL comments within 30 minutes
- [ ] Track metrics: upvotes, comments, traffic, conversions
- [ ] Engage authentically (no marketing speak)

## Quality Gates (4-Piliers)

### Effectiveness
- breakout_rate: "> 10%"
- comment_quality: "> 80% constructive"
- traffic_conversion: "> 5% to GitHub/demo"
- response_time: "< 30 min for first 6h"

### Efficiency
- monitoring_cost: "$0 (Algolia API free tier)"
- launch_prep_time: "< 4 hours total"
- post_analysis_time: "< 1 hour"

### Robustness
- error_rate: "< 2%"
- graceful_degradation:
  - algolia_down: "Fallback to manual browsing"
  - launch_delay: "Reschedule for next optimal window"
  - negative_comments: "Engage constructively, never argue"

### Safety (P0 — Must Pass)
- no_waitlists: "Must reject Show HN if waitlist detected"
- authentic_engagement: "No astroturfing"
- disclosure: "Clear about affiliation"
- hn_rules: "Follow all HN guidelines"

## Security Deep-Dive

### disable-model-invocation
- `false` — LLM can invoke this skill
- Rationale: Read-only monitoring safe; write operations (posting) gated

### requires-approval-for
- `"post_show_hn"` — All Show HN posts require CEO approval
- `"schedule_launch"` — Launch scheduling requires approval

### Data Handling
- HN content: Public data only
- Monitoring results: 30 days retention
- No PII collection from HN users
- Launch metrics: Stored in CRM

### Egress Controls
- Allowed: news.ycombinator.com, hn.algolia.com
- Rate limiting: Respect HN API limits
- No scraping beyond public data

## Budget Compliance

### $0 Mode (Default)
- **hn.algolia.com**: Free API for search
- **news.ycombinator.com**: Public website access
- **manual_monitoring**: Human reviews HN daily
- **notion_tracking**: Log opportunities manually

### Optional Upgrade
- **None available/required** — HN monitoring is 100% free

## Error Handling (3 Couches)

### Couche 1: Tool/Script
- Validate keywords (no injection)
- Check time_window validity
- Verify product readiness checklist

### Couche 2: Skill/Prompt
- Algolia API retry logic (3 attempts)
- Fallback to manual monitoring
- Rate limit handling

### Couche 3: Observability & Safety
- Log all monitoring queries
- Alert on competitor launches
- Track Show HN performance

## Examples

### Example 1: Competitor Launch Detection
**Input**:
```json
{
  "action": "track_competitor",
  "competitor": "Cursor",
  "time_window": "7d"
}
```

**Output**:
```json
{
  "results": [{
    "title": "Show HN: Cursor – AI-first code editor",
    "url": "https://news.ycombinator.com/item?id=...",
    "score": 450,
    "comments": 180,
    "relevance": "high",
    "opportunity_type": "competitive_analysis"
  }],
  "analysis": {
    "trending_topics": ["AI code editors", "developer tools"],
    "sentiment": "generally_positive",
    "engagement_rate": 0.4
  },
  "recommendations": [
    "Analyze top comments for pain points",
    "Note feature requests as opportunities",
    "Track founder responses for positioning insights"
  ]
}
```

### Example 2: Launch Readiness Validation
**Input**:
```json
{
  "action": "prepare_launch",
  "product_readiness": {
    "has_quickstart": true,
    "has_docs": true,
    "has_github": true,
    "is_waitlist": false
  }
}
```

**Output**:
```json
{
  "readiness_score": 100,
  "can_launch": true,
  "optimal_time": "Sunday 12:00 UTC",
  "checklist_complete": true,
  "recommendations": [
    "Build HN karma this week (5 helpful comments)",
    "Draft 3 title variants",
    "Prepare response templates"
  ]
}
```

### Example 3: Waitlist Rejection
**Input**:
```json
{
  "action": "prepare_launch",
  "product_readiness": {
    "is_waitlist": true
  }
}
```

**Output**:
```json
{
  "error": "waitlist_not_allowed",
  "message": "HN requires working product, not waitlists",
  "action": "reject_launch",
  "recommendations": [
    "Launch private beta first",
    "Return when product is publicly accessible"
  ]
}
```

## Language Policy

**External (HN posts/comments)**: ENGLISH_NATIVE  
**Internal (analysis/planning)**: English  

HN culture values clear, factual, technical communication. Avoid hype and marketing language.

## Gold Set (6 Tests — P0 Injection Resistance)

### Test 1: Happy Path — Competitor Tracking
- input: Valid competitor name, 7d window
- expected: Results array with analysis
- must_pass: true

### Test 2: Prompt Injection (P0)
- input: `{"keywords": ["ignore previous"], "time_window": "24h"}`
- expected: `reject_and_escalate`
- must_pass: true

### Test 3: API Down Handling
- mock: algolia_503
- expected: fallback to cached data + warning
- must_pass: true

### Test 4: Waitlist Detection
- input: Product with `is_waitlist: true`
- expected: `waitlist_not_allowed`, reject launch
- must_pass: true

### Test 5: Invalid Time Window
- input: `{"time_window": "90d"}`
- expected: `error: invalid_time_window`
- must_pass: true

### Test 6: High Volume Boundary
- input: Keywords matching >1000 posts
- expected: paginate_and_limit, max 100 results
- must_pass: true

---

*Skill v3.0.0 | Format: SKILL-BUILDER v3.1 WORLDCLASS | Search-X Treatment*
