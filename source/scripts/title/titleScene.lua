import "scripts/game/gameScene"
import "scripts/game/player/characterStats"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local util <const> = utilities
local characterStats <const> = CHARACTER_STATS

class('TitleScene').extends(gfx.sprite)

function TitleScene:init()
    local backgroundImage = gfx.image.new(400, 240, gfx.kColorBlack)
    gfx.sprite.setBackgroundDrawingCallback(
        function()
            backgroundImage:draw(0, 0)
        end
    )

    local titleSprite = util.animatedSprite("images/title/almostTennisTitle-table-237-137", 20, true)
    titleSprite:moveTo(200, -90)
    self.titleSprite = titleSprite
    self.titleAnimator = self:entranceAnimator(titleSprite, 1000, -90, 90)

    local instructionImage = gfx.image.new("images/title/startInstruction")
    local instructionSprite = gfx.sprite.new(instructionImage)
    self.instructionSprite = instructionSprite
    instructionSprite:add()
    instructionSprite:moveTo(200, 260)
    self.instructionAnimator = self:entranceAnimator(instructionSprite, 1500, 260, 215)
    self.blinkDelay = pd.timer.performAfterDelay(1500, function()
        self.blinkTimer = pd.timer.new(500)
        self.blinkTimer.repeats = true
        self.blinkTimer.timerEndedCallback = function()
            instructionSprite:setVisible(not instructionSprite:isVisible())
        end
    end)

    self:add()

    self.characterSelection = false

    local characterBannerImage = gfx.image.new("images/title/allCharactersLocked")
    if CHEF_UNLOCKED then
        characterBannerImage = gfx.image.new("images/title/allCharacters")
    elseif KNIGHT_UNLOCKED then
        characterBannerImage = gfx.image.new("images/title/allCharactersKnightUnlocked")
    end
    self.characterBanner = gfx.sprite.new(characterBannerImage)
    self.characterBanner:moveTo(600, -120)
    self.characterBanner:add()

    self.characters = {
        "contender",
        "knight",
        "chef"
    }

    self.selectedIndex = 1

    self.scrollPosition = 600
    self.scrollAnimator = pd.timer.new(500)
    self.scrollAnimator.discardOnCompletion = false
    self.scrollAnimator.easingFunction = pd.easingFunctions.outCubic
    self.scrollAnimator:pause()
    self.scrollAnimator.updateCallback = function(timer)
        self.scrollPosition = timer.value
    end
    self.scrollAnimator.timerEndedCallback = function(timer)
        self.scrollPosition = timer.endValue
    end

    local almostTennisSound = pd.sound.sampleplayer.new("sound/title/almostTennis")
    almostTennisSound:playAt(pd.sound.getCurrentTime() + .15)
    self.lowWhooshSound = pd.sound.sampleplayer.new("sound/title/lowWhoosh")
    self.lowWhooshSound:playAt(pd.sound.getCurrentTime() + .3)
    self.medWhooshSound = pd.sound.sampleplayer.new("sound/title/mediumWhoosh")
    self.confirmSound = pd.sound.sampleplayer.new("sound/title/confirm")
    self.errorSound = pd.sound.sampleplayer.new("sound/title/error")
end

function TitleScene:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        if not self.characterSelection then
            self.characterSelection = true
            self:characterSelectAnimation()
            self.medWhooshSound:play()
        else
            local selectedCharacter = self.characters[self.selectedIndex]
            local validSelection = true
            if selectedCharacter == "knight" and not KNIGHT_UNLOCKED then
                validSelection = false
            elseif selectedCharacter == "chef" and not CHEF_UNLOCKED then
                validSelection = false
            end

            if validSelection then
                self.confirmSound:play()
                SELECTED_CHARACTER = selectedCharacter
                MAX_HEALTH = characterStats[selectedCharacter].maxHealth
                CUR_HEALTH = MAX_HEALTH
                SCENE_MANAGER:switchScene(GameScene)
            else
                self.errorSound:play()
            end
        end
    end

    if self.characterSelection then
        if pd.buttonJustPressed(pd.kButtonLeft) then
            if self.selectedIndex > 1 then
                self.medWhooshSound:play()
                self.selectedIndex -= 1
                self:animateScroll(self.selectedIndex)
            end
        elseif pd.buttonJustPressed(pd.kButtonRight) then
            if self.selectedIndex < #self.characters then
                self.medWhooshSound:play()
                self.selectedIndex += 1
                self:animateScroll(self.selectedIndex)
            end
        end
    end

    self.characterBanner:moveTo(self.scrollPosition, self.characterBanner.y)
end

function TitleScene:animateScroll(index)
    local newPos = 600 - (index - 1) * 400
    self.scrollAnimator:reset()
    self.scrollAnimator.startValue = self.scrollPosition
    self.scrollAnimator.endValue = newPos
    self.scrollAnimator:start()
end

function TitleScene:entranceAnimator(sprite, time, startVal, endVal)
    local animator = pd.timer.new(time, startVal, endVal, pd.easingFunctions.inOutCubic)
    animator.updateCallback = function(timer)
        sprite:moveTo(sprite.x, timer.value)
    end
    animator.timerEndedCallback = function(timer)
        sprite:moveTo(sprite.x, timer.endValue)
    end
    return animator
end

function TitleScene:characterSelectAnimation()
    self.titleAnimator:remove()
    self.instructionAnimator:remove()
    self.blinkDelay:remove()
    if self.blinkTimer then
        self.blinkTimer:remove()
    end
    self.instructionSprite:setVisible(true)
    local titleAnimator = pd.timer.new(1000, 200, -200, pd.easingFunctions.inOutCubic)
    titleAnimator.updateCallback = function(timer)
        self.titleSprite:moveTo(timer.value, self.titleSprite.y)
        self.instructionSprite:moveTo(400 - timer.value, self.instructionSprite.y)
    end
    local characterBannerAnimator = pd.timer.new(700, self.characterBanner.y, -self.characterBanner.y, pd.easingFunctions.inOutCubic)
    characterBannerAnimator.updateCallback = function(timer)
        self.characterBanner:moveTo(self.characterBanner.x, timer.value)
    end
end