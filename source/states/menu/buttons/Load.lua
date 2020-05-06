Load = {}

Load.new = function(x, y, width, height)
    local self = self or {}

    self.Vx = x
    self.Vy = y
    self.Wx = x + width
    self.Wy = y + height
    self.width = width
    self.height = height
    self.font = love.graphics.newFont("states/menu/assets/Minecraft.ttf", 24)
    self.text = love.graphics.newText(self.font, "Starten")

    self.drawIn = function()
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", self.Vx, self.Vy, self.width, self.height)
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(self.text, self.Vx + width / 2 - self.text:getWidth() / 2,
            self.Vy + height / 2 - self.text:getHeight() / 2, 0, 1, 1)
    end

    self.drawOut = function()
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", self.Vx, self.Vy, self.width, self.height)
        love.graphics.draw(self.text, self.Vx + width / 2 - self.text:getWidth() / 2,
            self.Vy + height / 2 - self.text:getHeight() / 2, 0, 1, 1)
    end

    self.action = function(fullscreen)
        print(tostring(fullscreen))
        if fullscreen then love.window.setMode(1920, 1080) end
        loadState("emulator")
    end

    self.getVx = function()
        return self.Vx
    end

    self.getVy = function()
        return self.Vy
    end
    self.getWx = function()
        return self.Wx
    end

    self.getWy = function()
        return self.Wy
    end

    return self
end


