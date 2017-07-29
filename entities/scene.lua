local Bump = require 'libs.bump'

local Scene = Class{}

function Scene:init(props)
    self.entities = {}
    self.timer = Timer()
    self.signal = Signal.new()

    local cellSize = 64
    self.world = Bump.newWorld(cellSize)

    props = props or {}
    for k, v in pairs(props) do
        self[k] = v
    end
end

function Scene:update(dt)
    for i=#self.entities, 1, -1 do
        local object = self.entities[i]
        if object.update then
            object:update(dt)
        end
        if self.world:hasItem(object) then
            local x, y = object.position:unpack()
            local w, h = object.width, object.height
            self.world:update(object, x, y, w, h)
        end
        if object.dead then
            self:remove(object)
            if self.onRemove then
                self:onRemove(object)
            end
        end
    end

    if self.timer then
        self.timer:update(dt)
    end
end

function Scene:draw()
    love.graphics.setColor(255, 255, 255)
    for i=1, #self.entities do
        local object = self.entities[i]
        if object.predraw then
            object:predraw()
        end
    end
    for i=1, #self.entities do
        local object = self.entities[i]
        if object.draw then
            object:draw()
        end
    end
    for i=1, #self.entities do
        local object = self.entities[i]
        if object.postdraw then
            object:postdraw()
        end
    end
end

function Scene:add(target)
    table.insert(self.entities, target)

    if target.collidable then
        local x, y = object.position:unpack()
        local w, h = object.width, object.height

        self.world:add(target, x, y, w, h)
    end

    if self.onAdd then
        self:onAdd(target)
    end
    return target
end

function Scene:remove(target, index)
    if target.collidable then
        self.world:remove(target)
    end

    if index then
        table.remove(self.entities, index)
        return true
    else
        for i=1, #self.entities do
            if self.entities[i] == target then
                table.remove(self.entities, i)
                return true
            end
        end
    end
    return false
end

function Scene:queryRect(x, y, w, h, filter)
    return self.world:queryRect(x, y, w, h, filter)
end

function Scene:keypressed(...)
    for i=1, #self.entities do
        if self.entities[i].keypressed then
            self.entities[i].keypressed(self.entities[i], ...)
        end
    end
end

function Scene:mousepressed(...)
    for i=1, #self.entities do
        if self.entities[i].mousepressed then
            self.entities[i].mousepressed(self.entities[i], ...)
        end
    end
end

function Scene:mousereleased(...)
    for i=1, #self.entities do
        if self.entities[i].mousereleased then
            self.entities[i].mousereleased(self.entities[i], ...)
        end
    end
end

function Scene:mousemoved(...)
    for i=1, #self.entities do
        if self.entities[i].mousemoved then
            self.entities[i].mousemoved(self.entities[i], ...)
        end
    end
end

return Scene
