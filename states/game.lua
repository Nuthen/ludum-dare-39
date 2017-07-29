local Scene = require 'entities.scene'
local Dynamo = require 'entities.scenes.dynamo'
local Sprite = require 'entities.sprite'

local Bit = require 'bit'

local game = {}

function game:init()
    self.dynamo = Dynamo:new()
    self.scene = Scene:new()

    self.catalogs = {
        art = require 'catalogs.art',
    }

    self.isoSprite = love.graphics.newImage(self.catalogs.art.iso_tile)
    self.shipBitmask = love.image.newImageData(self.catalogs.art.ship_bitmask)

    -- Map (r, g, b) -> unique int
    local function getColorHash(r, g, b)
        return Bit.bor(Bit.lshift(r, 32), Bit.lshift(g, 16), b)
    end

    self.grid = {}
    self.rooms = {}
    self.enemies = {}
    for x = 1, self.shipBitmask:getWidth() do
        self.grid[x] = {}
        self.rooms[x] = {}
        self.enemies[x] = {}
        for y = 1, self.shipBitmask:getHeight() do
            local r, g, b, a = self.shipBitmask:getPixel(x - 1, y - 1)
            self.grid[x][y] = 0
            self.rooms[x][y] = 0
            self.enemies[x][y] = 0
            if not (r == 0 and g == 0 and b == 0 and a == 0) then
                self.grid[x][y] = 1
                self.rooms[x][y] = getColorHash(r, g, b)
            end
        end
    end

    self.gridX = love.graphics.getWidth()/2
    self.gridY = love.graphics.getHeight()/2
    self.gridWidth = #self.grid[1] -- tiles
    self.gridHeight = #self.grid -- tiles
    self.tileWidth = self.isoSprite:getWidth() -- pixels
    self.tileHeight = self.isoSprite:getHeight() -- pixels
    self.tileDepth = self.tileHeight / 2

    self.scene:add{
        hoverX = nil,
        hoverY = nil,

        update = function(self, dt)
            local mx, my = love.mouse.getPosition()
            local gx, gy, gw, gh = game:getGridBoundingBox()
            local translatedX = gx - game.gridX + gw/2
            local translatedY = gy - game.gridY + gh/2
            mx = -translatedX - mx
            my = -translatedY - my
            mx = mx + game.tileWidth / 2
            my = my + game.tileHeight
            self.hoverX, self.hoverY = game:screenToGrid(-mx, -my)
        end,

        draw = function(self)
            love.graphics.print(self.hoverX .. ', ' .. self.hoverY, 10, 10)
            love.graphics.push()
            local gx, gy, gw, gh = game:getGridBoundingBox()
            local translatedX = gx - game.gridX + gw/2
            local translatedY = gy - game.gridY + gh/2
            love.graphics.translate(-translatedX, -translatedY)

            for x = 1, game.gridWidth do
                for y = 1, game.gridHeight do
                    local roomNumber = game.rooms[x][y]

                    if x == self.hoverX and y == self.hoverY then
                        love.graphics.setColor(255, 0, 0)
                    elseif game.enemies[x][y] > 0 then
                        love.graphics.setColor(0, 255, 0)
                    elseif roomNumber > 0 then
                        love.graphics.setColor(255, 128, 255)
                    else
                        love.graphics.setColor(255, 255, 255)
                    end

                    tx, ty = game:gridToScreen(x, y)
                    local cellValue = game.grid[x][y]
                    if cellValue == 1 then
                        love.graphics.draw(game.isoSprite, tx, ty)
                    end
                end
            end

            -- Grid bounding box
            love.graphics.rectangle('line',  gx, gy, gw, gh)
            love.graphics.pop()
        end,
    }

    -- Every so often add a new enemy
    Timer.every(1, function()
        local ex, ey
        local enemy
        local notAnEmptySpace
        -- Locate empty square
        repeat
            ex = love.math.random(self.gridWidth)
            ey = love.math.random(self.gridHeight)
            enemy = self.enemies[ex][ey]
            notAnEmptySpace = self.grid[ex][ey] > 0
        until (enemy == 0 and notAnEmptySpace)
        self.enemies[ex][ey] = 1
    end)
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

function game:screenToGrid(sx, sy)
    local gx = ((sx / (self.tileWidth / 2)) + (sy / (self.tileDepth / 2))) / 2 + 1
    local gy = ((sy / (self.tileDepth / 2)) - (sx / (self.tileWidth / 2))) / 2 + 1
    return Lume.round(gx), Lume.round(gy)
end

function game:gridToScreen(gx, gy)
    local x = (gx - gy) * game.tileWidth / 2
    local y = (gx + gy) * game.tileDepth / 2
    return x, y
end

function game:getGridBoundingBox()
    local xFudge = 0
    local yFudge = 4
    local w = self.gridWidth  * self.tileWidth + xFudge
    local h = self.gridHeight * self.tileDepth + yFudge
    local x = -w/2 + self.tileWidth/2 - xFudge * 2
    local y = self.tileHeight         - yFudge * 2
    return x, y, w, h
end

return game
