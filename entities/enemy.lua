local Enemy = Class('Enemy')

function Enemy:initialize(game, x, y)
    self.game = game
    self.x = x
    self.y = y
    self.stage = 1
    self.stages = {
        SMALL = 1,
        MEDIUM = 2,
        LARGE = 3,
    }
    self.maxStages = 3

    self.animationStages = {
        [self.stages.SMALL] = {
            name = 'small_idle',
            image = Enemy.images.small_idle,
            animation = Enemy.animations.small_idle,
        },
        [self.stages.MEDIUM] = {
            name = 'medium_idle',
            image = Enemy.images.medium_idle,
            animation = Enemy.animations.medium_idle,
        },
        [self.stages.LARGE] = {
            name = 'large_idle',
            image = Enemy.images.large_idle,
            animation = Enemy.animations.large_idle,
        },
    }
    self.animationName = self.animationStages[self.stage].name
    self.image = self.animationStages[self.stage].image
    self.animation = self.animationStages[self.stage].animation:clone()

    -- I think these need to be integers
    self.evolveTimes = {
        [self.stages.SMALL]  = Vector(TWEAK.enemyStage1MinEvolveTime, TWEAK.enemyStage1MaxEvolveTime),
        [self.stages.MEDIUM] = Vector(TWEAK.enemyStage2MinEvolveTime, TWEAK.enemyStage2MaxEvolveTime),
    }

    self.clickCount = {
        [self.stages.SMALL]  = TWEAK.enemyStage1Health,
        [self.stages.MEDIUM] = TWEAK.enemyStage2Health,
        [self.stages.LARGE]  = TWEAK.enemyStage3Health,
    }

    self.spawnTimes = {
        [self.stages.SMALL]  = Vector(0, 0),
        [self.stages.MEDIUM] = Vector(TWEAK.enemy_stage2_spread_min_time, TWEAK.enemy_stage2_spread_max_time),
        [self.stages.LARGE]  = Vector(TWEAK.enemy_stage3_spread_min_time, TWEAK.enemy_stage3_spread_max_time),
    }

    self:setEvolveTime()
    self:setSpawnTime()

    self.clicks = 0

    self.spawnTime = 20
    self.spawnTimer = 0
end

function Enemy:hurt()
    self.clicks = self.clicks + 1
    return self.clicks >= self.clickCount[self.stage]
end

function Enemy:setEvolveTime()
    local evolveTimes = self.evolveTimes[self.stage]
    self.evolveTime = love.math.random(evolveTimes.x, evolveTimes.y)
    self.evolveTimer = 0
end

function Enemy:setSpawnTime()
    local spawnTimes = self.spawnTimes[self.stage]
    self.spawnTime = love.math.random(spawnTimes.x, spawnTimes.y)
    self.spawnTimer = 0
end

function Enemy:evolve()
    self.stage = self.stage + 1

    if self.stage > self.maxStages then
        self.stage = self.maxStages
    end

    self.animationName = self.animationStages[self.stage].name
    self.image = self.animationStages[self.stage].image
    self.animation = self.animationStages[self.stage].animation:clone()

    if self.stage < self.maxStages then
        self:setEvolveTime()
    end
end

function Enemy:update(dt)
    self.animation:update(dt)

    self.evolveTimer = self.evolveTimer + dt
    if self.evolveTimer >= self.evolveTime and self.stage < self.maxStages then
        self:evolve()
    end

    if TWEAK.enemy_spread_min_stage >= 2 then
        self.spawnTimer = self.spawnTimer + dt
        if self.spawnTimer >= self.spawnTime then
            self:setSpawnTime()
            self:spawnEnemy()
        end
    end
end

function Enemy:spawnEnemy()
    local game = self.game
    local x, y = self.x, self.y

    local upX,    upY    = x,     y + 1
    local downX,  downY  = x,     y - 1
    local leftX,  leftY  = x - 1, y
    local rightX, rightY = x + 1, y

    local emptyTiles = {}
    local availableTiles = {}

    if game:isShipTile(upX, upY) then
        table.insert(availableTiles, {x=upX,y=upY})
        if not game:hasEnemy(upX, upY) then
            table.insert(emptyTiles, {x=upX,y=upY})
        end
    end

    if game:isShipTile(downX, downY) then
        table.insert(availableTiles, {x=downX,y=downY})
        if not game:hasEnemy(downX, downY) then
            table.insert(emptyTiles, {x=downX,y=downY})
        end
    end

    if game:isShipTile(leftX, leftY) then
        table.insert(availableTiles, {x=leftX,y=leftY})
        if not game:hasEnemy(leftX, leftY) then
            table.insert(emptyTiles, {x=leftX,y=leftY})
        end
    end

    if game:isShipTile(rightX, rightY) then
        table.insert(availableTiles, {x=rightX,y=rightY})
        if not game:hasEnemy(rightX, rightY) then
            table.insert(emptyTiles, {x=rightX,y=rightY})
        end
    end

    if #emptyTiles > 0 then
        local tile = Lume.randomchoice(emptyTiles)
        game:addEnemy(tile.x, tile.y)
    elseif #availableTiles > 0 then
        local tile = Lume.randomchoice(availableTiles)
        game:addEnemy(tile.x, tile.y)
    end
end

function Enemy:draw()
    local game = self.game
    local sprite
    if self.stage == self.stages.EVOLVED then
        sprite = self.enemyEvolvedSprite
    else
        sprite = self.enemySprite
    end
    local x, y = game:gridToScreen(self.x, self.y)
    local offset = Enemy.animationOffsets[self.animationName]
    x = x + offset.x
    y = y - self.image:getHeight() + offset.y

    self.animation:draw(self.image, x, y)
end

return Enemy
