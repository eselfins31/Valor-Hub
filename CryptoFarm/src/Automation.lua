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

local collecting = false
local selling = false
local collectConn
local sellConn

-- Heuristic: items tagged as "Collectible"; if not, scan workspace for parts named with "Coin"/"Crypto"
local function findCollectibles()
    local items = {}
    for _, inst in ipairs(CollectionService:GetTagged("Collectible")) do table.insert(items, inst) end
    if #items == 0 then
        for _, inst in ipairs(workspace:GetDescendants()) do
            if inst:IsA("BasePart") then
                local n = inst.Name:lower()
                if n:find("coin") or n:find("crypto") or n:find("token") then table.insert(items, inst) end
            end
        end
    end
    return items
end

local function tpTo(part)
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and part and part.Position then
        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
    end
end

function Auto.autoCollect(on)
    collecting = on
    if collectConn then collectConn:Disconnect(); collectConn = nil end
    if on then
        collectConn = RunService.Heartbeat:Connect(function()
            local items = findCollectibles()
            for i = 1, math.min(5, #items) do
                local it = items[i]
                pcall(tpTo, it)
                task.wait(0.05)
            end
        end)
    end
end

-- Auto sell via GUI or remote: placeholder tries to fire a remote named Sell or SellCrypto if found
local function findSellRemote()
    for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
        if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
            local n = inst.Name:lower()
            if n == "sell" or n:find("sellcrypto") then return inst end
        end
    end
    return nil
end

local function clickSellGui()
    local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    for _, inst in ipairs(pg:GetDescendants()) do
        if inst:IsA("TextButton") or inst:IsA("ImageButton") then
            local n = inst.Name:lower()
            if n:find("sell") then pcall(function() inst:Activate() end) end
        end
    end
end

function Auto.autoSell(on)
    selling = on
    if sellConn then sellConn:Disconnect(); sellConn = nil end
    if on then
        sellConn = RunService.Heartbeat:Connect(function()
            local r = findSellRemote()
            if r then
                pcall(function() if r.FireServer then r:FireServer() else r:InvokeServer() end end)
            else
                clickSellGui()
            end
            task.wait(0.5)
        end)
    end
end

return Auto
