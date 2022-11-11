import "scripts/title/titleScene"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('GameEndScene').extends(gfx.sprite)

function GameEndScene:init()
    local fireworksImageTable = gfx.imagetable.new("images/game/end/loopingFireworks-table-400-240")
    self.animationLoop = gfx.animation.loop.new(20, fireworksImageTable, true)
    self:moveTo(200, 120)
    self:add()

    local congratsImage = gfx.image.new("images/game/end/congratulationsText")
    local congratsSprite = gfx.sprite.new(congratsImage)
    congratsSprite:moveTo(200, 120)
    congratsSprite:add()
    local congratsAnimateTimer = pd.timer.new(4000, 0, 2*math.pi)
    congratsAnimateTimer.repeats = true
    congratsAnimateTimer.updateCallback = function(timer)
        congratsSprite:moveTo(200, 120 + 5 * math.sin(timer.value))
    end
end

function GameEndScene:update()
    self:setImage(self.animationLoop:image())
    if pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB) then
        SCENE_MANAGER:switchScene(TitleScene)
    end
end