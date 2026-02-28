#!/usr/bin/env python3
"""
Process today's Google Alerts for Transgender news and send Telegram message.
"""

from datetime import datetime
import json

# Today's date
today = "Friday, February 27th, 2026"

# Parse the alert items from the email
alerts_data = {
    "date": "2026-02-27",
    "alerts": [
        {
            "title": "Transgender Kansans had their IDs invalidated overnight, causing confusion and panic",
            "source": "KCUR",
            "summary": "Matthew Neumann, a transgender man in Larned who runs an LGBTQ+ mutual aid organization, describes the immediate impact of Kansas's new law invalidating IDs.",
            "url": "https://www.kcur.org/politics-elections-and-government/2026-02-26/kansas-transgender-id-invalid-drivers-license-bathroom-law"
        },
        {
            "title": "Kansas revokes driver's licenses from trans residents in latest assault on rights",
            "source": "The Guardian",
            "summary": "Law demanding IDs match 'sex at birth' also includes bathroom ban provision for trans people in public buildings.",
            "url": "https://www.theguardian.com/us-news/2026/feb/26/kansas-trans-drivers-license-law-assault-on-rights"
        },
        {
            "title": "Kansas invalidates driver's licenses, birth certificates of over 1000 transgender residents",
            "source": "Reuters",
            "summary": "A new Kansas law takes effect, invalidating driver's licenses and birth certificates for over 1,000 transgender residents.",
            "url": "https://www.reuters.com/legal/government/kansas-invalidates-drivers-licenses-birth-certificates-over-1000-transgender-2026-02-26/"
        },
        {
            "title": "Kansas invalidates more than 1,000 transgender residents' driver's licenses, birth certificates",
            "source": "The Hill",
            "summary": "Kansas law takes effect impacting over 1,000 people. Affects driver's licenses and birth certificates for transgender residents.",
            "url": "https://thehill.com/homenews/state-watch/5757544-kansas-transgender-law-legislation/"
        },
        {
            "title": "NWLC Reacts to EEOC's Latest Move to Attack Transgender Workers' Rights",
            "source": "National Women's Law Center",
            "summary": "The National Women's Law Center responds to EEOC actions affecting transgender workers' rights to access bathrooms.",
            "url": "https://nwlc.org/press-release/nwlc-reacts-to-eeocs-latest-move-to-attack-transgender-workers-rights/"
        },
        {
            "title": "Missouri House passes bill to make transgender athlete ban permanent",
            "source": "Missouri Independent",
            "summary": "Legislation passes to permanently ban transgender athletes from women's sports in Missouri.",
            "url": "https://missouriindependent.com/2026/02/26/bill-to-make-transgender-athlete-ban-permanent-passes-missouri-house/"
        }
    ],
    "summary": "Major news today focuses on Kansas's first-of-its-kind law that invalidates gender marker changes on drivers' licenses and birth certificates for over 1,000 transgender residents. The law also includes bathroom restrictions. Additionally, Missouri passed legislation to make its transgender athlete ban permanent."
}

# Save to JSON files
with open("/home/jeremygaul/.openclaw/workspace/data/google_alerts_2026-02-27.json", "w") as f:
    json.dump(alerts_data, f, indent=2)

# Create Telegram message
telegram_message = f"""📰 **Daily Google Alerts Summary** - {today}

• **Kansas law invalidates IDs overnight** — Over 1,000 transgender Kansans had their driver's licenses and birth certificates invalidated by a new law. The law also includes bathroom restrictions in public buildings.
(KCUR, The Guardian, Reuters)

• **National response** — The law is the first of its kind in the U.S. to revoke previously-issued gender marker changes. The National Women's Law Center also responded to EEOC moves affecting transgender workers' rights.

• **Missouri passes permanent sports ban** — A bill making the transgender athlete ban permanent passed the Missouri House.

_Source: Google Alerts (Transgender News)_

Check the Intel tab in Mission Control for full details."""

# Save the Telegram message
with open("/home/jeremygaul/.openclaw/workspace/data/daily_alerts_message.txt", "w") as f:
    f.write(telegram_message)

print("✅ Alerts processed successfully!")
print(f"\n📊 Summary for {today}:")
print(f"   • Found {len(alerts_data['alerts'])} news items")
print(f"   • Key focus: Kansas ID invalidation affecting 1,000+ trans residents")
