local Turret = Class('Turret')

function Turret:initialize(game, x, y, roomHash, offset, flip)
    self.game = game
    self.x = x
    self.y = y
    self.screenX = 0
    self.screenY = 0
    self.hitboxX = 24
    self.hitboxY = 24
    self.hitboxWidth = 36
    self.hitboxHeight = 36
    self.offset = offset or Vector(0, 0)
    self.flip = flip or false

    self.animationName = 'idle'
    self.image = Turret.images.idle
    self.animation = Turret.animations.idle:clone()

    self.roomHash = roomHash or 0

    self.activated = false
    self.powered = false

    self.canShoot = true
    self.reloadTime = TWEAK.turretReloadTime

    self.timer = Timer.new()

    self.charge = 0
    self.chargePerClick = TWEAK.turret_charge_per_click
    self.maxCharge = TWEAK.turret_charge_required
end

function Turret:switchAnimation(name)
    self.animationName = name
    self.image = Turret.images[name]
    self.animation = Turret.animations[name]:clone()
end

function Turret:activate()
    if not self.activated then
        self.activated = true
        Signal.emit('turretActivate')
    else
        if self.game.powerGridRooms[self.roomHash].powered then
            self.charge = self.charge + self.chargePerClick

            if self.charge >= self.maxCharge then
                self.charge = self.maxCharge

                if not self.powered then
                    self.powered = true
                    Signal.emit('turretPowered')
                end
            else
                Signal.emit('turretCharge')
            end
        end
    end
end

function Turret:update(dt)
    local game = self.game
    self.animation:update(dt)

    self.timer:update(dt)

    if self.powered then
        local biggestEvolution = 0
        local targetCandidates = {}
        local tiles = game:getRoomTiles(self.roomHash)
        for i, tile in ipairs(tiles) do
            local enemy = game:getEnemy(tile.x, tile.y)
            if enemy then
                if enemy.stage > biggestEvolution then
                    targetCandidates = {enemy}
                    biggestEvolution = enemy.stage
                else
                    table.insert(targetCandidates, enemy)
                end
            end
        end

        local target = Lume.randomchoice(targetCandidates)
        if target and self.canShoot then
            -- @Hack
            game.mouseAction:clickEnemy(target.x, target.y)

            Signal.emit('turretFire', self.roomHash == game.currentRoom)

            self.canShoot = false
            self:switchAnimation('fire')
            self.animation.onLoop = function()
                self:switchAnimation('idle')
            end
            self.timer:after(self.reloadTime, function()
                self.canShoot = true
            end)
        end
    end
end

function Turret:draw()
    local game = self.game
    local x, y = game:gridToScreen(self.x, self.y)
    local offset = Turret.animationOffsets[self.animationName]
    x = x + offset.x
    y = y - self.image:getHeight() + offset.y

    self.screenX = x
    self.screenY = y

    x = x + self.offset.x
    y = y + self.offset.y

    if self.flip then
        love.graphics.push()
        love.graphics.scale(-1, 1)
        self.animation:draw(self.image, x, y)
        love.graphics.pop()
    else
        self.animation:draw(self.image, x, y)
    end

    local charge = Lume.round((self.charge / self.maxCharge) * 100, 1)
    local font = Fonts.pixel[16]
    local text = charge..'%'
    if not game.powerGridRooms[self.roomHash].powered then
        text = 'NEED POWER'
    end
    local tx, ty = x + 48 - font:getWidth(text)/2, y + 16
    tx = Lume.round(tx)
    ty = Lume.round(ty)
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(text, tx+1, ty+1)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(text, tx, ty)
end

return Turret
