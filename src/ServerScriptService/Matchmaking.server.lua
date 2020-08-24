local MAX_CHARS = 5
local LETTERS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
local NUMS = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
local DataStore = require(game.ServerScriptService.DataStore)
local Remotes = game.ReplicatedStorage.Remotes

function GenerateCode()
    local Code = ""
    for x = 1, MAX_CHARS do
        local ChosenChar
        if math.random(2) == 1 then
            if math.random(2) == 1 then
                ChosenChar = string.lower(LETTERS[math.random(#LETTERS)])
            else
                ChosenChar = LETTERS[math.random(#LETTERS)]
            end
        else
            ChosenChar = NUMS[math.random(#NUMS)]
        end

        Code = Code .. ChosenChar
    end
    return Code
end

Remotes.JoinServer.OnServerInvoke = function(p, Code)
    if Code and Code ~= "" then
        local Data = DataStore.LoadData("Codes", Code)
        if Data then
            print(Code .. " exists!")
            print(Data)
        else
            warn(Code .. " does NOT exist")
        end
    end
end

Remotes.CheckLevel.OnServerInvoke = function(p, MapLvl)
    if p.leaderstats.Level.Value >= MapLvl then
        return true
    end
end

Remotes.GenerateCode.OnServerInvoke = function(p, Info)

    local Code
    repeat
        Code = GenerateCode()
        wait()
    until not DataStore.LoadData("Codes", Code)

    local Data = {
        Privacy = Info.Privacy;
        Map = Info.Map;
        Dificulty = Info.Dificulty;
        Code = Code;
        Owner = p.UserId
    }

    DataStore.SaveData("Codes", Code, Data)
    return Code
end