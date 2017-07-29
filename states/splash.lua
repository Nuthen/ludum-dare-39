local Sprite = require 'entities.sprite'

local splash = {}

function splash:init()
    self.componentList = {
        {
            parent = self,
            image = Sprite:new('assets/images/splashscreen_logo.png'),
            initialAlpha = 0,
            finalAlpha = 255,
            fadeInTime = 2,
            stillTime = 2,
            fadeOutTime = 2,
            init = function(self)
                self.image.position = Vector(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
                self.image.scale = Vector(2, 2)
                self.image:moveOriginToCorner('center')

                self.alpha = self.initialAlpha
                Timer.tween(self.fadeInTime, self, {alpha=self.finalAlpha}, 'linear', function()
                    Timer.tween(self.stillTime, self, {}, 'linear', function()
                        Timer.tween(self.fadeOutTime, self, {alpha=self.initialAlpha}, 'linear', function()
                            self.parent:incrementActive()
                        end)
                    end)
                end)
            end,
            draw = function(self)
                self.image.color[4] = self.alpha
                self.image:draw()
            end,
        },
    }

    for k, component in pairs(self.componentList) do
        component:init()
    end

    self.active = 1
end

function splash:enter()

end

function splash:incrementActive()
    self.active = self.active + 1
    if self.active > #self.componentList then
        State.switch(States.menu)
    end
end

function splash:update(dt)

end

function splash:keyreleased(key, code)
    State.switch(States.menu)
end

function splash:touchreleased(id, x, y, dx, dy, pressure)
    State.switch(States.menu)
end

function splash:mousepressed(x, y, mbutton)

end

function splash:draw()
    local activeComponent = self.componentList[self.active]
    activeComponent:draw()
end

return splash
