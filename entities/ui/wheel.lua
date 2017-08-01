local Wheel = Class('Wheel')

function Wheel:initialize(parent, props)
    self.parent = parent
    self.radius = 40
    self.inactiveColor = {255, 255, 255}
    self.pressColor = {400, 400, 400}
    self.position = Vector(0, 0)
    self.angle = 0
    self.locked = {cw = true, ccw = true}
    self.onClicked = function(rotDir) end

    for k, prop in pairs(props) do
        self[k] = prop
    end

    self.isPressed = false
    self.beganPress = false
    self.rotationAccumulator = 0
    self.startAngle = self.angle
    self.activeRotDirection = "cw"

    self.bindingSpinMultiplier = .5
    self.mouseSpinMultiplier = 1

    self.beingMoved = false
    self.lastBeingMoved = false

    self.position.y = self.position.y - 1

    self.handleImage = love.graphics.newImage('assets/images/Dynamo/dynamo_smallbutton.png')
    self.arrowImage  = love.graphics.newImage('assets/images/Dynamo/dynamo_arrow_right.png')
end

function Wheel:activate()
    self.activated = true

    local possibles = {}
    if not self.locked.cw  then table.insert(possibles, 0) end
    if not self.locked.ccw then table.insert(possibles, 1) end

    local randomDir = possibles[love.math.random(1, #possibles)]
    if randomDir == 0 then
        self.activeRotDirection = "cw"
    elseif randomDir == 1 then
        self.activeRotDirection = "ccw"
    else
        error("Unexpected var for randDir: " .. randDir)
    end

    self.startAngle = self.angle
    self.rotationAccumulator = 0
end

function Wheel:getPressed(x, y)
    -- some extra leeway
    return Lume.distance(self.position.x, self.position.y, x, y) <= self.radius + 5
end

function Wheel:update(dt)
    if self.beingMoved and not self.lastBeingMoved then
        Signal.emit("Wheel Spin Start")
    elseif not self.beingMoved and self.lastBeingMoved then
        Signal.emit("Wheel Spin Stop")
    end

    self.lastBeingMoved = self.beingMoved
end

function Wheel:mousepressed(x, y, mbutton)
    if self.locked.cw    and
       self.locked.ccw then
           return
    end

    self.isPressed = false
    self.beingMoved = false
    if mbutton == 1 and self:getPressed(x, y) then
        self.beingMoved = true
        self.isPressed = true
        self.beganPress = true
        --self.rotationAccumulator = 0
        --self.startAngle = self.angle
    end
end

function Wheel:mousemoved(x, y, dx, dy, istouch)
    if self.isPressed then
        -- makes a good spinning behavior regardless of how far inside or outside of the wheel the mouse is
        local dist = Lume.distance(self.position.x, self.position.y, x, y)
        local currentAngle = Lume.angle(self.position.x, self.position.y, x, y)

        local extrapLength = math.max(self.radius, dist)
        local extrapOffset = Vector(math.cos(currentAngle)*extrapLength, math.sin(currentAngle)*extrapLength)
        extrapOffset = extrapOffset - Vector(dx, dy)

        local prevAngle = Lume.angle(0, 0, extrapOffset.x, extrapOffset.y)
        local deltaAngle = (currentAngle - prevAngle) * self.mouseSpinMultiplier

        self:solveAngle(deltaAngle)
    end
end

function Wheel:solveAngle(deltaAngle)
    -- idea: be able to treat the skip from 180deg to -180deg as no big deal
    -- fairly hacky
    if deltaAngle >= math.pi then
        deltaAngle = 2*math.pi - deltaAngle
    elseif deltaAngle <= -math.pi then
        deltaAngle = -2*math.pi - deltaAngle
    end

    self.angle = self.angle + deltaAngle

    self.rotationAccumulator = self.rotationAccumulator + deltaAngle
    if self.rotationAccumulator >= 2*math.pi then
        self.rotationAccumulator = self.rotationAccumulator - 2*math.pi
        if self.activated then
            if self.activeRotDirection == "cw" then
                self.activated = false
                self.onClicked(self.position, "cw")
            else
                Signal.emit("Dynamo Incorrect", "wheel")
            end
        end
    elseif self.rotationAccumulator <= -2*math.pi then
        self.rotationAccumulator = self.rotationAccumulator + 2*math.pi
        if self.activated then
            if self.activeRotDirection == "ccw" then
                self.activated = false
                self.onClicked(self.position, "ccw")
            else
                Signal.emit("Dynamo Incorrect", "wheel")
            end
        end
    end

    if self.angle >= 2*math.pi then
        self.angle = self.angle - 2*math.pi
    elseif self.angle <= -2*math.pi then
        self.angle = self.angle + 2*math.pi
    end
end

function Wheel:mousereleased(x, y, mbutton)
    if self.locked.cw    and
       self.locked.ccw then
           return
    end

    if mbutton == 1 and self.isPressed then
        self.beingMoved = false
        self.isPressed = false
        self.beganPress = false
        --self.rotationAccumulator = 0
    end
end

function Wheel:wheelmoved(x, y)
    if self.locked.cw  then y = math.max(0, y) end
    if self.locked.ccw then y = math.min(0, y) end

    --self.beingMoved = false
    if y ~= 0 then
        --self.beingMoved = true
        self:solveAngle(-y * self.bindingSpinMultiplier)
    end
end

function Wheel:draw()
    if self.locked.cw    and
       self.locked.ccw then
          return
    end

    love.graphics.setColor(self.inactiveColor)
    if self.activated then
        love.graphics.setColor(self.pressColor)
    end

    local angle1Raw, angle2Raw = self.startAngle, self.startAngle + self.rotationAccumulator
    local angle1, angle2 = math.min(angle1Raw, angle2Raw), math.max(angle1Raw, angle2Raw)
    --love.graphics.arc('line', self.position.x, self.position.y, self.radius + 5, angle1, angle2)

    --love.graphics.circle('line', self.position.x, self.position.y, self.radius)
    local radius = self.radius - 2
    local handleX, handleY = self.position.x + math.cos(self.angle)*radius, self.position.y + math.sin(self.angle)*radius
    love.graphics.draw(self.handleImage, math.floor(handleX), math.floor(handleY), 0, 1, 1, self.handleImage:getWidth()/2, self.handleImage:getHeight()/2)
    --love.graphics.circle('fill', handleX, handleY , 6)

    love.graphics.setColor(255, 255, 255)
    if self.activated then
        local deltaRad
        if self.activeRotDirection == "cw" then
            local x, y = self.position.x, self.position.y
            --x = x + 19
            x = x - self.arrowImage:getWidth()/2 + 1
            y = y - 1
            love.graphics.draw(self.arrowImage, math.floor(x), math.floor(y), 0, 1, -1)
            deltaRad = math.pi/4
        elseif self.activeRotDirection == "ccw" then
            local x, y = self.position.x, self.position.y
            x = x - 17
            y = y + 4
            love.graphics.draw(self.arrowImage, math.floor(x), math.floor(y))
            deltaRad = -math.pi/4
        end
    --    love.graphics.line(handleX, handleY, handleX + math.cos(self.angle+deltaRad)*20, handleY + math.sin(self.angle+deltaRad)*20)
    end



    --love.graphics.print(math.deg(self.rotationAccumulator), self.position.x, self.position.y)
end

return Wheel
