
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/game/gameScene"

local pd <const> = playdate
local gfx <const> = playdate.graphics

BALL_TAG = 20

GameScene()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end
