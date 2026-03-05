local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = ReplicatedStorage:WaitForChild("Functions")

local MacroManager = {
    IsRecording = false,
    IsPlaying = false,
    StartTime = 0,
    CurrentMacro = {},
    Step = 1
}

-- Folder Setup for Delta
local RootFolder = "AverageHub"
local MacroFolder = RootFolder .. "/Macros/" .. game.PlaceId
if not isfolder(RootFolder) then makefolder(RootFolder) end
if not isfolder(RootFolder .. "/Macros") then makefolder(RootFolder .. "/Macros") end
if not isfolder(MacroFolder) then makefolder(MacroFolder) end

-- Convert CFrame to String for JSON
local function cfToString(cf)
    return tostring(cf)
end

-- Convert String back to CFrame for Playing
local function stringToCf(str)
    return CFrame.new(unpack(str:gsub(" ", ""):split(",")))
end

-- RECORDING LOGIC
function MacroManager:StartRecording()
    self.CurrentMacro = {}
    self.Step = 1
    self.StartTime = tick()
    self.IsRecording = true
    print("Recording Started...")
end

function MacroManager:LogAction(data)
    if not self.IsRecording then return end
    
    -- Matches your Rougelike.json structure
    self.CurrentMacro[tostring(self.Step)] = {
        type = data.Type,
        time = tick() - self.StartTime,
        money = 0, -- You can link your money UI here
        wave = 0,  -- You can link your wave UI here
        pos = cfToString(data.Pos or CFrame.new()),
        unit = data.Unit
    }
    self.Step = self.Step + 1
end

function MacroManager:Save(name)
    self.IsRecording = false
    local json = HttpService:JSONEncode(self.CurrentMacro)
    writefile(MacroFolder .. "/" .. name .. ".json", json)
    print("Macro Saved to: " .. name)
end

-- PLAYBACK LOGIC
function MacroManager:Play(name)
    local file = MacroFolder .. "/" .. name .. ".json"
    if not isfile(file) then return end
    
    local data = HttpService:JSONDecode(readfile(file))
    self.IsPlaying = true
    local pStartTime = tick()
    
    -- Sort actions by time
    local sorted = {}
    for i, v in pairs(data) do table.insert(sorted, v) end
    table.sort(sorted, function(a, b) return a.time < b.time end)

    task.spawn(function()
        for _, action in ipairs(sorted) do
            if not self.IsPlaying then break end
            
            -- Wait for the recorded timestamp
            repeat task.wait() until (tick() - pStartTime) >= action.time
            
            if action.type == "Place" then
                Functions.SpawnNewTower:InvokeServer(action.unit, stringToCf(action.pos))
            elseif action.type == "Upgrade" then
                -- Note: You'll need logic to find the specific tower instance at that position
                -- Functions.UpgradeTower:InvokeServer(TowerInstance)
            end
        end
        self.IsPlaying = false
    end)
end

-- THE HOOK (Captures your manual clicks)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if MacroManager.IsRecording and method == "InvokeServer" then
        if self == Functions.SpawnNewTower then
            MacroManager:LogAction({Type = "Place", Unit = args[1], Pos = args[2]})
        elseif self == Functions.UpgradeTower then
            MacroManager:LogAction({Type = "Upgrade", Unit = args[1].Name, Pos = args[1].PrimaryPart.CFrame})
        end
    end
    return oldNamecall(self, ...)
end)

return MacroManager
