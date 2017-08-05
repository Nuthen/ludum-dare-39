-- Using underscores in places where camelCase becomes cumbersome - cmchenry
return {
    enemySpawnRate = 1.5, -- seconds
    enemy_spawn_rate_increase_per_power_grid = -0.13, -- seconds
    enemy_spawn_rate_increase_per_turret = -0.06, -- seconds

    power = 1,
    powerWarningThreshold = 0.3,

    totalRooms = 7,

    minimapOnGame = true,
    minimapOnDynamo = false,

    powerDropMultiplier = 0,

    power_drop_increase_for_power_grid_activate = 0.009,
    power_drop_increase_for_turret_activate = 0.004,
    power_drop_increase_during_charge = 0.01,

    power_charged_for_button = .1,
    power_charged_for_flick  = .2,
    power_charged_for_spin   = .4,

    powergrid_charge_per_click = 4,
    powergrid_charge_required = 50,

    turret_charge_per_click = 4,
    turret_charge_required = 30,

    powergrid_cost_to_activate = 0.5, -- percent of power

    turretReloadTime = 2.5,

    backgroundColor = {32, 35, 46},

    drawRoomBoundingBox = false,
    drawCanvasBoundingBox = false,
    drawGridBoundingBox = false,

    drawRoomShadows = false,

    drawTilePositions = false,

    printClickPosition = false,

    drawObjectHitboxes = false,

    -- keep these to ints
    enemyStage1MinEvolveTime = 7,
    enemyStage1MaxEvolveTime = 15,

    enemyStage2MinEvolveTime = 35,
    enemyStage2MaxEvolveTime = 50,

    enemyStage1Health = 1,
    enemyStage2Health = 2,
    enemyStage3Health = 4,

    enemy_spread_min_stage = 2,

    enemy_stage2_spread_min_time = 35,
    enemy_stage2_spread_max_time = 50,

    enemy_stage3_spread_min_time = 25,
    enemy_stage3_spread_max_time = 40,

    tutorial_popup_delay = 2,
    tutorial_min_showtime = 0.5,

    power_meter_warning_flash_rate = 4,
}
