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