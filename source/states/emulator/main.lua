local FPS = 60 --desired for chip-8: 840HZ
local nextTime = love.timer.getTime() + 1 / FPS

local gameName = "NONE"
local gameInfo
local description
local info = true

local backButton

local selectList

local buttonList = {}

local muteButton
local muted = false
local volume = 0.5

local storedDisplay

local stepsPerCylce = 10

local currentGamePath
local halt = false
local stop = true

local bit = require("bit")
local isDown = love.keyboard.isDown
local currentKeys = {}

local PC = 0x200
local Register
local I = 0
local Memory
local Stack
local Screen
local Display
local DT = 0 -- delay timer
local ST = 0 -- sound timer

local height = love.graphics.getHeight()
local width = love.graphics.getWidth()

local font
local fontSize
local beep
local beepShort
local beepPlaying = false

local loadStoreQuirk = false
local shiftQuirk = true

local chip8_fontset = {
    0xF0, 0x90, 0x90, 0x90, 0xF0, -- 0
    0x20, 0x60, 0x20, 0x20, 0x70, -- 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, -- 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, -- 3
    0x90, 0x90, 0xF0, 0x10, 0x10, -- 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, -- 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, -- 6
    0xF0, 0x10, 0x20, 0x40, 0x40, -- 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, -- 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, -- 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, -- A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, -- B
    0xF0, 0x80, 0x80, 0x80, 0xF0, -- C
    0xE0, 0x90, 0x90, 0x90, 0xE0, -- D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, -- E
    0xF0, 0x80, 0xF0, 0x80, 0x80 -- F
}
local fontLocations = {}

function load()
    require("states.emulator.structures.RegisterSet")
    require("states.emulator.structures.StackSet")
    require("states.emulator.ui.ScreenUI")
    require("states.emulator.ui.GameSelect")
    require("states.menu.buttons.Back")
    require("states.emulator.assets.UpDownButton")
    require("states.emulator.assets.SoundButton")
    require("states.emulator.GAME_INFO")

    love.graphics.setBackgroundColor(204, 0, 0)

    if width == 1920 then fontSize = 52 else fontSize = 28 end
    font = love.graphics.newFont("states/menu/assets/Minecraft.ttf", fontSize)
    beep = love.audio.newSource("states/emulator/assets/320khzSaw.wav", "static")
    beepShort = love.audio.newSource("states/emulator/assets/320khzSawShort.wav", "static")

    Screen = screenSetup()

    --Make Display a wrapper for the display array of screen
    Display = Screen.display

    --save initial Display
    storedDisplay = copyDisplay()

    --seed random generator with current time
    math.randomseed(os.time())

    initUIElements()
end

local strdefi = getmetatable('').__index
getmetatable('').__index = function(str, i) if type(i) == "number" then
    return string.sub(str, i, i)
else return strdefi[i]
end
end

getmetatable('').__call = string.sub

function love.update(dt)

    --control over how many frameupdates per second
    local timedif = nextTime - love.timer.getTime() -- are we there yet?
    if timedif > 0 then love.timer.sleep(timedif) end -- wait if not
    nextTime = nextTime + 1 / FPS

    if DT > 0 then DT = DT - 1 end
    if ST > 0 then ST = ST - 1 end

    for _ = 0, stepsPerCylce do
        local lstop = stop
        if not lstop then
            execute()
        end
    end

    if ST > 0 and not beepPlaying and not muted then
        love.audio.play(beep)
        beepPlaying = true
    elseif ST == 0 and beepPlaying then
        love.audio.stop()
        beepPlaying = false
    end
end

function love.draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(font)

    drawWindow()

    Screen.draw()

    local mx, my = love.mouse.getPosition()

    selectList.draw(mx, my, not info)

    -- draw buttons of all kind
    for _, v in pairs(buttonList) do
        if insideBoundary(v, mx, my) and not info then
            v.drawIn()
        else
            v.drawOut()
        end
    end

    if insideBoundary(muteButton, mx, my) and not info then
        muteButton.drawIn()
    else
        muteButton.drawOut()
    end

    --handle infooverlay
    if info then
        drawInfoScreen()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "c" then
        --Register.dump()
        Screen.clear()
    elseif key == "i" then
        info = not info
    elseif key == "escape" then
        backButton.action(fontSize == 52) --fontsize = 52 indicates fullscreen. look at load()
    elseif keyValid(key) and not stop then
        currentKeys[keyMapper(key)] = true
    end
end

function love.keyreleased(key, scancode)
    if keyValid(key) then
        currentKeys[keyMapper(key)] = false
    end
end

function love.mousepressed(xpos, ypos, button, istouch)
    if not info then
        if insideBoundary(Screen, xpos, ypos) and gameName ~= "NONE" then
            love.mouse.setVisible(false)
            Screen.loadDisplay(storedDisplay)
            stop = false
        elseif insideBoundary(selectList, xpos, ypos) then
            loadGameAndStart(selectList.click(xpos, ypos))
        end

        for _, v in pairs(buttonList) do
            if insideBoundary(v, xpos, ypos) then
                v.action()
            end
        end

        if insideBoundary(muteButton, xpos, ypos) then
            muted = not muted
            muteButton.toggle(muted)
        end

    else
        info = false
    end
end

function love.mousemoved(xpos, ypos, dx, dy, istouch)
    if not love.mouse.isVisible() then
        love.mouse.setVisible(true)
        storedDisplay = copyDisplay()
        Screen.pause()
        stop = true
    end
end

function initUIElements()
    selectList = GameSelect.new(width * 49 / 64, height / 2 - (height * 12 / 16) / 2, width * 1 / 5, height * 12 / 16)

    local backButton = Back.new(width * 1 / 72, height * 64 / 72, 200 * (width / 960), 50  * (height / 540), function() if width == 1920 then love.window.setMode(960, 540) end loadState("menu") end)
    table.insert(buttonList, backButton)

    local soundPlusButton = UpDownButton.new((width - (height * (13 / 16)) * 2) / 2 - 5, height * 8 / 72, 32 * (width / 960), 32 * (height / 540), "soundPlus",
        function()
            if volume <= 0.9 then
                volume = volume + 0.1
            end
            love.audio.stop()
            love.audio.setVolume(volume)
            love.audio.play(beepShort)
        end)
    table.insert(buttonList, soundPlusButton)

    local soundMinusButton = UpDownButton.new((width - (height * (13 / 16)) * 2) / 2 + (32 * (width / 960)) * 2 - 5, height * 8 / 72, 32 * (width / 960), 32 * (height / 540), "soundMinus",
        function()
            if volume >= 0.1 then
                volume = volume - 0.1
            end
            love.audio.stop()
            love.audio.setVolume(volume)
            love.audio.play(beepShort)
        end)
    table.insert(buttonList, soundMinusButton)

    muteButton = SoundButton.new((width - (height * (13 / 16)) * 2) / 2 + 32 * (width / 960) - 5, height * 8 / 72, 32 * (width / 960), 32 * (height / 540), muted)
end

function loadGameAndStart(name)
    currentGamePath = "/gamefiles/" .. name

    --Init necessery structures new
    Register = RegisterSet.new()

    Stack = StackSet.new()

    DT = 0
    ST = 0
    I = 0

    --Load the gamedata as table starting at 0x200
    Memory = initGame()

    --Load fontset into memory starting at 0x0
    loadFontset()

    --Clear struct of wich key is currently down
    keysSetup()

    loadStoreQuirk = GAME_INFO[name].loadStore
    shiftQuirk = GAME_INFO[name].shift
    stepsPerCylce = GAME_INFO[name].stepsPerCycle
    description = GAME_INFO[name].desc

    gameName = name

    PC = 0x200

    halt = false
    stop = true

    Screen.clear()
    storedDisplay = copyDisplay()
    Screen.pause()
end

--main fetch, decode, execute function. performs one step if not halted
function execute()

    opcode = getOp()

    --prepare opcode parts
    p = bit.rshift(opcode, 12)
    x = bit.band(bit.rshift(opcode, 8), 0xF)
    y = bit.band(bit.rshift(opcode, 4), 0xF)
    n = bit.band(opcode, 0xF)
    kk = bit.band(opcode, 0xFF)
    nnn = bit.band(opcode, 0xFFF)

    --print("Execute " .. bit.tohex(opcode) .. " @ " .. PC)
    if (p == 0) then
        if (kk == 0xE0) then --00E0 CLS
            Screen.clear()
            --print("Display cleared")
        elseif (kk == 0xEE) then --00EE RET
            PC = Stack.pop()
            --print("Returned to " .. PC .. " from the stack")
        end

    elseif (p == 1) then --1nnn JP addr
        PC = nnn
        --print("  --Made a unconditional jump to " .. PC)
        return --necessary because PC is incremented at the start of update. Otherwise we won't execute the line we jump to.

    elseif (p == 2) then --2nnn CALL addr
        --print("  --Pushed " .. PC .. " to the stack and jumped to " .. nnn)
        Stack.push(PC)
        PC = nnn
        return

    elseif (p == 3) then --3xkk SE Vx, byte
        --print("  --Is " .. Register.get(x) .. " equal " .. kk .. " ?")
        if (Register.get(x) == kk) then
            PC = PC + 2
            --print("   -Yes! Skipped next command")
        end

    elseif (p == 4) then --4xkk SNE Vx, byte
        --print("  --Is " .. Register.get(x) .. " not equal " .. kk .. " ?")
        if (Register.get(x) ~= kk) then
            PC = PC + 2
            --print("   -Yes! Skipped next command")
        end

    elseif (p == 5) then --5xy0 SE Vx, Vy
        --print("  --Is " .. Register.get(x) .. " equal " .. Register.get(y) .. " ?")
        if (Register.get(x) == Register.get(y)) then
            PC = PC + 2
            --print("   -Yes! Skipped next command")
        end

    elseif (p == 6) then --6xkk LD Vx, byte
        Register.put(x, kk)
        --print("  --" .. bit.tohex(kk) .. " loaded in register V" .. x)
        --Register.dump()

    elseif (p == 7) then --7xkk ADD Vx, bytes
        --print("  --V" .. x .. " = " .. Register.get(x) .. " + " .. kk)
        Register.put(x, Register.get(x) + kk)
        --Register.dump()

    elseif (p == 8) then -- => mathOp's according to least significant bit
        --Register.dump()
        mathOp[n]()
        --Register.dump()

    elseif (p == 9) then --SNE Vx, Vy
        if (Register.get(x) ~= Register.get(y)) then
            PC = PC + 2
        end

    elseif (p == 10) then --LD I, addr
        I = nnn
        --Register.put("I", nnn)
        --print("  --" .. bit.tohex(nnn) .. " loaded in register VI")

    elseif (p == 11) then --JP V0, addr
        PC = bit.band((nnn + Register.get(0)), 0x0FFF)
        --print("  --Made a jump with offset from register V0 to " .. PC)
        return
    elseif (p == 12) then --RND Vx, byte
        --print("Random Number generated")
        Register.put(x, bit.band(math.random(0, 255), kk))

    elseif (p == 13) then --DRW Vx, Vy, nibble
        --print("  --Sprite drawn at " .. Register.get(x) .. "," .. Register.get(y) .. " from sprite at " .. I .. " with " .. n .. " bytes")
        drawSprite(Register.get(x), Register.get(y), I, n)

    elseif (p == 14) then
        if (kk == 0x9E) then -- SKP Vx if Vx pressed
            --print("Listening to be pressed. Key " .. Register.get(x))
            if (currentKeys[Register.get(x)]) then
                PC = PC + 2
                --print("Pressed!")
            end
        elseif (kk == 0xA1) then -- SKP Vx if Vx NOT pressed
            --print("Listening not to be pressed. Key " .. Register.get(x))
            if (not currentKeys[Register.get(x)]) then
                PC = PC + 2
                --print("Not pressed. One skiped")
            end
        end

    elseif (p == 15) then

        if (kk == 7) then -- LD Vx, DT
            Register.put(x, DT)

        elseif (kk == 10) then -- LD Vx, K
            --print("Waiting for key to be pressed..")
            halt = true
            for i = 0, 15 do
                if currentKeys[i] then
                    Register.put(x, i)
                    halt = false
                    currentKeys[i] = false
                    -- print(i .. " pressed")
                end
            end

        elseif (kk == 0x15) then -- LD DT, Vx
            DT = Register.get(x)
            --print("Delay updated")

        elseif (kk == 0x18) then -- LD ST, Vx
            ST = Register.get(x)
            --print("  --Sound timer updated.")

        elseif (kk == 0x1E) then -- ADD I, Vx
            --print("Register VI = " .. I .. " + " .. Register.get(x) .. " (V " .. x .. ")")
            I = bit.band((I + Register.get(x)), 0xFFF)
            -- Register.put("I", bit.band(Register.get("I") + Register.get(x), 0xFFF))

        elseif (kk == 0x29) then -- LD F, Vx
            -- print("  --Font " .. Register.get(x) .. " loaded from memory from register " .. x)
            I = fontLocations[Register.get(x)]
            --Register.put("I", fontLocations[Register.get(x)])

        elseif (kk == 0x33) then -- LD B, Vx : Store Vx as BCD at I to I + 2

            local Vx = Register.get(x)
            --print("  --Storing " .. Vx .. "as BCD at " .. I)
            Memory[I] = getPlaceValue(Vx, 100)
            Memory[I + 1] = getPlaceValue(Vx, 10)
            Memory[I + 2] = getPlaceValue(Vx, 1)
            --print("Result: " .. Memory[I] .. " " .. Memory[I + 1] .. " " .. Memory[I + 2])

        elseif (kk == 0x55) then -- LD [I], Vx
            storeRegisterInMemory(I, x)

        elseif (kk == 0x65) then -- LD Vx, [I]
            readRegisterFromMemory(I, x)
        end
    else
        error("Unknown Opcode")
    end

    if not halt then PC = PC + 2
    end
end

--Draw a sprite starting at spriteAddr with a given amount of height (rows) starting at display[startX, startY]
function drawSprite(startX, startY, spriteAddr, height)
    Register.put(0xF, 0) --set collision flag zero

    for yline = 0, height - 1 do
        row = Memory[spriteAddr + yline]

        for xline = 0, 7 do
            if (bit.band(row, bit.rshift(0x80, xline)) ~= 0) then -- Check if there is something to do for the current digit in the row (i.e. == 1)
                if (Display[(startX + xline) % 64][(startY + yline) % 32] == 1) then -- Is there already an pixel active?
                    Register.put(0xF, 1)
                end

                Display[(startX + xline) % 64][startY + yline % 32] = bit.bxor(Display[(startX + xline) % 64][(startY + yline) % 32], 1) -- Finally xor the pixel in question onto display wrapping around in x and y
            end
        end
    end
end

function drawInfoScreen()
    local scale = 1.3
    local infowidth = height * (6 / 10) * 2 * scale
    local infoheight = height * (6 / 10) * scale

    local infox = (width - infowidth) / 2
    local infoy = (height - infoheight) / 2

    love.graphics.setFont(font)
    love.graphics.setColor(204, 0, 0)

    love.graphics.rectangle("fill", infox - 5, infoy - 5, infowidth + 10, infoheight + 10, 15)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", infox, infoy, infowidth, infoheight, 15)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(GAME_INFO[gameName].desc, infox + 15, infoy + 15, infowidth - 30, "center")
end

function loadFontset()
    num = 0
    for i = 0, 79 do
        Memory[i] = chip8_fontset[i + 1]

        if i % 5 == 0 then
            fontLocations[num] = i
            num = num + 1
        end
    end
end


--Read the game as a string and write it as 16Bit-Hex values to a data structure starting at 0
function initGame()
    local data = {}
    setmetatable(data, {
        __index = function()
            return 0
        end
    })

    local rawString, size = love.filesystem.read(currentGamePath)

    local l = 0x200
    for i = 1, size, 1 do
        data[l] = string.byte(rawString, i)
        --print(l .. " " .. bit.tohex(data[l]))
        l = l + 1
    end

    return data
end

function keysSetup()
    for i = 0, 15 do
        currentKeys[i] = false
    end
end

function screenSetup()
    return ScreenUI.new((width - (height * (13 / 16)) * 2) / 2, height * (3 / 16), height * (10 / 16))
end

--Return current Command and increment PC
function getOp()
    return bit.bor(bit.lshift(Memory[PC], 8), Memory[PC + 1])
end

--Stores the content of registers 0 -> 15 into the memory starting at a given address
function storeRegisterInMemory(addr, endreg)
    --print("Starting to store register starting at " .. addr)
    for i = 0, endreg do
        Memory[addr + i] = Register.get(i)
    end
    if not loadStoreQuirk then
        I = I + endreg + 1
        --Register.put("I", Register.get("I") + endreg + 1)
    end
end

-- Reads new values for the registers 0 -> 15 from the memory starting at a given adress
function readRegisterFromMemory(addr, endreg)
    --print("Starting to read memory from " .. addr)
    --print("Befor;")
    --Register.dump()
    for i = 0, endreg do
        Register.put(i, Memory[addr + i])
        --print("Stored " .. Memory[addr + i] .. " at Register " .. i)
    end
    if not loadStoreQuirk then
        I = I + endreg + 1
        --Register.put("I", Register.get("I") + endreg + 1)
    end
    --print("After:")
    --Register.dump()
end

--[[
- Key-Layoutmapping
-
- 1  2  3  C      1  2  3  4
- 4  5  6  D      Q  W  E  R
- 7  8  9  E  ->  A  S  D  F
- A  0  B  F      Y  X  C  V
- original        modern
-
]] --

function keyValid(key)
    if (keyMapper(key) < 16) then
        return true
    else
        return false
    end
end

--gets a love keystring an returns the coresponding hex value or otherwise 255
function keyMapper(key)
    if key == "1" then
        return 1
    elseif key == "2" then
        return 2
    elseif key == "3" then
        return 3
    elseif key == "4" then
        return 0xC
    elseif key == "q" then
        return 4
    elseif key == "w" then
        return 5
    elseif key == "e" then
        return 6
    elseif key == "r" then
        return 0xD
    elseif key == "a" then
        return 7
    elseif key == "s" then
        return 8
    elseif key == "d" then
        return 9
    elseif key == "f" then
        return 0xE
    elseif key == "y" then
        return 0xA
    elseif key == "x" then
        return 0
    elseif key == "c" then
        return 0xB
    elseif key == "v" then
        return 0xF
    else
        return 255
    end
end


-- Returns the place value of a given decimal number Bsp.: (324, 10) => 2
function getPlaceValue(value, place)
    return ((value % (place * 10)) - (value % place)) / place
end

--table for all math operations with p = 8
mathOp = {}

mathOp[0] = function() --LD Vx, Vy
    Register.put(x, Register.get(y))
    --print(x .. " set to " .. Register.get(y))
end

mathOp[1] = function() --OR Vx, Vy
    --print("Or " .. x .. " and " .. y)
    Register.put(x, bit.bor(Register.get(x), Register.get(y)))
end

mathOp[2] = function() --AND Vx, Vy
    --print("And " .. x .. " and " .. y)
    Register.put(x, bit.band(Register.get(x), Register.get(y)))
end

mathOp[3] = function() --XOR Vx, Vy
    --print("Xor " .. x .. " and " .. y)
    Register.put(x, bit.bxor(Register.get(x), Register.get(y)))
end

mathOp[4] = function() --ADD Vx, Vy
    result = Register.get(x) + Register.get(y)
    --print("Added " .. x .. " and " .. y .. " into " .. result)
    if result > 255 then
        Register.put(15, 1)
    else
        Register.put(15, 0)
    end
    Register.put(x, result)
    --print("Stored " .. Register.get(x))
end

mathOp[5] = function() --SUB Vx, Vy
    result = Register.get(x) - Register.get(y)
    if result >= 0 then
        Register.put(15, 1) --correct?
    else
        Register.put(15, 0)
    end
    Register.put(x, result)
end

mathOp[6] = function() --SHR Vx
    --Register.dump()
    --print("SHR: x:" .. x .. " y:" .. y)

    if shiftQuirk then
        y = x
    end
    if bit.band(Register.get(y), 1) == 1 then
        Register.put(15, 1)
    else
        Register.put(15, 0)
    end
    Register.put(x, Register.get(y) / 2)
    --Register.dump()
end

mathOp[7] = function() --SUBN Vx, Vy
    result = Register.get(y) - Register.get(x)
    if result >= 0 then
        Register.put(15, 1) --correct?
    else
        Register.put(15, 0)
    end
    Register.put(x, result)
end

mathOp[14] = function() --SHL Vx
    --Register.dump()
    --print("SHL: x:" .. x .. " y:" .. y)

    if shiftQuirk then
        y = x
    end
    if bit.band(Register.get(y), 128) == 128 then
        Register.put(15, 1)
    else
        Register.put(15, 0)
    end
    Register.put(x, Register.get(y) * 2)
    --Register.dump()
end

function insideBoundary(object, x, y)
    if x >= object:getVx() and x <= object:getWx() then
        if y >= object:getVy() and y <= object:getWy() then
            return true
        end
    end
    return false
end

function drawWindow()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", (width * (1 / 100)) / (16 / 9), height * 1 / 100, width - 2 * ((width * (1 / 100)) / (16 / 9)), height * 98 / 100)
end

function copyDisplay()
    local disp = Screen.getDisplay()
    local newDisp = {}
    for i = 0, 63 do
        newDisp[i] = {}
        for l = 0, 31 do
            newDisp[i][l] = disp[i][l]
        end
    end

    return newDisp
end

