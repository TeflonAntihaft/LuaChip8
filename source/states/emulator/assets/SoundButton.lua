SoundButton = {}

SoundButton.new = function(x, y, width, height, init)
    local self = self or {}

    self.name = name
    self.Vx = x
    self.Vy = y
    self.Wx = x + width
    self.Wy = y + height
    self.width = width
    self.height = height

    self.muted = init

    self.inOn = love.graphics.newImage("states/emulator/assets/icons/soundOnInvert.png")
    self.outOn = love.graphics.newImage("states/emulator/assets/icons/soundOn.png")
    self.inOff = love.graphics.newImage("states/emulator/assets/icons/soundOffInvert.png")
    self.outOff = love.graphics.newImage("states/emulator/assets/icons/soundOff.png")

    self.scaleFactorX = width / self.inOn:getWidth()
    self.scaleFactorY = height / self.inOn:getHeight()

    self.drawOut = function()
        love.graphics.setColor(255, 255, 255)
        if not self.muted then
            love.graphics.draw(self.outOn, self.Vx, self.Vy, 0, self.scaleFactorX, self.scaleFactorY)
        else
            love.graphics.draw(self.outOff, self.Vx, self.Vy, 0, self.scaleFactorX, self.scaleFactorY)
        end
        --love.graphics.setColor(0, 0, 0)
        --love.graphics.rectangle("line", self.Vx + 1, self.Vy + 1, self.width - 2, self.height - 2)
    end

    self.drawIn = function()
        love.graphics.setColor(255, 255, 255)
        if not self.muted then
            love.graphics.draw(self.inOn, self.Vx, self.Vy, 0, self.scaleFactorX, self.scaleFactorY)
        else
            love.graphics.draw(self.inOff, self.Vx, self.Vy, 0, self.scaleFactorX, self.scaleFactorY)
        end
    end

    self.toggle = function(bool)
        self.muted = bool
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

