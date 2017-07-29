local Wheel = Class('Wheel')

function Wheel:initialize(parent, props)
    self.parent = parent
    self.radius = 50
    self.inactiveColor = {255, 255, 255}
    self.pressColor = {127, 127, 127}
    self.position = Vector(0, 0)
    self.angle = 0

    for k, prop in pairs(props) do
        self[k] = prop
    end

    self.isPressed = false
end

function Wheel:getPressed(x, y)
    return Lume.distance(self.position.x, self.position.y, x, y) <= self.radius
end

function Wheel:update(dt)

end

function Wheel:mousepressed(x, y, mbutton)
    self.isPressed = false
    if mbutton == 1 then
        local mouse = Vector(x, y)
        mouse = mouse - self.parent.position
        self.isPressed = self:getPressed(mouse.x, mouse.y)
    end
end

function Wheel:mousemoved(x, y, dx, dy, istouch)
    if self.isPressed then
        local mouse = Vector(x, y)
        mouse = mouse - self.parent.position
        local prevMouse = mouse - Vector(dx, dy)

        local currentAngle = Lume.angle(self.position.x, self.position.y, mouse.x, mouse.y)
        local prevAngle = Lume.angle(self.position.x, self.position.y, prevMouse.x, prevMouse.y)
        self.angle = self.angle + (currentAngle - prevAngle)
    end
end

function Wheel:mousereleased(x, y, mbutton)
    if mbutton == 1 then
        self.isPressed = false
    end
end

function Wheel:draw()
    love.graphics.setColor(self.inactiveColor)
    if self.isPressed then
        love.graphics.setColor(self.pressColor)
    end
    love.graphics.circle('line', self.position.x, self.position.y, self.radius)
    love.graphics.circle('fill', self.position.x + math.cos(self.angle)*self.radius, self.position.y + math.sin(self.angle)*self.radius, 6)
end

return Wheel
