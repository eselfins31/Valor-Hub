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

    local function fireEvent(name, ...)
        local r = resolveEvent(name)
        if not r or not r:IsA("RemoteEvent") then return false end
        local ok = pcall(function(...) r:FireServer(...) end, ...)
        return ok == true
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

    -- Helpers to find computers owned by player
    local function isOwnedByPlayer(model)
        if model:GetAttribute("Owner") == LocalPlayer.Name then return true end
        local ownerTag = model:FindFirstChild("Owner")
        if ownerTag and ownerTag:IsA("StringValue") and ownerTag.Value == LocalPlayer.Name then return true end
        return false
    end

    local function findComputers()
        local results = {}
        for _, inst in ipairs(workspace:GetDescendants()) do
            if inst:IsA("Model") or inst:IsA("Folder") then
                local n = inst.Name:lower()
                if n:find("computer") or n:find("pc") then
                    table.insert(results, inst)
                end
            end
        end
        return results
    end

    -- Auto Collect via Remote (collect all from all computers)
    function Farm.startAutoCollect()
        Farm.stopAutoCollect()
        local accum = 0
        collectConn = RunService.Heartbeat:Connect(function(dt)
            if not State.get("autoCollect") then return end
            accum += dt
            if accum < 0.2 then return end -- 5x per second
            accum = 0
            -- attempt blanket collect (no args)
            fireEvent("ClaimCrypto")
            -- attempt per-computer collects
            for _, comp in ipairs(findComputers()) do
                if isOwnedByPlayer(comp) then
                    fireEvent("ClaimCrypto", comp)
                else
                    -- Some games require the top-level model or a child part
                    local candidate = comp:FindFirstChildWhichIsA("BasePart") or comp
                    fireEvent("ClaimCrypto", candidate)
                end
            end
        end)
    end

    function Farm.stopAutoCollect()
        if collectConn then collectConn:Disconnect(); collectConn = nil end
    end

    -- Auto Sell via Remote (sell everything)
    function Farm.startAutoSell()
        Farm.stopAutoSell()
        local accum = 0
        sellConn = RunService.Heartbeat:Connect(function(dt)
            if not State.get("autoSell") then return end
            accum += dt
            if accum < 0.4 then return end -- 2.5x per second
            accum = 0
            -- Common variants: no args, "All"
            fireEvent("SellCrypto")
            fireEvent("SellCrypto", "All")
        end)
    end

    function Farm.stopAutoSell()
        if sellConn then sellConn:Disconnect(); sellConn = nil end
    end

    return Farm
end
