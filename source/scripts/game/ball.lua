import "scripts/game/wall"
import "scripts/game/scoreBurst"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Ball').extends(gfx.sprite)

function Ball:init(x, y, fluid)
    self.fluid = fluid

    self.velocity = 8

    self.xVelocity = 4
    self.yVelocity = 4

    local ballImage = gfx.image.new("images/game/ball")
    self:setImage(ballImage)
    self:setCollideRect(0, 0, self:getSize())

    self:moveTo(x, y)
    self:add()

    self:setTag(BALL_TAG)

    self.crossedNet = false

    self.active = true
end

function Ball:collisionResponse(other)
    if other:isa(Wall) then
        return gfx.sprite.kCollisionTypeBounce
     else
         return gfx.sprite.kCollisionTypeOverlap
     end
end

function Ball:hit(hitX, hitY, isEnemy)
    if not self.active then
        return
    end

    local angleCos = (self.x - hitX) / (math.sqrt((self.x - hitX)^2 + (self.y - hitY)^2))
    local angleSin = math.sin(math.acos(angleCos))
    if isEnemy then
        angleSin *= -1
    end
    self.xVelocity = angleCos * self.velocity
    self.yVelocity = -angleSin * self.velocity
    if math.abs(self.yVelocity) < 0.5 then
        self.yVelocity = -0.5
    end
end

function Ball:update()
    if not self.active then
        return
    end

    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)
    local bounce = false
    local bounceNormal = {x = 0, y = 0}
    for i=1,length do
        local collision = collisions[i]
        if collision.other.collisionResponse == gfx.sprite.kCollisionTypeBounce then
            bounce = true
            if collision.normal.x ~= 0 then
                bounceNormal.x = collision.normal.x
            end
            if collision.normal.y ~= 0 then
                bounceNormal.y = collision.normal.y
            end
        end
    end
    if bounce then
        if bounceNormal.x ~= 0 then
            self.xVelocity *= -1
        end
        if bounceNormal.y ~= 0 then
            self.yVelocity *= -1
        end
    end

    if math.abs(self.y - 120) <= 5 and not self.crossedNet then
        self.crossedNet = true
        self.fluid:touch(self.x - 62, self.yVelocity)
    else
        self.crossedNet = false
    end

    if self.y <= 0 then
        self:ballScored(true)
    elseif self.y >= 240 then
        self:ballScored(false)
    end
end

function Ball:ballScored(playerScored)
    self.active = false
    self:setVisible(false)
    self.xVelocity = 0
    self.yVelocity = 0
    -- Screen Shake here
    -- Set off animation chain (blink, move To, and then set active)
    local blinkTime = 300
    self:screenShake()
    if playerScored then
        ScoreBurst(self.x, self.y + 2)
        SIGNAL_MANAGER:notify("damageEnemy")
    else
        ScoreBurst(self.x, self.y - 5)
        SIGNAL_MANAGER:notify("damagePlayer")
    end
    pd.timer.new(1000, function()
        self:setVisible(true)
        local randomX = math.random(LEFT_WALL + 10, RIGHT_WALL - 10)
        local ySpawnOffset = 60
        if playerScored then
            self:moveTo(randomX, ySpawnOffset)
        else
            self:moveTo(randomX, 240 - ySpawnOffset)
        end
        pd.timer.new(blinkTime, function()
            self:setVisible(false)
            pd.timer.new(blinkTime, function()
                self:setVisible(true)
                pd.timer.new(blinkTime, function()
                    self:setVisible(false)
                    pd.timer.new(blinkTime, function()
                        self:setVisible(true)
                        self.active = true
                    end)
                end)
            end)
        end)
    end)
end

function Ball:screenShake()
    local shakeTimer = pd.timer.new(700, 8, 0)
    shakeTimer.timerEndedCallback = function()
        pd.display.setOffset(0, 0)
    end
    shakeTimer.updateCallback = function(timer)
        local shakeAmount = timer.value
        local shakeAngle = math.random()*math.pi*2;
        shakeX = math.floor(math.cos(shakeAngle)*shakeAmount);
        shakeY = math.floor(math.sin(shakeAngle)*shakeAmount);
        pd.display.setOffset(shakeX, shakeY)
    end
end