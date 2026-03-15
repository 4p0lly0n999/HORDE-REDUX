-- =============================================================
-- HORDE GAMEMODE - core/registry.lua
-- Реестр — явный API для регистрации контента
-- =============================================================
-- ЭТОТ ФАЙЛ НЕ ТРОГАТЬ.
--
-- API:
--   HORDE:RegisterPerk(tbl)
--   HORDE:RegisterGadget(tbl)
--   HORDE:RegisterSpell(tbl)
--   HORDE:RegisterMutation(tbl)
--   HORDE:RegisterClass(tbl)
--   HORDE:RegisterSubclass(tbl)
--   HORDE:RegisterShopTab(tbl)
--   HORDE:RegisterDifficulty(tbl)
--   HORDE:RegisterSystem(tbl)
-- =============================================================

HORDE = HORDE or {}

-- ── Отложенная регистрация ────────────────────────────────────
-- Если Register* вызван до загрузки sh_perk.lua (например из
-- внешнего аддона, грузящегося в ненужный момент),
-- регистрация встаёт в очередь и выполняется после AllModulesLoaded.

local _deferred = {}
local function defer(fn, ...)
    local args = {...}
    table.insert(_deferred, function() fn(table.unpack(args)) end)
end

function HORDE:FlushDeferredRegistrations()
    local q = _deferred
    _deferred = {}
    for _, fn in ipairs(q) do
        local ok, err = pcall(fn)
        if not ok then
            ErrorNoHaltWithStack("[Horde Registry] Deferred registration failed: " .. tostring(err) .. "\n")
        end
    end
end

hook.Add("Horde_AllModulesLoaded", "Horde_FlushDeferred", function()
    if HORDE and HORDE.FlushDeferredRegistrations then
        HORDE:FlushDeferredRegistrations()
    end
end)

-- ── Регистрация перков ────────────────────────────────────────

function HORDE:RegisterPerk(tbl)
    if not tbl or type(tbl) ~= "table" then return end
    if tbl.Ignore then return end
    if not HORDE.perks then defer(self.RegisterPerk, self, tbl); return end

    local name = string.lower(tbl.ClassName or "")
    if name == "" then ErrorNoHaltWithStack("[Horde Registry] RegisterPerk: empty ClassName\n"); return end

    tbl.ClassName = name
    tbl.SortOrder = tbl.SortOrder or 0

    hook.Run("Horde_OnLoadPerk", tbl)

    if HORDE.perks[name] then
        -- Переопределение: удаляем старые хуки
        for k in pairs(HORDE.perks[name].Hooks or {}) do
            hook.Remove(k, "horde_perk_" .. name)
        end
        MsgC(Color(255, 255, 0), "[Horde Registry] Perk overridden: " .. name .. "\n")
    end

    HORDE.perks[name] = tbl

    for event, fn in pairs(tbl.Hooks or {}) do
        hook.Add(event, "horde_perk_" .. name, fn)
    end
end

-- ── Регистрация гаджетов ──────────────────────────────────────

function HORDE:RegisterGadget(tbl)
    if not tbl then return end
    if not HORDE.gadgets then defer(self.RegisterGadget, self, tbl); return end

    local name = string.lower(tbl.ClassName or "")
    if name == "" then ErrorNoHaltWithStack("[Horde Registry] RegisterGadget: empty ClassName\n"); return end

    tbl.ClassName = name

    if HORDE.gadgets[name] then
        for k in pairs(HORDE.gadgets[name].Hooks or {}) do
            hook.Remove(k, "horde_gadget_" .. name)
        end
        MsgC(Color(255, 255, 0), "[Horde Registry] Gadget overridden: " .. name .. "\n")
    end

    HORDE.gadgets[name] = tbl

    for event, fn in pairs(tbl.Hooks or {}) do
        hook.Add(event, "horde_gadget_" .. name, fn)
    end
end

-- ── Регистрация заклинаний ────────────────────────────────────

function HORDE:RegisterSpell(tbl)
    if not tbl then return end
    if not HORDE.spells then defer(self.RegisterSpell, self, tbl); return end

    local name = string.lower(tbl.ClassName or "")
    if name == "" then ErrorNoHaltWithStack("[Horde Registry] RegisterSpell: empty ClassName\n"); return end

    if HORDE.spells[name] then
        MsgC(Color(255, 255, 0), "[Horde Registry] Spell overridden: " .. name .. "\n")
    end
    HORDE.spells[name] = tbl
end

-- ── Регистрация мутаций ───────────────────────────────────────

function HORDE:RegisterMutation(tbl)
    if not tbl then return end
    if not HORDE.mutations then defer(self.RegisterMutation, self, tbl); return end

    local name = string.lower(tbl.ClassName or "")
    if name == "" then ErrorNoHaltWithStack("[Horde Registry] RegisterMutation: empty ClassName\n"); return end

    if HORDE.mutations[name] then
        for k in pairs(HORDE.mutations[name].Hooks or {}) do
            hook.Remove(k, "horde_mutation_" .. name)
        end
        MsgC(Color(255, 255, 0), "[Horde Registry] Mutation overridden: " .. name .. "\n")
    end

    HORDE.mutations[name] = tbl

    if not tbl.NoRand then
        HORDE.mutations_rand = HORDE.mutations_rand or {}
        HORDE.mutations_rand[name] = tbl
    end

    for event, fn in pairs(tbl.Hooks or {}) do
        hook.Add(event, "horde_mutation_" .. name, fn)
    end
end

-- ── Регистрация классов ───────────────────────────────────────

function HORDE:RegisterClass(tbl)
    if not tbl then return end
    if not HORDE.classes then defer(self.RegisterClass, self, tbl); return end

    HORDE:CreateClass(
        tbl.Name, tbl.ExtraDesc, tbl.MaxHP, tbl.MoveSpeed, tbl.SprintSpeed,
        tbl.BasePerk, tbl.Perks, tbl.Order, tbl.DisplayName,
        tbl.Model, tbl.Icon, tbl.Subclasses
    )
end

-- ── Регистрация подклассов ────────────────────────────────────

function HORDE:RegisterSubclass(tbl)
    if not tbl then return end
    if not HORDE.subclasses then defer(self.RegisterSubclass, self, tbl); return end

    local name = tbl.ClassName or tbl.PrintName
    if not name then ErrorNoHaltWithStack("[Horde Registry] RegisterSubclass: no name\n"); return end

    if HORDE.subclasses[name] then
        MsgC(Color(255, 255, 0), "[Horde Registry] Subclass overridden: " .. name .. "\n")
    end
    HORDE.subclasses[name] = tbl
end

-- ── Регистрация вкладки магазина ──────────────────────────────

HORDE._shop_tabs = HORDE._shop_tabs or {}

function HORDE:RegisterShopTab(tbl)
    if not tbl or not tbl.Name then return end
    tbl.Order = tbl.Order or 99
    table.insert(HORDE._shop_tabs, tbl)
    table.sort(HORDE._shop_tabs, function(a, b) return (a.Order or 99) < (b.Order or 99) end)
    hook.Run("Horde_OnShopTabRegistered", tbl)
end

-- ── Регистрация сложности ─────────────────────────────────────

HORDE._difficulties = HORDE._difficulties or {}

function HORDE:RegisterDifficulty(tbl)
    if not tbl or not tbl.Name or not tbl.Index then
        error("[Horde Registry] RegisterDifficulty: Name and Index required", 2)
        return
    end

    local i = tbl.Index  -- 1-based index into the difficulty arrays

    -- ── Displayed name list (used by UI and vote system) ──────
    HORDE.difficulty_text = HORDE.difficulty_text or {}
    HORDE.difficulty_text[i] = tbl.Name

    -- ── Wire into sv_difficulty.lua arrays ────────────────────
    -- These are the tables sv_difficulty.lua reads at runtime.
    -- We set them here so difficulty files don't need to touch sv_difficulty.lua.

    -- Damage & health
    if HORDE.difficulty_health_multiplier then
        HORDE.difficulty_health_multiplier[i] = tbl.HealthMult or 1
    end
    if HORDE.difficulty_reward_base_multiplier then
        HORDE.difficulty_reward_base_multiplier[i] = tbl.RewardMult or 1
    end

    -- Status effects
    if HORDE.difficulty_status_duration_bonus then
        HORDE.difficulty_status_duration_bonus[i] = tbl.StatusDurationBonus or 0
    end
    if HORDE.difficulty_break_health_left then
        HORDE.difficulty_break_health_left[i] = tbl.BreakHealthLeft or 0.20
    end
    if HORDE.difficulty_shock_damage_increase then
        HORDE.difficulty_shock_damage_increase[i] = tbl.ShockDamageIncrease or 0.15
    end
    if HORDE.difficulty_frostbite_slow then
        HORDE.difficulty_frostbite_slow[i] = tbl.FrostbiteSlow or 0.40
    end

    -- Elite scaling
    if HORDE.difficulty_elite_health_scale_add then
        HORDE.difficulty_elite_health_scale_add[i] = tbl.EliteHealthScaleAdd or 0.025
    end
    if HORDE.difficulty_elite_health_scale_multiplier then
        HORDE.difficulty_elite_health_scale_multiplier[i] = tbl.EliteHealthScaleMultiplier or 1.0
    end
    if HORDE.difficulty_additional_pack then
        HORDE.difficulty_additional_pack[i] = tbl.AdditionalPack or 0
    end
    if HORDE.difficulty_additional_ammoboxes then
        HORDE.difficulty_additional_ammoboxes[i] = tbl.AdditionalAmmoboxes or 0
    end

    -- Mutations
    if HORDE.difficulty_mutation_probability then
        HORDE.difficulty_mutation_probability[i] = tbl.MutationProbability or 0
    end
    if HORDE.difficulty_elite_mutation_probability then
        HORDE.difficulty_elite_mutation_probability[i] = tbl.EliteMutationProbability or 0
    end

    -- Store the full definition for external use (custom systems, UI, etc.)
    HORDE._difficulties[i] = tbl

    -- Store the local-variable arrays that sv_difficulty.lua uses but doesn't expose
    -- We store them on HORDE so sv_difficulty.lua can read them on demand
    HORDE._diff_damage_mult = HORDE._diff_damage_mult or {}
    HORDE._diff_damage_mult[i] = tbl.DamageMult or 1

    HORDE._diff_enemy_count_mult = HORDE._diff_enemy_count_mult or {}
    HORDE._diff_enemy_count_mult[i] = tbl.EnemyCountMult or 1

    HORDE._diff_start_money_mult = HORDE._diff_start_money_mult or {}
    HORDE._diff_start_money_mult[i] = tbl.StartMoneyMult or 1

    HORDE._diff_spawn_radius_mult = HORDE._diff_spawn_radius_mult or {}
    HORDE._diff_spawn_radius_mult[i] = tbl.SpawnRadiusMult or 1

    HORDE._diff_max_enemies_scale = HORDE._diff_max_enemies_scale or {}
    HORDE._diff_max_enemies_scale[i] = tbl.MaxEnemiesScaleFactor or 1

    HORDE._diff_poison_headcrab_dmg = HORDE._diff_poison_headcrab_dmg or {}
    HORDE._diff_poison_headcrab_dmg[i] = tbl.PoisonHeadcrabDamage or 50

    hook.Run("Horde_OnDifficultyRegistered", tbl)

    -- ── Difficulty hooks (same pattern as perks/gadgets) ──────────
    -- Hooks run only on SERVER (difficulty logic is server-side)
    if SERVER then
        for event, fn in pairs(tbl.Hooks or {}) do
            hook.Add(event, "horde_difficulty_" .. tbl.Name .. "_" .. event, fn)
        end
    end

    if GetConVar("developer"):GetBool() then
        print("[Horde Registry] Difficulty " .. i .. ": " .. tbl.Name)
    end
end

-- ── Регистрация системы ───────────────────────────────────────

HORDE._registered_systems = HORDE._registered_systems or {}

function HORDE:RegisterSystem(tbl)
    if not tbl or not tbl.Name then return end

    if tbl.Dependencies then
        for _, dep in ipairs(tbl.Dependencies) do
            if not HORDE._registered_systems[dep] then
                MsgC(Color(255, 100, 100),
                    "[Horde Registry] WARNING: System '" .. tbl.Name ..
                    "' requires '" .. dep .. "' which is not yet registered!\n")
            end
        end
    end

    HORDE._registered_systems[tbl.Name] = tbl

    if tbl.OnInit then
        local ok, err = pcall(tbl.OnInit)
        if not ok then
            ErrorNoHaltWithStack("[Horde Registry] System '" .. tbl.Name .. "' OnInit failed: " .. err .. "\n")
        end
    end

    print("[Horde Registry] System: " .. tbl.Name .. " v" .. (tbl.Version or "?"))
end

-- ── Псевдонимы для удобства ───────────────────────────────────

HORDE.AddPerk     = function(self, tbl) return self:RegisterPerk(tbl) end
HORDE.AddGadget   = function(self, tbl) return self:RegisterGadget(tbl) end
HORDE.AddSpell    = function(self, tbl) return self:RegisterSpell(tbl) end
HORDE.AddMutation = function(self, tbl) return self:RegisterMutation(tbl) end

-- ── Debug команда ─────────────────────────────────────────────

function HORDE:ListRegistered()
    print("\n=== HORDE Registered Content ===")
    print("Perks:      " .. table.Count(HORDE.perks or {}))
    print("Gadgets:    " .. table.Count(HORDE.gadgets or {}))
    print("Spells:     " .. table.Count(HORDE.spells or {}))
    print("Mutations:  " .. table.Count(HORDE.mutations or {}))
    print("Classes:    " .. table.Count(HORDE.classes or {}))
    print("Subclasses: " .. table.Count(HORDE.subclasses or {}))
    print("Systems:    " .. table.Count(HORDE._registered_systems or {}))
    print("================================\n")
end

if SERVER then
    concommand.Add("horde_list_registered", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end
        HORDE:ListRegistered()
    end)
end
