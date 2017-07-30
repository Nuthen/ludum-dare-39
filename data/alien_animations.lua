-- Animation table format:
--
-- (!) Animation name should match catalog name
-- (!) Include comma at the end of the line inside brackets
-- (*) Order does not matter
-- animation_name = {
--
--     -- Size of animation frames:
--
--     frameWidth = number,
--     frameHeight = number,
--
--     -- Offset of origin:
--
--     left = number (optional),
--     top = number (optional),
--
--     -- Border around each frame:
--
--     border = number (optional),
--
--     -- Frames:
--
--     frames = array of strings or numbers,
--
--     -- Frames examples:
--
--     frames = {2,                 1}
--               ^-- column (x)     ^-- row (y)
--
--     frames = {1, 1, 2, 1, 3, 1}      -- First 3 frames from row 1
--
--     -- Column and row can be a range like '1-4'
--
--     frames = {'1-3', 1}              -- First 3 frames from row 1
--     frames = {'1-3', 1, '5-1', 2}    -- First 3 frames from row 1, then first 5 frames from row 2 in reverse order
--
--     -- Duration of frames:
--
--     durations = number OR array OR hash,
--
--     -- Duration examples:
--
--     durations = 0.1,                 -- 0.3s per frame
--     durations = {0.1, 0.5, 0.1},     -- 0.1s for first frame, 0.5s for second, etc. Must specify all frames.
--
--     -- 0.1s for first four frames, 0.2s for fifth through seventh frame. Must specify all frames.
--     durations = {
--         ['1-4'] = 0.1,
--         ['5-7'] = 0.2,
--     },
--
--     -- Animation offsets (adjusts drawn position)
--
--     offsets = {
--         x = number,
--         y = number,
--     },
--
-- }, <----- (!) Include comma here

return {
    small_idle = {
        frameWidth = 32,
        frameHeight = 32,

        durations = 0.15,

        frames = {'1-4', 1},

        offsets = {
            x = 0,
            y = 20,
        },
    },

    medium_idle = {
        frameWidth = 32,
        frameHeight = 64,

        durations = 0.15,

        frames = {'1-4', 1},

        offsets = {
            x = 0,
            y = 28,
        },
    },

    large_idle = {
        frameWidth = 64,
        frameHeight = 64,

        durations = 0.15,

        frames = {'1-4', 1},

        offsets = {
            x = -16,
            y = 24,
        },
    },
}
