import "scripts/game/healthbar/animatedHeart"
import "scripts/game/healthbar/hurtBurst"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('HealthBar').extends()

function HealthBar:init(health, isEnemy)
    local fullHeartImage = gfx.image.new("images/game/heartFull")
    self.fullHeartSprite = gfx.sprite.new(fullHeartImage)
    self.fullHeartSprite:setZIndex(1000)
    local halfHeartImage = gfx.image.new("images/game/heartHalf")
    self.halfHeartSprite = gfx.sprite.new(halfHeartImage)
    self.halfHeartSprite:setZIndex(1000)

    self.gap = 20
    if isEnemy then
        self.baseX = 29
        self.baseY = 15
        self.dir = 1
    else
        self.baseX = 400 - 29
        self.baseY = 240 - 15
        self.dir = -1
    end

    self.heartArray = {}

    local drawX, drawY = self.baseX, self.baseY
    for i=1, math.floor(health / 2) do
        local fullHeartSpriteCopy = self.fullHeartSprite:copy()
        fullHeartSpriteCopy:moveTo(drawX, drawY)
        fullHeartSpriteCopy:add()
        self.heartArray[i] = fullHeartSpriteCopy
        drawY += self.gap * self.dir
    end
    if health % 2 ~= 0 then
        local halfHeartSpriteCopy = self.halfHeartSprite:copy()
        halfHeartSpriteCopy:moveTo(drawX, drawY)
        halfHeartSpriteCopy:add()
        self.heartArray[math.ceil(health / 2)] = halfHeartSpriteCopy
    end

    self.health = health
end

function HealthBar:damage()
    local curHealthSprite = self.heartArray[math.ceil(self.health / 2)]
    HurtBurst(self.baseX, curHealthSprite.y)
    curHealthSprite:remove()

    self.health -= 1
    local heartY = self.baseY + self.dir * (math.ceil(self.health/2) - 1) * self.gap
    if self.health % 2 ~= 0 then
        local halfHeartSpriteCopy = self.halfHeartSprite:copy()
        halfHeartSpriteCopy:moveTo(self.baseX, heartY)
        halfHeartSpriteCopy:add()
        self.heartArray[math.ceil(self.health / 2)] = halfHeartSpriteCopy
    end

    if self.health <= 0 then
        -- Signal death
    end
end