StackSet = {}

StackSet.new = function()
    local self = self or {}

    self.SP = 0
    self.strct = {}

    self.push = function(val)
        if self.SP == 15 then
            error("exceeded max. amount of subroutine calls")
        else
            self.strct[self.SP] = val
            self.SP = self.SP + 1
        end
    end

    self.pop = function()
        if self.SP == 0 then
            error("nothing to return from")
        else
            self.SP = self.SP - 1
            return self.strct[self.SP]
        end
    end

    self.dump = function()
        print("Current stack:")
        for i = 0, self.SP - 1 do
            print("Pos. " .. i .. ": " .. self.strct[i])
        end
    end

    return self
end
