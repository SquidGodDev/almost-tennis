
local pd <const> = playdate
local gfx <const> = playdate.graphics

class('ScoreBurst').extends(gfx.sprite)

function ScoreBurst:init(x, y)
    local burstImageTable = gfx.imagetable.new("images/game/scoreBurst-table-94-133")
    self.animationLoop = gfx.animation.loop.new(20, burstImageTable, false)
    self:moveTo(x, y)
    self:add()
end

function ScoreBurst:update()
    self:setImage(self.animationLoop:image())
    if not self.animationLoop:isValid() then
        self:remove()
    end
end