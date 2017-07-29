local Wheel = Class('Wheel')

function Wheel:initialize(parent, props)
    self.parent = parent
    self.radius = 90
    self.inactiveColor = {255, 255, 255}
    self.pressColor = {127, 127, 127}
    self.position = Vector(0, 0)
    self.angle = 0
    self.onClicked = function(rotDir) end

    for k, prop in pairs(props) do
        self[k] = prop
    end

    self.isPressed = false
    self.beganPress = false
    self.rotationAccumulator = 0
    self.startAngle = 0
end

function Wheel:getPressed(x, y)
    return Lume.distance(self.position.x, self.position.y, x, y) <= self.radius
end

function Wheel:update(dt)

end

function Wheel:mousepressed(x, y, mbutton)
    self.isPressed = false
    if mbutton == 1 and self:getPressed(x, y) then
        self.isPressed = true
        self.beganPress = true
        self.rotationAccumulator = 0
        self.startAngle = self.angle
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
        local deltaAngle = (currentAngle - prevAngle)

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
            self.onClicked("cw")
        elseif self.rotationAccumulator <= -2*math.pi then
            self.rotationAccumulator = self.rotationAccumulator + 2*math.pi
            self.onClicked("ccw")
        end

        if self.angle >= 2*math.pi then
            self.angle = self.angle - 2*math.pi
        elseif self.angle <= -2*math.pi then
            self.angle = self.angle + 2*math.pi
        end
    end
end

function Wheel:mousereleased(x, y, mbutton)
    if mbutton == 1 then
        self.isPressed = false
        self.beganPress = false
        self.rotationAccumulator = 0
    end
end

function Wheel:draw()
    love.graphics.setColor(self.inactiveColor)
    if self.isPressed then
        love.graphics.setColor(self.pressColor)
    end
    love.graphics.circle('line', self.position.x, self.position.y, self.radius)
    love.graphics.circle('fill', self.position.x + math.cos(self.angle)*self.radius, self.position.y + math.sin(self.angle)*self.radius, 6)

    local angle1Raw, angle2Raw = self.startAngle, self.startAngle + self.rotationAccumulator
    local angle1, angle2 = math.min(angle1Raw, angle2Raw), math.max(angle1Raw, angle2Raw)
    love.graphics.arc('line', self.position.x, self.position.y, self.radius + 5, angle1, angle2)

    love.graphics.print(math.deg(self.rotationAccumulator), self.position.x, self.position.y)
end

return Wheel
