local Scene = require 'entities.scene'

local Dynamo = Class('Dynamo', Scene)

function Dynamo:initialize(parent, props)
    Scene.initialize(self, props)

    self.width = love.graphics.getWidth()*.8
    self.height = love.graphics.getHeight()*.6

    self.position = Vector(love.graphics.getWidth()/2  - self.width/2,
                     love.graphics.getHeight()/2 - self.height/2)

    table.insert(self.entities, {
        parent = self,
        position = Vector(self.width/2, self.height/2),
        radius = 20,
        color = {80, 164, 242},
        pressColor = {31, 117, 60},
        isPressed = false,
        getPressed = function(self, x, y)
            return Lume.distance(self.position.x, self.position.y, x, y) <= self.radius
        end,
        update = function(self, dt)
            self.isPressed = false
            if love.mouse.isDown(1) then
                local mouse = Vector(love.mouse.getPosition())
                mouse = mouse - self.parent.position
                self.isPressed = self:getPressed(mouse.x, mouse.y)
            end
        end,
        draw = function(self)
            love.graphics.setColor(self.color)
            if self.isPressed then
                love.graphics.setColor(self.pressColor)
            end
            love.graphics.circle('fill', self.position.x, self.position.y, self.radius)
        end,
    })

    self.active = false
end

function Dynamo:update(dt)
    if not self.active then return end

    Scene.update(self, dt)
end

function Dynamo:keypressed(key, code)
    if key == 'space' then
        self.active = not self.active
    end

    if not self.active then return end

    Scene.keypressed(self, key, code)
end

function Dynamo:keyreleased(key, code)
    if not self.active then return end

    Scene.keyreleased(self, key, code)
end

function Dynamo:mousepressed(x, y, mbutton)
    if not self.active then return end

    Scene.mousepressed(self, x, y, mbutton)
end

function Dynamo:mousereleased(x, y, mbutton)
    if not self.active then return end

    Scene.mousereleased(self, x, y, mbutton)
end

function Dynamo:mousemoved(x, y, dx, dy, istouch)
    if not self.active then return end

    Scene.mousemoved(self, x, y, dx, dy, istouch)
end

function Dynamo:draw()
    if not self.active then return end

    love.graphics.push()
    love.graphics.translate(self.position:unpack())
    Scene.draw(self)
    love.graphics.pop()
end

return Dynamo
