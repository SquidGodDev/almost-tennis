
local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Hitbox').extends(gfx.sprite)

function Hitbox:init(x, y, width, height, sourceEntity, isEnemy)
    self:setCollideRect(0, 0, width, height)
    self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    self:setCenter(0, 0)
    self:moveTo(x, y)

    self.sourceEntity = sourceEntity

    pd.timer.new(100, function()
        self:remove()
    end)

    self.hit = false
    self.isEnemy = isEnemy

    self:add()
end

function Hitbox:update()
    if not self.hit then
        local overlappingSprites = self:overlappingSprites()
        for i=1,#overlappingSprites do
            local curSprite = overlappingSprites[i]
            if curSprite:getTag() == BALL_TAG then
                self.hit = true
                curSprite:hit(self.sourceEntity.x, self.sourceEntity.y, self.isEnemy)
            end
        end
    end
end