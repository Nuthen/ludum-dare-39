-- Using underscores in places where camelCase becomes cumbersome - cmchenry
return {
    enemySpawnRate = 1, -- seconds
    enemy_spawn_rate_increase_per_power_grid = -0.05, -- seconds
    enemy_spawn_rate_increase_per_turret = -0.05, -- seconds

    power = 1,
    powerWarningThreshold = 0.3,

    totalRooms = 7,

    minimapOnGame = true,
    minimapOnDynamo = false,

    powerDropMultiplier = 0,

    power_drop_increase_for_power_grid_activate = 0.01,
    power_drop_increase_for_turret_activate = 0.005,

    power_charged_for_button = .1,
    power_charged_for_flick  = .2,
    power_charged_for_spin   = .4,

    turretReloadTime = 1.5,

    backgroundColor = {32, 35, 46},

    drawRoomBoundingBox = false,
    drawCanvasBoundingBox = false,
    drawGridBoundingBox = false,

    drawRoomShadows = false,

    drawTilePositions = true,

    printClickPosition = false,

    drawObjectHitboxes = false,

    -- keep these to ints
    enemyStage1MinEvolveTime = 5,
    enemyStage1MaxEvolveTime = 10,
    enemyStage2MinEvolveTime = 10,
    enemyStage2MaxEvolveTime = 20,

    enemyStage1Health = 1,
    enemyStage2Health = 3,
    enemyStage3Health = 5,
}
