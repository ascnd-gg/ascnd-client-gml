/// ============================================================================
/// ASCND SDK EXAMPLE USAGE
/// ============================================================================
/// This file demonstrates how to integrate the Ascnd leaderboard SDK into
/// your GameMaker game. Copy the relevant code sections into your project.
/// ============================================================================

// ============================================================================
// STEP 1: Create a persistent controller object (e.g., obj_game_controller)
// ============================================================================

/// ----- CREATE EVENT -----
// Initialize the Ascnd SDK with your API key
// Get your API key from https://app.ascnd.gg
ascnd_init("your_api_key_here");

// Optional: Store your leaderboard ID for easy access
global.leaderboard_id = "lb_your_leaderboard_id";

// Optional: Generate or retrieve a player ID
// Option A: Use device ID (simple, no backend needed)
global.player_id = device_get_id();

// Option B: Use your own user system
// global.player_id = user_account_id;


/// ----- ASYNC - HTTP EVENT -----
// IMPORTANT: This is required to handle API responses!
ascnd_async_http();


/// ----- GAME END EVENT or CLEANUP EVENT -----
// Clean up SDK resources
ascnd_cleanup();


// ============================================================================
// STEP 2: Submit scores (e.g., when player finishes a level)
// ============================================================================

/// Example: Submit score after game over
function submit_player_score(score) {
    ascnd_submit_score(global.leaderboard_id, global.player_id, score, {
        on_success: function(response) {
            show_debug_message("Score submitted!");
            show_debug_message("New rank: #" + string(response.rank));

            if (response.is_new_best) {
                show_debug_message("New personal best!");
            }
        },
        on_error: function(error) {
            show_debug_message("Failed to submit score: " + error.message);

            // Handle specific errors
            if (error.http_status == 429) {
                show_debug_message("Rate limited - try again later");
            }
        }
    });
}

/// Example: Submit score with metadata
function submit_score_with_metadata(score, level_name, time_taken) {
    ascnd_submit_score(global.leaderboard_id, global.player_id, score, {
        on_success: function(response) {
            show_debug_message("Score submitted with metadata!");
        },
        on_error: function(error) {
            show_debug_message("Error: " + error.message);
        }
    }, {
        // Custom metadata attached to the score
        level: level_name,
        time_seconds: time_taken,
        character: global.selected_character
    });
}

/// Example: Submit with idempotency key (prevents duplicate submissions)
function submit_score_safe(score, game_session_id) {
    ascnd_submit_score(global.leaderboard_id, global.player_id, score, {
        on_success: function(response) {
            if (response.was_deduplicated) {
                show_debug_message("Score already submitted (duplicate)");
            } else {
                show_debug_message("Score submitted! Rank: #" + string(response.rank));
            }
        },
        on_error: function(error) {
            show_debug_message("Error: " + error.message);
        }
    }, undefined, game_session_id); // Use session ID as idempotency key
}


// ============================================================================
// STEP 3: Display leaderboards
// ============================================================================

/// Example: Fetch and display top 10
function fetch_leaderboard() {
    ascnd_get_leaderboard(global.leaderboard_id, {
        on_success: function(response) {
            // Store entries for display
            global.leaderboard_entries = response.entries;
            global.leaderboard_has_more = response.has_more;
            global.leaderboard_total = response.total_entries;

            show_debug_message("Loaded " + string(array_length(response.entries)) + " entries");
            show_debug_message("Total players: " + string(response.total_entries));

            // Display in console
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
            show_debug_message("Failed to load leaderboard: " + error.message);
        }
    }, 10); // Get top 10
}

/// Example: Fetch with pagination
function fetch_leaderboard_page(page_number) {
    var entries_per_page = 10;
    var offset = page_number * entries_per_page;

    ascnd_get_leaderboard(global.leaderboard_id, {
        on_success: function(response) {
            global.leaderboard_entries = response.entries;
            show_debug_message("Page loaded with " + string(array_length(response.entries)) + " entries");
        },
        on_error: function(error) {
            show_debug_message("Error: " + error.message);
        }
    }, entries_per_page, offset);
}

/// Example: Fetch previous period (e.g., last week's scores)
function fetch_previous_leaderboard() {
    ascnd_get_leaderboard(global.leaderboard_id, {
        on_success: function(response) {
            show_debug_message("Previous period: " + response.period_start + " to " + response.period_end);
            global.previous_leaderboard_entries = response.entries;
        },
        on_error: function(error) {
            show_debug_message("Error: " + error.message);
        }
    }, 10, 0, "previous");
}


// ============================================================================
// STEP 4: Show player's rank
// ============================================================================

/// Example: Get current player's rank
function fetch_my_rank() {
    ascnd_get_player_rank(global.leaderboard_id, global.player_id, {
        on_success: function(response) {
            if (response.rank != undefined) {
                show_debug_message("Your rank: #" + string(response.rank));
                show_debug_message("Your score: " + string(response.score));
                show_debug_message("Your best: " + string(response.best_score));
                show_debug_message("You're in the " + response.percentile);

                // Store for display
                global.my_rank = response.rank;
                global.my_score = response.score;
                global.my_percentile = response.percentile;
            } else {
                show_debug_message("You haven't submitted a score yet!");
                global.my_rank = undefined;
            }
        },
        on_error: function(error) {
            show_debug_message("Error: " + error.message);
        }
    });
}


// ============================================================================
// STEP 5: Draw the leaderboard (in Draw event)
// ============================================================================

/// Example Draw Event code for displaying leaderboard
function draw_leaderboard() {
    if (!variable_global_exists("leaderboard_entries")) return;

    draw_set_font(fnt_leaderboard); // Use your font
    draw_set_color(c_white);
    draw_set_halign(fa_left);

    var start_x = 100;
    var start_y = 100;
    var line_height = 30;

    // Draw header
    draw_text(start_x, start_y, "LEADERBOARD");
    start_y += line_height * 1.5;

    // Draw entries
    for (var i = 0; i < array_length(global.leaderboard_entries); i++) {
        var entry = global.leaderboard_entries[i];
        var y_pos = start_y + (i * line_height);

        // Highlight current player
        if (entry.player_id == global.player_id) {
            draw_set_color(c_yellow);
        } else {
            draw_set_color(c_white);
        }

        // Draw rank
        draw_text(start_x, y_pos, "#" + string(entry.rank));

        // Draw player name (you might map player_id to display names)
        draw_text(start_x + 60, y_pos, entry.player_id);

        // Draw score
        draw_set_halign(fa_right);
        draw_text(start_x + 400, y_pos, string(entry.score));
        draw_set_halign(fa_left);
    }

    // Reset color
    draw_set_color(c_white);
}
