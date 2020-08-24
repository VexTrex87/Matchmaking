-- // Settings \\ --

local MAX_CHARS = 5
local LETTERS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
local NUMS = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
local DATA_STORE_SCOPE = "Store3"
local DATA_STORE_KEY = "Servers"
local PLACE_IDS = {
	["Baseplate"] = 5610052484,
	["The Desert"] = 5610052631,
	["Grasslands"] = 5610052717
}

-- // Variables \\ --

local TeleportService = game:GetService("TeleportService")
local DataStore = require(game.ServerScriptService.DataStore)
local Remotes = game.ReplicatedStorage.Remotes

-- // Functions \\ --

function TeleportToServer(PlaceID, Code, Players)
    TeleportService:TeleportToPrivateServer(PlaceID, Code, Players)     
end

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

-- // Events \\ --

Remotes.JoinRandom.OnServerEvent:Connect(function(p)
    local Servers = DataStore.GetData(DATA_STORE_SCOPE, DATA_STORE_KEY)
    if Servers then
        for Code, Info in pairs(Servers) do
            if #Info.Players < Info.MaxPlayers then
                TeleportToServer(PLACE_IDS[Info.Map], Info.ServerCode, {p})
            end
        end
    else
        print("No Servers Found")
    end
end)

Remotes.JoinServer.OnServerInvoke = function(p, Code)
    if Code and Code ~= "" then
        local Info = DataStore.GetData(DATA_STORE_SCOPE, DATA_STORE_KEY)
        if Info then
            TeleportToServer(PLACE_IDS[Info[Code].Map], Info[Code].ServerCode, {p})
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
    local Found
    repeat
        Found = false
        Code = GenerateCode()
        
        local Data = DataStore.GetData(DATA_STORE_SCOPE, DATA_STORE_KEY)
        if Data then
            print("There are " .. #Data .. " server codes.")
            Found = table.find(Data, Code)
        end

        wait()
    until not Found

    DataStore.UpdateData(DATA_STORE_SCOPE, DATA_STORE_KEY, {
        Privacy = Info.Privacy;
        Map = Info.Map;
        Dificulty = Info.Dificulty;
        Owner = p.UserId;
        ServerCode = TeleportService:ReserveServer(PLACE_IDS[Info.Map]);
        Players = {};
        MaxPlayers = 10,
    }, Code)

    return Code
end