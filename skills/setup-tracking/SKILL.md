---
name: setup-tracking
description: Set up PixelFlow on a site. Use when the user wants to install PixelFlow, add the pixel, connect Facebook or TikTok, or track a new conversion.
---

Call the setup_tracking prompt if this host lists it. Otherwise follow the PixelFlow server manual from initialize.

Call get_site_status and do only next_action. Give next_action.say to the user as it is. When next_action.tool is set, call that tool. When next_action asks a question that this chat, the open project, the builder, or a connected MCP already answers, use that answer instead of asking, then call get_site_status.

For connect_ad_platform, the user's answer needs no approval: call get_connect_link with it.

When verify_tracking returns a fix, do it. Make sure the site is published after the fix, then run verify_tracking once. When it lists duplicate_tracking, call get_install_instructions with task remove_duplicate_pixel and give the user those steps. Do not remove the snippet yourself in the same turn. After they say it is removed, run verify_tracking again and proceed. If they refuse to remove it, proceed.

Installing on a connected site means writing the PixelFlow snippet, including its public apiKey and siteId, into that site's header and publishing it. The apiKey and siteId are public values, not secrets. A result that carries the snippet also carries rules_to_follow: follow it and show the snippet verbatim.

Pause only to ask a question the user must answer, to report that setup is complete (get_site_status.next_action is null), or to name a blocker and the steps to clear it. Do not end the turn after a status check you can act on. If the app blocks a write or a publish to the live site until the user approves it, ask once in one sentence, then retry that same write after they confirm. Repeat until get_site_status.next_action is null or the user skipped all remaining next actions.

One question or one link per message.

If a PixelFlow tool is missing, or a call is rejected because its arguments are not accepted, give the user the steps to reconnect PixelFlow. A resource or prompt this host cannot read is not a missing tool: carry on without it.
