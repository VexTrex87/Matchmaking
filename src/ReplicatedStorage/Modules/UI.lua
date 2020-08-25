local UI = {LoadingScreen = {}}
local TweenService = game:GetService("TweenService")

UI.LoadingScreen.TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

function UI.LoadingScreen.FadeIn(p, Text, Properties)
    p.PlayerGui.LoadingScreen.Background.Text = ""
    if Properties then
        for Name, Value in pairs(Properties) do
            p.PlayerGui.LoadingScreen.Background[Name] = Value
        end
    end

    local Tween = TweenService:Create(p.PlayerGui.LoadingScreen.Background, UI.LoadingScreen.TweenInfo, {BackgroundTransparency = 0})
    Tween:Play()
    Tween.Completed:Wait()
    p.PlayerGui.LoadingScreen.Background.Text = Text
end

function UI.LoadingScreen.FadeOut(p)
    p.PlayerGui.LoadingScreen.Background.Text = ""
    TweenService:Create(p.PlayerGui.LoadingScreen.Background, UI.LoadingScreen.TweenInfo, {BackgroundTransparency = 1}):Play()
end

function UI.LoadingScreen.UpdateProperties(p, Properties)
    for Name, Value in pairs(Properties) do
        p.PlayerGui.LoadingScreen.Background[Name] = Value
    end
end

return UI