local Scene = require "entities.scene"
local TextBox = require "entities.textbox"

local EventScene = Class("EventScene", Scene)

function EventScene:initialize(parent)
    self.parent = parent

    local continueText = "\n(Click here or press space to continue)"

    self.eventList = {
        prologue1 = function()
            self.eventBox:addEntry("Your fellow crew have all died. You are the last hope to get your derelict spaceship through dangerous territory.")
            local onClick = function()
                self.active = false
            end
            self.eventBox:addEntry(continueText, nil, nil, {clickTrigger=onClick,hoverTrigger=function() end}, "space")
        end,

        grid1 = function()
            self.eventBox:addEntry("Congrats on powering your first grid!")
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

    self:reset()
end

function EventScene:reset()
    --[[
    self.firstPowerGrid
    self.firstEnemy
    .. etc

    ]]

    self.firstPowerGrid = true

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
    local w, h = love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.8
    local x, y = love.graphics.getWidth()/2 - w/2, love.graphics.getHeight()/2 - h/2

    self.eventBox = TextBox:new(x, y, w, h, true)

    self.eventList[label]()

    self.eventBox:setToMaxScroll()
    self.active = true
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
