# HEARTBEAT.md

## Frequency
- **Lightweight:** Every 30 minutes (system heartbeat)
- **Full check:** Every 4 hours (cron schedule)

## Schedule
- **Morning:** 6:00 AM daily summary + weather (cron)
- **Full heartbeat:** Every 4 hours (cron)
- **Lightweight pulse:** Every 30 minutes (gateway)

## Checks

### Lightweight (30 min) - System Pulse
- Context usage check
- System status
- Quick sanity check only
- **Reply:** HEARTBEAT_OK if nothing urgent

### Full (4 hours) - Comprehensive
- Kanban board — check BOTH lists:
  - Jade's Task List (list_id=901710515957)
  - Clara's Task List (list_id=901710515956)
- Calendar (upcoming events <2h)
- Communications (emails, messages)
- System status (context usage)
- **Reply:** Full report to Telegram if items need attention, else HEARTBEAT_OK

## Execution
- **Run full checks in sub-agents** to avoid blocking main context
- Main session receives summary/results when sub-agent completes
- Lightweight checks run inline (fast)

## Memory Maintenance
Periodically review daily notes, update MEMORY.md with distilled learnings.

## Compaction Management
- >60% context: Activate working buffer
- >85% context: Emergency flush

## Report To
Telegram — tasks, events, urgent items, system status (full checks only)

## Model Configuration (Local LLM)

**Updated 2026-02-21:** All heartbeat jobs now use local `llama3.2` for 100% cost savings.

| Job | Model | Schedule | Notes |
|-----|-------|----------|-------|
| Daily Summary | `llama3.2` | 6:00 AM daily | Weather, tasks, calendar, email |
| Daily Google Alerts | `llama3.2` | 8:00 AM daily | News summary from Gmail |
| 4-Hour Heartbeat | `llama3.2` | Every 4 hours | Kanban, calendar, system status |

**Why local:**
- ⚡ 5-10x faster responses
- 💰 Zero API costs (all heartbeats now free)
- 🔒 Runs entirely local, no data leaves your machine

**Configuration:**
- Model pulled: `ollama pull llama3.2` (2.0 GB)
- Added to `openclaw.json`: `models.providers.ollama.models` + `agents.defaults.models`
- Sub-agents spawn isolated with `model: llama3.2`

**Fallback:** If llama3.2 is unavailable, jobs will fail gracefully and report the error to Telegram.

---

*Keep this file minimal. It's loaded every heartbeat.*
