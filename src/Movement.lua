return function(Services, State)
    local Movement = {}

    local Players = Services.Players
    local UserInputService = Services.UserInputService

    local infiniteJumpConn
    local speedConn

    local function setWalkSpeed(value)
        local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end

    function Movement.startInfiniteJump()
        Movement.stopInfiniteJump()
        infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            if State.get("infiniteJump") then
                local char = Players.LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
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

    function Movement.startSpeed()
        Movement.stopSpeed()
        local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
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
    end

    return Movement
end 