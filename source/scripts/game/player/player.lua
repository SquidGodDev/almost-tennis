import "libraries/AnimatedSprite"
import "scripts/game/player/racquet"
import "scripts/game/healthbar/healthbar"
import "scripts/game/player/characterStats"
import "scripts/game/player/powerBar"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local characterStats <const> = CHARACTER_STATS
local util <const> = utilities

class('Player').extends(AnimatedSprite)

function Player:init(x, y)
    self.pulseRing = util.animatedSprite("images/player/pulseRing-table-62-62", 20, true)
    self.pulseRing:add()
    self.pulseRing:setVisible(false)

    self.spinBurstImageTable = gfx.imagetable.new("images/player/spinBurst-table-89-87")
    self.spinBurstSprite = gfx.sprite.new()
    self.spinBurstSprite:add()
    function self.spinBurstSprite:update()
        if self.animationLoop then
            self:setImage(self.animationLoop:image())
        end
    end

    local curCharStats = characterStats[SELECTED_CHARACTER]
    local playerSpriteSheet = gfx.imagetable.new(curCharStats.imageTablePath)
    Player.super.init(self, playerSpriteSheet)
    self:addState("idle", 1, 4, {tickStep = 4})
    self:addState("run", 5, 8, {tickStep = 4})
    self:addState("dash", 5, 8, {tickStep = 4})
    self:addState("death", 9, 15, {tickStep = 6, loop = false})
    self.states["death"].onAnimationEndEvent = function()
        self:remove()
    end

    self:playAnimation()

    self.velocity = 0
    self.startVelocity = 1
    self.acceleration = 0.3
    self.friction = 0.3
    self.idleVelocity = 0.3

    self.dashSpeed = 10
    self.dashFriction = 0.7

    self.bonusPower = 5

    -- Adjustable Attributes
    self.healthbar = HealthBar(CUR_HEALTH, false)
    self.maxVelocity = curCharStats.maxVelocity
    self.hitVelocity = curCharStats.hitVelocity

    self:moveTo(x, y)
    self.pulseRing:moveTo(x, y)
    self.spinBurstSprite:moveTo(x, y)

    self.racquet = Racquet(x, y - 10, self, false, self.hitVelocity)

    self.leftWall = LEFT_WALL
    self.rightWall = RIGHT_WALL

    self:setZIndex(10)

    self.powerBar = PowerBar(curCharStats.maxCharge)
    SIGNAL_MANAGER:subscribe("ballHit", self, function()
        self.powerBar:updateCharge(10)
    end)
end

function Player:update()
    if self.currentState == "death" then
        self:updateAnimation()
        return
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        self.racquet:swing()
        self.pulseRing:setVisible(false)
    end

    if not (self.currentState == "dash") then
        if pd.buttonIsPressed(pd.kButtonLeft) then
            self:changeState("run")
            if self.velocity >= 0 then
                self.velocity = -self.startVelocity
            else
                self.velocity -= self.acceleration
                if math.abs(self.velocity) >= self.maxVelocity then
                    self.velocity = -self.maxVelocity
                end
            end
        elseif pd.buttonIsPressed(pd.kButtonRight) then
            self:changeState("run")
            if self.velocity <= 0 then
                self.velocity = self.startVelocity
            else
                self.velocity += self.acceleration
                if self.velocity >= self.maxVelocity then
                    self.velocity = self.maxVelocity
                end
            end
        else
            self:changeState("idle")
            if math.abs(self.velocity) <= self.idleVelocity then
                self.velocity = 0
            elseif self.velocity < 0 then
                self.velocity += self.friction
            elseif self.velocity > 0 then
                self.velocity -= self.friction
            end
        end
    else
        if self.velocity < 0 then
            self.velocity += self.dashFriction
        elseif self.velocity > 0 then
            self.velocity -= self.dashFriction
        end

        if math.abs(self.velocity) <= self.idleVelocity then
            self.velocity = 0
            self:changeState("idle")
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        local chargeAvailable = self.powerBar:useCharge()
        if chargeAvailable then
            if SELECTED_CHARACTER == "contender" then
                self:dashAbility()
            elseif SELECTED_CHARACTER == "knight" then
                self.racquet:setBonusPower(self.bonusPower)
                self.pulseRing:setVisible(true)
            elseif SELECTED_CHARACTER == "chef" then
                self.racquet:resetState()
                self.spinBurstSprite.animationLoop = gfx.animation.loop.new(20, self.spinBurstImageTable, false)
            end
        end
    end

    if not self.racquet:isSwinging() then
        if self.velocity < 0 then
            self.globalFlip = 1
            self.racquet:flip(1)
            self.racquet:moveTo(self.x, self.racquet.y)
        elseif self.velocity > 0 then
            self.globalFlip = 0
            self.racquet:flip(0)
            self.racquet:moveTo(self.x, self.racquet.y)
        end
    end

    local wallBuffer = 10
    local passingLeftWall = self.velocity < 0 and self.x <= self.leftWall + wallBuffer
    local passingRightWall = self.velocity > 0 and self.x >= self.rightWall - wallBuffer
    if not passingLeftWall and not passingRightWall then
        self:moveBy(self.velocity, 0)
        self.racquet:moveBy(self.velocity, 0)
        self.pulseRing:moveBy(self.velocity, 0)
        self.spinBurstSprite:moveBy(self.velocity, 0)
    end
    self:updateAnimation()
end

function Player:damage()
    self.healthbar:damage()
    CUR_HEALTH = self.healthbar.health
    if self:isDead() then
        self:changeState("death")
        self.racquet:remove()
    end
end

function Player:isDead()
    return self.healthbar:isDead()
end

function Player:dashAbility()
    local direction = 1
    if self.globalFlip == 1 then
        direction = -1
    end
    if pd.buttonIsPressed(pd.kButtonLeft) then
        direction = -1
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        direction = 1
    end
    self.velocity = direction * self.dashSpeed
    self:changeState("dash")
end
