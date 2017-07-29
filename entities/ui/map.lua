local Map = Class('Map')

function Map:initialize(parent, props)
    self.parent = parent
    self.bgColor = {127, 127, 127}
    self.inactiveColor = {255, 255, 255}
    self.activeColor = {127, 127, 127}
    self.position = Vector(0, 0)
    self.width = 50
    self.height = 50
    self.tileWidth = 8
    self.tileHeight = 8
    self.mapWidth = 0
    self.mapHeight = 0
    self.onClicked = function() end

    for k, prop in pairs(props) do
        self[k] = prop
    end

    if self.game.grid then
        self.mapWidth  = #self.game.grid * self.tileWidth
        self.mapHeight = #self.game.grid[1] * self.tileHeight
    end

    self.isPressed = false
end

function Map:getPressed(x, y)
    return (x >= self.position.x - self.width/2 ) and
           (x <= self.position.x + self.width/2 ) and
           (y >= self.position.y - self.height/2) and
           (y <= self.position.y + self.height/2)
end

function Map:screenToTile(x, y)
    if (x >= self.position.x - self.width/2 ) and
       (x <= self.position.x + self.width/2 ) and
       (y >= self.position.y - self.height/2) and
       (y <= self.position.y + self.height/2) then

    else
        return nil, nil
    end
end

function Map:mousepressed(x, y, mbutton)
    if self:getPressed(x, y) then
        self.onClicked()
    end
end

function Map:mousemoved(x, y, dx, dy, istouch)
    if self:getPressed(x, y) then
        self.isPressed = true
    end
end

function Map:draw()
    local power = self.parent.power

    love.graphics.setColor(self.inactiveColor)

    local margin = self.margin
    local x, y, w, h = self.position.x, self.position.y, self.width, self.height
    x, y = x - w/2, y - h/2

    love.graphics.setColor(self.bgColor)
    love.graphics.rectangle('fill', x, y, w, h)
    love.graphics.setColor(self.inactiveColor)

    --x, y, w, h = x + margin, y + margin, w - margin*2, h - margin*2
    love.graphics.rectangle('line', x, y, w, h)


    -- draw map tiles
    love.graphics.push()
    love.graphics.translate(w/2, h/2)
    love.graphics.translate(-self.mapWidth/2, -self.mapHeight/2)
    for ix = 1, #self.game.grid do
        for iy = 1, #self.game.grid[ix] do
            local cellNumber = self.game.grid[ix][iy]
            if cellNumber == 1 then
                love.graphics.rectangle('fill', x + (ix-1) * self.tileWidth, y + (iy-1) * self.tileHeight, self.tileWidth, self.tileHeight)
            end
        end
    end
    love.graphics.pop()
end

return Map
