local Scene = require 'entities.scene'
local Button = require 'entities.ui.button'
local Wheel = require 'entities.ui.wheel'
local Flick = require 'entities.ui.flick'
local Meter = require 'entities.ui.meter'
local Map = require 'entities.ui.map'

local Dynamo = Class('Dynamo', Scene)

function Dynamo:initialize(parent, props)
    self.parent = parent

    self.width = CANVAS_WIDTH*.8
    self.height = CANVAS_HEIGHT*.6

    self.positionSet = Vector(0, CANVAS_HEIGHT)

    self.position = Vector(CANVAS_WIDTH/2  - self.width/2,
                           self.positionSet.y)

    self.bgColor = {100, 100, 100, 255}

    self.bgImage = love.graphics.newImage('assets/images/Dynamo/dynamo_bg.png')

    Scene.initialize(self, props)

    local firstButton = Button:new(self, {
            position = Vector(self.width/4, self.height*3/4),
            inactiveColor = {31, 117, 60},
            pressColor = {80, 164, 242},
            locked = false,
            keybinds = SETTINGS.dynamoKeybinds.firstButton,
            image = love.graphics.newImage('assets/images/Dynamo/dynamo_button_green.png'),
            onClicked = function(position)
                self:addPower(TWEAK.power_charged_for_button, "button", position)
            end,
        })
    table.insert(self.entities, firstButton)

    local secondButton = Button:new(self, {
            position = Vector(self.width/2, self.height*3/4),
            inactiveColor = {89, 10, 74},
            pressColor = {222, 81, 144},
            keybinds = SETTINGS.dynamoKeybinds.secondButton,
            locked = false,
            image = love.graphics.newImage('assets/images/Dynamo/dynamo_button_pink.png'),
            onClicked = function(position)
                self:addPower(TWEAK.power_charged_for_button, "button", position)
            end,
        })
    table.insert(self.entities, secondButton)

    local thirdButton = Button:new(self, {
            position = Vector(self.width*3/4, self.height*3/4),
            inactiveColor = {147, 162, 77},
            pressColor = {255, 202, 66},
            keybinds = SETTINGS.dynamoKeybinds.thirdButton,
            image = love.graphics.newImage('assets/images/Dynamo/dynamo_button_blue.png'),
            onClicked = function(position)
                self:addPower(TWEAK.power_charged_for_button, "button", position)
            end,
        })
    table.insert(self.entities, thirdButton)

    local wheel = Wheel:new(self, {
            position = Vector(self.width*2/5, self.height*1/4),
            --inactiveColor = {147, 162, 77},
            --pressColor = {255, 202, 66},
            onClicked = function(position, dirRot) -- "cw", "ccw"
                self:addPower(TWEAK.power_charged_for_spin, "wheel", position)
            end,
        })
    table.insert(self.entities, wheel)

    local flick = Flick:new(self, {
            position = Vector(self.width*3/4, self.height*1/4),
            --inactiveColor = {147, 162, 77},
            --pressColor = {255, 202, 66},
            onClicked = function(position, dir) -- "up", "down", "left", "right"
                self:addPower(TWEAK.power_charged_for_flick, "flick", position)
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

    if TWEAK.minimapOnDynamo then
        table.insert(self.entities, Map:new(self, {
            game = self.parent,
            position = Vector(120, 120),
        }))
    end

    self.fidgets = {
        button1 = firstButton,
        button2 = secondButton,
        button3 = thirdButton,
        wheel = wheel,
        flick = flick,
    }

    self.unlockTable = {}
    self.unlockTable[2] = function()
        self.fidgets.button3.locked = false
    end
    --self.unlockTable[2] = function()
    --end
    self.unlockTable[3] = function()
        self.fidgets.flick.locked.up = false
        self.fidgets.flick.locked.right = false
        self.fidgets.flick.locked.down = false
        self.fidgets.flick.locked.left  = false
    end
    --self.unlockTable[4] = function()
    --end
    self.unlockTable[5] = function()
        self.fidgets.wheel.locked.cw    = false
        self.fidgets.wheel.locked.ccw   = false
    end
    --[[self.unlockTable[6] = function()
    end
    self.unlockTable[7] = function()
    end]]

    self.active = false
    self.powerDropMultiplier = TWEAK.powerDropMultiplier

    self.tweenMoveTime = .25

    self.unlockSignalWaiting = false

    self.counter = 0
end

function Dynamo:powerGridActivated(gridsPowered)
    self.counter = self.counter + 1

    if self.unlockTable[self.counter] then
        self.unlockTable[self.counter]()
        self.unlockSignalWaiting = true
    end
end

function Dynamo:addPower(amount, sourceType, position)
    self.game.power = math.max(0, math.min(1, self.game.power + amount))

    if amount > 0 then
        self:activateFidget()
        position = position + self.position
        Signal.emit("Dynamo Correct", sourceType, position)
    end
end

function Dynamo:toggleScreen()
    if self.parent.eventManager.firstPowerGrid then return end
    if self.active and self.parent.eventManager.firstDynamoCorrect then return end

    self.active = not self.active

    if self.active then
        Timer.tween(self.tweenMoveTime, self.position, {y = self.positionSet.x}, 'quad', function()
            self:activateFidget()
            Signal.emit("Dynamo Toggle On")
        end)
    else
        Timer.tween(self.tweenMoveTime, self.position, {y = self.positionSet.y}, 'quad', function()
            for k, fidget in pairs(self.fidgets) do
                fidget.activated = false
            end
            Signal.emit("Dynamo Toggle Off")
        end)
    end
end

function Dynamo:activateFidget()
    local keys = {}

    for k, fidget in pairs(self.fidgets) do
        if k == "flick" then
            if not fidget.locked.up    or
               not fidget.locked.down  or
               not fidget.locked.left  or
               not fidget.locked.right then
                table.insert(keys, k)
            end
        elseif k == "wheel" then
            if not fidget.locked.cw  or
               not fidget.locked.ccw then
                table.insert(keys, k)
            end
        elseif not fidget.locked then
            table.insert(keys, k)
        end
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

    if self.unlockSignalWaiting and self.active then
        Signal.emit("Dynamo Fidget Unlocked")
        self.unlockSignalWaiting = false
    end
end

function Dynamo:keypressed(key, code)
    if key == 'space' then
        self:toggleScreen()
    end

    if DEBUG then
        if key == "4" then
            self.fidgets.button3.locked = false
        end
        if key == "5" then
            self.fidgets.flick.locked.up = false
        end
        if key == "6" then
            self.fidgets.flick.locked.right = false
        end
        if key == "7" then
            self.fidgets.flick.locked.down = false
        end
        if key == "8" then
            self.fidgets.flick.locked.left = false
        end
        if key == "9" then
            self.fidgets.wheel.locked.cw = false
        end
        if key == "0" then
            self.fidgets.wheel.locked.ccw = false
        end
    end

    if not self.active then return end
    if self.parent.eventManager.firstDynamoOpen then return end

    Scene.keypressed(self, key, code)
end

function Dynamo:keyreleased(key, code)
    if not self.active then return end
    --if self.parent.eventManager.firstDynamoOpen then return end

    Scene.keyreleased(self, key, code)
end

function Dynamo:mousepressed(x, y, mbutton)
    --if not self.active then return end
    --if self.parent.eventManager.firstDynamoOpen then return end

    x, y = x - self.position.x, y - self.position.y
    Scene.mousepressed(self, x, y, mbutton)
end

function Dynamo:mousereleased(x, y, mbutton)
    --if not self.active then return end
    --if self.parent.eventManager.firstDynamoOpen then return end

    x, y = x - self.position.x, y - self.position.y
    Scene.mousereleased(self, x, y, mbutton)
end

function Dynamo:mousemoved(x, y, dx, dy, istouch)
    --if not self.active then return end
    --if self.parent.eventManager.firstDynamoOpen then return end

    x, y = x - self.position.x, y - self.position.y
    Scene.mousemoved(self, x, y, dx, dy, istouch)
end

function Dynamo:wheelmoved(x, y)
    --if not self.active then return end
    --if self.parent.eventManager.firstDynamoOpen then return end

    Scene.wheelmoved(self, x, y)
end

function Dynamo:draw()
    --if not self.active then return end

    love.graphics.push()
    love.graphics.translate(0, math.floor(self.position.y-30))
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.bgImage, 0, 0)
    love.graphics.pop()
    love.graphics.push()
    love.graphics.translate(self.position:unpack())
    --love.graphics.setColor(self.bgColor)
    --love.graphics.rectangle('fill', 0, 0, self.width, self.height)
    Scene.draw(self)
    love.graphics.pop()
end

return Dynamo
