# TOOLS.md — Configuration des outils MissionBound

> Notes sur les outils disponibles et leurs conventions

---

## Outils natifs OpenClaw

### Memory
- **Statut** : ✅ Activé
- **Usage** : Mémoire persistante via MEMORY.md et memory/
- **Sync** : Push quotidien vers Orkestra

### Sessions
- **Statut** : ✅ Activé
- **Usage** : Gestion conversations prospects

### File System (Read)
- **Statut** : ✅ ON
- **Scope** : `./` (workspace)

### Browser
- **Statut** : ✅ ON
- **Usage** : Scraping LinkedIn, Twitter
- **Limites** : Respecter rate limits

### Web Search
- **Statut** : ✅ ON
- **Provider** : Brave Search API

### Exec
- **Statut** : ❌ OFF
- **Raison** : Risque sécurité

---

## Intégrations externes

### Telegram
- **Statut** : ✅ Activé
- **Bot** : Dédié MissionBound
- **Usage** : Reports à JC

### OpenRouter
- **Statut** : ✅ Activé
- **Budget** : 5€/jour max

### GitHub
- **Statut** : ✅ Activé
- **Usage** : Sync avec Orkestra

### Railway
- **Statut** : ✅ Hébergement
- **Port** : 8080

---

*"Ces outils sont mes armes — je les utilise avec précision."*
