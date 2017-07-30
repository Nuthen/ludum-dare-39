local Button = Class('Button')

function Button:initialize(parent, props)
    self.parent = parent
    self.radius = 20
    self.inactiveColor = {255, 255, 255}
    self.pressColor = {127, 127, 127}
    self.position = Vector(0, 0)
    self.onClicked = function() end
    self.keybinds = {}

    for k, prop in pairs(props) do
        self[k] = prop
    end

    self.isPressed = false
    self.activated = false
    self.mode = "mouse" -- "mouse" or "keyboard"
end

function Button:activate()
    self.activated = true
end

function Button:getPressed(x, y)
    return Lume.distance(self.position.x, self.position.y, x, y) <= self.radius
end

function Button:update(dt)

end

function Button:keypressed(key, code)
    if Lume.find(self.keybinds, key) then
        self.isPressed = true
        self.mode = "keyboard"

        if self.activated then
            self.activated = false
            self.onClicked()
        end
    end
end

function Button:keyreleased(key, code)
    if self.mode == "keyboard" and Lume.find(self.keybinds, key) then
        self.isPressed = false
    end
end

function Button:mousepressed(x, y, mbutton)
    if self.mode == "mouse" then
        self.isPressed = false
    end

    if mbutton == 1 and self:getPressed(x, y) then
        self.isPressed = true
        self.mode = "mouse"

        if self.isPressed and self.activated then
            self.activated = false
            self.onClicked()
        end
    end
end

function Button:mousemoved(x, y, dx, dy, istouch)
    if love.mouse.isDown(1) and not self:getPressed(x, y) and self.isPressed and self.mode == "mouse" then
        self.isPressed = false
    end
end

function Button:mousereleased(x, y, mbutton)
    if mbutton == 1 and self.mode == "mouse" then
        self.isPressed = false
    end
end

function Button:draw()
    love.graphics.setColor(self.inactiveColor)
    if self.isPressed or self.activated then
        love.graphics.setColor(self.pressColor)
    end
    love.graphics.circle('fill', self.position.x, self.position.y, self.radius - 3)
    love.graphics.circle('line', self.position.x, self.position.y, self.radius)
end

return Button
