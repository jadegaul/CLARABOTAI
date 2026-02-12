# SESSION-STATE.md

**Status:** ACTIVE  
**Last Updated:** 2026-02-11  
**Current Task:** Online, awaiting messages

---

## Active Context

- Proactive Agent v3.0.0 installed and operational
- Preferring agent-browser for web searches and interactive content
- Jade heading to work, intermittent Telegram contact
- ✅ **Ollama Cloud monitoring active** — tracking session/weekly usage limits
- 🎓 **College started February 1, 2026 — actively studying!**
- ✅ **Daily automated backups to GitHub configured**

---

## Recent Decisions & Updates

- ✅ Installing Proactive Agent v3.0.0
- ✅ Using Ollama for heartbeats (free, local)
- ✅ Daily summary at 6am with weather check
- ✅ GOG credentials configured for calendar/email
- ✅ Prefer agent-browser over web_fetch for interactive web tasks
- 🎵 **ARIA'S GIFT SUCCESS**: K-pop band gift was a hit! She really loves it.
- 🎓 **COLLEGE UPDATE (Feb 11, 2026)**
  - School: Western Governors University (WGU)
  - Type: Online, competency-based
  - Program: **Bachelor of Science in Business Administration (BSBA)**
  - First Class: **Fundamentals for Success in Business**
  - **Future Goal: MBA after completing BSBA**
  - Start Date: February 1, 2026
  - Location: Fully online
- ✅ **NEW: Ollama Cloud usage monitoring added to heartbeat checks**
  - Pro plan on jeremylgaul@gmail.com
  - Monitors: Session usage (resets ~10 PM), Weekly usage (resets Sunday)
  - Threshold alerts: Will notify if usage exceeds 80%
  - Current: 1.2% session, 2.6% weekly (2026-02-11)
- ✅ **NEW: Clara Visibility Dashboard built**
  - Location: `/home/jeremygaul/.openclaw/workspace/dashboard/index.html`
  - Components: Status Panel, Task Board (Kanban), Activity Log, Notes Panel, Deliverables
  - Features: Live data, ClickUp sync, heartbeat processing, full transparency
  - Auto-refresh: Every 30 seconds
  - Open: `explorer.exe dashboard/index.html` (from workspace dir)
- ✅ **NEW: Daily automated backups to GitHub**
  - Schedule: Every day at 5:00 AM (America/Los_Angeles)
  - Repository: https://github.com/jadegaul/CLARABOTAI
  - Script: `/home/jeremygaul/.openclaw/workspace/scripts/daily-backup.sh`
  - Includes: Session state, memory files, configuration, skills, notes, logs
  - **Security**: API keys, passwords, tokens automatically redacted
  - Commits: Fully automated (no approval needed)

---

## Preferences & Notes

- Working Buffer activates at 60% context usage
- WAL Protocol: Write corrections, proper nouns, preferences, decisions BEFORE responding
- Compaction Recovery: Read working-buffer.md first after context loss
- **Agent Browser Preference**: Use agent-browser for web searches and internet information
- **Acknowledgment Style**: Use emoji reactions (👍 or 😊) when no response needed — confirms message received
- **Education**: Pursuing BSBA → MBA pathway at WGU
- **Calendar Preference**: Always check `jeremylgaul@gmail.com` shared calendar when asked about schedule/events
- **Voice Replies**: If user sends a voice message, ALWAYS reply with a voice (TTS) response using SAG. Otherwise reply with text.
- **My Email**: ClaraGaulAi@gmail.com — use when checking my emails or verifying links sent to me

---

## Family Updates

- **Aria (16, turning 17 Feb 6)**: Loved her K-pop band birthday gift! 🎁🎵
- **Aiden (11)**: Plays Roblox
- **Sarah**: Stay-at-home mom

## Location

- **Home Address:** 2010 N. Middle Shores St., Portland, OR 97217

---

## Active Cron Jobs

| Job | Schedule | Description |
|-----|----------|-------------|
| **daily-summary** | 6:00 AM daily | Weather, tasks, calendar, emails summary |
| **heartbeat-main** | Every 4 hours | Kanban, calendar, email, system checks |
| **weekly-security-audit** | Sunday 4:00 AM | Security audit and update status check |
| **daily-backup-github** | 5:00 AM daily | Backup to GitHub (sanitized) |

---

## Open Loops

- [x] Monitor heartbeats (every 4 hours) — check BOTH ClickUp lists
- [x] Ollama Cloud usage monitoring configured
- [x] Daily automated backups to GitHub configured
- [ ] Track college progress (study support, deadlines, courses)
- [ ] 6am daily summary tomorrow morning
- [ ] Continue tracking proactive ideas

---

*This file is updated continuously via the WAL Protocol.*
