local Scene = require 'entities.scene'
local Dynamo = require 'entities.scenes.dynamo'
local Sprite = require 'entities.sprite'
local Enemy = require 'entities.enemy'
local MouseAction = require 'entities.mouse_action'
local Map = require 'entities.ui.map'
local SoundManager = require 'entities.sound_manager'

local Bit = require 'bit'

local game = {}

function game:init()
    self.catalogs = {
        art   = require 'catalogs.art',
        sound = require 'catalogs.sound',
        music = require 'catalogs.music',
    }
end

function game:reset()
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

    Signal.clear()

    self.scene = Scene:new()

    self.soundManager = SoundManager:new(self.catalogs.sound, self.catalogs.music)

    self.emptyTile = love.graphics.newImage(self.catalogs.art.empty)
    self.shipBitmask = love.image.newImageData(self.catalogs.art.ship_bitmask)

    -- Map (r, g, b) -> unique int
    local function getColorHash(r, g, b)
        return Bit.bor(Bit.lshift(r, 32), Bit.lshift(g, 16), b)
    end

    -- All possible tiles on the ship
    self.grid = {}

    -- All available (not empty space) tiles on the ship
    self.tiles = {}

    -- Same as grid, but contains room hash instead
    self.rooms = {}

    -- Hash table of all room hashes
    self.roomHashes = {}

    -- Enemy entities indexed by x, y
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
                table.insert(self.tiles, {x=x, y=y})
                self.roomHashes[getColorHash(r, g, b)] = true
            end
        end
    end

    self.gridX = CANVAS_WIDTH/2
    self.gridY = CANVAS_HEIGHT/2
    self.gridWidth = #self.grid[1] -- tiles
    self.gridHeight = #self.grid -- tiles
    self.tileWidth = self.emptyTile:getWidth() -- pixels
    self.tileHeight = self.emptyTile:getHeight() -- pixels
    self.tileDepth = self.tileHeight / 2

    self.mouseAction = self.scene:add(MouseAction:new(self))

    -- Every so often add a new enemy
    self.timer = Timer.new()
    self.timer:every(TWEAK.enemySpawnRate, function()
        local ex, ey
        local enemy
        local notAnEmptySpace
        local tries = 0
        local maxTries = TWEAK.enemySpawnMaxTries
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

    -- Grid drawing code
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
                    if cellValue == 1 and
                       (roomNumber == 0 or
                        roomNumber == game.currentRoom) then
                        love.graphics.draw(sprite, tx, ty)
                    end

                    local enemy = game:getEnemy(x, y)
                    if enemy and
                       (roomNumber == 0 or
                        roomNumber == game.currentRoom) then
                        enemy:draw()
                    end
                end
            end

            -- Grid bounding box
            love.graphics.rectangle('line',  gx, gy, gw, gh)
            love.graphics.pop()
        end,
    }
    self.dynamo = Dynamo:new(self, {
        game = self,
    })

    if TWEAK.minimapOnGame then
        self.minimap = Map:new(self, {
            game = self,
            position = Vector(120, 120),
        })
    end

    self.power = 1 -- [0, 1]

    self.totalRooms = 9
    self.totalPoweredRooms = 0

    self.currentRoom = -1

    Signal.emit('gameStart')
end

function game:enter()
    self:reset()
end

function game:update(dt)
    self.timer:update(dt)
    self.scene:update(dt)
    self.dynamo:update(dt)
    self.soundManager:update(dt)

    if self.totalPoweredRooms == self.totalRooms then
        State.switch(States.victory)
    end

    -- Check all rooms for occupying enemies
    local occupiedRooms = 0
    for hash in pairs(self.roomHashes) do
        local roomTiles = self:getRoomTiles(hash)
        local occupiedTiles = 0
        for i, tile in ipairs(roomTiles) do
            if self:getEnemy(tile.x, tile.y) then
                occupiedTiles = occupiedTiles + 1
            end
        end
        if occupiedTiles >= #roomTiles then
            occupiedRooms = occupiedRooms + 1
        end
    end

    if self.power <= 0 or occupiedRooms >= 1 then
        State.switch(States.gameover)
    end
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
    x, y = self:screenToCanvas(x, y)
    self.scene:mousepressed(x, y, mbutton)
    self.dynamo:mousepressed(x, y, mbutton)
end

function game:mousereleased(x, y, mbutton)
    x, y = self:screenToCanvas(x, y)
    self.scene:mousereleased(x, y, mbutton)
    self.dynamo:mousereleased(x, y, mbutton)

    if self.minimap then self.minimap:mousereleased(x, y, mbutton) end
end

function game:mousemoved(x, y, dx, dy, istouch)
    x, y = self:screenToCanvas(x, y)
    dx, dy = self:screenToCanvas(dx, dy)

    self.scene:mousemoved(x, y, dx, dy, istouch)
    self.dynamo:mousemoved(x, y, dx, dy, istouch)

    if self.minimap then self.minimap:mousemoved(x, y, dx, dy, istouch) end
end

function game:wheelmoved(x, y)
    x, y = self:screenToCanvas(x, y)
    self.scene:wheelmoved(x, y)
    self.dynamo:wheelmoved(x, y)
end

function game:draw()
    local scale = self:getScale()
    local drawnWidth, drawnHeight = CANVAS_WIDTH*scale, CANVAS_HEIGHT*scale
    local x, y = math.floor(love.graphics.getWidth()/2 - drawnWidth/2), math.floor(love.graphics.getHeight()/2 - drawnHeight/2)

    self.canvas:renderTo(function()
        love.graphics.clear()
        self.scene:draw()
        if self.minimap then self.minimap:draw() end
        self.dynamo:draw()

        love.graphics.setColor(127, 127, 127)
        love.graphics.rectangle('line', 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
    end)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.canvas, x, y, 0, scale)
end

function game:getScale()
    return math.min(math.floor(love.graphics.getWidth() /CANVAS_WIDTH),
                           math.floor(love.graphics.getHeight()/CANVAS_HEIGHT))
end

function game:screenToCanvas(x, y)
    local scale = self:getScale()
    local drawnWidth, drawnHeight = CANVAS_WIDTH*scale, CANVAS_HEIGHT*scale
    local displacementX, displacementY = math.floor(love.graphics.getWidth()/2 - drawnWidth/2), math.floor(love.graphics.getHeight()/2 - drawnHeight/2)

    return (x - displacementX) / scale, (y - displacementY) / scale
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

function game:getRoom(x, y)
    return self.rooms[x] and self.rooms[x][y] or nil
end

function game:getRoomTiles(hash)
    local tiles = {}

    for i, tile in ipairs(self.tiles) do
        if self:getRoom(tile.x, tile.y) == hash then
            table.insert(tiles, tile)
        end
    end

    return tiles
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
