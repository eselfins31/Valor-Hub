return function(Services, State)
    local Aimbot = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local UserInputService = Services.UserInputService
    local TweenService = Services.TweenService

    local camera = workspace.CurrentCamera
    local localPlayer = Players.LocalPlayer

    local activationHeld = false
    local activationToggled = false
    local fovCircle

    local function toEnumKey(str)
        if str == "MouseButton2" then return Enum.UserInputType.MouseButton2 end
        local ok, enum = pcall(function() return Enum.KeyCode[str] end)
        if ok and enum then return enum end
        return Enum.KeyCode.RightBracket -- fallback
    end

    local function ensureFovCircle()
        local ok, DrawingLib = pcall(function() return Drawing end)
        if not ok or not DrawingLib then
            return nil
        end
        if not fovCircle then
            fovCircle = Drawing.new("Circle")
        end
        return fovCircle
    end

    local function updateCircle()
        local circle = ensureFovCircle()
        if not circle then return end
        circle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        circle.Radius = State.get("fovRadius")
        circle.Color = State.get("fovColor")
        circle.Visible = State.get("drawFov") and State.get("aimbotEnabled")
        circle.NumSides = 64
        circle.Filled = State.get("fovFilled")
        circle.Transparency = State.get("fovTransparency")
        circle.Thickness = State.get("fovThickness")
    end

    local function isVisible(hrp)
        if not State.get("visibleCheck") then return true end
        local origin = camera.CFrame.Position
        local direction = (hrp.Position - origin)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = { localPlayer.Character }
        params.FilterType = Enum.RaycastFilterType.Blacklist
        local result = workspace:Raycast(origin, direction, params)
        return (not result) or (result.Instance and result.Instance:IsDescendantOf(hrp.Parent))
    end

    local function distToCursor(worldPos)
        local screenPoint = camera:WorldToScreenPoint(worldPos)
        local cursor = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        return (cursor - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
    end

    local function getCandidates()
        local list = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                if not State.get("teamCheck") or player.Team ~= localPlayer.Team then
                    local character = player.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        local aimPart = character:FindFirstChild(State.get("aimPart"))
                        if humanoid and humanoid.Health > 0 and hrp and aimPart then
                            if isVisible(hrp) then
                                local distance = (camera.CFrame.Position - hrp.Position).Magnitude
                                if distance <= State.get("maxDistance") then
                                    table.insert(list, { player = player, character = character, hrp = hrp, aimPart = aimPart })
                                end
                            end
                        end
                    end
                end
            end
        end
        return list
    end

    local function pickTarget(candidates)
        local mode = State.get("targetPriority")
        local best, bestScore
        local fov = State.get("fovRadius")
        for _, c in ipairs(candidates) do
            local score
            if mode == "Distance" then
                score = (camera.CFrame.Position - c.hrp.Position).Magnitude
            else
                score = distToCursor(c.hrp.Position)
            end
            if score <= fov then
                if best == nil or score < bestScore then
                    best = c
                    bestScore = score
                end
            end
        end
        return best
    end

    local function aimAt(target)
        local smooth = State.get("aimSmoothing")
        local cf = CFrame.new(camera.CFrame.Position, target.aimPart.Position)
        if smooth > 0 then
            local tween = TweenService:Create(camera, TweenInfo.new(smooth, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = cf })
            tween:Play()
        else
            camera.CFrame = cf
        end
    end

    local function isActivated()
        local mode = State.get("aimActivation")
        if mode == "Hold" then
            return activationHeld
        else
            return activationToggled
        end
    end

    function Aimbot.start()
        -- input
        local key = toEnumKey(State.get("aimKey"))
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.MouseButton2 and key == Enum.UserInputType.MouseButton2 then
                activationHeld = true
            elseif input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == key then
                activationHeld = true
                if State.get("aimActivation") == "Toggle" then
                    activationToggled = not activationToggled
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 and key == Enum.UserInputType.MouseButton2 then
                activationHeld = false
            elseif input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == key then
                activationHeld = false
            end
        end)

        RunService:BindToRenderStep("ValorHub_Aimbot", Enum.RenderPriority.Camera.Value + 10, function()
            updateCircle()
            if not State.get("aimbotEnabled") then return end
            if not isActivated() then return end

            local candidates = getCandidates()
            local target = pickTarget(candidates)
            if target then
                aimAt(target)
            end
        end)
    end

    function Aimbot.stop()
        RunService:UnbindFromRenderStep("ValorHub_Aimbot")
        if fovCircle then pcall(function() fovCircle:Remove() end) fovCircle = nil end
        activationHeld = false
        activationToggled = false
    end

    return Aimbot
end 