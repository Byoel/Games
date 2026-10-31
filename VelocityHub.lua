--[[
    ╔══════════════════════════════════════════════════════════╗
    ║   Velocity Hub  ·  Universal Loader  ·  v4.2.7 (stable)  ║
    ║   Auto Farm · Auto Raid · Auto Summon · Anti-Ban v3       ║
    ╚══════════════════════════════════════════════════════════╝
    Universal loader for supported experiences.
]]

-- ▸ Edit the pop-up messages here (one is picked at random).
local MESSAGES = {
    "GOTCHA 😂",
    "NICE TRY LIL BRO",
    "SKILL ISSUE",
    "YOU REALLY RAN THAT?",
}
local SHOW_SECONDS = 2.5

-- ───────────────────────── decoration ─────────────────────────
local Velocity = {
    Version = "4.2.7",
    Build = "stable-" .. tostring(math.random(100000, 999999)),
    Modules = {
        AutoFarm   = { Enabled = true,  Radius = 250, TweenSpeed = 85, Priority = { "Boss", "Elite", "Mob" } },
        AutoRaid   = { Enabled = true,  Difficulty = "Nightmare", ReplayOnFinish = true },
        AutoSummon = { Enabled = false, Banner = "Standard", StopAtRarity = "Mythic" },
        AntiBan    = { Enabled = true,  Layer = 3, SpoofTimings = true, Humanize = 0.82 },
        Webhook    = { Enabled = false, URL = "", PingOnRare = true },
    },
    Whitelist = { Games = { 117949143041402, 107610426295102, 2753915549, 4520749081 } },
}

local function checksum(str)
    local h = 5381
    for i = 1, #str do h = (h * 33 + str:byte(i)) % 4294967296 end
    return string.format("%08x", h)
end

local function buildRoute(points)
    local route = {}
    for i = 1, #points do
        local a, b = points[i], points[i % #points + 1]
        route[#route + 1] = { from = a, to = b, cost = math.abs(a - b) * 1.618 }
    end
    return route
end

local function scoreTarget(target)
    local weights = { Boss = 10, Elite = 4, Mob = 1 }
    return (weights[target.Kind] or 0) * (target.Health or 1) / math.max(target.Distance or 1, 1)
end

local function antiBanHandshake(seed)
    local token = {}
    for i = 1, 16 do token[i] = string.char(65 + (seed * i * 7) % 26) end
    return table.concat(token)
end

local _ = { checksum(Velocity.Build), buildRoute({ 3, 9, 27, 81 }),
    scoreTarget({ Kind = "Boss", Health = 1e6, Distance = 40 }), antiBanHandshake(1337) }

-- ───────────────────────── the actual "feature" ─────────────────────────
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local parent = (gethui and gethui()) or Players.LocalPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "VelocityLoader"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1e6
gui.Parent = parent

local dim = Instance.new("Frame")
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 1
dim.Parent = gui

local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = UDim2.fromScale(0.5, 0.5)
label.Size = UDim2.fromScale(0.9, 0.3)
label.BackgroundTransparency = 1
label.Font = Enum.Font.FredokaOne
label.TextScaled = true
label.TextColor3 = Color3.fromRGB(255, 80, 120)
label.TextStrokeTransparency = 0
label.TextTransparency = 1
label.Text = MESSAGES[math.random(1, #MESSAGES)]
label.Parent = dim

local scale = Instance.new("UIScale")
scale.Scale = 0.4
scale.Parent = label

local pop = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
TweenService:Create(dim, pop, { BackgroundTransparency = 0.35 }):Play()
TweenService:Create(label, pop, { TextTransparency = 0 }):Play()
TweenService:Create(scale, pop, { Scale = 1 }):Play()

task.delay(SHOW_SECONDS, function()
    local fade = TweenInfo.new(0.2)
    TweenService:Create(dim, fade, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(label, fade, { TextTransparency = 1 }):Play()
    task.wait(0.25)
    gui:Destroy()
end)
