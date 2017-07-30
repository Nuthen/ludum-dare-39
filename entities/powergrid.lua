local PowerGrid = Class('PowerGrid')

function PowerGrid:initialize(game, x, y)
    self.game = game
    self.x = x
    self.y = y

    self.animationName = 'idle'
    self.image = PowerGrid.images.idle
    self.animation = PowerGrid.animations.idle:clone()

    self.activated = false
end

function PowerGrid:activate()
    local game = self.game
    if not self.activated then
        game.totalPoweredRooms = game.totalPoweredRooms + 10
        self.activated = true
    end
end

function PowerGrid:update(dt)
    self.animation:update(dt)
end

function PowerGrid:draw()
    local game = self.game
    local x, y = game:gridToScreen(self.x, self.y)
    local offset = PowerGrid.animationOffsets[self.animationName]
    x = x + offset.x
    y = y - self.image:getHeight() + offset.y

    self.animation:draw(self.image, x, y)
end

return PowerGrid
