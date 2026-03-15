-- =============================================================
-- ПРИМЕР: Новый гаджет из внешнего аддона
-- Путь: addons/my_addon/lua/horde/modules/gadgets/gadget_stasis_field.lua
-- =============================================================
-- Структура полностью идентична встроенным гаджетам.
-- Файл грузится автоматически — ничего не нужно прописывать.
-- =============================================================

GADGET = {}

GADGET.PrintName    = "Stasis Field"
GADGET.Description  = [[
Project a stasis field that slows all enemies in {1} units by {2}% for {3} seconds.
Cooldown: {4} seconds.
]]
GADGET.Icon         = "items/gadgets/stasis_field.png"
GADGET.Duration     = 0
GADGET.Cooldown     = 25
GADGET.Active       = true

GADGET.Params = {
    [1] = { value = 400 },
    [2] = { value = 50, percent = true },
    [3] = { value = 4 },
    [4] = { value = 25 },
}

GADGET.Hooks = {}

GADGET.Hooks.Horde_UseActiveGadget = function(ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_stasis_field" then return end

    local radius = 400
    local pos    = ply:GetPos()

    -- Звуковой эффект
    ply:EmitSound("horde/gadgets/stasis.ogg", 75, 100)

    -- Найти всех врагов в радиусе
    for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
        if not IsValid(ent) then continue end
        if not ent:IsNPC() then continue end

        -- Применяем хиндер (снижение скорости — встроенный debuff Horde)
        ent:Horde_SyncDebuff(HORDE.Status_Hinder, 4, 50)
    end

    -- Визуальный эффект (используем встроенные Horde particles если есть)
    local ed = EffectData()
    ed:SetOrigin(pos + Vector(0, 0, 50))
    ed:SetRadius(radius)
    util.Effect("horde_stasis_field", ed, true, true)
end
