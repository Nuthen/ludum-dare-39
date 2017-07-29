local MouseAction = Class('MouseAction')

function MouseAction:initialize(game)
    self.hoverX = 0
    self.hoverY = 0
    self.game = game
end

function MouseAction:update(dt)
    local game = self.game
    local mx, my = love.mouse.getPosition()
    local gx, gy, gw, gh = game:getGridBoundingBox()
    local translatedX = gx - game.gridX + gw/2
    local translatedY = gy - game.gridY + gh/2
    mx = -translatedX - mx
    my = -translatedY - my
    mx = mx + game.tileWidth / 2
    my = my + game.tileHeight
    self.hoverX, self.hoverY = game:screenToGrid(-mx, -my)
end

function MouseAction:mousepressed(mx, my)
    local game = self.game
    if game:hasEnemy(self.hoverX, self.hoverY) then
        local enemy = game.enemies[self.hoverX][self.hoverY]
        local upX,    upY    = self.hoverX,     self.hoverY + 1
        local downX,  downY  = self.hoverX,     self.hoverY - 1
        local leftX,  leftY  = self.hoverX - 1, self.hoverY
        local rightX, rightY = self.hoverX + 1, self.hoverY

        if enemy.stage == enemy.stages.EVOLVED then
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
    end
end

return MouseAction
