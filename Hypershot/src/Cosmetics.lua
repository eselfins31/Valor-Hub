return function(Services, State)
    local Cosmetics = {}

    local Players = Services.Players
    local RunService = Services.RunService

    local LocalPlayer = Players.LocalPlayer

    local running = false
    local renderConn
    local descConns = {}

    -- Track targeted parts and their originals to restore on stop
    local targetedParts = {}

    local function clearConnections()
        for inst, conn in pairs(descConns) do
            if conn then conn:Disconnect() end
            descConns[inst] = nil
        end
    end

    local function saveOriginal(part)
        if targetedParts[part] then return end
        targetedParts[part] = {
            Color = part.Color,
            Transparency = part.Transparency,
            Material = part.Material,
        }
    end

    local function restoreAll()
        for part, orig in pairs(targetedParts) do
            if part and part.Parent then
                pcall(function()
                    part.Color = orig.Color
                    part.Transparency = orig.Transparency
                    part.Material = orig.Material
                end)
            end
        end
        targetedParts = {}
    end

    local weaponNameHints = {
        "gun","weapon","pistol","rifle","smg","shotgun","sniper","knife","lmg","launcher","revolver","carbine",
        "viewmodel","vm","arms"
    }

    local function hasWeaponHint(name)
        if not name then return false end
        local lower = string.lower(name)
        for _, hint in ipairs(weaponNameHints) do
            if string.find(lower, hint, 1, true) then return true end
        end
        return false
    end

    local function isWeaponPart(part)
        if not part or not part:IsA("BasePart") then return false end
        -- Avoid affecting character body parts explicitly
        local lname = string.lower(part.Name)
        if lname == "head" or string.find(lname, "torso", 1, true) or string.find(lname, "leg", 1, true) or string.find(lname, "arm", 1, true) then
            -- Still allow if clearly within a weapon/tool hierarchy
            -- continue to hierarchy checks
        end
        local current = part
        local depth = 0
        while current and depth < 8 do
            if current:IsA("Tool") then return true end
            if hasWeaponHint(current.Name) then return true end
            current = current.Parent
            depth += 1
        end
        return false
    end

    local function tryTrackPart(inst)
        if not running then return end
        if inst and inst:IsA("BasePart") and isWeaponPart(inst) then
            saveOriginal(inst)
        end
    end

    local function watchContainer(container)
        if not container or descConns[container] then return end
        -- Track existing
        for _, d in ipairs(container:GetDescendants()) do
            tryTrackPart(d)
        end
        -- Watch future
        descConns[container] = container.DescendantAdded:Connect(function(d)
            tryTrackPart(d)
        end)
    end

    local function setupWatchers()
        clearConnections()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        local cam = workspace.CurrentCamera
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        watchContainer(char)
        if backpack then watchContainer(backpack) end
        if cam then watchContainer(cam) end
        if pg then watchContainer(pg) end
    end

    local hue = 0
    local function step()
        if not running then return end
        -- Cycle hue
        local speed = State.get("rainbowSkinsSpeed") or 1.5
        hue = (hue + (speed / 60)) % 1
        local col = Color3.fromHSV(hue, 1, 1)
        local trans = math.clamp(State.get("rainbowSkinsTransparency") or 0.3, 0, 0.9)
        for part, _ in pairs(targetedParts) do
            if part and part.Parent then
                pcall(function()
                    part.Color = col
                    part.Transparency = trans
                    -- Optional: make it glossy
                    part.Material = Enum.Material.SmoothPlastic
                end)
            end
        end
    end

    function Cosmetics.start()
        if running then return end
        running = true
        setupWatchers()
        if renderConn then renderConn:Disconnect() end
        renderConn = RunService.RenderStepped:Connect(step)
    end

    function Cosmetics.stop()
        if not running then return end
        running = false
        if renderConn then renderConn:Disconnect(); renderConn = nil end
        clearConnections()
        restoreAll()
    end

    function Cosmetics.refresh()
        if not running then return end
        setupWatchers()
    end

    return Cosmetics
end


