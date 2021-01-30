--[[
    WARNING: SPAGHETTI CODE AHEAD PROCEED AT YOUR OWN RISK.
    I AM BY NO MEANS AN EXPERIENCED LUA PROGRAMMER I ONLY USED 1 HOUR TO LEARN IT BEFORE CODING
]]--


--[[
    GLOBAL VARIABLES
]]--

os.loadAPI('movement')
os.loadAPI('action')

-- Initialize origin point x, y and z pos
local originX, originY, originZ = gps.locate()

-- Initialize width, height and length
local width = nil
local height = nil
local breadth = nil

-- Initialize distance to destination
local distanceX = nil
local distanceY = nil
local distanceZ = nil

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
        height = tonumber(args[2])
        width = tonumber(args[3])
        breadth = tonumber(args[4])

        destX = tonumber(args[5])
        destY = tonumber(args[6])
        destZ = tonumber(args[7])
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

    if not action.isFuelSufficient(width, height, breadth, distanceX, distanceY, distanceZ) then
        return
    end

    -- Travel to destination
    movement.travel(originX, originZ, destX, destY, destZ, destFacing)

    -- Mine designated area
    action.mine(width, height, breadth)

    -- Return to origin
    movement.travel(originX, originY, originZ, destX, destZ, 'N')
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