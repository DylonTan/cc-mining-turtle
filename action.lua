--[[
    MINE FUNCTION
]]--

os.loadAPI("movement")

local INVENTORY_SIZE = 16

-- Set array of valid fuel sources
local VALID_FUEL_SOURCES = {
    "minecraft:coal_block",
    "minecraft:coal",
    "minecraft:lava_bucket",
    "railcraft:fuel_coke"
}

-- Set array of acceptable items
local ACCEPTABLE_ITEMS = {
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

function mine(width, height, breadth)

    -- Traverse and dig height required
    for y = 1, height do

        -- Traverse and dig breadth required
        for z = 1, breadth do

            -- Traverse and dig width required
            for x = 1, width - 1 do
                movement.moveForwardAndDig()
            end

            -- Corner if turtle has not reached designated breadth
            if z ~= breadth then
                movement.corner(z, breadth)
            end

            -- Filter unwanted items in inventory
            filterInventory()

            -- Group unwanted items in inventory
            groupInventory()
        end

        -- Dig down to next y level
        movement.moveDownAndDig()

        -- Make a U-Turn
        turtle.turnRight()
        turtle.turnRight()

    end
end

--[[
    HELPER FUNCTIONS
]]--

function refuel(slotNumber)
    print("[TURTLE]: Refueling... \n")
    -- Select item at slot number
    turtle.select(slotNumber)

    -- Use selected item to refuel turtle
    turtle.refuel()
    print("[TURTLE]: Refueled, returning to forced labour.")
end

function isFuelSufficient(width, height, breadth, distanceX, distanceY, distanceZ)
    -- Calculate required fuel level ( 1 fuel level/block )
    local requiredFuelLevel = math.ceil(width * height * breadth) + 2 * (distanceX + distanceY + distanceZ)

    -- Get current fuel level
    local currentFuelLevel = turtle.getFuelLevel()

    print("[TURTLE]: Current fuel level is "..currentFuelLevel.."\nRequired fuel level is "..requiredFuelLevel)

    -- Check if current fuel level is greater than required fuel level
    if currentFuelLevel > requiredFuelLevel then
        -- Return if current fuel level is sufficient
        return true

    else
        print("[TURTLE]: Attempting refuel...")

        -- Check every item in inventory 
        for i = 1, INVENTORY_SIZE do
            -- Get current item object
            local currentItem = turtle.getItemDetail(i)

            -- Check if current item is something
            if currentItem ~= nil then

                -- Check every valid fuel source
                for j = 1, #VALID_FUEL_SOURCES do

                    -- Check if current item is valid fuel source
                    if currentItem.name == VALID_FUEL_SOURCES[j] then
                        print("[TURTLE]: Valid fuel source found.")

                        -- Refuel turtle with current item
                        refuel(i)
                        return true

                    end
                end
            end
        end

        return false

    end 

    print("[TURTLE]: No valid fuel source found.")

    return true
end

function filterInventory()
    print("[TURTLE]: Filtering inventory...")

    -- Check every item in inventory
    for i = 1, INVENTORY_SIZE do
        -- Get current item object
        local currentItem = turtle.getItemDetail(i)

        -- Check if current item is something
        if currentItem ~= nil then
            local isGarbage = true

            -- Check every acceptable item
            for n = 1, table.getn(ACCEPTABLE_ITEMS) do

                -- Check if current item is an acceptable item
                if currentItem.name == ACCEPTABLE_ITEMS[n] then
                    print("[TURTLE] Found good stuff: "..currentItem.name..". Keeping..")
                    isGarbage = false
                    break
                end
            end

            -- Throw current item away if it is not acceptable
            if isGarbage then
                print("[TURTLE] Found shit: "..currentItem.name..". Dumping..")
                turtle.select(i)
                turtle.dropUp()

            end
        end
    end

    print("[TURTLE]: Filtered inventory.")

    return
end

function groupInventory()
    print("[TURTLE] Grouping inventory...")

    -- Check every item in inventory
    for i = 1, INVENTORY_SIZE do

        -- Get current item object
        local currentItem = turtle.getItemDetail(i)

        -- Check if item is something
        if currentItem ~= nil then

            -- Select item at slot i
            turtle.select(i)

            -- Check every item after selected item
            for j = i + 1, INVENTORY_SIZE do

                -- Check if current item is stackable with selected item
                if turtle.compareTo(j) then

                    -- Stack current item to selected item
                    turtle.select(j)
                    turtle.transferTo(i)
                    turtle.select(i)

                end
            end
        end
    end

    print("[TURTLE] Grouped inventory, returning to forced labour.")

    return
end

return { mine = mine, isFuelSufficient = isFuelSufficient }