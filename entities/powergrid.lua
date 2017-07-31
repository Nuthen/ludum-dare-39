local PowerGrid = Class('PowerGrid')

function PowerGrid:initialize(game, x, y, roomHash)
    self.game = game
    self.x = x
    self.y = y
    self.screenX = 0
    self.screenY = 0
    self.hitboxX = 0
    self.hitboxY = 32
    self.hitboxWidth = 64
    self.hitboxHeight = 48

    self.animationName = 'offline'
    self.image = PowerGrid.images.offline
    self.animation = PowerGrid.animations.offline:clone()

    self.glowImage = love.graphics.newImage('assets/images/Glow.png')

    self.roomHash = roomHash or 0
    self.activated = false
    self.powered = false

    self.flashTimer = 0

    self.timer = Timer.new()

    self.charge = 0
    self.chargePerSecond = TWEAK.powergrid_charge_per_second
    self.maxCharge = TWEAK.powergrid_charge_required
end

function PowerGrid:activate()
    local game = self.game
    if not self.activated then
        self.activated = true

        game.power = game.power * (1 - TWEAK.powergrid_cost_to_activate)

        self.timer:every(1, function()
            self.charge = self.charge + self.chargePerSecond
        end)

        self.animationName = 'online'
        self.image = PowerGrid.images.online
        self.animation = PowerGrid.animations.online:clone()

        Signal.emit('powerGridActivate')
    end
end

function PowerGrid:update(dt)
    self.animation:update(dt)
    self.timer:update(dt)

    if self.charge >= self.maxCharge then
        self.charge = self.maxCharge

        if not self.powered then
            self.powered = true
            Signal.emit('powerGridPowered')
        end
    end

    self.flashTimer = self.flashTimer + dt
end

function PowerGrid:draw(isHovered)
    local game = self.game
    local x, y = game:gridToScreen(self.x, self.y)
    local offset = PowerGrid.animationOffsets[self.animationName]
    x = x + offset.x
    y = y - self.image:getHeight() + offset.y

    self.screenX, self.screenY = x, y

    local colorIncrease = 0

    if not self.activated then
        colorIncrease = colorIncrease + (math.sin(self.flashTimer/2)+1)/2 * 100
        if isHovered then
            colorIncrease = colorIncrease + 100
        end
    end

    love.graphics.setColor(255+colorIncrease, 255+colorIncrease, 255+colorIncrease)
    self.animation:draw(self.image, x, y)

    local charge = Lume.round((self.charge / self.maxCharge) * 100, 1)
    love.graphics.print(charge..'%', x, y)

    if not self.activated then
        local scale = (math.sin(self.flashTimer)+1)/2 + 1
        love.graphics.setColor(255, 0, 0)
        love.graphics.draw(self.glowImage, x + self.image:getWidth()/2, y + self.image:getHeight() - 32, math.rad(45), scale, scale, self.glowImage:getWidth()/2, self.glowImage:getHeight()/2)
    end
end

return PowerGrid
