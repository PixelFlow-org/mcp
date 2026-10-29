---
name: audit-tracking
description: Audit an existing PixelFlow site. Use when the user asks why purchases, leads, or ad-platform numbers look wrong, or wants a health check before a campaign.
---

Call the audit_tracking prompt if this host lists it. Otherwise call get_site_status with the site_id and read its last_events for each conversion event (is_seen, is_sent), then call verify_tracking once, then list_triggers, get_blocked_events, and suggest_triggers. For a click or submit trigger whose event has not arrived, name the event and its page and ask the user to test it once, then read list_events. If the event still does not arrive, call get_connect_link with target visual_tagger for that event and page, so the user picks the element again.

Report findings in revenue order, each with its fix: purchases missing or without a value, a missing script, an expired ad platform token, a native ad platform pixel that still loads, a selector that no longer matches, blocked events, and goal steps with no source.

Do not ask for a token. To reconnect an ad platform, call get_connect_link with target ad_platform and that ad_platform. The link opens in Chrome, Safari, or Firefox, not in this chat.
