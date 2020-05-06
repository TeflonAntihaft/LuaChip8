UpDownButton = {}

UpDownButton.new = function(x, y, width, height, name, action)
    local self = self or {}

    self.name = name
    self.Vx = x
    self.Vy = y
    self.Wx = x + width
    self.Wy = y + height
    self.width = width
    self.height = height

    self.outGraphic = love.graphics.newImage("states/emulator/assets/icons/" .. name .. ".png")
    self.inGraphic = love.graphics.newImage("states/emulator/assets/icons/" .. name .. "Invert.png")

    self.scaleFactorX = width / self.outGraphic:getWidth()
    self.scaleFactorY = height / self.outGraphic:getHeight()

    self.drawOut = function()
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(self.outGraphic, self.Vx, self.Vy, 0, self.scaleFactorX, self.scaleFactorY)
        --love.graphics.setColor(0, 0, 0)
        --love.graphics.rectangle("line", self.Vx + 1, self.Vy + 1, self.width - 2, self.height - 2)
    end

    self.drawIn = function()
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(self.inGraphic, self.Vx, self.Vy, 0, self.scaleFactorX, self.scaleFactorY)
    end

    self.action = action

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