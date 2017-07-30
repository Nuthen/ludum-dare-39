local Scene = Class('Scene')

function Scene:initialize(props)
    self.entities = {}
    self.timer = Timer()
    self.signal = Signal.new()

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

    if self.onAdd then
        self:onAdd(target)
    end
    return target
end

function Scene:remove(target, index)
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

function Scene:keypressed(...)
    for i=1, #self.entities do
        if self.entities[i].keypressed then
            self.entities[i].keypressed(self.entities[i], ...)
        end
    end
end

function Scene:keyreleased(...)
    for i=1, #self.entities do
        if self.entities[i].keyreleased then
            self.entities[i].keyreleased(self.entities[i], ...)
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

function Scene:wheelmoved(...)
    for i=1, #self.entities do
        if self.entities[i].wheelmoved then
            self.entities[i].wheelmoved(self.entities[i], ...)
        end
    end
end

return Scene
