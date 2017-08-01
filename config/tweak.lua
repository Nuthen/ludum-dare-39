-- Using underscores in places where camelCase becomes cumbersome - cmchenry
return {
    enemySpawnRate = 2, -- seconds
    enemy_spawn_rate_increase_per_power_grid = -0.1, -- seconds
    enemy_spawn_rate_increase_per_turret = -0.06, -- seconds

    power = 1,
    powerWarningThreshold = 0.3,

    totalRooms = 7,

    minimapOnGame = true,
    minimapOnDynamo = false,

    powerDropMultiplier = 0,

    power_drop_increase_for_power_grid_activate = 0.009,
    power_drop_increase_for_turret_activate = 0.004,

    power_charged_for_button = .1,
    power_charged_for_flick  = .2,
    power_charged_for_spin   = .4,

    powergrid_charge_per_click = 1,
    powergrid_charge_required = 50,

    turret_charge_per_click = 1,
    turret_charge_required = 30,

    powergrid_cost_to_activate = 0.5, -- percent of power

    turretReloadTime = 2.1,

    backgroundColor = {32, 35, 46},

    drawRoomBoundingBox = false,
    drawCanvasBoundingBox = false,
    drawGridBoundingBox = false,

    drawRoomShadows = false,

    drawTilePositions = false,

    printClickPosition = false,

    drawObjectHitboxes = false,

    -- keep these to ints
    enemyStage1MinEvolveTime = 5,
    enemyStage1MaxEvolveTime = 10,

    enemyStage2MinEvolveTime = 25,
    enemyStage2MaxEvolveTime = 35,

    enemyStage1Health = 1,
    enemyStage2Health = 3,
    enemyStage3Health = 5,

    tutorial_popup_delay = 2,
    tutorial_min_showtime = 0.5,
}
