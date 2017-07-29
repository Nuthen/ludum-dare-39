local Button = Class('Button')

function Button:initialize(parent, props)
    self.parent = parent
    self.radius = 20
    self.inactiveColor = {255, 255, 255}
    self.pressColor = {127, 127, 127}
    self.position = Vector(0, 0)

    for k, prop in pairs(props) do
        self[k] = prop
    end

    self.isPressed = false
end

function Button:getPressed(x, y)
    return Lume.distance(self.position.x, self.position.y, x, y) <= self.radius
end

function Button:update(dt)
    self.isPressed = false
    if love.mouse.isDown(1) then
        local mouse = Vector(love.mouse.getPosition())
        mouse = mouse - self.parent.position
        self.isPressed = self:getPressed(mouse.x, mouse.y)
    end
end

function Button:draw()
    love.graphics.setColor(self.inactiveColor)
    if self.isPressed then
        love.graphics.setColor(self.pressColor)
    end
    love.graphics.circle('fill', self.position.x, self.position.y, self.radius)
end

return Button
