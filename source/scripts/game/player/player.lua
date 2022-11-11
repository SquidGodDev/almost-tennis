import "libraries/AnimatedSprite"
import "scripts/game/player/racquet"
import "scripts/game/healthbar/healthbar"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(AnimatedSprite)

function Player:init(x, y)
    local playerSpriteSheet = gfx.imagetable.new("images/player/player-table-32-34")
    Player.super.init(self, playerSpriteSheet)
    self:addState("idle", 1, 4, {tickStep = 4})
    self:addState("run", 5, 8, {tickStep = 4})
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

    -- Adjustable Attributes
    self.healthbar = HealthBar(8, false)
    self.maxVelocity = 3
    self.hitVelocity = 8


    self:moveTo(x, y)


    self.racquet = Racquet(x, y - 10, self, false, self.hitVelocity)

    self.leftWall = LEFT_WALL
    self.rightWall = RIGHT_WALL

    self:setZIndex(10)
end

function Player:update()
    if self.currentState == "death" then
        self:updateAnimation()
        return
    end

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
        elseif self.velocity  then
            self.velocity -= self.friction
        end
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        self.racquet:swing()
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
    end
    self:updateAnimation()
end

function Player:damage()
    self.healthbar:damage()
    if self:isDead() then
        self:changeState("death")
        self.racquet:remove()
    end
end

function Player:isDead()
    return self.healthbar:isDead()
end
