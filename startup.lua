if not fs.exist("./main") then
    fs.copy("disk2/main", "main")
end

if not fs.exist("./mine") then
    fs.copy("disk/mine", "mine")
end

shell.run("main")