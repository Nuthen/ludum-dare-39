local Scene = require 'entities.scene'
local Dynamo = require 'entities.scenes.dynamo'

local game = {}

function game:init()
    self.dynamo = Dynamo:new()
    self.scene = Scene:new()

    self.grid = require 'data.ship'
    self.gridWidth = #self.grid[1] -- cells
    self.gridHeight = #self.grid -- cells
    self.cellWidth = 32 -- pixels
    self.cellHeight = 32 -- pixels

    -- Convert row-major to column-major
    local columnMajorGrid = {}
    for x = 1, self.gridWidth do
        columnMajorGrid[x] = {}
        for y = 1, self.gridHeight do
            columnMajorGrid[x][y] = self.grid[y][x]
        end
    end
    self.grid = columnMajorGrid

    self.scene:add{
        draw = function(self)
            for x = 1, game.gridWidth do
                for y = 1, game.gridHeight do
                    local cellValue = game.grid[x][y]
                    if cellValue == 0 then
                        love.graphics.setColor(33, 33, 33)
                    elseif cellValue == 1 then
                        love.graphics.setColor(255, 255, 255)
                    end
                    love.graphics.rectangle('fill', x*game.cellWidth, y*game.cellHeight, game.cellWidth, game.cellHeight)
                end
            end
        end,
    }
end

function game:enter()

end

function game:update(dt)
    self.scene:update(dt)
    self.dynamo:update(dt)
end

function game:keypressed(key, code)
    self.scene:keypressed(key, code)
    self.dynamo:keypressed(key, code)
end

function game:keyreleased(key, code)
    self.scene:keyreleased(key, code)
    self.dynamo:keyreleased(key, code)
end

function game:mousepressed(x, y, mbutton)
    self.scene:mousepressed(x, y, mbutton)
    self.dynamo:mousepressed(x, y, mbutton)
end

function game:mousereleased(x, y, mbutton)
    self.scene:mousereleased(x, y, mbutton)
    self.dynamo:mousereleased(x, y, mbutton)
end

function game:mousemoved(x, y, dx, dy, istouch)
    self.scene:mousemoved(x, y, dx, dy, istouch)
    self.dynamo:mousemoved(x, y, dx, dy, istouch)
end

function game:draw()
    self.scene:draw()
    self.dynamo:draw()
end

return game
