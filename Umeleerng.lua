local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Average Hub | Untitled Melee RNG",
    LoadingTitle = "Fixing Automation...",
    LoadingSubtitle = "by Average",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Main")
local SkillTab = Window:CreateTab("Skill Tree")

-- ==========================================
-- MAIN AUTOMATION (WEAPONS)
-- ==========================================

MainTab:CreateToggle({
    Name = "Auto Roll Weapons",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoRoll = Value
        task.spawn(function()
            while _G.AutoRoll do
                -- Attempting FireServer if InvokeServer failed
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.RollWeapons:InvokeServer()
                end)
                task.wait(0.1) 
            end
        end)
    end,
})

MainTab:CreateToggle({
    Name = "Auto Equip Best (10s)",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoEquip = Value
        task.spawn(function()
            while _G.AutoEquip do
                -- Fixed 10s loop per request
                game:GetService("ReplicatedStorage").Remotes.EquipBest:FireServer()
                task.wait(10)
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

-- ==========================================
-- SKILL TREE AUTOMATION
-- ==========================================

SkillTab:CreateLabel("Skill Point Management")

SkillTab:CreateToggle({
    Name = "Auto Convert Skill Points",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoSP = Value
        task.spawn(function()
            while _G.AutoSP do
                -- Firing both remotes for conversion
                local args = {[1] = 10}
                game:GetService("ReplicatedStorage").Remotes.CalculateManaPrice:InvokeServer(unpack(args))
                game:GetService("ReplicatedStorage").Remotes.GetSPMultiplier:InvokeServer()
                task.wait(2)
            end
        end)
    end,
})

SkillTab:CreateToggle({
    Name = "Auto Buy Spin Speed",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoUpgrade = Value
        task.spawn(function()
            while _G.AutoUpgrade do
                -- Buying spin speed upgrade
                local args = {[1] = "Spin Speed"}
                game:GetService("ReplicatedStorage").Remotes.BuyUpgrade:InvokeServer(unpack(args))
                task.wait(1)
            end
        end)
    end,
})
