-- ██████╗ ██████╗ ██╗███████╗ ██████╗ ███╗   ██╗    ██╗  ██╗
-- ██╔══██╗██╔══██╗██║██╔════╝██╔═══██╗████╗  ██║    ╚██╗██╔╝
-- ██████╔╝██████╔╝██║███████╗██║   ██║██╔██╗ ██║     ╚███╔╝ 
-- ██╔═══╝ ██╔══██╗██║╚════██║██║   ██║██║╚██╗██║     ██╔██╗ 
-- ██║     ██║  ██║██║███████║╚██████╔╝██║ ╚████║    ██╔╝ ██╗
-- ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝  ╚═╝
-- Prison Life | Fluent UI | Velocity Executor
-- Features: Silent Aim, ESP, Kill Aura, Arrest Aura, Noclip,
--           Infinite Jump, Speed, Teleports, Gun Obtainer,
--           Anti-Arrest, Anti-Tase, Bypasses, Auto-Keycard & more

if getgenv().prisonx_loaded then
    warn("[PrisonX] Already running.")
    return
end
getgenv().prisonx_loaded = true

-- ─────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui       = game:GetService("StarterGui")
local Teams            = game:GetService("Teams")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local LP        = Players.LocalPlayer
local Camera    = workspace.CurrentCamera
local PlaceId   = game.PlaceId
local JobId     = game.JobId

-- ─────────────────────────────────────────────
--  FLUENT UI LOAD
-- ─────────────────────────────────────────────
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

-- ─────────────────────────────────────────────
--  SETTINGS TABLE
-- ─────────────────────────────────────────────
local settings = {
    -- Bypasses
    char_collision_bypass = true,
    anti_noclip_bypass    = true,
    stamina_bypass        = true,

    -- Combat
    silent_aim   = false,
    team_check   = true,
    wall_check   = true,
    fov          = 120,
    target_part  = "Head",
    show_fov     = true,
    fov_color    = Color3.fromRGB(255, 255, 255),

    kill_aura         = false,
    killaura_radius   = 10,
    killaura_sphere   = false,
    katc              = false,
    katype            = "All",
    katype_allowed    = {},

    arrest_aura       = false,
    arrestaura_radius = 15,
    aatc              = false,
    aatype            = "Both",

    -- Player
    noclip       = false,
    inf_jump     = false,
    auto_sprint  = false,
    speed_val    = 25,
    speed_enable = false,
    spin         = false,
    spin_speed   = 5,
    fov_changer  = 70,

    -- Protection
    anti_arrest  = false,
    anti_tase    = true,
    auto_respawn = false,
    aajr         = true,       -- auto anti-jump removal loop

    -- Automation
    auto_guns    = false,
    auto_guns_list = {},
    auto_fg      = false,
    auto_fgrate  = 0,
    akeycard     = true,
    abtoilets    = false,

    -- Visual / Doors
    nodoors      = false,
    tdoors       = false,
    htrees       = false,
    remove_team_indicators = false,

    -- ESP
    esp_enabled  = false,
    esp_distance = true,
    esp_health   = true,
    esp_name     = true,
    esp_boxes    = false,

    -- Kill Feed
    killfeed     = false,
}

-- ─────────────────────────────────────────────
--  HELPERS
-- ─────────────────────────────────────────────
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "PrisonX",
            Text  = text  or "",
            Duration = duration or 3,
        })
    end)
end

local function GetChar()  return LP.Character end
local function GetHRP()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ─────────────────────────────────────────────
--  PASS CHECKS
-- ─────────────────────────────────────────────
local riot_pass, mafia_pass, sniper_pass = false, false, false
pcall(function()
    riot_pass  = MarketplaceService:UserOwnsGamePassAsync(LP.UserId, 643697197)
             or MarketplaceService:UserOwnsGamePassAsync(LP.UserId, 96651)
    mafia_pass = MarketplaceService:UserOwnsGamePassAsync(LP.UserId, 1443271)
    sniper_pass = MarketplaceService:UserOwnsGamePassAsync(LP.UserId, 699360089)
end)

local allGuns = {"AK-47", "Remington 870", "MP5"}
if riot_pass   then table.insert(allGuns, "M4A1")  end
if mafia_pass  then table.insert(allGuns, "FAL")   end
if sniper_pass then table.insert(allGuns, "M700")  end

local allGuns2 = {table.unpack(allGuns)}
table.insert(allGuns2, "Taser")
table.insert(allGuns2, "M9")
table.insert(allGuns2, "Revolver")

-- ─────────────────────────────────────────────
--  WINDOW
-- ─────────────────────────────────────────────
local Window = Fluent:CreateWindow({
    Title    = "PrisonX",
    SubTitle = "Fluent Edition",
    TabWidth = 160,
    Size     = UDim2.fromOffset(600, 480),
    Acrylic  = true,
    Theme    = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

local Tabs = {
    Main     = Window:AddTab({ Title = "Main",      Icon = "shield"         }),
    Combat   = Window:AddTab({ Title = "Combat",    Icon = "sword"          }),
    Player   = Window:AddTab({ Title = "Player",    Icon = "person-running" }),
    Teleport = Window:AddTab({ Title = "Teleport",  Icon = "map-pin"        }),
    Guns     = Window:AddTab({ Title = "Guns",      Icon = "crosshair"      }),
    Visual   = Window:AddTab({ Title = "Visuals",   Icon = "eye"            }),
    ESP      = Window:AddTab({ Title = "ESP",       Icon = "scan"           }),
    Settings = Window:AddTab({ Title = "Settings",  Icon = "settings"       }),
}

-- ═══════════════════════════════════════════════════════════
--  ██████╗ ██╗   ██╗██████╗  █████╗ ███████╗███████╗███████╗
--  ██╔══██╗╚██╗ ██╔╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝
--  ██████╔╝ ╚████╔╝ ██████╔╝███████║███████╗███████╗█████╗  
--  ██╔══██╗  ╚██╔╝  ██╔═══╝ ██╔══██║╚════██║╚════██║██╔══╝  
--  ██████╔╝   ██║   ██║     ██║  ██║███████║███████║███████╗
--  ╚═════╝    ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
-- ═══════════════════════════════════════════════════════════

-- ─── CHARACTER COLLISION BYPASS ─────────────────────────────
local function applyCollisionBypass()
    pcall(function()
        local s = ReplicatedStorage:FindFirstChild("Scripts")
        if s then
            local cc = s:FindFirstChild("CharacterCollision")
            if cc then cc.Disabled = true end
        end
    end)
end

-- ─── ANTI-NOCLIP BYPASS (counter the game's head-CanCollide lock) ─────────
local antiNoclipBypassConn
local function enableAntiNoclipBypass()
    LP.CharacterAdded:Connect(function(char)
        if not settings.anti_noclip_bypass then return end
        local head = char:WaitForChild("Head", 10)
        if head then
            head:GetPropertyChangedSignal("CanCollide"):Connect(function()
                -- We want CanCollide OFF for noclip; the game tries to force it ON.
                -- If noclip is active we leave it alone; otherwise we don't fight it.
                -- This simply neutralises the game's forced re-enable when noclip is off.
                if settings.noclip and head.CanCollide then
                    head.CanCollide = false
                end
            end)
        end
    end)
end

-- ─── STAMINA / ANTI-JUMP BYPASS ──────────────────────────────
local function removeAntiJump()
    pcall(function()
        local sc = game:GetService("StarterPlayer"):FindFirstChild("StarterCharacterScripts")
        if sc then
            local aj = sc:FindFirstChild("AntiJump")
            if aj then aj:Destroy() end
        end
    end)
    pcall(function()
        local char = GetChar()
        if char then
            local aj = char:FindFirstChild("AntiJump")
            if aj then aj.Disabled = true end
        end
    end)
end

-- Patch the stamina table in gc so infinite jumps cost nothing
local function patchStaminaGC()
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "v_u_2") then
                rawset(v, "v_u_2", 2)
            end
        end
    end)
end

-- Apply bypasses on load
applyCollisionBypass()
enableAntiNoclipBypass()
if settings.stamina_bypass then removeAntiJump() end

-- Continuous stamina patch
task.spawn(function()
    while true do
        task.wait(0.5)
        if settings.stamina_bypass then patchStaminaGC() end
    end
end)

-- ─────────────────────────────────────────────
--  MAIN TAB – Bypasses & Misc
-- ─────────────────────────────────────────────
Tabs.Main:AddSection("Bypasses")

Tabs.Main:AddToggle("CharCollisionBypass", {
    Title   = "Character Collision Bypass",
    Description = "Disables the game's CharacterCollision script",
    Default = true,
    Callback = function(v)
        settings.char_collision_bypass = v
        if v then applyCollisionBypass() end
    end,
})

Tabs.Main:AddToggle("AntiNoclipBypass", {
    Title   = "Anti-Noclip Bypass",
    Description = "Neutralises the game's forced Head.CanCollide re-enable",
    Default = true,
    Callback = function(v)
        settings.anti_noclip_bypass = v
    end,
})

Tabs.Main:AddToggle("StaminaBypass", {
    Title   = "Stamina / Anti-Jump Bypass",
    Description = "Destroys AntiJump and patches the stamina GC table",
    Default = true,
    Callback = function(v)
        settings.stamina_bypass = v
        if v then removeAntiJump() end
    end,
})

Tabs.Main:AddSection("Kill Feed")
Tabs.Main:AddToggle("KillFeed", {
    Title   = "Kill Feed",
    Default = false,
    Callback = function(v)
        settings.killfeed = v
        if v then
            local Killfeed = ReplicatedStorage:FindFirstChild("Killfeed")
            if Killfeed then
                Killfeed.OnClientEvent:Connect(function(killer, victim)
                    if settings.killfeed then
                        Notify("Kill Feed", (killer and killer.Name or "?") .. " killed " .. (victim and victim.Name or "?"), 4)
                    end
                end)
            end
        end
    end,
})

Tabs.Main:AddSection("Server")
Tabs.Main:AddButton({
    Title    = "Server Hop",
    Description = "Jump to a less-populated server",
    Callback = function()
        local ok, res = pcall(function()
            return HttpService:JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
            )
        end)
        if ok and res and res.data then
            for _, srv in pairs(res.data) do
                if srv.playing > 0 and srv.playing < (srv.maxPlayers - 2) and srv.id ~= JobId then
                    Notify("Server Hop", "Joining server...", 3)
                    TeleportService:TeleportToPlaceInstance(PlaceId, srv.id, LP)
                    return
                end
            end
        end
        Notify("Server Hop", "No suitable server found.", 3)
    end,
})

Tabs.Main:AddButton({
    Title    = "Rejoin",
    Callback = function()
        if #Players:GetPlayers() <= 1 then
            LP:Kick("\nRejoining...")
            task.wait()
            TeleportService:Teleport(PlaceId, LP)
        else
            TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LP)
        end
    end,
})

-- ═══════════════════════════════════════════════════════════════
--  COMBAT TAB
-- ═══════════════════════════════════════════════════════════════

-- ─── FOV CIRCLE ──────────────────────────────────────────────
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.NumSides  = 64
fovCircle.Radius    = settings.fov
fovCircle.Filled    = false
fovCircle.Color     = settings.fov_color
fovCircle.Visible   = false

RunService.RenderStepped:Connect(function()
    local mp = UserInputService:GetMouseLocation()
    fovCircle.Position = mp
    fovCircle.Radius   = settings.fov
    fovCircle.Color    = settings.fov_color
    fovCircle.Visible  = settings.show_fov and settings.silent_aim
end)

-- ─── WALL CHECK ──────────────────────────────────────────────
local function isVisible(part)
    if not settings.wall_check then return true end
    local char = GetChar()
    local origin = Camera.CFrame.Position
    local dir    = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, Camera}
    local result = workspace:Raycast(origin, dir, params)
    if not result then return false end
    return result.Instance:IsDescendantOf(part.Parent)
end

-- ─── CLOSEST PLAYER (for silent aim) ─────────────────────────
local function getClosestPlayer()
    local closest, shortest = nil, settings.fov
    local mp = UserInputService:GetMouseLocation()

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if settings.team_check and plr.Team == LP.Team then continue end
        local char = plr.Character
        local hum  = char and char:FindFirstChild("Humanoid")
        local part = char and char:FindFirstChild(settings.target_part)
        if char and hum and hum.Health > 0 and part then
            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                if dist < shortest and isVisible(part) then
                    shortest = dist
                    closest  = plr
                end
            end
        end
    end
    return closest
end

-- ─── HOOK castRay for Silent Aim ─────────────────────────────
local castRayFunction, oldCastRay = nil, nil

pcall(function()
    for _, fn in ipairs(getgc()) do
        if type(fn) == "function" and not isexecutorclosure(fn) then
            local info = debug.getinfo(fn)
            if info.name == "castRay" and info.source and info.source:find("GunController") then
                castRayFunction = fn
                break
            end
        end
    end

    if castRayFunction then
        oldCastRay = hookfunction(castRayFunction, function(origin, targetPos, spread)
            if settings.silent_aim then
                local victim = getClosestPlayer()
                if victim and victim.Character then
                    local part = victim.Character:FindFirstChild(settings.target_part)
                    if part then return part, part.Position end
                end
            end
            return oldCastRay(origin, targetPos, spread)
        end)
        print("[PrisonX] castRay hooked successfully.")
    else
        warn("[PrisonX] castRay not found – silent aim unavailable until gunfire.")
    end
end)

-- ─── KILL AURA ───────────────────────────────────────────────
local ka_wl = {}

local katypes = {
    "All", "Criminals", "Inmates", "Guards",
    "Criminals + Inmates", "Criminals + Guards",
    "Inmates + Guards", "Other Teams"
}

local function updateKillableTeams(v)
    settings.katype = v
    local lteam = LP.Team and LP.Team.Name or ""
    local allowed = {}
    if v == "All"                 then allowed = {"Criminals","Inmates","Guards"}
    elseif v == "Criminals"       then allowed = {"Criminals"}
    elseif v == "Inmates"         then allowed = {"Inmates"}
    elseif v == "Guards"          then allowed = {"Guards"}
    elseif v == "Criminals + Inmates" then allowed = {"Criminals","Inmates"}
    elseif v == "Criminals + Guards"  then allowed = {"Criminals","Guards"}
    elseif v == "Inmates + Guards"    then allowed = {"Inmates","Guards"}
    elseif v == "Other Teams" then
        if lteam == "Inmates"   then allowed = {"Criminals","Guards"}
        elseif lteam == "Criminals" then allowed = {"Inmates","Guards"}
        elseif lteam == "Guards"    then allowed = {"Criminals","Inmates"}
        end
    end
    settings.katype_allowed = allowed
end
updateKillableTeams("All")

local function isKillable(plr)
    if plr == LP then return false end
    if table.find(ka_wl, plr.Name) then return false end
    if settings.katc then
        return table.find(settings.katype_allowed, plr.Team and plr.Team.Name or "") ~= nil
    end
    return true
end

local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent")

RunService.Heartbeat:Connect(function()
    if not settings.kill_aura then return end
    if not meleeEvent then
        meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent")
        return
    end
    local hrp = GetHRP()
    if not hrp then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if not isKillable(plr) then continue end
        local char = plr.Character
        local phrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if phrp and hum and hum.Health > 0 then
            if (hrp.Position - phrp.Position).Magnitude <= settings.killaura_radius then
                pcall(function() meleeEvent:FireServer(plr) end)
            end
        end
    end
end)

-- ─── ARREST AURA ─────────────────────────────────────────────
local aa_wl = {}
local arrestEvent = ReplicatedStorage:FindFirstChild("Remotes") and
    ReplicatedStorage.Remotes:FindFirstChild("ArrestPlayer")

RunService.Heartbeat:Connect(function()
    if not settings.arrest_aura then return end
    if LP.Team and LP.Team.Name ~= "Guards" then return end
    if not arrestEvent then
        arrestEvent = ReplicatedStorage:FindFirstChild("Remotes") and
            ReplicatedStorage.Remotes:FindFirstChild("ArrestPlayer")
        return
    end
    local hrp = GetHRP()
    if not hrp then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if table.find(aa_wl, plr.Name) then continue end
        local tname = plr.Team and plr.Team.Name or ""
        local shouldTarget = false
        if settings.aatype == "Both" then
            shouldTarget = tname == "Criminals" or tname == "Inmates"
        elseif settings.aatype == "Criminals" then
            shouldTarget = tname == "Criminals"
        elseif settings.aatype == "Inmates" then
            shouldTarget = tname == "Inmates"
        end
        if not shouldTarget then continue end

        local char = plr.Character
        local phrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if phrp and hum and hum.Health > 0 then
            if (hrp.Position - phrp.Position).Magnitude <= settings.arrestaura_radius then
                pcall(function() arrestEvent:FireServer(plr) end)
            end
        end
    end
end)

-- ─── COMBAT TAB UI ───────────────────────────────────────────
Tabs.Combat:AddSection("Silent Aim")

Tabs.Combat:AddToggle("SilentAim", {
    Title   = "Silent Aim",
    Default = false,
    Callback = function(v) settings.silent_aim = v end,
})

Tabs.Combat:AddToggle("ShowFOV", {
    Title   = "Show FOV Circle",
    Default = true,
    Callback = function(v) settings.show_fov = v end,
})

Tabs.Combat:AddSlider("FOVRadius", {
    Title   = "FOV Radius",
    Description = "Adjust silent aim circle size",
    Default = 120,
    Min     = 10,
    Max     = 600,
    Rounding = 1,
    Callback = function(v) settings.fov = v end,
})

Tabs.Combat:AddColorpicker("FOVColor", {
    Title   = "FOV Circle Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(v) settings.fov_color = v end,
})

Tabs.Combat:AddToggle("TeamCheck", {
    Title   = "Team Check (Silent Aim)",
    Default = true,
    Callback = function(v) settings.team_check = v end,
})

Tabs.Combat:AddToggle("WallCheck", {
    Title   = "Wall Check (Silent Aim)",
    Default = true,
    Callback = function(v) settings.wall_check = v end,
})

Tabs.Combat:AddDropdown("TargetPart", {
    Title   = "Target Part",
    Values  = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"},
    Default = 1,
    Callback = function(v) settings.target_part = v end,
})

Tabs.Combat:AddSection("Kill Aura")

Tabs.Combat:AddToggle("KillAura", {
    Title   = "Kill Aura",
    Default = false,
    Callback = function(v) settings.kill_aura = v end,
})

Tabs.Combat:AddSlider("KARadius", {
    Title   = "Kill Aura Radius",
    Default = 10,
    Min     = 1,
    Max     = 60,
    Rounding = 1,
    Callback = function(v) settings.killaura_radius = v end,
})

Tabs.Combat:AddToggle("KATeamCheck", {
    Title   = "Kill Aura Team Check",
    Default = false,
    Callback = function(v) settings.katc = v end,
})

Tabs.Combat:AddDropdown("KAType", {
    Title   = "Kill Aura Target Type",
    Values  = katypes,
    Default = 1,
    Callback = function(v) updateKillableTeams(v) end,
})

Tabs.Combat:AddSection("Arrest Aura")

Tabs.Combat:AddToggle("ArrestAura", {
    Title   = "Arrest Aura (Guards only)",
    Default = false,
    Callback = function(v) settings.arrest_aura = v end,
})

Tabs.Combat:AddSlider("AArrestRadius", {
    Title   = "Arrest Aura Radius",
    Default = 15,
    Min     = 1,
    Max     = 60,
    Rounding = 1,
    Callback = function(v) settings.arrestaura_radius = v end,
})

Tabs.Combat:AddDropdown("AArrestType", {
    Title   = "Arrest Target Type",
    Values  = {"Both", "Criminals", "Inmates"},
    Default = 1,
    Callback = function(v) settings.aatype = v end,
})

-- ═══════════════════════════════════════════════════════════════
--  PLAYER TAB
-- ═══════════════════════════════════════════════════════════════

-- ─── NOCLIP ──────────────────────────────────────────────────
RunService.Stepped:Connect(function()
    if not settings.noclip then return end
    local char = GetChar()
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- ─── INFINITE JUMP ───────────────────────────────────────────
UserInputService.JumpRequest:Connect(function()
    if settings.inf_jump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ─── SPEED ───────────────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    if not settings.speed_enable then return end
    local hum = GetHum()
    if hum then hum.WalkSpeed = settings.speed_val end
end)

-- ─── AUTO SPRINT ─────────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    if not settings.auto_sprint then return end
    local hum = GetHum()
    if hum and hum.MoveDirection.Magnitude > 0 then
        hum.WalkSpeed = 21
    elseif hum and not settings.speed_enable then
        hum.WalkSpeed = 16
    end
end)

-- ─── SPIN ────────────────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    if not settings.spin then return end
    local hrp = GetHRP()
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(settings.spin_speed), 0)
    end
end)

-- ─── PLAYER TAB UI ───────────────────────────────────────────
Tabs.Player:AddSection("Movement")

Tabs.Player:AddToggle("Noclip", {
    Title   = "Noclip",
    Default = false,
    Callback = function(v) settings.noclip = v end,
})

Tabs.Player:AddToggle("InfiniteJump", {
    Title   = "Infinite Jump",
    Default = false,
    Callback = function(v) settings.inf_jump = v end,
})

Tabs.Player:AddToggle("SpeedEnable", {
    Title   = "Speed Changer",
    Default = false,
    Callback = function(v) settings.speed_enable = v end,
})

Tabs.Player:AddSlider("SpeedVal", {
    Title   = "Walk Speed",
    Default = 25,
    Min     = 1,
    Max     = 100,
    Rounding = 1,
    Callback = function(v) settings.speed_val = v end,
})

Tabs.Player:AddToggle("AutoSprint", {
    Title   = "Auto Sprint",
    Default = false,
    Callback = function(v) settings.auto_sprint = v end,
})

Tabs.Player:AddSection("Misc")

Tabs.Player:AddToggle("Spin", {
    Title   = "Spin",
    Default = false,
    Callback = function(v) settings.spin = v end,
})

Tabs.Player:AddSlider("SpinSpeed", {
    Title   = "Spin Speed",
    Default = 5,
    Min     = 1,
    Max     = 30,
    Rounding = 1,
    Callback = function(v) settings.spin_speed = v end,
})

Tabs.Player:AddSlider("FOVChanger", {
    Title   = "Camera FOV",
    Default = 70,
    Min     = 10,
    Max     = 120,
    Rounding = 1,
    Callback = function(v)
        settings.fov_changer = v
        Camera.FieldOfView = v
    end,
})

-- ─── PROTECTION ──────────────────────────────────────────────
Tabs.Player:AddSection("Protection")

Tabs.Player:AddToggle("AntiArrest", {
    Title   = "Anti-Arrest",
    Description = "Respawn as criminal when arrested",
    Default = false,
    Callback = function(v) settings.anti_arrest = v end,
})

Tabs.Player:AddToggle("AntiTase", {
    Title   = "Anti-Tase",
    Default = true,
    Callback = function(v) settings.anti_tase = v end,
})

Tabs.Player:AddToggle("AutoRespawn", {
    Title   = "Auto Respawn (same position)",
    Default = false,
    Callback = function(v) settings.auto_respawn = v end,
})

-- Anti-arrest hook
local lastCF = CFrame.new()
local fugging = false

LP.CharacterAdded:Connect(function(char)
    local hrp = char:WaitForChild("HumanoidRootPart")
    task.spawn(function()
        while char.Parent do
            lastCF = hrp.CFrame
            task.wait(0.5)
        end
    end)
end)

local crimPad = workspace:FindFirstChild("Criminals Spawn")

LP.CharacterAdded:Connect(function(char)
    if settings.auto_respawn then
        task.wait(0.1)
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = lastCF
    end

    if settings.anti_arrest then
        task.spawn(function()
            if crimPad and not fugging then
                fugging = true
                local oldCF = lastCF
                local hrp = char:WaitForChild("HumanoidRootPart")
                local pad = crimPad:FindFirstChild("SpawnLocation")
                if pad then
                    hrp.CFrame = pad.CFrame
                    repeat task.wait() until LP.Team == Teams.Criminals
                    hrp.CFrame = oldCF
                end
                fugging = false
            end
        end)
    end
end)

-- Anti-tase (re-enable movement)
RunService.Heartbeat:Connect(function()
    if not settings.anti_tase then return end
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    local home = pg:FindFirstChild("Home")
    if not home then return end
    -- re-enable reset button that gets hidden on tase
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    end)
end)

-- ═══════════════════════════════════════════════════════════════
--  TELEPORT TAB
-- ═══════════════════════════════════════════════════════════════

local Teleports = {
    { name = "Neutral Spawn",           cf = CFrame.new(879.2, 36.09, 2349.8) },
    { name = "(P) Cell Block",          cf = CFrame.new(918.9735107421875, 99.98998260498047, 2451.423583984375) },
    { name = "(P) Nexus",               cf = CFrame.new(877.929688, 99.9899826, 2373.57031, 0.989495575, 1.64841456e-08, 0.144563332, -3.13438235e-08, 1, 1.00512544e-07, -0.144563332, -1.0398788e-07, 0.989495575) },
    { name = "(P) Armory",              cf = CFrame.new(836.130432, 99.9899826, 2284.55908) },
    { name = "(P) Yard",                cf = CFrame.new(787.560425, 97.9999237, 2468.32056) },
    { name = "Criminal Base",           cf = CFrame.new(-864.760071, 94.4760284, 2085.87671) },
    { name = "(P) Cafeteria",           cf = CFrame.new(884.492798, 99.9899368, 2293.54907) },
    { name = "(P) Kitchen",             cf = CFrame.new(936.633118, 99.9899368, 2224.77148) },
    { name = "(P) Roof",                cf = CFrame.new(918.694092, 139.709427, 2266.60986) },
    { name = "(P) Vents",               cf = CFrame.new(933.55376574342, 121.534234671875, 2232.7952174975) },
    { name = "(P) Secret Room/Office",  cf = CFrame.new(706.1928465, 103.14982749, 2344.3957382525) },
    { name = "(P) Yard Tower",          cf = CFrame.new(786.731873, 125.039917, 2587.79834) },
    { name = "(P) Left Front Wall",     cf = CFrame.new(505.551605, 125.039917, 2127.41138) },
    { name = "(P) Garage",              cf = CFrame.new(618.705566, 98.039917, 2469.14136) },
    { name = "(P) Sewers",              cf = CFrame.new(917.123657, 78.6990509, 2297.05298) },
    { name = "Neighbourhood",           cf = CFrame.new(-281.254669, 54.1751289, 2484.75513) },
    { name = "Gas Station",             cf = CFrame.new(-497.284821, 54.3937759, 1686.3175) },
    { name = "Roadend by Warehouse",    cf = CFrame.new(-979.852478, 54.1750259, 1382.78967) },
    { name = "Lakeside Grocer/Armory+", cf = CFrame.new(455.089508, 11.4253607, 1222.89746) },
    { name = "Roadend by Prison",       cf = CFrame.new(1060.81995, 67.5668106, 1847.08923) },
    { name = "Inside Big Building (Trap)", cf = CFrame.new(-306.715485, 84.2401199, 1984.13367) },
    { name = "Inside Top of Shops (Trap)", cf = CFrame.new(-315.790436, 64.5724411, 1840.83521) },
    { name = "Inside Other Warehouse (Trap)", cf = CFrame.new(-943.973145, 94.1287613, 1919.73694) },
    { name = "Top of Big Building",     cf = CFrame.new(-317.689331, 118.838821, 2009.28186) },
}

local tpNames = {}
local tpMap   = {}
for _, tp in ipairs(Teleports) do
    table.insert(tpNames, tp.name)
    tpMap[tp.name] = tp.cf
end

local selectedTP = tpNames[1]

Tabs.Teleport:AddSection("Locations")

Tabs.Teleport:AddDropdown("TPLocation", {
    Title   = "Select Location",
    Values  = tpNames,
    Default = 1,
    Callback = function(v) selectedTP = v end,
})

Tabs.Teleport:AddButton({
    Title    = "Teleport",
    Callback = function()
        local hrp = GetHRP()
        if hrp and tpMap[selectedTP] then
            hrp.CFrame = tpMap[selectedTP]
            Notify("Teleport", "Teleported to " .. selectedTP, 2)
        end
    end,
})

Tabs.Teleport:AddSection("Player Teleport")

local allPlayerNames = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(allPlayerNames, p.Name) end
end
Players.PlayerAdded:Connect(function(p)
    table.insert(allPlayerNames, p.Name)
end)

Tabs.Teleport:AddButton({
    Title    = "Teleport to Closest Player",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then return end
        local closest, minDist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP then continue end
            local ph = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if ph then
                local d = (hrp.Position - ph.Position).Magnitude
                if d < minDist then minDist = d; closest = p end
            end
        end
        if closest then
            local ph = closest.Character.HumanoidRootPart
            hrp.CFrame = ph.CFrame * CFrame.new(0, 0, 3)
            Notify("Teleport", "Teleported to " .. closest.Name, 2)
        end
    end,
})

-- ═══════════════════════════════════════════════════════════════
--  GUNS TAB
-- ═══════════════════════════════════════════════════════════════

local AlreadyFound = {}

local function FindGunSpawner(GunName)
    if AlreadyFound[GunName] then return AlreadyFound[GunName], true end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "TouchGiver" then
            local actual = v:FindFirstChild("TouchGiver") or v
            if v:GetAttribute("ToolName") == GunName then
                AlreadyFound[GunName] = actual
                return actual, false
            end
            if v.Parent and v.Parent:GetAttribute("ToolName") == GunName then
                AlreadyFound[GunName] = actual
                return actual, false
            end
        end
    end
    return nil, nil
end

local function GetTool(name)
    return (LP:FindFirstChild("Backpack") and LP.Backpack:FindFirstChild(name))
        or (LP.Character and LP.Character:FindFirstChild(name))
end

local function GetGun(GunName)
    local giver, found = FindGunSpawner(GunName)
    if not giver then Notify("Gun Obtainer", "Could not find " .. GunName, 3); return end
    if not found then
        local clone = giver:Clone()
        clone.Parent = giver.Parent
        giver.Parent = workspace:FindFirstChild("Folder") or workspace
        giver.CanCollide = false
        giver.Transparency = 1
    end
    local hrp = LP.Character:WaitForChild("HumanoidRootPart")
    hrp.CFrame = giver.CFrame * CFrame.new(math.random(-2, 2), 0, 0)
    local timeout = 5
    repeat task.wait(0.1); timeout = timeout - 0.1 until GetTool(GunName) or timeout <= 0
    if GetTool(GunName) then
        Notify("Gun Obtainer", "Got " .. GunName, 2)
    else
        Notify("Gun Obtainer", "Failed to get " .. GunName, 2)
    end
end

local selectedGun = allGuns2[1]

Tabs.Guns:AddSection("Gun Obtainer")

Tabs.Guns:AddDropdown("GunSelect", {
    Title   = "Select Gun",
    Values  = allGuns2,
    Default = 1,
    Callback = function(v) selectedGun = v end,
})

Tabs.Guns:AddButton({
    Title    = "Get Selected Gun",
    Callback = function() GetGun(selectedGun) end,
})

Tabs.Guns:AddButton({
    Title    = "Get All Available Guns",
    Callback = function()
        for _, gun in ipairs(allGuns) do
            if not GetTool(gun) then
                GetGun(gun)
                task.wait(0.35)
            end
        end
        Notify("Gun Obtainer", "All guns obtained!", 3)
    end,
})

Tabs.Guns:AddSection("Fast Guns")

Tabs.Guns:AddToggle("AutoFG", {
    Title   = "Fast Guns (namecall hook)",
    Default = false,
    Callback = function(v) settings.auto_fg = v end,
})

Tabs.Guns:AddSlider("FGRate", {
    Title   = "Fire Rate Override (0 = fastest)",
    Default = 0,
    Min     = 0,
    Max     = 1,
    Rounding = 2,
    Callback = function(v) settings.auto_fgrate = v end,
})

-- Hook __namecall for fast guns
pcall(function()
    if hookmetamethod then
        local namecall
        namecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "GetAttributes" then
                local result = namecall(self, ...)
                if settings.auto_fg then
                    result.AutoFire  = true
                    result.FireRate  = settings.auto_fgrate
                end
                return result
            end
            return namecall(self, ...)
        end)
    else
        warn("[PrisonX] hookmetamethod not available – fast guns disabled.")
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  VISUALS TAB
-- ═══════════════════════════════════════════════════════════════

Tabs.Visual:AddSection("Doors")

Tabs.Visual:AddToggle("NoDoors", {
    Title   = "Remove Doors (Client)",
    Default = false,
    Callback = function(v)
        settings.nodoors = v
        if v then
            for _, door in pairs(workspace:GetDescendants()) do
                if door.Name == "Door" and door:IsA("BasePart") then
                    door:Destroy()
                end
            end
        end
    end,
})

Tabs.Visual:AddToggle("TransparentDoors", {
    Title   = "Transparent Doors (Client)",
    Default = false,
    Callback = function(v)
        settings.tdoors = v
        for _, door in pairs(workspace:GetDescendants()) do
            if door.Name == "Door" and door:IsA("BasePart") then
                door.Transparency = v and 1 or 0
            end
        end
    end,
})

Tabs.Visual:AddButton({
    Title    = "Destroy Prison Fences (Client)",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "Fence" and v:IsA("BasePart") then v:Destroy() end
        end
        Notify("Visuals", "Fences destroyed (client-side)", 2)
    end,
})

Tabs.Visual:AddButton({
    Title    = "Destroy Prison Gates (Client)",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if (v.Name == "Gate" or v.Name == "PrisonGate") and v:IsA("BasePart") then v:Destroy() end
        end
        Notify("Visuals", "Gates destroyed (client-side)", 2)
    end,
})

Tabs.Visual:AddSection("Environment")

Tabs.Visual:AddToggle("HideTrees", {
    Title   = "Hide Trees",
    Default = false,
    Callback = function(v)
        settings.htrees = v
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("tree") and obj:IsA("BasePart") then
                obj.Transparency = v and 1 or 0
            end
        end
    end,
})

Tabs.Visual:AddSection("Toilets")

Tabs.Visual:AddButton({
    Title    = "Break All Toilets (needs Hammer)",
    Callback = function()
        local hammer = GetTool("Hammer")
        if not hammer then Notify("Toilets", "You need a Hammer!", 3); return end
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name:lower():find("toilet") and v:IsA("BasePart") then
                pcall(function() v:Destroy() end)
            end
        end
        Notify("Toilets", "Toilets smashed!", 2)
    end,
})

Tabs.Visual:AddToggle("AutoToilets", {
    Title   = "Auto Break Toilets (loop)",
    Default = false,
    Callback = function(v)
        settings.abtoilets = v
        task.spawn(function()
            while settings.abtoilets do
                local hammer = GetTool("Hammer")
                if hammer then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name:lower():find("toilet") and obj:IsA("BasePart") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end,
})

-- ═══════════════════════════════════════════════════════════════
--  ESP TAB
-- ═══════════════════════════════════════════════════════════════

local espObjects = {}

local function clearESP()
    for _, obj in pairs(espObjects) do
        for _, d in pairs(obj) do pcall(function() d:Remove() end) end
    end
    espObjects = {}
end

local function createESPFor(plr)
    if plr == LP then return end
    local drawings = {}

    drawings.name = Drawing.new("Text")
    drawings.name.Size    = 14
    drawings.name.Center  = true
    drawings.name.Outline = true
    drawings.name.Visible = false

    drawings.health = Drawing.new("Text")
    drawings.health.Size    = 13
    drawings.health.Center  = true
    drawings.health.Outline = true
    drawings.health.Visible = false

    drawings.dist = Drawing.new("Text")
    drawings.dist.Size    = 12
    drawings.dist.Center  = true
    drawings.dist.Outline = true
    drawings.dist.Visible = false

    espObjects[plr] = drawings
end

Players.PlayerAdded:Connect(createESPFor)
Players.PlayerRemoving:Connect(function(plr)
    if espObjects[plr] then
        for _, d in pairs(espObjects[plr]) do pcall(function() d:Remove() end) end
        espObjects[plr] = nil
    end
end)
for _, p in pairs(Players:GetPlayers()) do createESPFor(p) end

local function getTeamColor(plr)
    if plr.Team then return plr.Team.TeamColor.Color end
    return Color3.fromRGB(255,255,255)
end

RunService.RenderStepped:Connect(function()
    if not settings.esp_enabled then
        for _, obj in pairs(espObjects) do
            for _, d in pairs(obj) do d.Visible = false end
        end
        return
    end

    local hrp = GetHRP()
    for plr, drawings in pairs(espObjects) do
        local char = plr.Character
        local phrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")

        if not phrp or not hum or hum.Health <= 0 then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local sp, onScreen = Camera:WorldToViewportPoint(phrp.Position + Vector3.new(0, 3.5, 0))
        if not onScreen then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local pos2D = Vector2.new(sp.X, sp.Y)
        local dist  = hrp and math.floor((hrp.Position - phrp.Position).Magnitude) or 0
        local color = getTeamColor(plr)

        if settings.esp_name and drawings.name then
            drawings.name.Text     = plr.Name
            drawings.name.Color    = color
            drawings.name.Position = pos2D + Vector2.new(0, -22)
            drawings.name.Visible  = true
        else
            drawings.name.Visible = false
        end

        if settings.esp_health and drawings.health then
            drawings.health.Text     = string.format("HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
            drawings.health.Color    = Color3.fromRGB(50, 255, 50)
            drawings.health.Position = pos2D + Vector2.new(0, -8)
            drawings.health.Visible  = true
        else
            drawings.health.Visible = false
        end

        if settings.esp_distance and drawings.dist then
            drawings.dist.Text     = dist .. " studs"
            drawings.dist.Color    = Color3.fromRGB(200, 200, 200)
            drawings.dist.Position = pos2D + Vector2.new(0, 6)
            drawings.dist.Visible  = true
        else
            drawings.dist.Visible = false
        end
    end
end)

Tabs.ESP:AddSection("ESP Settings")

Tabs.ESP:AddToggle("ESPEnabled", {
    Title   = "Enable ESP",
    Default = false,
    Callback = function(v) settings.esp_enabled = v end,
})

Tabs.ESP:AddToggle("ESPName", {
    Title   = "Show Names",
    Default = true,
    Callback = function(v) settings.esp_name = v end,
})

Tabs.ESP:AddToggle("ESPHealth", {
    Title   = "Show Health",
    Default = true,
    Callback = function(v) settings.esp_health = v end,
})

Tabs.ESP:AddToggle("ESPDist", {
    Title   = "Show Distance",
    Default = true,
    Callback = function(v) settings.esp_distance = v end,
})

-- ═══════════════════════════════════════════════════════════════
--  SETTINGS TAB
-- ═══════════════════════════════════════════════════════════════

Tabs.Settings:AddSection("Auto-Jump Removal Loop")

Tabs.Settings:AddToggle("AAJR", {
    Title   = "Auto Anti-Jump Removal (loop)",
    Description = "Repeatedly destroys AntiJump every 3s",
    Default = true,
    Callback = function(v)
        settings.aajr = v
        if v then
            task.spawn(function()
                while settings.aajr do
                    removeAntiJump()
                    task.wait(3)
                end
            end)
        end
    end,
})

Tabs.Settings:AddSection("Auto Keycard")

Tabs.Settings:AddToggle("AutoKeycard", {
    Title   = "Auto Keycard",
    Description = "Automatically picks up keycard on spawn",
    Default = true,
    Callback = function(v) settings.akeycard = v end,
})

Tabs.Settings:AddSection("UI")

Tabs.Settings:AddButton({
    Title    = "Close / Hide UI (RightCtrl)",
    Callback = function()
        Fluent:Destroy()
    end,
})

Tabs.Settings:AddButton({
    Title    = "Unload Script",
    Callback = function()
        clearESP()
        fovCircle:Remove()
        getgenv().prisonx_loaded = false
        Fluent:Destroy()
        Notify("PrisonX", "Script unloaded.", 3)
    end,
})

-- ─────────────────────────────────────────────
--  AUTO KEYCARD LOOP
-- ─────────────────────────────────────────────
LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    if not settings.akeycard then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v.Name:lower():find("keycard") then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = v:GetPrimaryPartCFrame() or hrp.CFrame
                task.wait(0.2)
                v.Parent = LP.Backpack
                Notify("Auto Keycard", "Keycard collected!", 2)
                break
            end
        end
    end
end)

-- ─────────────────────────────────────────────
--  AAJR STARTUP LOOP
-- ─────────────────────────────────────────────
task.spawn(function()
    while settings.aajr do
        removeAntiJump()
        task.wait(3)
    end
end)

-- ─────────────────────────────────────────────
--  FINALISE UI
-- ─────────────────────────────────────────────
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Notify("PrisonX", "Loaded! Press RightCtrl to toggle UI.", 5)
print("[PrisonX] Script loaded successfully.")
