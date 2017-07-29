local Scene = require 'entities.scene'

local game = {}

function game:init()
    self.scene = Scene()
end

function game:enter()

end

function game:update(dt)
    self.scene:update(dt)
end

function game:keypressed(key, code)
    self.scene:keypressed(key, code)
end

function game:keyreleased(key, code)
    self.scene:keyreleased(key, code)
end

function game:mousepressed(x, y, mbutton)
    self.scene:mousepressed(x, y, mbutton)
end

function game:mousereleased(x, y, mbutton)
    self.scene:mousereleased(x, y, mbutton)
end

function game:mousemoved(x, y, dx, dy, istouch)
    self.scene:mousereleased(x, y, dx, dy, istouch)
end

function game:draw()
    self.scene:draw()
end

return game
