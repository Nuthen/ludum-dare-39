local Scene = require 'entities.scene'
local Button = require 'entities.ui.button'
local Wheel = require 'entities.ui.wheel'
local Flick = require 'entities.ui.flick'
local Meter = require 'entities.ui.meter'
local Map = require 'entities.ui.map'

local Dynamo = Class('Dynamo', Scene)

function Dynamo:initialize(parent, props)
    self.parent = parent

    self.width = love.graphics.getWidth()*.8
    self.height = love.graphics.getHeight()*.6

    self.positionSet = Vector(0, love.graphics.getHeight())

    self.position = Vector(love.graphics.getWidth()/2  - self.width/2,
                           self.positionSet.y)

    self.bgColor = {100, 100, 100, 255}

    Scene.initialize(self, props)

    local firstButton = Button:new(self, {
            position = Vector(self.width/4, self.height*3/4),
            inactiveColor = {31, 117, 60},
            pressColor = {80, 164, 242},
            keybinds = {'1', 'kp1'},
            onClicked = function()
                self:addPower(.1)
                self:activateFidget()
            end,
        })
    table.insert(self.entities, firstButton)

    local secondButton = Button:new(self, {
            position = Vector(self.width/2, self.height*3/4),
            inactiveColor = {89, 10, 74},
            pressColor = {222, 81, 144},
            keybinds = {'2', 'kp2'},
            onClicked = function()
                self:addPower(.1)
                self:activateFidget()
            end,
        })
    table.insert(self.entities, secondButton)

    local thirdButton = Button:new(self, {
            position = Vector(self.width*3/4, self.height*3/4),
            inactiveColor = {147, 162, 77},
            pressColor = {255, 202, 66},
            keybinds = {'3', 'kp3'},
            onClicked = function()
                self:addPower(.1)
                self:activateFidget()
            end,
        })
    table.insert(self.entities, thirdButton)

    local wheel = Wheel:new(self, {
            position = Vector(self.width*2/5, self.height*1/4),
            inactiveColor = {147, 162, 77},
            pressColor = {255, 202, 66},
            onClicked = function(dirRot) -- "cw", "ccw"
                self:addPower(.1)
                self:activateFidget()
            end,
        })
    table.insert(self.entities, wheel)

    local flick = Flick:new(self, {
            position = Vector(self.width*3/4, self.height*1/4),
            inactiveColor = {147, 162, 77},
            pressColor = {255, 202, 66},
            onClicked = function(dir) -- "up", "down", "left", "right"
                self:addPower(.1)
                self:activateFidget()
            end,
        })
    table.insert(self.entities, flick)

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

    table.insert(self.entities, Map:new(self, {
        game = self.parent,
        position = Vector(120, 120),
    }))

    self.fidgets = {
        button1 = firstButton,
        button2 = secondButton,
        button3 = thirdButton,
        wheel = wheel,
        flick = flick,
    }

    self.active = false
    self.powerDropMultiplier = 0.05

    self.tweenMoveTime = .25
end

function Dynamo:addPower(amount)
    self.game.power = math.max(0, math.min(1, self.game.power + amount))
end

function Dynamo:toggleScreen()
    self.active = not self.active

    if self.active then
        Timer.tween(self.tweenMoveTime, self.position, {y = self.positionSet.x}, 'linear', function()
            self:activateFidget()
        end)
    else
        Timer.tween(self.tweenMoveTime, self.position, {y = self.positionSet.y})
    end
end

function Dynamo:activateFidget()
    local keys = {}

    for k, fidget in pairs(self.fidgets) do
        table.insert(keys, k)
    end

    local keyIndex = love.math.random(1, #keys)
    local key = keys[keyIndex]
    local newFidget = self.fidgets[key]
    newFidget:activate()
end

function Dynamo:update(dt)
    --if not self.active then return end

    Scene.update(self, dt)

    self:addPower(-dt*self.powerDropMultiplier)
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

function Dynamo:wheelmoved(x, y)
    --if not self.active then return end

    Scene.wheelmoved(self, x, y)
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
