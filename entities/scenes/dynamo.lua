local Scene = require 'entities.scene'
local Button = require 'entities.ui.button'
local Wheel = require 'entities.ui.wheel'
local Flick = require 'entities.ui.flick'
local Meter = require 'entities.ui.meter'

local Dynamo = Class('Dynamo', Scene)

function Dynamo:initialize(parent, props)
    self.width = love.graphics.getWidth()*.8
    self.height = love.graphics.getHeight()*.6

    self.positionSet = Vector(0, love.graphics.getHeight())

    self.position = Vector(love.graphics.getWidth()/2  - self.width/2,
                           self.positionSet.y)

    self.bgColor = {100, 100, 100, 100}

    Scene.initialize(self, props)

    table.insert(self.entities, Button:new(self, {
            position = Vector(self.width/4, self.height*3/4),
            inactiveColor = {31, 117, 60},
            pressColor = {80, 164, 242},
            onClicked = function()
                self.power = self.power + .1
            end,
        }))

    table.insert(self.entities, Button:new(self, {
            position = Vector(self.width/2, self.height*3/4),
            inactiveColor = {89, 10, 74},
            pressColor = {222, 81, 144},
            onClicked = function()
                self.power = self.power + .1
            end,
        }))

    table.insert(self.entities, Button:new(self, {
            position = Vector(self.width*3/4, self.height*3/4),
            inactiveColor = {147, 162, 77},
            pressColor = {255, 202, 66},
            onClicked = function()
                self.power = self.power + .1
            end,
        }))

    table.insert(self.entities, Wheel:new(self, {
            position = Vector(self.width*2/5, self.height*1/4),
            inactiveColor = {147, 162, 77},
            pressColor = {255, 202, 66},
            onClicked = function(dirRot)
                self.power = self.power + .1
            end,
        }))

    table.insert(self.entities, Flick:new(self, {
            position = Vector(self.width*3/4, self.height*1/4),
            inactiveColor = {147, 162, 77},
            pressColor = {255, 202, 66},
            onClicked = function(dir)
                self.power = self.power + .1
            end,
        }))

    -- power meter
    local meter = Meter:new(self, {
            position = Vector(self.width/2, 0),
            bgColor = self.bgColor,
            inactiveColor = {147, 162, 77},
            activeColor = {255, 202, 66},
            onClicked = function()
                self:toggleScreen()
            end,
        })
    meter.position.y = meter.position.y - meter.height

    self.positionSet.x = self.positionSet.x + meter.height

    table.insert(self.entities, meter)

    self.active = true
    self.power = 1 -- [0, 1]
    self.powerDropMultiplier = 0.1

    self.tweenMoveTime = .5
end

function Dynamo:toggleScreen()
    self.active = not self.active

    if self.active then
        Timer.tween(self.tweenMoveTime, self.position, {y = self.positionSet.y})
    else
        Timer.tween(self.tweenMoveTime, self.position, {y = self.positionSet.x})
    end
end

function Dynamo:update(dt)
    --if not self.active then return end

    Scene.update(self, dt)

    self.power = math.max(0, math.min(1, self.power - dt*self.powerDropMultiplier))
end

function Dynamo:keypressed(key, code)
    if key == 'space' then
        self:toggleScreen()
    end

    if not self.active then return end

    Scene.keypressed(self, key, code)
end

function Dynamo:keyreleased(key, code)
    if not self.active then return end

    Scene.keyreleased(self, key, code)
end

function Dynamo:mousepressed(x, y, mbutton)
    --if not self.active then return end

    x, y = x - self.position.x, y - self.position.y
    Scene.mousepressed(self, x, y, mbutton)
end

function Dynamo:mousereleased(x, y, mbutton)
    --if not self.active then return end

    x, y = x - self.position.x, y - self.position.y
    Scene.mousereleased(self, x, y, mbutton)
end

function Dynamo:mousemoved(x, y, dx, dy, istouch)
    --if not self.active then return end

    x, y = x - self.position.x, y - self.position.y
    Scene.mousemoved(self, x, y, dx, dy, istouch)
end

function Dynamo:draw()
    --if not self.active then return end

    love.graphics.push()
    love.graphics.translate(self.position:unpack())
    love.graphics.setColor(self.bgColor)
    love.graphics.rectangle('fill', 0, 0, self.width, self.height)
    Scene.draw(self)
    love.graphics.pop()
end

return Dynamo
