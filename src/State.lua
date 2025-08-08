local State = {}

-- Shared toggles/settings used across modules
State.settings = {
    -- Visuals / ESP
    espEnabled = false,
    espShow = true, -- show labels/boxes
    teamCheck = true,

    -- Aimbot
    aimbotEnabled = false,
    aimPart = "Head",
    fovRadius = 55,
    sensitivity = 0.03,
    drawFov = true,

    -- Movement
    infiniteJump = false,
    speedEnabled = false,
    walkSpeed = 100,

    -- Weapons
    ammoMod = false,
    fireRateMod = false,
    recoilMod = false,

    -- Silent aim (optional)
    silentAim = false,
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