local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield", true))()

-- Point BASE at CryptoFarm folder so we can use src/*.lua paths
local BASE = "https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/CryptoFarm"

local function notifyErr(msg)
    pcall(function()
        Rayfield:Notify({ Title = "Valor Hub - Crypto Farm", Content = msg, Duration = 6 })
    end)
end

local function fetch(path)
    local ok, res = pcall(function()
        return game:HttpGet(BASE .. "/" .. path, true)
    end)
    if not ok or not res or #res == 0 then
        notifyErr("Fetch failed: " .. tostring(path))
        return nil
    end
    return res
end

local function loadChunk(source, name)
    if not source then return nil end
    local fn, err = loadstring(source)
    if not fn then
        notifyErr("Load error: " .. tostring(name) .. " -> " .. tostring(err))
        return nil
    end
    local ok, rv = pcall(fn)
    if not ok then
        notifyErr("Run error: " .. tostring(name) .. " -> " .. tostring(rv))
        return nil
    end
    return rv
end

-- Load modules from CryptoFarm/src with safe fallbacks
local State     = loadChunk(fetch("src/State.lua"), "State") or { settings = {}, update = function() end, get = function() return nil end }
local Services  = loadChunk(fetch("src/Services.lua"), "Services") or { Players = game:GetService("Players"), RunService = game:GetService("RunService"), UserInputService = game:GetService("UserInputService"), TweenService = game:GetService("TweenService"), Lighting = game:GetService("Lighting"), ReplicatedStorage = game:GetService("ReplicatedStorage") }

local function loadInitModule(path, name)
    local init = loadChunk(fetch(path), name)
    if not init then
        notifyErr(name .. " init missing; using stub")
        return { start = function() end, stop = function() end }
    end
    local ok, mod = pcall(function() return init(Services, State) end)
    if not ok or not mod then
        notifyErr(name .. " init failed; using stub")
        return { start = function() end, stop = function() end }
    end
    return mod
end

local Movement  = loadInitModule("src/Movement.lua", "Movement")
local Farm      = loadInitModule("src/Farm.lua", "Farm")

local Window = Rayfield:CreateWindow({
    Name = "Valor Hub - Crypto Farm",
    LoadingTitle = "Valor Hub - Crypto Farm",
    LoadingSubtitle = "Roblox-friendly UI",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "ValorHub",
        FileName = "UserConfig"
    },
    Discord = { Enabled = false, Invite = "", RememberJoins = true },
    KeySystem = false,
    KeySettings = { Title = "Valor Hub - Crypto Farm", Subtitle = "Authentication", Note = "", FileName = "ValorHubKey", SaveKey = true, GrabKeyFromSite = false, Key = "" }
})

local HomeTab     = Window:CreateTab("Home", 4483362458)
local FarmTab     = Window:CreateTab("Farm", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local UITab       = Window:CreateTab("UI & Config", 4483362458)
local InfoTab     = Window:CreateTab("Info", 4483362458)

-- Farm tab features
FarmTab:CreateSection("Teleport")
FarmTab:CreateToggle({
    Name = "Click Teleport",
    CurrentValue = State.get("clickTeleportEnabled"),
    Flag = "clickTeleportEnabled",
    Callback = function(on)
        State.update({ clickTeleportEnabled = on })
        if on then Farm.startClickTeleport() else Farm.stopClickTeleport() end
    end
})
FarmTab:CreateButton({
    Name = "Save Point (current position)",
    Callback = function()
        local name = Farm.saveCurrentPoint()
        Rayfield:Notify({ Title = "Valor Hub - Crypto Farm", Content = "Saved point: " .. tostring(name), Duration = 4 })
    end
})
FarmTab:CreateDropdown({
    Name = "Teleport to Saved Point",
    Options = Farm.listPoints(),
    CurrentOption = "",
    Flag = "teleportPoint",
    Callback = function(opt)
        Farm.teleportToPoint(opt)
    end
})

FarmTab:CreateSection("Automation")
FarmTab:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = State.get("autoCollect"),
    Flag = "autoCollect",
    Callback = function(on)
        State.update({ autoCollect = on })
        if on then Farm.startAutoCollect() else Farm.stopAutoCollect() end
    end
})
FarmTab:CreateToggle({
    Name = "Auto Sell Inventory",
    CurrentValue = State.get("autoSell"),
    Flag = "autoSell",
    Callback = function(on)
        State.update({ autoSell = on })
        if on then Farm.startAutoSell() else Farm.stopAutoSell() end
    end
})

-- Movement
MovementTab:CreateSection("Player")
MovementTab:CreateToggle({ Name = "Infinite Jump", CurrentValue = State.get("infiniteJump"), Flag = "infiniteJump", Callback = function(on) State.update({ infiniteJump = on }); if on then Movement.startInfiniteJump() else Movement.stopInfiniteJump() end end })
MovementTab:CreateToggle({ Name = "Speed Hack", CurrentValue = State.get("speedEnabled"), Flag = "speedEnabled", Callback = function(on) State.update({ speedEnabled = on }); if on then Movement.startSpeed() else Movement.stopSpeed() end end })
MovementTab:CreateSlider({ Name = "WalkSpeed", Range = {16, 250}, Increment = 1, Suffix = "ws", CurrentValue = State.get("walkSpeed"), Flag = "walkSpeed", Callback = function(v) State.update({ walkSpeed = v }); Movement.applySpeed(v) end })

-- UI
UITab:CreateSection("Interface")
UITab:CreateButton({ Name = "Destroy UI", Callback = function() Rayfield:Destroy() end })

InfoTab:CreateSection("About")
InfoTab:CreateParagraph({ Title = "Valor Hub - Crypto Farm", Content = "Grow a Crypto Farm automation: click teleport, saved points, auto collect, auto sell." })

Rayfield:LoadConfiguration()
