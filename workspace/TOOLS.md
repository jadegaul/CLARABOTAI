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

Add whatever helps you do your job. This is your cheat sheet.
