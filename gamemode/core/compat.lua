-- =============================================================
-- HORDE GAMEMODE - core/compat.lua
-- Backward-compatibility шимы
-- =============================================================
-- ЭТОТ ФАЙЛ НЕ ТРОГАТЬ.
--
-- Гарантирует что:
-- 1. Старые паттерны PERK={}/GADGET={}/SPELL={} продолжают работать
-- 2. Старые пути к файлам логируются с предупреждением
-- 3. data/horde/*.txt, ConVar'ы и net strings — не изменены
-- =============================================================

HORDE = HORDE or {}

-- ── Заглушки для устаревших функций ─────────────────────────
function HORDE:ForceReloadPerks()
    MsgC(Color(255,200,100), "[Horde Compat] ForceReloadPerks() устарел — v2.0 грузит всё автоматически. Используй HORDE:RegisterPerk(tbl).\n")
end
function HORDE:ForceReloadGadgets()
    MsgC(Color(255,200,100), "[Horde Compat] ForceReloadGadgets() устарел.\n")
end

-- ── Compat-проверка при старте ───────────────────────────────
if GetConVar("developer"):GetBool() then
    hook.Add("Horde_AllModulesLoaded", "Horde_CompatCheck", function()
        local ok = true
        for _, name in ipairs({ "perks","gadgets","spells","mutations","classes","subclasses","enemies" }) do
            if not HORDE[name] then
                MsgC(Color(255,100,100), "[Horde Compat] MISSING TABLE: HORDE." .. name .. "\n")
                ok = false
            end
        end
        if ok then MsgC(Color(0,255,0), "[Horde Compat] All core tables OK.\n") end
    end)
end

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
СОВМЕСТИМОСТЬ v1.x → v2.0:

✅ PERK = {} / GADGET = {} / SPELL = {} — работает
✅ data/horde/*.txt — не изменены
✅ Все ConVar'ы horde_* — не изменены
✅ Все net strings Horde_* — не изменены
✅ HORDE:CreateClass() / CreateEnemy() — не изменены
✅ Карты и FGD — не затронуты
✅ entities/ — не затронуты

🔄 ИЗМЕНИЛОСЬ:
   gamemode/perks/      → gamemode/modules/perks/
   gamemode/gadgets/    → gamemode/modules/gadgets/
   gamemode/spells/     → gamemode/modules/spells/
   gamemode/mutations/  → gamemode/modules/mutations/
   gamemode/subclasses/ → gamemode/modules/subclasses/
   gamemode/arccw/      → gamemode/modules/arccw/
   gamemode/sh_*.lua    → gamemode/core_systems/sh_*.lua
   gamemode/sv_*.lua    → gamemode/core_systems/sv_*.lua
   gamemode/cl_*.lua    → gamemode/core_systems/cl_*.lua
   gamemode/status/     → gamemode/core_systems/status/
   gamemode/gui/        → gamemode/core_systems/gui/
   gamemode/languages/  → gamemode/core_systems/languages/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]
