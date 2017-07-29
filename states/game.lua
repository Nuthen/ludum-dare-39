local Scene = require 'entities.scene'
local Dynamo = require 'entities.scenes.dynamo'
local Sprite = require 'entities.sprite'
local Enemy = require 'entities.enemy'
local MouseAction = require 'entities.mouse_action'

local Bit = require 'bit'

local game = {}

function game:init()
    self.tweak = require 'config.tweak'

    self.scene = Scene:new()

    self.catalogs = {
        art = require 'catalogs.art',
    }

    self.emptyTile = love.graphics.newImage(self.catalogs.art.empty)
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
            self.enemies[x][y] = nil
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
    self.tileWidth = self.emptyTile:getWidth() -- pixels
    self.tileHeight = self.emptyTile:getHeight() -- pixels
    self.tileDepth = self.tileHeight / 2

    self.mouseAction = self.scene:add(MouseAction:new(self))

    -- Every so often add a new enemy
    Timer.every(self.tweak.enemySpawnRate, function()
        local ex, ey
        local enemy
        local notAnEmptySpace
        local tries = 0
        local maxTries = self.tweak.enemySpawnMaxTries
        -- Locate empty square
        repeat
            tries = tries + 1
            ex = love.math.random(self.gridWidth)
            ey = love.math.random(self.gridHeight)
            enemy = self.enemies[ex][ey]
            notAnEmptySpace = self.grid[ex][ey] > 0
        until (notAnEmptySpace or tries >= maxTries)
        self:addEnemy(ex, ey)
    end)

    self.scene:add{
        draw = function(self)
            love.graphics.push()
            local gx, gy, gw, gh = game:getGridBoundingBox()
            local translatedX = gx - game.gridX + gw/2
            local translatedY = gy - game.gridY + gh/2
            love.graphics.translate(-translatedX, -translatedY)

            for x = 1, game.gridWidth do
                for y = 1, game.gridHeight do
                    local roomNumber = game.rooms[x][y]

                    local sprite = game.emptyTile

                    if x == game.mouseAction.hoverX and y == game.mouseAction.hoverY then
                        love.graphics.setColor(255, 0, 0)
                    else
                        love.graphics.setColor(255, 255, 255)
                    end

                    tx, ty = game:gridToScreen(x, y)
                    local cellValue = game.grid[x][y]
                    if cellValue == 1 then
                        love.graphics.draw(sprite, tx, ty)
                    end

                    local enemy = game:getEnemy(x, y)
                    if enemy then
                        enemy:draw()
                    end
                end
            end

            -- Grid bounding box
            love.graphics.rectangle('line',  gx, gy, gw, gh)
            love.graphics.pop()
        end,
    }
    self.dynamo = Dynamo:new(self)
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

function game:isShipTile(x, y)
    return self.grid[x] and self.grid[x][y] and self.grid[x][y] > 0
end

function game:hasEnemy(x, y)
    return self:isShipTile(x, y) and self.enemies[x] and self.enemies[x][y] ~= nil
end

function game:getEnemy(x, y)
    return self:hasEnemy(x, y) and self.enemies[x][y] or nil
end

function game:addEnemy(x, y)
    local enemy = self:getEnemy(x, y)
    if enemy then
        enemy:evolve()
    else
        self.enemies[x][y] = Enemy:new(self, x, y)
    end
end

return game
