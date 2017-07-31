local PowerGrid = Class('PowerGrid')

function PowerGrid:initialize(game, x, y, roomHash)
    self.game = game
    self.x = x
    self.y = y

    self.animationName = 'idle'
    self.image = PowerGrid.images.idle
    self.animation = PowerGrid.animations.idle:clone()

    self.roomHash = roomHash or 0
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
    self.alreadyDrawn = false
    self.animation:update(dt)
end

function PowerGrid:draw()
    if not self.alreadyDrawn then
        local game = self.game
        local x, y = game:gridToScreen(self.x, self.y)
        local offset = PowerGrid.animationOffsets[self.animationName]
        x = x + offset.x
        y = y - self.image:getHeight() + offset.y

        self.animation:draw(self.image, x, y)
        self.alreadyDrawn = true
    end
end

return PowerGrid
