return function(Services, State)
    local SilentAim = {}

    local Players = Services.Players

    local running = false

    local function expandHitboxes()
        local me = Players.LocalPlayer
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= me and v.Character then
                local ch = v.Character
                local parts = {
                    "RightUpperLeg",
                    "LeftUpperLeg",
                    "HeadHB",
                    "HumanoidRootPart",
                }
                local size = State.get("silentAimSize")
                for _, name in ipairs(parts) do
                    local p = ch:FindFirstChild(name)
                    if p and p:IsA("BasePart") then
                        p.CanCollide = false
                        p.Transparency = 1
                        p.Size = Vector3.new(size, size, size)
                    end
                end
            end
        end
    end

    function SilentAim.start()
        if running then return end
        running = true
        task.spawn(function()
            while running do
                if State.get("silentAim") then
                    pcall(expandHitboxes)
                end
                task.wait(1)
            end
        end)
    end

    function SilentAim.stop()
        running = false
    end

    return SilentAim
end 