
local pd <const> = playdate
local gfx <const> = playdate.graphics

local fadedRects = {}
for i=0,1,0.01 do
    local fadedImage = gfx.image.new(400, 240)
    gfx.pushContext(fadedImage)
        local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
        filledRect:drawFaded(0, 0, i, gfx.image.kDitherTypeBayer8x8)
    gfx.popContext()
    fadedRects[math.floor(i * 100)] = fadedImage
end
fadedRects[100] = gfx.image.new(400, 240, gfx.kColorBlack)

class('SceneManager').extends()

function SceneManager:init()
    self.transitionTime = 500
    self.transitioning = false
end

function SceneManager:switchScene(scene, ...)
    if self.transitioning then
        return
    end

    self.transitioning = true

    self.newScene = scene
    local args = {...}
    self.sceneArgs = args

    self:startTransition()
end

function SceneManager:loadNewScene()
    self:cleanupScene()
    self.newScene(table.unpack(self.sceneArgs))
end

function SceneManager:cleanupScene()
    gfx.sprite.removeAll()
    self:removeAllTimers()
    gfx.setDrawOffset(0, 0)
end

function SceneManager:startTransition()
    local transitionTimer = self:fadeTransition(0, 1)

    transitionTimer.timerEndedCallback = function()
        self:loadNewScene()
        transitionTimer = self:fadeTransition(1, 0)
        transitionTimer.timerEndedCallback = function()
            self.transitioning = false
            self.transitionSprite:remove()
            local allSprites = gfx.sprite.getAllSprites()
            for i=1,#allSprites do
                allSprites[i]:markDirty()
            end
        end
    end
end

function SceneManager:fadeTransition(startValue, endValue)
    local transitionSprite = self:createTransitionSprite()
    transitionSprite:setImage(self:getFadedImage(startValue))

    local transitionTimer = pd.timer.new(self.transitionTime, startValue, endValue, pd.easingFunctions.inOutCubic)
    transitionTimer.updateCallback = function(timer)
        transitionSprite:setImage(self:getFadedImage(timer.value))
    end
    return transitionTimer
end

function SceneManager:getFadedImage(alpha)
    return fadedRects[math.floor(alpha * 100)]
end


function SceneManager:createTransitionSprite()
    local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
    local transitionSprite = gfx.sprite.new(filledRect)
    transitionSprite:moveTo(200, 120)
    transitionSprite:setZIndex(10000)
    transitionSprite:setIgnoresDrawOffset(true)
    transitionSprite:add()
    self.transitionSprite = transitionSprite
    return transitionSprite
end

function SceneManager:removeAllTimers()
    local allTimers = pd.timer.allTimers()
    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end