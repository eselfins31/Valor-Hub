return function(Services, State)
    local Aimbot = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local UserInputService = Services.UserInputService
    local TweenService = Services.TweenService

    local camera = workspace.CurrentCamera
    local localPlayer = Players.LocalPlayer

    local holding = false
    local fovCircle

    local function ensureFovCircle()
        if fovCircle then
            return fovCircle
        end
        local ok, DrawingLib = pcall(function()
            return Drawing
        end)
        if not ok or not DrawingLib then
            return nil
        end
        fovCircle = Drawing.new("Circle")
        return fovCircle
    end

    local function updateCircle()
        local circle = ensureFovCircle()
        if not circle then
            return
        end
        circle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        circle.Radius = State.get("fovRadius")
        circle.Color = Color3.fromRGB(255, 255, 255)
        circle.Visible = State.get("drawFov") and State.get("aimbotEnabled")
        circle.NumSides = 64
        circle.Filled = false
        circle.Transparency = State.get("aimbotEnabled") and 1 or 0
        circle.Thickness = 0
    end

    local function getClosestPlayerInFov()
        local target
        local maxDist = State.get("fovRadius")
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                if not State.get("teamCheck") or player.Team ~= localPlayer.Team then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                        local screenPoint = camera:WorldToScreenPoint(character.HumanoidRootPart.Position)
                        local cursor = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
                        local dist = (cursor - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                        if dist < maxDist then
                            target = player
                            maxDist = dist
                        end
                    end
                end
            end
        end
        return target
    end

    function Aimbot.start()
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                holding = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                holding = false
            end
        end)

        RunService:BindToRenderStep("ValorHub_Aimbot", Enum.RenderPriority.Camera.Value + 10, function()
            updateCircle()
            if holding and State.get("aimbotEnabled") then
                local target = getClosestPlayerInFov()
                if target and target.Character and target.Character:FindFirstChild(State.get("aimPart")) then
                    local aimPart = target.Character[State.get("aimPart")]
                    local tween = TweenService:Create(
                        camera,
                        TweenInfo.new(State.get("sensitivity"), Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        { CFrame = CFrame.new(camera.CFrame.Position, aimPart.Position) }
                    )
                    tween:Play()
                end
            end
        end)
    end

    function Aimbot.stop()
        RunService:UnbindFromRenderStep("ValorHub_Aimbot")
        if fovCircle then
            pcall(function()
                fovCircle:Remove()
            end)
            fovCircle = nil
        end
    end

    return Aimbot
end 