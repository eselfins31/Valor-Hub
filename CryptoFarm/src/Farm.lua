return function(Services, State)
    local Farm = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local UserInputService = Services.UserInputService
    local ReplicatedStorage = Services.ReplicatedStorage

    local LocalPlayer = Players.LocalPlayer

    local savedPoints = {}
    local clickConn
    local collectConn
    local sellConn

    -- Remote lookup/cache (ReplicatedStorage.Remotes.Events.<Name>)
    local remoteCache = {}
    local function resolveEvent(name)
        if remoteCache[name] and remoteCache[name].Parent then return remoteCache[name] end
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("remotes")
        if not remotes then remotes = ReplicatedStorage:WaitForChild("Remotes", 2) end
        if not remotes then return nil end
        local events = remotes:FindFirstChild("Events") or remotes:FindFirstChild("events")
        if not events then events = remotes:WaitForChild("Events", 2) end
        if not events then return nil end
        local ev = events:FindFirstChild(name) or events:FindFirstChild(name:upper()) or events:FindFirstChild(name:lower())
        if not ev then ev = events:WaitForChild(name, 1) end
        remoteCache[name] = ev
        return ev
    end

    local function fireNoArg(name)
        local r = resolveEvent(name)
        if not r or not r:IsA("RemoteEvent") then return false end
        return pcall(function() r:FireServer() end) == true
    end

    -- Click Teleport
    function Farm.startClickTeleport()
        Farm.stopClickTeleport()
        clickConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp or not State.get("clickTeleportEnabled") then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = UserInputService:GetMouseLocation()
                local cam = workspace.CurrentCamera
                local unitRay = cam:ViewportPointToRay(mouse.X, mouse.Y)
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Blacklist
                params.FilterDescendantsInstances = { LocalPlayer.Character }
                local hit = workspace:Raycast(unitRay.Origin, unitRay.Direction * 5000, params)
                if hit then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) end
                end
            end
        end)
    end

    function Farm.stopClickTeleport()
        if clickConn then clickConn:Disconnect(); clickConn = nil end
    end

    -- Save/Teleport Points
    function Farm.saveCurrentPoint()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return "" end
        local name = os.date("%H:%M:%S")
        savedPoints[name] = hrp.CFrame
        return name
    end

    function Farm.listPoints()
        local list = {}
        for k in pairs(savedPoints) do table.insert(list, k) end
        table.sort(list)
        return list
    end

    function Farm.teleportToPoint(name)
        local cf = savedPoints[name]
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if cf and hrp then hrp.CFrame = cf end
    end

    -- PlayerData/Placed helpers
    local function getPlacedRoot()
        local playerFolder = LocalPlayer
        if not playerFolder then return nil end
        local pd = playerFolder:FindFirstChild("PlayerData")
        if not pd then pd = playerFolder:FindFirstChildOfClass("Folder") end
        return pd and pd:FindFirstChild("Placed") or nil
    end

    local function hasCrypto(machine)
        local cryptoFolder = machine and machine:FindFirstChild("Crypto")
        if not cryptoFolder then return false end
        for _, child in ipairs(cryptoFolder:GetChildren()) do
            return true
        end
        return false
    end

    -- Claim pattern cache per machine
    -- stores a function that returns true/false when invoked
    local claimPattern = {}

    local function buildClaimAttempts(machine)
        local attempts = {}
        -- IndexKey value
        local idx = machine:FindFirstChild("IndexKey")
        if idx and idx.Value ~= nil then
            table.insert(attempts, function()
                local r = resolveEvent("ClaimCrypto"); if not r then return false end
                return pcall(function() r:FireServer(idx.Value) end) == true
            end)
        end
        -- GUID/string name
        table.insert(attempts, function()
            local r = resolveEvent("ClaimCrypto"); if not r then return false end
            return pcall(function() r:FireServer(machine.Name) end) == true
        end)
        -- model instance
        table.insert(attempts, function()
            local r = resolveEvent("ClaimCrypto"); if not r then return false end
            return pcall(function() r:FireServer(machine) end) == true
        end)
        -- basepart child
        local bp = machine:FindFirstChildWhichIsA("BasePart")
        if bp then
            table.insert(attempts, function()
                local r = resolveEvent("ClaimCrypto"); if not r then return false end
                return pcall(function() r:FireServer(bp) end) == true
            end)
        end
        -- no-arg fallback
        table.insert(attempts, function() return fireNoArg("ClaimCrypto") end)
        return attempts
    end

    -- Auto Collect via ClaimCrypto per machine that has crypto
    function Farm.startAutoCollect()
        Farm.stopAutoCollect()
        local scanAccum = 0
        collectConn = RunService.Heartbeat:Connect(function(dt)
            if not State.get("autoCollect") then return end
            scanAccum += dt
            if scanAccum < 0.6 then return end -- ~1.6x per second to reduce load
            scanAccum = 0

            local placed = getPlacedRoot(); if not placed then return end
            for _, machine in ipairs(placed:GetChildren()) do
                if hasCrypto(machine) then
                    local ok = false
                    local fn = claimPattern[machine]
                    if fn then
                        ok = fn()
                    else
                        for _, try in ipairs(buildClaimAttempts(machine)) do
                            if try() then
                                claimPattern[machine] = try
                                ok = true
                                break
                            end
                        end
                    end
                    task.wait(0.04)
                end
            end
        end)
    end

    function Farm.stopAutoCollect()
        if collectConn then collectConn:Disconnect(); collectConn = nil end
    end

    -- Auto Sell via Remote (cache first working variant)
    local sellPattern
    function Farm.startAutoSell()
        Farm.stopAutoSell()
        local accum = 0
        sellConn = RunService.Heartbeat:Connect(function(dt)
            if not State.get("autoSell") then return end
            accum += dt
            if accum < 0.8 then return end -- ~1.25x per second
            accum = 0

            if sellPattern then
                sellPattern(); return
            end
            local tried = {
                function() return fireNoArg("SellCrypto") end,
                function()
                    local r = resolveEvent("SellCrypto"); if not r then return false end
                    return pcall(function() r:FireServer("All") end) == true
                end,
                function()
                    local r = resolveEvent("SellCrypto"); if not r then return false end
                    return pcall(function() r:FireServer(true) end) == true
                end,
            }
            for _, f in ipairs(tried) do
                if f() then sellPattern = f; break end
            end
        end)
    end

    function Farm.stopAutoSell()
        if sellConn then sellConn:Disconnect(); sellConn = nil end
    end

    return Farm
end
