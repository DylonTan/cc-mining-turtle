--[[
    WARNING: SPAGHETTI CODE AHEAD PROCEED AT YOUR OWN RISK.
    I AM BY NO MEANS AN EXPERIENCED LUA PROGRAMMER I ONLY USED 1 HOUR TO LEARN IT BEFORE CODING
]]--


--[[
    GLOBAL VARIABLES
]]--

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
        local senderID, instruction, protocol = rednet.receive()
        print(instruction, protocol)

        -- Run instruction
        shell.run(instruction)

        -- End listening loop if exit instruction is received
        if instruction == "exit" then
            break

        end

    end

    -- Close wireless modem
    rednet.close("left")

end

main()