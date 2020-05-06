-- Created in IntelliJ IDEA.
-- User: David Eckhardt
-- Date: 27.03.2019
-- Time: 19:28
-- Copyright (c) 2019 David Eckhardt
--
function clearLoveCallbacks()
    love.draw = nil
    love.keypressed = nil
    love.keyreleased = nil
    love.load = nil
    love.mousepressed = nil
    love.mousereleased = nil
    love.update = nil
end

function loadState(name)
    clearLoveCallbacks()
    local path = "states/" .. name
    require(path .. "/main")
    package.loaded[path .. "/main"] = nil
    load()
    print("Sucessfull loaded state!")
end

function load()
    --currently nothing to load :-(
end

function love.load()
    love.window.setFullscreen(false, "desktop")
    icon = love.image.newImageData("LuaChip8Icon.png")
    love.window.setIcon(icon)
    loadState("menu")
end