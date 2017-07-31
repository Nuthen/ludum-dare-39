local Flick = Class('Flick')

function Flick:initialize(parent, props)
    self.parent = parent
    self.radius = 40
    self.inactiveColor = {255, 255, 255}
    self.pressColor = {127, 127, 127}
    self.position = Vector(0, 0)
    self.angle = 0
    self.locked = {up = true, down = true, right = true, left = true}
    self.onClicked = function(angleInterval) end

    for k, prop in pairs(props) do
        self[k] = prop
    end

    self.isPressed = false

    self.rawPosition = Vector(0, 0)
    self.dist = 0
    self.beganPress = false
    self.activeDirection = "up"
    self.rawActiveDir = 0
    self.handleSpeed = 200

    self.keybinds = {
        up    = SETTINGS.dynamoKeybinds.flick.up,
        down  = SETTINGS.dynamoKeybinds.flick.down,
        left  = SETTINGS.dynamoKeybinds.flick.left,
        right = SETTINGS.dynamoKeybinds.flick.right,
    }
end

function Flick:activate()
    self.activated = true

    local possibles = {}
    if not self.locked.right then table.insert(possibles, 0) end
    if not self.locked.down  then table.insert(possibles, 1) end
    if not self.locked.left  then table.insert(possibles, 2) end
    if not self.locked.up    then table.insert(possibles, 3) end

    local randomDir = possibles[love.math.random(1, #possibles)]
    if randomDir == 0 then
        self.activeDirection = "right"
    elseif randomDir == 1 then
        self.activeDirection = "down"
    elseif randomDir == 2 then
        self.activeDirection = "left"
    elseif randomDir == 3 then
        self.activeDirection = "up"
    end

    self.rawActiveDir = randomDir
end

function Flick:getPressed(x, y)
    return Lume.distance(self.position.x, self.position.y, x, y) <= self.radius
end

function Flick:update(dt)
    local delta = Vector(0, 0)

    if love.keyboard.isDown(unpack(self.keybinds.up)) and not self.locked.up then
        delta.y = -1
    elseif love.keyboard.isDown(unpack(self.keybinds.down)) and not self.locked.down then
        delta.y = 1
    end

    if love.keyboard.isDown(unpack(self.keybinds.left)) and not self.locked.left then
        delta.x = -1
    elseif love.keyboard.isDown(unpack(self.keybinds.right)) and not self.locked.right then
        delta.x = 1
    end

    delta = delta:normalized()

    if delta:len() > 0 then
        self.rawPosition = self.rawPosition + delta * self.handleSpeed * dt
        self:solvePosition()
    end
end

function Flick:keypressed(key, code)
    if self.locked.up    and
       self.locked.down  and
       self.locked.left  and
       self.locked.right then
           return
    end

    if Lume.find(self.keybinds.up,    key) or
       Lume.find(self.keybinds.down,  key) or
       Lume.find(self.keybinds.left,  key) or
       Lume.find(self.keybinds.right, key) then
           self.isPressed = true
           self.rawPosition = Vector(0, 0)
           self.dist = 0
           self.beganPress = true
    end
end

function Flick:keyreleased(key, code)
    if self.locked.up    and
       self.locked.down  and
       self.locked.left  and
       self.locked.right then
           return
    end

    if Lume.find(self.keybinds.up,    key) or
       Lume.find(self.keybinds.down,  key) or
       Lume.find(self.keybinds.left,  key) or
       Lume.find(self.keybinds.right, key) then
           self.isPressed = false
           self.rawPosition = Vector(0, 0)
           self.dist = 0
           self.beganPress = false
    end
end

function Flick:solvePosition()
    local dist = Lume.distance(self.position.x, self.position.y, self.rawPosition.x + self.position.x, self.rawPosition.y + self.position.y)
    local currentAngle = Lume.angle(self.position.x, self.position.y, self.rawPosition.x + self.position.x, self.rawPosition.y + self.position.y)
    self.dist = math.min(self.radius, dist)
    local increment = math.rad(90)
    local angleInterval = math.floor(currentAngle/increment + increment/2)
    self.angle = angleInterval*increment

    if self.beganPress and self.dist == self.radius then
        self.beganPress = false

        local dir = "up"
        if angleInterval == 2 or angleInterval == -2 then
            dir = "left"
        elseif angleInterval == -1 then
            dir = "up"
        elseif angleInterval == 0 then
            dir = "right"
        elseif angleInterval == 1 then
            dir = "down"
        else
            error("Unexpected angle interval on Flick: " .. angleInterval .. " from angle: " .. currentAngle)
        end

        if self.activated then
            if dir == self.activeDirection then
                self.activated = false
                self.onClicked(self.position, dir)
            else
                Signal.emit("Dynamo Incorrect", "flick")
            end
        end
    end
end

function Flick:mousepressed(x, y, mbutton)
    if self.locked.up    and
       self.locked.down  and
       self.locked.left  and
       self.locked.right then
           return
    end

    self.isPressed = false
    if mbutton == 1 then
        self.isPressed = self:getPressed(x, y)
        self.rawPosition = Vector(0, 0)
        self.dist = 0
        self.beganPress = true
    end
end

function Flick:mousemoved(x, y, dx, dy, istouch)
    if self.isPressed then
        if self.locked.up    then dy = math.max(0, dy) end
        if self.locked.down  then dy = math.min(0, dy) end
        if self.locked.left  then dx = math.max(0, dx) end
        if self.locked.right then dx = math.min(0, dx) end

        self.rawPosition = self.rawPosition + Vector(dx, dy)
        self:solvePosition()
    end
end

function Flick:mousereleased(x, y, mbutton)
    if self.locked.up    and
       self.locked.down  and
       self.locked.left  and
       self.locked.right then
           return
    end

    if mbutton == 1 then
        self.isPressed = false
        self.rawPosition = Vector(0, 0)
        self.dist = 0
        self.beganPress = false
    end
end

function Flick:draw()
    if self.locked.up    and
       self.locked.down  and
       self.locked.left  and
       self.locked.right then
           return
    end

    for i = 0, 3 do
        local key
        if     i == 0 then key = "right"
        elseif i == 1 then key = "down"
        elseif i == 2 then key = "left"
        elseif i == 3 then key = "up" end

        if not self.locked[key] then
            love.graphics.setColor(self.inactiveColor)
            if self.activated and i == self.rawActiveDir then
                love.graphics.setColor(self.pressColor)
            end
            love.graphics.line(self.position.x, self.position.y, self.position.x + math.cos(i*math.rad(90))*self.radius, self.position.y + math.sin(i*math.rad(90))*self.radius)
        end
    end

    love.graphics.setColor(self.inactiveColor)
    if self.isPressed then
        love.graphics.setColor(self.pressColor)
    end
    love.graphics.circle('fill', self.position.x + math.cos(self.angle)*self.dist, self.position.y + math.sin(self.angle)*self.dist, 6)
end

return Flick
