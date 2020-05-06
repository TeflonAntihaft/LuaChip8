Entry = {}

Entry.new = function(x, y, width, height, name)

    local self = self or {}

    self.Vx = x
    self.Vy = y
    self.Wx = x + width
    self.Wy = y + height
    self.width = width
    self.height = height
    self.name = name
    self.formatedName = string.gsub(self.name, "_", " ")


    if love.graphics.getWidth() == 1920 then
        self.FONT_SIZE = 24
        self.arrow = love.graphics.newImage("states/emulator/assets/icons/arrow_big.png")
    else
        self.FONT_SIZE = 14 self.SCALE = 1
        self.arrow = love.graphics.newImage("states/emulator/assets/icons/arrow_small.png")
    end
    self.selected = false

    local font = love.graphics.newFont("states/menu/assets/Minecraft.ttf", self.FONT_SIZE)

    self.draw = function(mousex, mousey, drawIn)
        love.graphics.setFont(font)
        if self.insideBoundary(mousex, mousey) and drawIn then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", self.Vx, self.Vy, self.width, self.height)

            love.graphics.setColor(255, 255, 255)
            love.graphics.printf(self.formatedName, self.Vx, self.Vy + self.FONT_SIZE / 5, self.width, "center")
            if self.selected then
                love.graphics.draw(self.arrow, self.Wx, self.Vy)
            end
        elseif self.selected then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", self.Vx, self.Vy, self.width, self.height)

            love.graphics.setColor(255, 255, 255)
            love.graphics.printf(self.formatedName, self.Vx, self.Vy + self.FONT_SIZE / 5, self.width, "center")
            love.graphics.draw(self.arrow, self.Wx, self.Vy, 0, self.SCALE, self.SCALE)
        else
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", self.Vx, self.Vy, self.width, self.height)

            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(self.formatedName, self.Vx, self.Vy + self.FONT_SIZE / 5, self.width, "center")
        end
    end

    self.insideBoundary = function(xc, yc)
        if xc >= self.Vx and xc <= self.Wx then
            if yc >= self.Vy and yc <= self.Wy then
                return true
            end
        end
        return false
    end

    self.onClick = function(mousex, mousey)
        if (self.insideBoundary(mousex, mousey)) then
            self.selected = true
            return self.name
        else
            return "NOT ME!"
        end
    end

    self.setSelected = function(val)
        self.selected = val
    end

    return self
end
