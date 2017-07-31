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

    self:setEvolveTime()

    self.clicks = 0
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
