local PowerGrid = Class('PowerGrid')

function PowerGrid:initialize(game, x, y, roomHash)
    self.game = game
    self.x = x
    self.y = y

    self.animationName = 'idle'
    self.image = PowerGrid.images.idle
    self.animation = PowerGrid.animations.idle:clone()

    self.glowImage = love.graphics.newImage('assets/images/Glow.png')

    self.roomHash = roomHash or 0
    self.activated = false

    self.timer = 0
end

function PowerGrid:activate()
    local game = self.game
    if not self.activated then
        game.totalPoweredRooms = game.totalPoweredRooms + 1
        self.activated = true
        Signal.emit('powerGridActivate')
    end
end

function PowerGrid:update(dt)
    self.alreadyDrawn = false
    self.animation:update(dt)

    self.timer = self.timer + dt
end

function PowerGrid:draw()
    if not self.alreadyDrawn then
        local game = self.game
        local x, y = game:gridToScreen(self.x, self.y)
        local offset = PowerGrid.animationOffsets[self.animationName]
        x = x + offset.x
        y = y - self.image:getHeight() + offset.y

        love.graphics.setColor(255, 255, 255)
        self.animation:draw(self.image, x, y)

        if not self.activated then
            local scale = (math.sin(self.timer)+1)/2 + 1
            love.graphics.setColor(255, 0, 0)
            love.graphics.draw(self.glowImage, x + self.image:getWidth()/2, y + self.image:getHeight() - 32, math.rad(45), scale, scale, self.glowImage:getWidth()/2, self.glowImage:getHeight()/2)
        end
        
        self.alreadyDrawn = true
    end
end

return PowerGrid
