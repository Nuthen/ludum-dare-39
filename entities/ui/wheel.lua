local Wheel = Class('Wheel')

function Wheel:initialize(parent, props)
    self.parent = parent
    self.radius = 90
    self.inactiveColor = {255, 255, 255}
    self.pressColor = {127, 127, 127}
    self.position = Vector(0, 0)
    self.angle = 0
    self.locked = {cw = true, ccw = true}
    self.onClicked = function(rotDir) end

    for k, prop in pairs(props) do
        self[k] = prop
    end

    self.isPressed = false
    self.beganPress = false
    self.rotationAccumulator = 0
    self.startAngle = self.angle
    self.activeRotDirection = "cw"

    self.bindingSpinMultiplier = .5
    self.mouseSpinMultiplier = 1
end

function Wheel:activate()
    self.activated = true

    local possibles = {}
    if not self.locked.cw  then table.insert(possibles, 0) end
    if not self.locked.ccw then table.insert(possibles, 1) end

    local randomDir = possibles[love.math.random(1, #possibles)]

    local randDir = love.math.random(0, 1)
    if randDir == 0 then
        self.activeRotDirection = "cw"
    elseif randDir == 1 then
        self.activeRotDirection = "ccw"
    else
        error("Unexpected var for randDir: " .. randDir)
    end
end

function Wheel:getPressed(x, y)
    return Lume.distance(self.position.x, self.position.y, x, y) <= self.radius
end

function Wheel:update(dt)

end

function Wheel:mousepressed(x, y, mbutton)
    if self.locked.cw    and
       self.locked.ccw then
           return
    end

    self.isPressed = false
    if mbutton == 1 and self:getPressed(x, y) then
        self.isPressed = true
        self.beganPress = true
        --self.rotationAccumulator = 0
        --self.startAngle = self.angle
    end
end

function Wheel:mousemoved(x, y, dx, dy, istouch)
    if self.isPressed then
        -- makes a good spinning behavior regardless of how far inside or outside of the wheel the mouse is
        local dist = Lume.distance(self.position.x, self.position.y, x, y)
        local currentAngle = Lume.angle(self.position.x, self.position.y, x, y)

        local extrapLength = math.max(self.radius, dist)
        local extrapOffset = Vector(math.cos(currentAngle)*extrapLength, math.sin(currentAngle)*extrapLength)
        extrapOffset = extrapOffset - Vector(dx, dy)

        local prevAngle = Lume.angle(0, 0, extrapOffset.x, extrapOffset.y)
        local deltaAngle = (currentAngle - prevAngle) * self.mouseSpinMultiplier

        self:solveAngle(deltaAngle)
    end
end

function Wheel:solveAngle(deltaAngle)
    -- idea: be able to treat the skip from 180deg to -180deg as no big deal
    -- fairly hacky
    if deltaAngle >= math.pi then
        deltaAngle = 2*math.pi - deltaAngle
    elseif deltaAngle <= -math.pi then
        deltaAngle = -2*math.pi - deltaAngle
    end

    self.angle = self.angle + deltaAngle

    self.rotationAccumulator = self.rotationAccumulator + deltaAngle
    if self.rotationAccumulator >= 2*math.pi then
        self.rotationAccumulator = self.rotationAccumulator - 2*math.pi
        if self.activated and self.activeRotDirection == "cw" then
            self.activated = false
            self.onClicked("cw")
        end
    elseif self.rotationAccumulator <= -2*math.pi then
        self.rotationAccumulator = self.rotationAccumulator + 2*math.pi
        if self.activated and self.activeRotDirection == "ccw" then
            self.activated = false
            self.onClicked("ccw")
        end
    end

    if self.angle >= 2*math.pi then
        self.angle = self.angle - 2*math.pi
    elseif self.angle <= -2*math.pi then
        self.angle = self.angle + 2*math.pi
    end
end

function Wheel:mousereleased(x, y, mbutton)
    if self.locked.cw    and
       self.locked.ccw then
           return
    end

    if mbutton == 1 then
        self.isPressed = false
        self.beganPress = false
        --self.rotationAccumulator = 0
    end
end

function Wheel:wheelmoved(x, y)
    if self.locked.cw  then y = math.min(0, y) end
    if self.locked.ccw then y = math.max(0, y) end

    self:solveAngle(-y * self.bindingSpinMultiplier)
end

function Wheel:draw()
    if self.locked.cw    and
       self.locked.ccw then
          return
    end

    love.graphics.setColor(self.inactiveColor)
    if self.activated then
        love.graphics.setColor(self.pressColor)
    end

    local angle1Raw, angle2Raw = self.startAngle, self.startAngle + self.rotationAccumulator
    local angle1, angle2 = math.min(angle1Raw, angle2Raw), math.max(angle1Raw, angle2Raw)
    love.graphics.arc('line', self.position.x, self.position.y, self.radius + 5, angle1, angle2)

    love.graphics.circle('line', self.position.x, self.position.y, self.radius)

    love.graphics.setColor(self.inactiveColor)
    if self.isPressed then
        love.graphics.setColor(self.pressColor)
    end
    local handleX, handleY = self.position.x + math.cos(self.angle)*self.radius, self.position.y + math.sin(self.angle)*self.radius

    love.graphics.circle('fill', handleX, handleY , 6)

    if self.activated then
        local deltaRad
        if self.activeRotDirection == "cw" then
            deltaRad = math.pi/4
        elseif self.activeRotDirection == "ccw" then
            deltaRad = -math.pi/4
        end
        love.graphics.line(handleX, handleY, handleX + math.cos(self.angle+deltaRad)*20, handleY + math.sin(self.angle+deltaRad)*20)
    end



    --love.graphics.print(math.deg(self.rotationAccumulator), self.position.x, self.position.y)
end

return Wheel
