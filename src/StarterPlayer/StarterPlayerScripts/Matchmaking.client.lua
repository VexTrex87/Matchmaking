wait(1)

-- // Settings \\ --

local SHOWN_COLOR = Color3.fromRGB(255, 255, 255)
local FADE_COLOR = Color3.fromRGB(150, 150, 150)

-- // Variables \\ --

local p = game.Players.LocalPlayer
local UI = p.PlayerGui.Matchmaking
local Frame = UI.Frame
local Left = Frame.Left
local Create = Frame.Create
local Join = Frame.Join

-- // Functions \\ --

function Show(Table)
    for _,v in pairs(Table) do
        v.TextColor3 = SHOWN_COLOR
    end    
end

function Fade(Table)
    for _,v in pairs(Table) do
        v.TextColor3 = FADE_COLOR
    end
end

function VisibleAll(Table, IsVisible)
    for _,v in pairs(Table) do
        v.Visible = IsVisible
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
                VisibleAll({Create, Left, Frame.Title}, true)
            end
        elseif Button.Name == "Join" then
            if Join.Visible then
                VisibleAll({Create, Join, Left, Frame.Title})
            else
                Create.Visible = false
                VisibleAll({Join, Left, Frame.Title}, true)
                Fade({Left.CreatePrivate.Text, Left.CreatePublic.Text})
            end
        end
    elseif Button.Parent == Left then
        Join.Visible = false
        if Button.Name == "CreatePrivate" then
            VisibleAll({Create, Left, Frame.Title}, true)
            Fade({Left.CreatePublic.Text})
            Show({Left.CreatePrivate.Text})
            Create.SelectedPrivacy.Value = "Private"           
        elseif Button.Name == "CreatePublic" then
            VisibleAll({Create, Left, Frame.Title}, true)
            Show({Left.CreatePublic.Text})
            Fade({Left.CreatePrivate.Text})
            Create.SelectedPrivacy.Value = "Public"
        elseif Button.Name == "JoinRandom" then
            print("Joining a random match...")
        elseif Button.Name == "JoinServer" then
            if Left.ServerID.Text ~= "" then
                print("Joining " .. Left.ServerID.Text .. "...")
            end
        end
    elseif Button.Parent == Create.Dificulty then
        Fade({Create.Dificulty.Easy.Text, Create.Dificulty.Medium.Text, Create.Dificulty.Hard.Text, Create.Dificulty.Endless.Text})
        Show({Button.Text})
        Create.SelectedDificulty.Value = Button.Name     
    elseif Button.Parent == Create then
        if Button.Name == "Apply" then
            if Create.SelectedPrivacy.Value ~= "" and Create.SelectedDificulty.Value ~= "" then
                Status = "Success"
            else
                Status = "Error"
            end
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

-- // Defaults \\ --

VisibleAll({Create, Join, Left, Frame.Title})
Fade({
	Left.CreatePublic.Text;
    Left.CreatePrivate.Text;
    Left.JoinRandom.Text;
    Create.Dificulty.Easy.Text;
    Create.Dificulty.Medium.Text;
    Create.Dificulty.Hard.Text;
    Create.Dificulty.Endless.Text;
})

-- // Main \\ --

for _,Button in pairs(UI:GetDescendants()) do
    if Button:IsA("TextButton") or Button:IsA("ImageButton") then
        Button.MouseButton1Click:Connect(function()
            ButtonClicked(Button)
        end)
    end
end