import "libraries/AnimatedSprite"
import "scripts/game/player/hitbox"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Racquet').extends(AnimatedSprite)

function Racquet:init(x, y, entity)
    self.entity = entity
    local racquetSpriteSheet = gfx.imagetable.new("images/player/racquetSwingLarge-table-125-95")
    Racquet.super.init(self, racquetSpriteSheet)
    self:addState("idle", 1, 120, {tickStep = 1})
    self:addState("swing", 121, 144, {tickStep = 1, nextAnimation = "idle"})

    self.swingFrame = 122
    -- self.states["swing"].onFrameChangedEvent = function()
    --     if self:getCurrentFrameIndex() == swingFrame then
    --         Hitbox(self.x - 64, self.y - 55, 127, 70, self.entity.x, self.entity.y)
    --         self:createHitbox()
    --     end
    -- end
    self.hit = false
    self.states["swing"].onAnimationEndEvent = function()
        self.hit = false
    end

    self:moveTo(x, y)
    self:playAnimation()

    local xOffset, yOffset = 0, 0
    local hitboxWidth, hitboxHeight = 127, 70
    self:setCollideRect(xOffset, yOffset, hitboxWidth, hitboxHeight)
    self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
end

function Racquet:update()
    if self:getCurrentFrameIndex() == self.swingFrame then
        if not self.hit then
            local overlappingSprites = self:overlappingSprites()
            for i=1,#overlappingSprites do
                local curSprite = overlappingSprites[i]
                if curSprite:getTag() == BALL_TAG then
                    if self:alphaCollision(curSprite) then
                        self.hit = true
                        curSprite:hit(self.x, self.y)
                    end
                end
            end
        end
    end

    self:updateAnimation()
end

function Racquet:swing()
    self:changeState("swing")
end

function Racquet:isSwinging()
    return self.currentState == "swing"
end

function Racquet:flip(direction)
    self.globalFlip = direction
end