import "scripts/game/wall"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Ball').extends(gfx.sprite)

function Ball:init(x, y)
    self.velocity = 8

    self.xVelocity = 4
    self.yVelocity = 4

    local ballImage = gfx.image.new("images/game/ball")
    self:setImage(ballImage)
    self:setCollideRect(0, 0, self:getSize())

    self:moveTo(x, y)
    self:add()

    self:setTag(BALL_TAG)
end

function Ball:collisionResponse(other)
    if other:isa(Wall) then
        return gfx.sprite.kCollisionTypeBounce
     else
         return gfx.sprite.kCollisionTypeOverlap
     end
end

function Ball:hit(hitX, hitY)
    local angleCos = (self.x - hitX) / (math.sqrt((self.x - hitX)^2 + (self.y - hitY)^2))
    local angleSin = math.sin(math.acos(angleCos))
    print("Cosine" ..  angleCos)
    print("Sine" ..  angleSin)
    self.xVelocity = angleCos * self.velocity
    self.yVelocity = -angleSin * self.velocity
    if math.abs(self.yVelocity) < 0.5 then
        self.yVelocity = -0.5
    end
end

function Ball:update()
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
end