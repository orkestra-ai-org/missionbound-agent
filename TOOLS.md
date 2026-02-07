# TOOLS.md — MissionBound Growth Agent v2.0

> Configuration des outils et policies de sécurité
> Aligné RBAC L3 | VISION Section 12, 14

---

## RBAC Level : L3 (Specialist Agent)

Toutes les capabilities ci-dessous sont alignées avec config.json et AGENTS.md.

---

## Outils Natifs OpenClaw

### Memory
- **Statut** : ✅ ON
- **Usage** : MEMORY.md (agent-level, append-only) + memory/ (daily logs)
- **Sync** : Pre-compaction flush vers orkestra-memory (git push)
- **Sécurité** : Enterprise memory = read-only (PR-like pipeline pour modifications)

### Sessions
- **Statut** : ✅ ON
- **Usage** : Gestion conversations prospects, contexte courant
- **Retention** : Durée session, compacted par OpenClaw

### File System (Read)
- **Statut** : ✅ ON
- **Scope** : `./` (workspace), `./skills/`, `./security/`, `./schemas/`
- **Interdit** : Tout path hors workspace

### File System (Write)
- **Statut** : ⚠️ ON (limité)
- **Scope** : `./memory/` uniquement (append-only)
- **Interdit** : Tout autre path, y compris SOUL.md, AGENTS.md, skills/
- **Rationale** : L'agent écrit ses learnings, pas sa configuration

### Browser
- **Statut** : ✅ ON
- **Usage** : LinkedIn scraping (profils, posts), Twitter (monitoring)
- **Limites** : < 20 connexions LinkedIn/jour, respecter rate limits
- **Sécurité** : Validation CEO requise pour tout login (formulaire, OAuth)
- **Rationale VISION** : browser ON justifié car L3 avec gates explicites

### Exec
- **Statut** : ❌ OFF
- **Rationale** : Risque critique (VISION 12.2). Aucun cas d'usage growth ne nécessite shell access.

### Web Search
- **Statut** : ✅ ON
- **Provider** : Brave Search API
- **Usage** : Recherche concurrentielle, trends, profils
- **Autonome** : Oui (pas de validation requise)

### Web Fetch
- **Statut** : ✅ ON
- **Usage** : Extraction contenu pages web, APIs publiques
- **Autonome** : Oui
- **DLP** : Patterns sensibles redactés (api_key, token, password, secret)

### Cron
- **Statut** : ✅ ON
- **Usage** : Heartbeat agent (30min), workflows schedulés
- **Jobs** : W1 (4h), W2 (2h), W6 (weekly)

### Message
- **Statut** : ✅ ON
- **Canaux** : Telegram (bot MissionBound), Slack (#missionbound)
- **Usage** : Reports CEO, alertes budget, escalations
- **Sécurité** : Canaux dédiés uniquement, pas de DM externe sans gate

---

## Intégrations Externes

### Notion
- **Statut** : ✅ ON
- **Scope** : Read/Write Orkestra Team + MissionBound databases
- **Token** : Via env `NOTION_TOKEN`
- **Rate limit** : 3 req/sec (Notion limit)
- **Usage** : CRM pipeline, dashboard, métriques, reports

### GitHub
- **Statut** : ✅ ON
- **Scope** : PRs via orkestra-github skill, lecture repos publics
- **Token** : Via env `GITHUB_TOKEN`
- **Sécurité** : Merge PR = gate CEO. Jamais de commit direct.

### Telegram
- **Statut** : ✅ ON
- **Bot** : Dédié MissionBound
- **Token** : Via env `TELEGRAM_BOT_TOKEN`
- **Usage** : Reports, alertes P0-P1, escalations urgentes

### Slack
- **Statut** : ✅ ON
- **Canal** : #missionbound
- **Token** : Via env `SLACK_TOKEN`
- **Usage** : Communication async, alertes P2-P3

### OpenRouter
- **Statut** : ✅ ON
- **Budget** : 5€/jour max (via config.json)
- **Models** : Kimi K2.5 (default), Opus 4 (strategy), Deepseek V3 (browsing)
- **Token** : Via env `OPENROUTER_API_KEY`

### Railway
- **Statut** : ✅ Hébergement
- **Port** : 8080
- **Volume** : /data (mémoire persistante)
- **Resources** : 1x CPU, 512MB RAM

---

## Egress Policy (Résumé)

Détail complet dans `security/egress_policy.yaml`.

| Domaine | Méthodes | Usage |
|---------|----------|-------|
| api.notion.com | GET, POST, PATCH | CRM, dashboard |
| api.github.com | GET, POST | PRs, lecture repos |
| api.telegram.org | GET, POST | Notifications |
| api.openrouter.ai | POST | Model routing |
| reddit.com, oauth.reddit.com | GET, POST | Engagement Reddit |
| news.ycombinator.com, hn.algolia.com | GET | Monitoring HN |
| **Tout le reste** | **DENY** | Egress policy whitelist |

---

*TOOLS.md v2.0 | MissionBound Growth | RBAC L3 | 2026-02-07*
