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

    self.canShoot = true
    self.reloadTime = TWEAK.turretReloadTime

    self.timer = Timer.new()
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
    end
end

function Turret:update(dt)
    local game = self.game
    self.alreadyDrawn = false
    self.animation:update(dt)

    self.timer:update(dt)

    if self.activated then
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
    if not self.alreadyDrawn then
        local x, y = game:gridToScreen(self.x, self.y)
        local offset = Turret.animationOffsets[self.animationName]
        x = x + offset.x
        y = y - self.image:getHeight() + offset.y

        x = x + self.offset.x
        y = y + self.offset.y

        self.screenX = x
        self.screenY = y
        if self.flip then
            love.graphics.push()
            love.graphics.scale(-1, 1)
            self.animation:draw(self.image, x, y)
            love.graphics.pop()
        else
            self.animation:draw(self.image, x, y)
        end
        self.alreadyDrawn = true
    end
end

return Turret
