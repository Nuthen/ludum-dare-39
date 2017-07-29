local Flick = Class('Flick')

function Flick:initialize(parent, props)
    self.parent = parent
    self.radius = 80
    self.inactiveColor = {255, 255, 255}
    self.pressColor = {127, 127, 127}
    self.position = Vector(0, 0)
    self.angle = 0

    for k, prop in pairs(props) do
        self[k] = prop
    end

    self.isPressed = false

    self.rawPosition = Vector(0, 0)
    self.dist = 0
end

function Flick:getPressed(x, y)
    return Lume.distance(self.position.x, self.position.y, x, y) <= self.radius
end

function Flick:update(dt)

end

function Flick:mousepressed(x, y, mbutton)
    self.isPressed = false
    if mbutton == 1 then
        self.isPressed = self:getPressed(x, y)
        self.rawPosition = Vector(0, 0)
        self.dist = 0
    end
end

function Flick:mousemoved(x, y, dx, dy, istouch)
    if self.isPressed then
        self.rawPosition = self.rawPosition + Vector(dx, dy)

        local dist = Lume.distance(self.position.x, self.position.y, self.rawPosition.x + self.position.x, self.rawPosition.y + self.position.y)
        local currentAngle = Lume.angle(self.position.x, self.position.y, self.rawPosition.x + self.position.x, self.rawPosition.y + self.position.y)
        self.dist = math.min(self.radius, dist)
        local increment = math.rad(90)
        self.angle = math.floor(currentAngle/increment + increment/2)*increment
    end
end

function Flick:mousereleased(x, y, mbutton)
    if mbutton == 1 then
        self.isPressed = false
        self.rawPosition = Vector(0, 0)
        self.dist = 0
    end
end

function Flick:draw()
    love.graphics.setColor(self.inactiveColor)
    if self.isPressed then
        love.graphics.setColor(self.pressColor)
    end
    for i = 0, 3 do
        love.graphics.line(self.position.x, self.position.y, self.position.x + math.cos(i*math.rad(90))*self.radius, self.position.y + math.sin(i*math.rad(90))*self.radius)
    end
    love.graphics.circle('fill', self.position.x + math.cos(self.angle)*self.dist, self.position.y + math.sin(self.angle)*self.dist, 6)
end

return Flick
