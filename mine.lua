--[[
    WARNING: SPAGHETTI CODE AHEAD PROCEED AT YOUR OWN RISK.
    I AM BY NO MEANS AN EXPERIENCED LUA PROGRAMMER I ONLY USED 1 HOUR TO LEARN IT BEFORE CODING
]]--

-- Initialize origin point object
local origin = {
    x = nil,
    y = nil,
    z = nil
}

-- Set constant value for turtle inventory size
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

--[[
    START FUNCTION
]]--

function start()
    local width = nil
    local height = nil
    local breadth = nil

    if #arg == 6 then
        -- Set variables to shell command args
        height = tonumber(arg[1])
        width = tonumber(arg[2])
        breadth = tonumber(arg[3])

        destX = tonumber(arg[4])
        destY = tonumber(arg[5])
        destZ = tonumber(arg[6])

        -- Travel to destination
        travel(destX, destY, destZ)

    else 
        print("Please enter the width and height (e.g. mine 5 5 5 1 1 1)")
        return 
    
    end

    if not isFuelSufficient() then
        return
    end

    mine(width, height, breadth)
end

--[[
    TRAVEL FUNCTION
]]--
 
function travel(destX, destY, destZ)
    -- Get and set origin point's x, y and z pos
    local originX, originY, originZ = gps.locate()
    origin.x = originX
    origin.y = originY
    origin.z = originZ

    moveForwardAndDig()

    -- Get new reference point's x, y and z pos
    local currentX, currentY, currentZ = gps.locate()

    -- Determine which direction the turtle is facing by sending previous pos and new pos
    local facing = getFacingDirection(originX, originZ, currentX, currentZ)

    -- Absolute distance between current x pos and destination x pos
    local distanceX = math.abs(currentX - destX)

    -- Absolute distance between current y pos and destination y pos
    local distanceZ = math.abs(currentY - destY)

    -- Absolute distance between current z pos and destination z pos
    local distanceZ = math.abs(currentZ - destZ)

    -- Get correct path directions (2 directions)
    local pathDirections = getPathDirections(currentX, currentZ, destX, destZ)
    
    -- Turn to correct path direction on the x axis 
    turnToDirection(facing, pathDirections.x)

    facing = pathDirections.x

    -- Traverse distance required on the x axis
    for x = 1, distanceX do
        moveForwardAndDig()
    end

    -- Turn to correct path direction on the z axis 
    turnToDirection(facing, pathDirections.z)

    facing = pathDirections.currentZ

    -- Traverse distance required on the z axis
    for z = 1, distanceZ do
        moveForwardAndDig()
    end

    -- Traverse distance required on the y axis

    -- Check if destination is below turtle
    if currentY > destY then
        for y = 1, distanceY do
            moveDownAndDig()
        end
    else
        for y = 1, distanceY do
            moveUpAndDig()
        end
    end
 
end

--[[
    MINE FUNCTION
]]--

local nextUTurnDirection = "right"

function mine(width, height, breadth)

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
    
    -- Turtle is facing N if current z pos is less than previous z pos
    if currentZ < previousZ then
        facingDirection = "N"

    -- Turtle is facing W if current x pos is less than previous x pos
    elseif currentX < previousX then
        facingDirection = "W"

    -- Turtle is facing E if current x pos is greater than previous x pos
    elseif currentX > previousX then 
        facingDirection = "E"

    -- Turtle is facing S if current z pos is greater than current z pos
    else 
        facingDirection = "S"

    end

    -- Return facing direction
    return facingDirection

end

function turnToDirection(facing, direction)
    -- Permutations for a left turn
    local permLeft = {
        'NW', 'WS', 'SE', 'EN'
    }

    -- Permutations for a right turn
    local permRight = {
        "NE", "ES", "SW", "WN"
    }
    
    -- Get current permutation
    local currentPerm = facing..direction

    -- Check every permutation for a left turn
    for l = 1, #permLeft do

        -- Check if current permutation is included
        if currentPerm == permLeft[l] then
            turtle.turnLeft()
            return
        end
    end

    -- Check every permutation for a right turn
    for r = 1, #permRight do

        -- Check if current permutation is included
        if currentPerm == permRight[r] then
            turtle.turnRight()
            return
        end
    end

    -- Make a U-Turn
    turtle.turnRight()
    turtle.turnRight()

end

function getPathDirections(currentX, currentZ, destX, destZ)
    local directionX = ""
    local directionZ = ""

    -- Turtle should go east if current x pos is less than destination x pos
    if currentX < destX then
        directionX = "E"

    -- Turtle should go west if current x pos is greater than destination x pos
    else 
        directionX = "W"

    end

    -- Turtle should go south if current z pos is less than destination z pos
    if currentZ < destZ then
        directionZ = "S"

    -- Turtle should go north if current z pos is greater than destination z pos
    else
        directionZ = "N"

    end

    -- Return path direction object
    return { x = directionX, z = directionZ }
end

function refuel(slotNumber)
    print("[TURTLE]: Refueling... \n")
    -- Select item at slot number
    turtle.select(slotNumber)

    -- Use selected item to refuel turtle
    turtle.refuel()
    print("[TURTLE]: Refueled, returning to forced labour.")
end

function isFuelSuxfficient()
    -- Calculate required fuel level ( 1 fuel level/block )
    local requiredFuelLevel = math.ceil(height * width * breadth)

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

function moveUpAndDig()
    print("[TURTLE]: Moving up and digging...")

    -- Dig once, keep digging if blocked
    while turtle.up() == false do
        turtle.digUp()
    end

    print("[TURTLE]: Moved up and dug.")
end
 
function moveForwardAndDig()
    print("[TURTLE]: Moving forward and digging...")

    -- Dig once, keep digging if blocked
    while turtle.forward() == false do
        turtle.dig()
    end

    print("[TURTLE]: Moved forward and dug.")
end
 
function moveDownAndDig()
    print("[TURTLE]: Moving down and digging...")

    -- Dig once, keep digging if blocked 
    while turtle.down() == false do
        turtle.digDown()
    end

    print("[TURTLE]: Moved down and dug.")
end

function corner(z, breadth)
    print("[TURTLE]: Making a corner...")

    -- Make U-Turn, change next U-Turn direction to left if current is right
    if nextUTurnDirection == "right" then
        uTurn(nextUTurnDirection)
        nextUTurnDirection = "left"

    -- Make U-Turn, change next U-Turn direction to left if current is right
    else
        uTurn(nextUTurnDirection)
        nextUTurnDirection = "right"    
    end

    print("[TURTLE]: Corner completed.")
end

function uTurn(direction)
    print("[TURTLE]: Making a U-Turn...")

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

    print("[TURTLE]: U-Turn completed.")
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

start()