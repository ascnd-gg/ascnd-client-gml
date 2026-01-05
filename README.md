# Ascnd GameMaker SDK

> [!WARNING]
> This project is experimental and under active development. Expect bugs, breaking changes, and incomplete features. Please report issues via the [issue tracker](../../issues).

Official GameMaker SDK for [Ascnd](https://ascnd.gg) - the leaderboard API for game developers.

## Features

- Submit scores to leaderboards
- Retrieve leaderboard rankings
- Get player-specific rank and stats
- Works on **all platforms** (Windows, Mac, Linux, HTML5, iOS, Android, consoles)
- Zero dependencies - uses native GameMaker HTTP functions

## Installation

### From GameMaker Marketplace

1. Search for "Ascnd" in the GameMaker Marketplace
2. Click "Add to Account" then import into your project

### Manual Installation

1. Download the latest `.yymps` from [Releases](https://github.com/ascnd-gg/ascnd-client-gml/releases)
2. In GameMaker, go to **Tools > Import Local Package**
3. Select the downloaded file and import all assets

## Quick Start

### 1. Initialize the SDK

In your game's initialization code (e.g., a persistent controller object's Create event):

```gml
// Initialize with your API key from https://app.ascnd.gg
ascnd_init("your_api_key_here");
```

### 2. Handle Async Responses

In your **Async - HTTP** event:

```gml
ascnd_async_http();
```

### 3. Submit a Score

```gml
ascnd_submit_score("lb_your_leaderboard_id", "player_123", 5000, {
    on_success: function(response) {
        show_debug_message("Score submitted! New rank: " + string(response.rank));
    },
    on_error: function(error) {
        show_debug_message("Error: " + error.message);
    }
});
```

### 4. Get Leaderboard

```gml
ascnd_get_leaderboard("lb_your_leaderboard_id", {
    on_success: function(response) {
        for (var i = 0; i < array_length(response.entries); i++) {
            var entry = response.entries[i];
            show_debug_message(
                "#" + string(entry.rank) + " " +
                entry.player_id + ": " +
                string(entry.score)
            );
        }
    },
    on_error: function(error) {
        show_debug_message("Error: " + error.message);
    }
}, 10); // Get top 10
```

### 5. Get Player Rank

```gml
ascnd_get_player_rank("lb_your_leaderboard_id", "player_123", {
    on_success: function(response) {
        if (response.rank != undefined) {
            show_debug_message("Your rank: #" + string(response.rank));
            show_debug_message("Your score: " + string(response.score));
            show_debug_message("Percentile: " + response.percentile);
        } else {
            show_debug_message("Player not on leaderboard yet");
        }
    },
    on_error: function(error) {
        show_debug_message("Error: " + error.message);
    }
});
```

## API Reference

### ascnd_init(api_key, [base_url])

Initialize the SDK. Call this once at game start.

| Parameter | Type | Description |
|-----------|------|-------------|
| `api_key` | string | Your API key from the Ascnd dashboard |
| `base_url` | string | (Optional) Custom API URL. Default: `https://api.ascnd.gg` |

### ascnd_submit_score(leaderboard_id, player_id, score, [callbacks], [metadata], [idempotency_key])

Submit a score to a leaderboard.

| Parameter | Type | Description |
|-----------|------|-------------|
| `leaderboard_id` | string | The leaderboard ID |
| `player_id` | string | Unique player identifier |
| `score` | real | The score value |
| `callbacks` | struct | (Optional) `{ on_success, on_error }` functions |
| `metadata` | struct | (Optional) Custom data to attach to the score |
| `idempotency_key` | string | (Optional) Prevents duplicate submissions |

**Success Response:**
```gml
{
    score_id: "sc_abc123",
    rank: 42,
    is_new_best: true,
    was_deduplicated: false
}
```

### ascnd_get_leaderboard(leaderboard_id, [callbacks], [limit], [offset], [period], [view_slug])

Get leaderboard entries.

| Parameter | Type | Description |
|-----------|------|-------------|
| `leaderboard_id` | string | The leaderboard ID |
| `callbacks` | struct | (Optional) `{ on_success, on_error }` functions |
| `limit` | real | (Optional) Max entries to return (1-100). Default: 10 |
| `offset` | real | (Optional) Pagination offset. Default: 0 |
| `period` | string | (Optional) `"current"`, `"previous"`, or ISO 8601 timestamp |
| `view_slug` | string | (Optional) Filter by metadata view |

**Success Response:**
```gml
{
    entries: [
        { rank: 1, player_id: "player_1", score: 10000, submitted_at: "2024-01-15T...", metadata: {...} },
        { rank: 2, player_id: "player_2", score: 9500, submitted_at: "2024-01-15T...", metadata: {...} }
    ],
    total_entries: 1500,
    has_more: true,
    period_start: "2024-01-01T00:00:00Z",
    period_end: "2024-02-01T00:00:00Z"
}
```

### ascnd_get_player_rank(leaderboard_id, player_id, [callbacks], [period], [view_slug])

Get a specific player's rank.

| Parameter | Type | Description |
|-----------|------|-------------|
| `leaderboard_id` | string | The leaderboard ID |
| `player_id` | string | The player's identifier |
| `callbacks` | struct | (Optional) `{ on_success, on_error }` functions |
| `period` | string | (Optional) `"current"`, `"previous"`, or ISO 8601 timestamp |
| `view_slug` | string | (Optional) Filter by metadata view |

**Success Response:**
```gml
{
    rank: 42,
    score: 5000,
    best_score: 5500,
    total_entries: 1500,
    percentile: "top 3%"
}
```

### ascnd_async_http()

Process Ascnd API responses. **Call this in your Async - HTTP event.**

Returns `true` if the event was an Ascnd response, `false` otherwise.

### ascnd_cleanup()

Clean up SDK resources. Call when your game ends or when you no longer need the SDK.

## Metadata

You can attach custom metadata to scores:

```gml
ascnd_submit_score("lb_racing", "player_123", 95000, {
    on_success: function(r) { /* ... */ }
}, {
    // Custom metadata
    car: "sports_car",
    track: "mountain_pass",
    difficulty: "hard"
});
```

Metadata is returned when fetching leaderboards, already decoded as a struct.

## Error Handling

Error callbacks receive a struct with:

| Field | Type | Description |
|-------|------|-------------|
| `http_status` | real | HTTP status code (0 for network errors) |
| `message` | string | Human-readable error message |
| `code` | string | (Optional) Error code like `"invalid_argument"` |
| `raw` | string | Raw response body |

Common errors:

| HTTP Status | Code | Description |
|-------------|------|-------------|
| 400 | `invalid_argument` | Missing or invalid parameters |
| 401 | `unauthenticated` | Invalid API key |
| 403 | `permission_denied` | API key lacks required scope |
| 404 | `not_found` | Leaderboard not found |
| 429 | `resource_exhausted` | Rate limit exceeded |

## Player Identification

The `player_id` is your responsibility to generate and maintain. Options:

1. **User accounts** - Use your backend's user ID
2. **Device ID** - Use `device_get_id()` for casual games
3. **Platform ID** - Steam ID, Game Center ID, etc.

## Best Practices

1. **Initialize early** - Call `ascnd_init()` in a persistent object's Create event
2. **Handle errors gracefully** - Always provide `on_error` callbacks
3. **Cache leaderboard data** - Don't fetch on every frame
4. **Use idempotency keys** - Prevent duplicate score submissions
5. **Clean up** - Call `ascnd_cleanup()` in your game end event

## Example Project

See the `examples/` folder for a complete working example.

## Support

- [Documentation](https://docs.ascnd.gg)
- [Discord](https://discord.gg/ascnd)
- [GitHub Issues](https://github.com/ascnd-gg/ascnd-client-gml/issues)

## License

MIT License - see [LICENSE](LICENSE) for details.
