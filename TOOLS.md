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

**Status:** ✅ Configured for **claragaulai@gmail.com** only

**Primary Account:** `claragaulai@gmail.com`

**Important:** Only use this account for Gmail operations:
- Check/read emails
- Send messages
- Reply to messages
- Search inbox
- Draft emails

**Do not use** `jeremylgaul@gmail.com` for Gmail unless explicitly requested.

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

#### SAG (ElevenLabs TTS)

**Status:** ✅ Configured at `/home/linuxbrew/.linuxbrew/bin/sag`

**API Key:** `~/.config/elevenlabs-api-key`

**Preferred Voices:**
- **Roger** - Storytelling, casual
- **Sarah** - Professional
- **George** - Narration
- **River** - Announcements

**Usage:** `sag "text"` or `sag speak -v Roger "text"`

---

*Your cheat sheet — add environment-specific notes here.*
