local fontHeader
local fontSubHeader
local fontText
local width = love.graphics.getWidth()
local height = love.graphics.getHeight()

local stringAccu = ""
local showSecret = false
local secretImg = love.graphics.newImage("states/menu/assets/heart.png")

local backButton
local textWidth = width * 5 / 6
local header = 'Chip8-Emulator - Lua Edition'
local credits = "Geschrieben in Lua [Copyright (c) 1994-2018 Lua.org, PUC-Rio.] \n\nMit der Hilfe von \nLove2d [Copyright (c) 2006-2019 LOVE Development Team] \nLua BitOp [Copyright (c) 2008-2012 Mike Pall] \n\nSonstige Assets \nSchriftart von [https://www.dafont.com/de/minecraft.font] \nSpiele bereitgestellt von Revival Studio [Copyright (c) 2008 Revival Studios] \n\nVielen Dank an Thomas P. Greene und David Winter fuer ihre umfangreiche Dokumentation zur Chip8 Implementation! \n\nEntwickelt von David 'teflonanti' Eckhardt"

function load()
    require("states.menu.buttons.Back")

    backButton = Back.new(width * 1 / 72, height * 64 / 72, 200, 50, function() loadState("menu") end)

    love.graphics.setBackgroundColor(255, 255, 255)
    fontHeader = love.graphics.newFont("states/menu/assets/Minecraft.ttf", 50)
    fontSubHeader = love.graphics.newFont("states/menu/assets/Minecraft.ttf", 20)
    fontText = love.graphics.newFont("states/menu/assets/Minecraft.ttf", 22)
end

function love.keypressed(key)
    --QQQQQQQ222X
    if string.upper(key) == "Q" and (stringAccu == "" or stringAccu == "Q" or stringAccu == "QQ" or stringAccu == "QQQ" or stringAccu == "QQQQ" or stringAccu == "QQQQQ" or stringAccu == "QQQQQQ") then
        stringAccu = stringAccu .. "Q"
    elseif string.upper(key) == "2" and (stringAccu == "QQQQQQQ" or stringAccu == "QQQQQQQ2" or stringAccu == "QQQQQQQ22") then
        stringAccu = stringAccu .. "2"
    elseif string.upper(key) == "X" and stringAccu == "QQQQQQQ222" then
        stringAccu = stringAccu .. "X"
    elseif string.upper(key) == "I" and stringAccu == "QQQQQQQ222X" then
        showSecret = true
    elseif key == "s" then
        print(tostring(showSecret))
    else
        stringAccu = ""
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if insideBoundary(backButton, x, y) then
            backButton.action(false)
        end
    end
end

function love.draw()
    drawCredits()

    local mx, my = love.mouse.getPosition()
    if insideBoundary(backButton, mx, my) then
        backButton.drawIn()
    else
        backButton.drawOut()
    end
    drawSecret()
end

function drawCredits()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(fontHeader)
    love.graphics.rectangle("line", width / 2 - textWidth / 2, height * 1 / 10, textWidth, 55, 20)
    love.graphics.printf(header, width / 2 - textWidth / 2, height * 1 / 10, textWidth, "center")

    --love.graphics.setFont(fontSubHeader)
    --love.graphics.printf(subHeader, width / 2 - textWidth / 2, height * 1/8 + 55, textWidth, "center" )

    love.graphics.setFont(fontText)
    love.graphics.printf(credits, width / 2 - textWidth / 2, height * 2 / 8, textWidth, "center")
end

function drawSecret()
    if showSecret then
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(fontText)
        love.graphics.printf("fuer Sophia", width / 2 - textWidth / 2 - 22, height * 7 / 8 + 20, textWidth, "center")
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(secretImg, width / 2 + 45, height * 7 / 8 + 23, 0, 1.1)
    end
end

function insideBoundary(object, x, y)
    if x >= object:getVx() and x <= object:getWx() then
        if y >= object:getVy() and y <= object:getWy() then
            return true
        end
    end
    return false
end


