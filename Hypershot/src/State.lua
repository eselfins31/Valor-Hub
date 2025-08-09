local State = {}

-- Общие переключатели/настройки, используемые в разных модулях
State.settings = {
    -- Визуалы / ESP
    espEnabled = false,
    espShow = false, -- основное показать/скрыть
    teamCheck = false,

    -- Расширенные настройки ESP
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

    -- Rage (заменяет Aimbot)
    rageFovRadius = 250,
    drawRageFov = false,
    rageFovFilled = false,
    rageFovThickness = 2,
    rageFovColor = Color3.fromRGB(255, 255, 255),
    rageFovTransparency = 1,
    rageHitchanceAngleDeg = 6, -- меньше = строже
    rageAutoShoot = false,
    rageTriggerbot = false,
    rageQuickStop = false,
    rageHitbox = "Head", -- Head | HumanoidRootPart

    -- Движение
    infiniteJump = false,
    speedEnabled = false,
    walkSpeed = 100,
    noclipEnabled = false,
    flyEnabled = false,
    flySpeed = 60,
    airStrafeSpeed = 80,
    spiderEnabled = false,

    -- Оружие
    ammoMod = false,
    fireRateMod = false,
    recoilMod = false,

    -- Silent aim (расширение хитбокса)
    silentAim = false,
    silentAimSize = 13,

    -- HUD
    hudEnabled = true,

    -- Клавиши (переключение функций)
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