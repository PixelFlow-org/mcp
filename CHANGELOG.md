# Changelog

## 2.0.0

Tool definitions were rewritten. `tools/list` has 25 tools. The version is 2.0.0 because the contract changed: the `site` argument is refused, three tools are gone, and one is renamed. A host that cached the 1.0.x tool list gets a sentence naming the replacement when it calls a removed tool, and the hint to call `tools/list` again. Claude, Claude Code, Cursor, and Lovable fetch the list on each new chat; in ChatGPT, refresh the connector in its settings.

Added:

- `list_supported_values`: the platforms, ad platforms, integrations, events, and traffic sources that parameters take. `list_sites` no longer returns them.
- `TOOLS.md`: the description, hints, arguments, and result fields of every tool, generated from the server. The README tool table carries the first sentence of each description.

Removed:

- `list_recent_changes`
- `ensure_webflow_ecommerce_triggers`: saving a Webflow site with eCommerce on and a domain through `create_site` or `update_site` adds the standard url triggers and returns `triggers_added`.
- `check_selector`: a headless page load cannot tell a selector that no longer matches from a form that loads late. When a click or submit trigger sends no event, ask the user to test it once and read `list_events`; if the event still does not arrive, `get_connect_link` with target `visual_tagger` lets the user pick the element again.

Renamed:

- `upsert_blocking_rule` is now `save_blocking_rule`.
- Titles: `get_connect_link` is "Get dashboard link", `get_overview` is "Get tracking overview", `get_event_payloads` is "Get event details", and `close_get_started` is "Update Get Started checklist".

Contract changes:

- Every tool takes the site as `site_id`, an integer from `list_sites`. The `site` argument is refused. Results return `site_id` and `workspace_id`.
- Trigger tools take `type` (`url`, `click`, `submit`) in place of `kind` (`page`, `click`, `form`). The old names are still accepted.
- The ad platform value is `facebook`. `meta` is still accepted as input.
- `get_install_instructions` and `get_site_status` `next_action` take `task` (`install`, `add_utm`, `remove_duplicate_pixel`, `uninstall`) and `ad_platform`, in place of `part`.
- `get_connect_link` `target` is `ad_platform`, `integration`, `billing`, or `visual_tagger`, with the name in `ad_platform` or `integration`.
- `verify_tracking` checks the live page only. `get_site_status` `last_events` says whether an event arrived and was sent.
- `get_journeys` returns one row per visitor, as the dashboard Journeys page does. `list_triggers` takes no date range and returns `last_event_at` per trigger.
- `save_blocking_rule` returns `{ rule }`, and `delete_blocking_rule` returns `{ rules_left }`. `suggestion_id` is ignored.
- `update_pixel` returns `test_mode_ends_at`.
- Every tool sends all four annotation hints. `destructiveHint` is true when a write deletes or overwrites stored values: `update_site`, `update_pixel`, `update_integration`, `disconnect_integration`, `update_trigger`, `delete_trigger`, `save_blocking_rule`, and `delete_blocking_rule`. `openWorldHint` is true only on `verify_tracking`.
- Every tool declares an output schema, and results match it. A nullable result field is `anyOf` its typed branch and `null`, each with a single `type`, so clients that reject a `type` array (Gemini function declarations) accept the schema.
- The `setup_tracking`, `audit_tracking`, and `weekly_report` prompts and the three skills use the new tools and arguments.

## 1.0.0

Tools on `tools/list`:

- `list_sites`
- `get_site_status`
- `get_install_instructions`
- `verify_tracking`
- `get_connect_link`
- `update_pixel`
- `update_integration`
- `disconnect_integration`
- `create_site`
- `update_site`
- `get_overview`
- `get_attribution`
- `get_journeys`
- `list_events`
- `get_event_payloads`
- `get_blocked_events`
- `list_triggers`
- `suggest_triggers`
- `check_selector`
- `list_recent_changes`
- `create_trigger`
- `update_trigger`
- `delete_trigger`
- `upsert_blocking_rule`
- `delete_blocking_rule`
- `close_get_started`
- `ensure_webflow_ecommerce_triggers`
