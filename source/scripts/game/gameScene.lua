import "scripts/game/player/player"
import "scripts/game/enemies/enemy"
import "scripts/game/enemies/enemyList"
import "scripts/game/wall"
import "scripts/game/ball"
import "scripts/title/titleScene"
import "libraries/Fluid"
import "scripts/game/gameEndScene"
import "scripts/game/player/characterStats"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local characterStats <const> = CHARACTER_STATS

local enemyList <const> = ENEMY_LIST

class('GameScene').extends(gfx.sprite)

function GameScene:init()
    if not GAME_MUSIC:isPlaying() then
        GAME_MUSIC:play(0)
    end
    gfx.setBackgroundColor(gfx.kColorBlack)
    local backgroundImage = gfx.image.new("images/game/background")
    gfx.sprite.setBackgroundDrawingCallback(
        function()
            backgroundImage:draw(0, 0)
        end
    )

    local wallImage = gfx.image.new("images/game/walls")
    local wallSprite = gfx.sprite.new(wallImage)
    wallSprite:moveTo(200, 120)
    wallSprite:setZIndex(100)
    wallSprite:add()

    local fluidWidth, fluidHeight = 276, 40
    local fluidOptions = {
        tension = 0.35,
        dampening = 0.005
    }
    local fluid = Fluid.new(0, 20, fluidWidth, fluidHeight, fluidOptions)
    local fluidSprite = gfx.sprite.new()
    fluidSprite:setSize(fluidWidth, 40)
    fluidSprite:setCenter(0, 0)
    fluidSprite:moveTo(62, 100)
    fluidSprite:add()
    function fluidSprite:update()
        fluid:update()
        local fluidImage = gfx.image.new(fluidWidth, 40)
        gfx.pushContext(fluidImage)
            gfx.setLineWidth(2)
            gfx.setColor(gfx.kColorWhite)
            fluid:draw()
        gfx.popContext()
        self:setImage(fluidImage)
    end

    self.ball = Ball(200, 120, fluid)
    local player = Player(200, 220)
    local enemy = Enemy(200, 20, self.ball)
    self.ball:initEntities(player, enemy)
    Wall(52, 0, 10, 240)
    Wall(338, 0, 10, 240)
    -- Wall(10, -10, 380, 10)
    -- Wall(10, 240, 380, 10)

    self:add()

    SIGNAL_MANAGER:subscribe("damagePlayer", self, function()
        player:damage()
    end)

    SIGNAL_MANAGER:subscribe("damageEnemy", self, function()
        enemy:damage()
    end)

    SIGNAL_MANAGER:subscribe("playerDied", self, function()
        self:createGameEndAnimation(false)
    end)

    SIGNAL_MANAGER:subscribe("enemyDied", self, function()
        self:createGameEndAnimation(true)
    end)


    self:createEntranceAnimation()
end

function GameScene:createGameEndAnimation(win)
    local resultSashImage
    if win then
        local victorySound = pd.sound.sampleplayer.new("sound/game/victory")
        victorySound:playAt(pd.sound.getCurrentTime() + .2)
        resultSashImage = gfx.image.new("images/game/victorySash")
    else
        local defeatSound = pd.sound.sampleplayer.new("sound/game/defeat")
        defeatSound:playAt(pd.sound.getCurrentTime() + .2)
        resultSashImage = gfx.image.new("images/game/defeatSash")
    end

    resultSashSprite = gfx.sprite.new(resultSashImage)
    resultSashSprite:setZIndex(3000)
    resultSashSprite:moveTo(200, 120)
    resultSashSprite:add()
    resultSashSprite:setClipRect(0, 0, 0, 240)
    local resultSashTimer = pd.timer.new(2000, 0, 400, pd.easingFunctions.inOutCubic)
    resultSashTimer.updateCallback = function(timer)
        resultSashSprite:setClipRect(0, 0, timer.value, 240)
    end
    resultSashTimer.timerEndedCallback = function()
        pd.timer.performAfterDelay(1000, function()
            if win then
                CUR_LEVEL += 1
                CUR_HEALTH += 2
                if CUR_HEALTH > MAX_HEALTH then
                    CUR_HEALTH = MAX_HEALTH
                end
                if CUR_LEVEL > 10 then
                    GAME_MUSIC:stop()
                    SCENE_MANAGER:switchScene(GameEndScene)
                else
                    SCENE_MANAGER:switchScene(GameScene)
                end
            else
                GAME_MUSIC:stop()
                SCENE_MANAGER:switchScene(TitleScene)
            end
        end)
    end
end

function GameScene:createEntranceAnimation()
    -- Sash
    local leftCenter, rightCenter = 88, 311
    local sashWidth, sashHeight = 100, 240
    local sashImage = gfx.image.new(sashWidth, sashHeight, gfx.kColorWhite)
    local sashSpriteLeft = gfx.sprite.new(sashImage)
    sashSpriteLeft:setZIndex(3000)
    local sashSpriteRight = sashSpriteLeft:copy()
    sashSpriteLeft:moveTo(leftCenter, -120)
    sashSpriteLeft:add()
    sashSpriteRight:moveTo(rightCenter, 240 + 120)
    sashSpriteRight:add()

    local sashTimer = pd.timer.new(1000, -120, 120, pd.easingFunctions.inOutCubic)
    sashTimer.delay = 500
    local metalDoorSlideSound = pd.sound.sampleplayer.new("sound/game/intro/metalDoorSliding")
    pd.timer.performAfterDelay(500, function()
        metalDoorSlideSound:play()
    end)
    sashTimer.updateCallback = function(timer)
        sashSpriteLeft:moveTo(sashSpriteLeft.x, timer.value)
        sashSpriteRight:moveTo(sashSpriteRight.x, 240 - timer.value)
    end

    -- Character Images
    local curCharStats = characterStats[SELECTED_CHARACTER]
    local playerImage = gfx.imagetable.new(curCharStats.imageTablePath):getImage(1)
    local enemyData = enemyList[CUR_LEVEL]
    local enemyImage = gfx.imagetable.new(enemyData.imageTablePath):getImage(1)
    local playerImageSprite = gfx.sprite.new(playerImage:scaledImage(2))
    playerImageSprite:setZIndex(3000)
    playerImageSprite:moveTo(leftCenter, -100)
    playerImageSprite:add()
    local enemyImageSprite = gfx.sprite.new(enemyImage:scaledImage(2))
    enemyImageSprite:setZIndex(3000)
    enemyImageSprite:moveTo(rightCenter, -100)
    enemyImageSprite:add()

    local medLowWhooshSound1 = pd.sound.sampleplayer.new("sound/game/intro/medLowWhoosh")
    local imagesTimer = pd.timer.new(1500, -100, 80, pd.easingFunctions.inOutCubic)
    imagesTimer.delay = 1000
    pd.timer.performAfterDelay(1500, function()
        medLowWhooshSound1:play()
    end)
    imagesTimer.updateCallback = function(timer)
        playerImageSprite:moveTo(playerImageSprite.x, timer.value)
        enemyImageSprite:moveTo(enemyImageSprite.x, timer.value)
    end

    -- Character Names
    local playerNameImage = gfx.image.new("images/player/youName")
    local enemyNameImage = gfx.image.new(enemyData.nameImagePath)
    local playerNameSprite = gfx.sprite.new(playerNameImage)
    local enemyNameSprite = gfx.sprite.new(enemyNameImage)
    playerNameSprite:setZIndex(3000)
    playerNameSprite:moveTo(leftCenter, 300)
    playerNameSprite:add()
    enemyNameSprite:setZIndex(3000)
    enemyNameSprite:moveTo(rightCenter, 300)
    enemyNameSprite:add()

    local nameTimer = pd.timer.new(1500, 300, 180, pd.easingFunctions.inOutCubic)
    nameTimer.delay = 1200
    pd.timer.performAfterDelay(1600, function()
        -- medLowWhooshSound2:play()
    end)
    nameTimer.updateCallback = function(timer)
        playerNameSprite:moveTo(playerNameSprite.x, timer.value)
        enemyNameSprite:moveTo(enemyNameSprite.x, timer.value)
    end

    -- VS
    local imageTable = gfx.imagetable.new("images/game/intro/versusShake-table-93-67")
    local animationLoop = gfx.animation.loop.new(20, imageTable, false)
    animationLoop.paused = true
    local vsSprite = gfx.sprite.new(animationLoop:image())
    vsSprite.animationLoop = animationLoop
    vsSprite:add()
    function vsSprite:update()
        self:setImage(self.animationLoop:image())
    end
    vsSprite:setZIndex(3000)
    vsSprite:moveTo(200, -40)

    local lightningSound = pd.sound.sampleplayer.new("sound/game/intro/lightning")
    local vsTimer = pd.timer.new(1000, -40, 120, pd.easingFunctions.inOutCubic)
    vsTimer.delay = 2000
    vsTimer.updateCallback = function(timer)
        vsSprite:moveTo(vsSprite.x, timer.value)
    end
    vsTimer.timerEndedCallback = function()
        animationLoop.paused = false
        lightningSound:play()
    end

    pd.timer.performAfterDelay(4000, function()
        metalDoorSlideSound:play()
        local moveLeftTimer = pd.timer.new(1000, leftCenter, -100, pd.easingFunctions.inOutCubic)
        moveLeftTimer.updateCallback = function(timer)
            sashSpriteLeft:moveTo(timer.value, sashSpriteLeft.y)
            playerImageSprite:moveTo(timer.value, playerImageSprite.y)
            playerNameSprite:moveTo(timer.value, playerNameSprite.y)
        end

        local moveRightTimer = pd.timer.new(1000, rightCenter, 500, pd.easingFunctions.inOutCubic)
        moveRightTimer.updateCallback = function(timer)
            sashSpriteRight:moveTo(timer.value, sashSpriteRight.y)
            enemyImageSprite:moveTo(timer.value, enemyImageSprite.y)
            enemyNameSprite:moveTo(timer.value, enemyNameSprite.y)
        end

        local moveUpTimer = pd.timer.new(1000, 120, -100, pd.easingFunctions.inOutCubic)
        moveUpTimer.updateCallback = function(timer)
            vsSprite:moveTo(vsSprite.x, timer.value)
        end
        moveUpTimer.timerEndedCallback = function()
            self.ball:resetBall(false)
        end
    end)
end