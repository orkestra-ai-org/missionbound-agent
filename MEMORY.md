# MEMORY.md — MissionBound Growth Agent

> Layer 2 : Agent-level memory | Append-only | Flush protocol
> Version : 1.0 | 2026-02-07

---

## Architecture Mémoire (VISION 6.1)

| Couche | Source | Scope | Sync |
|--------|--------|-------|------|
| **Enterprise** | orkestra-memory | VISION, STANDARDS, RUNBOOK, STRATEGY | sync.yml (toutes les 4h) |
| **Agent** | CE FICHIER | Apprentissages MissionBound | Pre-compaction flush + git push |
| **Session** | OpenClaw natif | Contexte conversation | Auto-géré |

---

## Pipeline PR-like Enterprise Memory (VISION 6.2)

**Règle absolue** : Toute écriture dans la mémoire Enterprise = processus PR-like.

```
Agent identifie un apprentissage de portée Enterprise
    ↓
Rédige proposition dans session (pas d'écriture directe)
    ↓
Notification CEO via Telegram/Slack (canal urgent si P0-P1)
    ↓
CEO : Approve / Reject / Modify
    ↓
Si Approved → Commit atomique via orkestra-github skill
    ↓
Sync vers orkestra-memory (prochain cycle sync.yml)
```

**NE JAMAIS** :
- Écrire directement dans les fichiers enterprise sans validation CEO
- Modifier VISION.md, STANDARDS.md, RUNBOOK.md, STRATEGY.md
- Bypasser le pipeline, même en "mode urgent"

---

## Droits d'Accès

| Couche | Lecture | Écriture | Validation |
|--------|---------|----------|------------|
| Enterprise | ✅ Oui | ❌ Propose uniquement | CEO review obligatoire |
| Agent (ce fichier) | ✅ Oui | ✅ Append-only | Auto |
| Session | ✅ Oui | ✅ Auto | Auto |

---

## Template d'Entrée Agent

```markdown
### [YYYY-MM-DD HH:MM UTC] — [Type: Action|Decision|Learning|Error]

**Contexte** : [Situation complète — quel workflow, quelle skill, quel trigger]

**Action** : [Ce qui a été fait — skill invoquée, input, paramètres]

**Résultat** : [Mesurable — métriques, output, succès/échec]

**Learning** : [Insight réutilisable — ce qui marche, ce qui ne marche pas, pourquoi]

**Référence** : [Message ID, fichier, URL, workflow_id]
```

---

## Flush Protocol (Pre-Compaction)

1. **Détection** : Context > 80% → préparer flush
2. **Dump** : Copier les entrées nouvelles de MEMORY.md vers `memory/YYYY-MM-DD.md`
3. **Git commit** : `[memory] Session YYYY-MM-DD — N learnings`
4. **Git push** : Vers orkestra-memory (branche agent/missionbound-growth)
5. **Confirmation** : Log dans session avant compaction
6. **Compaction** : OpenClaw peut compresser le contexte

---

## Entrées

*[À remplir par l'agent à chaque session significative]*

---

*Dernière mise à jour : 2026-02-07 | Version 1.0*
