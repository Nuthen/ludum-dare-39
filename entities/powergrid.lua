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
    self.chargePerClick = TWEAK.powergrid_charge_per_click
    self.maxCharge = TWEAK.powergrid_charge_required
end

function PowerGrid:activate()
    local game = self.game
    if not self.activated then
        self.activated = true

        game.power = game.power * (1 - TWEAK.powergrid_cost_to_activate)

        self.animationName = 'online'
        self.image = PowerGrid.images.online
        self.animation = PowerGrid.animations.online:clone()

        Signal.emit('powerGridActivate')
    elseif not game.eventManager.firstEnemyDeath then
        self.charge = self.charge + self.chargePerClick

        if self.charge >= self.maxCharge then
            self.charge = self.maxCharge

            if not self.powered then
                self.powered = true
                Signal.emit('powerGridPowered')
            end
        else
            Signal.emit('powerGridCharge')
        end
    end
end

function PowerGrid:update(dt)
    self.animation:update(dt)
    self.timer:update(dt)

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
    else
        if isHovered then
            colorIncrease = 200
        end
    end

    love.graphics.setColor(255+colorIncrease, 255+colorIncrease, 255+colorIncrease)
    self.animation:draw(self.image, x, y)

    if self.activated and not self.powered then
        local charge = Lume.round((self.charge / self.maxCharge) * 100, 1)
        local font = Fonts.pixel[16]
        local text = 'CHARGE: '..charge..'%'
        local tx, ty = x, y
        tx = tx + self.image:getWidth()/2 - font:getWidth(text)/2
        tx = Lume.round(tx)
        ty = Lume.round(ty)
        love.graphics.setFont(font)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(text, tx+1, ty+1)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(text, tx, ty)
    end

    if not self.activated then
        local scale = (math.sin(self.flashTimer)+1)/2 + 1
        love.graphics.setColor(255, 0, 0)
        love.graphics.draw(self.glowImage, x + self.image:getWidth()/2, y + self.image:getHeight() - 32, math.rad(45), scale, scale, self.glowImage:getWidth()/2, self.glowImage:getHeight()/2)
    end
end

return PowerGrid
