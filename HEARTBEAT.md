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
- **Ollama Cloud usage** — monitor session/weekly limits at https://ollama.com/settings
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

---

*Keep this file minimal. It's loaded every heartbeat.*
