return function(Services, State)
    local Rage = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local UserInputService = Services.UserInputService

    local camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    local fovCircle
    local started = false
    local lastShot = 0

    local function ensureFovCircle()
        local ok, DrawingLib = pcall(function() return Drawing end)
        if not ok or not DrawingLib then return nil end
        if not fovCircle then
            fovCircle = Drawing.new("Circle")
        end
        return fovCircle
    end

    local function updateFov()
        local circle = ensureFovCircle()
        if not circle then return end
        pcall(function()
            circle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
            circle.Radius = State.get("rageFovRadius")
            circle.Color = State.get("rageFovColor")
            circle.Visible = State.get("drawRageFov")
            circle.NumSides = 64
            circle.Filled = State.get("rageFovFilled")
            circle.Transparency = State.get("rageFovTransparency")
            circle.Thickness = State.get("rageFovThickness")
        end)
    end

    local function areTeammates(a, b)
        if a.Team and b.Team and a.Team == b.Team then return true end
        if a.TeamColor and b.TeamColor and a.TeamColor == b.TeamColor then return true end
        return false
    end

    local function isVisible(part)
        if not part then return false end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = { LocalPlayer.Character }
        local origin = camera.CFrame.Position
        local direction = (part.Position - origin)
        local hit = workspace:Raycast(origin, direction, params)
        if not hit then return true end
        return hit.Instance and hit.Instance:IsDescendantOf(part.Parent)
    end

    local function cursorDistance(worldPos)
        local screenPoint = camera:WorldToScreenPoint(worldPos)
        local cursor = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        return (cursor - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
    end

    local function getAimPart(character)
        if not character then return nil end
        local which = State.get("rageHitbox") or "Head"
        return character:FindFirstChild(which) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    end

    local function selectTarget()
        local best, bestDist
        local fov = State.get("rageFovRadius") or 250
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if not State.get("teamCheck") or not areTeammates(p, LocalPlayer) then
                    local char = p.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        local aim = getAimPart(char)
                        if hum and hum.Health > 0 and aim then
                            local dist = cursorDistance(aim.Position)
                            local visible = isVisible(aim)
                            if State.get("silentAim") then
                                visible = true -- allow through-wall targeting when Silent Aim enabled
                            end
                            if dist <= fov and visible then
                                if not best or dist < bestDist then
                                    best = aim
                                    bestDist = dist
                                end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    local function canShoot()
        return (tick() - lastShot) > 0.12
    end

    local function doClick()
        lastShot = tick()
        pcall(function()
            mouse1press(); task.wait(); mouse1release()
        end)
    end

    function Rage.start()
        if started then return end
        started = true
        RunService:BindToRenderStep("ValorHub_Rage", Enum.RenderPriority.Camera.Value + 11, function()
            updateFov()
            local targetPart = selectTarget()
            if targetPart and canShoot() then
                if State.get("rageTriggerbot") or State.get("rageAutoShoot") then
                    doClick()
                end
            end
        end)
    end

    function Rage.stop()
        if not started then return end
        started = false
        RunService:UnbindFromRenderStep("ValorHub_Rage")
        if fovCircle then pcall(function() fovCircle:Remove() end) fovCircle = nil end
    end

    return Rage
end 