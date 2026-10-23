PixelFlow is server-side conversion tracking for Meta and TikTok. No tag manager, and no developer needed.

The MCP server lets your AI agent do two things from the chat:

1. Set up conversion tracking. The agent walks you through the install, connects Meta or TikTok, and creates the triggers for the actions you want to track, such as a form submission, a booked call, or a purchase. You approve the changes.
2. Answer questions about your tracking and your data. PixelFlow returns the events themselves, so the agent can answer what you ask and build the report in the chat. What was attributed revenue last week? Which campaigns drove purchases? Why is Meta showing more leads than PixelFlow?

The server URL is https://api.pixelflow.so/mcp.

The client opens the PixelFlow login and the customer clicks Allow. No token is pasted.

## Reads, edits, and never touches

| | |
| --- | --- |
| Reads | Events, attribution, journeys, and site status. Reads do not need approval. |
| Edits | Creating, editing, or deleting a trigger, a blocking rule, a site field, a pixel label, or an integration. Show the change and wait for one approval. |
| Never touches | The customer's ad account. The server does not change campaigns, budgets, or ads. |
| Never touches | The customer's website. The server does not edit it. A coding agent that already has the repo may place the snippet the install tool returned. |
| Never touches | Tokens, keys, and passwords. They are not returned and must not be typed into the chat. |
| Never touches | A visitor's raw email, phone, or name. Hashed values stay hashed. IP stays masked unless the customer asks for the full value. |
| Never touches | Deleting a Site or a Pixel. Those tools do not exist. |

<!-- tools:start -->
`list_sites`: List sites. Reads.
`get_site_status`: Get site status. Reads.
`get_install_instructions`: Get install instructions. Reads.
`verify_tracking`: Verify tracking. Loads the customer's site.
`get_connect_link`: Get connect link. Edits.
`update_pixel`: Update pixel. Edits.
`update_integration`: Update integration. Edits.
`disconnect_integration`: Disconnect integration. Deletes.
`create_site`: Create site. Edits.
`update_site`: Update site. Edits.
`get_overview`: Get overview. Reads.
`get_attribution`: Get attribution. Reads.
`get_journeys`: Get journeys. Reads.
`list_events`: List events. Reads.
`get_event_payloads`: Get event payloads. Reads.
`get_blocked_events`: Get blocked events. Reads.
`list_triggers`: List triggers. Reads.
`suggest_triggers`: Suggest triggers. Reads.
`check_selector`: Check selector. Loads the customer's site.
`list_recent_changes`: List recent changes. Reads.
`create_trigger`: Create trigger. Edits.
`update_trigger`: Update trigger. Edits.
`delete_trigger`: Delete trigger. Deletes.
`upsert_blocking_rule`: Save blocking rule. Edits.
`delete_blocking_rule`: Delete blocking rule. Deletes.
`close_get_started`: Close get started. Edits.
`ensure_webflow_ecommerce_triggers`: Ensure Webflow ecommerce triggers. Edits.
<!-- tools:end -->

## Claude

Guide: https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp

Connect:

1. In Claude, click Customize, then Connectors, then Add, then Add custom connector.
2. Type PixelFlow in the Name field.
3. Copy and paste https://api.pixelflow.so/mcp into the MCP server URL field.
4. Click Continue, then Add.
5. Click Connect, then Continue Connecting. Sign in with your normal PixelFlow login if asked, then click Allow.

Start:

1. Open a new chat in Claude.
2. Copy and paste the setup prompt from https://pixelflow.so/features/mcp into the chat, then send it. Claude has no / menu for prompts, so the pasted prompt is what starts setup.

Custom connectors work on every Claude plan (free plans are limited to one). On Team and Enterprise plans an owner adds the connector first, under Organization settings, then Connectors.

## Claude Code

Guide: https://code.claude.com/docs/en/mcp

Connect:

1. Open a terminal. Do not run this inside a Claude Code chat.
2. Run:

```
claude mcp add --transport http --scope user pixelflow https://api.pixelflow.so/mcp
```

3. Start Claude Code, run /mcp, and choose PixelFlow.
4. Choose Authenticate. Sign in with your normal PixelFlow login in the browser that opens, then click Allow.

Start:

1. In Claude Code, type / and pick setup_tracking, then send it. That menu item already selects PixelFlow, so you do not need to name it.
2. If setup_tracking is not in the menu, paste the setup prompt from https://pixelflow.so/features/mcp into the chat.

## ChatGPT

Guide: https://developers.openai.com/api/docs/mcp

Connect:

1. In ChatGPT, click Plugins in the left sidebar, then Add, then Add custom MCP server.
2. Type PixelFlow in the Name field.
3. Copy and paste https://api.pixelflow.so/mcp into the Connection, Server URL field.
4. Tick I understand and want to continue, then click Create as a plugin.
5. Click Continue to PixelFlow. Sign in with your normal PixelFlow login if asked, then click Allow.
6. In Plugins, search for PixelFlow and open it. Click the Manage icon, then the Permission row, and select Allow all tools.

Start:

1. Open a new chat in ChatGPT.
2. Paste the setup prompt from https://pixelflow.so/features/mcp into the chat, then send it.

## Codex

Connect:

1. Open https://chatgpt.com/plugins, then click Add, then Add custom MCP server.
2. Type PixelFlow in the Name field.
3. Copy and paste https://api.pixelflow.so/mcp into the Connection, Server URL field.
4. Tick I understand and want to continue, then click Create as a plugin.
5. Click Continue to PixelFlow. Sign in with your normal PixelFlow login if asked, then click Allow.
6. In Plugins, search for PixelFlow and open it. Click the Manage icon, then the Permission row, and select Allow all tools.

Start:

1. Open a new chat in Codex.
2. Paste the setup prompt from https://pixelflow.so/features/mcp into the chat, then send it.

## Cursor

Guide: https://cursor.com/docs/mcp

Connect:

1. In Cursor, click the gear icon at the top right, then Customize.
2. Click MCPs, then New MCP Server, then User.
3. If mcp.json already has a server, add a comma after it. Then paste the block below inside mcpServers and save the file.

```
"pixelflow": {
  "url": "https://api.pixelflow.so/mcp"
}
```

4. Go back to MCPs and click Authenticate next to PixelFlow. Sign in with your normal PixelFlow login in the browser that opens, then click Allow. If Authenticate is not listed, reload Cursor.

Start:

1. Open a new agent chat, type / and pick setup_tracking, then send the message. That menu item already selects PixelFlow, so you do not need to name it.
2. If setup_tracking is still missing from the menu, paste the setup prompt from https://pixelflow.so/features/mcp into the chat and send it.

## Codex CLI

Connect:

1. Open a terminal.
2. Run:

```
codex mcp add pixelflow --url https://api.pixelflow.so/mcp
```

3. Sign in with your normal PixelFlow login in the browser that opens, then click Allow.

Start:

1. Open a new Codex CLI chat.
2. Paste the setup prompt from https://pixelflow.so/features/mcp into the chat, then send it.

## Lovable

Guide: https://docs.lovable.dev/integrations/custom-mcp

Connect:

1. In Lovable, open Connectors, click the + button at the top right of the catalog, then MCP server.
2. Name the server PixelFlow and paste https://api.pixelflow.so/mcp as the Server URL.
3. Leave authentication on OAuth and click Add & authorize, then approve access and pick the workspace to connect.

Start:

1. Open your project chat. PixelFlow now appears under your chat connectors.
2. Paste the setup prompt from https://pixelflow.so/features/mcp into the chat, then send it.

Chat connectors are personal to you and are not part of your published app. If MCP server is greyed out, a workspace admin has turned custom servers off.

## Other MCP clients

Connect:

1. Add a remote MCP server in your client. Most ask for a name and a URL. Any tool that can add a remote MCP server uses the same address.
2. Name it PixelFlow and use https://api.pixelflow.so/mcp. Streamable HTTP is the transport.
3. When the client opens a PixelFlow sign-in, use your normal PixelFlow login, then click Allow.

Start:

1. Open a new chat and paste the setup prompt from https://pixelflow.so/features/mcp, then send it.

Works with Gemini CLI, VS Code, Windsurf, Zed and anything else that speaks MCP over HTTP.

PixelFlow never asks you to paste a token, a key or a password: you sign in with your normal login and click Allow. Once connected, the tool shows under AI tools in your PixelFlow dashboard, where you can connect another tool or disconnect this one. You stay signed in while you use it; after 30 days unused it asks you to sign in again. Prefer guided steps? Click AI Tools in the dashboard, or Set up with AI at the start of site setup.

## Prompts

`setup_tracking`: Create or update a Site, return the snippet or the plugin steps, connect an Ad Platform, verify, and set up the conversions to track, including the duplicate-tracking message.

`audit_tracking`: Health check of a running Site. Findings are ordered by revenue impact, and each one includes its fix.

`weekly_report`: Last 7 days against the 7 days before: Overview numbers, attributed revenue, blocked events, and whether tracking is still healthy.

The pasteable setup prompt is on https://pixelflow.so/features/mcp.
