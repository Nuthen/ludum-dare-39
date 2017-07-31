local Turret = Class('Turret')

function Turret:initialize(game, x, y, roomHash)
    self.game = game
    self.x = x
    self.y = y
    self.screenX = 0
    self.screenY = 0
    self.hitboxX = 0
    self.hitboxY = 0
    self.hitboxWidth = 32
    self.hitboxHeight = 32

    self.animationName = 'idle'
    self.image = Turret.images.idle
    self.animation = Turret.animations.idle:clone()

    self.roomHash = roomHash or 0

    self.activated = false
end

function Turret:activate()
    if not self.activated then
        self.activated = true
        Signal.emit('turretActivate')
    end
end

function Turret:update(dt)
    self.alreadyDrawn = false
    self.animation:update(dt)
end

function Turret:draw()
    local game = self.game
    if not self.alreadyDrawn then
        local x, y = game:gridToScreen(self.x, self.y)
        local offset = Turret.animationOffsets[self.animationName]
        x = x + offset.x
        y = y - self.image:getHeight() + offset.y

        self.screenX = x
        self.screenY = y
        self.animation:draw(self.image, x, y)
        self.alreadyDrawn = true
    end
end

return Turret
