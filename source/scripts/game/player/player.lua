import "libraries/AnimatedSprite"
import "scripts/game/player/racquet"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(AnimatedSprite)

function Player:init(x, y)
    local playerSpriteSheet = gfx.imagetable.new("images/player/player-table-32-34")
    Player.super.init(self, playerSpriteSheet)
    self:addState("idle", 1, 4, {tickStep = 4})
    self:addState("run", 5, 8, {tickStep = 4})

    self:playAnimation()

    self.velocity = 0
    self.startVelocity = 1
    self.maxVelocity = 3
    self.acceleration = 0.3
    self.friction = 0.3

    self.idleVelocity = 0.3

    self:moveTo(x, y)

    self.racquetOffset = 0
    self.racquet = Racquet(x + self.racquetOffset, y - 10, self)

    self:setZIndex(10)
end

function Player:update()
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

    -- if self.currentState == "idle" then
    --     if math.abs(self.velocity) > self.idleVelocity then
    --         self:changeState("run")
    --     end
    -- elseif self.currentState == "run" then
    --     if math.abs(self.velocity) <= self.idleVelocity then
    --         self:changeState("idle")
    --     end
    -- end

    if not self.racquet:isSwinging() then
        if self.velocity < 0 then
            self.globalFlip = 1
            self.racquet:flip(1)
            self.racquet:moveTo(self.x - self.racquetOffset, self.racquet.y)
        elseif self.velocity > 0 then
            self.globalFlip = 0
            self.racquet:flip(0)
            self.racquet:moveTo(self.x + self.racquetOffset, self.racquet.y)
        end
    end

    self:moveBy(self.velocity, 0)
    self.racquet:moveBy(self.velocity, 0)
    self:updateAnimation()
end