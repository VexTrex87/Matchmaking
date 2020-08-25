wait(1)

-- // Settings \\ --

local SHOW_1 = Color3.fromRGB(255, 255, 255)
local FADE_1 = Color3.fromRGB(150, 150, 150)
local FADE_2 = Color3.fromRGB(0, 0, 0)
local SERVER_LIST_UPDATE_DELAY = 5

local TWEEN_DURATION = 0.5
local HOVER_DURATION = 0.1
local HOVER_MULTIPLIER = 1.05

-- // Variables \\ --

local TeleportService = game:GetService("TeleportService")
local Core = require(game.ReplicatedStorage.Modules.Core)
local UiModule = require(game.ReplicatedStorage.Modules.UI)

local p = game.Players.LocalPlayer
local Remotes = game.ReplicatedStorage.Remotes
local UIs = game.ReplicatedStorage.UI

local UI = p.PlayerGui:WaitForChild("Matchmaking")
local Frame = UI.Frame
local Left = Frame.Left
local Create = Frame.Create
local Join = Frame.Join
local HoveredItems = {}

-- // Functions \\ --

function Color(Table, Color, IsBackgroundColor)
    for _,v in pairs(Table) do
        if IsBackgroundColor then
            v.BackgroundColor3 = Color
        else
            v.TextColor3 = Color
        end
    end       
end

function VisibleAll(Table, IsVisible)
    for _,v in pairs(Table) do
        v.Visible = IsVisible
    end
end

function Update()
    Create.SelectedMap.Value, Create.SelectedDificulty.Value, Create.SelectedPrivacy.Value = "", "", "Public"
    VisibleAll({Join, Left, Frame.Title}, true)
    VisibleAll({Create})
    Color({Left.JoinPublic.Text}, SHOW_1)   
    Color(Core.Get(Create.Maps, "ImageButton"), FADE_2, true)
    
    Color({
        Create.Maps.Baseplate.Title;
        Create.Maps.Grasslands.Title;
        Create.Maps["The Desert"].Title;
    }, FADE_1)

    Color({     
        Left.CreatePrivate.Text;
        Left.CreatePublic.Text;
        Left.JoinRandom.Text;
        Create.Dificulty.Easy.Text;
        Create.Dificulty.Medium.Text;
        Create.Dificulty.Hard.Text;
        Create.Dificulty.Endless.Text;
    }, FADE_1)      

    local Level = Remotes.GetLevel:InvokeServer()
    for _,Map in pairs(Core.Get(Create.Maps, "ImageButton")) do
        if Level < Map.RequiredLevel.Value and not Map:FindFirstChild("Locked") then
            local Locked = Create.Maps.ListLayout.Locked:Clone()
            Locked.Requirements.Text = "You must be level " .. Map.RequiredLevel.Value .. " to play " .. Map.Name
            Locked.Parent = Map
        elseif Level >= Map.RequiredLevel.Value and Map:FindFirstChild("Locked") then
            Map.Locked:Destroy()
        end
    end
end

function ButtonClicked(Button)
    UI.Click:Play()

    if Button == UI.Servers then
        if Frame.Shown.Value then
            Frame.Shown.Value = false
            Frame:TweenPosition(UDim2.new(0.5, 0, 1.5, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, TWEEN_DURATION, true)
        else
            Frame.Shown.Value = true
            Update()
            Frame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, TWEEN_DURATION, true)
        end
    elseif Button.Parent == Left then
        if Button.Name == "CreatePublic" then
            Create.Visible, Join.Visible = true, false
            Color({Left.CreatePublic.Text}, SHOW_1)
            Color({Left.JoinPublic.Text, Left.CreatePrivate.Text}, FADE_1)
            Create.SelectedPrivacy.Value = "Public"
        elseif Button.Name == "CreatePrivate" then
            Create.Visible, Join.Visible = true, false
            Color({Left.CreatePrivate.Text}, SHOW_1)
            Color({Left.JoinPublic.Text, Left.CreatePublic.Text}, FADE_1)
            Create.SelectedPrivacy.Value = "Private" 
        elseif Button.Name == "JoinPublic" then
            Join.Visible, Create.Visible = true, false
            Color({Left.JoinPublic.Text}, SHOW_1)
            Color({Left.CreatePrivate.Text, Left.CreatePublic.Text}, FADE_1)     
        elseif Button.Name == "JoinRandom" then
            UiModule.LoadingScreen.FadeIn(p, "Joining Random Game...")
            TeleportService:SetTeleportGui(UIs.JoiningRandom)
            if Remotes.JoinRandom:InvokeServer() then
                print("Failed")
                wait(1)
                UiModule.LoadingScreen.UpdateProperties(p, {["Text"] = "No Servers Found"})
                wait(1)
                UiModule.LoadingScreen.FadeOut(p)
            end
        elseif Button.Name == "JoinServer" and Left.ServerID.Text ~= "" then
            UiModule.LoadingScreen.FadeIn(p, "Joining Game...")
            TeleportService:SetTeleportGui(UIs.JoiningGame)
            if Remotes.JoinServer:InvokeServer(Left.ServerID.Text) then
                wait(1)
                UiModule.LoadingScreen.UpdateProperties(p, {["Text"] = "Server Not Found"})
                wait(1)
                UiModule.LoadingScreen.FadeOut(p)
            end
        end
    elseif Button.Parent == Create and Button.Name == "Apply" then
        if Create.SelectedPrivacy.Value ~= "" and Create.SelectedDificulty.Value ~= "" and Create.SelectedMap.Value ~= "" then
            Left.ServerID.Text = Remotes.GenerateCode:InvokeServer({
                ["Privacy"] = Create.SelectedPrivacy.Value;
                ["Map"] = Create.SelectedMap.Value;
                ["Dificulty"] = Create.SelectedDificulty.Value
            })
            UI.Success:Play()
        else
            UI.Error:Play()
        end
    elseif Button.Parent == Create.Dificulty then
        Color({Create.Dificulty.Easy.Text, Create.Dificulty.Medium.Text, Create.Dificulty.Hard.Text, Create.Dificulty.Endless.Text}, FADE_1)
        Color({Button.Text}, SHOW_1)
        Create.SelectedDificulty.Value = Button.Name     
    elseif Button.Parent == Create.Maps and Remotes.GetLevel:InvokeServer() >= Button.RequiredLevel.Value then  
        Create.SelectedMap.Value = Button.Name
        Color(Core.Get(Create.Maps, "ImageButton"), FADE_2, true) -- Fade background
        Color({ -- Fade text
            Create.Maps.Baseplate.Title;
            Create.Maps.Grasslands.Title;
            Create.Maps["The Desert"].Title;
        }, FADE_1)
        Color({Button}, SHOW_1, true) -- Show background
        Color({Button.Title}, SHOW_1) -- Show text
    end

end

-- // Main \\ --

Update()
Frame.Visible = true
Frame.Position = UDim2.new(0.5, 0, 1.5, 0)

for _,Button in pairs(UI:GetDescendants()) do
    if Button:IsA("TextButton") or Button:IsA("ImageButton") then

        -- Clicked
        Button.MouseButton1Click:Connect(function()
            ButtonClicked(Button)
        end)

        -- Hovered
        if Button.Parent ~= Create.Maps then
            HoveredItems[Button:GetFullName()] = Button.Size

            Button.MouseEnter:Connect(function()
                local Size = HoveredItems[Button:GetFullName()]
                local Goal = UDim2.new(Size.X.Scale * HOVER_MULTIPLIER, Size.X.Offset * HOVER_MULTIPLIER, Size.Y.Scale * HOVER_MULTIPLIER, Size.Y.Offset * HOVER_MULTIPLIER)
                Button:TweenSize(Goal, Enum.EasingDirection.In, Enum.EasingStyle.Linear, HOVER_DURATION, true)
            end)

            Button.MouseLeave:Connect(function()
                Button:TweenSize(HoveredItems[Button:GetFullName()], Enum.EasingDirection.In ,Enum.EasingStyle.Linear, HOVER_DURATION, true)
            end)
        end

    end
end

while wait(1) do
    while Join.Visible do
        local Servers = Remotes.GetServers:InvokeServer()
        if Servers then
            
            -- Deletes servers that are not found
            for _,Frame in pairs(Core.Get(Join.Games, "ImageLabel")) do
                if not table.find(Servers, Frame.Name) or #Servers[Frame.Name].Players >= Servers[Frame.Name].MaxPlayers then
                    Frame:Destroy()
                end
            end

            -- Adds servers
            for Code, Info in pairs(Servers) do
                if not Join.Games:FindFirstChild(Code) and Info.Privacy == "Public" then
                    local Template = Join.Games.ListLayout.Template:Clone()
                    Template.Creator.Text = Info.Owner
                    Template.Dificulty.Text = Info.Dificulty
                    Template.Level.Text = "Level: " .. Info.LevelOfOwner
                    Template.Parent = Join.Games

                    Template.Join.MouseButton1Click:Connect(function()
                        UiModule.LoadingScreen.FadeIn(
                            p,
                            "Join Game..."
                        )
                        TeleportService:SetTeleportGui(UIs.JoiningGame)
                        if Remotes.JoinServer:InvokeServer(Code) then
                            wait(1)
                            UiModule.LoadingScreen.UpdateProperties(p, {["Text"] = "Server Not Found"})
                            wait(1)
                            UiModule.LoadingScreen.FadeOut(p)
                        end
                    end)

                end
            end

        end
        wait(SERVER_LIST_UPDATE_DELAY)
    end
end