-- =============================================================
-- DIFFICULTY: Boss Rush (Index 5)
-- Каждая волна — один или несколько боссов подряд.
-- Обычные враги не спавнятся.
--
-- ФОРМАТ WaveConfig:
--
--   [волна] = "Имя Босса"
--     → всегда этот конкретный босс
--
--   [волна] = { "Имя1", "Имя2", "Имя3" }
--     → случайный один из списка
--
--   [волна] = { sequence = { "Имя1", "Имя2" } }
--     → все боссы из списка по очереди (первый умер → следующий)
--
--   [волна] = { sequence = { "Имя1", "Имя2", "Имя3" }, count = 2 }
--     → случайные 2 из 3, потом по очереди
--
-- Волна 5 боссы : "Mutated Hulk", "Plague Berserker", "Plague Heavy",
--                 "Plague Demolition", "Hell Knight", "Xen Host Unit"
-- Волна 10 боссы: "Alpha Gonome", "Gamma Gonome", "Subject: Wallace Breen",
--                 "Xen Destroyer Unit", "Xen Psychic Unit", "Plague Platoon"
-- =============================================================

local WAVE5_BOSSES  = { "Mutated Hulk", "Plague Berserker", "Plague Heavy",
                         "Plague Demolition", "Hell Knight", "Xen Host Unit" }
local WAVE10_BOSSES = { "Alpha Gonome", "Gamma Gonome", "Subject: Wallace Breen",
                         "Xen Destroyer Unit", "Xen Psychic Unit", "Plague Platoon" }
local ALL_BOSSES    = {}
for _, v in ipairs(WAVE5_BOSSES)  do table.insert(ALL_BOSSES, v) end
for _, v in ipairs(WAVE10_BOSSES) do table.insert(ALL_BOSSES, v) end

-- ── Конфигурация волн ─────────────────────────────────────────
local WaveConfig = {
    [1]  = WAVE5_BOSSES,                                            -- случайный из ранних
    [2]  = WAVE5_BOSSES,
    [3]  = WAVE5_BOSSES,
    [4]  = ALL_BOSSES,                                              -- случайный из всех
    [5]  = "Mutated Hulk",                                          -- всегда этот
    [6]  = ALL_BOSSES,
    [7]  = ALL_BOSSES,
    [8]  = { sequence = { "Hell Knight", "Xen Host Unit" } },       -- два подряд
    [9]  = { sequence = WAVE10_BOSSES, count = 2 },                 -- 2 случайных из 6
    [10] = { sequence = { "Subject: Wallace Breen",
                          "Xen Destroyer Unit" } },                 -- финальный дуэт
}
local DEFAULT_WAVE = ALL_BOSSES

-- ── Shuffle ───────────────────────────────────────────────────
local function Shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- ── Разбор конфига волны → очередь боссов ────────────────────
local function ResolveBossQueue(config)
    if type(config) == "string" then
        return { config }
    elseif type(config) == "table" then
        if config.sequence then
            local pool = table.Copy(config.sequence)
            if config.count then
                Shuffle(pool)
                local result = {}
                for i = 1, math.min(config.count, #pool) do result[i] = pool[i] end
                return result
            end
            return table.Copy(pool)
        else
            -- обычный массив → случайный один
            return { config[math.random(#config)] }
        end
    end
    return { ALL_BOSSES[math.random(#ALL_BOSSES)] }
end

-- ── Регистрация босса для текущей волны в HORDE.bosses ────────
local function RegisterBossForWave(boss_name, wave_num, is_last)
    local ref_entry
    -- Ищем эталонную запись (волна 5, потом 10, потом любая)
    for _, try_wave in ipairs({ 5, 10, 1, 2, 3, 4, 6, 7, 8, 9 }) do
        if HORDE.bosses[boss_name .. try_wave] then
            ref_entry = HORDE.bosses[boss_name .. try_wave]
            break
        end
    end

    if not ref_entry then
        ErrorNoHaltWithStack("[BossRush] Unknown boss: '" .. tostring(boss_name) .. "'\n")
        return false
    end

    local entry = table.Copy(ref_entry)
    entry.boss_properties = table.Copy(ref_entry.boss_properties or {})
    entry.boss_properties.is_boss                = true
    entry.boss_properties.end_wave               = is_last   -- последний завершает волну
    entry.boss_properties.unlimited_enemies_spawn = false
    entry.boss_properties.enemies_spawn_threshold = 0        -- без обычных мобов

    HORDE.bosses[boss_name .. tostring(wave_num)] = entry
    return true
end

-- ──────────────────────────────────────────────────────────────

HORDE:RegisterDifficulty({
    Name  = "BOSS_RUSH",
    Index = 5,

    DamageMult              = 2.185,
    HealthMult              = 1.725,
    RewardMult              = 0.8,    -- боссы дают больше денег
    StartMoneyMult          = 1.0,
    EnemyCountMult          = 1.0,
    SpawnRadiusMult         = 0.4,
    MaxEnemiesScaleFactor   = 1.0,
    AdditionalPack          = 0,
    AdditionalAmmoboxes     = 2,
    StatusDurationBonus     = 3,
    BreakHealthLeft         = 0.04,
    ShockDamageIncrease     = 0.35,
    FrostbiteSlow           = 0.60,
    PoisonHeadcrabDamage    = 90,
    EliteHealthScaleAdd         = 0.145,
    EliteHealthScaleMultiplier  = 1.38,
    MutationProbability         = 0,
    EliteMutationProbability    = 0,

    Hooks = {

        -- Начало волны: строим очередь боссов для этой волны
        HordeWaveStart = function(wave)
            if HORDE.difficulty_text[HORDE.difficulty] ~= "BOSS_RUSH" then return end

            local wave_key = ((wave - 1) % 10) + 1
            local config   = WaveConfig[wave_key] or DEFAULT_WAVE
            local queue    = ResolveBossQueue(config)
            if #queue == 0 then queue = { ALL_BOSSES[math.random(#ALL_BOSSES)] } end

            -- Регистрируем все боссы волны
            local registered = {}
            for idx, boss_name in ipairs(queue) do
                if RegisterBossForWave(boss_name, wave, idx == #queue) then
                    table.insert(registered, boss_name)
                end
            end
            if #registered == 0 then return end

            HORDE.horde_boss_name = registered[1]

            HORDE._boss_rush_queue = {}
            for i = 2, #registered do
                table.insert(HORDE._boss_rush_queue, registered[i])
            end

            -- Вся волна = только боссы
            HORDE.total_enemies_this_wave       = 1
            HORDE.total_enemies_this_wave_fixed = 1

            HORDE:SendNotification(
                "BOSS RUSH — Wave " .. wave .. ": " .. table.concat(registered, " → "), 0
            )
        end,

        -- Смерть NPC: если очередь не пуста → ставим следующего босса
        OnNPCKilled = function(victim, killer, weapon)
            if HORDE.difficulty_text[HORDE.difficulty] ~= "BOSS_RUSH" then return end
            if not (HORDE._boss_rush_queue and #HORDE._boss_rush_queue > 0) then return end
            if not victim:GetVar("is_boss") then return end

            local next_boss = table.remove(HORDE._boss_rush_queue, 1)
            HORDE.horde_boss_name = next_boss

            -- Даём один слот чтобы SpawnBoss смог запустить следующего
            HORDE.total_enemies_this_wave       = HORDE.total_enemies_this_wave + 1
            HORDE.total_enemies_this_wave_fixed = HORDE.total_enemies_this_wave_fixed + 1

            HORDE:SendNotification("Next: " .. next_boss, 0)
        end,

        -- Конец волны: чистим состояние
        HordeWaveEnd = function(wave)
            if HORDE.difficulty_text[HORDE.difficulty] ~= "BOSS_RUSH" then return end
            HORDE._boss_rush_queue = {}
        end,
    },
})
