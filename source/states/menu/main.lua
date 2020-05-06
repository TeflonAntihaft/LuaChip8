local jumpTextScaleOrig = 1.1
local jumpTextScale = jumpTextScaleOrig
local targetSize = 300
local pulseUp = false
local fullscreen = false


function load()

    require("states.menu.buttons.Load")
    require("states.menu.buttons.Credits")
    require("states.menu.buttons.Exit")
    require("states.menu.buttons.Fullscreen")

    love.graphics.setBackgroundColor(255, 255, 255)
    font = love.graphics.newFont("states/menu/assets/Minecraft.ttf", 18)
    version = love.graphics.newText(font, "beta 1.10 - 13.4.19 ")
    title = love.graphics.newImage("states/menu/assets/title.png")
    math.randomseed(os.time())
    jump_text = love.graphics.newImage("states/menu/assets/splashTexts/st" .. math.random(1, 12) .. ".png")


    local buttonPosX = love.graphics.getWidth() / 2 - 200
    local buttonPosY = love.graphics.getHeight() * 3 / 6


    startButton = Load.new(buttonPosX, buttonPosY, 400, 50)
    creditsButton = Credits.new(buttonPosX, buttonPosY + 70, 400, 50)
    exitButton = Exit.new(buttonPosX, buttonPosY + 140, 400, 50)
    fullscreenButton = Fullscreen.new(buttonPosX - 70, buttonPosY + 140, fullscreen)

    buttons = { exitButton, startButton, creditsButton, fullscreenButton }
    print("Loaded Menu")
end

function love.draw()
    for _, v in pairs(buttons) do
        drawButton(v)
    end

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(title, love.graphics.getWidth() / 2 - (title:getWidth() * 0.9) / 2, 75, 0, 0.9)
    love.graphics.draw(jump_text, love.graphics.getWidth() / 2 - (targetSize / jump_text:getWidth()) * jump_text:getWidth() * jumpTextScale  + 420, 190, -0.35, (targetSize / jump_text:getWidth()) * jumpTextScale)

    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(version, love.graphics.getWidth() * 0.8, love.graphics.getHeight() * 0.9, 0, 1, 1)
end

function love.update(dt)
    if pulseUp then
        jumpTextScale = jumpTextScale + 0.0025
        if jumpTextScale >= jumpTextScaleOrig + 0.025 then
            pulseUp = false
        end
    else
        jumpTextScale = jumpTextScale - 0.0025

        if jumpTextScale <= jumpTextScaleOrig - 0.025 then
            pulseUp = true
        end
    end
end


function love.mousepressed(x, y, button)
    if button == 1 then
        if insideBoundary(exitButton, x, y) then
            exitButton.action()
        elseif insideBoundary(startButton, x, y) then
            startButton.action(fullscreen)
        elseif insideBoundary(creditsButton, x, y) then
            creditsButton.action()
        elseif insideBoundary(fullscreenButton, x, y) then
            fullscreen = fullscreenButton.action()
        end
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

function drawButton(button)
    local inside = insideBoundary(button, love.mouse.getX(), love.mouse.getY())

    if inside then
        button:drawIn()
    else
        button:drawOut()
    end
end
