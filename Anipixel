local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local MERGE_CFRAME = CFrame.new(229.45134, -181.306137, 183.051865, -0.999990702, 0, -0.00440241303, 0, 1, 0, 0.00440241303, 0, -0.999990702)
local BOSS_SPAWN_CFRAME = CFrame.new(-255.015045, -5.69940853, -881.5802)
local TP_THRESHOLD = 15 

local DB_LOCATIONS = {
    CFrame.new(-1.67291641, 79.0576019, 266.863037),
    CFrame.new(95.8843079, 29.1571198, 5.08903503),
    CFrame.new(377.109161, 12.3360214, 7.98773193),
    CFrame.new(196.93129, -216.564728, -54.9656982),
    CFrame.new(1184.02759, -337.992981, -728.5495), 
    CFrame.new(676.919922, 12.1649628, -127.206299),
    CFrame.new(-88.4978256, 12.8059921, -239.257172)
}

local BossList = {
    "Aizen (Hogyoku)", "All For One", "Boros", "Dio Over Heaven", 
    "Fusion Zamasu (Corrupted)", "Heian Era Sukuna", "Madara Ten Tails", 
    "Meliodas (Demon Form 2)", "Mob"
}

local Blacklist = {
    ["Wano Luffy"] = true,
    ["Naru (Kid)"] = true,
}

local function serverHop()
    local PlaceID = game.PlaceId
    local JobID = game.JobId
    local Success, Servers = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    
    if Success then
        local Decoded = HttpService:JSONDecode(Servers)
        local targetServer = nil
        for _, server in pairs(Decoded.data) do
            if server.playing > 0 and server.playing < (server.maxPlayers - 2) and server.id ~= JobID then
                targetServer = server.id
                break
            end
        end
        if targetServer then
            Rayfield:Notify({Title = "Server Hop", Content = "Joining small server...", Duration = 3})
            TeleportService:TeleportToPlaceInstance(PlaceID, targetServer, LP)
        else
            Rayfield:Notify({Title = "Error", Content = "No small servers found.", Duration = 3})
        end
    else
        Rayfield:Notify({Title = "Error", Content = "Failed to fetch servers.", Duration = 3})
    end
end

local function equipMainSquad()
    local args = {
        [1] = {
            ["1"] = "Toji",
            ["4"] = "Titan Rengoku",
            ["3"] = "Mega Sparking Hakari",
            ["2"] = "Mahito"
        }
    }
    ReplicatedStorage.Events.SquadUpdate:FireServer(unpack(args))
end

local function runMergeProcess()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local inventory = LP:WaitForChild("DoodleInv")
    local targetUnit = nil

    for _, item in pairs(inventory:GetChildren()) do
        if item.Value >= 4 and not Blacklist[item.Name] then
            targetUnit = item.Name
            break
        end
    end

    if targetUnit then
        local distance = (root.Position - MERGE_CFRAME.Position).Magnitude
        if distance > TP_THRESHOLD then
            char:PivotTo(MERGE_CFRAME)
            ReplicatedStorage.Events.Teleport:FireServer(MERGE_CFRAME)
            task.wait(1.2)
        end
        local squadArgs = {[1] = {["1"] = targetUnit, ["2"] = targetUnit, ["3"] = targetUnit, ["4"] = targetUnit}}
        ReplicatedStorage.Events.SquadUpdate:FireServer(unpack(squadArgs))
        task.wait(0.8)
        local prompt = workspace:FindFirstChild("Prompt", true) 
        if prompt then
            fireproximityprompt(prompt)
            Rayfield:Notify({Title = "Merged", Content = "Processed: " .. targetUnit, Duration = 2})
            return true 
        end
    end
    return false
end

local function raidAfkMerge()
    local inventory = LP:WaitForChild("DoodleInv")
    local needsMerge = false
    
    for _, item in pairs(inventory:GetChildren()) do
        if item.Value >= 20 and not Blacklist[item.Name] then
            needsMerge = true
            break
        end
    end
    
    if needsMerge then
        Rayfield:Notify({Title = "AFK Merge", Content = "Inventory Full (Value 20). Merging...", Duration = 3})
        while runMergeProcess() do
            task.wait(2)
        end
        equipMainSquad()
        task.wait(1)
    end
end

local function sniperDragonBall()
    if _G.SnipingNow then return end
    local foundBall = nil
    for i = 1, 7 do
        local name = "DragonBall" .. i
        local check = workspace:FindFirstChild(name, true)
        if check then foundBall = check break end
    end

    if foundBall then
        _G.SnipingNow = true
        local prompt = foundBall:FindFirstChildOfClass("ProximityPrompt") or foundBall:FindFirstChild("Prompt", true)
        if prompt then
            local originalPos = LP.Character.HumanoidRootPart.CFrame
            LP.Character:PivotTo(foundBall.CFrame)
            task.wait(0.2)
            fireproximityprompt(prompt)
            task.wait(0.2)
            LP.Character:PivotTo(originalPos)
            Rayfield:Notify({Title = "Sniper", Content = "Sniped " .. foundBall.Name, Duration = 5})
        end
        task.wait(2)
        _G.SnipingNow = false
        return true
    end
    return false
end

_G.InBattle = false
local lastBattleTime = 0

local function startRaidBattle()
    if _G.InBattle and (tick() - lastBattleTime) > 60 then
        _G.InBattle = false
    end
    if _G.InBattle then return end
    
    local campaign = workspace:FindFirstChild("Campaign")
    if not campaign then return end

    local bossFound = false
    for _, bossName in pairs(BossList) do
        local bossModel = campaign:FindFirstChild(bossName)
        if bossModel and bossModel:IsA("Model") then
            _G.InBattle = true
            bossFound = true
            lastBattleTime = tick()
            LP.Character:PivotTo(BOSS_SPAWN_CFRAME)
            task.wait(0.5)
            ReplicatedStorage.Events.RequestBattle:FireServer(bossModel)
            Rayfield:Notify({Title = "Raid Boss", Content = "Engaging " .. bossName, Duration = 3})
            
            task.spawn(function()
                while _G.InBattle do
                    task.wait(1)
                    if not campaign:FindFirstChild(bossName) then
                        _G.InBattle = false
                    end
                end
            end)
            break
        end
    end

    -- If no boss found, handle AFK Merge logic
    if not bossFound then
        raidAfkMerge()
        -- Ensure character is at boss spawn to wait
        if (LP.Character.HumanoidRootPart.Position - BOSS_SPAWN_CFRAME.Position).Magnitude > 10 then
            LP.Character:PivotTo(BOSS_SPAWN_CFRAME)
        end
    end
end

ReplicatedStorage.Events.BattleResult.OnClientEvent:Connect(function(result)
    if result == "Won" then _G.InBattle = false end
end)

local Window = Rayfield:CreateWindow({
    Name = "AniPixels | Average Hub",
    LoadingTitle = "Delta Interface",
    LoadingSubtitle = "by Average",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Main Tab")

MainTab:CreateLabel("Unit Automation")
MainTab:CreateToggle({
    Name = "Auto-Merge Loop",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoMerge = Value
        task.spawn(function()
            while _G.AutoMerge do
                local merged = runMergeProcess()
                task.wait(merged and 3 or 5)
            end
        end)
    end,
})

MainTab:CreateButton({
    Name = "Manual Merge (Single)",
    Callback = function() runMergeProcess() end,
})

MainTab:CreateLabel("Raid Boss Automation")
MainTab:CreateToggle({
    Name = "Auto-Raid Loop",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoRaid = Value
        task.spawn(function()
            while _G.AutoRaid do
                startRaidBattle()
                task.wait(3)
            end
        end)
    end,
})

MainTab:CreateButton({
    Name = "Force Reset Battle State",
    Callback = function()
        _G.InBattle = false
        Rayfield:Notify({Title = "System", Content = "Battle state reset to Idle", Duration = 2})
    end,
})

MainTab:CreateLabel("World Events & Utilities")
MainTab:CreateToggle({
    Name = "Auto-Snipe Dragon Balls",
    CurrentValue = false,
    Callback = function(Value)
        _G.SnipeDB = Value
        task.spawn(function()
            while _G.SnipeDB do
                sniperDragonBall()
                task.wait(1) 
            end
        end)
    end,
})

MainTab:CreateButton({
    Name = "Scan Spawns & Server Hop",
    Callback = function()
        local char = LP.Character
        if not char then return end
        local originalPos = char.HumanoidRootPart.CFrame
        local found = false
        Rayfield:Notify({Title = "Scanning", Content = "Checking all locations...", Duration = 3})
        for _, loc in pairs(DB_LOCATIONS) do
            char:PivotTo(loc)
            task.wait(0.5)
            if sniperDragonBall() then found = true break end
        end
        if not found then
            Rayfield:Notify({Title = "No Luck", Content = "No Dragon Ball found. Hopping...", Duration = 2})
            task.wait(1)
            serverHop()
        else
            char:PivotTo(originalPos)
        end
    end,
})

MainTab:CreateButton({
    Name = "Manual Small Server Hop",
    Callback = function() serverHop() end,
})
