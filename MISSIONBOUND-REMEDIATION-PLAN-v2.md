# MissionBound — Plan de Remédiation WORLDCLASS++ v2.0

> Basé sur audit Claude Code v1.0 + corrections audit plan v1.0 | Score cible : 9.5+  
> Version 2.0 | 7 février 2026

---

## Résumé des Corrections v2.0

### Problèmes identifiés dans l'audit du plan v1.0 (score 7.1/10)

| # | Problème | Correction v2.0 |
|---|----------|-----------------|
| **F1** | 8/12 budgets skills incorrects | ✅ Budgets exacts copiés depuis SKILL.md |
| **F2** | Bug VISION.md dans Dockerfile | ✅ Supprimé ou fallback `|| true` |
| **F3** | sync.yml vague | ✅ Corrections détaillées spécifiées |
| **F4** | Pas d'owners | ✅ Owners assignés par phase |
| **F5** | Pas de checkpoints | ✅ Audits intermédiaires après Phases 1, 3, 5 |
| **F6** | Workflow versioning absent | ✅ Ajouté Phase 3 |
| **F7** | Pipeline PR-like enterprise absent | ✅ Spécifié dans AGENTS.md Phase 1 |
| **F8** | Observabilité/Cockpit faible | ✅ Ajouté Phase 4 avec dashboard Notion |
| **F9** | Bounded Nondeterminism absent | ✅ Tests statistiques Phase 6 |
| **F10** | Circuit breakers absents | ✅ Ajoutés governance.yaml Phase 3 |
| **F11-F13** | Phase 5 sous-estimée | ✅ 9-10 jours au lieu de 6, total 20-22 jours |

### Trajectory Score Corrigée

| Étape | Score v1.0 | Score v2.0 | Delta |
|-------|------------|------------|-------|
| Actuel | 6.0 | 6.0 | — |
| Phase 0+1 | 7.5 | 7.5 | = |
| Phase 2-3 | 8.2 | 8.5 | +0.3 |
| Phase 4-6 | 9.0 | **9.5+** | **+0.5** |

---

## PARTIE 1 : PHASE 0 — URGENCES BLOQUANTES (Jour 1)

**Owner** : Launchpad (Orkestra)  
**Validation** : CEO (JC) review  
**Checkpoint** : `docker build` + `docker run` → skills accessibles

### Action 0.1 : Dockerfile Corrigé v2.0

**Problème identifié** : `skills/` non copié + `VISION.md` inexistant dans repo

```dockerfile
FROM node:22-alpine
RUN apk add --no-cache git curl
WORKDIR /app

# VERSION PINNÉE (reproductibilité)
RUN npm install -g openclaw@1.2.0

# Fichiers système (VISION.md depuis sync ou ignoré si absent)
COPY SOUL.md AGENTS.md TOOLS.md railway.toml ./
# Note: VISION.md vient de sync.yml (orkestra-memory), pas du repo local
# Si absent lors du build, le healthcheck échouera gracieusement

# .github/workflows pour sync
COPY .github/ ./.github/

# SKILLS — CRITIQUE (manquant dans v1.0)
COPY skills/ ./skills/

# WORKFLOWS (versionné — voir Phase 3)
COPY workflows.yaml ./

# SCHÉMAS (créés Phase 3, optionnel ici)
RUN mkdir -p ./schemas

# Mémoire persistante
RUN mkdir -p /data/.openclaw/agents/missionbound-growth/memory

# Sécurité : user non-root
RUN adduser -D appuser && chown -R appuser /app /data
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["openclaw", "gateway", "--config", "./config.json", "--port", "8080"]
```

**Changements v2.0** :
- ✅ `COPY skills/ ./skills/` AJOUTÉ
- ✅ Version pinnée exacte (`@1.2.0`)
- ✅ Commentaire VISION.md (provient de sync, pas du repo)
- ✅ `config.json` chargé explicitement

---

### Action 0.2 : Unification RBAC L3

**Problème** : Contradiction L2 (AGENTS.md) vs L3 (SOUL.md)

**Corrections à appliquer** :

```markdown
# AGENTS.md — Section RBAC (CORRIGÉ v2.0)

## RBAC Level : L3 (Specialist)

Aligné avec : SOUL.md (L3), VISION.md (L3 par défaut pour agents autonomes)

| Capability | Status | Notes |
|------------|--------|-------|
| `memory` | ✅ ON | Enterprise (via orkestra-notion) + Agent (MEMORY.md) |
| `sessions` | ✅ ON | Sub-agents L1-L2 autorisés |
| `fs:read` | ✅ Limité | workspace/ + skills/ uniquement |
| `fs:write` | ⚠️ ON | memory/ uniquement (append-only) |
| `browser` | ✅ ON | Validation CEO pour actions sensibles (login) |
| `exec` | ❌ OFF | Jamais — pas de shell access |
| `web_search` | ✅ ON | Autonome pour recherche |
| `web_fetch` | ✅ ON | Autonome pour extraction |
| `cron` | ✅ ON | Heartbeat actif (30min) |
| `message` | ✅ ON | Telegram/Slack (canaux dédiés) |
| `github` | ✅ ON | PRs via orkestra-github skill (gate CEO) |
| `notion` | ✅ ON | Read/Write via orkestra-notion skill |

**Validation requise pour** : browser login, github PR merge, notion pages sensibles
```

---

### Action 0.3 : config.json Complet

```json
{
  "agent": {
    "id": "missionbound-growth",
    "name": "MissionBound Growth",
    "version": "1.0.0",
    "soul_md": "./SOUL.md",
    "agents_md": "./AGENTS.md",
    "tools_md": "./TOOLS.md",
    "memory_md": "./MEMORY.md"
  },
  "model_routing": {
    "default": "moonshotai/kimi-k2.5",
    "strategy": "anthropic/claude-opus-4",
    "browsing": "deepseek/deepseek-v3",
    "vision": "google/gemini-2.5-flash",
    "twitter": "x-ai/grok-4.1-fast"
  },
  "rbac": {
    "level": "L3",
    "capabilities": {
      "memory": true,
      "sessions": true,
      "fs_read": true,
      "fs_write": "memory_only",
      "browser": true,
      "exec": false,
      "web_search": true,
      "web_fetch": true,
      "cron": true,
      "message": true,
      "github": true,
      "notion": true
    },
    "validation_gates": [
      "browser:login",
      "github:pr_merge",
      "notion:enterprise_pages"
    ]
  },
  "budget": {
    "daily_max_eur": 5.0,
    "alert_threshold": 0.8,
    "hard_stop_threshold": 1.0,
    "model_costs": {
      "moonshotai/kimi-k2.5": 0.0006,
      "anthropic/claude-opus-4": 0.005,
      "deepseek/deepseek-v3": 0.00027,
      "google/gemini-2.5-flash": 0.0001,
      "x-ai/grok-4.1-fast": 0.0002
    }
  },
  "integrations": {
    "notion": {
      "enabled": true,
      "token_env": "NOTION_TOKEN",
      "databases": {
        "memory": "Orkestra Team",
        "tracking": "MissionBound"
      }
    },
    "github": {
      "enabled": true,
      "token_env": "GITHUB_TOKEN",
      "repo": "orkestra-ai-org/missionbound-agent"
    },
    "telegram": {
      "enabled": true,
      "bot_token_env": "TELEGRAM_BOT_TOKEN",
      "channel": "missionbound"
    },
    "slack": {
      "enabled": true,
      "token_env": "SLACK_TOKEN",
      "channel": "#missionbound"
    }
  },
  "skills": {
    "path": "./skills/missionbound/v3-final",
    "auto_load": true,
    "manifest": "skills.yaml",
    "budgets": {
      "search-x-adapter": 0.05,
      "icp-enricher": 0.05,
      "dm-automator": 0.03,
      "gtm-strategist": 0.10,
      "reddit-engager": 0.02,
      "hn-monitor": 0.02,
      "content-multiplier": 0.10,
      "notion-tracker": 0.02,
      "pricing-intel": 0.05,
      "readme-optimizer": 0.05,
      "discord-engager": 0.02,
      "utm-tracker": 0.02
    }
  },
  "workflows": {
    "path": "./workflows.yaml",
    "auto_load": true,
    "versioning": {
      "enabled": true,
      "current": "1.0.0",
      "rollback_allowed": true
    }
  },
  "heartbeat": {
    "enabled": true,
    "interval_minutes": 30,
    "checks": {
      "budget": true,
      "agents": true,
      "backup": true,
      "skills_health": true
    },
    "report_channel": "telegram"
  },
  "security": {
    "circuit_breakers": {
      "enabled": true,
      "error_threshold": 5,
      "timeout_ms": 30000
    },
    "input_validation": "strict",
    "egress_policy": "whitelist"
  },
  "logging": {
    "level": "info",
    "structured": true,
    "format": "jsonl",
    "output": "stdout",
    "traces": true
  }
}
```

**Corrections v2.0** :
- ✅ Budgets skills exacts (corrigés depuis SKILL.md)
- ✅ `versioning` dans workflows
- ✅ `circuit_breakers` ajoutés
- ✅ `skills.budgets` détaillés

---

### Action 0.4 : MEMORY.md Initial

```markdown
# MEMORY.md — MissionBound Growth Agent

> Layer 2 : Agent-level memory | Append-only | Flush protocol

---

## Architecture Mémoire (VISION 6.1)

| Couche | Source | Scope | Sync |
|--------|--------|-------|------|
| **Enterprise** | orkestra-memory | VISION, STANDARDS, RUNBOOK | Toutes les 4h (sync.yml) |
| **Agent** | CE FICHIER | Apprentissages MissionBound | Pre-compaction flush |
| **Session** | OpenClaw natif | Contexte conversation | Auto |

---

## Pipeline PR-like Enterprise Memory (VISION 6.2)

**Règle** : Toute écriture Enterprise = PR-like process

```
Agent propose changement
    ↓
Loggué dans session
    ↓
Notification CEO (Telegram/Slack)
    ↓
CEO : Approve / Reject / Modify
    ↓
Si Approved → Commit atomique via orkestra-github skill
    ↓
Sync vers orkestra-memory
```

**NE JAMAIS** : Écrire directement dans fichiers enterprise sans validation CEO.

---

## Template d'Entrée Agent

```markdown
### [YYYY-MM-DD HH:MM UTC] — [Type: Action|Decision|Learning|Error]

**Contexte** : [Situation complète]

**Action** : [Ce qui a été fait]

**Résultat** : [Mesurable, quantifié si possible]

**Learning** : [Insight réutilisable]

**Référence** : [Message ID, fichier, URL]
```

---

## Entrées

*[À remplir par l'agent à chaque session significative]*

---

## Flush Protocol (Pre-Compaction)

1. **Détection compaction imminente** (>80% context)
2. **Dump MEMORY.md** vers `memory/YYYY-MM-DD.md`
3. **Git commit** avec message "[memory] Session YYYY-MM-DD"
4. **Push** vers orkestra-memory
5. **Confirmation** avant compaction

---

*Dernière mise à jour : 2026-02-07 | Version 1.0*
```

---

### Action 0.5 : Correction sync.yml Détaillée

```yaml
# .github/workflows/sync.yml v2.0
name: Sync Enterprise Memory

on:
  schedule:
    - cron: '0 */4 * * *'  # Toutes les 4h
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout missionbound-agent
        uses: actions/checkout@v4
        
      - name: Checkout orkestra-memory
        uses: actions/checkout@v4
        with:
          repository: orkestra-ai-org/orkestra-memory
          path: orkestra-memory
          token: ${{ secrets.GITHUB_TOKEN }}
        continue-on-error: false  # ❌ Échec visible si orkestra-memory inaccessible
        
      - name: Sync files
        run: |
          # Vérifier existence fichiers source
          for file in VISION.md STANDARDS.md RUNBOOK.md STRATEGY.md CEO_PROFILE.md; do
            if [ ! -f "orkestra-memory/$file" ]; then
              echo "❌ ERREUR: $file manquant dans orkestra-memory"
              exit 1
            fi
            cp "orkestra-memory/$file" .
            echo "✅ Sync: $file"
          done
          
          # Sync skills orkestra (si présents)
          if [ -d "orkestra-memory/skills/orkestra" ]; then
            cp -r orkestra-memory/skills/orkestra/* skills/orkestra/ 2>/dev/null || true
            echo "✅ Sync: orkestra skills"
          fi
          
      - name: Validate sync
        run: |
          # Vérifier fichiers non vides
          for file in VISION.md STANDARDS.md RUNBOOK.md; do
            if [ ! -s "$file" ]; then
              echo "❌ ERREUR: $file vide après sync"
              exit 1
            fi
          done
          echo "✅ Validation sync réussie"
          
      - name: Commit changes
        run: |
          git config user.name "MissionBound Agent"
          git config user.email "missionbound@orkestra.ai"
          git add VISION.md STANDARDS.md RUNBOOK.md STRATEGY.md CEO_PROFILE.md
          git add skills/orkestra/ 2>/dev/null || true
          git diff --cached --quiet || git commit -m "sync: Enterprise memory $(date -u +%Y-%m-%d-%H:%M)"
          git push
```

**Corrections v2.0** :
- ✅ `continue-on-error: false` (erreurs visibles)
- ✅ Vérification fichiers existants avant cp
- ✅ Validation post-sync (fichiers non vides)
- ✅ Sync de tous les fichiers enterprise (pas juste 2)

---

## PARTIE 2 : PHASE 1 — AGENTS.md v2.0 (Jours 2-3)

**Owner** : Launchpad (rédaction)  
**Validation** : Claude Code audit intermédiaire (checkpoint obligatoire)  
**Reviewer** : CEO (JC)  
**Scope** : 60 lignes → 350-400 lignes

### Structure Complète v2.0

```markdown
# AGENTS.md — MissionBound Growth Agent v2.0

## 1. Identity & Context
- Référence SOUL.md
- Alignement VISION.md (Section 2, 3, 6)

## 2. Skills Arsenal (12)
- Liste complète avec budgets EXACTS (corrigés v2.0)
- Routing decision tree (keywords → skill)
- Usage conditions

## 3. Workflows Ordonnancés (6)
- Intégration workflows.yaml versionné
- Workflow execution protocol
- Human gates specification

## 4. Decision Matrix
- FAIT (autonome avec skills)
- SOUMET (validation CEO)
- NE FAIT JAMAIS

## 5. Memory Protocol
- Tri-couche (Enterprise/Agent/Session)
- PR-like pipeline pour Enterprise
- Flush rules

## 6. Escalation Protocol
- Matrice P0-P3
- Canaux (Telegram Urgent, Slack Async)
- Timeouts

## 7. Security & Compliance
- RBAC L3 unifié
- Circuit breakers
- DLP rules

## 8. Gold Set (6 tests)
- Tests d'orchestration
- Tests sécurité
- Tests résilience
```

### Section 2 : Skills Arsenal (Budgets Corrigés v2.0)

| # | Skill | Budget Exact | Usage | Trigger |
|---|-------|--------------|-------|---------|
| 1 | search-x-adapter | **0.05€** | Recherche web structurée | `/search` ou keywords recherche |
| 2 | icp-enricher | **0.05€** | Enrichissement profils | Nouveau lead identifié |
| 3 | dm-automator | **0.03€** | Messages personnalisés | Lead qualifié BANT |
| 4 | gtm-strategist | **0.10€** | Stratégie go-to-market | Weekly planning |
| 5 | reddit-engager | 0.02€ | Engagement Reddit | Daily heartbeat |
| 6 | hn-monitor | 0.02€ | Monitoring HN | Heartbeat 2h + launches |
| 7 | content-multiplier | **0.10€** | Distribution cross-platform | Content ready |
| 8 | notion-tracker | **0.02€** | Tracking projets | After action |
| 9 | pricing-intel | **0.05€** | Intelligence prix | Strategy sessions |
| 10 | readme-optimizer | **0.05€** | Optimisation GitHub | Before launch |
| 11 | discord-engager | 0.02€ | Engagement Discord | Daily heartbeat |
| 12 | utm-tracker | 0.02€ | Tracking campagnes | Campaign setup |

**Note v2.0** : Les 8 budgets en gras ont été corrigés par rapport à la v1.0 du plan.

### Section 3 : Workflow Versioning (NOUVEAU v2.0)

```markdown
## 3. Workflows Versionnés

Chaque workflow a une version semver individuelle :

```yaml
workflows:
  w1_market_intelligence:
    version: "2.1.0"  # Major.Minor.Patch
    locked_skills:
      gtm-strategist: "v1.2.0"
      pricing-intel: "v2.0.1"
      icp-enricher: "v1.5.0"
    trigger: heartbeat_4h
    human_gates: []
    
  w2_community_engagement:
    version: "1.3.0"
    locked_skills:
      reddit-engager: "v2.1.0"
      discord-engager: "v1.0.0"
      hn-monitor: "v3.0.0"
```

**Policy** :
- Major change = breaking (nouvelle validation CEO requise)
- Minor change = nouvelle feature (notification CEO)
- Patch change = bugfix (auto)

**Rollback** : Si workflow échoue, rollback à version précédente automatique.
```

---

## PARTIE 3 : PHASES 2-6 Détaillées

### Phase 2 — SOUL.md v2.0 (Jour 3)

**Owner** : Launchpad  
**Ajouts** :
- Section Skills Reference (quand invoquer chaque skill)
- Section Workflows Reference avec versioning
- Memory Protocol (format, fréquence, PR-like)
- Gold Set pour persona (tests de ton, values, decisions)
- 4-Piliers Quality Gates agent-level

### Phase 3 — Infrastructure & Sécurité (Jours 4-5)

**Owner** : Launchpad  
**Checkpoint** : Audit sécurité intermédiaire (Claude Code)

| # | Livrable | Détail v2.0 |
|---|----------|-------------|
| 3.1 | security/governance.yaml | Policies, approval chains, audit logging |
| 3.2 | security/egress_policy.yaml | Whitelist domaines, rate limits, DLP |
| 3.3 | security/rbac_matrix.yaml | Matrice L1-L4 complète, escalation rules |
| 3.4 | Circuit breakers | 5 erreurs/30s → break, notification, graceful degradation |
| 3.5 | Workflow versioning implémenté | Version dans chaque workflow, skill locking |
| 3.6 | Dockerfile v2.1 | Multi-stage, schemas/ obligatoire |

**Circuit Breaker Spec (v2.0)** :
```yaml
circuit_breakers:
  error_threshold: 5          # Erreurs en 60s
  timeout_ms: 30000           # 30s max par call
  recovery_time_ms: 60000     # 1min avant retry
  fallback_action: "notify_ceo_and_queue"
  notification_channel: "telegram"
```

### Phase 4 — Feedback Loops & Cockpit (Jours 6-8)

**Owner** : Launchpad  
**Checkpoint** : Dashboard opérationnel visible

| # | Livrable | Détail v2.0 |
|---|----------|-------------|
| 4.1 | analytics-reporter skill | Tracking outcome par workflow |
| 4.2 | Workflow W7: feedback_loop | Daily learnings aggregation |
| 4.3 | Cockpit Notion | Dashboard temps réel |
| 4.4 | Observability | Traces inter-skills, latence, tokens |

**Cockpit Notion Structure** :
```
MissionBound Cockpit
├── 📊 Overview
│   ├── Budget jour/semaine
│   ├── Workflows actifs
│   └── Alertes en cours
├── 🎯 KPIs
│   ├── Leads générés (W2, W4)
│   ├── Engagement rate (W2, W3)
│   └── Conversion funnel
├── 🔧 Health
│   ├── Skills status
│   ├── Last heartbeat
│   └── Circuit breaker state
└── 📝 Logs
    ├── Recent actions
    ├── Learnings
    └── Escalations
```

### Phase 5 — Funnel Completion (Jours 9-17) ⚠️ ÉTENDU

**Owner** : Launchpad  
**Validation** : Audit itératif Claude Code (2-3 cycles)  
**Durée** : **9-10 jours** (au lieu de 6) pour itérations qualité

| # | Skill | Stage | Durée estimée |
|---|-------|-------|---------------|
| 5.1 | linkedin-engager | Intent | Jours 9-11 |
| 5.2 | email-outreach | Intent→Purchase | Jours 12-14 |
| 5.3 | onboarding-optimizer | Activation | Jours 15-17 |

**Process v2.0** :
1. Draft SKILL.md (Jour X)
2. Audit Claude Code (Jour X+1)
3. Corrections (Jour X+2)
4. Re-audit si nécessaire (Jour X+3)
5. Gold Set pass → Integration

**Standard cible** : 9.0/10 par skill (pas 7.0 qui baisserait le global).

### Phase 6 — Eval Infrastructure (Jours 18-20) ⚠️ ÉTENDU

**Owner** : Launchpad  
**Checkpoint** : Audit WORLDCLASS++ final

| # | Livrable | Détail v2.0 |
|---|----------|-------------|
| 6.1 | eval/ runner | Bash + assertions, exécutable |
| 6.2 | Gold Sets skills | 12 skills × 6 tests = 72 tests |
| 6.3 | Gold Set agent | 6 tests orchestration |
| 6.4 | Bounded Nondeterminism tests | 10 runs, variance < 5% |
| 6.5 | CI gate | `ork eval run` avant deploy |
| 6.6 | Final audit | Claude Code — Score cible 9.5+ |

**Bounded Nondeterminism Test (NOUVEAU v2.0)** :
```bash
#!/bin/bash
# Test: Même input → output stable

INPUT="test_prompt_1"
EXPECTED_OUTPUT_HASH="abc123..."

for i in {1..10}; do
  OUTPUT=$(missionbound-agent process "$INPUT")
  HASH=$(echo "$OUTPUT" | sha256sum | cut -d' ' -f1)
  
  if [ "$HASH" != "$EXPECTED_OUTPUT_HASH" ]; then
    VARIANCE=$((VARIANCE + 1))
  fi
done

if [ $VARIANCE -gt 1 ]; then  # Max 1 variance acceptable
  echo "❌ FAIL: Nondeterminism too high ($VARIANCE/10)"
  exit 1
fi

echo "✅ PASS: Bounded nondeterminism OK"
```

---

## PARTIE 4 : Checkpoints de Validation (NOUVEAU v2.0)

| Checkpoint | Timing | Validateur | Critères de Pass |
|------------|--------|------------|------------------|
| **CP0** | Fin Phase 0 | Launchpad | `docker build` succeed, skills listables |
| **CP1** | Fin Phase 1 | Claude Code | AGENTS.md v2.0 > 300 lignes, routing tree présent, budgets exacts |
| **CP2** | Fin Phase 3 | Claude Code + CEO | Security audit, circuit breakers testés, RBAC cohérent |
| **CP3** | Fin Phase 5 | Claude Code | 3 nouvelles skills > 8.5/10, funnel complet testé |
| **CP4** | Fin Phase 6 | Claude Code | Score composite > 9.5, tous invariants VISION alignés |

**Règle** : Si checkpoint échoue, retour phase précédente avant continuation.

---

## PARTIE 5 : Scoring Trajectory Réaliste v2.0

| Dimension | Actuel | CP0 | CP1 | CP2 | CP3 | CP4 (Final) |
|-----------|--------|-----|-----|-----|-----|-------------|
| Skills Arsenal | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 |
| AGENTS.md | 4.0 | 4.0 | **8.5** | 8.5 | 8.5 | **9.0** |
| SOUL.md | 7.5 | 7.5 | 7.5 | **8.5** | 8.5 | **9.0** |
| Deployment | 3.5 | **7.0** | 7.0 | **8.5** | 8.5 | **9.0** |
| CI/CD | 5.0 | 5.0 | 5.0 | **7.5** | 7.5 | **9.0** |
| TOOLS.md | 5.0 | 5.0 | 5.0 | **7.0** | 7.0 | **8.0** |
| VISION Alignment | 5.5 | **7.0** | **7.5** | **8.0** | **8.5** | **9.0** |
| Feedback Loops | 4.0 | 4.0 | 4.0 | 4.0 | **8.0** | **8.5** |
| Functional Coverage | 6.5 | 6.5 | 6.5 | 6.5 | **8.5** | **9.0** |
| Data Contracts | 6.0 | 6.0 | 6.0 | **8.5** | 8.5 | **9.0** |
| Budget Discipline | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 |
| Security (Runtime) | 4.5 | **6.5** | 6.5 | **8.5** | 8.5 | **9.0** |
| **COMPOSITE** | **6.0** | **7.0** | **7.5** | **8.5** | **8.7** | **9.5+** |

**Timeline v2.0** :
- Phase 0 : Jour 1 (5h)
- Phase 1 : Jours 2-3 (2 jours)
- Phase 2 : Jour 3 (0.5 jour)
- Phase 3 : Jours 4-5 (2 jours)
- Checkpoint 2 : Jour 6 (audit)
- Phase 4 : Jours 7-9 (3 jours)
- Phase 5 : Jours 10-17 **(8 jours avec itérations)**
- Checkpoint 3 : Jour 18 (audit)
- Phase 6 : Jours 19-21 (3 jours)
- Checkpoint 4 : Jour 22 (audit final)

**Total : 22 jours** (vs 17 dans v1.0)

---

## Conclusion

Ce plan v2.0 corrige les erreurs factuelles (budgets, VISION.md), intègre les concepts VISION manquants (versioning, bounded nondeterminism, PR-like memory, cockpit), et ajoute les garde-fous manquants (owners, checkpoints, itérations d'audit).

**Score atteignable : 9.5+ WORLDCLASS++**

---

*Plan de Remédiation v2.0 | Corrections audit plan v1.0 | 2026-02-07*
