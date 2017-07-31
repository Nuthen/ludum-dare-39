local SoundManager = Class('SoundManager')

function SoundManager:initialize(soundCatalog, musicCatalog)
    love.audio.stop()

    self.sounds = {}
    self.defaultSoundVolume = SETTINGS.soundVolume * 0.5

    for name, sound in pairs(soundCatalog) do
        local source = love.audio.newSource(sound)
        source:setVolume(self.defaultSoundVolume)
        self.sounds[name] = source
    end

    self.music = {}
    self.currentMusic = nil
    self.defaultMusicVolume = SETTINGS.musicVolume

    for name, music in pairs(musicCatalog) do
        local source = love.audio.newSource(music)
        source:setVolume(self.defaultMusicVolume)
        self.music[name] = source
    end

    self.maxSoundsPlaying = SETTINGS.maxSoundsPlaying
    self.soundsPlaying = {}

    self.timer = Timer.new()

    Signal.register('gameStart', function()
        self:playLooping('background_engine_hum', 0.4)
        self:playMusic('buzzy', 0.6)
    end)

    Signal.register('enemyDeath', function(isCurrentRoom)
        if not isCurrentRoom then return end
        self:play('enemy_death', 1, 1, 0.1, 1, 4)
        self:play('enemy_death_impact', 0.6, 1, 0.1)
    end)

    Signal.register('Enemy Hurt', function(isCurrentRoom)
        if not isCurrentRoom then return end
        self:play('enemy_death_impact', 0.6, 1, 0.1)
        self:play('enemy_death', 0.1, 1, 0.1, 1, 4)
    end)

    Signal.register('turretFire', function(isCurrentRoom)
        if not isCurrentRoom then return end
        self:play('turret_shoot', 0.5, 1, 0.1)
    end)

    Signal.register('powerGridActivate', function()
        self:play('powergrid_activate', 0.5)
        self:play('powergrid_activate_layer', 0.75)
        self:play('powergrid_zap', 0.8, 1, 0.05, 1, 4)
        self:playDelayed(0.2, 'powergrid_zap', 0.8, 1, 0.05, 1, 4)
        self:playDelayed(0.33, 'powergrid_zap', 0.8, 1, 0.05, 1, 4)
    end)

    Signal.register('powerGridCharge', function()
        self:play('powergrid_zap', 0.8, 1, 0.05, 1, 4)
    end)

    Signal.register('powerGridPowered', function()
        self:play('powergrid_powered', 0.8)
    end)

    Signal.register('turretActivate', function()
        self:play('powergrid_activate', 0.5)
        self:play('powergrid_activate_layer', 0.75)
        self:play('powergrid_zap', 0.8, 1, 0.05, 1, 4)
    end)

    Signal.register('turretCharge', function()
        self:play('powergrid_zap', 0.8, 1, 0.05, 1, 4)
    end)

    Signal.register('turretPowered', function()
        self:play('turret_powered', 0.8)
    end)

    self.lowPowerSound = self:getSound('low_power_siren', 0.66)
    self.lowPowerSound:setLooping(true)
    Signal.register('Low Power Warning Toggle On', function()
        self.lowPowerSound:play()
    end)

    Signal.register('Low Power Warning Toggle Off', function()
        self.lowPowerSound:stop()
    end)

    Signal.register('Dynamo Correct', function(kind)
        if kind == "button" then
            self:play('widget_button_press', 1, 1, 0.1)
        elseif kind == "wheel" then
            self:play('widget_wheel', 1, 1, 0.1)
            self:play('widget_flick_spring', 1, 0.8)
            self:play('widget_flick_spring', 1, 0.8)
        elseif kind == "flick" then
            self:play('widget_flick_spring', 1, 0.8)
            self:play('widget_flick_spring', 1, 1)
            self:play('widget_flick_spring', 1, 1)
        end
        self:play('powergrid_zap', 0.66, 1, 0.05, 1, 4)
    end)

    Signal.register('Dynamo Incorrect', function(kind)

    end)

    self.wheelTurn = self:getSound('widget_wheel_turn')
    self.wheelTurn:setLooping(true)
    Signal.register('Wheel Spin Start', function()
        self.wheelTurn:play()
    end)

    Signal.register('Wheel Spin Stop', function()
        self.wheelTurn:stop()
    end)
end

function SoundManager:update(dt)
    for i=#self.soundsPlaying, 1, -1 do
        local sound = self.soundsPlaying[i]
        if not sound.source:isPlaying() then
            table.remove(self.soundsPlaying, i)
        end
    end

    self.timer:update(dt)
end

function SoundManager:playMusic(name, volume, looping)
    if self.currentMusic then
        self.currentMusic:stop()
    end

    if looping == nil then
        looping = true
    end

    local music = self.music[name]
    self.currentMusic = music
    music:setVolume(music:getVolume() * volume)
    music:setLooping(looping)
    music:play()
end

function SoundManager:getSound(name, volume, pitch, pitchVariation, soundRangeStart, soundRangeEnd, doPlay)
    if soundRangeStart and soundRangeEnd then
        name = name .. love.math.random(soundRangeStart, soundRangeEnd)
    end
    local source = self.sounds[name]:clone()
    if volume == nil then
        volume = 1
    end
    if pitch == nil then
        pitch = 1
    end
    if pitchVariation == nil then
        pitchVariation = 0
    end
    table.insert(self.soundsPlaying, {
        name = name,
        source = source,
    })
    if #self.soundsPlaying > self.maxSoundsPlaying then
        local sound = table.remove(self.soundsPlaying, 1)
        sound.source:stop()
    end
    if pitchVariation > 0 then
        local min = (pitch * 100) - pitchVariation * 100
        local max = (pitch * 100) + pitchVariation * 100
        local p = love.math.random(min, max) / 100
        source:setPitch(p)
    else
        source:setPitch(pitch)
    end
    source:setVolume(volume * source:getVolume())
    return source
end

function SoundManager:play(name, volume, pitch, pitchVariation, soundRangeStart, soundRangeEnd)
    local source = self:getSound(name, volume, pitch, pitchVariation, soundRangeStart, soundRangeEnd)
    source:play()
    return source
end

function SoundManager:playLooping(name, volume, pitch, pitchVariation, soundRangeStart, soundRangeEnd)
    local source = self:getSound(name, volume, pitch, pitchVariation, soundRangeStart, soundRangeEnd)
    source:setLooping(true)
    source:play()
    return source
end

function SoundManager:playDelayed(delay, name, volume, pitch, pitchVariation, soundRangeStart, soundRangeEnd)
    local source = self:getSound(name, volume, pitch, pitchVariation, soundRangeStart, soundRangeEnd)
    self.timer:after(delay, function()
        source:play()
    end)
    return source
end

return SoundManager
