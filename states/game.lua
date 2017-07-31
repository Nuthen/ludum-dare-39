local Scene = require 'entities.scene'
local Dynamo = require 'entities.scenes.dynamo'
local Sprite = require 'entities.sprite'
local MouseAction = require 'entities.mouse_action'
local Map = require 'entities.ui.map'
local SoundManager = require 'entities.sound_manager'
local ParticleSystem = require 'entities.fx.particle'

local Enemy = require 'entities.enemy'
local Turret = require 'entities.turret'
local PowerGrid = require 'entities.powergrid'

local Bit = require 'bit'

local game = {}

function game:init()
    self.catalogs = {
        art       = require 'catalogs.art',
        sound     = require 'catalogs.sound',
        music     = require 'catalogs.music',
        animation = require 'catalogs.animation',
    }

    self:loadAnimations(Enemy, 'alien', 'data.alien_animations')
    self:loadAnimations(Turret, 'turret', 'data.turret_animations')
    self:loadAnimations(PowerGrid, 'powergrid', 'data.powergrid_animations')

    Signal.register("Enter Room", function()
        local roomX, roomY, roomWidth, roomHeight = self:getActiveRoomBoundingBox()
        if roomX then
            -- camera centered on room
            local gx, gy, gw, gh = game:getGridBoundingBox()
            local translatedX = gx - game.gridX + gw/2
            local translatedY = gy - game.gridY + gh/2

            self.cameraGoal.x = -translatedX + roomX + roomWidth/2
            self.cameraGoal.y = -translatedY + roomY + roomHeight/2
        end
    end)

    Signal.register("enemyDeath", function()
        self.enemyKills = self.enemyKills + 1
    end)

    Signal.register("powerGridActivate", function()
        self.dynamo:powerGridActivated(self.totalPoweredRooms)
    end)
end

function game:reset()
    self.canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

    Signal.clear()

    self.scene = Scene:new()

    if not self.soundManager then
        self.soundManager = SoundManager:new(self.catalogs.sound, self.catalogs.music)
    end

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

    -- Turret entities indexed by x, y
    self.turrets = {}

    -- Power grid entities indexed by x, y
    self.powerGrids = {}
    self.powerGridRooms = {}

    for x = 1, self.shipBitmask:getWidth() do
        self.grid[x] = {}
        self.rooms[x] = {}
        self.enemies[x] = {}
        self.turrets[x] = {}
        self.powerGrids[x] = {}
        for y = 1, self.shipBitmask:getHeight() do
            local r, g, b, a = self.shipBitmask:getPixel(x - 1, y - 1)
            self.grid[x][y] = 0
            self.rooms[x][y] = 0
            self.enemies[x][y] = nil
            self.turrets[x][y] = nil
            self.powerGrids[x][y] = nil
            if not (r == 0 and g == 0 and b == 0 and a == 0) then
                self.grid[x][y] = 1
                self.rooms[x][y] = getColorHash(r, g, b)
                table.insert(self.tiles, {x=x, y=y})
                self.roomHashes[getColorHash(r, g, b)] = true
            end
        end
    end

    local function placePowerGrid(x, y, rx, ry)
        local roomType = self.rooms[rx][ry]
        local grid = PowerGrid:new(self, x, y, roomType)
        self.powerGridRooms[roomType] = grid
        -- This actually works
        self.powerGrids[x][y] = grid
        self.powerGrids[x-1][y] = grid
        self.powerGrids[x-2][y] = grid
        self.powerGrids[x][y-1] = grid
        self.powerGrids[x][y-2] = grid
        self.powerGrids[x-1][y-1] = grid
        self.powerGrids[x-2][y-2] = grid
        self.powerGrids[x-2][y-1] = grid
        self.powerGrids[x-1][y-2] = grid
    end

    -- x, y is the frontmost square from the camera's perspective
    --            |x, y     |room that it is "in"
    placePowerGrid(15, 9,   13, 10)
    placePowerGrid(15, 2,   13, 3)
    placePowerGrid(16, 16,  13, 17)
    placePowerGrid(16, 22,  13, 24)
    placePowerGrid(7, 14,   8, 10)
    placePowerGrid(20, 10,  21, 10)
    placePowerGrid(24, 16,  21, 17)

    local function placeTurret(x, y, rx, ry)
        local roomType = self.rooms[rx][ry]
        local turret = Turret:new(self, x, y, roomType)
        -- This actually works
        self.turrets[x][y] = turret
        self.turrets[x-1][y] = turret
        self.turrets[x][y-1] = turret
        self.turrets[x-1][y-1] = turret
    end

    placeTurret(12, 13, 13, 10)
    placeTurret(12, 6, 13, 3)
    placeTurret(13, 15, 13, 17)
    placeTurret(11, 28, 13, 24)
    placeTurret(6, 18, 8, 10)
    placeTurret(19, 15, 21, 10)
    placeTurret(20, 15, 21, 17)

    self.gridX = CANVAS_WIDTH/2
    self.gridY = CANVAS_HEIGHT/2
    self.gridWidth = #self.grid[1] -- tiles
    self.gridHeight = #self.grid -- tiles
    self.tileWidth = self.emptyTile:getWidth() -- pixels
    self.tileHeight = self.emptyTile:getHeight() -- pixels

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
                    local roomNumber = game:getRoom(x, y)

                    local sprite = game.emptyTile

                    if x == game.mouseAction.hoverX and y == game.mouseAction.hoverY then
                        love.graphics.setColor(400, 400, 400)
                    else
                        love.graphics.setColor(255, 255, 255)
                    end

                    tx, ty = game:gridToScreen(x, y)
                    local cellValue = game.grid[x][y]
                    if cellValue == 1 and (roomNumber == game.currentRoom or TWEAK.drawRoomShadows) then
                        love.graphics.draw(sprite, tx, ty)
                    end

                    local roomIsVisible = roomNumber == game.currentRoom

                    local enemy = game:getEnemy(x, y)
                    if enemy and roomIsVisible then
                        enemy:draw()
                    end

                    local turret = game:getTurret(x, y)
                    if turret and turret.roomHash == game.currentRoom then
                        if game:hasTurret(game.mouseAction.hoverX, game.mouseAction.hoverY) then
                            love.graphics.setColor(400, 400, 400)
                        else
                            love.graphics.setColor(255, 255, 255)
                        end
                        turret:draw()
                    end

                    local powerGrid = game:getPowerGrid(x, y)
                    if powerGrid and powerGrid.roomHash == game.currentRoom then
                        if game:hasPowerGrid(game.mouseAction.hoverX, game.mouseAction.hoverY) then
                            love.graphics.setColor(400, 400, 400)
                        else
                            love.graphics.setColor(255, 255, 255)
                        end
                        powerGrid:draw()
                    end

                    if TWEAK.drawTilePositions then
                        if x == game.mouseAction.hoverX and y == game.mouseAction.hoverY then
                            love.graphics.setColor(255, 255, 255)
                        else
                            love.graphics.setColor(255, 255, 255, 127)
                        end
                        love.graphics.setFont(Fonts.monospace[7])
                        love.graphics.print(x..','..y, tx, ty)
                    end
                end
            end

            if TWEAK.drawGridBoundingBox then
                love.graphics.rectangle('line', gx, gy, gw, gh)
                love.graphics.pop()
            end
        end,
    }

    if not self.particleSystem then
        self.particleSystem = ParticleSystem:new()
    end

    self.dynamo = Dynamo:new(self, {
        game = self,
    })

    if TWEAK.minimapOnGame then
        self.minimap = Map:new(self, {
            game = self,
            position = Vector(CANVAS_WIDTH-60, 60),
        })
    end

    self.power = TWEAK.power
    local rawbgimages = {
        { -- bottom room, Bridge
            rgb = {25, 187, 34},
            imagepath = 'Bridge',
            offset = Vector(-64, 82)
        },
        { -- left room, Crew Quarters
            rgb = {102, 64, 178},
            imagepath = 'CrewQuarters',
            offset = Vector(-16, -38)
        },
        { -- top room, Engines
            rgb = {211, 72, 218},
            imagepath = 'EnginesRoom',
            offset = Vector(272, -86)
        },
        { -- middle-bottom room, Main Deck
            rgb = {208, 52, 52},
            imagepath = 'MainDeck',
            offset = Vector(48, 26)
        },
        { -- middle-top room, Storage
            rgb = {100, 183, 36},
            imagepath = 'StorageRoom',
            offset = Vector(160, -30)
        },
        { -- right-bottom room, MedBay
            rgb = {84, 208, 156},
            imagepath = 'MedicBay',
            offset = Vector(176, 90)
        },
        { -- right-top room, Engineering
            rgb = {174, 35, 161},
            imagepath = 'Engineering',
            offset = Vector(288, 34)
        }
    }

    self.backgroundImages = {}

    for k, bgLookup in pairs(rawbgimages) do
        local roomType = getColorHash(unpack(bgLookup.rgb))
        self.backgroundImages[roomType] = {
            image = love.graphics.newImage('assets/images/Rooms/'..bgLookup.imagepath..'.png'),
            offset = bgLookup.offset
        }
    end

    self.totalRooms = TWEAK.totalRooms
    self.totalPoweredRooms = 0

    self.currentRoom = -1

    local gx, gy, gw, gh = game:getGridBoundingBox()
    self.camera = Camera(0, 0)
    --self.camera.smoother = Camera.smooth.linear(1)
    self.camera.smoother = Camera.smooth.damped(5)
    self.cameraGoal = Vector(0, 0)

    self.roundTime = 0
    self.enemyKills = 0

    Signal.emit('gameStart')
end

function game:enter()
    self:reset()
end

function game:update(dt)
    self.timer:update(dt)
    self.particleSystem:update(dt)

    self.roundTime = self.roundTime + dt

    -- Update all entities
    for x = 1, self.gridWidth do
        for y = 1, self.gridHeight do
            local enemy = self:getEnemy(x, y)
            if enemy then
                enemy:update(dt)
            end

            local turret = game:getTurret(x, y)
            if turret then
                turret:update(dt)
            end

            local powerGrid = game:getPowerGrid(x, y)
            if powerGrid then
                powerGrid:update(dt)
            end
        end
    end

    self.scene:update(dt)
    self.dynamo:update(dt)
    self.soundManager:update(dt)
    self.camera:lockPosition(self.cameraGoal:unpack())

    if self.totalPoweredRooms >= self.totalRooms then
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

    self.lastClickPosition = Vector(x, y)
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

function game:getActiveRoomBoundingBox()
    if self.currentRoom == -1 then
        return nil, nil, nil, nil
    end

    local activeMinX, activeMinY, activeMaxX, activeMaxY = math.huge, math.huge, -math.huge, -math.huge
    local maxXLog, maxYLog

    for ix = 1, #self.grid do
        for iy = 1, #self.grid[ix] do
            local cellNumber = self.grid[ix][iy]
            local roomType = self.rooms[ix][iy]

            local screenX, screenY = self:gridToScreen(ix-1, iy-1)
            -- move screenX and screenY to the center of the tile face
            screenX = screenX + self.emptyTile:getWidth()/2
            screenY = screenY + self.emptyTile:getHeight()*3/2

            if roomType == self.currentRoom then
                if screenX < activeMinX then activeMinX = screenX end
                if screenY < activeMinY then activeMinY = screenY end
                if screenX > activeMaxX then activeMaxX = screenX end
                if screenY > activeMaxY then activeMaxY = screenY end
            end
        end
    end

    local width, height = activeMaxX - activeMinX, activeMaxY - activeMinY

    return activeMinX, activeMinY, width, height
end

function game:draw()
    love.graphics.setBackgroundColor(TWEAK.backgroundColor)
    local scale = self:getScale()
    local drawnWidth, drawnHeight = CANVAS_WIDTH*scale, CANVAS_HEIGHT*scale
    local x, y = math.floor(love.graphics.getWidth()/2 - drawnWidth/2), math.floor(love.graphics.getHeight()/2 - drawnHeight/2)

    local roomX, roomY, roomWidth, roomHeight = self:getActiveRoomBoundingBox()

    self.canvas:renderTo(function()
        love.graphics.clear(love.graphics.getBackgroundColor())

        local gx, gy, gw, gh = game:getGridBoundingBox()
        local translatedX = gx - game.gridX + gw/2
        local translatedY = gy - game.gridY + gh/2

        love.graphics.push()
        self.camera:attach(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
        if TWEAK.drawRoomBoundingBox and roomX then
            love.graphics.setColor(255, 0, 0)
            love.graphics.circle('line', -translatedX + roomX + roomWidth/2, -translatedY + roomY + roomHeight/2, 10)
            love.graphics.rectangle('line', -translatedX + roomX, -translatedY + roomY, roomWidth, roomHeight)
        end
        if self.backgroundImages[self.currentRoom] then
            local bg = self.backgroundImages[self.currentRoom]
            love.graphics.draw(bg.image, bg.offset.x, bg.offset.y)
        end
        self.scene:draw()


        self.camera:detach()
        love.graphics.pop()

        if self.minimap then self.minimap:draw() end
        self.dynamo:draw()

        self.particleSystem:draw()

        if TWEAK.drawCanvasBoundingBox then
            love.graphics.setColor(127, 127, 127)
            love.graphics.rectangle('line', 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
        end
    end)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.canvas, x, y, 0, scale)

    if TWEAK.printClickPosition and self.printClickPosition then
        love.graphics.print("Mouse: ("..self.last.x..', '..self.last.y..')', 100, 5)
    end
end

function game:loadAnimations(class, category, dataFile)
    -- Load animations for alien enemies
    local animationData = require(dataFile)
    class.static.images = {}
    class.static.animations = {}
    class.static.animationOffsets = {}

    for animationName, file in pairs(self.catalogs.animation[category]) do
        local data = animationData[animationName]

        if data ~= nil then
            local img = love.graphics.newImage(file)
            class.static.images[animationName] = img
            if not data.frameWidth then
                error('No frame width found for animation name: "' .. animationName .. '"')
            end
            if not data.frameHeight then
                error('No frame height found for animation name: "' .. animationName .. '"')
            end

            local grid = Anim8.newGrid(data.frameWidth, data.frameHeight, img:getWidth(), img:getHeight(), data.left, data.top, data.border)

            if not data.frames then
                error('No animation frames found for animation name: "' .. animationName .. '"')
            elseif #data.frames == 0 then
                error('Empty animation frames for animation name: "' .. animationName .. '"')
            end
            if not data.durations then
                error('No animation durations found for animation name: "' .. animationName .. '"')
            elseif type(data.durations) == "table" and #data.durations == 0 then
                error('Empty animation durations for animation name: "' .. animationName .. '"')
            end

            local anim = Anim8.newAnimation(grid(unpack(data.frames)), data.durations)
            class.static.animations[animationName] = anim
            if not data.offsets then
                error('No animation offsets found for animation name: "' .. animationName .. '"')
            end
            class.static.animationOffsets[animationName] = data.offsets
        else
            error('No animation data found for animation name: "' .. animationName .. '"')
        end
    end
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
    local gx = ((sx / (self.tileWidth / 2)) + (sy / (self.tileHeight / 2))) / 2 + 1
    local gy = ((sy / (self.tileHeight / 2)) - (sx / (self.tileWidth / 2))) / 2 + 1
    return Lume.round(gx), Lume.round(gy)
end

function game:gridToScreen(gx, gy)
    local x = (gx - gy) * game.tileWidth / 2
    local y = (gx + gy) * game.tileHeight / 2
    return x, y
end

function game:getGridBoundingBox()
    local xFudge = 0
    local yFudge = 4
    local w = self.gridWidth  * self.tileWidth + xFudge
    local h = self.gridHeight * self.tileHeight + yFudge
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

function game:hasTurret(x, y)
    return self.turrets[x] and self.turrets[x][y] ~= nil
end

function game:getTurret(x, y)
    return self:hasTurret(x, y) and self.turrets[x][y] or nil
end

function game:hasPowerGrid(x, y)
    return self.powerGrids[x] and self.powerGrids[x][y] ~= nil
end

function game:getPowerGrid(x, y)
    return self:hasPowerGrid(x, y) and self.powerGrids[x][y] or nil
end

return game
