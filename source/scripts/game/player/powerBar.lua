import "libraries/utilities"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local util <const> = utilities

class('PowerBar').extends(gfx.sprite)

function PowerBar:init(maxCharge)
    self.curCharge = 0
    self.maxCharge = maxCharge

    local powerBarBackground = gfx.image.new("images/player/powerBarBackground")
    self:setImage(powerBarBackground)
    self:setCenter(0, 0)
    self:moveTo(352, 145)
    self:setZIndex(1000)
    self:add()

    local bImage = gfx.image.new("images/player/bImage")
    self.bSprite = gfx.sprite.new(bImage)
    self.bSprite:setCenter(0, 0)
    self.bSprite:moveTo(352, 118)
    self.bSprite:setVisible(false)
    self.bSprite:setZIndex(1000)
    self.bSprite:add()

    self.powerBarWave = util.animatedSprite("images/player/powerBarWave-table-34-97", 20, true)
    self.powerBarWave:setVisible(false)
    self.powerBarWave:setCenter(0, 0)
    self.powerBarWave:moveTo(345, 141)
    self.powerBarWave:setZIndex(1300)
    self.powerBarWave:add()

    self.drawWidth = 12
    self.maxDrawHeight = 81
    self.drawHeight = 0
    self.drawAnimator = pd.timer.new(500)
    self.drawAnimator.discardOnCompletion = false
    self.drawAnimator.easingFunction = pd.easingFunctions.outCubic
    self.drawAnimator:pause()
    self.drawAnimator.updateCallback = function(timer)
        self.drawHeight = timer.value
    end
    self.drawAnimator.timerEndedCallback = function(timer)
        self.drawHeight = timer.endValue
    end

    self.barSprite = gfx.sprite.new()
    self.barSprite:setZIndex(1000)
    self.barSprite:setCenter(0, 0)
    self.barSprite:moveTo(356, 149)
    self.barSprite:add()

    self.powerupSound = pd.sound.sampleplayer.new("sound/game/powerup")
    self.chargeSound = pd.sound.sampleplayer.new("sound/game/charge")
    self.useChargeSound = pd.sound.sampleplayer.new("sound/game/useCharge")
    self.powerupSoundPlayed = false
end

function PowerBar:update()
    local barImage = gfx.image.new(self.drawWidth, self.maxDrawHeight)
    gfx.pushContext(barImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, self.maxDrawHeight - self.drawHeight, self.drawWidth, self.drawHeight)
    gfx.popContext()
    self.barSprite:setImage(barImage)
end

function PowerBar:useCharge()
    if self.curCharge >= self.maxCharge then
        self.curCharge = 0
        self:animateBar(self.curCharge)
        self.powerupSoundPlayed = false
        self.useChargeSound:play()
        self.powerBarWave:setVisible(false)
        self.bSprite:setVisible(false)
        return true
    end
    return false
end

function PowerBar:updateCharge(amount)
    self.curCharge += amount
    if self.curCharge >= self.maxCharge then
        if not self.powerupSoundPlayed then
            self.powerupSoundPlayed = true
            self.powerupSound:play()
            self.chargeSound:play()
        end
        self.curCharge = self.maxCharge
        self.powerBarWave:setVisible(true)
        self.bSprite:setVisible(true)
    else
        self.chargeSound:play()
    end
    self:animateBar(self.curCharge)
end

function PowerBar:animateBar(newCharge)
    local newDrawHeight = (newCharge / self.maxCharge) * self.maxDrawHeight
    self.drawAnimator:reset()
    self.drawAnimator.startValue = self.drawHeight
    self.drawAnimator.endValue = newDrawHeight
    self.drawAnimator:start()
end