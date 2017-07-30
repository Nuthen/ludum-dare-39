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
end

function Enemy:evolve()
    self.stage = self.stage + 1

    if self.stage > self.maxStages then
        self.stage = self.maxStages
    end

    self.animationName = self.animationStages[self.stage].name
    self.image = self.animationStages[self.stage].image
    self.animation = self.animationStages[self.stage].animation:clone()
end

function Enemy:update(dt)
    self.animation:update(dt)
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
