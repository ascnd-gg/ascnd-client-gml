/// @description Ascnd Leaderboard SDK for GameMaker
/// @author Ascnd (https://ascnd.gg)
/// @version 1.1.0

// ============================================================================
// INITIALIZATION
// ============================================================================

/// @function ascnd_init(api_key, [base_url])
/// @description Initialize the Ascnd SDK with your API key
/// @param {string} api_key Your Ascnd API key from the dashboard
/// @param {string} [base_url] Optional custom API URL (default: https://api.ascnd.gg)
/// @returns {undefined}
function ascnd_init(api_key, base_url = "https://api.ascnd.gg") {
    global.__ascnd_api_key = api_key;
    global.__ascnd_base_url = base_url;
    global.__ascnd_requests = ds_map_create();
    global.__ascnd_initialized = true;
}

/// @function ascnd_cleanup()
/// @description Clean up Ascnd SDK resources. Call this when your game ends.
/// @returns {undefined}
function ascnd_cleanup() {
    if (variable_global_exists("__ascnd_requests") && ds_exists(global.__ascnd_requests, ds_type_map)) {
        ds_map_destroy(global.__ascnd_requests);
    }
    global.__ascnd_initialized = false;
}

// ============================================================================
// CORE API METHODS
// ============================================================================

/// @function ascnd_submit_score(leaderboard_id, player_id, score, [callbacks], [metadata], [idempotency_key])
/// @description Submit a score to a leaderboard
/// @param {string} leaderboard_id The leaderboard ID
/// @param {string} player_id The player's unique identifier
/// @param {real} score The score value
/// @param {struct} [callbacks] Optional struct with on_success and on_error functions
/// @param {struct} [metadata] Optional metadata struct to attach to the score
/// @param {string} [idempotency_key] Optional key to prevent duplicate submissions
/// @returns {real} The request ID for tracking
function ascnd_submit_score(leaderboard_id, player_id, score, callbacks = undefined, metadata = undefined, idempotency_key = undefined) {
    var body = {
        leaderboard_id: leaderboard_id,
        player_id: player_id,
        score: string(score) // Send as string for int64 precision
    };

    if (metadata != undefined) {
        // Encode metadata as base64 JSON
        var meta_json = json_stringify(metadata);
        body.metadata = base64_encode(meta_json);
    }

    if (idempotency_key != undefined) {
        body.idempotency_key = idempotency_key;
    }

    return __ascnd_request("ascnd.v1.AscndService/SubmitScore", body, callbacks);
}

/// @function ascnd_get_leaderboard(leaderboard_id, [callbacks], [limit], [cursor], [period], [view_slug], [around_rank])
/// @description Get leaderboard entries with cursor-based pagination
/// @param {string} leaderboard_id The leaderboard ID
/// @param {struct} [callbacks] Optional struct with on_success and on_error functions
/// @param {real} [limit] Maximum entries to return (1-100, default 10)
/// @param {string} [cursor] Cursor for keyset pagination (from previous response's next_cursor)
/// @param {string} [period] Period filter: "current", "previous", or ISO 8601 timestamp
/// @param {string} [view_slug] Optional view slug for filtered leaderboards
/// @param {real} [around_rank] Jump to a specific rank position (alternative to cursor for random access)
/// @returns {real} The request ID for tracking
function ascnd_get_leaderboard(leaderboard_id, callbacks = undefined, limit = 10, cursor = undefined, period = undefined, view_slug = undefined, around_rank = undefined) {
    var body = {
        leaderboard_id: leaderboard_id,
        limit: limit
    };

    if (cursor != undefined) {
        body.cursor = cursor;
    }

    if (period != undefined) {
        body.period = period;
    }

    if (view_slug != undefined) {
        body.view_slug = view_slug;
    }

    if (around_rank != undefined) {
        body.around_rank = around_rank;
    }

    return __ascnd_request("ascnd.v1.AscndService/GetLeaderboard", body, callbacks);
}

/// @function ascnd_get_player_rank(leaderboard_id, player_id, [callbacks], [period], [view_slug])
/// @description Get a specific player's rank on a leaderboard
/// @param {string} leaderboard_id The leaderboard ID
/// @param {string} player_id The player's unique identifier
/// @param {struct} [callbacks] Optional struct with on_success and on_error functions
/// @param {string} [period] Period filter: "current", "previous", or ISO 8601 timestamp
/// @param {string} [view_slug] Optional view slug for filtered leaderboards
/// @returns {real} The request ID for tracking
function ascnd_get_player_rank(leaderboard_id, player_id, callbacks = undefined, period = undefined, view_slug = undefined) {
    var body = {
        leaderboard_id: leaderboard_id,
        player_id: player_id
    };

    if (period != undefined) {
        body.period = period;
    }

    if (view_slug != undefined) {
        body.view_slug = view_slug;
    }

    return __ascnd_request("ascnd.v1.AscndService/GetPlayerRank", body, callbacks);
}

// ============================================================================
// ASYNC HTTP EVENT HANDLER
// ============================================================================

/// @function ascnd_async_http()
/// @description Call this in your Async HTTP event to process Ascnd responses
/// @returns {bool} True if this was an Ascnd response, false otherwise
function ascnd_async_http() {
    if (!variable_global_exists("__ascnd_requests") || !ds_exists(global.__ascnd_requests, ds_type_map)) {
        return false;
    }

    var request_id = async_load[? "id"];

    // Check if this is one of our requests
    if (!ds_map_exists(global.__ascnd_requests, request_id)) {
        return false;
    }

    var status = async_load[? "status"];

    // Still in progress
    if (status == 1) {
        return true;
    }

    // Get request info
    var request_info = global.__ascnd_requests[? request_id];
    var callbacks = request_info.callbacks;

    // Remove from tracking
    ds_map_delete(global.__ascnd_requests, request_id);

    // Handle completion
    if (status == 0) {
        var http_status = async_load[? "http_status"];
        var result_str = async_load[? "result"];

        if (http_status >= 200 && http_status < 300) {
            // Success
            var result = undefined;
            try {
                result = json_parse(result_str);
            } catch (e) {
                result = { raw: result_str };
            }

            // Decode metadata if present in entries
            result = __ascnd_decode_response_metadata(result);

            if (callbacks != undefined && variable_struct_exists(callbacks, "on_success")) {
                callbacks.on_success(result);
            }
        } else {
            // HTTP error
            var error = {
                http_status: http_status,
                message: "HTTP Error " + string(http_status),
                raw: result_str
            };

            try {
                var err_data = json_parse(result_str);
                if (variable_struct_exists(err_data, "message")) {
                    error.message = err_data.message;
                }
                if (variable_struct_exists(err_data, "code")) {
                    error.code = err_data.code;
                }
            } catch (e) {
                // Keep default error
            }

            if (callbacks != undefined && variable_struct_exists(callbacks, "on_error")) {
                callbacks.on_error(error);
            }
        }
    } else if (status < 0) {
        // Network error
        var error = {
            http_status: 0,
            message: "Network error (status: " + string(status) + ")",
            code: "network_error"
        };

        if (callbacks != undefined && variable_struct_exists(callbacks, "on_error")) {
            callbacks.on_error(error);
        }
    }

    return true;
}

// ============================================================================
// INTERNAL HELPERS
// ============================================================================

/// @function __ascnd_request(endpoint, body, callbacks)
/// @description Internal: Make an HTTP request to the Ascnd API
/// @param {string} endpoint The API endpoint path
/// @param {struct} body The request body
/// @param {struct} callbacks Optional callbacks struct
/// @returns {real} The request ID
function __ascnd_request(endpoint, body, callbacks) {
    if (!variable_global_exists("__ascnd_initialized") || !global.__ascnd_initialized) {
        show_error("Ascnd SDK not initialized. Call ascnd_init() first.", false);
        return -1;
    }

    var url = global.__ascnd_base_url + "/" + endpoint;
    var headers = ds_map_create();
    ds_map_add(headers, "Authorization", "Bearer " + global.__ascnd_api_key);
    ds_map_add(headers, "Content-Type", "application/json");

    var body_str = json_stringify(body);

    var request_id = http_request(url, "POST", headers, body_str);

    ds_map_destroy(headers);

    // Store request info for callback handling
    var request_info = {
        endpoint: endpoint,
        callbacks: callbacks,
        timestamp: current_time
    };
    ds_map_add(global.__ascnd_requests, request_id, request_info);

    return request_id;
}

/// @function __ascnd_decode_response_metadata(response)
/// @description Internal: Decode base64 metadata in response entries
/// @param {struct} response The API response
/// @returns {struct} The response with decoded metadata
function __ascnd_decode_response_metadata(response) {
    if (!is_struct(response)) {
        return response;
    }

    // Handle GetLeaderboard response
    if (variable_struct_exists(response, "entries") && is_array(response.entries)) {
        for (var i = 0; i < array_length(response.entries); i++) {
            var entry = response.entries[i];
            if (variable_struct_exists(entry, "metadata") && is_string(entry.metadata)) {
                try {
                    var decoded = base64_decode(entry.metadata);
                    entry.metadata = json_parse(decoded);
                } catch (e) {
                    // Keep as-is if decoding fails
                }
            }
        }
    }

    return response;
}
