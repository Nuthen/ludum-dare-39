local victory = {}

function victory:init()

end

function victory:enter(prev)
    self.prevState = prev
end

function victory:update(dt)

end

function victory:keypressed(key, code)
    State.switch(States.game)
end

function victory:keyreleased(key, code)

end

function victory:touchreleased(id, x, y, dx, dy, pressure)

end

function victory:mousepressed(x, y, mbutton)

end

local function drawCenteredText(text, y)
    love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
end

function victory:draw()
    self.prevState:draw()
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local text = "YOU SURVIVED"
    love.graphics.setColor(33, 180, 33)
    love.graphics.setFont(Fonts.bold[72])
    drawCenteredText(text, love.graphics.getHeight()/4)

    -- SCORE
    local scoreText = ""
    if self.prevState.roundTime then
        scoreText = scoreText .. string.format("Completed in %.3f space seconds!\n", self.prevState.roundTime)
    end
    if self.prevState.enemyKills then
        scoreText = scoreText .. string.format("You killed " .. self.prevState.enemyKills .. " space squids!\n")
    end
    love.graphics.setColor(238, 230, 35)
    love.graphics.setFont(Fonts.bold[52])
    drawCenteredText(scoreText, love.graphics.getHeight()/2)

    local text = "Press any key to restart"
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(Fonts.default[36])
    drawCenteredText(text, love.graphics.getHeight()*3/4)
end

return victory
