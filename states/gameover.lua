local gameover = {}

function gameover:init()

end

function gameover:enter(prev)
    self.prevState = prev
end

function gameover:update(dt)

end

function gameover:keypressed(key, code)
    State.switch(States.game)
end

function gameover:keyreleased(key, code)

end

function gameover:touchreleased(id, x, y, dx, dy, pressure)

end

function gameover:mousepressed(x, y, mbutton)

end

local function drawCenteredText(text, y)
    love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
end

function gameover:draw()
    self.prevState:draw()
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local text = "YOU DIED"
    love.graphics.setColor(180, 33, 33)
    love.graphics.setFont(Fonts.bold[72])
    drawCenteredText(text, 100)

    local text = "Press any key to restart"
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(Fonts.default[36])
    drawCenteredText(text, love.graphics.getHeight()/2)
end

return gameover
