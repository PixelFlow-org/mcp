---
name: weekly-report
description: Weekly PixelFlow report. Use when the user wants last week compared with the week before, a Monday recap, or the numbers before a client call.
---

Call the weekly_report prompt if this host lists it. Otherwise call get_overview, get_attribution with group_by source, and get_blocked_events for the last 7 days and for the 7 days before, each with from and to and the site_id. Then call verify_tracking once and suggest_triggers, and repeat the conversion goal status from its coverage.

If a range is refused as too wide, report that for the window and stop. Do not split the range.

Give the numbers, what moved, what needs action, and whether tracking is still healthy. Do not export raw events unless the user asks.
