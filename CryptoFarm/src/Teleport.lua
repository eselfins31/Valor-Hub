return function(Services, State)
    local Teleport = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local UserInputService = Services.UserInputService

    local saved = {}
    local enabledClick = false
    local clickConn

    local function getRoot()
        local plr = Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        return char:FindFirstChild("HumanoidRootPart")
    end

    function Teleport.enableClickTp(on)
        enabledClick = on
        if clickConn then clickConn:Disconnect(); clickConn = nil end
        if on then
            clickConn = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 and enabledClick then
                    local cam = workspace.CurrentCamera
                    local mouse = UserInputService:GetMouseLocation()
                    local ray = cam:ViewportPointToRay(mouse.X, mouse.Y)
                    local raycast = workspace:Raycast(ray.Origin, ray.Direction * 1000)
                    local pos = raycast and raycast.Position or (ray.Origin + ray.Direction * 50)
                    local hrp = getRoot()
                    if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
                end
            end)
        end
    end

    function Teleport.savePoint(name)
        if type(name) ~= "string" or name == "" then return end
        local hrp = getRoot()
        if hrp then saved[name] = hrp.CFrame end
    end

    function Teleport.getSavedNames()
        local t = {}
        for k in pairs(saved) do table.insert(t, k) end
        table.sort(t)
        return t
    end

    function Teleport.teleportToSaved(name)
        local cf = saved[name]
        if cf then
            local hrp = getRoot()
            if hrp then hrp.CFrame = cf end
        end
    end

    return Teleport
end
