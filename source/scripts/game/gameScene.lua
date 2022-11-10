import "scripts/game/player/player"
import "scripts/game/enemies/enemy"
import "scripts/game/wall"
import "scripts/game/ball"
import "libraries/Fluid"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('GameScene').extends(gfx.sprite)

function GameScene:init()
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

    local ball = Ball(200, 120, fluid)
    Player(200, 220)
    Enemy(200, 20, ball)
    Wall(52, 0, 10, 240)
    Wall(338, 0, 10, 240)
    -- Wall(10, -10, 380, 10)
    -- Wall(10, 240, 380, 10)

    self:add()
end

function GameScene:update()
    
end