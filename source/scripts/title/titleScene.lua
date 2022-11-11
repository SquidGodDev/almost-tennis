import "scripts/game/gameScene"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local util <const> = utilities

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
    self:entranceAnimator(titleSprite, 1000, -90, 90)

    local instructionImage = gfx.image.new("images/title/startInstruction")
    local instructionSprite = gfx.sprite.new(instructionImage)
    instructionSprite:add()
    instructionSprite:moveTo(200, 260)
    self:entranceAnimator(instructionSprite, 1500, 260, 215)
    pd.timer.performAfterDelay(1500, function()
        local blinkTimer = pd.timer.new(500)
        blinkTimer.repeats = true
        blinkTimer.timerEndedCallback = function()
            instructionSprite:setVisible(not instructionSprite:isVisible())
        end
    end)

    self:add()
end

function TitleScene:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        SCENE_MANAGER:switchScene(GameScene)
    end
end

function TitleScene:entranceAnimator(sprite, time, startVal, endVal)
    local animator = pd.timer.new(time, startVal, endVal, pd.easingFunctions.inOutCubic)
    animator.updateCallback = function(timer)
        sprite:moveTo(sprite.x, timer.value)
    end
    animator.timerEndedCallback = function(timer)
        sprite:moveTo(sprite.x, timer.endValue)
    end
end