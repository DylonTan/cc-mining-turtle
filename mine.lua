local height = 5
local width = 5
local breadth = 5

local INVENTORY_SIZE = 16

local VALID_FUEL_SOURCES = {
    "minecraft:coal_block",
    "minecraft:coal",
    "minecraft:lava_bucket",
    "railcraft:fuel_coke"
}

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

--[[
    START FUNCTION
]]--
local nextUTurnDirection = "right"

function start()
    if #arg == 6 then
        height = tonumber(arg[1])
        width = tonumber(arg[2])
        breadth = tonumber(arg[3])

        destX = tonumber(arg[4])
        destY = tonumber(arg[5])
        destZ = tonumber(arg[6])

        travel(destX, destY, destZ)

    else 
        print("Please enter the width and height (e.g. mine 5 5 5 1 1 1)")
        return 
    
    end

    if not checkFuelLevel() then
        return
    end
end

--[[
    TRAVEL FUNCTION
]]--
function travel(destX, destY, destZ)
    -- Get current x, y and z pos
    local currentX, currentY, currentZ = gps.locate()
    
    moveForwardAndDig()

    -- Get new x, y and z pos
    local newX, newY, newZ = gps.locate()

    -- Determine which nextUTurnDirection the turtle is facing by sending previous pos and new pos
    local facing = getFacingDirection(currentX, currentZ, newX, newZ)

    -- Absolute distance between current x pos and destination x pos
    local distanceX = math.abs(newX - destX)

    -- Absolute distance between current z pos and destination z pos
    local distanceZ = math.abs(newZ - destZ)

    -- Get correct route (2 directions)
    local route = getRoute(newX, newZ, destX, destZ)
    
    -- Check if destination has been reached
    while not newX == destX and not newZ == destZ do

        -- Check if turtle is facing north
        if facing == "north" then

            -- Check if turtle is facing south
            if route[1] == "south" then

                -- Make a U-Turn
                turtle.turnRight()
                turtle.turnRight()

            end

            -- Traverse distance required on the z axis
            for newZ, distanceZ do
                moveForwardAndDig()

                -- Update current z pos
                newZ++

            end
        end
        
        -- Check if turtle is facing west
        if facing == "west" then

            -- Check if turtle is facing east
            if route[0] == "east" then

                -- Make a U-Turn
                turtle.turnRight()
                turtle.turnRight()

            end
            
            -- Traverse distance required on the x axis
            for newX, distanceX do
                moveForwardAndDig()

                -- Update current z pos
                newX++

            end
        end
    end

    -- Traverse and dig distance required on the y axis 
    for y = currentY, destY do
        moveDownAndDig()
    end
end

--[[
    MINE FUNCTION
]]--
function mine()

    -- Traverse and dig height required
    for y = 1, height do

        -- Traverse and dig breadth required
        for z = 1, breadth do

            -- Traverse and dig width required
            for x = 1, width - 1 do
                moveForwardAndDig()
            end

            -- Corner if turtle has not reached designated breadth
            if z ~= breadth then
                corner(z, breadth)
            end

            -- Filter unwanted items in inventory
            filterInventory()

            -- Group unwanted items in inventory
            groupInventory()
        end

        -- Dig down to next y level
        moveDownAndDig()

        -- Make a U-Turn
        turtle.turnRight()
        turtle.turnRight()

    end
end

--[[
    HELPER FUNCTIONS
]]--
function getFacingDirection(previousX, previousZ, currentX, currentZ)
    local facingDirection = ""
    
    -- Turtle is facing north if current z pos is less than previous z pos
    if currentZ < previousZ then
        facingDirection = "north"

    -- Turtle is facing west if current x pos is less than previous x pos
    elseif currentX < previousX then
        facingDirection = "west"

    -- Turtle is facing east if current x pos is greater than previous x pos
    elseif currentX > previousX then 
        facingDirection = "east"

    -- Turtle is facing south if current z pos is greater than current z pos
    else 
        facingDirection = "south"

    end

    return facingDirection

end

function getRoute(currentX, currentZ, destX, destZ)
    local directionX = ""
    local directionZ = ""

    -- Turtle should go east if current x pos is less than destination x pos
    if currentX < destX then
        directionX = "east"

    -- Turtle should go west if current x pos is greater than destination x pos
    else 
        directionX = "west"

    end

    -- Turtle should go south if current z pos is less than destination z pos
    if currentZ < destZ then
        directionZ = "south"

    -- Turtle should go north if current z pos is greater than destination z pos
    else
        directionZ = "north"

    end

    return { directionX, directionY }
end

function refuel(slotNumber)
    print("[SLAVE]: Refueling... \n")
    -- Select item at slot number
    turtle.select(slotNumber)

    -- Use selected item to refuel turtle
    turtle.refuel()
    print("[SLAVE]: Refueled, returning to forced labour.")
end

function checkFuelLevel()
    -- Calculate required fuel level ( 1 fuel level/block )
    local requiredFuelLevel = math.ceil(height * width * breadth)

    -- Get current fuel level
    local currentFuelLevel = turtle.getFuelLevel()

    print("[SLAVE]: Current fuel level is "..currentFuelLevel.."\nRequired fuel level is "..requiredFuelLevel)

    -- Check if current fuel level is greater than required fuel level
    if currentFuelLevel > requiredFuelLevel then
        -- Return if current fuel level is sufficient
        return true

    else
        print("[SLAVE]: Attempting refuel...")

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
                        print("[SLAVE]: Valid fuel source found.")

                        -- Refuel turtle with current item
                        refuel(i)
                        return true

                    end
                end
            end
        end

        return false

    end 

    print("[SLAVE]: No valid fuel source found.")

    return true
end

function moveUpAndDig()
    print("[SLAVE]: Moving up and digging...")

    -- Dig once, keep digging if turtle can not go up
    while turtle.up() == false do
        turtle.digUp()
    end

    print("[SLAVE]: Moved up and dug.")
end
 
function moveForwardAndDig()
    print("[SLAVE]: Moving forward and digging...")

    -- Dig once, keep digging if turtle can not go forward
    while turtle.forward() == false do
        turtle.dig()
    end

    print("[SLAVE]: Moved forward and dug.")
end
 
function moveDownAndDig()
    print("[SLAVE]: Moving down and digging...")

    -- Dig once, keep digging if turtle can not go down
    while turtle.down() == false do
        turtle.digDown()
    end

    print("[SLAVE]: Moved down and dug.")
end

function corner(z, breadth)
    print("[SLAVE]: Making a corner...")

    -- Make U-Turn, change next U-Turn direction to left if current is right
    if nextUTurnDirection == "right" then
        uTurn(nextUTurnDirection)
        nextUTurnDirection = "left"

    -- Make U-Turn, change next U-Turn direction to left if current is right
    else
        uTurn(nextUTurnDirection)
        nextUTurnDirection = "right"    
    end

    print("[SLAVE]: Corner completed.")
end

function uTurn(direction)
    print("[SLAVE]: Making a U-Turn...")

    -- Make U-Turn to the right
    if direction == "right" then
        turtle.turnRight()
        moveForwardAndDig()
        turtle.turnRight()
    
    -- Make U-Turn to the left
    else
        turtle.turnLeft()
        moveForwardAndDig()
        turtle.turnLeft()
    end

    print("[SLAVE]: U-Turn completed.")
end

function filterInventory()
    print("[SLAVE]: Filtering inventory...")

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
                    print("[SLAVE] Found good stuff: "..currentItem.name..". Keeping..")
                    isGarbage = false
                    break
                end
            end

            -- Throw current item away if it is not acceptable
            if isGarbage then
                print("[SLAVE] Found shit: "..currentItem.name..". Dumping..")
                turtle.select(i)
                turtle.dropUp()

            end
        end
    end

    print("[SLAVE]: Filtered inventory.")

    return
end

function groupInventory()
    print("[SLAVE] Grouping inventory...")

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

    print("[SLAVE] Grouped inventory, returning to forced labour.")

    return
end

start()