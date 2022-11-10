
local pd <const> = playdate
local gfx <const> = playdate.graphics

class('AnimatedHeart').extends(gfx.sprite)

function AnimatedHeart:init(x, y, isFull)
    if isFull then
        self.heartImageTable = gfx.imagetable.new("images/game/heartFullSkew-table-25-25")
    else
        self.heartImageTable = gfx.imagetable.new("images/game/heartHalfSkew-table-25-25")
    end
    self.animationLoop = gfx.animation.loop.new(20, self.heartImageTable, false)
    self:setZIndex(1500)
    self:moveTo(x, y)
    self:add()
end

function AnimatedHeart:update()
    self:setImage(self.animationLoop:image())
    if not self.animationLoop:isValid() then
        self:remove()
    end
end