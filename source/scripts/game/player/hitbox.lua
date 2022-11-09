
local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Hitbox').extends(gfx.sprite)

function Hitbox:init(x, y, width, height, sourceX, sourceY)
    self:setCollideRect(0, 0, width, height)
    self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    self:setCenter(0, 0)
    self:moveTo(x, y)

    self.sourceX = sourceX
    self.sourceY = sourceY

    pd.timer.new(100, function()
        self:remove()
    end)

    self.hit = false

    self:add()
end

function Hitbox:update()
    if not self.hit then
        local overlappingSprites = self:overlappingSprites()
        for i=1,#overlappingSprites do
            local curSprite = overlappingSprites[i]
            if curSprite:getTag() == BALL_TAG then
                self.hit = true
                curSprite:hit(self.sourceX, self.sourceY)
            end
        end
    end
end