-- =============================================================
-- HORDE GAMEMODE - init.lua (v2.0 Modular Architecture)
-- =============================================================
-- Этот файл намеренно минимален.
-- Вся логика загрузки делегирована core/loader.lua.
-- НЕ ДОБАВЛЯЙ СЮДА include() или AddCSLuaFile() напрямую!
-- Для добавления контента используй папку modules/
-- или lua/horde/modules/ в своём аддоне.
-- =============================================================

-- Ядро должно дойти до клиента
AddCSLuaFile("core/loader.lua")
AddCSLuaFile("core/registry.lua")
AddCSLuaFile("core/compat.lua")

-- Запуск движка модульной загрузки
include("core/loader.lua")
