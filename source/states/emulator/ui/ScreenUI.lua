ScreenUI = {}

ScreenUI.new = function(x, y, height)
    local self = self or {}

    require("states.emulator.assets.noGame")
    require("states.emulator.assets.pause")
    self.Vx = x
    self.Vy = y
    self.width = height * 2
    self.height = height
    self.Wx = x + self.width
    self.Wy = y + self.height
    self.rectSide = height / 32

    --init disp with no Game
    self.display = {}
    for x = 0, 63 do
        self.display[x] = {}
        for y = 0, 31 do
            self.display[x][y] = noGameData[y * 64 + x + 1]
        end
    end

    self.draw = function()
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", self.Vx - 5, self.Vy - 5, self.width + 10, self.height + 10)

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", self.Vx, self.Vy, self.width, self.height)

        love.graphics.setColor(255, 255, 255)
        for x = 0, 63 do
            for y = 0, 31 do
                if (self.display[x][y] == 1) then
                    love.graphics.rectangle("fill", self.Vx + self.rectSide * x, self.Vy + self.rectSide * y, self.rectSide, self.rectSide)
                end
            end
        end
    end

    self.clear = function()
        for i = 0, 63 do
            self.display[i] = {}
            for l = 0, 31 do
                self.display[i][l] = 0
            end
        end
    end

    self.flush = function()
        print("----------------------------------------------------------------")
        for y = 0, 31 do
            for x = 0, 63 do
                pixel = self.display[x][y]
                if pixel == 0 then
                    io.write(" ")
                else
                    io.write("@")
                end
                io.flush()
            end
            print("")
        end
        print("----------------------------------------------------------------")
        print("\n ")
    end

    self.pause = function()
        for x = 15, 46 do
            for y = 7, 22 do
                self.display[x][y] = pauseData[(y - 7) * 32 + (x - 15) + 1]
            end
        end
    end

    self.loadDisplay = function(newDisp)
        for i = 0, 63 do
            for l = 0, 31 do
                self.display[i][l] = newDisp[i][l]
            end
        end
    end

    self.getDisplay = function()
        return self.display
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

