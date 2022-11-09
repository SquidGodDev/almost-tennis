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

    local swingFrame = 121
    self.states["swing"].onFrameChangedEvent = function()
        if self:getCurrentFrameIndex() == swingFrame then
            local xOffset, yOffset = -64, -47
            local hitboxWidth, hitboxHeight = 127, 60
            Hitbox(self.x + xOffset, self.y + yOffset, hitboxWidth, hitboxHeight, self.entity)
        end
    end

    self:moveTo(x, y)
    self:playAnimation()
end

function Racquet:update()
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