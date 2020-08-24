wait(1)

-- // Settings \\ --

local SHOW_1 = Color3.fromRGB(255, 255, 255)
local FADE_1 = Color3.fromRGB(150, 150, 150)
local FADE_2 = Color3.fromRGB(0, 0, 0)

-- // Variables \\ --

local Core = require(game.ReplicatedStorage.Core)
local p = game.Players.LocalPlayer
local Remotes = game.ReplicatedStorage.Remotes
local UI = p.PlayerGui:WaitForChild("Matchmaking")
local Frame = UI.Frame
local Left = Frame.Left
local Create = Frame.Create
local Join = Frame.Join

-- // Functions \\ --

function Color(Table, Color, IsBackgroundColor)
    if IsBackgroundColor then
        for _,v in pairs(Table) do
            v.BackgroundColor3 = Color
        end       
    else
        for _,v in pairs(Table) do
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
    Create.SelectedMap.Value, Create.SelectedDificulty.Value, Create.SelectedPrivacy.Value = "", "", ""
    VisibleAll({Create, Join, Left, Frame.Title})
    Color({
        Left.CreatePublic.Text;
        Left.CreatePrivate.Text;
        Left.JoinRandom.Text;
        Create.Dificulty.Easy.Text;
        Create.Dificulty.Medium.Text;
        Create.Dificulty.Hard.Text;
        Create.Dificulty.Endless.Text;
    }, FADE_1)
    
    Color(Core.Get(Create.Maps, "ImageButton"), FADE_2, true)
    Color({
        Create.Maps.Baseplate.Title;
        Create.Maps.Grasslands.Title;
        Create.Maps["The Desert"].Title;
    }, FADE_1)
    
    for _,Map in pairs(Core.Get(Create.Maps, "ImageButton")) do
        local MeetsLevel = Remotes.CheckLevel:InvokeServer(Map.RequiredLevel.Value)
        if not MeetsLevel and not Map:FindFirstChild("Locked") then
            local Locked = Create.Maps.ListLayout.Locked:Clone()
            Locked.Requirements.Text = "You must be level " .. Map.RequiredLevel.Value .. " to play " .. Map.Name
            Locked.Parent = Map
        elseif MeetsLevel and Map:FindFirstChild("Locked") then
            Map.Locked:Destroy()
        end
    end
end

function ButtonClicked(Button)
    local Status
    if Button.Parent == UI then
        if Button.Name == "Create" then
            if Create.Visible then
                VisibleAll({Create, Join, Left, Frame.Title})
            else
                Join.Visible = false
                Update()
                VisibleAll({Create, Left, Frame.Title}, true)
            end
        elseif Button.Name == "Join" then
            if Join.Visible then
                VisibleAll({Create, Join, Left, Frame.Title})
            else
                Create.Visible = false
                Update()
                VisibleAll({Join, Left, Frame.Title}, true)
                Color({Left.CreatePrivate.Text, Left.CreatePublic.Text}, FADE_1)
            end
        end
    elseif Button.Parent == Left then
        Join.Visible = false
        if Button.Name == "CreatePrivate" then
            VisibleAll({Create, Left, Frame.Title}, true)
            Color({Left.CreatePublic.Text}, FADE_1)
            Color({Left.CreatePrivate.Text}, SHOW_1)
            Create.SelectedPrivacy.Value = "Private"           
        elseif Button.Name == "CreatePublic" then
            VisibleAll({Create, Left, Frame.Title}, true)
            Color({Left.CreatePublic.Text}, SHOW_1)
            Color({Left.CreatePrivate.Text}, FADE_1)
            Create.SelectedPrivacy.Value = "Public"
        elseif Button.Name == "JoinRandom" then
            print("Joining a random match...")
        elseif Button.Name == "JoinServer" then
            if Left.ServerID.Text ~= "" then
                Remotes.JoinServer:InvokeServer(Left.ServerID.Text)
            end
        end
    elseif Button.Parent == Create.Dificulty then
        Color({Create.Dificulty.Easy.Text, Create.Dificulty.Medium.Text, Create.Dificulty.Hard.Text, Create.Dificulty.Endless.Text}, FADE_1)
        Color({Button.Text}, SHOW_1)
        Create.SelectedDificulty.Value = Button.Name     
    elseif Button.Parent == Create then
        if Button.Name == "Apply" then
            if Create.SelectedPrivacy.Value ~= "" and Create.SelectedDificulty.Value ~= "" and Create.SelectedMap.Value ~= "" then
                Left.ServerID.Text = Remotes.GenerateCode:InvokeServer({
                    ["Privacy"] = Create.SelectedPrivacy.Value;
                    ["Map"] = Create.SelectedMap.Value;
                    ["Value"] = Create.SelectedDificulty.Value
                })
                Status = "Success"
            else
                Status = "Error"
            end
        end
    elseif Button.Parent == Create.Maps then
        if Remotes.CheckLevel:InvokeServer(Button.RequiredLevel.Value) then
            Color(Core.Get(Create.Maps, "ImageButton"), FADE_2, true)
            Color({
                Create.Maps.Baseplate.Title;
                Create.Maps.Grasslands.Title;
                Create.Maps["The Desert"].Title;
            }, FADE_1)
            Color({Button}, SHOW_1, true)
            Color({Button.Title}, SHOW_1)
            Create.SelectedMap.Value = Button.Name
        end
    end

    if Status == "Error" then
        UI.Error:Play()
    elseif Status == "Success" then
        UI.Success:Play()
    else
        UI.Click:Play()
    end

end

-- // Main \\ --

Update()
for _,Button in pairs(UI:GetDescendants()) do
    if Button:IsA("TextButton") or Button:IsA("ImageButton") then
        Button.MouseButton1Click:Connect(function()
            ButtonClicked(Button)
        end)
    end
end