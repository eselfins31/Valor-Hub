local Services = require(script.Parent.Services)
local Auto = {}

local Players = Services.Players
local RunService = Services.RunService
local CollectionService = Services.CollectionService
local ReplicatedStorage = Services.ReplicatedStorage

-- Movement helpers
local Movement = {}
local speedConn
local originalWalkSpeed
local function getHumanoid()
    local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end
function Movement.startSpeed(target)
    local hum = getHumanoid()
    if not hum then return end
    if originalWalkSpeed == nil then originalWalkSpeed = hum.WalkSpeed end
    hum.WalkSpeed = target or 100
    if speedConn then speedConn:Disconnect() end
    speedConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        hum.WalkSpeed = target or 100
    end)
end
function Movement.stopSpeed()
    if speedConn then speedConn:Disconnect(); speedConn = nil end
    local hum = getHumanoid()
    if hum and originalWalkSpeed then hum.WalkSpeed = originalWalkSpeed end
    originalWalkSpeed = nil
end
function Movement.applySpeed(target)
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = target or hum.WalkSpeed end
end
Auto.Movement = Movement

-- Internal flags for keybind flips
Auto.__collecting = false
Auto.__selling = false

-- Utilities
local function getHRP()
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function tpNear(pos)
    local hrp = getHRP()
    if hrp and pos then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function getPromptWorldPos(prompt)
    if not prompt then return nil end
    local parent = prompt.Parent
    local tries = 0
    while parent and tries < 4 do
        if parent:IsA("BasePart") then return parent.Position end
        parent = parent.Parent; tries = tries + 1
    end
    if prompt.Parent and prompt.Parent:IsA("BasePart") then return prompt.Parent.Position end
    return nil
end

local function isCollectPrompt(prompt)
    local a = (prompt.ActionText or ""):lower()
    local o = (prompt.ObjectText or ""):lower()
    return a:find("collect") or a:find("harvest") or a:find("farm") or o:find("computer") or o:find("pc") or o:find("miner")
end

local function isSellPrompt(prompt)
    local a = (prompt.ActionText or ""):lower()
    local o = (prompt.ObjectText or ""):lower()
    return a:find("sell") or o:find("sell")
end

local function getPrompts()
    local collects, sells = {}, {}
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            if isCollectPrompt(p) then table.insert(collects, p)
            elseif isSellPrompt(p) then table.insert(sells, p) end
        end
    end
    return collects, sells
end

local function firePrompt(prompt)
    if not prompt or not prompt:IsDescendantOf(workspace) then return end
    -- Try executor helper first
    local ok = pcall(function() if fireproximityprompt then fireproximityprompt(prompt) end end)
    if ok then return end
    -- Fallback: temporarily set HoldDuration 0 and proximity range
    local oldHold, oldRange = prompt.HoldDuration, prompt.MaxActivationDistance
    prompt.MaxActivationDistance = math.max(oldRange, 20)
    prompt.HoldDuration = 0
    pcall(function() prompt:InputHoldBegin() end)
    task.wait(0.02)
    pcall(function() prompt:InputHoldEnd() end)
    prompt.HoldDuration = oldHold
    prompt.MaxActivationDistance = oldRange
end

local collectConn
local lastFired = setmetatable({}, {__mode = "k"})

function Auto.autoCollect(on)
    Auto.__collecting = on
    if collectConn then collectConn:Disconnect(); collectConn = nil end
    if on then
        collectConn = RunService.Heartbeat:Connect(function()
            local collects = getPrompts()
            -- collects is first return; we only need the first value
            collects = collects
            -- Teleport and fire a few per tick
            local fired = 0
            for _, prompt in ipairs(select(1, getPrompts())) do
                if fired >= 4 then break end
                if prompt.Enabled then
                    local t = lastFired[prompt] or 0
                    if (tick() - t) > 0.5 then
                        local pos = getPromptWorldPos(prompt)
                        if pos then tpNear(pos) end
                        firePrompt(prompt)
                        lastFired[prompt] = tick()
                        fired += 1
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end

local sellConn
function Auto.autoSell(on)
    Auto.__selling = on
    if sellConn then sellConn:Disconnect(); sellConn = nil end
    if on then
        sellConn = RunService.Heartbeat:Connect(function()
            -- find nearest sell prompt and activate
            local nearest, nd = nil, math.huge
            for _, p in ipairs(select(2, getPrompts())) do
                if p.Enabled then
                    local pos = getPromptWorldPos(p)
                    if pos then
                        local d = (pos - (getHRP() and getHRP().Position or pos)).Magnitude
                        if d < nd then nd = d; nearest = p end
                    end
                end
            end
            if nearest then
                local pos = getPromptWorldPos(nearest)
                if pos then tpNear(pos) end
                firePrompt(nearest)
            end
            task.wait(0.3)
        end)
    end
end

return Auto
