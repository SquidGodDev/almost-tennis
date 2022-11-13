
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

SELECTED_CHARACTER = "contender"
CHEF_UNLOCKED = true
KNIGHT_UNLOCKED = true

-- local gameData = pd.datastore.read()
-- if gameData then
--     CHEF_UNLOCKED = gameData.chefUnlocked
--     KNIGHT_UNLOCKED = gameData.knightUnlocked
-- end

SIGNAL_MANAGER = Signal()
SCENE_MANAGER = SceneManager()

import "scripts/title/titleScene"

GAME_MUSIC = pd.sound.fileplayer.new("sound/game/Ludum Dare 38 - Track 4")

local menu = pd.getSystemMenu()
menu:addOptionsMenuItem("Music", {"low", "med", "high", "off"}, "med", function(value)
    if value == "low" then
        GAME_MUSIC:setVolume(0.33)
    elseif value == "med" then
        GAME_MUSIC:setVolume(0.66)
    elseif value == "high" then
        GAME_MUSIC:setVolume(1)
    elseif value == "off" then
        GAME_MUSIC:setVolume(0)
    end
end)

TitleScene()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end

function pd.gameWillTerminate()
    local saveData = {
        chefUnlocked = CHEF_UNLOCKED,
        knightUnlocked = KNIGHT_UNLOCKED
    }
    pd.datastore.write(saveData)
end

function pd.gameWillSleep()
    local saveData = {
        chefUnlocked = CHEF_UNLOCKED,
        knightUnlocked = KNIGHT_UNLOCKED
    }
    pd.datastore.write(saveData)
end
