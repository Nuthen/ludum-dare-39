local Scene = require "entities.scene"
local TextBox = require "entities.textbox"

local EventScene = Class("EventScene", Scene)

function EventScene:initialize(parent)
    self.parent = parent

    local continueText = "\n(Click here or press space to continue)"

    self.eventList = {
        prologue1 = function()
            self.eventBox:addEntry("Welcome. Your goal is to restore power to all 7 power grids of your spaceship. Start by clicking on the first power grid (It is glowing red).")
            local onClick = function()
                self.active = false
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
        end,

        grid1 = function()
            self.eventBox:addEntry("Warning. Power grids will slowly deplete your power over time. If you run out of power, your ship will be lost. To recharge your power, click on the power bar at the bottom of the screen or press SPACE.")
            local onClick = function()
                self.active = false
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
        end,

        dynamo1 = function()
            self.eventBox:addEntry("Click on the active button (green light) to recharge your power levels.")
            local onClick = function()
                self.active = false
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
        end,

        dynamoCorrect1 = function()
            self.eventBox:addEntry("Well done! Make sure to return here often to keep enough power. Also, more tools will unlock as more grids are powered. When you are ready, close the interface by clicking on the power bar or by pressing SPACE.")
            local onClick = function()
                self.active = false
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
        end,

        dynamoToggleOff1 = function()
            self.eventBox:addEntry("Aliens are invading your ship! They're attracted to the active power grids.  Click on the aliens to destroy them.")
            local onClick = function()
                self.active = false
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
        end,

        enemyDeath1 = function()
            self.eventBox:addEntry("To win the game you will need to fully charge all power grids in the ship by clicking on them until they reach 100%. Click on a red room on the minimap at the top right corner of your screen.")
            local onClick = function()
                self.active = false
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
        end,

        roomEnter1 = function()
            self.eventBox:addEntry("To help you against the aliens, you can activate turrets by clicking on them once a room is fully charged. Good Luck.")
            local onClick = function()
                self.active = false
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
        end,

        turretActivate1 = function()
            self.eventBox:addEntry("Click on the turret until it reaches 100% to activate it. It will help you by automatically shooting the invaders.")
            local onClick = function()
                self.active = false
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
        end,
    }

    self.drawIndex = 100

    Signal.register('powerGridActivate', function()
        if self.firstPowerGrid then
            self.firstPowerGrid = false
            self:setEvent("grid1")
        end
    end)

    Signal.register("Dynamo Toggle On", function()
        if self.firstDynamoOpen then
            self.firstDynamoOpen = false
            self:setEvent("dynamo1")
        end
    end)

    Signal.register("Dynamo Correct", function()
        if self.firstDynamoCorrect then
            self.firstDynamoCorrect = false
            self:setEvent("dynamoCorrect1")
        end
    end)

    Signal.register("enemyDeath", function()
        if self.firstEnemyDeath then
            self.firstEnemyDeath = false
            self:setEvent("enemyDeath1")
        end
    end)

    Signal.register("turretActivate", function()
        if self.firstTurretActive then
            self.firstTurretActive = false
            self:setEvent("turretActivate1")
        end
    end)

    Signal.register("Dynamo Toggle Off", function()
        if self.firstDynamoClose then
            self.firstDynamoClose = false
            self.parent:spawnEnemy(true)
            self:setEvent("dynamoToggleOff1")
        end
    end)

    Signal.register("Enter Room", function()
        if self.firstRoomEnter then
            self.firstRoomEnter = false
            self:setEvent("roomEnter1")
        end
    end)

    self:reset()
end

function EventScene:reset()
    --[[
    self.firstPowerGrid
    self.firstEnemy
    .. etc

    ]]

    self.firstPowerGrid = true
    self.firstDynamoOpen = true
    self.firstDynamoCorrect = true
    self.firstEnemyDeath = true
    self.firstTurretActive = true
    self.firstDynamoClose = true
    self.firstRoomEnter = true

    self:setEvent("prologue1")

    self.active = true
end

function EventScene:setPrologue()
    local w, h = love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.8
    local x, y = love.graphics.getWidth()/2 - w/2, love.graphics.getHeight()/2 - h/2

    self.eventBox = TextBox:new(x, y, w, h, true)
    self:setEvent("prologue1")
end

function EventScene:setEvent(label)
    Timer.after(TWEAK.tutorial_popup_delay, function()

        local w, h = love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.8
        local x, y = love.graphics.getWidth()/2 - w/2, love.graphics.getHeight()/2 - h/2

        self.eventBox = TextBox:new(x, y, w, h, true)

        self.eventList[label]()

        self.eventBox:setToMaxScroll()
        self.active = true
    end)
end

function EventScene:resize(screenWidth, screenHeight)
    if self.eventBox then
        local w, h = screenWidth*0.5, screenHeight*0.8
        local x, y = screenWidth/2 - w/2, screenHeight/2 - h/2

        local fontScale = screenWidth / 1280

        self.eventBox:resize(x, y, w, h, fontScale)
    end
end

function EventScene:update()
    if not self.active then return end

    if self.eventBox then
        self.eventBox:update()
    end
end

function EventScene:keypressed(key, code)
    if not self.active then return end

    if self.eventBox then
        self.eventBox:keypressed(key, code)
    end
end

function EventScene:mousepressed(x, y, mbutton)
    if not self.active then return end

    if self.eventBox then
        self.eventBox:mousepressed(x, y, mbutton)
    end
end

function EventScene:wheelmoved(x, y)
    if self.eventBox then
        -- pretty bad hack on the minus @Hack
        self.eventBox:wheelmoved(x, -y)
    end
end

function EventScene:draw()

end

function EventScene:drawNative()
    if not self.active then return end

    if self.eventBox then
        self.eventBox:draw()
    end
end

return EventScene
