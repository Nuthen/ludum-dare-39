local Turret = Class('Turret')

function Turret:initialize(game, x, y)
    self.game = game
    self.x = x
    self.y = y

    self.animationName = 'idle'
    self.image = Turret.images.idle
    self.animation = Turret.animations.idle:clone()
end

function Turret:update(dt)
    self.animation:update(dt)
end

function Turret:draw()
    local game = self.game
    local x, y = game:gridToScreen(self.x, self.y)
    local offset = Turret.animationOffsets[self.animationName]
    x = x + offset.x
    y = y - self.image:getHeight() + offset.y

    self.animation:draw(self.image, x, y)
end

return Turret
