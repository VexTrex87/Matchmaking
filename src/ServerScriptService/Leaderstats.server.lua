game.Players.PlayerAdded:Connect(function(p)
    
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = p

    local Level = Instance.new("IntValue")
    Level.Name = "Level"
    Level.Parent = leaderstats

end)

workspace.Leveler.ClickDetector.MouseClick:Connect(function(p)
    p.leaderstats.Level.Value = p.leaderstats.Level.Value + 1
end)