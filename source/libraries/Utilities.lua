local pd <const> = playdate
local gfx <const> = playdate.graphics

utilities = {}

function utilities.centeredTextSprite(text)
    local descriptionImage = gfx.image.new(gfx.getTextSize(text))
    gfx.pushContext(descriptionImage)
        gfx.drawText(text, 0, 0)
    gfx.popContext()
    return gfx.sprite.new(descriptionImage)
end

function utilities.centeredTextImage(text)
    local descriptionImage = gfx.image.new(gfx.getTextSize(text))
    gfx.pushContext(descriptionImage)
        gfx.drawText(text, 0, 0)
    gfx.popContext()
    return descriptionImage
end