-- =============================================================
-- ПРИМЕР: Новый класс из внешнего аддона
-- Путь: addons/my_addon/lua/horde/modules/classes/class_ranger.lua
-- =============================================================
-- Можно использовать два стиля: через HORDE:RegisterClass() или
-- через прямой HORDE:CreateClass() — оба работают.
-- =============================================================

-- Ждём пока загрузится система классов
hook.Add("Horde_AllModulesLoaded", "Register_Ranger_Class", function()

    -- ─── Вариант А: через RegisterClass (рекомендуется) ─────
    HORDE:RegisterClass({
        Name        = "Ranger",
        ExtraDesc   = "A long-range specialist using precision and traps.",
        MaxHP       = 80,
        MoveSpeed   = 200,
        SprintSpeed = 320,
        BasePerk    = "ranger_base",
        Perks = {
            -- Те же перки что объявляются в modules/perks/ranger/
        },
        Order       = 11,  -- Показывается после Cremator (order=10)
        DisplayName = "Ranger",
        Model       = "models/player/custom_ranger.mdl",
        Icon        = "Ranger.png",
        Subclasses  = { "Ranger" },
    })

    -- ─── Вариант Б: напрямую (старый стиль) ─────────────────
    -- HORDE:CreateClass(
    --     "Ranger",
    --     "A long-range specialist.",
    --     80, 200, 320,
    --     "ranger_base",
    --     {},
    --     11,
    --     "Ranger",
    --     "models/player/custom_ranger.mdl",
    --     "Ranger.png",
    --     { "Ranger" }
    -- )

    print("[MyAddon] Ranger class registered!")
end)

-- =============================================================
-- ПРИМЕР: Соответствующий подкласс
-- Путь: addons/my_addon/lua/horde/modules/subclasses/ranger.lua
-- =============================================================

--[[
SUBCLASS = {}
SUBCLASS.PrintName   = "Ranger"
SUBCLASS.ParentClass = "Ranger"  -- базовый класс
SUBCLASS.Description = [[
Precision shooter. Uses traps and ranged abilities.
]]
SUBCLASS.Perks       = {}
SUBCLASS.Icon        = "Ranger.png"
SUBCLASS.UnlockCost  = 5000
-- UnlockCost = 0 означает разблокирован по умолчанию
]]
