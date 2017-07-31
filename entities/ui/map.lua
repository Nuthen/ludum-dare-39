local Map = Class('Map')

function Map:initialize(parent, props)
    self.parent = parent
    self.bgColor = {0, 0, 0}
    self.inactiveColor = {255, 255, 255}
    self.activeColor = {127, 127, 127}
    self.borderColor = {255, 255, 255}
    self.unpoweredColor = {255, 0, 0}
    self.poweredColor = {255, 255, 255}
    self.position = Vector(0, 0)
    self.width = 90
    self.height = 90
    self.tileWidth = 3
    self.tileHeight = 3
    self.mapWidth = 0
    self.mapHeight = 0
    self.onClicked = function() end
    --[[ note that the tileWidth and tileHeight should multiply evenly
         into the width and height based on the grid size]]

    for k, prop in pairs(props) do
        self[k] = prop
    end

    if self.game.grid then
        self.mapWidth  = #self.game.grid * self.tileWidth
        self.mapHeight = #self.game.grid[1] * self.tileHeight
    end

    self.isPressed = false

    self.hoveredRoom = -1

    self.pixelColors = {}
    for x = 1, self.game.shipBitmask:getWidth() do
        self.pixelColors[x] = {}
        for y = 1, self.game.shipBitmask:getHeight() do
            local r, g, b, a = self.game.shipBitmask:getPixel(x - 1, y - 1)
            self.pixelColors[x][y] = {r, g, b, a}
        end
    end
end

function Map:screenToTile(x, y)
    if (x >= self.position.x - self.width/2 ) and
       (x <= self.position.x + self.width/2 ) and
       (y >= self.position.y - self.height/2) and
       (y <= self.position.y + self.height/2) then

        x = x - (self.position.x - self.width /2)
        y = y - (self.position.y - self.height/2)
        local tileX, tileY = math.ceil(x / self.tileWidth), math.ceil(y / self.tileHeight)
        if tileX <= 0 or tileY <= 0 or tileX >= #self.game.grid or tileY >= #self.game.grid[1] then
            return nil, nil
        end

        return tileX, tileY
    else
        return nil, nil
    end
end

function Map:mousepressed(x, y, mbutton)

end

function Map:mousemoved(x, y, dx, dy, istouch)
    self.hoveredRoom = -1

    local hoverX, hoverY = self:screenToTile(x, y)
    if hoverX and hoverY then
        local roomType = self.game.rooms[hoverX][hoverY]
        if roomType ~= 0 then
            self.hoveredRoom = roomType
        end
    end
end

function Map:mousereleased(x, y, mbutton)
    self.hoveredRoom = -1

    local hoverX, hoverY = self:screenToTile(x, y)
    if hoverX and hoverY then
        local roomType = self.game.rooms[hoverX][hoverY]
        if roomType ~= 0 then
            self.hoveredRoom = roomType
            self.game.currentRoom = roomType
            Signal.emit("Enter Room")
        end
    end
end

function Map:draw()
    love.graphics.setColor(self.inactiveColor)

    local margin = self.margin
    local x, y, w, h = self.position.x, self.position.y, self.width, self.height
    x, y = x - w/2, y - h/2

    love.graphics.setColor(self.bgColor)
    love.graphics.rectangle('fill', x, y, w, h)
    love.graphics.setColor(self.inactiveColor)
    love.graphics.rectangle('line', x, y, w, h)

    -- draw map tiles
    local activeMinX, activeMinY, activeMaxX, activeMaxY = math.huge, math.huge, -1, -1

    for ix = 1, #self.game.grid do
        for iy = 1, #self.game.grid[ix] do
            local cellNumber = self.game.grid[ix][iy]
            --love.graphics.setColor(255, 255, 255)
            local r, g, b = unpack(self.unpoweredColor)
            local a = 200
            local roomType = self.game.rooms[ix][iy]

            local powerGrid = self.game.powerGridRooms[roomType]
            if powerGrid and powerGrid.activated then
                r, g, b = unpack(self.poweredColor)
            end

            if roomType == self.hoveredRoom then
                a = 255
            end
            love.graphics.setColor(r, g, b, a)
            if self.game:hasEnemy(ix, iy) then
                love.graphics.setColor(42, 214, 54)
            end
            local screenX, screenY = x + (ix-1) * self.tileWidth, y + (iy-1) * self.tileHeight
            if cellNumber == 1 then
                love.graphics.rectangle('fill', screenX, screenY, self.tileWidth, self.tileHeight)
            end

            if roomType == self.game.currentRoom then
                if ix < activeMinX then activeMinX = ix end
                if iy < activeMinY then activeMinY = iy end
                if ix > activeMaxX then activeMaxX = ix end
                if iy > activeMaxY then activeMaxY = iy end
            end
        end
    end

    if self.game.currentRoom ~= -1 then
        local minScreenX, minScreenY = x + (activeMinX-1) * self.tileWidth, y + (activeMinY-1) * self.tileHeight
        local maxScreenX, maxScreenY = x + (activeMaxX) * self.tileWidth, y + (activeMaxY) * self.tileHeight
        local width, height = maxScreenX - minScreenX, maxScreenY - minScreenY
        local m = 2

        love.graphics.setColor(self.borderColor)
        love.graphics.rectangle('line', minScreenX-m, minScreenY-m, width+m*2, height+m*2)
    end
end

return Map
