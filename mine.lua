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

local ACCEPTED_ITEMS = {
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

-- MINE FUNCTION
local direction = "right"

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

function travel(destX, destY, destZ)
    local currentX, currentY, currentZ = gps.locate()
    

    moveForwardAndDig()

    local newX, newY, newZ = gps.locate()

    -- Determine which direction the turtle is facing
    local facing = getFacingDirection(currentX, currentZ, newX, newZ)

    local distanceX = math.abs(newCurrentX - destX)
    local distanceZ = math.abs(newCurrentZ - destZ)
    local route = getRoute(newX, newZ, destX, destZ)
    
    while not newX == destX and not newZ == destZ do
        if facing == "north" then
            if route[1] == "south" then
                turtle.turnRight()
                turtle.turnRight()

            end

            for newZ, distanceZ do
                moveForwardAndDig()
                newZ++
            end
        end
        

        if facing == "west" then
            if route[0] == "east" then
                turtle.turnRight()
                turtle.turnRight()

            end
            
            for newX, distanceX do
                moveForwardAndDig()
                newX++
            end
        end
    end

    for y = currentY, destY do
        moveDownAndDig()
    end
end

function mine()
    for y = 1, height do
        for z = 1, breadth do
            for x = 1, width - 1 do
                moveForwardAndDig()
            end

            if z ~= breadth then
                corner(z, breadth)
            end

            filterInventory()

        end

        groupInventory()

        moveDownAndDig()
        turtle.turnRight()
        turtle.turnRight()

    end
end

-- HELPER FUNCTIONS
function getFacingDirection(previousX, previousZ, currentX, currentZ)
    local facing = ""
    
    if currentZ < previousZ then
        facing = "north"

    elseif currentX < previousX then
        facing = "west"

    elseif currentX > previousX then 
        facing = "east"

    else 
        facing = "south"

    end

    return facing

end

function getRoute(currentX, currentZ, destX, destZ)
    local directionX = ""
    local directionZ = ""

    if currentX < destX then
        directionX = "east"

    else 
        directionX = "west"

    end

    if currentZ < destZ then
        directionZ = "south"

    else
        directionZ = "north"

    end

    return { directionX, directionY }
end

function refuel(slotNumber)
    print("[SLAVE]: Refueling... \n")
    turtle.select(slotNumber)
    turtle.refuel()
    print("[SLAVE]: Refueled, returning to forced labour.")
end

function checkFuelLevel()
    local requiredFuelLevel = math.ceil(height * width * breadth)
    local currentFuelLevel = turtle.getFuelLevel()

    print("[SLAVE]: Current fuel level is "..currentFuelLevel.."\nRequired fuel level is "..requiredFuelLevel)

    if currentFuelLevel > requiredFuelLevel then
        return true
    end

    if currentFuelLevel < requiredFuelLevel then
        print("[SLAVE]: Attempting refuel...")

        for i = 1, INVENTORY_SIZE do
            local currentItem = turtle.getItemDetail(i)

            if currentItem ~= nil then
                for j = 1, #VALID_FUEL_SOURCES do
                    if currentItem.name == VALID_FUEL_SOURCES[j] then
                        print("[SLAVE]: Valid fuel source found.")

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

    while turtle.up() == false do
        turtle.digUp()
    end

    print("[SLAVE]: Moved up and dug.")
end
 
function moveForwardAndDig()
    print("[SLAVE]: Moving forward and digging...")

    while turtle.forward() == false do
        turtle.dig()
    end

    print("[SLAVE]: Moved forward and dug.")
end
 
function moveDownAndDig()
    print("[SLAVE]: Moving down and digging...")

    while turtle.down() == false do
        turtle.digDown()
    end

    print("[SLAVE]: Moved down and dug.")
end

function corner(z, breadth)
    print("[SLAVE]: Making a corner...")

    if direction == "right" then
        uTurn(direction)
        direction = "left"
    else
        uTurn(direction)
        direction = "right"    
    end

    print("[SLAVE]: Corner completed.")
end

function uTurn(direction)
    print("[SLAVE]: Making a U-Turn...")

    if direction == "right" then
        turtle.turnRight()
        moveForwardAndDig()
        turtle.turnRight()
    else
        turtle.turnLeft()
        moveForwardAndDig()
        turtle.turnLeft()
    end

    print("[SLAVE]: U-Turn completed.")
end

function filterInventory()
    print("[SLAVE]: Filtering inventory...")

    for i = 1, INVENTORY_SIZE do
        local currentItem = turtle.getItemDetail(i)

        if currentItem ~= nil then

            local isShit = true

            for n = 1, table.getn(ACCEPTED_ITEMS) do
                if currentItem.name == ACCEPTED_ITEMS[n] then
                    print("[SLAVE] Found good stuff: "..currentItem.name..". Keeping..")
                    isShit = false
                    break
                end
            end

            if isShit then
                print("[SLAVE] Found shit: "..currentItem.name..". Dumping..")
                turtle.select(i)
                turtle.dropUp()

            end
        end
    end

    print("[SLAVE]: Filtered inventory.")

    return
end

-- FIX THIS!!!
function groupInventory()
    print("[SLAVE] Grouping inventory...")

    for i = 1, INVENTORY_SIZE do
        local currentItem = turtle.getItemDetail(i)

        if currentItem ~= nil then
            turtle.select(i)

            for j = i, INVENTORY_SIZE do
                if turtle.compareTo(j) then
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