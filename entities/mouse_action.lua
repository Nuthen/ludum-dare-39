local MouseAction = Class('MouseAction')

function MouseAction:initialize(game)
    self.hoverX = 0
    self.hoverY = 0
    self.canvasX = 0
    self.canvasY = 0
    self.game = game

    self.heldObject = nil
end

function MouseAction:update(dt)
    if not love.mouse.isDown(1) then
        if self.heldObject then
            self.heldObject.beingHeld = false
        end
        self.heldObject = nil
    end

    if self.heldObject then
        local isHovered = self.game:pointInsideRect(self.canvasX, self.canvasY, self.heldObject.screenX + self.heldObject.hitboxX, self.heldObject.screenY + self.heldObject.hitboxY, self.heldObject.hitboxWidth, self.heldObject.hitboxHeight)
        if not isHovered then
            self.heldObject.beingHeld = false
            self.heldObject = nil
        end
    end
end

function MouseAction:mousemoved(mx, my, dx, dy, istouch)
    local game = self.game

    mx, my = game.camera:worldCoords(mx, my, 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)

    local gx, gy, gw, gh = game:getGridBoundingBox()
    local translatedX = gx - game.gridX + gw/2
    local translatedY = gy - game.gridY + gh/2
    mx = -translatedX - mx
    my = -translatedY - my
    self.canvasX, self.canvasY = -mx, -my
    mx = mx + game.tileWidth / 2
    my = my + game.tileHeight * (3/2)
    self.hoverX, self.hoverY = game:screenToGrid(-mx, -my)
end

-- @Cleanup This shouldn't be in here, send help
function MouseAction:clickEnemy(x, y)
    local game = self.game
    local enemy = game:getEnemy(x, y)
    local upX,    upY    = x,     y + 1
    local downX,  downY  = x,     y - 1
    local leftX,  leftY  = x - 1, y
    local rightX, rightY = x + 1, y

    local isDead = enemy:hurt()
    local roomType = game.rooms[x][y]

    -- do transformations from room bounding box function
    -- then subtract camera position, and add half canvas size
    local screenX, screenY = game:gridToScreen(x-1, y-1)
    -- move screenX and screenY to the center of the tile face
    screenX = screenX + game.emptyTile:getWidth()/2
    screenY = screenY + game.emptyTile:getHeight()*3/2

    --local ex, ey = game:gridToScreen(x, y)
    --local cx, cy = game.camera:cameraCoords(ex, ey)
    screenX = screenX - game.camera.x + CANVAS_WIDTH/2
    screenY = screenY - game.camera.y + CANVAS_HEIGHT/2

    -- fudge
    screenX = screenX + CANVAS_WIDTH/2 - 15
    screenY = screenY - 65

    if isDead then
        if enemy.stage == enemy.stages.LARGE then
            if game:isShipTile(upX, upY) then
                game:addEnemy(upX, upY)
            end

            if game:isShipTile(downX, downY) then
                game:addEnemy(downX, downY)
            end

            if game:isShipTile(leftX, leftY) then
                game:addEnemy(leftX, leftY)
            end

            if game:isShipTile(rightX, rightY) then
                game:addEnemy(rightX, rightY)
            end
        end

        game.enemies[x][y] = nil

        Signal.emit('enemyDeath', roomType == game.currentRoom, enemy.stage, Vector(screenX, screenY))
    else
        Signal.emit("Enemy Hurt", roomType == game.currentRoom, enemy.stage, Vector(screenX, screenY))
    end
end

function MouseAction:mousepressed(mx, my, mbutton)
    if mbutton ~= 1 then return end

    local game = self.game

    -- Clicking on enemy
    if game:hasEnemy(self.hoverX, self.hoverY) and game.currentRoom == game:getRoom(self.hoverX, self.hoverY) then
        self:clickEnemy(self.hoverX, self.hoverY)
    end

    for x = 1, game.gridWidth do
        for y = 1, game.gridHeight do
            local powerGrid = game:getPowerGrid(x, y)
            if powerGrid then
                local isHovered = game:pointInsideRect(self.canvasX, self.canvasY, powerGrid.screenX + powerGrid.hitboxX, powerGrid.screenY + powerGrid.hitboxY, powerGrid.hitboxWidth, powerGrid.hitboxHeight)
                if isHovered then
                    if powerGrid.roomHash == game.currentRoom then
                        if powerGrid.activated then
                            self.heldObject = powerGrid
                        else
                            powerGrid:activate()
                        end
                    end
                end
            end

            local turret = game:getTurret(x, y)
            if turret then
                local isHovered = game:pointInsideRect(self.canvasX, self.canvasY, turret.screenX + turret.hitboxX, turret.screenY + turret.hitboxY, turret.hitboxWidth, turret.hitboxHeight)
                if isHovered then
                    if turret.roomHash == game.currentRoom then
                        if turret.activated then
                            self.heldObject = turret
                        else
                            turret:activate()
                        end
                    end
                end
            end
        end
    end

    if self.heldObject then
        self.heldObject.beingHeld = true
    end
end

function MouseAction:mousereleased(mx, my, mbutton)
    if mbutton ~= 1 then return end

    if self.heldObject then
        self.heldObject.beingHeld = false
    end
    self.heldObject = nil
end

return MouseAction
