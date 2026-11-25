# PixelFlow for Claude

Server-side conversion tracking for Meta, TikTok, etc. The plugin connects Claude to the PixelFlow MCP server at https://api.pixelflow.so/mcp and adds three skills: set up tracking, audit tracking, and a weekly report.

After installing, sign in with your normal PixelFlow login and click Allow. No token is pasted.

## Website visitors, notice and consent

PixelFlow records events, such as page views, form submissions and purchases, from visitors to websites the customer owns or manages, and sends them to the ad platforms the customer connects. It does not record the person using Claude, and it does not read Claude conversations.

Website visitors must be told about this tracking. The PixelFlow Terms (https://pixelflow.so/terms) make the site owner responsible for giving visitors all required privacy notices and obtaining any required consent before tracking starts.

Consent mode is on by default. It follows the site's consent banner, Google Consent Mode and Global Privacy Control. When a visitor denies consent, their events are not sent to ad platforms. A site owner who turns Consent mode off is still bound by these obligations.

Visitor email, phone, name and IP address are returned to Claude only as hashes. Every category of data the tools return, and how long it is kept, is listed in section 9 of https://pixelflow.so/privacy.

Documentation and tool reference: https://github.com/PixelFlow-org/mcp
