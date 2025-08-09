local State = {}

State.settings = {
    -- Visuals
    espEnabled = false,
    espShow = true,
    teamCheck = false,

    espMode = "Box",
    espShowNames = true,
    espShowHealth = true,
    espShowTracers = false,
    espUseTeamColor = true,
    espEnemyColor = Color3.fromRGB(255, 70, 70),
    espTeamColor = Color3.fromRGB(70, 170, 255),
    espThickness = 1.5,
    espTextSize = 13,
    espTracerOrigin = "Bottom",

    rageFovRadius = 250,
    drawRageFov = false,
    rageFovFilled = false,
    rageFovThickness = 2,
    rageFovColor = Color3.fromRGB(255, 255, 255),
    rageFovTransparency = 1,
    rageHitchanceAngleDeg = 6,
    rageAutoShoot = false,
    rageTriggerbot = false,
    rageQuickStop = false,
    rageHitbox = "Head",

    -- Movement
    infiniteJump = false,
    speedEnabled = false,
    walkSpeed = 100,
    noclipEnabled = false,
    flyEnabled = false,
    flySpeed = 60,
    airStrafeSpeed = 80,
    spiderEnabled = false,

    -- Farm
    clickTeleportEnabled = false,
    autoCollect = false,
    autoSell = false,

    -- HUD
    hudEnabled = true,

    ammoMod = false,
    fireRateMod = false,
    recoilMod = false,

    silentAim = false,
    silentAimSize = 13,

    bindEspToggle = "T",
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