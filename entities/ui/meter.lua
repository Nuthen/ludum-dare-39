local Meter = Class('Meter')

function Meter:initialize(parent, props)
    self.parent = parent
    self.radius = 20
    self.bgColor = {127, 127, 127}
    self.inactiveColor = {255, 255, 255}
    self.activeColor = {127, 127, 127}
    self.warningColor = {255, 0, 0}
    self.position = Vector(0, 0)
    self.width = 350
    self.height = 30
    self.margin = 6
    self.onClicked = function() end

    for k, prop in pairs(props) do
        self[k] = prop
    end

    self.isPressed = false
    self.previouslyBelowThreshold = false

    self.timer = 0
end

function Meter:update(dt)
    local power = self.parent.game.power
    local belowThreshold = power <= TWEAK.powerWarningThreshold

    if belowThreshold and not self.previouslyBelowThreshold then
        Signal.emit("Low Power Warning Toggle On")
    elseif not belowThreshold and self.previouslyBelowThreshold then
        Signal.emit("Low Power Warning Toggle Off")
    end

    self.previouslyBelowThreshold = belowThreshold

    self.timer = self.timer + dt
end

function Meter:getPressed(x, y)
    return (x >= self.position.x - self.width/2) and
           (x <= self.position.x + self.width/2) and
           (y >= self.position.y) and
           (y <= self.position.y + self.height)
end

function Meter:mousepressed(x, y, mbutton)
    if self:getPressed(x, y) then
        self.onClicked()
    end
end

function Meter:mousemoved(x, y, dx, dy, istouch)
    if self:getPressed(x, y) then
        self.isPressed = true
    end
end

function Meter:draw()
    local power = self.parent.game.power
    local belowThreshold = power <= TWEAK.powerWarningThreshold

    love.graphics.setColor(self.inactiveColor)

    local margin = self.margin
    local x, y, w, h = self.position.x, self.position.y, self.width, self.height
    x, y = x - w/2, y
    love.graphics.setColor(self.bgColor)
    --love.graphics.rectangle('fill', x, y, w, h)
    love.graphics.setColor(self.inactiveColor)

    x, y, w, h = x + margin, y + margin, w - margin*2, h - margin*2
    love.graphics.rectangle('fill', x, y, w, h)
    love.graphics.setColor(self.activeColor)
    if belowThreshold then
        local r, g, b = unpack(self.warningColor)
        local a = (math.cos(self.timer*TWEAK.power_meter_warning_flash_rate)+1)/2 * 255
        love.graphics.setColor(r, g, b, a)
    end

    love.graphics.rectangle('fill', x, y, w*power, h)
end

return Meter
