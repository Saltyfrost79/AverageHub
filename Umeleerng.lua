local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Average Hub | Untitled Melee RNG",
    LoadingTitle = "Melee Automation Loading...",
    LoadingSubtitle = "by Average",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Main")
local SkillTab = Window:CreateTab("Skill Tree")

MainTab:CreateToggle({
    Name = "Auto Roll Weapons",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoRoll = Value
        task.spawn(function()
            while _G.AutoRoll do
                -- Firing the weapon roll remote
                game:GetService("ReplicatedStorage").Remotes.RollWeapons:InvokeServer()
                task.wait(0.1) 
            end
        end)
    end,
})

MainTab:CreateButton({
    Name = "Manual Equip Best",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.EquipBest:FireServer()
    end,
})

_G.EquipInterval = 60
MainTab:CreateSlider({
    Name = "Auto Equip Interval (Seconds)",
    Info = "How often to equip best weapon",
    Min = 0,
    Max = 60,
    CurrentValue = 60,
    Flag = "EquipSlider",
    Callback = function(Value)
        _G.EquipInterval = Value
    end,
})

MainTab:CreateToggle({
    Name = "Auto Equip Best Loop",
    CurrentValue = false,
    Callback = function(Value)
        _G.EquipLoop = Value
        task.spawn(function()
            while _G.EquipLoop do
                -- Firing the equip best remote based on slider value
                game:GetService("ReplicatedStorage").Remotes.EquipBest:FireServer()
                task.wait(_G.EquipInterval)
            end
        end)
    end,
})

SkillTab:CreateToggle({
    Name = "Auto Buy Upgrades",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoUpgrade = Value
        task.spawn(function()
            while _G.AutoUpgrade do
                -- Using the BuyUpgrade remote for "Spin Speed"
                local args = {[1] = "Spin Speed"}
                game:GetService("ReplicatedStorage").Remotes.BuyUpgrade:InvokeServer(unpack(args))
                task.wait(1)
            end
        end)
    end,
})

SkillTab:CreateToggle({
    Name = "Auto Convert Skill Points",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoSP = Value
        task.spawn(function()
            while _G.AutoSP do
                local args = {[1] = 10}
                game:GetService("ReplicatedStorage").Remotes.CalculateManaPrice:InvokeServer(unpack(args))
                game:GetService("ReplicatedStorage").Remotes.GetSPMultiplier:InvokeServer()
                task.wait(2)
            end
        end)
    end,
})
