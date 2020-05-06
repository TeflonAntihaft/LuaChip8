local bit = require("bit")
RegisterSet = {}

RegisterSet.new = function()
    local self = self or {}

    for i = 0, 15 do
        self[i] = 0
    end

    self.put = function(reg, val)
        --if (reg == "I") then
        --    self[reg] = bit.band(val, 0x0FFF)
        if (reg < 16) then
            self[reg] = bit.band(val, 0xFF)
        else
            error("register out of bounds access")
        end
    end

    self.get = function(reg)
        return self[reg]
    end

    self.dump = function()
        print("Current register values")
        for i = 0, 15 do
            print("V" .. i .. ": " .. self.get(i))
        end
    end

    return self
end

