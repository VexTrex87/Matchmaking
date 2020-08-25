-- // Settings \\ --

local DATA_STORE_SCOPE = "Store16"
local DATA_STORE_KEY = "Servers"
local SERVER_UPDATE_DELAY = 60
local SERVER_LOCK_DELAY = 30
local MAX_CHARS = 5
local PLACE_IDS = {
	["Baseplate"] = 5610052484,
	["The Desert"] = 5610052631,
	["Grasslands"] = 5610052717
}

local LETTERS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
local NUMS = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}

-- // Variables \\ --

local TeleportService = game:GetService("TeleportService")
local DataStore = require(game.ServerScriptService.DataStore)
local Remotes = game.ReplicatedStorage.Remotes

-- // Functions \\ --

function TeleportToServer(...)
    TeleportService:TeleportToPrivateServer(...)     
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

Remotes.JoinRandom.OnServerInvoke = function(p)
    local Servers = DataStore.GetData(DATA_STORE_SCOPE, DATA_STORE_KEY)
    if Servers then
        for Code, Info in pairs(Servers) do
            if #Info.Players < Info.MaxPlayers then
                TeleportToServer(PLACE_IDS[Info.Map], Info.ServerCode, {p})
            end
        end
    else
        return true
    end
end

Remotes.JoinServer.OnServerInvoke = function(p, Code)
    print(1)
    if Code and Code ~= "" then
        print(2)
        local Info = DataStore.GetData(DATA_STORE_SCOPE, DATA_STORE_KEY)
        print(Code)
        if Info and Info[Code] then
            print(3)
            TeleportToServer(PLACE_IDS[Info[Code].Map], Info[Code].ServerCode, {p})
        else
            print(4)
            return true
        end
    else
        print(5)
        return true
    end
end

Remotes.GetServers.OnServerInvoke = function(p)
    return DataStore.GetData(DATA_STORE_SCOPE, DATA_STORE_KEY)
end

Remotes.GetLevel.OnServerInvoke = function(p)
    return p.leaderstats.Level.Value
end

Remotes.GenerateCode.OnServerInvoke = function(p, Info)
    local Code, Found
    repeat
        Code = GenerateCode()
        Found = false        
        local Data = DataStore.GetData(DATA_STORE_SCOPE, DATA_STORE_KEY)
        if Data then
            Found = table.find(Data, Code)
        end
        wait()
    until not Found

    DataStore.UpdateData(DATA_STORE_SCOPE, DATA_STORE_KEY, {
        Privacy = Info.Privacy;
        Map = Info.Map;
        Dificulty = Info.Dificulty;

        Owner = p.Name;
        LevelOfOwner = p.leaderstats.Level.Value;
        
        ServerCode = TeleportService:ReserveServer(PLACE_IDS[Info.Map]);
        TimeCreated = os.time();
        Players = {};
        MaxPlayers = 10,
    }, Code)

    return Code
end

while wait(SERVER_UPDATE_DELAY) do
    local Servers = DataStore.GetData(DATA_STORE_SCOPE, DATA_STORE_KEY)
    local CurrentTime = os.time()
    for Code, Info in pairs(Servers) do
        if CurrentTime - Info.TimeCreated >= SERVER_LOCK_DELAY then
            print("Deleting " .. Code)
            DataStore.RemoveUpdateData(DATA_STORE_SCOPE, DATA_STORE_KEY, Code)
        end
	end
end