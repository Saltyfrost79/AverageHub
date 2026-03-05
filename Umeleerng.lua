local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local VirtualInputManager = game:GetService("VirtualInputManager")
local LP = game:GetService("Players").LocalPlayer

-- ==========================================
-- CONFIGURATION
-- ==========================================
local SP_PEDESTAL_CFRAME = CFrame.new(186.035492, 33.6716805, -272.198517, 1, 0, 0, 0, 1, 0, 0, 0, 1)

local Window = Rayfield:CreateWindow({
    Name = "Average Hub | Untitled Melee RNG",
    LoadingTitle = "Finalizing Melee Script...",
    LoadingSubtitle = "by Average",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Main")
local SkillTab = Window:CreateTab("Skill Tree")

-- ==========================================
-- MAIN AUTOMATION (ROLL & EQUIP)
-- ==========================================

MainTab:CreateToggle({
    Name = "Auto Roll Weapons (UI Click)",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoRoll = Value
        task.spawn(function()
            while _G.AutoRoll do
                -- Clicks the Roll die at the bottom
                local x, y = 0.5, 0.9 
                local viewportSize = workspace.CurrentCamera.ViewportSize
                VirtualInputManager:SendMouseButtonEvent(viewportSize.X * x, viewportSize.Y * y, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(viewportSize.X * x, viewportSize.Y * y, 0, false, game, 0)
                task.wait(0.2) 
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
                game:GetService("ReplicatedStorage").Remotes.EquipBest:FireServer()
                task.wait(10)
            end
        end)
    end,
})

-- ==========================================
-- SKILL TREE AUTOMATION (TP + CLICK)
-- ==========================================

SkillTab:CreateToggle({
    Name = "Auto TP & Convert SP",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoSP = Value
        task.spawn(function()
            while _G.AutoSP do
                -- 1. Teleport to Pedestal
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    LP.Character:PivotTo(SP_PEDESTAL_CFRAME)
                end
                task.wait(0.5)

                -- 2. Click the 'BUY 10 SP' purple button
                local x, y = 0.5, 0.15 
                local viewportSize = workspace.CurrentCamera.ViewportSize
                VirtualInputManager:SendMouseButtonEvent(viewportSize.X * x, viewportSize.Y * y, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(viewportSize.X * x, viewportSize.Y * y, 0, false, game, 0)
                
                task.wait(1)
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
                -- Fires the remote for stat upgrades
                local args = {[1] = "Spin Speed"}
                game:GetService("ReplicatedStorage").Remotes.BuyUpgrade:InvokeServer(unpack(args))
                task.wait(1)
            end
        end)
    end,
})
