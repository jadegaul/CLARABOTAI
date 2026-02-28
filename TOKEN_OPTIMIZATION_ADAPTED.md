# OpenClaw Token Optimization Guide — Adapted for Kimi + OpenRouter + Ollama

**Goal:** Reduce AI costs by optimizing for OpenRouter models and local Ollama heartbeat

**Stack:** Kimi K2.5 (primary via OpenRouter) + Ollama (local heartbeat)

---

## Part 1: Session Initialization (ALREADY IMPLEMENTED ✅)

**What's Working:**
- Memory flush before compaction: ENABLED
- Session memory search: ENABLED (sources: memory + sessions)
- This gives us similar benefits to the guide's recommendations

**Your Current Setup:**
```json
{
  "agents": {
    "defaults": {
      "compaction": {
        "memoryFlush": { "enabled": true }
      },
      "memorySearch": {
        "sources": ["memory", "sessions"],
        "experimental": { "sessionMemory": true }
      }
    }
  }
}
```

**How It Works:**
- Before compaction, memory is flushed to files (preserves context)
- Session transcripts are searchable (don't need to load full history)
- Only essential files load at startup

**Result:** Reduced context loading without manual file management

---

## Part 2: Model Routing for OpenRouter

**The Kimi K2.5 Advantage:**
- Kimi K2.5 is already cost-effective via OpenRouter
- It's your default model: `openrouter/moonshotai/kimi-k2.5`
- Good balance of capability and price

**Recommended Setup:**

Add to `~/.openclaw/openclaw.json`:
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "openrouter/moonshotai/kimi-k2.5",
        "fallbacks": ["openrouter/auto"]
      },
      "models": {
        "openrouter/moonshotai/kimi-k2.5": {
          "alias": "kimi"
        },
        "openrouter/anthropic/claude-sonnet-4.5": {
          "alias": "sonnet"
        },
        "openrouter/meta-llama/llama-4-maverick": {
          "alias": "llama"
        }
      }
    }
  }
}
```

**Model Selection Rules (Add to SOUL.md):**
```markdown
## Model Selection
Default: Kimi K2.5 (via OpenRouter)

Switch to Sonnet ONLY when:
- Complex reasoning requiring step-by-step analysis
- Security-sensitive code review
- Architecture decisions with trade-offs
- Debugging complex multi-file issues

Switch to Llama-4-Maverick when:
- Long context needed (128K+ tokens)
- Cost-sensitive batch processing
- Testing/trial runs

When in doubt: Try Kimi first. It's fast and capable for most tasks.
```

**Why This Works:**
- Kimi K2.5: ~$0.50-2/M tokens (cheap, fast, capable)
- Claude Sonnet: ~$3-15/M tokens (expensive, best reasoning)
- Llama-4: ~$0.20-1/M tokens (cheapest, good for drafts)

---

## Part 3: Heartbeat to Ollama (LOCAL LLM)

**The Cost Problem:**
- Heartbeats every 30-60 minutes = 24-48 API calls/day
- At ~500-1000 tokens per heartbeat = 12K-48K tokens/day
- Kimi cost: ~$0.02-0.10/day = $0.60-3/month
- Sonnet cost: ~$0.05-0.20/day = $1.50-6/month

**The Solution: Free Local Heartbeats**

### Step 1: Install Ollama
```bash
# macOS/Linux
curl -fsSL https://ollama.ai/install.sh | sh

# Or download from: https://ollama.ai
```

### Step 2: Pull a Lightweight Model
```bash
# Option A: Tiny but capable (recommended for heartbeats)
ollama pull llama3.2:3b

# Option B: Even smaller/faster
ollama pull llama3.2:1b

# Option C: Best quality (but slower)
ollama pull qwen2.5:7b
```

**Recommendation:** `llama3.2:3b` — 2GB, fast, handles context well

### Step 3: Configure OpenClaw for Ollama Heartbeat

Add to `~/.openclaw/openclaw.json`:
```json
{
  "agents": {
    "defaults": {
      "heartbeat": {
        "every": "30m",
        "model": "ollama/llama3.2:3b",
        "session": "main",
        "prompt": "Check: Any tasks on the Kanban board? Calendar events coming up? Blockers or updates needed?"
      }
    }
  }
}
```

**Important:** You need Ollama running:
```bash
# Start Ollama server
ollama serve

# In another terminal, test it:
ollama run llama3.2:3b "Say OK if you can hear me"
```

### Step 4: Update HEARTBEAT.md for Ollama

Your `HEARTBEAT.md` should work with the local model:
```markdown
# HEARTBEAT.md

## Every 30 Minutes (via Ollama - FREE)
1. Check Kanban board for new tasks
2. Review calendar for upcoming events (next 24h)
3. Look for unread emails/messages
4. Check Moltbook notifications
5. Report: "Heartbeat OK" or list any actions taken
```

**Results:**
- Before: $0.60-6/month for heartbeats
- After: $0/month (local compute only)

---

## Part 4: Rate Limits & Budgets

**Add to SOUL.md:**
```markdown
## Rate Limits & Budgets
- 5 seconds minimum between API calls
- 10 seconds between web searches  
- Max 3 searches per batch, then 2-minute break
- Batch similar tasks together (one request for 10 items, not 10 requests)
- If you hit rate limit: STOP, wait 5 minutes, retry with smaller request

## Daily Budget
- Target: Under $1/day for routine work
- Warning at: $2/day
- Stop and ask permission at: $5/day

## Monthly Budget
- Target: Under $30/month
- Warning at: $50/month
- Stop and ask permission at: $100/month
```

**Why These Limits:**
- Prevents runaway loops
- Forces batching (more efficient)
- Keeps costs predictable
- OpenRouter has its own rate limits anyway

---

## Part 5: Prompt Caching (LIMITED SUPPORT)

**Reality Check:**
- Prompt caching works best with **Claude 3.5+ on Anthropic's API**
- **OpenRouter caching** is supported but varies by model
- **Kimi K2.5** may not support caching the same way
- **Benefit:** 90% discount on repeated context

**Current Status:**
- OpenClaw handles caching automatically when available
- Don't rely on it for Kimi via OpenRouter
- Focus on other optimizations instead

**If You Want to Try Caching:**
```json
{
  "agents": {
    "defaults": {
      "contextPruning": {
        "mode": "cache-ttl",
        "ttl": "5m"
      }
    }
  }
}
```

But expect minimal savings with Kimi — focus on session init and Ollama instead.

---

## Part 6: Optimized Workspace Files

### SOUL.md (Minimal)
```markdown
# SOUL.md

## Core Identity
- Name: Clara
- Emoji: ✨
- Vibe: Casual, upbeat, proactive

## How to Operate
- Check Kanban board during heartbeat for tasks
- Use Kimi K2.5 for most work (default)
- Use Sonnet only for complex reasoning/debugging
- Heartbeat runs via Ollama (local, free)
- Batch similar tasks together

## Model Selection
Default: Kimi K2.5
Use Sonnet for: architecture, security, complex debugging
Use Llama-4 for: drafts, tests, long context

## Rate Limits
5s between calls, 10s between searches
Max 3 searches/batch, then 2min break
```

### USER.md (Essential Only)
```markdown
# USER.md

- **Name:** Jade Gaul
- **Pronouns:** she/her
- **Timezone:** America/Los_Angeles
- **Working Style:** Casual, upbeat, appreciates proactive suggestions

## Quick Context
- Uses Kanban board for task management
- Active on Moltbook (agent social network)
- Prefers batching work over constant messaging
```

### AGENTS.md (Workspace Rules)
```markdown
# AGENTS.md

## Cost Optimization
1. Heartbeat uses Ollama (free local LLM)
2. Kimi K2.5 is default model
3. Check Kanban board before asking for tasks
4. Batch similar requests

## Memory Strategy
- Daily notes in memory/YYYY-MM-DD.md
- Long-term in MEMORY.md
- Session search enabled for both
```

**Key Principle:** Every line costs tokens. Keep it lean.

---

## Part 7: Quick Reference — Your Stack

### Models (via OpenRouter)
| Model | Use Case | Cost |
|-------|----------|------|
| **Kimi K2.5** (default) | Most tasks | ~$0.5-2/M tokens |
| **Claude Sonnet** | Complex reasoning | ~$3-15/M tokens |
| **Llama-4-Maverick** | Long context, drafts | ~$0.2-1/M tokens |

### Local Setup (Ollama)
| Model | Size | Use |
|-------|------|-----|
| **llama3.2:3b** | 2GB | Heartbeat (recommended) |
| **llama3.2:1b** | 1GB | Ultra-fast heartbeat |
| **qwen2.5:7b** | 4GB | Better quality (slower) |

### Cost Targets
| Metric | Before | After |
|--------|--------|-------|
| Daily | $2-5 | $0.50-1 |
| Monthly | $60-150 | $15-30 |
| Heartbeats | $1-6/mo | $0 |

---

## Implementation Checklist

- [ ] Install Ollama: `curl -fsSL https://ollama.ai/install.sh | sh`
- [ ] Pull heartbeat model: `ollama pull llama3.2:3b`
- [ ] Test Ollama: `ollama run llama3.2:3b "Say OK"`
- [ ] Update `openclaw.json` with heartbeat config
- [ ] Update SOUL.md with model selection rules
- [ ] Update USER.md (keep it minimal)
- [ ] Update HEARTBEAT.md for Ollama
- [ ] Restart gateway: `openclaw gateway restart`
- [ ] Test heartbeat: Check logs for Ollama calls
- [ ] Monitor costs for 1 week to verify savings

---

## Troubleshooting

**Ollama not responding:**
```bash
# Make sure it's running
ollama serve

# Test in another terminal
ollama run llama3.2:3b "test"
```

**Heartbeat still using API:**
- Check config syntax in `openclaw.json`
- Verify model string: `"ollama/llama3.2:3b"`
- Restart gateway after config changes

**Costs not dropping:**
- Check `session_status` to see current model
- Verify SOUL.md is being loaded
- Look for rate limit violations (may indicate runaway loops)

---

## The Bottom Line

**For Your Stack (Kimi + OpenRouter + Ollama):**

1. ✅ Session init: DONE (memory flush + session search)
2. 🔄 Model routing: Configure fallbacks in config
3. 🔄 Ollama heartbeat: Install + configure (saves $1-6/mo)
4. ✅ Rate limits: Add to SOUL.md
5. ⚠️ Prompt caching: Limited support, don't rely on it
6. 🔄 Workspace files: Keep SOUL.md + USER.md minimal

**Expected Savings:**
- Before: $60-150/month
- After: $15-30/month (75-80% reduction)
- Main drivers: Ollama heartbeat + Kimi default + batching

**Questions?**
- Check `session_status` to verify your setup
- Monitor OpenRouter dashboard for actual spend
- Adjust rate limits based on your actual usage patterns
