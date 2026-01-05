# GameMaker Marketplace Submission Guide

## Prerequisites

1. **YoYo Games Account** - Create one at https://accounts.yoyogames.com
2. **Publisher Account** - Apply at https://marketplace.yoyogames.com/become-a-publisher

## Creating the Package

### Step 1: Create a new GameMaker project

1. Open GameMaker and create a new blank project
2. Name it something like "Ascnd SDK"

### Step 2: Add the Script

1. In the Asset Browser, right-click **Scripts** → **Create Script**
2. Name it `scr_ascnd`
3. Copy the contents of `scripts/scr_ascnd/scr_ascnd.gml` into the script
4. Save the script

### Step 3: Add the Example (Optional but Recommended)

1. Create a new Script called `scr_ascnd_example`
2. Copy the contents of `examples/example_usage.gml`
3. This helps users understand how to use the SDK

### Step 4: Export as Local Package

1. Go to **Tools → Create Local Package**
2. In the dialog:
   - Check `scr_ascnd` (required)
   - Check `scr_ascnd_example` (optional)
3. Click **OK**
4. Fill in package details:
   - **Display Name:** Ascnd Leaderboard SDK
   - **Package ID:** com.ascnd.leaderboard-sdk
   - **Version:** 1.0.0
   - **Author:** Ascnd
   - **Description:** Official SDK for integrating Ascnd leaderboards into your game
5. Click **OK** and save as `ascnd-sdk.yymps`

## Submitting to Marketplace

1. Go to https://marketplace.yoyogames.com/publishers
2. Log in to your publisher account
3. Click **"Add Asset"**
4. Fill in the details:

| Field | Value |
|-------|-------|
| **Asset Type** | Scripts |
| **Name** | Ascnd Leaderboard SDK |
| **Price** | Free |
| **Category** | Networking / Online Services |
| **Description** | *(see below)* |
| **Documentation URL** | https://docs.ascnd.gg |
| **Support URL** | https://github.com/ascnd-gg/ascnd-client-gml/issues |

5. Upload the `.yymps` file
6. Add screenshots showing:
   - Code example of submitting a score
   - Code example of displaying a leaderboard
7. Submit for review

### Suggested Description

```
Official GameMaker SDK for Ascnd - the leaderboard API for game developers.

Features:
• Submit player scores to leaderboards
• Retrieve top scores and rankings
• Get player-specific rank and percentile
• Works on ALL platforms (Windows, Mac, Linux, HTML5, iOS, Android, consoles)
• Zero dependencies - uses native GameMaker HTTP functions
• Async callback support for non-blocking API calls

Quick Start:
1. Call ascnd_init("your_api_key") at game start
2. Add ascnd_async_http() to your Async HTTP event
3. Use ascnd_submit_score(), ascnd_get_leaderboard(), ascnd_get_player_rank()

Get your free API key at https://app.ascnd.gg

Full documentation: https://docs.ascnd.gg
```

## Review Process

- YoYo Games reviews all submissions
- Typically takes **1-2 weeks**
- They may request changes or clarifications
- You'll get an email when approved
- Once approved, it appears on the Marketplace

## Updating the Asset

1. Make changes to the script in your GameMaker project
2. Export a new `.yymps` with bumped version number
3. Go to your Publisher dashboard
4. Find the asset and click **"Update"**
5. Upload the new package
6. Add changelog notes (e.g., "Fixed metadata encoding bug")
7. Submit for review

## Tips

- **Test before submitting** - Make sure the SDK works on at least Windows and HTML5
- **Include examples** - Users love copy-paste code
- **Respond to reviews quickly** - Faster turnaround = faster approval
- **Use clear function names** - All functions are prefixed with `ascnd_` to avoid conflicts
