local ParticleSystem = Class('ParticleSystem')

function ParticleSystem:initialize()
    self.systems = {}

    self.drawLater = {"sparks"}

    self.defaultImage = love.graphics.newImage("assets/images/particles/1x1white.png")
    self.sparkImage = love.graphics.newImage("assets/images/particles/spark.png")
    self.gibImage = love.graphics.newImage("assets/images/particles/gib.png")

    -- How many particles each system can have
    self.particleLimit = 500

    self.systems.default = love.graphics.newParticleSystem(self.defaultImage, self.particleLimit)
    self.systems.default:stop()

    self.systems.sparks = self.systems.default:clone()
    self.systems.sparks:setColors(
        255, 255, 255, 255,
        255, 255, 0, 255,
        255, 215, 0, 255,
        255, 127, 0, 255
    )
    self.systems.sparks:setTexture(self.sparkImage)
    self.systems.sparks:setSizes(2, 1.5, 0.75, 0.25)
    self.systems.sparks:setSizeVariation(1)
    self.systems.sparks:setSpeed(100, 300)
    self.systems.sparks:setLinearAcceleration(0, 400)
    self.systems.sparks:setTangentialAcceleration(-100, 100)
    self.systems.sparks:setRadialAcceleration(-100, 100)
    self.systems.sparks:setSpread(math.pi / 2)
    self.systems.sparks:setDirection(-math.pi/2)
    self.systems.sparks:setParticleLifetime(0.25, 1)
    self.systems.sparks:setEmissionRate(25)
    self.systems.sparks:setRelativeRotation(true)

    self.systems.gibs = self.systems.default:clone()
    self.systems.gibs:setTexture(self.gibImage)
    self.systems.gibs:setSizes(2, 1, 0.5, 0.25)
    self.systems.gibs:setSizeVariation(1)
    self.systems.gibs:setSpeed(100, 300)
    self.systems.gibs:setLinearAcceleration(0, 400)
    self.systems.gibs:setTangentialAcceleration(-100, 100)
    self.systems.gibs:setRadialAcceleration(-100, 100)
    self.systems.gibs:setSpread(math.pi / 2)
    self.systems.gibs:setDirection(-math.pi/2)
    self.systems.gibs:setParticleLifetime(0.25, 1)
    self.systems.gibs:setEmissionRate(25)
    self.systems.gibs:setRelativeRotation(true)

    -- For now, particle emitters and the ParticleSystem (this class) use different tables
    -- ParticleSystem uses object pooling, and ParticleEmitters just get 1 system per instance
    self.usedSystems = {}
    self.pool = {}

    for name, system in pairs(self.systems) do
        self.pool[name] = {}
    end

    local function createSystem(name)
        for i=#self.pool[name], 1, -1 do
            local system = self.pool[name][i]
            if not system:isActive() then
                return system
            end
        end
        local s = self.systems[name]:clone()
        table.insert(self.pool[name], s)
        return s
    end

    Signal.register('emitterCreated', function(emitter, kind)
        -- Default system
        if kind == "" or kind == nil then
            kind = "default"
        end
        local system = self.systems[kind]:clone()
        Signal.emit('systemCreated', system, emitter)
        table.insert(self.usedSystems, system)
    end)

    Signal.register('Dynamo Correct', function(sourceType, position)
        local s = createSystem("sparks")
        s:setPosition(position:unpack())
        s:start()
        s:emit(20)
        s:setEmitterLifetime(.1)
    end)

    Signal.register('Enemy Hurt', function(isCurrentRoom, stage, position)
        if isCurrentRoom then
            local s = createSystem("gibs")
            s:setSizes(1, 0.5, 0.25)
            s:setSpeed(50, 150)
            s:setPosition(position:unpack())
            s:start()
            s:emit(10)
            s:setEmitterLifetime(.1)
        end
    end)

    Signal.register('enemyDeath', function(isCurrentRoom, stage, position)
        if isCurrentRoom then
            local s = createSystem("gibs")
            s:setSizes(2, 1, 0.5, 0.25)
            s:setSpeed(100, 300)
            s:setPosition(position:unpack())
            s:start()
            s:emit(20 * stage)
            s:setEmitterLifetime(.1)
        end
    end)
end

function ParticleSystem:update(dt)
    for _, system in ipairs(self.usedSystems) do
        system:update(dt)
    end

    for _, kind in pairs(self.pool) do
        for _, system in ipairs(kind) do
            system:update(dt)
        end
    end
end

function ParticleSystem:draw()
    love.graphics.setColor(255, 255, 255)

    for k, system in ipairs(self.usedSystems) do
        if not Lume.find(self.drawLater, k) then
            love.graphics.setColor(255, 255, 255)
            love.graphics.draw(system)
        end
    end

    for k, kind in pairs(self.pool) do
        for _, system in ipairs(kind) do
            if not Lume.find(self.drawLater, k) then
                love.graphics.setColor(255, 255, 255)
                love.graphics.draw(system)
            end
        end
    end
end

function ParticleSystem:drawAfter()
    love.graphics.setColor(255, 255, 255)

    for k, system in ipairs(self.usedSystems) do
        if Lume.find(self.drawLater, k) then
            love.graphics.setColor(255, 255, 255)
            love.graphics.draw(system)
        end
    end

    for k, kind in pairs(self.pool) do
        for _, system in ipairs(kind) do
            if Lume.find(self.drawLater, k) then
                love.graphics.setColor(255, 255, 255)
                love.graphics.draw(system)
            end
        end
    end
end

return ParticleSystem
