local UI = {LoadingScreen = {}}
local TweenService = game:GetService("TweenService")

UI.LoadingScreen.TweenInfo = TweenInfo.new(
    1,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.In
)

function UI.LoadingScreen.FadeIn(p, Properties)

    if Properties then
        for Name, Value in pairs(Properties) do
            p.PlayerGui.LoadingScreen.Background[Name] = Value
        end
    end

    TweenService:Create(p.PlayerGui.LoadingScreen.Background, UI.LoadingScreen.TweenInfo, {
        BackgroundTransparency = 0
    }):Play()

end

function UI.LoadingScreen.FadeOut(p)
    TweenService:Create(p.PlayerGui.LoadingScreen.Background, UI.LoadingScreen.TweenInfo, {
        BackgroundTransparency = 1
    }):Play()
end

return UI