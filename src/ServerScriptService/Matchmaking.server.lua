local MAX_CHARS = 5
local LETTERS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
local NUMS = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
local PLACE_IDS = {
	["Baseplate"] = 5610052484,
	["The Desert"] = 5610052631,
	["Grasslands"] = 5610052717
}

local TeleportService = game:GetService("TeleportService")
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
        local Data = DataStore.LoadData("Servers", Code)
        if Data then
            TeleportService:TeleportToPrivateServer(PLACE_IDS[Data.Map], Data.ServerCode, {p})
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
    until not DataStore.LoadData("Servers", Code)

    DataStore.SaveData("Servers", Code, {
        Privacy = Info.Privacy;
        Map = Info.Map;
        Dificulty = Info.Dificulty;
        Owner = p.UserId;
        Code = Code;
        ServerCode = TeleportService:ReserveServer(PLACE_IDS[Info.Map])
    })

    return Code
end