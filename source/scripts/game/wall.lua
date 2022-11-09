
local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Wall').extends(gfx.sprite)

function Wall:init(x, y, width, height)
    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:setCollideRect(0, 0, width, height)
    self.collisionResponse = gfx.sprite.kCollisionTypeBounce
    self:add()
end