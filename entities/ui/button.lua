local Button = Class('Button')

function Button:initialize(parent, props)
    self.parent = parent
    self.radius = 20
    self.inactiveColor = {255, 255, 255}
    self.pressColor = {127, 127, 127}
    self.position = Vector(0, 0)
    self.onCorrect = function() end

    for k, prop in pairs(props) do
        self[k] = prop
    end

    self.isPressed = false
end

function Button:getPressed(x, y)
    return Lume.distance(self.position.x, self.position.y, x, y) <= self.radius
end

function Button:update(dt)

end

function Button:mousepressed(x, y, mbutton)
    self.isPressed = false
    if mbutton == 1 then
        self.isPressed = self:getPressed(x, y)

        if self.isPressed then
            self.onCorrect()
        end
    end
end

function Button:mousemoved(x, y, dx, dy, istouch)
    self.isPressed = false
    if love.mouse.isDown(1) then
        self.isPressed = self:getPressed(x, y)
    end
end

function Button:mousereleased(x, y, mbutton)
    if mbutton == 1 then
        self.isPressed = false
    end
end

function Button:draw()
    love.graphics.setColor(self.inactiveColor)
    if self.isPressed then
        love.graphics.setColor(self.pressColor)
    end
    love.graphics.circle('fill', self.position.x, self.position.y, self.radius - 3)
    love.graphics.circle('line', self.position.x, self.position.y, self.radius)
end

return Button
