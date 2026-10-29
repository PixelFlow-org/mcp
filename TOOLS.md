# PixelFlow MCP tools

The server is https://api.pixelflow.so/mcp. This file is generated from the tool definitions the server advertises, in `tools/list` order, with the title, hints, description, arguments, and result fields of each tool. Do not edit it by hand: run `pnpm mcp:docs` in the API repository.

Every tool that works on one site takes site_id, the integer from list_sites. Reads run without the user's approval. Before a create, update, or delete, the agent shows the change and waits for the user's approval.

25 tools.

## `list_sites`

List sites. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

List the websites the signed-in user can access in PixelFlow: each site's site_id, domain, platform, currency, whether the user can edit it, and the workspace it belongs to with the user's role there. Plan, limits, and usage are in get_site_status. Use it to find the site_id for a website the user names, or to ask which site they mean when there are several.

### Arguments

None.

### Result

| Field | Type | Description |
| --- | --- | --- |
| `sites` | array of object | Every site the user can access, across all their workspaces. |
| `sites[].site_id` | integer | Site id. Every other tool takes it as site_id. |
| `sites[].external_id` | string | Public id of this site. For sites created from the PixelFlow app inside Webflow or Framer, this is that builder's site id; otherwise PixelFlow generated it. The PixelFlow snippet uses it as its site id. Output only. |
| `sites[].domain` | string or null | Website domain, such as example.com. null until saved (allowed on platforms with a PixelFlow plugin, such as WordPress). |
| `sites[].platform` | string or null | Platform the site runs on, such as webflow or wordpress. null until chosen. |
| `sites[].currency` | string or null | ISO 4217 currency for event values. |
| `sites[].can_edit` | boolean | Whether the user may run write tools on this site. |
| `sites[].workspace_id` | integer | Workspace that owns the site. create_site takes it as workspace_id. |
| `sites[].workspace_name` | string | Workspace name. |
| `sites[].workspace_role` | string, one of owner, admin, viewer | The user's role in that workspace. A viewer cannot run write tools. |

## `list_supported_values`

List supported values. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

List the names PixelFlow supports and other tools accept: the platforms a site can run on, the ad platforms events can be sent to, the integrations that report conversions, the supported events, and the traffic sources events are attributed to. Use it when the user asks whether PixelFlow supports a platform, ad platform, integration, event, or traffic source, or before passing one of these names to another tool.

### Arguments

None.

### Result

| Field | Type | Description |
| --- | --- | --- |
| `platforms` | array of string | Platforms a site can run on, such as webflow or wordpress. create_site and update_site take these in `platform`. other means custom code or a platform not in the list. |
| `ad_platforms` | array of string | Ad platforms PixelFlow sends events to, such as facebook or tiktok. get_connect_link takes these in `ad_platform`. |
| `integrations` | array of string | Integrations that report conversions to PixelFlow, such as stripe or calendly. get_connect_link takes these in `integration`. |
| `events` | array of string | Supported events, such as Purchase or Lead. Trigger tools take these in `event`, blocking rules in `target`, and report filters in `events`. |
| `sources` | array of string | Traffic source buckets PixelFlow assigns to events, such as facebook, google, organic, or direct. list_events and get_journeys take these in `sources`; get_attribution returns them as row keys and takes one in `source`. |

## `get_site_status`

Get site status. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

Get the setup and health state of one site: its settings (domain, platform, currency, ecommerce flags), whether the PixelFlow script or plugin is installed, connected pixels and integrations, blocking rules, consent mode, the last event received of each type, which Get Started checklist items are done, and the plan, limits, and usage of its workspace. It also returns the next setup step, until setup and the Get Started checklist are complete. Use it before any setup or troubleshooting step, or when the user asks about their plan or limits.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `site_id` | integer | Site id. |
| `domain` | string or null | Website domain. |
| `platform` | string or null | Platform the site runs on, such as webflow. |
| `currency` | string or null | ISO 4217 currency for event values. A site created without one holds USD until the user sets it; while setup is open, next_action still asks. |
| `is_webflow_ecommerce` | boolean | Whether the Webflow site uses Webflow eCommerce. |
| `is_woocommerce` | boolean | Whether the WordPress site uses WooCommerce. |
| `is_old_pixel_removed` | boolean | Whether the Get Started item "remove old pixel code" is done. |
| `is_meta_domain_approved` | boolean | Whether the Get Started item "verify the domain in Facebook Business Manager" is done. |
| `is_utm_snippet_added` | boolean | Whether the Get Started item "add UTM parameters to ads" is done. |
| `is_consent_banner_configured` | boolean | Whether the Get Started item "configure a consent banner" is done. |
| `script_or_plugin` | object | PixelFlow install on the site. |
| `script_or_plugin.is_seen` | boolean | Whether events from the script or plugin arrived in the last events_window_days. |
| `script_or_plugin.type` | string, one of script, plugin | Install method the site's platform uses. |
| `is_plugin_connected` | boolean | Whether the WordPress plugin has signed in to this site. type plugin alone does not mean this. A site that already sends events skips the plugin step without it. |
| `pixels` | array of object | Ad platform pixels connected to the site. |
| `pixels[].pixel_id` | integer | Pixel id. update_pixel and list_events take it. |
| `pixels[].name` | string | Pixel label. |
| `pixels[].ad_platform` | string | Ad platform the pixel belongs to, such as facebook. |
| `pixels[].is_active` | boolean | Whether events are being sent to this pixel. |
| `pixels[].token` | string, one of stored, connection, missing | Where the access token comes from. The token itself is never returned. missing: events cannot be sent. |
| `integrations` | array of object | Connected integrations. |
| `integrations[].type` | string | Integration name, such as stripe. |
| `integrations[].label` | string or null | Integration label. |
| `integrations[].event` | string or null | Event the integration sends, such as Purchase. |
| `blocking_rules` | array of object | Blocking rules saved on the site, one per target: `target`, `mode`, and `groups`, the shape save_blocking_rule takes. |
| `blocking_rules[].target` | string |  |
| `blocking_rules[].mode` | string, one of block, do_not_block |  |
| `blocking_rules[].groups` | array of object, may be omitted |  |
| `blocking_rules[].groups[].conditions` | array of object |  |
| `last_events` | array of object | The newest of each event received in the last events_window_days, such as one PageView and one Purchase. |
| `last_events[].event` | string | Event received, such as PageView. |
| `last_events[].at` | string (date-time) | When it arrived. |
| `last_events[].is_sent` | boolean | Whether it was delivered to the ad platforms. |
| `events_window_days` | integer | Days back script_or_plugin.is_seen and last_events look. |
| `consent_mode` | string, one of enabled, disabled | enabled: PixelFlow honors visitor consent before sending. |
| `workspace` | object | Workspace that owns this site, with its plan, limits, and usage. |
| `workspace.workspace_id` | integer | Workspace id. |
| `workspace.workspace_name` | string | Workspace name. |
| `workspace.plan` | string | Plan name, such as Standard. `trial` during a free trial without a plan, `none` once that trial has ended. |
| `workspace.plan_status` | string, one of active, canceled, incomplete, incomplete_expired, past_due, paused, trialing, unpaid, expired, none | Billing state. expired: the free trial ended without a plan. none: no plan and no trial. |
| `workspace.trial_days_left` | integer or null | Whole days until the trial ends. 0: ended. null: no trial. |
| `workspace.limits` | object |  |
| `workspace.limits.sites` | integer | Sites the workspace may have, including purchased extra sites. |
| `workspace.limits.events_per_month` | integer or null | Events per month the plan includes, such as 500000. null means unlimited. |
| `workspace.limits.ad_platform_slots` | integer | Ad platform connections allowed, including purchased extras. |
| `workspace.limits.analytics_lookback_days` | integer | How far back get_overview, get_attribution, and get_blocked_events can read. |
| `workspace.limits.journeys_lookback_days` | integer | How far back get_journeys can read. |
| `workspace.limits.member_seats` | integer | Team members allowed, not counting the owner. 0 on a free trial. |
| `workspace.usage` | object |  |
| `workspace.usage.sites` | integer | Sites in the workspace, including ones this user cannot open. |
| `workspace.usage.ad_platform_slots` | integer | Ad platform slots in use. |
| `workspace.usage.member_seats` | integer | Seats in use, not counting the owner. |
| `duplicate_tracking` | array of object | Native ad platform pixel loaders seen on the last page check: `ad_platform` (string) and `evidence` (string, the script URL seen). |
| `duplicate_tracking[].ad_platform` | string |  |
| `duplicate_tracking[].evidence` | string |  |
| `docs` | array of object | Help articles for this result: `title` (string) and `url` (string, uri). |
| `docs[].title` | string |  |
| `docs[].url` | string (uri) |  |
| `next_action` | object or null | The one open setup step. null once setup and every Get Started item that applies to this site are complete. |
| `next_action.action` | string, one of ask_platform, wordpress_connect, ask_domain, ask_currency, connect_ad_platform, install, verify, triggers, get_started | Step to do now. |
| `next_action.say` | string | Suggested wording for the user. Words for the user only; the tool for this step is in next_action.tool. |
| `next_action.step` | integer | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.total` | integer | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.progress` | string | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.steps` | array of object | Every setup step: `step` (integer), `label` (string), `state` (enum: done, current, later). |
| `next_action.steps[].step` | integer |  |
| `next_action.steps[].label` | string |  |
| `next_action.steps[].state` | string, one of done, current, later |  |
| `next_action.tool` | string, may be omitted | Tool that performs this step. Absent when the step needs no tool or when install is attached. |
| `next_action.target` | string, one of ad_platform, may be omitted | get_connect_link target, for connect_ad_platform. |
| `next_action.ad_platform` | string, may be omitted | Ad platform to connect, for connect_ad_platform. Set only when a saved pixel cannot send yet; absent when the user still has to pick an ad platform. |
| `next_action.phase` | string, one of connect, activate, may be omitted | Plugin install phase, for install. |
| `next_action.task` | string, one of install, may be omitted | get_install_instructions task, for install. |
| `next_action.install` | object, may be omitted | For install: the steps and snippet for this site, the same as get_install_instructions returns for task install. When it is set, there is no tool. |
| `next_action.install.steps` | string or null | Numbered steps for this task on this platform. |
| `next_action.install.snippet` | string or null | HTML snippet with this site's public site id and key, to paste into the site. null on platforms with a PixelFlow plugin. |
| `next_action.install.rules_to_follow` | array of string or null | How to show the snippet to the user; follow them when you present it. null when the result has no snippet. |
| `next_action.install.native_pixel_search` | array of string or null | Phase activate only: text to search the site's code for to find an ad platform pixel already on the site. null otherwise. |
| `next_action.install.docs` | array of object | Help articles for this result: `title` (string) and `url` (string, uri). |
| `next_action.install.docs[].title` | string |  |
| `next_action.install.docs[].url` | string (uri) |  |

## `get_install_instructions`

Get install instructions. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

Get step-by-step instructions the user follows on their website or in their ad platform's ads manager, for one task: installing PixelFlow, adding UTM parameters to ad links, removing an ad platform's own pixel code (such as the Facebook pixel) that was added before PixelFlow and would count events twice, or removing PixelFlow. Steps are written for the site's platform, and install steps include this site's code snippet, ready to paste. Use it when the user is ready to install PixelFlow, or asks how to add UTM parameters, remove a duplicate pixel, or uninstall.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `task` | string, one of install, add_utm, remove_duplicate_pixel, uninstall | yes | What the instructions are for. install: add PixelFlow to the site. add_utm: add UTM parameters to ad links so conversions are attributed to campaigns. remove_duplicate_pixel: find and remove an ad platform pixel already on the site. uninstall: remove PixelFlow from the site. |
| `other_platform` | string | no | Platform the site runs on when its saved platform is other, such as kajabi, hubspot, or html. Omit for the generic steps. An unknown name is refused with the supported list. Refused when the saved platform is not other. |
| `phase` | string, one of connect, activate | no | install on platforms with a PixelFlow plugin only. connect (default): install the plugin and sign in. activate: the remaining steps after an ad platform is connected. Ignored on other platforms. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `task` | string, one of install, add_utm, remove_duplicate_pixel, uninstall | The task the instructions are for. |
| `instruction` | string | One-sentence summary of what to do. |
| `platform` | string or null | Platform the steps are written for, such as webflow. |
| `other_platform` | string or null | Platform the steps are written for when the saved platform is other, such as kajabi. null when it was not passed or the saved platform is not other. |
| `supported_other_platforms` | array of string or null | Platforms with their own steps when the saved platform is other, such as kajabi or html. Pass one as `other_platform`. null when the saved platform is not other. |
| `steps` | string or null | Numbered steps for this task on this platform. |
| `snippet` | string or null | HTML snippet with this site's public site id and key, to paste into the site. null on platforms with a PixelFlow plugin and for tasks other than install. |
| `rules_to_follow` | array of string or null | How to show the snippet to the user; follow them when you present it. null when the result has no snippet. |
| `utm_templates` | array of object or null | add_utm only: one UTM template per ad platform, to paste into the ad's URL parameters: `ad_platform` (string) and `template` (string). |
| `utm_templates[].ad_platform` | string |  |
| `utm_templates[].template` | string |  |
| `native_pixel_search` | array of string or null | remove_duplicate_pixel, and install with phase activate: text to search the site's code for to find an ad platform pixel already on the site. |
| `docs` | array of object | Help articles for this result: `title` (string) and `url` (string, uri). |
| `docs[].title` | string |  |
| `docs[].url` | string (uri) |  |

## `verify_tracking`

Verify tracking. Loads the customer's site. readOnlyHint false, destructiveHint false, idempotentHint false, openWorldHint true

Check that tracking works on one site by loading one of its pages in a headless browser and reading the events received since checked_from. Returns whether tracking works, the first failing step with its cause and fix, whether the page could be loaded, and any ad platform pixel added to the site outside PixelFlow that double counts events. A passing check marks site setup as complete. The result includes next_action, the same as get_site_status. Refused until an ad platform is connected. Rate limited per site. Use it after installing PixelFlow, after connecting a pixel, or when the user reports missing events.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `url` | string | no | Published page on this site's domain to load, such as https://example.com/pricing. Default the home page. Preview and staging hosts are refused. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `site_id` | integer | Site id. |
| `domain` | string or null | Website domain. |
| `is_successful` | boolean | Whether tracking works end to end: an event from the site was received and accepted since checked_from. |
| `checked_from` | string (date-time) | Start of the recent period whose events the check reads. |
| `failed_step` | string or null, one of script_missing, script_error, pixel_missing, token_unusable, consent_blocked, no_event_received | First step that failed. script_missing: the PixelFlow script is not on the page. script_error: the script loaded but failed to run. pixel_missing: no ad platform pixel is connected. token_unusable: the ad platform rejected the pixel's access token. consent_blocked: events were blocked because visitors did not give consent. no_event_received: the script is on the page but no event has been received yet. null on success, or when the page could not be loaded and no recent events exist. |
| `cause` | string or null | Why that step failed, in plain words. |
| `fix` | string or null | What to change to pass that step. |
| `page_check` | object | Whether the headless browser could load and inspect the page. When status is not passed, the result relies only on events received since checked_from; with none, is_successful is false and failed_step is null. |
| `page_check.status` | string, one of passed, blocked, inconclusive | passed: the page loaded and was inspected. blocked: the site stopped the browser (bot challenge, password, geo restriction, or a consent banner it could not get past). inconclusive: the page did not finish loading. |
| `page_check.cause` | string or null | Why the page could not be loaded. null when status is passed. |
| `duplicate_tracking` | array of object | Ad platform pixels added to the site outside PixelFlow, seen on this page load: `ad_platform` (string, such as facebook) and `evidence` (string, the script URL seen). Each one double counts events, because PixelFlow already sends both the browser pixel and the Conversions API for that ad platform. |
| `duplicate_tracking[].ad_platform` | string |  |
| `duplicate_tracking[].evidence` | string |  |
| `setup_completed` | boolean | Whether site setup is now marked complete. |
| `has_conversion_event` | boolean | Whether an event other than PageView arrived since checked_from. |
| `docs` | array of object | Help articles for this result: `title` (string) and `url` (string, uri). |
| `docs[].title` | string |  |
| `docs[].url` | string (uri) |  |
| `next_action` | object or null | The one open setup step. null once setup and every Get Started item that applies to this site are complete. |
| `next_action.action` | string, one of ask_platform, wordpress_connect, ask_domain, ask_currency, connect_ad_platform, install, verify, triggers, get_started | Step to do now. |
| `next_action.say` | string | Suggested wording for the user. Words for the user only; the tool for this step is in next_action.tool. |
| `next_action.step` | integer | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.total` | integer | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.progress` | string | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.steps` | array of object | Every setup step: `step` (integer), `label` (string), `state` (enum: done, current, later). |
| `next_action.steps[].step` | integer |  |
| `next_action.steps[].label` | string |  |
| `next_action.steps[].state` | string, one of done, current, later |  |
| `next_action.tool` | string, may be omitted | Tool that performs this step. Absent when the step needs no tool or when install is attached. |
| `next_action.target` | string, one of ad_platform, may be omitted | get_connect_link target, for connect_ad_platform. |
| `next_action.ad_platform` | string, may be omitted | Ad platform to connect, for connect_ad_platform. Set only when a saved pixel cannot send yet; absent when the user still has to pick an ad platform. |
| `next_action.phase` | string, one of connect, activate, may be omitted | Plugin install phase, for install. |
| `next_action.task` | string, one of install, may be omitted | get_install_instructions task, for install. |
| `next_action.install` | object, may be omitted | For install: the steps and snippet for this site, the same as get_install_instructions returns for task install. When it is set, there is no tool. |
| `next_action.install.steps` | string or null | Numbered steps for this task on this platform. |
| `next_action.install.snippet` | string or null | HTML snippet with this site's public site id and key, to paste into the site. null on platforms with a PixelFlow plugin. |
| `next_action.install.rules_to_follow` | array of string or null | How to show the snippet to the user; follow them when you present it. null when the result has no snippet. |
| `next_action.install.native_pixel_search` | array of string or null | Phase activate only: text to search the site's code for to find an ad platform pixel already on the site. null otherwise. |
| `next_action.install.docs` | array of object | Help articles for this result: `title` (string) and `url` (string, uri). |
| `next_action.install.docs[].title` | string |  |
| `next_action.install.docs[].url` | string (uri) |  |

## `get_connect_link`

Get dashboard link. Edits. readOnlyHint false, destructiveHint false, idempotentHint false, openWorldHint false

Create a one-time link to the PixelFlow dashboard page for a step that needs a browser sign-in or a secret. Returns the link and when it expires. The link holds only an opaque id and works only for this user when signed in, so no credential passes through the chat. It must be opened in a regular browser such as Chrome, Safari, or Firefox. Integration and Visual Tagger targets are refused until site setup has passed verify. Use it when connecting an ad platform pixel (such as Facebook or TikTok), connecting an integration (such as Stripe or Calendly), opening billing, or opening the Visual Tagger on a page of the site. A Visual Tagger link saves the trigger itself when the user confirms, so read list_triggers afterwards instead of calling create_trigger.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `target` | string, one of ad_platform, integration, billing, visual_tagger | yes | Dashboard page to open. ad_platform: connect or reconnect a pixel. integration: connect an integration. billing: change the plan. visual_tagger: pick an element on page_path to track. |
| `ad_platform` | string | no | Ad platform to connect, such as facebook or tiktok. Names are in list_supported_values's `ad_platforms`. |
| `integration` | string | no | Integration to connect, such as stripe or calendly. Names are in list_supported_values's `integrations`. |
| `page_path` | string | no | Path on this site, such as /thank-you. Any query string is dropped. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `url` | string (uri) | One-time dashboard link. |
| `target` | string, one of ad_platform, integration, billing, visual_tagger | Dashboard page the link opens. |
| `ad_platform` | string, may be omitted | ad_platform only: ad platform the link connects, such as facebook. |
| `integration` | string, may be omitted | integration only: integration the link connects, such as stripe. |
| `site_id` | integer | Site id. |
| `expires_at` | string (date-time) | When the link stops working. |
| `page_path` | string, may be omitted | visual_tagger only: page the Visual Tagger opens. |

## `update_pixel`

Update pixel. Edits. readOnlyHint false, destructiveHint true, idempotentHint true, openWorldHint false

Change the label or the test event code of a connected ad platform pixel. Returns the pixel's label and test event code after the change. A test event code sends events to the ad platform's test events view, for debugging. An empty test event code turns test mode off. Test mode also turns off by itself at test_mode_ends_at. Fields left out stay unchanged. The pixel id and access token can only be changed in the dashboard. Use it when the user wants to rename a pixel or check events in the ad platform's test view.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `pixel_id` | integer | yes | Pixel id as returned by get_site_status (`pixels[].pixel_id`). |
| `label` | string, up to 255 characters | no | Display name for the pixel. |
| `test_event_code` | string, up to 255 characters | no | Test event code from the ad platform's events manager, such as TEST12345. Empty string clears it. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `pixel_id` | integer | Pixel id. |
| `label` | string | Pixel label after the change. |
| `test_event_code` | string or null | Test event code after the change. null: test mode is off. |
| `test_mode_ends_at` | string (date-time) or null | When test mode turns off by itself and the test event code is cleared. A new code sent while test mode is on keeps this time. null: test mode is off. |

## `update_integration`

Update integration. Edits. readOnlyHint false, destructiveHint true, idempotentHint true, openWorldHint false

Change the settings of an integration connected to a site, such as Stripe or Calendly. Returns the saved settings. Every integration has a label and a fixed value sent with every event. Integrations that report payments also have a product list and a minimum payment amount. When they are set, events are sent only for those products and for payments of at least that amount. Fields left out stay unchanged. null clears a field. A setting the integration does not support is refused. Use it when the user wants to change which events an integration sends or the value sent with them.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `integration_id` | integer | yes | Integration id: the `trigger_id` of an integration row in list_triggers. |
| `label` | string or null, up to 255 characters | no | Display name. null clears it. |
| `fixed_value` | number or null, at least 0 | no | Value sent with every event from this integration, in the site's currency. null clears it, so each event carries the integration's own amount. |
| `product_ids` | array of string or null, up to 50 items | no | Integrations that report products only, such as Stripe. Events are sent only for payments of these product ids. null clears the filter, so events are sent for all products. |
| `minimum_purchase_value` | number or null, at least 0 | no | Integrations that report payment amounts only, such as Stripe. No event is sent for a payment below this amount. null removes the minimum. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `integration_id` | integer | Integration id. |
| `type` | string | Integration name, such as stripe. |
| `label` | string or null | Label after the change. |
| `fixed_value` | number or null | Fixed value sent with each event. null: the integration's own amount is used. |
| `product_ids` | array of string or null | Product ids events are sent for. null: events are sent for all products. |
| `minimum_purchase_value` | number or null | No event is sent for a payment below this amount. null: no minimum. |

## `disconnect_integration`

Disconnect integration. Deletes. readOnlyHint false, destructiveHint true, idempotentHint true, openWorldHint false

Disconnect an integration such as Stripe or Calendly from a site and return which one was removed. Its webhook is removed and its events stop being sent to ad platforms. Reconnecting is done from the dashboard. Use it when the user asks to stop sending conversions from that integration.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `integration_id` | integer | yes | Integration id: the `trigger_id` of an integration row in list_triggers. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `disconnected` | boolean | Whether the integration was removed. Always true on success. |
| `integration_id` | integer | Id of the removed integration. |
| `type` | string | Integration name, such as stripe. |

## `create_site`

Create site. Edits. readOnlyHint false, destructiveHint false, idempotentHint false, openWorldHint false

Add a new website to a PixelFlow workspace and return the saved site with its site_id. If the workspace is at its site limit or its plan is canceled, the site is not created and the error says why. The result includes next_action, the same as get_site_status. Use it when the user wants to track a website that list_sites does not show.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `platform` | string | yes | Platform the site runs on, a name from list_supported_values's `platforms`, such as webflow or wordpress. other for custom code or a platform not in the list. |
| `domain` | string | no | Website domain, such as example.com. Required except on platforms with a PixelFlow plugin, such as WordPress, where it can be added later with update_site. |
| `currency` | string, up to 3 characters | no | ISO 4217 currency for event values, such as EUR. Same requirement as domain. |
| `is_webflow_ecommerce` | boolean | no | Whether the Webflow site uses Webflow eCommerce. When true and the site has a domain, PixelFlow adds the standard Webflow eCommerce triggers, returned in triggers_added. |
| `is_woocommerce` | boolean | no | Whether the WordPress site uses WooCommerce. |
| `workspace_id` | integer | no | Workspace to add the site to, `workspace_id` from list_sites. Required only when the user belongs to more than one workspace. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `site_id` | integer | Site id. |
| `external_id` | string | Public site id, as in list_sites. |
| `workspace_id` | integer | Workspace that owns the site. |
| `domain` | string or null | Website domain. |
| `platform` | string or null | Platform the site runs on, such as webflow. |
| `currency` | string or null | ISO 4217 currency for event values. |
| `is_webflow_ecommerce` | boolean | Whether the Webflow site uses Webflow eCommerce. |
| `is_woocommerce` | boolean | Whether the WordPress site uses WooCommerce. |
| `is_setup_via_ai` | boolean | Whether the site was set up through an AI assistant. |
| `is_old_pixel_removed` | boolean | Whether the Get Started item "remove old pixel code" is done. |
| `is_meta_domain_approved` | boolean | Whether the Get Started item "verify the domain in Facebook Business Manager" is done. |
| `is_utm_snippet_added` | boolean | Whether the Get Started item "add UTM parameters to ads" is done. |
| `is_consent_banner_configured` | boolean | Whether the Get Started item "configure a consent banner" is done. |
| `triggers_added` | array of object | Webflow eCommerce triggers this call added: `trigger_id` (integer), `type` (url), `event` (string, such as Purchase), and `url` (string). Empty when none were added, including when they already exist. |
| `triggers_added[].trigger_id` | integer |  |
| `triggers_added[].type` | string, one of url |  |
| `triggers_added[].event` | string |  |
| `triggers_added[].url` | string |  |
| `next_action` | object or null | The one open setup step. null once setup and every Get Started item that applies to this site are complete. |
| `next_action.action` | string, one of ask_platform, wordpress_connect, ask_domain, ask_currency, connect_ad_platform, install, verify, triggers, get_started | Step to do now. |
| `next_action.say` | string | Suggested wording for the user. Words for the user only; the tool for this step is in next_action.tool. |
| `next_action.step` | integer | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.total` | integer | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.progress` | string | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.steps` | array of object | Every setup step: `step` (integer), `label` (string), `state` (enum: done, current, later). |
| `next_action.steps[].step` | integer |  |
| `next_action.steps[].label` | string |  |
| `next_action.steps[].state` | string, one of done, current, later |  |
| `next_action.tool` | string, may be omitted | Tool that performs this step. Absent when the step needs no tool or when install is attached. |
| `next_action.target` | string, one of ad_platform, may be omitted | get_connect_link target, for connect_ad_platform. |
| `next_action.ad_platform` | string, may be omitted | Ad platform to connect, for connect_ad_platform. Set only when a saved pixel cannot send yet; absent when the user still has to pick an ad platform. |
| `next_action.phase` | string, one of connect, activate, may be omitted | Plugin install phase, for install. |
| `next_action.task` | string, one of install, may be omitted | get_install_instructions task, for install. |
| `next_action.install` | object, may be omitted | For install: the steps and snippet for this site, the same as get_install_instructions returns for task install. When it is set, there is no tool. |
| `next_action.install.steps` | string or null | Numbered steps for this task on this platform. |
| `next_action.install.snippet` | string or null | HTML snippet with this site's public site id and key, to paste into the site. null on platforms with a PixelFlow plugin. |
| `next_action.install.rules_to_follow` | array of string or null | How to show the snippet to the user; follow them when you present it. null when the result has no snippet. |
| `next_action.install.native_pixel_search` | array of string or null | Phase activate only: text to search the site's code for to find an ad platform pixel already on the site. null otherwise. |
| `next_action.install.docs` | array of object | Help articles for this result: `title` (string) and `url` (string, uri). |
| `next_action.install.docs[].title` | string |  |
| `next_action.install.docs[].url` | string (uri) |  |

## `update_site`

Update site. Edits. readOnlyHint false, destructiveHint true, idempotentHint true, openWorldHint false

Change settings on a site (domain, platform, currency, ecommerce flags, or Get Started checklist items) and return the saved site. Omitted fields stay unchanged; provided fields overwrite the stored value. The result includes next_action, the same as get_site_status. Use it when the user changes a site setting or confirms that a Get Started item is done.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `platform` | string | no | Platform the site runs on, a name from list_supported_values's `platforms`, such as webflow or wordpress. other for custom code or a platform not in the list. |
| `domain` | string | no | Website domain, such as example.com. |
| `currency` | string, up to 3 characters | no | ISO 4217 currency for event values, such as EUR. |
| `is_webflow_ecommerce` | boolean | no | Whether the Webflow site uses Webflow eCommerce. When true and the site has a domain, PixelFlow adds the standard Webflow eCommerce triggers, returned in triggers_added. |
| `is_woocommerce` | boolean | no | Whether the WordPress site uses WooCommerce. |
| `is_old_pixel_removed` | boolean | no | Whether the user confirmed the old ad platform pixel code is removed from the site (a Get Started item). |
| `is_meta_domain_approved` | boolean | no | Whether the user confirmed the domain is verified in Facebook Business Manager (a Get Started item). |
| `is_utm_snippet_added` | boolean | no | Whether the user confirmed UTM parameters are added to their ads (a Get Started item). |
| `is_consent_banner_configured` | boolean | no | Whether the user confirmed a consent banner is configured (a Get Started item). |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `site_id` | integer | Site id. |
| `external_id` | string | Public site id, as in list_sites. |
| `workspace_id` | integer | Workspace that owns the site. |
| `domain` | string or null | Website domain. |
| `platform` | string or null | Platform the site runs on, such as webflow. |
| `currency` | string or null | ISO 4217 currency for event values. |
| `is_webflow_ecommerce` | boolean | Whether the Webflow site uses Webflow eCommerce. |
| `is_woocommerce` | boolean | Whether the WordPress site uses WooCommerce. |
| `is_setup_via_ai` | boolean | Whether the site was set up through an AI assistant. |
| `is_old_pixel_removed` | boolean | Whether the Get Started item "remove old pixel code" is done. |
| `is_meta_domain_approved` | boolean | Whether the Get Started item "verify the domain in Facebook Business Manager" is done. |
| `is_utm_snippet_added` | boolean | Whether the Get Started item "add UTM parameters to ads" is done. |
| `is_consent_banner_configured` | boolean | Whether the Get Started item "configure a consent banner" is done. |
| `triggers_added` | array of object | Webflow eCommerce triggers this call added: `trigger_id` (integer), `type` (url), `event` (string, such as Purchase), and `url` (string). Empty when none were added, including when they already exist. |
| `triggers_added[].trigger_id` | integer |  |
| `triggers_added[].type` | string, one of url |  |
| `triggers_added[].event` | string |  |
| `triggers_added[].url` | string |  |
| `next_action` | object or null | The one open setup step. null once setup and every Get Started item that applies to this site are complete. |
| `next_action.action` | string, one of ask_platform, wordpress_connect, ask_domain, ask_currency, connect_ad_platform, install, verify, triggers, get_started | Step to do now. |
| `next_action.say` | string | Suggested wording for the user. Words for the user only; the tool for this step is in next_action.tool. |
| `next_action.step` | integer | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.total` | integer | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.progress` | string | Position in setup, such as Step 4 of 7. total depends on the site: plugin platforms add a step, and sites that set up conversions add another. |
| `next_action.steps` | array of object | Every setup step: `step` (integer), `label` (string), `state` (enum: done, current, later). |
| `next_action.steps[].step` | integer |  |
| `next_action.steps[].label` | string |  |
| `next_action.steps[].state` | string, one of done, current, later |  |
| `next_action.tool` | string, may be omitted | Tool that performs this step. Absent when the step needs no tool or when install is attached. |
| `next_action.target` | string, one of ad_platform, may be omitted | get_connect_link target, for connect_ad_platform. |
| `next_action.ad_platform` | string, may be omitted | Ad platform to connect, for connect_ad_platform. Set only when a saved pixel cannot send yet; absent when the user still has to pick an ad platform. |
| `next_action.phase` | string, one of connect, activate, may be omitted | Plugin install phase, for install. |
| `next_action.task` | string, one of install, may be omitted | get_install_instructions task, for install. |
| `next_action.install` | object, may be omitted | For install: the steps and snippet for this site, the same as get_install_instructions returns for task install. When it is set, there is no tool. |
| `next_action.install.steps` | string or null | Numbered steps for this task on this platform. |
| `next_action.install.snippet` | string or null | HTML snippet with this site's public site id and key, to paste into the site. null on platforms with a PixelFlow plugin. |
| `next_action.install.rules_to_follow` | array of string or null | How to show the snippet to the user; follow them when you present it. null when the result has no snippet. |
| `next_action.install.native_pixel_search` | array of string or null | Phase activate only: text to search the site's code for to find an ad platform pixel already on the site. null otherwise. |
| `next_action.install.docs` | array of object | Help articles for this result: `title` (string) and `url` (string, uri). |
| `next_action.install.docs[].title` | string |  |
| `next_action.install.docs[].url` | string (uri) |  |

## `get_overview`

Get tracking overview. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

Get tracking totals for one site over a date range: the count of each event, such as Purchase or Lead, revenue, events delivered and failed per pixel, events blocked by consent or bot detection, event counts per day or week, and, for the newest 500 conversions in the range, how many carried a hashed email or phone. Ranges before the plan's analytics lookback are refused, and a range too large to read at once is refused as range_too_wide with the largest range that fits. Use it for "how is tracking doing" and weekly report questions.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `from` | string | yes | Range start. YYYY-MM-DD means the start of that day in `timezone`; a full ISO 8601 timestamp is used as is. |
| `to` | string | yes | Range end. YYYY-MM-DD means the end of that day in `timezone`, so the whole day is included; a full ISO 8601 timestamp is used as is. |
| `timezone` | string | no | IANA time zone such as Europe/Berlin. Default UTC. Returned times and day buckets use it. |
| `group_by` | string, one of day, week | no | Series bucket. Default day. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `window` | object | Exact range read, after applying timezone. |
| `window.from` | string (date-time) | First instant included. |
| `window.to` | string (date-time) | Last instant included. |
| `timezone` | string | IANA time zone used for dates and buckets. UTC when none was passed. |
| `group_by` | string, one of day, week | Series bucket used. |
| `event_count` | integer | Events read to compute these numbers. |
| `event_counts` | map of integer | Count per event in the range, such as { "Purchase": 64, "Lead": 211 }. Events with no count are left out. |
| `revenue` | object | Revenue in the currency with the most valued events: `amount` (number), `currency` (string or null), `events` (integer, valued events summed). |
| `revenue.amount` | number | Revenue amount. |
| `revenue.currency` | string or null | Currency code. |
| `revenue.events` | integer | Valued events summed. |
| `revenue_by_currency` | array of object | Same fields, one row per currency. |
| `revenue_by_currency[].amount` | number | Revenue amount. |
| `revenue_by_currency[].currency` | string or null | Currency code. |
| `revenue_by_currency[].events` | integer | Valued events summed. |
| `delivered` | object | Events delivered to the ad platforms. |
| `delivered.count` | integer | Events delivered. |
| `failed` | object | Events that failed with an error. Events still sending are in neither count. |
| `failed.count` | integer | Events failed. |
| `pixels` | array of object | Per pixel: `pixel_id` (integer), `name` (string), `ad_platform` (string or null), `sent` (integer), `failed` (integer, not delivered). |
| `pixels[].pixel_id` | integer | Pixel id. |
| `pixels[].name` | string | Pixel name. |
| `pixels[].ad_platform` | string or null | Ad platform name. |
| `pixels[].sent` | integer | Events sent. |
| `pixels[].failed` | integer | Events not delivered. |
| `blocked` | object | Events not sent because of consent or bots: `total`, `bots_blocked`, `consent_events_blocked` (integers), `reasons` (object, reason to count: denied, no_decision, gpc, bot), and `event_counts` (object, event to count, such as { "Purchase": 9 }). For the individual blocked events, see get_blocked_events. |
| `blocked.total` | integer | All blocked events. |
| `blocked.bots_blocked` | integer | Blocked as bots. |
| `blocked.consent_events_blocked` | integer | Blocked by consent. |
| `blocked.reasons` | map of integer | Reason to count. |
| `blocked.event_counts` | map of integer | Event to count. |
| `field_presence` | object or null | Hashed email and phone on the newest conversions in the range. Only recent conversions are checked, from checked_from; null when the whole range is older or the sample could not be read in time. Every other field counts all events. |
| `field_presence.max_checked` | integer | Most conversions checked in one call. |
| `field_presence.checked` | integer | Conversions checked. Below max_checked means every conversion since checked_from was checked. |
| `field_presence.checked_from` | string (date-time) | Start of the period checked, which runs to window.to: window.from when every conversion was checked, otherwise the time of the oldest conversion checked. |
| `field_presence.events` | array of object | Per conversion event, such as Purchase (never PageView): `event`, `checked` (conversions of this event checked), `with_email`, `with_phone` (how many of those carried a hashed email or phone). |
| `field_presence.events[].event` | string | Event name. |
| `field_presence.events[].checked` | integer | Conversions checked. |
| `field_presence.events[].with_email` | integer | Carried a hashed email. |
| `field_presence.events[].with_phone` | integer | Carried a hashed phone. |
| `series` | array of object | Event counts per bucket: `bucket` (string, YYYY-MM-DD of the day or week start in timezone), `event`, `count`. |
| `series[].bucket` | string | Bucket start date. |
| `series[].event` | string | Event name. |
| `series[].count` | integer | Events in the bucket. |

## `get_attribution`

Get attribution. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

Get revenue and conversions for one site over a date range, broken down by traffic source, campaign, ad set, or ad, using PixelFlow's website attribution (the UTM tags and referrer of the converting visit). Each row has its event counts, revenue, unique visitors, and sessions. To drill down, pass the parent levels: campaign needs source; adset needs source and campaign; ad needs all three. Ranges before the plan's analytics lookback are refused, and a range too large to read at once is refused as range_too_wide with the largest range that fits. Use it for "which campaigns or ads drove conversions" questions.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `from` | string | yes | Range start. YYYY-MM-DD means the start of that day in `timezone`; a full ISO 8601 timestamp is used as is. |
| `to` | string | yes | Range end. YYYY-MM-DD means the end of that day in `timezone`, so the whole day is included; a full ISO 8601 timestamp is used as is. |
| `timezone` | string | no | IANA time zone such as Europe/Berlin. Default UTC. Returned times and day buckets use it. |
| `group_by` | string, one of source, campaign, adset, ad | no | Breakdown level. Default source. |
| `source` | string | no | Parent source key from a previous result, such as facebook. Names are in list_supported_values's `sources`; (not set) for a blank source. Required for campaign, adset, and ad. |
| `campaign` | string | no | Parent campaign key. Required for adset and ad. |
| `adset` | string | no | Parent ad set key. Required for ad. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `window` | object | Exact range read, after applying timezone. |
| `window.from` | string (date-time) | First instant included. |
| `window.to` | string (date-time) | Last instant included. |
| `timezone` | string | IANA time zone used for dates and times. UTC when none was passed. |
| `group_by` | string, one of source, campaign, adset, ad | Breakdown level used. |
| `event_count` | integer | Sum of total_events across rows. |
| `attributed_revenue` | object | Revenue in the site currency: `amount` (number), `currency` (string or null), `events` (integer). |
| `attributed_revenue.amount` | number | Revenue amount. |
| `attributed_revenue.currency` | string or null | Currency code. |
| `attributed_revenue.events` | integer | Valued events summed. |
| `excluded_valued_events` | integer | Valued conversions in another currency, left out of the revenue. |
| `revenue_tracked_since` | string (date-time) or null | Set when the range starts before PixelFlow began recording attribution revenue: revenue before this date is not counted. |
| `rows` | array of object | One row per source, campaign, ad set, or ad. |
| `rows[].key` | string | Source bucket, campaign, ad set, or ad name. (not set) for a blank tag. Pass it as the parent parameter to drill down. |
| `rows[].event_counts` | map of integer | Count per event on this row, such as { "Purchase": 29 }. |
| `rows[].total_events` | integer | All events on this row. |
| `rows[].revenue` | object or null | Revenue on this row, same fields as attributed_revenue. |
| `rows[].revenue.amount` | number | Revenue amount. |
| `rows[].revenue.currency` | string or null | Currency code. |
| `rows[].revenue.events` | integer | Valued events summed. |
| `rows[].visitors` | integer or null | Unique visitors on this row. null when the range is too large to read at once; ask for a shorter range. |
| `rows[].sessions` | integer or null | Sessions on this row. null when the range is too large to read at once; ask for a shorter range. |

## `get_journeys`

Get journeys. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

Get visitor journeys on one site, one row per visitor with an event in the date range. A journey covers that visitor's events in the lookback_days up to their last event in the range. Each row has the journey's value per currency, the count of each event, its last 50 events with their times, and the first and last touch credited (source and UTM tags). Events with no visitor id are their own rows. Ranges before the plan's journey lookback are refused. Use it when the user asks about customer, user, or conversion journeys: what visitors did on the site before they converted, and which first and last touch the conversion is credited to.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `from` | string | yes | Range start. YYYY-MM-DD means the start of that day in `timezone`; a full ISO 8601 timestamp is used as is. |
| `to` | string | yes | Range end. YYYY-MM-DD means the end of that day in `timezone`, so the whole day is included; a full ISO 8601 timestamp is used as is. |
| `timezone` | string | no | IANA time zone such as Europe/Berlin. Default UTC. Returned times and day buckets use it. |
| `events` | array of string, up to 50 items | no | Only journeys with at least one of these events, such as Purchase. Names are in list_supported_values's `events`. Default: the conversion events. Add PageView to include visitors who did not convert. |
| `sources` | array of string, up to 50 items | no | Only journeys with at least one event from these traffic source buckets, such as facebook, google, organic, or direct. Names are in list_supported_values's `sources`. (not set) matches a blank value. |
| `utm_campaign` | array of string, up to 50 items | no | Only journeys with at least one event carrying one of these UTM campaigns. (not set) matches a blank value. |
| `utm_term` | array of string, up to 50 items | no | Only journeys with at least one event carrying one of these UTM terms (usually the ad set). (not set) matches a blank value. |
| `utm_content` | array of string, up to 50 items | no | Only journeys with at least one event carrying one of these UTM contents (usually the ad). (not set) matches a blank value. |
| `visitor_id` | string | no | One visitor's journey, visitor_id from an earlier row or from list_events. |
| `sort` | string, one of most_recent, highest_value | no | most_recent: newest latest event first. highest_value: largest journey value first. Default most_recent. |
| `page` | integer, 1 to 10000 | no | Page to return. Default 1. |
| `limit` | integer, 1 to 50 | no | Journeys per page. Default 25. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `window` | object | Exact range read, after applying timezone. |
| `window.from` | string (date-time) | First instant included. |
| `window.to` | string (date-time) | Last instant included. |
| `timezone` | string | IANA time zone used for dates and times. UTC when none was passed. |
| `sort` | string, one of most_recent, highest_value | Sort used. |
| `lookback_days` | integer | Days before a visitor's last event that their journey covers. |
| `total` | integer | Journeys matching the filters, across all pages. |
| `next_page` | integer or null | Pass as page for the next page, with the same filters and sort. null: last page. |
| `journeys` | array of object | Journeys on this page, in the requested sort. |
| `journeys[].visitor_id` | string or null | Visitor this journey belongs to. null when the row is one event with no visitor id, so earlier visits could not be linked. |
| `journeys[].id` | integer or null | Row id of the single event on a row with no visitor id, as id in list_events; get_event_payloads takes it in ids. null on visitor rows. |
| `journeys[].started_at` | string (date-time) | Time of the first event in the journey, at most lookback_days before ended_at. |
| `journeys[].ended_at` | string (date-time) | Time of the visitor's latest event in the range. |
| `journeys[].event_counts` | map of integer | Count of each event in the journey, including the latest, by event name, such as `{ "PageView": 10, "Purchase": 2 }`. |
| `journeys[].touchpoints` | array of object | The journey's last 50 events, oldest first: `event` (string, such as PageView) and `time` (string, date-time, in timezone). |
| `journeys[].touchpoints[].event` | string | Event name. |
| `journeys[].touchpoints[].time` | string (date-time) | When the event arrived. |
| `journeys[].has_earlier_touchpoints` | boolean | true when the journey has more than 50 events, so earlier ones are not in touchpoints. event_counts still counts all of them. |
| `journeys[].values` | array of object | Value of the journey's conversions, summed per currency: `currency` (string or null), `amount` (number). Empty when none carried a value. |
| `journeys[].values[].currency` | string or null | Currency code. |
| `journeys[].values[].amount` | number | Summed value. |
| `journeys[].first_touch` | object or null | First visit credited, as stored on the journey's latest event: `source` (string, such as facebook or organic), `utm_campaign`, `utm_term` (usually the ad set), `utm_content` (usually the ad), `utm_medium`, `utm_id` (string or null each). null on a row with no visitor id, or when none was stored. |
| `journeys[].first_touch.source` | string or null | Source, such as facebook or organic. |
| `journeys[].first_touch.utm_campaign` | string or null | UTM campaign. |
| `journeys[].first_touch.utm_term` | string or null | UTM term (usually the ad set). |
| `journeys[].first_touch.utm_content` | string or null | UTM content (usually the ad). |
| `journeys[].first_touch.utm_medium` | string or null | UTM medium. |
| `journeys[].first_touch.utm_id` | string or null | UTM id. |
| `journeys[].last_touch` | object or null | Last visit credited, as stored on the journey's latest event. Same fields as first_touch. null on a row with no visitor id, or when none was stored. |
| `journeys[].last_touch.source` | string or null | Source, such as facebook or organic. |
| `journeys[].last_touch.utm_campaign` | string or null | UTM campaign. |
| `journeys[].last_touch.utm_term` | string or null | UTM term (usually the ad set). |
| `journeys[].last_touch.utm_content` | string or null | UTM content (usually the ad). |
| `journeys[].last_touch.utm_medium` | string or null | UTM medium. |
| `journeys[].last_touch.utm_id` | string or null | UTM id. |

## `list_events`

List events. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

List the tracked events on one site as rows, up to 100 per call. Each row has the time, event, page URL, traffic source, value, visitor and session ids, UTM tags with first and last touch, consent, and send status per pixel with any ad platform error. For an event's full payload, pass its id to get_event_payloads. Use it to answer questions about tracked events, such as what one visitor did, which conversions failed to send, or which pages purchases came from.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `from` | string | yes | Range start. YYYY-MM-DD means the start of that day in `timezone`; a full ISO 8601 timestamp is used as is. |
| `to` | string | yes | Range end. YYYY-MM-DD means the end of that day in `timezone`, so the whole day is included; a full ISO 8601 timestamp is used as is. |
| `timezone` | string | no | IANA time zone such as Europe/Berlin. Default UTC. Returned times and day buckets use it. |
| `events` | array of string, up to 50 items | no | Events to include, such as Purchase. Names are in list_supported_values's `events`. Default all. |
| `sources` | array of string, up to 50 items | no | Traffic source buckets, such as facebook, google, organic, or direct. Names are in list_supported_values's `sources`. |
| `utm_campaign` | array of string, up to 50 items | no | Match the visitor's UTM campaign seen in the lookback_days before the event (returned in the result). (not set) matches a blank value. |
| `utm_term` | array of string, up to 50 items | no | Same, for UTM term (usually the ad set). |
| `utm_content` | array of string, up to 50 items | no | Same, for UTM content (usually the ad). |
| `pixel_ids` | array of integer, up to 50 items | no | Only events sent to these pixels, ids from get_site_status. Rows still list every pixel. |
| `is_sent_successfully` | boolean | no | Whether to return only delivered events (true) or only failed and still-sending events (false); rows with an error are real failures. Default all. |
| `visitor_id` | string | no | One visitor's events, visitor_id from an earlier row. |
| `sort` | string, one of newest, oldest | no | Default newest. |
| `limit` | integer, 1 to 100 | no | Page size. Default 25. |
| `cursor` | string | no | next_cursor from the previous page, with the same sort. Omit for the first page. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `window` | object | Exact range read, after applying timezone. |
| `window.from` | string (date-time) | First instant included. |
| `window.to` | string (date-time) | Last instant included. |
| `timezone` | string | IANA time zone used for dates and times. UTC when none was passed. |
| `event_count` | integer | Rows on this page. |
| `next_cursor` | string or null | Pass as cursor for the next page. null: last page. |
| `lookback_days` | integer | Days before each event in which the visitor's UTM tags count, for the UTM filters and fields. |
| `events` | array of object | Events, in the requested sort. |
| `events[].id` | integer | Id of this event row. get_event_payloads takes it in ids. Not the same as event_id. |
| `events[].time` | string (date-time) | When the event arrived, in timezone. |
| `events[].event` | string | Event recorded, such as Purchase. |
| `events[].url` | string or null | Page URL. |
| `events[].source` | string or null | Traffic source bucket credited. |
| `events[].value` | number or null | Event value. |
| `events[].currency` | string or null | Event currency. |
| `events[].event_id` | string or null | Deduplication id shared with the browser pixel. |
| `events[].visitor_id` | string or null | Visitor id. |
| `events[].session_id` | string or null | Session id. |
| `events[].is_sent_successfully` | boolean | Whether the event was delivered to the ad platforms. |
| `events[].error` | string or null | Ad platform error. Set only on a real failure. |
| `events[].utm_source` | string or null | UTM tag of the visitor in the lookback_days before the event. |
| `events[].utm_medium` | string or null | UTM tag of the visitor in the lookback_days before the event. |
| `events[].utm_campaign` | string or null | UTM tag of the visitor in the lookback_days before the event. |
| `events[].utm_term` | string or null | UTM tag of the visitor in the lookback_days before the event. |
| `events[].utm_content` | string or null | UTM tag of the visitor in the lookback_days before the event. |
| `events[].utm_id` | string or null | UTM tag of the visitor in the lookback_days before the event. |
| `events[].first_touch` | object or null | First and last visit credited: `source`, `utm_campaign`, `utm_term`, `utm_content`, `utm_medium`, `utm_id` (string or null). null when no touch was recorded. |
| `events[].first_touch.source` | string or null | Source, such as facebook or organic. |
| `events[].first_touch.utm_campaign` | string or null | UTM campaign. |
| `events[].first_touch.utm_term` | string or null | UTM term (usually the ad set). |
| `events[].first_touch.utm_content` | string or null | UTM content (usually the ad). |
| `events[].first_touch.utm_medium` | string or null | UTM medium. |
| `events[].first_touch.utm_id` | string or null | UTM id. |
| `events[].last_touch` | object or null | First and last visit credited: `source`, `utm_campaign`, `utm_term`, `utm_content`, `utm_medium`, `utm_id` (string or null). null when no touch was recorded. |
| `events[].last_touch.source` | string or null | Source, such as facebook or organic. |
| `events[].last_touch.utm_campaign` | string or null | UTM campaign. |
| `events[].last_touch.utm_term` | string or null | UTM term (usually the ad set). |
| `events[].last_touch.utm_content` | string or null | UTM content (usually the ad). |
| `events[].last_touch.utm_medium` | string or null | UTM medium. |
| `events[].last_touch.utm_id` | string or null | UTM id. |
| `events[].consent` | object | Consent on the event: `state`, `source` (consent tool), `decision_at` (date-time, in timezone) (string or null each), and `regime` (enum: opt_in, opt_out; or null). opt_in: consent is needed before tracking. opt_out: tracking is allowed until the visitor refuses. null when not recorded. |
| `events[].consent.state` | string or null | Consent state. |
| `events[].consent.source` | string or null | Consent tool. |
| `events[].consent.decision_at` | string (date-time) or null | When the visitor decided. |
| `events[].consent.regime` | string or null, one of opt_in, opt_out | Consent rule for the visitor's region. opt_in: consent is needed before tracking. opt_out: tracking is allowed until the visitor refuses. null when not recorded. |
| `events[].pixels` | array of object | Per pixel: `pixel_id`, `name`, `ad_platform`, `state` (enum: sent, failed, pending). |
| `events[].pixels[].pixel_id` | integer | Pixel id. |
| `events[].pixels[].name` | string | Pixel name. |
| `events[].pixels[].ad_platform` | string or null | Ad platform name. |
| `events[].pixels[].state` | string, one of sent, failed, pending | Send status, as in list_events. |

## `get_event_payloads`

Get event details. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

Get the payload (request body) PixelFlow sent to each ad platform for up to 25 events by id. Each event lists every pixel it was sent to, with that payload and any error. IP addresses in the payload are partly hidden. Pass include_ip true to see them in full. Name, email and phone are hashed, as the ad platforms receive them. Use it to see exactly what was sent for an event from list_events, or why an ad platform rejected it.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `ids` | array of integer, at least 1 items, up to 25 items | yes | Row `id` values from list_events. |
| `include_ip` | boolean | no | Whether to return the full IP address inside the payload. Default false, which keeps only the first three IPv4 octets or the IPv6 /48 and replaces the rest with x. Use only when the user asks for the full address. |
| `timezone` | string | no | IANA time zone such as Europe/Berlin. Default UTC. Returned times and day buckets use it. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `timezone` | string | IANA time zone used for times. |
| `events` | array of object | One per id found, in the order of `ids`. |
| `events[].id` | integer | Row id from list_events. |
| `events[].time` | string (date-time) | Arrival time. |
| `events[].event` | string | The event recorded, such as Purchase. |
| `events[].pixels` | array of object | One per pixel the event was sent to, including pixels deleted since. Empty when the event was not sent to any pixel. |
| `events[].pixels[].pixel_id` | integer | The pixel, as in list_events. |
| `events[].pixels[].name` | string | The pixel, as in list_events. |
| `events[].pixels[].ad_platform` | string or null | The pixel, as in list_events. |
| `events[].pixels[].state` | string, one of sent, failed, pending | Send status, as in list_events. |
| `events[].pixels[].error` | string or null | Error stored for this send. Set only on a real failure. |
| `events[].pixels[].payload` | object or null | Payload (request body) sent to the ad platform, as stored. IP masked unless include_ip. null when no payload is stored, such as a send that failed before dispatch or an event older than payload retention. |

## `get_blocked_events`

Get blocked events. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

List the events PixelFlow did not send to ad platforms on one site because of consent or bot detection, up to 100 per call. Blocked events are stored without visitor data and by the hour, not the exact time. Each row is one blocked event with its hour, event, reason, consent tool, and consent regime. Events stopped by the site's blocking rules are not included. Ranges before the plan's analytics lookback are refused. Use it to find out why a conversion did not reach an ad platform, such as a purchase made at 3:15 today.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `from` | string | yes | Range start. YYYY-MM-DD means the start of that day in `timezone`; a full ISO 8601 timestamp is used as is. |
| `to` | string | yes | Range end. YYYY-MM-DD means the end of that day in `timezone`, so the whole day is included; a full ISO 8601 timestamp is used as is. |
| `timezone` | string | no | IANA time zone such as Europe/Berlin. Default UTC. Returned times and day buckets use it. |
| `events` | array of string, up to 50 items | no | Events to include, such as Purchase. Names are in list_supported_values's `events`. Default: the conversion events. Add PageView to include page views. |
| `reasons` | array of string | no | Reasons to include. Default all. |
| `sort` | string, one of newest, oldest | no | Default newest. |
| `limit` | integer, 1 to 100 | no | Page size. Default 25. |
| `cursor` | string | no | next_cursor from the previous page, with the same sort. Omit for the first page. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `window` | object | Exact range read, after applying timezone. |
| `window.from` | string (date-time) | First instant included. |
| `window.to` | string (date-time) | Last instant included. |
| `timezone` | string | IANA time zone used for times. UTC when none was passed. |
| `next_cursor` | string or null | Pass as cursor for the next page. null: last page. |
| `rows` | array of object | One per blocked event, in the requested sort. |
| `rows[].id` | integer | Id of this blocked event. |
| `rows[].hour` | string (date-time) | Start of the hour the event was blocked in, in timezone. |
| `rows[].event` | string | The event blocked, such as Purchase. |
| `rows[].reason` | string, one of denied, no_decision, gpc, bot | denied: the visitor refused consent. no_decision: no consent choice yet where one is required. gpc: the browser sent Global Privacy Control. bot: bot traffic. |
| `rows[].consent_source` | string or null | Consent tool that reported the choice, such as cookieyes or onetrust. null for gpc and bot, and when the site did not report one. |
| `rows[].regime` | string, one of opt_in, opt_out | Consent rule for the visitor's region. opt_in: consent is needed before tracking. opt_out: tracking is allowed until the visitor refuses. |
| `rows[].detail` | string or null | For bot only: the bot pattern detected, such as headless. null otherwise. |

## `list_triggers`

List triggers. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

List every conversion trigger on one site, including integrations such as Stripe. Each trigger has its type, the event it sends, its page URL, selector, value and data extraction. It also shows when the trigger last sent an event and whether that send succeeded. Use it to check what is tracked, or to find a trigger_id before changing a trigger or an integration.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `timezone` | string | no | IANA time zone such as Europe/Berlin. Default UTC. Returned times and day buckets use it. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `timezone` | string | IANA time zone used for times. UTC when none was passed. |
| `checked_from` | string (date-time) | Start of the period checked for each trigger's last event, which runs to now. |
| `triggers` | array of object | Every trigger on the site: saved triggers newest first, then system triggers. |
| `triggers[].trigger_id` | integer | Id of the trigger. update_trigger and delete_trigger take it for url, click, and submit. update_integration and disconnect_integration take it as integration_id for an integration. A system trigger cannot be changed. |
| `triggers[].type` | string | url: fires when a page loads. click: fires when an element is clicked. submit: fires when a form is submitted. system: built into the site platform. Otherwise an integration name, such as stripe or calendly. |
| `triggers[].event` | string | Event the trigger sends, such as Lead. |
| `triggers[].url` | string or null | Page address, query removed. |
| `triggers[].selector` | string or null | Element selector. |
| `triggers[].text_match` | object or null | Text filter on the element. |
| `triggers[].value` | number or null | Fixed value. |
| `triggers[].data_extraction` | object or null | Where customer data, value, and product data are read on the page; the shape create_trigger takes. |
| `triggers[].created_at` | string (date-time) or null | When the trigger was created. null on system triggers. |
| `triggers[].last_event_at` | string (date-time) or null | Latest event from this trigger since checked_from. null when there was none. |
| `triggers[].last_event_sent` | boolean or null | Whether that latest event was sent to the ad platforms successfully. null when there was no event. |

## `suggest_triggers`

Suggest triggers. Reads. readOnlyHint true, destructiveHint false, idempotentHint true, openWorldHint false

Suggest the conversion triggers a site still needs: which events are tracked today, and one proposal per gap. It uses what PixelFlow knows about the site and the observations passed in; it does not load the website or read code.
A url proposal carries arguments ready for create_trigger. An integration proposal carries connect arguments for get_connect_link. A click or submit proposal carries no create_trigger arguments: the agent builds them from the site's code, or the proposal carries connect arguments for get_connect_link, so the user picks the element on the website with the Visual Tagger.
Refused until site setup has passed verify. Use it when setting up conversion tracking, or when the user asks what else they could track.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `goal` | string, one of buy, book, lead, signup, donate | no | What a visitor does that earns the business money: buy a product, book a call or appointment, send a lead form, sign up, or donate. Omit when unknown; the result then includes a question to ask. |
| `events` | array of string | no | Limit proposals to these events, such as Subscribe. Names are in list_supported_values's `events`. |
| `observations` | array of object, up to 40 items | no | Forms, buttons, links, pages, or integrations the agent found in the site's code, on a page, or heard from the user. They decide which events are proposed and how; PixelFlow does not check them, and nothing in them is written to a trigger. Observations outrank what PixelFlow infers. |
| `observations[].type` | string, one of form, button, link, page, integration | yes | What was found. page: a page of the site, such as a thank-you page, given in page_path. |
| `observations[].page_path` | string | no | Path part of the page URL, such as /contact: the page where the form, button, or link lives. For the page observation type, the page path itself. Query values are dropped. |
| `observations[].text` | string | no | Visible label of a form's submit control, a button, or a link. A hint for naming the event, such as "Book a demo"; it is not compared with the page. |
| `observations[].form_fields` | array of string | no | Input names or labels on a form, such as email, phone. A hint for naming the event; they are not written to the trigger. |
| `observations[].provider` | string | no | Third-party provider of an integration or an embedded form, such as calendly or typeform. |
| `observations[].is_in_iframe` | boolean | no | Whether the element is inside an iframe. The script cannot see inside one, so such a form comes back as an add_code proposal. |
| `observations[].source` | string, one of code, page, user | yes | Where it was seen: in the site's code or a builder's element data (code), on a rendered page (page), or told by the user (user). Required. A form or button from code is a proposal for create_trigger; from page or user it is a Visual Tagger line with that page_path. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `rules_to_follow` | array of string | How to present and create the lines below; follow them. Empty when nothing applies. |
| `goal` | string or null, one of buy, book, lead, signup, donate | Goal the proposals are for: the one passed, or the one PixelFlow could tell from the site. null when unknown. |
| `question` | string or null | When goal is null: a question to ask the user, then call again with goal. |
| `coverage` | array of object | One row per event recommended for the goal, plus any other event that already has a source. |
| `coverage[].event` | string | Event, such as Lead. |
| `coverage[].status` | string, one of covered, proposed, gap | covered: something sends it today. proposed: a proposal below would send it. gap: recommended for the goal, but nothing can be proposed. |
| `coverage[].source` | string or null | What sends it today, such as a submit trigger, stripe, or the platform. null when nothing does. |
| `coverage[].when_it_fires` | string or null | When that source sends it. |
| `coverage[].last_event` | object or null | Latest event received: `at` (date-time) and `is_sent` (boolean). null when none was received recently. |
| `coverage[].last_event.at` | string (date-time) |  |
| `coverage[].last_event.is_sent` | boolean |  |
| `proposals` | array of object | What to set up, best first. |
| `proposals[].event` | string | Event the trigger would send, such as Lead. |
| `proposals[].type` | string or null | Type of the trigger to set up: url, click, submit, or an integration name, as in list_triggers. null on an add_code line, which has no trigger. |
| `proposals[].action` | string, one of create_trigger, get_connect_link, add_code | The action the agent performs for an approved proposal. create_trigger: create the trigger. get_connect_link: call it with the arguments in the connect field and show the link with the instructions. add_code: no trigger can track it; make the code change yourself or ask the user, as the message field says. |
| `proposals[].when_it_fires` | string | When the event is sent, in one sentence. |
| `proposals[].arguments` | object or null | url type only: arguments for create_trigger (`type`, `event`, `url`, and `url_params_mapping` when the page URL carries customer data); add site_id and an idempotency_key. null for every other line. |
| `proposals[].arguments.type` | string, one of url |  |
| `proposals[].arguments.event` | string |  |
| `proposals[].arguments.url` | string |  |
| `proposals[].arguments.url_params_mapping` | map of string, may be omitted |  |
| `proposals[].connect` | object or null | Arguments for get_connect_link. Set when action is get_connect_link, null otherwise. |
| `proposals[].connect.target` | string, one of integration, visual_tagger | integration: connect a third-party service. visual_tagger: the user picks the element on the website, because no code names it. |
| `proposals[].connect.integration` | string or null | With target integration: the integration to connect, such as stripe. |
| `proposals[].connect.page_path` | string or null | With target visual_tagger: the page where the user picks the element. null when no page is known; ask the user for it. |
| `proposals[].message` | string or null | With action add_code: why no trigger can track the event and how to send it from the site's code instead, such as trackEvent from the Programmatic Tracking API for a form inside an iframe. |
| `proposals[].evidence` | object | Why the event was proposed. |
| `proposals[].evidence.type` | string, one of site_facts, observation, observed_path | site_facts: what PixelFlow knows about the site, such as its platform or a connected integration. observation: an observation passed in this call. observed_path: a page visitors reached recently, such as /thank-you. |
| `proposals[].evidence.note` | string | The evidence in one sentence, such as "Form with an email field at /contact". |
| `proposals[].evidence.source` | string or null, one of code, page, user | With type observation: that observation's source. null otherwise. |
| `proposals[].prefix_warning` | string or null | url type only: other pages of this site the url would also match, because a url trigger matches the path as a prefix, such as /thank-you also matching /thank-you-newsletter. Tell the user before creating it. null when no page shares the prefix. |
| `proposals[].fallback` | object or null | Next-best way to track the same event, a url trigger on a page the site is known to have: `type`, `when_it_fires`, `prefix_warning`, and `arguments` (same shape as above). |
| `proposals[].fallback.type` | string |  |
| `proposals[].fallback.when_it_fires` | string |  |
| `proposals[].fallback.prefix_warning` | string or null |  |
| `proposals[].fallback.arguments` | object or null |  |
| `proposals[].fallback.arguments.type` | string, one of url |  |
| `proposals[].fallback.arguments.event` | string |  |
| `proposals[].fallback.arguments.url` | string |  |
| `proposals[].fallback.arguments.url_params_mapping` | map of string, may be omitted |  |
| `proposals[].conflict` | object or null | The event already has a source: `existing_source`, `when_it_fires`. |
| `proposals[].conflict.existing_source` | string |  |
| `proposals[].conflict.when_it_fires` | string |  |
| `proposals[].docs` | array of object | Help articles: `title` (string) and `url` (string, uri). |
| `proposals[].docs[].title` | string |  |
| `proposals[].docs[].url` | string (uri) |  |
| `blocking_rules` | array of object | Refresh protection to save: `when_it_fires`, `rule` (ready for save_blocking_rule). |
| `blocking_rules[].when_it_fires` | string |  |
| `blocking_rules[].rule` | object |  |
| `blocking_rules[].rule.target` | string |  |
| `blocking_rules[].rule.mode` | string, one of block |  |
| `blocking_rules[].rule.groups` | array of object |  |
| `blocking_rules[].rule.groups[].conditions` | array of object |  |
| `blocking_rules[].rule.groups[].conditions[].type` | string |  |
| `blocking_rules[].rule.groups[].conditions[].interval_in_seconds` | integer |  |

## `create_trigger`

Create trigger. Edits. readOnlyHint false, destructiveHint false, idempotentHint true, openWorldHint false

Create a trigger that sends an event to the site's ad platforms when a visitor submits a form, clicks an element, or loads a page, and return the saved trigger with its trigger_id.
Build the selector, text_match, and data_extraction fields only from the site's code open in this chat, or from a site builder's element data when that builder is connected in this chat. Use what is rendered in the page: an element's id, a class, the control's visible label, or an input's `name` attribute. Without the code or the builder's element data, do not create a click or submit trigger: call get_connect_link with target visual_tagger and the page path, so the user picks the element and its fields. Call list_triggers first: a click or submit trigger on the same element may already exist, such as one the Visual Tagger saved.
Nothing is added to the website code. Repeating an idempotency_key returns the same trigger. Refused until site setup has passed verify. Use it after the user approves a trigger, such as one proposed by suggest_triggers.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `idempotency_key` | string | yes | Unique string per intended change, such as a UUID. Repeating a key returns the first result instead of writing again. |
| `type` | string, one of url, click, submit | yes | What the visitor does to trigger an event. submit: submits a `<form>` element. click: clicks a button, link, or other element, including the button of a form built without a `<form>` element. url: loads a page (prefix match on host and path; the query is ignored), such as a product page for ViewContent. |
| `event` | string | yes | Event to send, such as Lead or Purchase. Names are in list_supported_values's `events`. |
| `url` | string | no | Page on this site that fires the event when it loads. Required for url type. Refused for click and submit. Query values are ignored. |
| `selector` | string | no | Required for click and submit type. For click: the element the visitor clicks, such as a button, a link, an image, or any other clickable element. For submit: the form's submit control, a `button` or an `input` of type submit, never the form or a wrapper around it; a submit selector that ends in `form`, `div`, `span`, `section`, or another container tag is refused. Prefer the element's `#id`, then a control tag (`button`, `input`, `a`) with text_match on its label, then a stable `[name=...]`, `[data-...=...]`, or `a[href=...]`, then a class chain read from the markup. The trigger fires on every element the selector matches, on every page, so a class has to be unique across the site, not only on this page. A bare tag without text_match is refused. At most 250 characters and 10 `>` segments. |
| `text_match` | object | no | The control's own text, lowercased with whitespace collapsed: a button's label, or a submit input's `value`. Nothing else is compared, not aria-label, data-name, a form name, or an id. Required with a bare control tag such as `button` or `input`; optional with an id or attribute selector. equals: the whole label, such as "send message". contains: part of it. regex: a JavaScript regular expression, run on the lowercased text. Send one operator; when several are sent, equals is used, then contains. |
| `text_match.equals` | string | no |  |
| `text_match.contains` | string | no |  |
| `text_match.regex` | string | no |  |
| `value` | number, at least 0 | no | Fixed value for every event. Omit when data_extraction reads the value from the page. |
| `currency` | string, up to 3 characters | no | ISO 4217 currency for value. Default the site's currency. |
| `data_extraction` | object | no | Customer data, event value, and product data the script reads from the page when the trigger fires and sends with the event to the ad platforms. Recommended: it raises match quality and attribution, and lets the platform optimize on value. Each section is optional; unknown keys are refused. |
| `data_extraction.customer` | object | no | Where the script reads the visitor's data on the page: inside the submitted `<form>` first (or `form.formContainerSelector` for a click), then anywhere on the page. |
| `data_extraction.customer.email` | object | no | Where the script reads the visitor's email on the page. |
| `data_extraction.customer.email.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.customer.email.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.customer.email.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.customer.email.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.customer.email.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.customer.email.textMatch.contains` | string | no |  |
| `data_extraction.customer.email.textMatch.equals` | string | no |  |
| `data_extraction.customer.email.textMatch.regex` | string | no |  |
| `data_extraction.customer.phone` | object | no | Where the script reads the visitor's phone on the page. |
| `data_extraction.customer.phone.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.customer.phone.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.customer.phone.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.customer.phone.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.customer.phone.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.customer.phone.textMatch.contains` | string | no |  |
| `data_extraction.customer.phone.textMatch.equals` | string | no |  |
| `data_extraction.customer.phone.textMatch.regex` | string | no |  |
| `data_extraction.customer.firstName` | object | no | Where the script reads the visitor's first name on the page. |
| `data_extraction.customer.firstName.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.customer.firstName.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.customer.firstName.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.customer.firstName.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.customer.firstName.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.customer.firstName.textMatch.contains` | string | no |  |
| `data_extraction.customer.firstName.textMatch.equals` | string | no |  |
| `data_extraction.customer.firstName.textMatch.regex` | string | no |  |
| `data_extraction.customer.lastName` | object | no | Where the script reads the visitor's last name on the page. |
| `data_extraction.customer.lastName.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.customer.lastName.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.customer.lastName.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.customer.lastName.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.customer.lastName.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.customer.lastName.textMatch.contains` | string | no |  |
| `data_extraction.customer.lastName.textMatch.equals` | string | no |  |
| `data_extraction.customer.lastName.textMatch.regex` | string | no |  |
| `data_extraction.customer.fullName` | object | no | Where the script reads the visitor's full name on the page, when the form has one name input. Split on whitespace into first and last name. |
| `data_extraction.customer.fullName.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.customer.fullName.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.customer.fullName.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.customer.fullName.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.customer.fullName.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.customer.fullName.textMatch.contains` | string | no |  |
| `data_extraction.customer.fullName.textMatch.equals` | string | no |  |
| `data_extraction.customer.fullName.textMatch.regex` | string | no |  |
| `data_extraction.form` | object | no | Where the script reads the event value on the page, and the container of a form built without a `<form>` element. |
| `data_extraction.form.formContainerSelector` | string | no | Applicable for click triggers only, recommended when customer fields or valueSelector are read: the element that wraps both the inputs and the clicked button. Customer fields and valueSelector are read inside it. When it does not wrap the clicked element, the first match on the page is used. Not needed for commerce fields. |
| `data_extraction.form.valueSelector` | object | no | Where the script reads the event value on the page, such as a chosen plan's price. Omit when `value` is fixed. |
| `data_extraction.form.valueSelector.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.form.valueSelector.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.form.valueSelector.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.form.valueSelector.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.form.valueSelector.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.form.valueSelector.textMatch.contains` | string | no |  |
| `data_extraction.form.valueSelector.textMatch.equals` | string | no |  |
| `data_extraction.form.valueSelector.textMatch.regex` | string | no |  |
| `data_extraction.commerce` | object | no | Where the script reads product data on the page: one product on a product page, every product in a cart or checkout. `fields` is required. |
| `data_extraction.commerce.productContainerSelector` | string | no | The element that wraps one product, with its id, name, price, and quantity inside. On a product page it wraps the add-to-cart button; in a cart it repeats once per product. |
| `data_extraction.commerce.productsListContainerSelector` | string | no | The element that wraps all product containers, such as a cart or an order summary; each product inside it is read. |
| `data_extraction.commerce.fields` | object | yes |  |
| `data_extraction.commerce.fields.productId` | object | no | Where the script reads the product id, inside the product container. |
| `data_extraction.commerce.fields.productId.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.commerce.fields.productId.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.commerce.fields.productId.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.commerce.fields.productId.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.commerce.fields.productId.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.commerce.fields.productId.textMatch.contains` | string | no |  |
| `data_extraction.commerce.fields.productId.textMatch.equals` | string | no |  |
| `data_extraction.commerce.fields.productId.textMatch.regex` | string | no |  |
| `data_extraction.commerce.fields.productName` | object | no | Where the script reads the product name, inside the product container. |
| `data_extraction.commerce.fields.productName.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.commerce.fields.productName.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.commerce.fields.productName.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.commerce.fields.productName.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.commerce.fields.productName.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.commerce.fields.productName.textMatch.contains` | string | no |  |
| `data_extraction.commerce.fields.productName.textMatch.equals` | string | no |  |
| `data_extraction.commerce.fields.productName.textMatch.regex` | string | no |  |
| `data_extraction.commerce.fields.price` | object | no | Where the script reads the unit price, inside the product container. |
| `data_extraction.commerce.fields.price.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.commerce.fields.price.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.commerce.fields.price.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.commerce.fields.price.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.commerce.fields.price.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.commerce.fields.price.textMatch.contains` | string | no |  |
| `data_extraction.commerce.fields.price.textMatch.equals` | string | no |  |
| `data_extraction.commerce.fields.price.textMatch.regex` | string | no |  |
| `data_extraction.commerce.fields.quantity` | object | no | Where the script reads the quantity, inside the product container. |
| `data_extraction.commerce.fields.quantity.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.commerce.fields.quantity.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.commerce.fields.quantity.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.commerce.fields.quantity.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.commerce.fields.quantity.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.commerce.fields.quantity.textMatch.contains` | string | no |  |
| `data_extraction.commerce.fields.quantity.textMatch.equals` | string | no |  |
| `data_extraction.commerce.fields.quantity.textMatch.regex` | string | no |  |
| `data_extraction.commerce.totalPriceSelector` | object | no | Where the script reads the order total on the page. |
| `data_extraction.commerce.totalPriceSelector.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.commerce.totalPriceSelector.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.commerce.totalPriceSelector.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.commerce.totalPriceSelector.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.commerce.totalPriceSelector.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.commerce.totalPriceSelector.textMatch.contains` | string | no |  |
| `data_extraction.commerce.totalPriceSelector.textMatch.equals` | string | no |  |
| `data_extraction.commerce.totalPriceSelector.textMatch.regex` | string | no |  |
| `url_params_mapping` | object | no | Customer data and event value the script reads from the page URL's query when a url trigger fires and sends with the event to the ad platforms, such as a thank-you page opened as /thanks?email=...&amount=.... An object of query parameter name to field: `{ "email": "em", "amount": "value" }`. Fields: `em` (email), `ph` (phone), `fn` (first name), `ln` (last name), `full_name`, `ct` (city), `st` (state), `zp` (postal code), `country`, `value`, `currency`, `quantity`. url type only. Required when the page URL carries customer data in its query; without it, the call is refused and the refusal gives the mapping to send. |
| `allow_duplicate` | boolean | no | Whether to save even though the event already has another source. Without it, the call is refused and the refusal names that source. Default false. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `trigger` | object | The saved trigger, as a list_triggers row. |
| `trigger.trigger_id` | integer | Id of the trigger. update_trigger and delete_trigger take it. |
| `trigger.type` | string, one of url, click, submit | Type of the saved trigger. |
| `trigger.event` | string | Event the trigger sends, such as Lead. |
| `trigger.url` | string or null | Page address, query removed. |
| `trigger.selector` | string or null | Element selector. |
| `trigger.text_match` | object or null | Text filter on the element. |
| `trigger.value` | number or null | Fixed value. |
| `trigger.data_extraction` | object or null | Where customer data, value, and product data are read on the page; same shape as the parameter. |
| `trigger.created_at` | string (date-time) | When the trigger was created. |
| `next_step` | string | For a saved trigger: what to do next. The previous configuration stays cached for about a minute; then test once in a fresh private window and confirm with list_events. For click and submit: adding customer fields when missing, and, when the test sends no event, opening the Visual Tagger for that page. |

## `update_trigger`

Update trigger. Edits. readOnlyHint false, destructiveHint true, idempotentHint true, openWorldHint false

Change an existing trigger of type url, click, or submit and return the saved trigger. type and event are always required, and type cannot change. Other omitted fields stay unchanged; provided fields overwrite the stored value.
Build a new selector, text_match, or data_extraction only from the site's code open in this chat, or from a site builder's element data when that builder is connected in this chat. Use what is rendered in the page: an element's id, a class, the control's visible label, or an input's `name` attribute. Without the code or the builder's element data, do not change a click or submit selector: call get_connect_link with target visual_tagger and the page path, so the user picks the element and its fields.
Repeating an idempotency_key applies the change once. Use it when the user wants to change a trigger's page, element, event, value, or data extraction.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `idempotency_key` | string | yes | Unique string per intended change, such as a UUID. Repeating a key returns the first result instead of writing again. |
| `trigger_id` | integer | yes | Trigger id as returned by list_triggers or create_trigger. |
| `type` | string, one of url, click, submit | yes | Type of the stored trigger, as returned by list_triggers. It cannot change; a different type is refused. |
| `event` | string | yes | Event to send, such as Lead or Purchase. Names are in list_supported_values's `events`. |
| `url` | string | no | Page on this site that fires the event when it loads. url type only; refused for click and submit. Query values are ignored. |
| `selector` | string | no | Click and submit only. For click: the element the visitor clicks, such as a button, a link, an image, or any other clickable element. For submit: the form's submit control, a `button` or an `input` of type submit, never the form or a wrapper around it; a submit selector that ends in `form`, `div`, `span`, `section`, or another container tag is refused. Prefer the element's `#id`, then a control tag (`button`, `input`, `a`) with text_match on its label, then a stable `[name=...]`, `[data-...=...]`, or `a[href=...]`, then a class chain read from the markup. The trigger fires on every element the selector matches, on every page, so a class has to be unique across the site, not only on this page. A bare tag without text_match is refused. At most 250 characters and 10 `>` segments. |
| `text_match` | object | no | The control's own text, lowercased with whitespace collapsed: a button's label, or a submit input's `value`. Nothing else is compared, not aria-label, data-name, a form name, or an id. Required with a bare control tag such as `button` or `input`; optional with an id or attribute selector. equals: the whole label, such as "send message". contains: part of it. regex: a JavaScript regular expression, run on the lowercased text. Send one operator; when several are sent, equals is used, then contains. |
| `text_match.equals` | string | no |  |
| `text_match.contains` | string | no |  |
| `text_match.regex` | string | no |  |
| `value` | number, at least 0 | no | Fixed value for every event. Omit when data_extraction reads the value from the page. |
| `currency` | string, up to 3 characters | no | ISO 4217 currency for value. Default the site's currency. |
| `data_extraction` | object | no | Customer data, event value, and product data the script reads from the page when the trigger fires and sends with the event to the ad platforms. Recommended: it raises match quality and attribution, and lets the platform optimize on value. Each section is optional; unknown keys are refused. |
| `data_extraction.customer` | object | no | Where the script reads the visitor's data on the page: inside the submitted `<form>` first (or `form.formContainerSelector` for a click), then anywhere on the page. |
| `data_extraction.customer.email` | object | no | Where the script reads the visitor's email on the page. |
| `data_extraction.customer.email.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.customer.email.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.customer.email.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.customer.email.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.customer.email.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.customer.email.textMatch.contains` | string | no |  |
| `data_extraction.customer.email.textMatch.equals` | string | no |  |
| `data_extraction.customer.email.textMatch.regex` | string | no |  |
| `data_extraction.customer.phone` | object | no | Where the script reads the visitor's phone on the page. |
| `data_extraction.customer.phone.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.customer.phone.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.customer.phone.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.customer.phone.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.customer.phone.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.customer.phone.textMatch.contains` | string | no |  |
| `data_extraction.customer.phone.textMatch.equals` | string | no |  |
| `data_extraction.customer.phone.textMatch.regex` | string | no |  |
| `data_extraction.customer.firstName` | object | no | Where the script reads the visitor's first name on the page. |
| `data_extraction.customer.firstName.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.customer.firstName.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.customer.firstName.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.customer.firstName.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.customer.firstName.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.customer.firstName.textMatch.contains` | string | no |  |
| `data_extraction.customer.firstName.textMatch.equals` | string | no |  |
| `data_extraction.customer.firstName.textMatch.regex` | string | no |  |
| `data_extraction.customer.lastName` | object | no | Where the script reads the visitor's last name on the page. |
| `data_extraction.customer.lastName.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.customer.lastName.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.customer.lastName.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.customer.lastName.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.customer.lastName.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.customer.lastName.textMatch.contains` | string | no |  |
| `data_extraction.customer.lastName.textMatch.equals` | string | no |  |
| `data_extraction.customer.lastName.textMatch.regex` | string | no |  |
| `data_extraction.customer.fullName` | object | no | Where the script reads the visitor's full name on the page, when the form has one name input. Split on whitespace into first and last name. |
| `data_extraction.customer.fullName.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.customer.fullName.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.customer.fullName.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.customer.fullName.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.customer.fullName.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.customer.fullName.textMatch.contains` | string | no |  |
| `data_extraction.customer.fullName.textMatch.equals` | string | no |  |
| `data_extraction.customer.fullName.textMatch.regex` | string | no |  |
| `data_extraction.form` | object | no | Where the script reads the event value on the page, and the container of a form built without a `<form>` element. |
| `data_extraction.form.formContainerSelector` | string | no | Applicable for click triggers only, recommended when customer fields or valueSelector are read: the element that wraps both the inputs and the clicked button. Customer fields and valueSelector are read inside it. When it does not wrap the clicked element, the first match on the page is used. Not needed for commerce fields. |
| `data_extraction.form.valueSelector` | object | no | Where the script reads the event value on the page, such as a chosen plan's price. Omit when `value` is fixed. |
| `data_extraction.form.valueSelector.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.form.valueSelector.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.form.valueSelector.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.form.valueSelector.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.form.valueSelector.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.form.valueSelector.textMatch.contains` | string | no |  |
| `data_extraction.form.valueSelector.textMatch.equals` | string | no |  |
| `data_extraction.form.valueSelector.textMatch.regex` | string | no |  |
| `data_extraction.commerce` | object | no | Where the script reads product data on the page: one product on a product page, every product in a cart or checkout. `fields` is required. |
| `data_extraction.commerce.productContainerSelector` | string | no | The element that wraps one product, with its id, name, price, and quantity inside. On a product page it wraps the add-to-cart button; in a cart it repeats once per product. |
| `data_extraction.commerce.productsListContainerSelector` | string | no | The element that wraps all product containers, such as a cart or an order summary; each product inside it is read. |
| `data_extraction.commerce.fields` | object | yes |  |
| `data_extraction.commerce.fields.productId` | object | no | Where the script reads the product id, inside the product container. |
| `data_extraction.commerce.fields.productId.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.commerce.fields.productId.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.commerce.fields.productId.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.commerce.fields.productId.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.commerce.fields.productId.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.commerce.fields.productId.textMatch.contains` | string | no |  |
| `data_extraction.commerce.fields.productId.textMatch.equals` | string | no |  |
| `data_extraction.commerce.fields.productId.textMatch.regex` | string | no |  |
| `data_extraction.commerce.fields.productName` | object | no | Where the script reads the product name, inside the product container. |
| `data_extraction.commerce.fields.productName.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.commerce.fields.productName.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.commerce.fields.productName.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.commerce.fields.productName.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.commerce.fields.productName.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.commerce.fields.productName.textMatch.contains` | string | no |  |
| `data_extraction.commerce.fields.productName.textMatch.equals` | string | no |  |
| `data_extraction.commerce.fields.productName.textMatch.regex` | string | no |  |
| `data_extraction.commerce.fields.price` | object | no | Where the script reads the unit price, inside the product container. |
| `data_extraction.commerce.fields.price.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.commerce.fields.price.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.commerce.fields.price.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.commerce.fields.price.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.commerce.fields.price.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.commerce.fields.price.textMatch.contains` | string | no |  |
| `data_extraction.commerce.fields.price.textMatch.equals` | string | no |  |
| `data_extraction.commerce.fields.price.textMatch.regex` | string | no |  |
| `data_extraction.commerce.fields.quantity` | object | no | Where the script reads the quantity, inside the product container. |
| `data_extraction.commerce.fields.quantity.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.commerce.fields.quantity.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.commerce.fields.quantity.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.commerce.fields.quantity.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.commerce.fields.quantity.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.commerce.fields.quantity.textMatch.contains` | string | no |  |
| `data_extraction.commerce.fields.quantity.textMatch.equals` | string | no |  |
| `data_extraction.commerce.fields.quantity.textMatch.regex` | string | no |  |
| `data_extraction.commerce.totalPriceSelector` | object | no | Where the script reads the order total on the page. |
| `data_extraction.commerce.totalPriceSelector.selector` | string | yes | A valid, stable CSS selector for the element. Preferred order: `#id`; `[name="..."]` exactly as rendered (letter case matters); a unique `[type="..."]` such as `[type="email"]`; a class. A label, placeholder, or display name is not a selector. A bare tag such as `input` is refused. |
| `data_extraction.commerce.totalPriceSelector.extractFrom` | string, one of value, text, attribute | no | `value` for inputs, selects, and textareas (the default for them); `text` for visible text (the default otherwise); `attribute` with `attributeName`. |
| `data_extraction.commerce.totalPriceSelector.attributeName` | string | no | Attribute to read when `extractFrom` is `attribute`. |
| `data_extraction.commerce.totalPriceSelector.fallbackSelector` | string | no | Tried when `selector` matches nothing. |
| `data_extraction.commerce.totalPriceSelector.textMatch` | object | no | Narrows the matched elements by their text; same operators and rules as `text_match`. |
| `data_extraction.commerce.totalPriceSelector.textMatch.contains` | string | no |  |
| `data_extraction.commerce.totalPriceSelector.textMatch.equals` | string | no |  |
| `data_extraction.commerce.totalPriceSelector.textMatch.regex` | string | no |  |
| `url_params_mapping` | object | no | Customer data and event value the script reads from the page URL's query when a url trigger fires and sends with the event to the ad platforms, such as a thank-you page opened as /thanks?email=...&amount=.... An object of query parameter name to field: `{ "email": "em", "amount": "value" }`. Fields: `em` (email), `ph` (phone), `fn` (first name), `ln` (last name), `full_name`, `ct` (city), `st` (state), `zp` (postal code), `country`, `value`, `currency`, `quantity`. url type only. Required when the page URL carries customer data in its query; without it, the call is refused and the refusal gives the mapping to send. |
| `allow_duplicate` | boolean | no | Whether to save even though the event already has another source. Without it, the call is refused and the refusal names that source. Default false. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `trigger` | object | The saved trigger, as a list_triggers row. |
| `trigger.trigger_id` | integer | Id of the trigger. update_trigger and delete_trigger take it. |
| `trigger.type` | string, one of url, click, submit | Type of the saved trigger. |
| `trigger.event` | string | Event the trigger sends, such as Lead. |
| `trigger.url` | string or null | Page address, query removed. |
| `trigger.selector` | string or null | Element selector. |
| `trigger.text_match` | object or null | Text filter on the element. |
| `trigger.value` | number or null | Fixed value. |
| `trigger.data_extraction` | object or null | Where customer data, value, and product data are read on the page; same shape as the parameter. |
| `trigger.created_at` | string (date-time) | When the trigger was created, not when it was changed. |
| `next_step` | string | For a saved trigger: what to do next. The previous configuration stays cached for about a minute; then test once in a fresh private window and confirm with list_events. For click and submit: adding customer fields when missing, and, when the test sends no event, opening the Visual Tagger for that page. |

## `delete_trigger`

Delete trigger. Deletes. readOnlyHint false, destructiveHint true, idempotentHint true, openWorldHint false

Delete a trigger of type url, click, or submit and return the id and type of the removed trigger. Its event stops being sent from that trigger once visitors' browsers pick up the new site configuration. Repeating an idempotency_key deletes once. Use it when the user wants to stop sending an event from that trigger.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `idempotency_key` | string | yes | Unique string per intended change, such as a UUID. Repeating a key returns the first result instead of writing again. |
| `type` | string, one of url, click, submit | yes | Type of the stored trigger, as returned by list_triggers. |
| `trigger_id` | integer | yes | Trigger id as returned by list_triggers or create_trigger. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `saved` | boolean | Whether the request was applied. Always true on success. |
| `deleted` | boolean | Whether the trigger was removed. Always true on success. |
| `trigger_id` | integer | Id of the removed trigger. |
| `type` | string, one of url, click, submit | Type of the removed trigger. |

## `save_blocking_rule`

Save blocking rule. Edits. readOnlyHint false, destructiveHint true, idempotentHint true, openWorldHint false

Save the blocking rule for one event on a site, such as Purchase, or for all events (AllEvents). It replaces the rule already saved for that event, if any. Rules for other events stay. A blocking rule stops matching events from being sent to ad platforms, such as a second Purchase when the confirmation page is refreshed. A rule for one event, such as Purchase, replaces the AllEvents rule for that event, so include any AllEvents conditions it should keep. The current rules are in get_site_status. Returns the saved rule. Repeating an idempotency_key applies the change once. Use it when the user wants to stop duplicate or unwanted events reaching ad platforms, or to save a rule proposed by suggest_triggers.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `idempotency_key` | string | yes | Unique string per intended change, such as a UUID. Repeating a key returns the first result instead of writing again. |
| `rule` | object | yes | Rule to save. The `rule` of a suggest_triggers blocking_rules line is ready to pass. |
| `rule.target` | string | yes | AllEvents, or one event, such as Purchase. Event names are in list_supported_values's `events`. |
| `rule.mode` | string, one of block, do_not_block | yes | block: events that match any group are not sent. do_not_block: always send this event, even when the AllEvents rule would block it. Use it for an event that must always reach the ad platforms. Send it with no groups. Not allowed when target is AllEvents. |
| `rule.groups` | array of object | no | Required for block. Any matching group blocks the event. |
| `rule.groups[].conditions` | array of object | yes | All conditions in a group must match. |
| `rule.groups[].conditions[].type` | string, one of no_fbc, no_query_params, same_event, same_url, same_referrer, external_tracking, block_url | yes | no_fbc: the event has no Facebook click id. Stops sending to Facebook only; every other condition stops sending to all ad platforms. no_query_params: the page URL has no query parameters. same_event: the same visitor sent the same event within interval_in_seconds. same_url: the same visitor sent the event from the same page URL within interval_in_seconds. same_referrer: the same visitor sent the event with the same referrer within interval_in_seconds. block_url: the page URL equals, or starts with, value. external_tracking: the event was not sent by the PixelFlow script, such as a direct API call. |
| `rule.groups[].conditions[].interval_in_seconds` | integer, at least 1 | no | Seconds. Required for same_event, same_url, and same_referrer. |
| `rule.groups[].conditions[].matcher` | string, one of equal, starts_with | no | Required for block_url. |
| `rule.groups[].conditions[].value` | string | no | Required for block_url. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `rule` | object | The saved rule: `target`, `mode`, and `groups`, the shape the rule parameter takes. |
| `rule.target` | string |  |
| `rule.mode` | string, one of block, do_not_block |  |
| `rule.groups` | array of object, may be omitted |  |
| `rule.groups[].conditions` | array of object |  |
| `rule.groups[].conditions[].type` | string |  |
| `rule.groups[].conditions[].interval_in_seconds` | integer, may be omitted |  |
| `rule.groups[].conditions[].matcher` | string, may be omitted |  |
| `rule.groups[].conditions[].value` | string, may be omitted |  |

## `delete_blocking_rule`

Delete blocking rule. Deletes. readOnlyHint false, destructiveHint true, idempotentHint true, openWorldHint false

Delete the blocking rule for one event on a site, such as Purchase, or the AllEvents rule. Rules for other events stay. After an event's own rule is deleted, the AllEvents rule applies to that event again. After the AllEvents rule is deleted, events without their own rule are no longer blocked. If the event has no rule, the call is refused and nothing changes. Returns the events that still have a rule, including AllEvents. Repeating an idempotency_key deletes once. Use it when the user wants events that a rule blocks to reach ad platforms again.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `idempotency_key` | string | yes | Unique string per intended change, such as a UUID. Repeating a key returns the first result instead of writing again. |
| `target` | string | yes | AllEvents, or the event whose rule to delete, such as Purchase. Event names are in list_supported_values's `events`. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `rules_left` | array of string | Events that still have a blocking rule after the delete, such as AllEvents or Lead. Empty when the site has no rules left. |

## `close_get_started`

Update Get Started checklist. Edits. readOnlyHint false, destructiveHint false, idempotentHint true, openWorldHint false

Check the site's Get Started checklist and mark as done the items PixelFlow can confirm from its data. The setup item is marked done when any event was received. The old pixel item is marked done when the last page check found no native ad platform pixel. The UTM item is marked done when an event came from a paid source. The consent banner item is marked done when a banner was detected or consent blocked an event. Items are only marked done, never undone. Returns the items this call marked done and the items not done yet, each with the update_site field that marks it done once the user confirms. Use it at the end of setup.

### Arguments

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `site_id` | integer | yes | Site to act on, as returned by list_sites. |
| `extra_events_declined` | boolean | no | Whether the user said they do not want to track more conversions. Saves that answer so get_site_status stops asking. |

### Result

| Field | Type | Description |
| --- | --- | --- |
| `has_conversion_event` | boolean | Whether an event other than PageView arrived in the last events_window_days of get_site_status. |
| `marked_done` | array of string | Items this call marked done, named by their flag: is_completed (setup finished), is_old_pixel_removed, is_utm_snippet_added, is_consent_banner_configured. Empty when no item was marked done. |
| `remaining` | array of object | Items not done yet that apply to this site. |
| `remaining[].field` | string, one of is_old_pixel_removed, is_utm_snippet_added, is_meta_domain_approved, is_consent_banner_configured | The update_site field that marks this item done. |
| `remaining[].title` | string | Item title, such as "Approve your domain in Meta". |
| `remaining[].docs` | array of object | Help articles for this item: `title` (string) and `url` (string, uri). |
| `remaining[].docs[].title` | string |  |
| `remaining[].docs[].url` | string (uri) |  |
