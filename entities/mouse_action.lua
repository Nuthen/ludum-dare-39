local MouseAction = Class('MouseAction')

function MouseAction:initialize(game)
    self.hoverX = 0
    self.hoverY = 0
    self.canvasX = 0
    self.canvasY = 0
    self.game = game
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

function MouseAction:mousepressed(mx, my)
    local game = self.game

    -- Clicking on enemy
    if game:hasEnemy(self.hoverX, self.hoverY) and game.currentRoom == game:getRoom(self.hoverX, self.hoverY) then
        local enemy = game:getEnemy(self.hoverX, self.hoverY)
        local upX,    upY    = self.hoverX,     self.hoverY + 1
        local downX,  downY  = self.hoverX,     self.hoverY - 1
        local leftX,  leftY  = self.hoverX - 1, self.hoverY
        local rightX, rightY = self.hoverX + 1, self.hoverY

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

        game.enemies[self.hoverX][self.hoverY] = nil

        Signal.emit('enemyDeath', enemy.stage, Vector(mx, my))
    end

    for x = 1, game.gridWidth do
        for y = 1, game.gridHeight do
            local powerGrid = game:getPowerGrid(x, y)
            if powerGrid then
                local isHovered = game:pointInsideRect(self.canvasX, self.canvasY, powerGrid.screenX + powerGrid.hitboxX, powerGrid.screenY + powerGrid.hitboxY, powerGrid.hitboxWidth, powerGrid.hitboxHeight)
                if isHovered then
                    if powerGrid.roomHash == game.currentRoom then
                        powerGrid:activate()
                    end
                end
            end

            local turret = game:getTurret(x, y)
            if turret then
                local isHovered = game:pointInsideRect(self.canvasX, self.canvasY, turret.screenX + turret.hitboxX, turret.screenY + turret.hitboxY, turret.hitboxWidth, turret.hitboxHeight)
                if isHovered then
                    if turret.roomHash == game.currentRoom then
                        turret:activate()
                    end
                end
            end
        end
    end
end

return MouseAction
