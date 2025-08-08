return function(Services, State)
    local Movement = {}

    local Players = Services.Players
    local RunService = Services.RunService
    local UserInputService = Services.UserInputService

    local infiniteJumpConn
    local speedConn
    local originalWalkSpeed

    local noclipConn
    local flyConn
    local flyBodyVel
    local flyBodyGyro

    local keysDown = {}

    local function getCharacter()
        return Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    end

    local function getHumanoid()
        local char = getCharacter()
        return char:FindFirstChildOfClass("Humanoid")
    end

    local function getRoot()
        local char = getCharacter()
        return char:FindFirstChild("HumanoidRootPart")
    end

    local function setWalkSpeed(value)
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end

    function Movement.applySpeed(value)
        if State.get("speedEnabled") then
            setWalkSpeed(value or State.get("walkSpeed"))
        end
    end

    -- Infinite Jump
    function Movement.startInfiniteJump()
        Movement.stopInfiniteJump()
        infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            if State.get("infiniteJump") then
                local humanoid = getHumanoid()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end

    function Movement.stopInfiniteJump()
        if infiniteJumpConn then
            infiniteJumpConn:Disconnect()
            infiniteJumpConn = nil
        end
    end

    -- Speed Hack
    function Movement.startSpeed()
        Movement.stopSpeed()
        local humanoid = getHumanoid()
        if humanoid then
            if originalWalkSpeed == nil then
                originalWalkSpeed = humanoid.WalkSpeed
            end
            setWalkSpeed(State.get("walkSpeed"))
            speedConn = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if State.get("speedEnabled") then
                    setWalkSpeed(State.get("walkSpeed"))
                end
            end)
        end
    end

    function Movement.stopSpeed()
        if speedConn then
            speedConn:Disconnect()
            speedConn = nil
        end
        if originalWalkSpeed ~= nil then
            setWalkSpeed(originalWalkSpeed)
            originalWalkSpeed = nil
        end
    end

    -- NOCLIP (while keeping ground)
    local function isNearGround(hrp)
        local origin = hrp.Position
        local dir = Vector3.new(0, -6, 0)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = { getCharacter() }
        params.FilterType = Enum.RaycastFilterType.Blacklist
        local res = workspace:Raycast(origin, dir, params)
        return res ~= nil
    end

    function Movement.startNoclip()
        Movement.stopNoclip()
        noclipConn = RunService.Stepped:Connect(function()
            if not State.get("noclipEnabled") then return end
            local char = getCharacter()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            -- Keep ground collision by enabling root collision if falling without ground beneath
            local hrp = getRoot()
            if hrp then
                local onGround = isNearGround(hrp)
                hrp.CanCollide = not onGround and true or false
            end
        end)
    end

    function Movement.stopNoclip()
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
        -- restore default collisions on character parts
        local char = Players.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end

    -- FLY
    local function updateKeys(input, down)
        if input.KeyCode == Enum.KeyCode.W then keysDown.W = down end
        if input.KeyCode == Enum.KeyCode.A then keysDown.A = down end
        if input.KeyCode == Enum.KeyCode.S then keysDown.S = down end
        if input.KeyCode == Enum.KeyCode.D then keysDown.D = down end
        if input.KeyCode == Enum.KeyCode.Space then keysDown.Space = down end
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then keysDown.Shift = down end
    end

    function Movement.startFly()
        Movement.stopFly()
        local hrp = getRoot()
        if not hrp then return end

        local humanoid = getHumanoid()
        if humanoid then
            humanoid.PlatformStand = true
        end

        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyVel.Velocity = Vector3.zero
        flyBodyVel.Parent = hrp

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyGyro.P = 9e4
        flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
        flyBodyGyro.Parent = hrp

        local function stepFly()
            local cam = workspace.CurrentCamera
            local cf = cam.CFrame
            local moveDir = Vector3.zero
            local speed = State.get("flySpeed")
            if keysDown.W then moveDir += cf.LookVector end
            if keysDown.S then moveDir -= cf.LookVector end
            if keysDown.A then moveDir -= cf.RightVector end
            if keysDown.D then moveDir += cf.RightVector end
            if keysDown.Space then moveDir += Vector3.new(0, 1, 0) end
            if keysDown.Shift then moveDir -= Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * speed
            end

            flyBodyVel.Velocity = moveDir
            flyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + cf.LookVector)
        end

        flyConn = RunService.RenderStepped:Connect(function()
            if not State.get("flyEnabled") then return end
            stepFly()
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            updateKeys(input, true)
        end)
        UserInputService.InputEnded:Connect(function(input)
            updateKeys(input, false)
        end)
    end

    function Movement.stopFly()
        if flyConn then flyConn:Disconnect() flyConn = nil end
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        keysDown = {}
    end

    return Movement
end 