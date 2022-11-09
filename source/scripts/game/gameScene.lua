import "scripts/game/player/player"
import "scripts/game/wall"
import "scripts/game/ball"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('GameScene').extends(gfx.sprite)

function GameScene:init()
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

    Player(200, 220)
    Wall(52, 0, 10, 240)
    Wall(338, 0, 10, 240)
    Wall(10, -10, 380, 10)
    Wall(10, 240, 380, 10)
    Ball(200, 120)

    self:add()
end

function GameScene:update()
    
end