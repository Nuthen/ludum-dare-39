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
    self.gridX = 300
    self.gridY = 300
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

    local function screenToGrid(sx, sy)
        local gx = ((sx / self.tileWidth / 2) + (sy / self.tileDepth / 2)) / 2 + 1
        local gy = ((sy / self.tileDepth / 2) - (sx / self.tileWidth / 2)) / 2 + 1
        return Lume.round(gx), Lume.round(gy)
        -- local a = 0.5
        -- local b = self.tileDepth
        -- local x = math.floor((x-y*a)/b)
        -- local y = math.floor((x+y*a)/b)
        -- return x, y
    end

    local function gridToScreen(gx, gy)
        -- local tx = game.gridX + ((x-y) * (game.tileWidth / 2))
        -- local ty = game.gridY + ((x+y) * (game.tileDepth / 2)) - (game.tileDepth * (game.tileHeight / 2))
        local x = (gx - gy) * game.tileWidth / 2
        local y = (gx + gy) * game.tileDepth / 2
        return x, y
    end

    self.gridScreenWidth  = self.gridWidth  * self.tileWidth
    self.gridScreenHeight = self.gridHeight * self.tileDepth

    self.scene:add{
        hoverX = nil,
        hoverY = nil,

        update = function(self, dt)
            local mx, my = love.mouse.getPosition()
            mx = game.gridX - mx
            my = game.gridY - my
            self.hoverX, self.hoverY = screenToGrid(-mx, -my)
        end,

        draw = function(self)
            love.graphics.print(self.hoverX .. ', ' .. self.hoverY, 10, 10)
            love.graphics.push()
            love.graphics.translate(game.gridX, game.gridY)
            for x = 1, game.gridWidth do
                for y = 1, game.gridHeight do
                    if x == self.hoverX and y == self.hoverY then
                        love.graphics.setColor(255, 0, 0)
                    else
                        love.graphics.setColor(255, 255, 255)
                    end

                    -- Calculate isometric tile positions
                    -- @TODO gridX and gridY are actually nowhere near the center of the grid
                    tx, ty = gridToScreen(x, y)
                    local cellValue = game.grid[x][y]
                    if cellValue == 1 then
                        love.graphics.setFont(Fonts.monospace[12])
                        love.graphics.print(x .. ',' .. y, tx, ty - 15)
                        love.graphics.draw(game.isoSprite, tx, ty)
                    end

                    -- @Debug
                    love.graphics.rectangle('line',  0, 0, game.gridScreenWidth, game.gridScreenHeight)
                end
            end
            love.graphics.pop()
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
