local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = ReplicatedStorage:WaitForChild("Functions")

-- Settings & State
local MacroManager = {
    IsRecording = false,
    IsPlaying = false,
    StartTime = 0,
    CurrentMacro = {},
    Step = 1,
    SelectedFile = nil
}

-- Folder Setup
local RootFolder = "AverageHub"
local MacroFolder = RootFolder .. "/Macros/" .. game.PlaceId
if not isfolder(RootFolder) then makefolder(RootFolder) end
if not isfolder(RootFolder .. "/Macros") then makefolder(RootFolder .. "/Macros") end
if not isfolder(MacroFolder) then makefolder(MacroFolder) end

-- Utility Functions
local function cfToString(cf) return tostring(cf) end

local function stringToCf(str)
    local components = {}
    for val in str:gmatch("[^, ]+") do table.insert(components, tonumber(val)) end
    return CFrame.new(unpack(components))
end

-- Finding a tower at a position (Required for Upgrade/Sell playback)
local function GetTowerAtPos(posStr)
    local targetCf = stringToCf(posStr)
    for _, tower in pairs(workspace.Towers:GetChildren()) do
        if tower:IsA("Model") and tower.PrimaryPart then
            local dist = (tower.PrimaryPart.Position - targetCf.Position).Magnitude
            if dist < 1 then return tower end
        end
    end
    return nil
end

-- UI Initialization
local Window = Rayfield:CreateWindow({
    Name = "Average Hub | TD Macro Pro",
    LoadingTitle = "Initializing Macro System...",
    LoadingSubtitle = "by Average",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Macro Manager")

-- RECORDING SECTION
MainTab:CreateSection("Recording")

MainTab:CreateToggle({
    Name = "Record Macro",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            MacroManager.CurrentMacro = {}
            MacroManager.Step = 1
            MacroManager.StartTime = tick()
            MacroManager.IsRecording = true
            Rayfield:Notify({Title = "Macro", Content = "Recording Started!"})
        else
            MacroManager.IsRecording = false
            Rayfield:Notify({Title = "Macro", Content = "Recording Stopped."})
        end
    end,
})

local SaveName = ""
MainTab:CreateInput({
    Name = "Macro Filename",
    PlaceholderText = "e.g. ExtremeMode_Win",
    Callback = function(Text) SaveName = Text end,
})

MainTab:CreateButton({
    Name = "Save Recorded Macro",
    Callback = function()
        if SaveName ~= "" then
            local json = HttpService:JSONEncode(MacroManager.CurrentMacro)
            writefile(MacroFolder .. "/" .. SaveName .. ".json", json)
            Rayfield:Notify({Title = "Success", Content = "Saved to " .. SaveName .. ".json"})
        end
    end,
})

-- PLAYBACK SECTION
MainTab:CreateSection("Playback")

local FileList = {}
for _, file in pairs(listfiles(MacroFolder)) do
    table.insert(FileList, file:gsub(MacroFolder .. "/", ""):gsub(".json", ""))
end

local Dropdown = MainTab:CreateDropdown({
    Name = "Select Macro to Play",
    Options = FileList,
    CurrentOption = "",
    Callback = function(Option) MacroManager.SelectedFile = Option end,
})

MainTab:CreateButton({
    Name = "Play Selected Macro",
    Callback = function()
        if not MacroManager.SelectedFile or MacroManager.IsPlaying then return end
        
        local raw = readfile(MacroFolder .. "/" .. MacroManager.SelectedFile .. ".json")
        local data = HttpService:JSONDecode(raw)
        MacroManager.IsPlaying = true
        local pStartTime = tick()
        
        -- Sorting by time
        local sorted = {}
        for _, v in pairs(data) do table.insert(sorted, v) end
        table.sort(sorted, function(a, b) return a.time < b.time end)

        task.spawn(function()
            for _, action in ipairs(sorted) do
                if not MacroManager.IsPlaying then break end
                
                -- Wait for correct timestamp
                repeat task.wait() until (tick() - pStartTime) >= action.time
                
                if action.type == "Place" then
                    Functions.SpawnNewTower:InvokeServer(action.unit, stringToCf(action.pos))
                elseif action.type == "Upgrade" then
                    local tower = GetTowerAtPos(action.pos)
                    if tower then Functions.UpgradeTower:InvokeServer(tower) end
                elseif action.type == "Sell" then
                    local tower = GetTowerAtPos(action.pos)
                    if tower then Functions.SellTower:InvokeServer(tower) end
                end
            end
            MacroManager.IsPlaying = false
        end)
    end,
})

MainTab:CreateButton({
    Name = "Stop Playback",
    Callback = function() MacroManager.IsPlaying = false end,
})

-- THE HOOK
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if MacroManager.IsRecording and method == "InvokeServer" then
        local actionData = nil
        
        if self == Functions.SpawnNewTower then
            actionData = {Type = "Place", Unit = args[1], Pos = args[2]}
        elseif self == Functions.UpgradeTower then
            actionData = {Type = "Upgrade", Unit = args[1].Name, Pos = args[1].PrimaryPart.CFrame}
        elseif self == Functions.SellTower then
            actionData = {Type = "Sell", Unit = args[1].Name, Pos = args[1].PrimaryPart.CFrame}
        end
        
        if actionData then
            MacroManager.CurrentMacro[tostring(MacroManager.Step)] = {
                type = actionData.Type,
                time = tick() - MacroManager.StartTime,
                pos = cfToString(actionData.Pos),
                unit = actionData.Unit
            }
            MacroManager.Step = MacroManager.Step + 1
        end
    end
    return oldNamecall(self, ...)
end)
