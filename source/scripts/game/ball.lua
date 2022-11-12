import "scripts/game/wall"
import "scripts/game/scoreBurst"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local util <const> = utilities

class('Ball').extends(gfx.sprite)

function Ball:init(x, y, fluid)
    self.fluid = fluid

    self.xVelocity = 0
    self.yVelocity = 0

    local ballImage = gfx.image.new("images/game/ball")
    self:setImage(ballImage)
    self:setCollideRect(0, 0, self:getSize())

    self:moveTo(x, y)
    self:add()

    self:setTag(BALL_TAG)

    self.crossedNet = false

    self:setVisible(false)
    self.active = false
end

function Ball:initEntities(player, enemy)
    self.player = player
    self.enemy = enemy
end

function Ball:collisionResponse(other)
    if other:isa(Wall) then
        return gfx.sprite.kCollisionTypeBounce
     else
         return gfx.sprite.kCollisionTypeOverlap
     end
end

function Ball:hit(hitX, hitY, isEnemy, hitVelocity)
    if not self.active then
        return false
    end

    local angleCos = (self.x - hitX) / (math.sqrt((self.x - hitX)^2 + (self.y - hitY)^2))
    local angleSin = math.sin(math.acos(angleCos))
    if isEnemy then
        angleSin *= -1
    end
    self.xVelocity = angleCos * hitVelocity
    self.yVelocity = -angleSin * hitVelocity
    if math.abs(self.yVelocity) < 0.5 then
        self.yVelocity = -0.5
    end
    return true
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
    self:screenShake()
    if playerScored then
        ScoreBurst(self.x, self.y + 2)
        self.enemy:damage()
        if self.enemy:isDead() then
            SIGNAL_MANAGER:notify("enemyDied")
            self.active = false
            self:setVisible(false)
            self.xVelocity = 0
            self.yVelocity = 0
            return
        end
    else
        ScoreBurst(self.x, self.y - 5)
        self.player:damage()
        if self.player:isDead() then
            SIGNAL_MANAGER:notify("playerDied")
            self.active = false
            self:setVisible(false)
            self.xVelocity = 0
            self.yVelocity = 0
            return
        end
    end
    self:resetBall(playerScored)
end

function Ball:resetBall(spawnAtEnemySide)
    local blinkTime = 300
    self.active = false
    self:setVisible(false)
    self.xVelocity = 0
    self.yVelocity = 0
    local randomX = math.random(LEFT_WALL + 10, RIGHT_WALL - 10)
    local ySpawnOffset = 60
    local spawnY = ySpawnOffset
    if not spawnAtEnemySide then
        spawnY = 240 - ySpawnOffset
    end
    local spawnBurstSprite = util.animatedSprite("images/game/spawnBurst-table-93-96", 20, false)
    spawnBurstSprite:setZIndex(2000)
    spawnBurstSprite:moveTo(randomX, spawnY)
    pd.timer.new(800, function()
        self:setVisible(true)
        self:moveTo(randomX, spawnY)
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