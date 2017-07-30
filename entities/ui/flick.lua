local Flick = Class('Flick')

function Flick:initialize(parent, props)
    self.parent = parent
    self.radius = 80
    self.inactiveColor = {255, 255, 255}
    self.pressColor = {127, 127, 127}
    self.position = Vector(0, 0)
    self.angle = 0
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
        up    = {'up'   , 'w'},
        down  = {'down' , 's'},
        left  = {'left' , 'a'},
        right = {'right', 'd'},
    }
end

function Flick:activate()
    self.activated = true
    local randomDir = love.math.random(0, 3)
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

    if love.keyboard.isDown(unpack(self.keybinds.up)) then
        delta.y = -1
    elseif love.keyboard.isDown(unpack(self.keybinds.down)) then
        delta.y = 1
    end

    if love.keyboard.isDown(unpack(self.keybinds.left)) then
        delta.x = -1
    elseif love.keyboard.isDown(unpack(self.keybinds.right)) then
        delta.x = 1
    end

    delta = delta:normalized()

    if delta:len() > 0 then
        self.rawPosition = self.rawPosition + delta * self.handleSpeed * dt
        self:solvePosition()
    end
end

function Flick:keypressed(key, code)
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

        if self.activated and dir == self.activeDirection then
            self.activated = false
            self.onClicked(dir)
        end
    end
end

function Flick:mousepressed(x, y, mbutton)
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
        self.rawPosition = self.rawPosition + Vector(dx, dy)
        self:solvePosition()
    end
end

function Flick:mousereleased(x, y, mbutton)
    if mbutton == 1 then
        self.isPressed = false
        self.rawPosition = Vector(0, 0)
        self.dist = 0
        self.beganPress = false
    end
end

function Flick:draw()
    for i = 0, 3 do
        love.graphics.setColor(self.inactiveColor)
        if self.activated and i == self.rawActiveDir then
            love.graphics.setColor(self.pressColor)
        end
        love.graphics.line(self.position.x, self.position.y, self.position.x + math.cos(i*math.rad(90))*self.radius, self.position.y + math.sin(i*math.rad(90))*self.radius)
    end

    love.graphics.setColor(self.inactiveColor)
    if self.isPressed then
        love.graphics.setColor(self.pressColor)
    end
    love.graphics.circle('fill', self.position.x + math.cos(self.angle)*self.dist, self.position.y + math.sin(self.angle)*self.dist, 6)
end

return Flick
