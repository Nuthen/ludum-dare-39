local TextGroup = Class("TextGroup")

function TextGroup:initialize(x, y, w, h, cachedText)
    self.texts = {}
    self.cache = cachedText or {}

    self:resize(x, y, w, h)
end

function TextGroup:calculateMaxOffset()
    local maxY = self.origin.y

    for k, text in pairs(self.texts) do
        for _, index in pairs(text.indices) do
            local x, y = text.positions[index].x, text.positions[index].y
            local w, h = text.textInstance:getDimensions(index)

            maxY = math.max(maxY, y+h)
        end
    end

    return maxY - self.origin.y
end

function TextGroup:calculateOverflow()
    local maxOffset = self:calculateMaxOffset()

    return -(math.max(self.h, maxOffset) - self.h)
end

function TextGroup:addNewTextInstance(font, color, triggers)
    local newFontData = self.defaultFont
    if font then
        newFontData = font
    end
    local newFont = (newFontData.font)[newFontData.size]
    local newText = love.graphics.newText(newFont)

    triggers = triggers or {}

    local color = color or {66, 66, 66}
    local highlightColor = {255, 153, 0}
    local hoverColor = {50, 153, 187}

    local hoverTrigger = triggers.hoverTrigger or nil
    local clickTrigger = triggers.clickTrigger or nil

    table.insert(self.texts, {
        textInstance=newText,
        color=color,
        hoverColor=hoverColor,
        highlightColor = highlightColor,
        positions={},
        hoverTrigger=hoverTrigger,
        clickTrigger=clickTrigger,
        highlight=false,
        indices={},
    })
end

function TextGroup:resize(x, y, w, h, fontScale)
    self.fontScale = fontScale or 1
    self.defaultFont = {font=Fonts.regular, size = 48}

    self.origin = Vector(x, y)
    self.w, self.h = w, h

    self.textPointer = Vector(self.origin.x, self.origin.y)

    for i = 1, #self.texts do
        local text = self.texts[i]
        --text.textInstance:clear()
        text = nil
    end

    self.texts = {
        -- {
        --     textInstance  = Text ...
        --     textPositions = {}   ...
        --     activateInput = key  ...
        --     fontSize      = Num  ...
        -- }
    }

    self:addNewTextInstance()
    self.currentLineMaxHeight = self.texts[1].textInstance:getFont():getHeight()

    for _, cachedText in ipairs(self.cache) do
        local font
        if cachedText.font then
            font = {font=cachedText.font.font, size=cachedText.font.size}
        else
            font = {font=self.defaultFont.font, size=self.defaultFont.size}
        end

        font.size = math.floor(font.size * self.fontScale)
        font.size = math.ceil(font.size/16) * 16

        self:addText(cachedText.text, font, cachedText.color, cachedText.triggers, cachedText.activateInput, nil, true)
    end
end

function TextGroup:update(x, y)
    x, y = x or 0, y or 0

    local mx, my = love.mouse.getPosition()

    local textObject, hoverX, hoverY, w, h = self:calculateHover(mx + x, my + y)
    if textObject then
        if textObject.hoverTrigger or textObject.clickTrigger then
            textObject.highlight = true
        end
        if textObject.hoverTrigger then
            textObject.hoverTrigger(hoverX, hoverY, w, h)
        end
    end
end

function TextGroup:keypressed(key, code)
    for k, text in pairs(self.texts) do
        if key == text.activateInput then
            if text.clickTrigger then
                text.clickTrigger()
            end
        end
    end
end

function TextGroup:mousepressed(mx, my, mbutton)
    local textObject = self:calculateHover(mx, my)
    if textObject and textObject.clickTrigger then
        textObject.clickTrigger()
    end
end

function TextGroup:calculateHover(mx, my)
    for k, text in pairs(self.texts) do
        text.highlight = false
    end

    for k, text in pairs(self.texts) do
        for _, index in pairs(text.indices) do
            local x, y = text.positions[index].x, text.positions[index].y
            local w, h = text.textInstance:getDimensions(index)

            if mx >= x and mx <= x+w and my >= y and my <= y+h then
                return text, x, y, w, h
            end
        end
    end
end

function TextGroup:newLine()
    local lineHeight = self.currentLineMaxHeight

    self.textPointer.x = self.origin.x
    self.textPointer.y = self.textPointer.y + lineHeight

    self.currentLineMaxHeight = self.texts[1].textInstance:getFont():getHeight()
end

function TextGroup:addText(text, setFont, color, triggers, activateInput, textIndex, isCached, isNotFirst)
    local isNotFirst = isNotFirst or false
    local textIndex = textIndex or 1
    local advancedLine = false

    if textIndex == 1 and not isCached and not isNotFirst then
        table.insert(self.cache, {text=text,font=setFont,color=color,triggers=triggers,activateInput=activateInput})
    end

    if setFont or (triggers) then
        -- if it is a set font that has not been instantiated yet, then create a new instance
        if textIndex == 1 then
            self:addNewTextInstance(setFont, color, triggers)
        end

        -- this assumes that the new text is instantiated at the end of the table
        textIndex = #self.texts
    end


    local textInstance = self.texts[textIndex].textInstance
    local fontData = setFont or self.defaultFont
    local font = fontData.font[fontData.size]
    local textString = ""
    if type(text) == "string" then
        textString = text
    elseif type(text) == "table" then
        error("Error: There is no support for table text. Ask the programmer about it.")
    else
        error("Error: Invalid text data entered.")
    end

    local textWidth, textHeight = font:getWidth(textString), font:getHeight()

    -- track the max height for printed text on the current line
    self.currentLineMaxHeight = math.max(self.currentLineMaxHeight, textHeight)

    local wrapLimit = self.origin.x + self.w - self.textPointer.x
    local maxWidth, wrappedText = font:getWrap(textString, wrapLimit)

    -- use the wrapped text to take the text on the first line and just call addText again with the remaining text
    if #wrappedText > 0 then
        local printText = wrappedText[1]

        -- Search for any newline characters
        -- If one is found, then print up to that point, remove the newline character, and add a line
        local newLineStart, newLineEnd = string.find(printText, "\n")

        local printTextWidth = font:getWidth(printText)

        local x, y = math.floor(self.textPointer.x), math.floor(self.textPointer.y)

        local index = textInstance:add(wrappedText[1], x, y)
        table.insert(self.texts[textIndex].indices, index)

        -- store the position so it can be used later
        self.texts[textIndex].positions[index] = Vector(x, y)
        self.texts[textIndex].activateInput = activateInput

        self.textPointer.x = self.textPointer.x + printTextWidth

        -- remove the printed bit of text from the string
        local newString = string.sub(textString, printText:len()+1)

        local newLineStart, newLineEnd = string.find(newString, "\n")
        if (self.origin.x + self.w) < (self.textPointer.x + printTextWidth) then
            self:newLine()
            advancedLine = true
        end
        if newLineStart and newLineStart == 1 then
            -- remove the first new line character
            newString = string.gsub(newString, "\n", "", 1)
            if not advancedLine then
                self:newLine()
                advancedLine = true
            end
        end

        if newString:len() > 0 and newString ~= printText then
            self:addText(newString, setFont, color, triggers, activateInput, textIndex, isCached, true)
        end
    end
end

function TextGroup:draw(x, y)
    x, y = x or 0, y or 0

    for k, text in pairs(self.texts) do
        love.graphics.setColor(22, 22, 22)
        if text.color then
            love.graphics.setColor(text.color)
        end
        if text.hoverTrigger then
            if text.hoverColor then
                love.graphics.setColor(text.hoverColor)
            else
                love.graphics.setColor(255, 0, 0)
            end
        end
        if text.highlight then
            if text.highlightColor then
                love.graphics.setColor(text.highlightColor)
            else
                love.graphics.setColor(0, 0, 255)
            end
        end
        love.graphics.draw(text.textInstance, x, y)
    end

    if DEBUG and SHOW_TEXT_POINTER then
        love.graphics.setColor(255, 0, 0)
        love.graphics.circle('fill', self.textPointer.x + x, self.textPointer.y + y, 5)
    end
end



local TextBox = Class("TextBox")

function TextBox:initialize(x, y, w, h, hasScrollbar)
    self.x, self.y = x, y
    self.w, self.h = w, h

    self.margin = 20
    self.scrollAmount = 0
    self.deltaScroll = 0
    self.manualScrollSpeed = 10

    self.scrollBarWidth = 5
    self.hasScrollbar = hasScrollbar or false

    local textGroupWidth = self.w - self.margin*2
    if self.hasScrollbar then
        textGroupWidth = textGroupWidth - self.scrollBarWidth
    end

    self.textGroup = TextGroup:new(x + self.margin, y + self.margin, textGroupWidth, self.h - self.margin*2)

    self.borderColor = {22, 22, 22}
    self.backgroundColor = {233, 233, 233}
end

function TextBox:setToMaxScroll()
    self:updateScroll()
    self.deltaScroll = math.abs(self.scrollAmount)
end

function TextBox:setText(string)
    -- deceptive name
    self.textGroup:addText(string)
end

function TextBox:addEntry(string, font, color, triggers, activateInput)
    self.textGroup:addText(string, font, color, triggers, activateInput)
end

function TextBox:resize(x, y, w, h, fontScale)
    fontScale = fontScale or 1

    self.x, self.y = x, y
    self.w, self.h = w, h

    local textGroupWidth = self.w - self.margin*2
    if self.hasScrollbar then
        textGroupWidth = textGroupWidth - self.scrollBarWidth
    end

    self.textGroup:resize(x + self.margin, y + self.margin, textGroupWidth, self.h - self.margin*2, fontScale)

    self.scrollAmount = self.textGroup:calculateOverflow()
end

function TextBox:updateScroll()
    self.scrollAmount = self.textGroup:calculateOverflow()
    self.textGroup:update(0, -self.scrollAmount - self.deltaScroll)
end

function TextBox:update()
    self:updateScroll()
end

function TextBox:keypressed(key, code)
    self.textGroup:keypressed(key, code)
end

function TextBox:mousepressed(x, y, mbutton)
    y = y - self.scrollAmount - self.deltaScroll
    self.textGroup:mousepressed(x, y, mbutton)
end

function TextBox:wheelmoved(x, y)
    local maxOffset = self.textGroup:calculateMaxOffset() - self.textGroup.h

    self.deltaScroll = self.deltaScroll - y * self.manualScrollSpeed
    self.deltaScroll = math.max(0, math.min(maxOffset, self.deltaScroll))
end

function TextBox:draw()
    local margin = self.margin

    local wrapLimit = self.w - margin*2
    local font = love.graphics.getFont()

    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.setScissor(self.x, self.y, self.w, self.h)
    self.textGroup:draw(0, self.scrollAmount+self.deltaScroll)
    love.graphics.setScissor()
    if self.hasScrollbar and self.scrollAmount ~= 0 then
        self:drawScrollbar()
    end
end

function TextBox:drawScrollbar()
    local margin = self.margin
    local x, y = self.x+self.w-self.margin-self.scrollBarWidth, self.y+self.margin

    local heightPercent = self.textGroup.h / math.max(self.textGroup.h, self.textGroup:calculateMaxOffset())
    local scrollBarHeight = (self.h-margin*2) * heightPercent
    local scrollBarNonHeight = (self.h-margin*2) * (1-heightPercent)

    local scrollPercent
    -- prevent divide by 0
    if self.scrollAmount == 0 then
        scrollPercent = 0
    else
        scrollPercent = self.deltaScroll / self.scrollAmount
    end
    -- position the scrollbar according to how far it is scrolled
    -- note that the calculated percent must be adjusted from [-1, 0] to [0, 1]
    y = y + scrollBarNonHeight * (scrollPercent+1)

    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", x, y, self.scrollBarWidth, scrollBarHeight)
end

return TextBox
