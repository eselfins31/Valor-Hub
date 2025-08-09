local State = {}

State.settings = {
    espEnabled = false,
    espShow = false,
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

    infiniteJump = false,
    speedEnabled = false,
    walkSpeed = 100,
    noclipEnabled = false,
    flyEnabled = false,
    flySpeed = 60,
    airStrafeSpeed = 80,
    spiderEnabled = false,

    ammoMod = false,
    fireRateMod = false,
    recoilMod = false,

    silentAim = false,
    silentAimSize = 13,

    -- Rapid fire helper (clicks per second)
    rapidFireCPS = 14,

    hudEnabled = true,

    -- Cosmetics: Rainbow weapon skins
    rainbowSkins = false,
    rainbowSkinsTransparency = 0.3,
    rainbowSkinsSpeed = 1.5,

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