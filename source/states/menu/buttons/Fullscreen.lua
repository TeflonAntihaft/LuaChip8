Fullscreen = {}

Fullscreen.new = function(x, y, init)
    local self = self or {}

    self.iconOn = love.graphics.newImage("states/menu/assets/iconOn.png")
    self.iconOff = love.graphics.newImage("states/menu/assets/iconOff.png")
    self.iconOnInvert = love.graphics.newImage("states/menu/assets/iconOnInvert.png")
    self.iconOffInvert = love.graphics.newImage("states/menu/assets/iconOffInvert.png")
    self.scale = 1.64
    self.Vx = x
    self.Vy = y
    self.width = (self.iconOn:getWidth() * self.scale)
    self.height = (self.iconOn:getHeight() * self.scale)

    self.Wx = x + self.width
    self.Wy = y + self.height
    self.toggel = init

    self.drawOut = function()
        love.graphics.setColor(255, 255, 255)
        if self.toggle then
            love.graphics.draw(self.iconOn, self.Vx, self.Vy, 0, self.scale)
        else
            love.graphics.draw(self.iconOff, self.Vx, self.Vy, 0, self.scale)
        end
    end

    self.drawIn = function()
        love.graphics.setColor(255, 255, 255)
        if self.toggle then
            love.graphics.draw(self.iconOnInvert, self.Vx, self.Vy, 0, self.scale)
        else
            love.graphics.draw(self.iconOffInvert, self.Vx, self.Vy, 0, self.scale)
        end
    end

    self.action = function()
        print("Triggered")
        self.toggle = not self.toggle
        return self.toggle
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
