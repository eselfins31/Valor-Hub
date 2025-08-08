return function(Services, State)
    local FOV = {}
    local RunService = Services.RunService
    local UserInputService = Services.UserInputService

    local circle
    local started = false

    local function ensure()
        local ok = pcall(function() return Drawing end)
        if not ok then return nil end
        if not circle then
            circle = Drawing.new("Circle")
        end
        return circle
    end

    local function update()
        local c = ensure()
        if not c then return end
        local ok = pcall(function()
            c.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
            c.Radius = State.get("rageFovRadius")
            c.Color = State.get("rageFovColor")
            c.Visible = State.get("drawRageFov")
            c.NumSides = 64
            c.Filled = false
            c.Transparency = State.get("rageFovTransparency")
            c.Thickness = 0
        end)
        if not ok then return end
    end

    function FOV.start()
        if started then return end
        started = true
        RunService.RenderStepped:Connect(update)
    end

    function FOV.stop()
        started = false
        if circle then pcall(function() circle:Remove() end) circle = nil end
    end

    return FOV
end 