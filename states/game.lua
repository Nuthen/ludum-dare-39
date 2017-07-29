local Scene = require 'entities.scene'
local Dynamo = require 'entities.scenes.dynamo'
local Sprite = require 'entities.sprite'

local game = {}

function game:init()
    self.dynamo = Dynamo:new()
    self.scene = Scene:new()

    self.catalogs = {
        art = require 'catalogs.art',
    }

    self.isoSprite = love.graphics.newImage(self.catalogs.art.iso_tile)

    self.grid = require 'data.ship'
    self.gridX = 600
    self.gridY = 500
    self.gridWidth = #self.grid[1] -- tiles
    self.gridHeight = #self.grid -- tiles
    self.tileWidth = self.isoSprite:getWidth() -- pixels
    self.tileHeight = self.isoSprite:getHeight() -- pixels
    self.tileDepth = self.tileHeight / 2

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
                    -- Calculate isometric tile positions
                    -- @TODO gridX and gridY are actually nowhere near the center of the grid
                    local tx = game.gridX + ((x-y) * (game.tileWidth / 2))
                    local ty = game.gridY + ((x+y) * (game.tileDepth / 2)) - (game.tileDepth * (game.tileHeight / 2))
                    local cellValue = game.grid[x][y]
                    if cellValue == 1 then
                        love.graphics.draw(game.isoSprite, tx, ty)
                    end
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
