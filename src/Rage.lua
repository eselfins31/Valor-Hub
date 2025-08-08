return function(Services, State)
    local Rage = {}

    local RunService = Services.RunService
    local UserInputService = Services.UserInputService

    local camera = workspace.CurrentCamera

    local fovCircle

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

    local function distToCursor(worldPos)
        local screenPoint = camera:WorldToScreenPoint(worldPos)
        local cursor = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        return (cursor - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
    end

    local function currentHumanoid()
        local plr = game:GetService("Players").LocalPlayer
        local char = plr.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    local function quickStop()
        if not State.get("rageQuickStop") then return end
        local hum = currentHumanoid()
        if hum then hum:Move(Vector3.new(), false) end
    end

    local function hitchanceOK(worldPos)
        local deg = State.get("rageHitchanceAngleDeg")
        local cursor = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        local screenPoint = Vector2.new(camera:WorldToScreenPoint(worldPos).X, camera:WorldToScreenPoint(worldPos).Y)
        local dx = (cursor - screenPoint).Magnitude
        return dx <= State.get("rageFovRadius") and dx <= deg * 8 -- empirical mapping
    end

    local function autoShoot()
        if not State.get("rageAutoShoot") then return end
        quickStop()
        pcall(function()
            mouse1press()
            task.wait()
            mouse1release()
        end)
    end

    local function triggerbot()
        if not State.get("rageTriggerbot") then return end
        pcall(function()
            mouse1press()
            task.wait()
            mouse1release()
        end)
    end

    function Rage.start()
        RunService:BindToRenderStep("ValorHub_Rage", Enum.RenderPriority.Camera.Value + 11, function()
            updateFov()
            -- targeting logic is left to SilentAim expansion and/or configured hitboxes
            -- here we only handle auto behaviors based on cursor within FOV (trigger) and hitchance
            if hitchanceOK(camera.CFrame.Position + camera.CFrame.LookVector * 1000) then
                if State.get("rageTriggerbot") then triggerbot() end
                if State.get("rageAutoShoot") then autoShoot() end
            end
        end)
    end

    function Rage.stop()
        RunService:UnbindFromRenderStep("ValorHub_Rage")
        if fovCircle then pcall(function() fovCircle:Remove() end) fovCircle = nil end
    end

    return Rage
end 