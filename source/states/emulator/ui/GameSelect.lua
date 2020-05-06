GameSelect = {}

GameSelect.new = function(x, y, width, height)

    local self = self or {}

    require("states.emulator.ui.Entry")
    --package.loaded["states.emulator.ui.Entry"] = nil

    self.Vx = x
    self.Vy = y
    self.width = width
    self.height = height
    self.Wx = x + width
    self.Wy = y + height

    self.games = love.filesystem.getDirectoryItems("gamefiles/")
    self.amount = tablelength(self.games)
    self.entryHeight = self.height / self.amount
    self.selectedGame = "NONE"

    self.entryList = {}

    for index, gameName in ipairs(self.games) do
        table.insert(self.entryList, Entry.new(self.Vx, self.Vy + (index - 1) * self.entryHeight, self.width, self.entryHeight, gameName))
    end


    self.draw = function(mouseX, mouseY, drawIn)

        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("line", self.Vx, self.Vy, self.width, self.height)

        for _, entry in ipairs(self.entryList) do
            entry.draw(mouseX, mouseY, drawIn)
        end
    end

    self.click = function(xpos, ypos)
        for _, entry in ipairs(self.entryList) do
            local game = entry.onClick(xpos, ypos)
            if not (game == "NOT ME!") then
                self.selectedGame = game
            end
        end
        for _, entry in ipairs(self.entryList) do
            if entry.name ~= self.selectedGame then
                entry.selected = false
            end
        end


        print("Loaded Game " .. self.selectedGame)
        return self.selectedGame
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

function tablelength(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

