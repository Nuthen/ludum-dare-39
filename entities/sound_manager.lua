local SoundManager = Class('SoundManager')

function SoundManager:initialize(soundCatalog, musicCatalog)
    self.sounds = {}
    self.defaultSoundVolume = SETTINGS.soundVolume * 0.5

    for name, sound in pairs(soundCatalog) do
        local source = love.audio.newSource(sound)
        source:setVolume(self.defaultSoundVolume)
        self.sounds[name] = source
    end

    self.music = {}
    self.defaultMusicVolume = SETTINGS.musicVolume

    for name, music in pairs(musicCatalog) do
        local source = love.audio.newSource(music)
        source:setVolume(self.defaultMusicVolume)
        self.music[name] = source
    end

    Signal.register('gameStart', function()
        local sound = self.sounds.background_engine_hum
        sound:setVolume(sound:getVolume() * 0.25)
        sound:setLooping(true)
        sound:play()

        local music = self.music.buzzy
        music:setVolume(music:getVolume() * 0.3)
        music:setLooping(true)
        music:play()
    end)

    Signal.register('enemyDeath', function()
        self:play('enemy_death', 0.66, 1, 0.1, 1, 4)
        self:play('enemy_death_impact', 0.33, 1, 0.1)
    end)

    self.maxSoundsPlaying = SETTINGS.maxSoundsPlaying
    self.soundsPlaying = {}
end

function SoundManager:update(dt)
    for i=#self.soundsPlaying, 1, -1 do
        local source = self.soundsPlaying[i]
        if not source:isPlaying() then
            table.remove(self.soundsPlaying, i)
        end
    end
end

function SoundManager:play(name, volume, pitch, pitchVariation, soundRangeStart, soundRangeEnd)
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
    table.insert(self.soundsPlaying, source)
    if #self.soundsPlaying > self.maxSoundsPlaying then
        local source = table.remove(self.soundsPlaying, 1)
        source:stop()
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
    source:play()
    return source
end

return SoundManager
