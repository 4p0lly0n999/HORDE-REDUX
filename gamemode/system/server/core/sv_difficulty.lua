-- =============================================================
-- sv_difficulty.lua — полностью данные-ориентированная версия
-- Все значения читаются из HORDE._difficulties[index]
-- который заполняется файлами из modules/difficulties/
-- =============================================================

HORDE.difficulty = GetConVar("horde_difficulty"):GetInt() + 1  -- 1-based
HORDE.additional_pack = 0

-- ── Запасные дефолтные значения (если нет difficulty-файлов) ──
local DEFAULTS = {
    [1] = { Name="CASUAL",     DamageMult=1.0,   HealthMult=1.0,   RewardMult=1.0,  EnemyCountMult=1.0,   StartMoneyMult=1.0,  SpawnRadiusMult=1.0,  MaxEnemiesScaleFactor=1.0,   PoisonHeadcrabDamage=50, StatusDurationBonus=0, BreakHealthLeft=0.20, ShockDamageIncrease=0.15, FrostbiteSlow=0.40, EliteHealthScaleAdd=0.025, EliteHealthScaleMultiplier=1.0, AdditionalPack=0, AdditionalAmmoboxes=2, MutationProbability=0,    EliteMutationProbability=0    },
    [2] = { Name="NIGHTMARE",  DamageMult=1.7,   HealthMult=1.5,   RewardMult=0.5,  EnemyCountMult=1.6,   StartMoneyMult=0.75, SpawnRadiusMult=0.5,  MaxEnemiesScaleFactor=1.25,  PoisonHeadcrabDamage=75, StatusDurationBonus=3, BreakHealthLeft=0.10, ShockDamageIncrease=0.25, FrostbiteSlow=0.50, EliteHealthScaleAdd=0.100, EliteHealthScaleMultiplier=1.1, AdditionalPack=2, AdditionalAmmoboxes=0, MutationProbability=0.20, EliteMutationProbability=0.30 },
    [3] = { Name="APOCALYPSE", DamageMult=1.9,   HealthMult=1.5,   RewardMult=0.4,  EnemyCountMult=1.7,   StartMoneyMult=0.6,  SpawnRadiusMult=0.4,  MaxEnemiesScaleFactor=1.3,   PoisonHeadcrabDamage=75, StatusDurationBonus=4, BreakHealthLeft=0.05, ShockDamageIncrease=0.30, FrostbiteSlow=0.55, EliteHealthScaleAdd=0.125, EliteHealthScaleMultiplier=1.2, AdditionalPack=3, AdditionalAmmoboxes=0, MutationProbability=0.30, EliteMutationProbability=0.40 },
    [4] = { Name="CHAOS",      DamageMult=2.185, HealthMult=1.725, RewardMult=0.46, EnemyCountMult=1.955, StartMoneyMult=0.69, SpawnRadiusMult=0.46, MaxEnemiesScaleFactor=1.495, PoisonHeadcrabDamage=90, StatusDurationBonus=5, BreakHealthLeft=0.04, ShockDamageIncrease=0.35, FrostbiteSlow=0.60, EliteHealthScaleAdd=0.145, EliteHealthScaleMultiplier=1.38, AdditionalPack=4, AdditionalAmmoboxes=0, MutationProbability=0.45, EliteMutationProbability=0.55 },
    [5] = { Name="BOSS_RUSH",  DamageMult=2.185, HealthMult=1.725, RewardMult=0.46, EnemyCountMult=1.955, StartMoneyMult=0.69, SpawnRadiusMult=0.46, MaxEnemiesScaleFactor=1.495, PoisonHeadcrabDamage=90, StatusDurationBonus=5, BreakHealthLeft=0.04, ShockDamageIncrease=0.35, FrostbiteSlow=0.60, EliteHealthScaleAdd=0.145, EliteHealthScaleMultiplier=1.38, AdditionalPack=4, AdditionalAmmoboxes=0, MutationProbability=0.45, EliteMutationProbability=0.55 },
    [6] = { Name="TOWDEF",     DamageMult=2.185, HealthMult=1.725, RewardMult=0.46, EnemyCountMult=1.955, StartMoneyMult=0.69, SpawnRadiusMult=0.46, MaxEnemiesScaleFactor=1.495, PoisonHeadcrabDamage=90, StatusDurationBonus=5, BreakHealthLeft=0.04, ShockDamageIncrease=0.35, FrostbiteSlow=0.60, EliteHealthScaleAdd=0.145, EliteHealthScaleMultiplier=1.38, AdditionalPack=4, AdditionalAmmoboxes=0, MutationProbability=0.45, EliteMutationProbability=0.55 },
    [7] = { Name="HUNDRED",    DamageMult=1.9,   HealthMult=1.5,   RewardMult=0.4,  EnemyCountMult=1.7,   StartMoneyMult=0.6,  SpawnRadiusMult=0.4,  MaxEnemiesScaleFactor=1.3,   PoisonHeadcrabDamage=75, StatusDurationBonus=4, BreakHealthLeft=0.05, ShockDamageIncrease=0.30, FrostbiteSlow=0.55, EliteHealthScaleAdd=0.125, EliteHealthScaleMultiplier=1.2, AdditionalPack=3, AdditionalAmmoboxes=0, MutationProbability=0.30, EliteMutationProbability=0.40, IsHundred=true, MaxWaves=100, ScalePerWave=0.10 },
}

-- Получить данные сложности по индексу (приоритет: файлы > дефолты)
local function GetDiffData(index)
    return (HORDE._difficulties and HORDE._difficulties[index])
        or DEFAULTS[index]
        or DEFAULTS[1]
end

-- ── Публичные таблицы (читаются другими системами) ────────────────────────
HORDE.difficulty_health_multiplier             = {}
HORDE.difficulty_reward_base_multiplier        = {}
HORDE.difficulty_status_duration_bonus         = {}
HORDE.difficulty_break_health_left             = {}
HORDE.difficulty_shock_damage_increase         = {}
HORDE.difficulty_frostbite_slow                = {}
HORDE.difficulty_elite_health_scale_add        = {}
HORDE.difficulty_elite_health_scale_multiplier = {}
HORDE.difficulty_additional_pack               = {}
HORDE.difficulty_additional_ammoboxes          = {}
HORDE.difficulty_mutation_probability          = {}
HORDE.difficulty_elite_mutation_probability    = {}
HORDE.difficulty_text                          = {}

-- Заполняем дефолтами немедленно (файлы перезапишут позже)
for i, d in pairs(DEFAULTS) do
    HORDE.difficulty_health_multiplier[i]              = d.HealthMult
    HORDE.difficulty_reward_base_multiplier[i]         = d.RewardMult
    HORDE.difficulty_status_duration_bonus[i]          = d.StatusDurationBonus
    HORDE.difficulty_break_health_left[i]              = d.BreakHealthLeft
    HORDE.difficulty_shock_damage_increase[i]          = d.ShockDamageIncrease
    HORDE.difficulty_frostbite_slow[i]                 = d.FrostbiteSlow
    HORDE.difficulty_elite_health_scale_add[i]         = d.EliteHealthScaleAdd
    HORDE.difficulty_elite_health_scale_multiplier[i]  = d.EliteHealthScaleMultiplier
    HORDE.difficulty_additional_pack[i]                = d.AdditionalPack
    HORDE.difficulty_additional_ammoboxes[i]           = d.AdditionalAmmoboxes
    HORDE.difficulty_mutation_probability[i]           = d.MutationProbability
    HORDE.difficulty_elite_mutation_probability[i]     = d.EliteMutationProbability
    HORDE.difficulty_text[i]                           = d.Name
end

-- Endless
HORDE.endless_health_multiplier = 1
HORDE.endless_damage_multiplier = 1

-- ── Применить выбранную сложность к игровым переменным ────────────────────
-- Вызывается из Horde_AllModulesLoaded — к этому моменту все файлы загружены
local function ApplyDifficulty()
    local idx = HORDE.difficulty

    -- Обновляем публичные таблицы из загруженных файлов (для всех индексов)
    local max_idx = 0
    for i, _ in pairs(HORDE._difficulties or {}) do
        if i > max_idx then max_idx = i end
    end
    for i, _ in pairs(DEFAULTS) do
        if i > max_idx then max_idx = i end
    end

    for i = 1, max_idx do
        local di = GetDiffData(i)
        HORDE.difficulty_health_multiplier[i]              = di.HealthMult
        HORDE.difficulty_reward_base_multiplier[i]         = di.RewardMult
        HORDE.difficulty_status_duration_bonus[i]          = di.StatusDurationBonus
        HORDE.difficulty_break_health_left[i]              = di.BreakHealthLeft
        HORDE.difficulty_shock_damage_increase[i]          = di.ShockDamageIncrease
        HORDE.difficulty_frostbite_slow[i]                 = di.FrostbiteSlow
        HORDE.difficulty_elite_health_scale_add[i]         = di.EliteHealthScaleAdd
        HORDE.difficulty_elite_health_scale_multiplier[i]  = di.EliteHealthScaleMultiplier
        HORDE.difficulty_additional_pack[i]                = di.AdditionalPack
        HORDE.difficulty_additional_ammoboxes[i]           = di.AdditionalAmmoboxes
        HORDE.difficulty_mutation_probability[i]           = di.MutationProbability
        HORDE.difficulty_elite_mutation_probability[i]     = di.EliteMutationProbability
        HORDE.difficulty_text[i]                           = di.Name
    end

    local d = GetDiffData(idx)

    -- Сохраняем оригиналы перед масштабированием (чтобы можно было пересчитать)
    HORDE._orig_total_enemies_per_wave = HORDE._orig_total_enemies_per_wave or {}
    if #HORDE._orig_total_enemies_per_wave == 0 then
        for i, v in ipairs(HORDE.total_enemies_per_wave) do
            HORDE._orig_total_enemies_per_wave[i] = v
        end
    end
    HORDE._orig_kill_reward_base  = HORDE._orig_kill_reward_base  or HORDE.kill_reward_base
    HORDE._orig_round_bonus_base  = HORDE._orig_round_bonus_base  or HORDE.round_bonus_base
    HORDE._orig_start_money       = HORDE._orig_start_money       or HORDE.start_money
    HORDE._orig_spawn_radius      = HORDE._orig_spawn_radius      or HORDE.spawn_radius

    -- Применяем
    for i, v in ipairs(HORDE._orig_total_enemies_per_wave) do
        HORDE.total_enemies_per_wave[i] = math.floor(v * d.EnemyCountMult)
    end
    HORDE.kill_reward_base  = math.floor(HORDE._orig_kill_reward_base * d.RewardMult)
    HORDE.round_bonus_base  = math.floor(HORDE._orig_round_bonus_base * d.RewardMult)
    HORDE.start_money       = math.floor(HORDE._orig_start_money      * d.StartMoneyMult)
    HORDE.spawn_radius      = math.floor(HORDE._orig_spawn_radius     * d.SpawnRadiusMult)
    HORDE.difficulty_max_enemies_alive_scale_factor = d.MaxEnemiesScaleFactor

    -- HUNDRED: расширяем max_waves до 100
    if d.IsHundred then
        HORDE.max_waves = d.MaxWaves or 100
        HORDE.hundred_scale_per_wave = d.ScalePerWave or 0.10
        HORDE.hundred_mode = true
    else
        HORDE.max_waves = math.min(HORDE.max_max_waves, math.max(1, GetConVarNumber("horde_max_wave")))
        HORDE.hundred_mode = false
        HORDE.hundred_scale_per_wave = 0
    end

    -- Убираем endless (заменён на HUNDRED)
    HORDE.endless = 0

    print(string.format("[Horde Difficulty] %s (idx %d) | dmg×%.2f hp×%.2f reward×%.2f enemies×%.2f",
        d.Name, idx, d.DamageMult, d.HealthMult, d.RewardMult, d.EnemyCountMult))
end

hook.Add("Horde_AllModulesLoaded", "Horde_ApplyDifficulty", function()
    ApplyDifficulty()
end)

-- =============================================================
-- DAMAGE HOOK — читает GetDiffData() динамически каждый вызов
-- =============================================================
function VJ_DestroyCombineTurret() end

hook.Add("EntityTakeDamage", "Horde_EntityTakeDamage", function(target, dmg)
    if not target:IsValid() then return end
    local diff = GetDiffData(HORDE.difficulty)

    if target:IsPlayer() then
        if dmg:GetAttacker():IsNPC() then
            if dmg:GetAttacker():GetNWEntity("HordeOwner"):IsPlayer() then return true end
            if dmg:IsDamageType(DMG_CRUSH) then
                dmg:SetDamage(math.min(dmg:GetDamage(), 20))
            end
            local hundred_dmg = (HORDE.hundred_mode and HORDE.current_wave > HORDE.max_max_waves)
                and (1 + HORDE.hundred_scale_per_wave * (HORDE.current_wave - HORDE.max_max_waves)) or 1
            local scale = diff.DamageMult * hundred_dmg
            dmg:ScaleDamage(scale)
            if dmg:GetAttacker():GetVar("damage_scale") then
                dmg:ScaleDamage(dmg:GetAttacker():GetVar("damage_scale"))
            end
        elseif dmg:GetAttacker():IsPlayer() and dmg:GetAttacker() ~= target then
            return true
        elseif dmg:IsDamageType(DMG_CRUSH) then
            dmg:SetDamage(math.min(dmg:GetDamage(), 20))
        end

    elseif HORDE:IsPlayerMinion(target) then
        if dmg:GetAttacker():IsPlayer() or HORDE:IsPlayerMinion(dmg:GetAttacker()) then
            return true
        else
            if dmg:GetAttacker():GetClass() == "npc_headcrab_poison" then
                dmg:SetDamage(math.min(dmg:GetDamage(), diff.PoisonHeadcrabDamage))
            end
            if target:GetClass() == "npc_turret_floor" then
                dmg:SetDamageForce(Vector(0, 0, 0))
                target:SetHealth(target:Health() - dmg:GetDamage())
                if target:Health() <= 0 then target:Fire("selfdestruct") end
            end
            local hundred_dmg = (HORDE.hundred_mode and HORDE.current_wave > HORDE.max_max_waves)
                and (1 + HORDE.hundred_scale_per_wave * (HORDE.current_wave - HORDE.max_max_waves)) or 1
            local scale = diff.DamageMult * hundred_dmg
            dmg:ScaleDamage(scale)
            if dmg:GetAttacker():GetVar("damage_scale") then
                dmg:ScaleDamage(dmg:GetAttacker():GetVar("damage_scale"))
            end
        end

    elseif target:IsNPC() then
        if not dmg:GetAttacker():IsNPC() then return end
        if target:GetClass() == dmg:GetAttacker() and dmg:GetAttacker() == dmg:GetInflictor() then return true end
        if dmg:IsDamageType(DMG_POISON) and dmg:GetAttacker():GetClass() == "npc_headcrab_poison" then
            dmg:SetDamage(0)
        elseif dmg:IsDamageType(DMG_SHOCK) or dmg:IsDamageType(DMG_REMOVENORAGDOLL) then
            local c = dmg:GetAttacker():GetClass()
            if c == "npc_vj_horde_screecher" or c == "npc_vj_horde_weeper" then dmg:SetDamage(0) end
        end
    end
end)

-- =============================================================
-- FALL DAMAGE — Index 1=Normal(flat), 2=Hard(half), 3+=реалистичный
-- =============================================================
hook.Add("GetFallDamage", "RealisticDamage", function(ply, speed)
    local bonus = { less = 1 }
    local dmg   = 0
    local idx   = HORDE.difficulty

    if idx == 1 then
        dmg = 10
    elseif idx == 2 then
        dmg = math.max(0, math.ceil(0.2418 * speed - 141.75)) / 2
    else
        dmg = math.max(0, math.ceil(0.2418 * speed - 141.75))
    end

    hook.Run("Horde_GetFallDamage", ply, speed, bonus)
    return dmg * bonus.less
end)
