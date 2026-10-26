---
name: audit-tracking
description: Audit an existing PixelFlow site. Use when the user asks why purchases, leads, or ad-platform numbers look wrong, or wants a health check before a campaign.
---

Call the audit_tracking prompt if this host lists it. Otherwise call get_site_status, then verify_tracking for each conversion event type except PageView, then list_triggers, get_blocked_events, and suggest_triggers. Report findings in revenue order. Do not ask for a token. Reconnect through get_connect_link.
