
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
CHEF_UNLOCKED = false
KNIGHT_UNLOCKED = false

local gameData = pd.datastore.read()
if gameData then
    CHEF_UNLOCKED = gameData.chefUnlocked
    KNIGHT_UNLOCKED = gameData.knightUnlocked
end

SIGNAL_MANAGER = Signal()
SCENE_MANAGER = SceneManager()

import "scripts/title/titleScene"

GAME_MUSIC = pd.sound.sampleplayer.new("sound/game/Ludum Dare 38 - Track 4")

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

CRANK_SENSE = 10
menu:addOptionsMenuItem("Crank Sens", {"low", "med", "hi"}, "med", function(value)
    if value == "low" then
        CRANK_SENSE = 15
    elseif value == "med" then
        CRANK_SENSE = 10
    elseif value == "hi" then
        CRANK_SENSE = 5
    end
end)


SHAKER = Shaker.new(function()
    if SHAKE_SENSE > 0 then
        SIGNAL_MANAGER:notify("playdateShook")
    end
end, {sensitivity = Shaker.kSensitivityMedium, threshold = 0.4, samples = 20})
SHAKER:setEnabled(true)

SHAKE_SENSE = 0.4
menu:addOptionsMenuItem("Shake Sens", {"low", "med", "hi", "off"}, "off", function(value)
    if value == "low" then
        SHAKE_SENSE = 0.3
        SHAKER.threshold = SHAKE_SENSE
    elseif value == "med" then
        SHAKE_SENSE = 0.2
        SHAKER.threshold = SHAKE_SENSE
    elseif value == "high" then
        SHAKE_SENSE = 0.1
        SHAKER.threshold = SHAKE_SENSE
    elseif value =="off" then
        SHAKE_SENSE = 0
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
