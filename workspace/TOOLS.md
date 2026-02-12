# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

### Calendar

- **Primary calendar:** `jeremylgaul@gmail.com` (shared with claragaulai@gmail.com)
- **Always check:** When looking for appointments/events, check the shared calendar `jeremylgaul@gmail.com`, not just the default
- **Command:** `gog calendar events jeremylgaul@gmail.com --days <N>`

---

### Web Tools Priority

**Preferred order for web tasks:**
1. **agent-browser** (CLI tool) - First choice for interactive sites, scraping, forms
2. **browser plugin** (chrome profile) - Fallback for visual debugging
3. **web_fetch** - Last resort for simple static pages

Use `agent-browser` for:
- Price checking
- Form submissions
- Screenshots
- JavaScript-heavy sites
- Multi-step navigation

---

### ClickUp

**Status:** ✅ Configured and ready to use

**Workspace:** Jade Gaul's Workspace
**Space:** Team Space  
**Projects:** Project 1, Project 2

**Available Commands:**
```bash
# List workspaces
python3 skills/clickup-skill/scripts/clickup_client.py get_teams

# List spaces
python3 skills/clickup-skill/scripts/clickup_client.py get_spaces team_id="9017845650"

# List tasks in a project
python3 skills/clickup-skill/scripts/clickup_client.py get_tasks list_id="901710515956"

# Create a task
python3 skills/clickup-skill/scripts/clickup_client.py create_task list_id="901710515956" name="New Task" status="to do"

# Update task status
python3 skills/clickup-skill/scripts/clickup_client.py update_task task_id="86dzk52we" status="complete"
```

**Note:** API token is set in ~/.bashrc (do not share or commit this file)

---

### Gmail

**Status:** ✅ Configured for multiple accounts

**Accounts:**
1. **claragaulai@gmail.com** — Family Gmail (Jade/Sarah)
2. **ClaraGaulAi@gmail.com** — Clara's personal email account (NEW)

**Account usage:**
- For family emails: Use `claragaulai@gmail.com`
- For Clara's emails: Use `ClaraGaulAi@gmail.com`
- **Do not use** `jeremylgaul@gmail.com` for Gmail unless explicitly requested.

---

### Subagents & Messaging

**Important:** Subagents cannot resolve display names like "Jade" when sending messages.

**For Telegram:**
- ❌ "Jade" - Won't work (display name not resolvable)
- ✅ "7152537300" - Chat ID (works)
- ✅ "@jadegaul" - Username (works if configured)

**Always use:**
- Telegram chat IDs (numeric)
- Telegram usernames (with @)
- Specific channel/user identifiers

---

### SAG (ElevenLabs TTS)

**Status:** ✅ Configured at `/home/linuxbrew/.linuxbrew/bin/sag`

**API Key:** `~/.config/elevenlabs-api-key`

**Preferred Voices:**
- **Roger** - Storytelling, casual
- **Sarah** - Professional
- **George** - Narration
- **River** - Announcements

**Usage:** `sag "text"` or `sag speak -v Roger "text"`

---

### Clara Dashboard

**Status:** ✅ Built and ready at `/home/jeremygaul/.openclaw/workspace/dashboard/index.html`

**Features:**
- 📊 **Status Panel** - AI state, current task, sub-agents, last activity
- 📋 **Task Board** - Kanban with To Do / In Progress / Done / Archive (LOCAL STORAGE - separate from ClickUp!)
  - Drag and drop tasks between columns
  - Add/edit/delete tasks directly in the UI
  - Persists in browser localStorage
  - Fully independent from ClickUp
- 📜 **Activity Log** - Full timestamped action log (non-negotiable visibility)
- 📝 **Notes Panel** - Drop notes, auto-processed on heartbeat, marked "seen"
- 📁 **Deliverables** - Quick links to reports, Google Drive, GitHub backup

**Usage:**
```bash
# Open dashboard in browser (WSL)
explorer.exe dashboard/index.html
# Or on Linux/Mac:
open dashboard/index.html
# Or serve locally:
cd dashboard && python3 -m http.server 8080
# Then: http://localhost:8080
```

**Sync Data:**
```bash
# Update dashboard with current ClickUp tasks, status, etc.
bash dashboard/scripts/sync-dashboard.sh

# Or add to crontab for auto-sync every 15 minutes:
*/15 * * * * cd /home/jeremygaul/.openclaw/workspace && bash dashboard/scripts/sync-dashboard.sh
```

---

*Your cheat sheet — add environment-specific notes here.*
