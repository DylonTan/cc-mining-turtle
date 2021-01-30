--[[
    WARNING: SPAGHETTI CODE AHEAD PROCEED AT YOUR OWN RISK.
    I AM BY NO MEANS AN EXPERIENCED LUA PROGRAMMER I ONLY USED 1 HOUR TO LEARN IT BEFORE CODING
]]--


--[[
    GLOBAL VARIABLES
]]--

local movement = require("movement.lua")
local action = require("action.lua")

-- Initialize origin point x, y and z pos
originX, originY, originZ = gps.locate()

-- Initialize width, height and length
width = nil
height = nil
breadth = nil

-- Initialize distance to destination
distanceX = nil
distanceY = nil
distanceZ = nil

-- Set constant value for turtle inventory size
INVENTORY_SIZE = 16

-- Set array of valid fuel sources
VALID_FUEL_SOURCES = {
    "minecraft:coal_block",
    "minecraft:coal",
    "minecraft:lava_bucket",
    "railcraft:fuel_coke"
}

-- Set array of acceptable items
ACCEPTABLE_ITEMS = {
    "minecraft:coal",
    "minecraft:iron_ore",
    "minecraft:gold_ore",
    "minecraft:redstone",
    "minecraft:diamond",
    "minecraft:emerald",
    "minecraft:dye",
    "thermalfoundation:ore",
    "appliedenergistics2:material",
    "tconstruct:ore",
    "draconiumevolution:draconium_dust",
    "bigreactors:oreyellorite"
}

-- MAIN FUNCTION
function main() 
    -- Open wireless modem
    rednet.open("left")

    -- Listen to rednet signal
    while true do
        -- Listen to senederID, message and protocol from rednet signal
        local senderID, message, protocol = rednet.receive()

        local args = split(tostring(message), " ")
        local instruction = args[1]
       
        -- End listening loop if exit instruction is received
        if instruction == "exit" then
            break

        end

        if instruction == 'mine' then
            start(args)
        end
    end

    -- Close wireless modem
    rednet.close("left")

end

function start(args)

    if #args == 8 then
        -- Set variables to shell command args
        height = tonumber(arg[2])
        width = tonumber(arg[3])
        breadth = tonumber(arg[4])

        destX = tonumber(arg[5])
        destY = tonumber(arg[6])
        destZ = tonumber(arg[7])
        destFacing = tostring(arg[8])

        -- Set absolute distance between current x pos and destination x pos
        distanceX = math.abs(originX - destX)

        -- Set absolute distance between current y pos and destination y pos
        distanceY = math.abs(originY - destY)

        -- Set absolute distance between current z pos and destination z pos
        distanceZ = math.abs(originZ - destZ)

    else 
        print("Please enter the width and height (e.g. mine 5 5 5 1 1 1 south)")
        return 
    
    end

    if not isFuelSufficient() then
        return
    end

    -- Travel to destination
    movement.travel(destX, destY, destZ, destFacing)

    -- Mine designated area
    action.mine(width, height, breadth)

    -- Return to origin
    movement.travel(originX, originY, originZ, 'N')
end

function split (str, seperator)
    if seperator == nil then
        seperator = "%s"
    end

    local arr = {}

    for str in string.gmatch(str, "[^%s]+") do
            table.insert(arr, str)
    end
    
    return arr
end

main()