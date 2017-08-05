local Scene = require "entities.scene"
local TextBox = require "entities.textbox"

local EventScene = Class("EventScene", Scene)

function EventScene:initialize(parent)
    self.parent = parent

    self.textBoxWidth = 0.8
    self.textBoxHeight = 0.7

    local continueText = "\n(Click here or press space to continue)"
    local skipText = "\nOr press '" .. string.upper(SETTINGS.skipTutorialKeybind) .. "' to skip the tutorial"

    self.eventList = {
        prologue1 = function()
            self.eventBox:addEntry("You are stranded on a derelict spaceship. Your goal is to restore power to all 7 power grids of your spaceship. Start by clicking on the first power grid (It is glowing red).")
            local onClick = function()
                self:deactivatePopup()
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
            self.eventBox:addEntry(skipText, {font=Fonts.regular,size=24}, nil)
        end,

        grid1 = function()
            self.eventBox:addEntry("Warning. Power grids will slowly deplete your power over time. If you run out of power, your ship will be lost. To recharge your power, click on the power bar at the bottom of the screen or press SPACE.")
            local onClick = function()
                self:deactivatePopup()
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
            self.eventBox:addEntry(skipText, {font=Fonts.regular,size=24}, nil)
        end,

        dynamo1 = function()
            self.eventBox:addEntry("Click on the active button (green light) to recharge your power levels.")
            local onClick = function()
                self:deactivatePopup()
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
            self.eventBox:addEntry(skipText, {font=Fonts.regular,size=24}, nil)
        end,

        dynamoCorrect1 = function()
            self.eventBox:addEntry("Well done! Make sure to return here often to keep enough power. Also, more tools will unlock as more grids are powered. When you are ready, close the interface by clicking on the power bar or by pressing SPACE.")
            local onClick = function()
                self:deactivatePopup()
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
            self.eventBox:addEntry(skipText, {font=Fonts.regular,size=24}, nil)
        end,

        dynamoToggleOff1 = function()
            self.eventBox:addEntry("Aliens are invading your ship! They're attracted to the active power grids.  Click on the aliens to destroy them.")
            local onClick = function()
                self:deactivatePopup()
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
            self.eventBox:addEntry(skipText, {font=Fonts.regular,size=24}, nil)
        end,

        enemyDeath1 = function()
            self.eventBox:addEntry("To win the game you will need to fully charge all power grids in the ship by clicking and holding on them until they reach 100%. Click on a red room on the minimap at the top right corner of your screen.")
            local onClick = function()
                self:deactivatePopup()
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
            self.eventBox:addEntry(skipText, {font=Fonts.regular,size=24}, nil)
        end,

        roomEnter1 = function()
            self.eventBox:addEntry("To help you against the aliens, you can activate turrets by powering them up once a room is fully charged. Good Luck.")
            local onClick = function()
                self:deactivatePopup()
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
            self.eventBox:addEntry(skipText, {font=Fonts.regular,size=24}, nil)
        end,

        turretActivate1 = function()
            self.eventBox:addEntry("Click and hold on the turret until it reaches 100% to activate it. It will help you by automatically shooting the invaders.")
            local onClick = function()
                self:deactivatePopup()
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
            self.eventBox:addEntry(skipText, {font=Fonts.regular,size=24}, nil)
        end,
    }

    self.drawIndex = 100

    Signal.register('powerGridActivate', function()
        if self.firstPowerGrid then
            Timer.after(TWEAK.tutorial_popup_delay, function()
                self.firstPowerGrid = false
                self:setEvent("grid1")
            end)
        end
    end)

    Signal.register("Dynamo Toggle On", function()
        if self.firstDynamoOpen then
            Timer.after(TWEAK.tutorial_popup_delay, function()
                self.firstDynamoOpen = false
                self:setEvent("dynamo1")
            end)
        end
    end)

    Signal.register("Dynamo Correct", function()
        if self.firstDynamoCorrect then
            Timer.after(TWEAK.tutorial_popup_delay, function()
                self.firstDynamoCorrect = false
                self:setEvent("dynamoCorrect1")
            end)
        end
    end)

    Signal.register("enemyDeath", function()
        if self.firstEnemyDeath then
            Timer.after(TWEAK.tutorial_popup_delay, function()
                self.firstEnemyDeath = false
                self:setEvent("enemyDeath1")
            end)
        end
    end)

    Signal.register("turretActivate", function()
        if self.firstTurretActive then
            Timer.after(TWEAK.tutorial_popup_delay, function()
                self.firstTurretActive = false
                self:setEvent("turretActivate1")
            end)
        end
    end)

    Signal.register("Dynamo Toggle Off", function()
        if self.firstDynamoClose then
            Timer.after(TWEAK.tutorial_popup_delay, function()
                self.firstDynamoClose = false
                self.parent:spawnEnemy(true)
                self:setEvent("dynamoToggleOff1")
            end)
        end
    end)

    Signal.register("Enter Room", function(doesntCount)
        if self.firstRoomEnter and not doesntCount then
            Timer.after(TWEAK.tutorial_popup_delay, function()
                self.firstRoomEnter = false
                self:setEvent("roomEnter1")
            end)
        end
    end)

    self:reset()
end

function EventScene:deactivatePopup()
    if self.shownTime >= TWEAK.tutorial_min_showtime then
        self.shownTime = 0
        self.active = false
    end
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

    self.shownTime = 0

    self:setEvent("prologue1")

    self.active = true
end

function EventScene:skipTutorial()
    self.firstPowerGrid = false
    self.firstDynamoOpen = false
    self.firstDynamoCorrect = false
    self.firstEnemyDeath = false
    self.firstTurretActive = false
    self.firstDynamoClose = false
    self.firstRoomEnter = false

    self.active = false
end

function EventScene:setEvent(label)
    local drawnWidth, drawnHeight = self.parent:getCanvasDrawnSize()

    local w, h = drawnWidth*self.textBoxWidth, drawnHeight*self.textBoxHeight
    local x, y = love.graphics.getWidth()/2 - w/2, love.graphics.getHeight()/2 - h/2

    self.eventBox = TextBox:new(x, y, w, h, true)

    self.eventList[label]()

    self.eventBox:setToMaxScroll()
    self.active = true
end

function EventScene:resize(screenWidth, screenHeight)
    if self.eventBox then
        local w, h = screenWidth*self.textBoxWidth, screenHeight*self.textBoxHeight
        local x, y = love.graphics.getWidth()/2 - w/2, love.graphics.getHeight()/2 - h/2

        local fontScale = screenWidth / 1280

        self.eventBox:resize(x, y, w, h, fontScale)
    end
end

function EventScene:update(dt)
    if not self.active then return end

    self.shownTime = self.shownTime + dt

    if self.eventBox then
        self.eventBox:update()
    end
end

function EventScene:keypressed(key, code)
    if key == SETTINGS.skipTutorialKeybind then
        self:skipTutorial()
    end

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
