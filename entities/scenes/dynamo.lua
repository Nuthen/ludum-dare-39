local Scene = require 'entities.scene'
local Button = require 'entities.ui.button'
local Wheel = require 'entities.ui.wheel'
local Flick = require 'entities.ui.flick'

local Dynamo = Class('Dynamo', Scene)

function Dynamo:initialize(parent, props)
    Scene.initialize(self, props)

    self.width = love.graphics.getWidth()*.8
    self.height = love.graphics.getHeight()*.6

    self.position = Vector(love.graphics.getWidth()/2  - self.width/2,
                     love.graphics.getHeight()/2 - self.height/2)

    table.insert(self.entities, Button:new(self, {
            position = Vector(self.width/4, self.height*3/4),
            inactiveColor = {31, 117, 60},
            pressColor = {80, 164, 242},
        }))

    table.insert(self.entities, Button:new(self, {
            position = Vector(self.width/2, self.height*3/4),
            inactiveColor = {89, 10, 74},
            pressColor = {222, 81, 144},
        }))

    table.insert(self.entities, Button:new(self, {
            position = Vector(self.width*3/4, self.height*3/4),
            inactiveColor = {147, 162, 77},
            pressColor = {255, 202, 66},
        }))

    table.insert(self.entities, Wheel:new(self, {
            position = Vector(self.width*2/5, self.height*1/4),
            inactiveColor = {147, 162, 77},
            pressColor = {255, 202, 66},
        }))

    table.insert(self.entities, Flick:new(self, {
            position = Vector(self.width*3/4, self.height*1/4),
            inactiveColor = {147, 162, 77},
            pressColor = {255, 202, 66},
        }))

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
    love.graphics.setColor(100, 100, 100, 100)
    love.graphics.rectangle('fill', 0, 0, self.width, self.height)
    Scene.draw(self)
    love.graphics.pop()
end

return Dynamo
