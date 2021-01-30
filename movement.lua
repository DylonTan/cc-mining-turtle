local M = {}

--[[
    TRAVEL FUNCTION
]]--
 
function M.travel(destX, destY, destZ, destDirection)

    moveForwardAndDig()

    -- Get new reference point's x, y and z pos
    local currentX, currentY, currentZ = gps.locate()

    -- Determine which direction the turtle is facing by sending previous pos and new pos
    local facing = getFacingDirection(originX, originZ, currentX, currentZ)

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

    facing = pathDirections.z

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

    -- Turn to direction master was facing
    turnToDirection(facing, destDirection)
 
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

function M.moveUpAndDig()
    print("[TURTLE]: Moving up and digging...")

    -- Dig once, keep digging if blocked
    while turtle.up() == false do
        turtle.digUp()
    end

    print("[TURTLE]: Moved up and dug.")
end
 
function M.moveForwardAndDig()
    print("[TURTLE]: Moving forward and digging...")

    -- Dig once, keep digging if blocked
    while turtle.forward() == false do
        turtle.dig()
    end

    print("[TURTLE]: Moved forward and dug.")
end
 
function M.moveDownAndDig()
    print("[TURTLE]: Moving down and digging...")

    -- Dig once, keep digging if blocked 
    while turtle.down() == false do
        turtle.digDown()
    end

    print("[TURTLE]: Moved down and dug.")
end

function M.corner(z, breadth)
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

function M.uTurn(direction)
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

return M