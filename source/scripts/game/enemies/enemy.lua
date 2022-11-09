import "libraries/AnimatedSprite"
import "scripts/game/player/racquet"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local DIRECTION = {
    LEFT = -1,
    RIGHT = 1,
    IDLE = 0
}

class('Enemy').extends(AnimatedSprite)

function Enemy:init(x, y, ball)
    self.ball = ball

    local enemySpriteSheet = gfx.imagetable.new("images/player/player-table-32-34")
    Enemy.super.init(self, enemySpriteSheet)
    self:addState("idle", 1, 4, {tickStep = 4})
    self:addState("run", 5, 8, {tickStep = 4})

    self:playAnimation()

    self.velocity = 0
    self.startVelocity = 1
    self.acceleration = 0.3
    self.friction = 0.3
    self.idleVelocity = 0.3

    -- Adjustable Attributes
    self.maxVelocity = 3
    self.hitRange = 60
    self.hitRangeX = 65
    self.hitRangeY = 60
    -- Hit cooldown
    -- Hit velocity

    self:moveTo(x, y)

    self.racquet = Racquet(x, y + 10, self, true)

    self.leftWall = LEFT_WALL
    self.rightWall = RIGHT_WALL

    self:setZIndex(10)
end

function Enemy:update()
    local moveDirection = DIRECTION.IDLE
    if self.ball.x < self.x then
        moveDirection = DIRECTION.LEFT
    elseif self.ball.x > self.x then
        moveDirection = DIRECTION.RIGHT
    end

    if moveDirection == DIRECTION.LEFT then
        self:changeState("run")
        if self.velocity >= 0 then
            self.velocity = -self.startVelocity
        else
            self.velocity -= self.acceleration
            if math.abs(self.velocity) >= self.maxVelocity then
                self.velocity = -self.maxVelocity
            end
        end
    elseif moveDirection == DIRECTION.RIGHT then
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

    -- if self:distanceToBall() <= self.hitRange then
    if self:ballInHitRange() then
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

function Enemy:distanceToBall()
    return math.sqrt((self.x - self.ball.x)^2 + (self.y - self.ball.y)^2)
end

function Enemy:ballInHitRange()
    local xDist = math.abs(self.x - self.ball.x)
    local yDist = math.abs(self.y - self.ball.y)
    return xDist <= self.hitRangeX and yDist <= self.hitRangeY
end