-- MAIN FUNCTION
function main() 
    rednet.open("left")

    while true do
        local senderID, message, protocol = rednet.receive()
        print(message, protocol)

        if protocol == "instruction" then
            shell.run(message)
        elseif protocol == "location" then
            shell

        end

        if message == "exit" then
            break

        end
        
        

    end

    rednet.close("left")

end

main()