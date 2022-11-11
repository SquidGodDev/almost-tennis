
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"

import "libraries/Signal"
import "libraries/Utilities"
import "libraries/SceneManager"

local pd <const> = playdate
local gfx <const> = playdate.graphics

math.randomseed(pd.getSecondsSinceEpoch())

BALL_TAG = 20
LEFT_WALL = 62
RIGHT_WALL = 337

CUR_LEVEL = 1
MAX_HEALTH = 8
CUR_HEALTH = 6

SIGNAL_MANAGER = Signal()
SCENE_MANAGER = SceneManager()

import "scripts/game/gameScene"
import "scripts/title/titleScene"

-- GameScene()
TitleScene()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.drawFPS(5, 5)
end
