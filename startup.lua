-- Copy main script to turtle if non found
if not fs.exist("./main") then
    fs.copy("disk2/main", "main")
end

-- Copy mine script to turtle if non found
if not fs.exist("./mine") then
    fs.copy("disk/mine", "mine")
end

shell.run("main")