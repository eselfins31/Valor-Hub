local State = {}

-- Shared toggles/settings used across modules
State.settings = {
    -- Visuals / ESP
    espEnabled = false,
    espShow = true, -- master show/hide
    teamCheck = true,

    -- ESP advanced
    espMode = "Box", -- Box | Corner
    espShowNames = true,
    espShowHealth = true,
    espShowTracers = false,
    espUseTeamColor = true,
    espEnemyColor = Color3.fromRGB(255, 70, 70),
    espTeamColor = Color3.fromRGB(70, 170, 255),
    espThickness = 1.5,
    espTextSize = 13,
    espTracerOrigin = "Bottom", -- Bottom | Center | Top

    -- Aimbot
    aimbotEnabled = false,
    aimPart = "Head",
    fovRadius = 55,
    drawFov = true,
    fovFilled = false,
    fovThickness = 2,
    fovColor = Color3.fromRGB(255, 255, 255),
    fovTransparency = 1,
    aimActivation = "Hold", -- Hold | Toggle
    aimKey = "MouseButton2", -- e.g. MouseButton2, Q, E
    aimSmoothing = 0.08, -- seconds for tween
    visibleCheck = true,
    targetPriority = "CursorProximity", -- CursorProximity | Distance
    maxDistance = 15000,

    -- Movement
    infiniteJump = false,
    speedEnabled = false,
    walkSpeed = 100,
    noclipEnabled = false,
    flyEnabled = false,
    flySpeed = 60,
    airStrafeSpeed = 80,

    -- Weapons
    ammoMod = false,
    fireRateMod = false,
    recoilMod = false,

    -- Silent aim (optional)
    silentAim = false,

    -- Keybinds (toggle features)
    bindEspToggle = "T",
    bindAimbotToggle = "V",
    bindInfJumpToggle = "J",
    bindSpeedToggle = "Z",
    bindNoclipToggle = "X",
    bindFlyToggle = "F",
    bindSilentAimToggle = "C",
    bindWeaponModsApply = "M",
}

function State.update(partial)
    for k, v in pairs(partial) do
        State.settings[k] = v
    end
end

function State.get(key)
    return State.settings[key]
end

return State 