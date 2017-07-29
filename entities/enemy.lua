local Enemy = Class('Enemy')

function Enemy:initialize(game, x, y)
    self.game = game
    self.x = x
    self.y = y
    self.stage = 1
    self.stages = {
        NORMAL = 1,
        EVOLVED = 2,
    }
    self.maxStages = 2
    self.enemySprite = love.graphics.newImage(game.catalogs.art.enemy)
    self.enemyEvolvedSprite = love.graphics.newImage(game.catalogs.art.enemy_evolved)
end

function Enemy:evolve()
    self.stage = self.stage + 1

    if self.stage > self.maxStages then
        self.stage = self.maxStages
    end
end

function Enemy:update(dt)

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
    love.graphics.draw(sprite, x, y)
end

return Enemy
