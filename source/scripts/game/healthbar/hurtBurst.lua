
local pd <const> = playdate
local gfx <const> = playdate.graphics

class('HurtBurst').extends(gfx.sprite)

function HurtBurst:init(x, y)
    local imageTable = gfx.imagetable.new("images/game/hurtBurst-table-72-89")
    self.animationLoop = gfx.animation.loop.new(10, imageTable, false)
    self:setZIndex(1500)
    self:moveTo(x, y)
    self:add()
end

function HurtBurst:update()
    self:setImage(self.animationLoop:image())
    if not self.animationLoop:isValid() then
        self:remove()
    end
end