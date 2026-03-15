-- =============================================================
-- HORDE GAMEMODE - core/loader.lua
-- Движок модульной загрузки v2.0
-- =============================================================
-- ЭТОТ ФАЙЛ НЕ ТРОГАТЬ.
-- Автоматически обнаруживает и загружает все модули из:
--   1. system/  — ядро (строгий порядок через SYSTEMS_MANIFEST)
--   2. modules/       — контент (перки, гаджеты, заклинания, мутации...)
--   3. lua/horde/modules/ — внешние аддоны (грузятся последними)
-- =============================================================

local LOADER_VERSION = "2.0.0"

-- Корень пути в LUA-дереве (gamemodes/horde/gamemode/)
local GM_PATH  = "horde/gamemode/"
-- Путь для внешних аддонов (addons/*/lua/horde/modules/)
local EXT_PATH = "horde/modules/"

-- ============================================================
-- §1. БЕЗОПАСНАЯ ЗАГРУЗКА
-- Сломанный модуль = предупреждение, игра продолжает работу.
-- ============================================================

local function _CSLuaFile(path)
    if SERVER then
        local ok, err = pcall(AddCSLuaFile, path)
        if not ok then
            ErrorNoHaltWithStack("[Horde Loader] AddCSLuaFile FAILED: '" .. path .. "'\n" .. tostring(err) .. "\n")
            return false
        end
    end
    return true
end

local function _Include(path)
    local ok, err = pcall(include, path)
    if not ok then
        ErrorNoHaltWithStack("[Horde Loader] include FAILED: '" .. path .. "'\n" .. tostring(err) .. "\n")
        return false
    end
    return true
end

-- Загрузить один .lua файл с учётом sh_/sv_/cl_ префикса
local function LoadFile(full_path, filename)
    local prefix = filename:sub(1, 3)

    _CSLuaFile(full_path)

    if prefix == "sv_" then
        if SERVER then return _Include(full_path) end
    elseif prefix == "cl_" then
        if CLIENT then return _Include(full_path) end
    else
        -- sh_ или без префикса → shared
        return _Include(full_path)
    end
    return true
end

-- ============================================================
-- §2. ЗАГРУЗКА ПАПКИ
-- ============================================================

-- options.recursive   = true  → заходить в подпапки
-- options.first_files = {}    → грузить эти файлы первыми
local function LoadFolder(folder_path, options)
    options = options or {}
    local first_files = options.first_files or {}
    local dev = GetConVar("developer"):GetBool()

    local files, dirs = file.Find(folder_path .. "/*", "LUA")
    if not files then return end

    table.sort(files)

    -- Сначала приоритетные файлы
    for _, priority_name in ipairs(first_files) do
        for _, fname in ipairs(files) do
            if fname == priority_name then
                LoadFile(folder_path .. "/" .. fname, fname)
                if dev then print("[Horde Loader]   (priority) " .. fname) end
            end
        end
    end

    -- Затем всё остальное
    for _, fname in ipairs(files) do
        if not fname:EndsWith(".lua") then continue end
        if fname:sub(1, 1) == "_" then continue end  -- _disabled

        local already = false
        for _, p in ipairs(first_files) do
            if fname == p then already = true; break end
        end
        if already then continue end

        LoadFile(folder_path .. "/" .. fname, fname)
        if dev then print("[Horde Loader]   " .. fname) end
    end

    -- Подпапки
    if options.recursive and dirs then
        table.sort(dirs)
        for _, dir in ipairs(dirs) do
            if dir:sub(1, 1) ~= "_" then
                LoadFolder(folder_path .. "/" .. dir, options)
            end
        end
    end
end

-- ============================================================
-- §3. MANIFEST СИСТЕМНЫХ МОДУЛЕЙ
-- Строгий порядок загрузки для system/
-- ============================================================

local SYSTEMS_MANIFEST = {
    -- ── ФАЗА A: Shared ──────────────────────────────────────
    -- ── shared/core ────────────────────────────────────────────
    { path = "shared/core/sh_horde.lua",       desc = "HORDE table & constants" },
    { path = "shared/core/sh_translate.lua",   desc = "Translations" },
    { path = "shared/core/sh_particles.lua",   desc = "Particle pre-cache" },
    { path = "shared/core/sh_sync.lua",        desc = "Network sync helpers" },
    { path = "shared/core/sh_misc.lua",        desc = "Misc helpers" },
    { path = "shared/core/shared.lua",         desc = "GMod shared convar/convars" },

    -- ── shared/combat ───────────────────────────────────────
    { path = "shared/combat/sh_status.lua",    desc = "Status effect framework" },
    { path = "shared/combat/sh_damage.lua",    desc = "Damage types" },
    { path = "shared/combat/sh_objective.lua", desc = "Objectives" },

    -- ── shared/player ───────────────────────────────────────
    { path = "shared/player/sh_class.lua",     desc = "Class system" },
    { path = "shared/player/sh_perk.lua",      desc = "Perk system" },
    { path = "shared/player/sh_gadget.lua",    desc = "Gadget system" },
    { path = "shared/player/sh_spells.lua",    desc = "Spell system" },
    { path = "shared/player/sh_infusion.lua",  desc = "Infusion system" },
    { path = "shared/player/sh_rank.lua",      desc = "Rank system" },

    -- ── shared/world ────────────────────────────────────────
    { path = "shared/world/sh_enemy.lua",      desc = "Enemy registration" },
    { path = "shared/world/sh_mutation.lua",   desc = "Mutation framework" },
    { path = "shared/world/sh_item.lua",       desc = "Item/shop framework" },
    { path = "shared/world/sh_maps.lua",       desc = "Map config" },
    { path = "shared/world/sh_attachments.lua",desc = "ArcCW attachment config" },
    { path = "shared/world/sh_custom.lua",     desc = "External config hooks" },

    -- ── server/combat ───────────────────────────────────────
    { path = "server/combat/sv_damage.lua",    server_only = true, desc = "Damage processing" },
    { path = "server/combat/sv_heal.lua",      server_only = true, desc = "Healing" },

    -- ── STATUS PHASE (buffs/debuffs — loaded after sh_status) ─
    { STATUS_PHASE = true },

    -- ── server/core (support) ───────────────────────────────
    { path = "server/core/obj_entity_extend_sv.lua", server_only = true, desc = "VJ NPC extension" },
    { path = "server/core/sv_difficulty.lua",        server_only = true, desc = "Difficulty system" },
    { path = "server/core/sv_hooks.lua",             server_only = true, desc = "Game event hooks" },
    { path = "server/core/sv_nodegraph.lua",         server_only = true, desc = "AI node graph" },
    { path = "server/core/sv_misc.lua",              server_only = true, desc = "Misc server" },

    -- ── server/players ──────────────────────────────────────
    { path = "server/players/sv_perk.lua",           server_only = true, desc = "Server perk logic" },
    { path = "server/players/sv_rank.lua",           server_only = true, desc = "Rank persistence" },
    { path = "server/players/sv_economy.lua",        server_only = true, desc = "Economy & shop" },
    { path = "server/players/sv_commands.lua",       server_only = true, desc = "Console commands" },
    { path = "server/players/sv_playerlifecycle.lua",server_only = true, desc = "Player join/leave/vote" },
    { path = "server/players/sv_leaderboard.lua",    server_only = true, desc = "Leaderboard" },

    -- ── server/combat (rest) ────────────────────────────────
    { path = "server/combat/sv_hitnumbers.lua",      server_only = true, desc = "Hit numbers" },
    { path = "server/combat/sv_tip.lua",             server_only = true, desc = "Tip system" },

    -- ── client/core ─────────────────────────────────────────
    { path = "client/core/cl_economy.lua",     client_only = true, desc = "Client economy" },
    { path = "client/core/cl_achievement.lua", client_only = true, desc = "Achievement display" },
    { path = "client/core/cl_hitnumbers.lua",  client_only = true, desc = "Hit number rendering" },
    { path = "client/core/cl_init.lua",        client_only = true, desc = "Client init" },

    -- ── server/core (Wave Director — LAST) ──────────────────
    { path = "server/core/sv_horde.lua", server_only = true, desc = "Wave Director — LAST" },
}

-- ============================================================
-- §4. ЗАГРУЗКА СТАТУС-ЭФФЕКТОВ
-- ============================================================

local function LoadStatusEffects(base)
    local status_root = GM_PATH .. "modules/status/"

    -- Shared: sh_mind.lua и другие sh_ файлы
    local sh_files, _ = file.Find(status_root .. "sh_*.lua", "LUA")
    if sh_files then
        table.sort(sh_files)
        for _, f in ipairs(sh_files) do
            LoadFile(status_root .. f, f)
        end
    end

    -- sv_barrier.lua
    if file.Exists(status_root .. "sv_barrier.lua", "LUA") then
        if SERVER then
            _CSLuaFile(status_root .. "sv_barrier.lua")
            _Include(status_root .. "sv_barrier.lua")
        end
    end

    -- Все buff/ файлы — sv_buff.lua первым (базовый класс)
    LoadFolder(status_root .. "buff", { first_files = { "sv_buff.lua" } })

    -- Все debuff/ файлы — sv_debuff.lua первым
    LoadFolder(status_root .. "debuff", { first_files = { "sv_debuff.lua" } })
end

-- ============================================================
-- §5. ЗАГРУЗКА GUI
-- ============================================================

local function LoadGUI(base)
    local gui_root = base .. "client/gui/"
    local dev = GetConVar("developer"):GetBool()

    if dev then MsgC(Color(100, 200, 255), "[Horde Loader] Loading GUI...\n") end

    -- npcinfo (contains sh_ shared component)
    LoadFolder(gui_root .. "npcinfo", {})

    -- scoreboard (client-only — uses vgui/surface but no cl_ prefix)
    if CLIENT then
        LoadFolder(gui_root .. "scoreboard", {})
    else
        local sb_files, _ = file.Find(gui_root .. "scoreboard/*.lua", "LUA")
        if sb_files then
            for _, f in ipairs(sb_files) do _CSLuaFile(gui_root .. "scoreboard/" .. f) end
        end
    end

    -- GUI subfolders (all client-only)
    for _, subfolder in ipairs({ "hud", "shop", "config", "class", "summary" }) do
        LoadFolder(gui_root .. subfolder, { client_only = true })
    end
    -- Плоский уровень gui/
    local files, _ = file.Find(gui_root .. "*.lua", "LUA")
    if files then
        table.sort(files)
        for _, f in ipairs(files) do
            if f:sub(1, 1) ~= "_" then
                LoadFile(gui_root .. f, f)
            end
        end
    end
end

-- ============================================================
-- §6. ЗАГРУЗКА CORE СИСТЕМ
-- ============================================================

local function LoadCoreSystems()
    local base = GM_PATH .. "system/"
    local dev  = GetConVar("developer"):GetBool()

    for _, entry in ipairs(SYSTEMS_MANIFEST) do

        if entry.STATUS_PHASE then
            LoadStatusEffects(base)
            continue
        end

        local full_path = base .. entry.path

        if entry.server_only then
            _CSLuaFile(full_path)
            if SERVER then _Include(full_path) end
        elseif entry.client_only then
            _CSLuaFile(full_path)
            if CLIENT then _Include(full_path) end
        else
            LoadFile(full_path, entry.path)
        end

        if dev then
            print("[Horde Loader] sys: " .. entry.path .. (entry.desc and (" — " .. entry.desc) or ""))
        end
    end


    -- GUI (после всех систем)
    LoadGUI(base)
end

-- ============================================================
-- §7. ЗАГРУЗКА КОНТЕНТ-МОДУЛЕЙ
-- ============================================================

local FLAT_MODULE_TYPES = {
    -- difficulties MUST be first: they populate HORDE._diff_* tables
    -- before gadgets/spells/etc register (so sv_difficulty has data)
    { dir = "difficulties", desc = "difficulties" },
    { dir = "gadgets",      desc = "gadgets" },
    { dir = "spells",       desc = "spells" },
    { dir = "mutations",    desc = "mutations" },
    { dir = "subclasses",   desc = "subclasses" },
}

local function LoadContentModules(modules_path)
    local dev = GetConVar("developer"):GetBool()

    -- Helper: recursively collect all .lua files from a folder tree
    local function CollectFiles(folder)
        local result = {}
        local files, dirs = file.Find(folder .. "/*", "LUA")
        if files then
            table.sort(files)
            for _, f in ipairs(files) do
                if f:EndsWith(".lua") and f:sub(1,1) ~= "_" then
                    table.insert(result, { path = folder .. "/" .. f, name = f })
                end
            end
        end
        if dirs then
            table.sort(dirs)
            for _, d in ipairs(dirs) do
                if d:sub(1,1) ~= "_" then
                    for _, entry in ipairs(CollectFiles(folder .. "/" .. d)) do
                        table.insert(result, entry)
                    end
                end
            end
        end
        return result
    end

    -- Плоские модули с полной регистрацией (как оригинальные Horde_Load* функции)
    for _, mt in ipairs(FLAT_MODULE_TYPES) do
        local folder = modules_path .. mt.dir
        -- gadgets/spells load recursively (have class subfolders), others are flat
        local entries
        if mt.dir == "gadgets" or mt.dir == "spells" then
            entries = CollectFiles(folder)
        else
            local files, _ = file.Find(folder .. "/*.lua", "LUA")
            entries = {}
            if files then
                table.sort(files)
                for _, f in ipairs(files) do
                    if not f:EndsWith(".lua") or f:sub(1,1) == "_" then continue end
                    table.insert(entries, { path = folder .. "/" .. f, name = f })
                end
            end
        end
        if #entries > 0 then
            if dev then MsgC(Color(100, 200, 255), "[Horde Loader] Loading " .. mt.desc .. "...\n") end
            for _, entry in ipairs(entries) do
                local f = entry.name
                local full_path = entry.path
                if f:sub(1, 1) == "_" then continue end
                local basename = string.Explode(".", f)[1]

                if mt.dir == "gadgets" then
                    GADGET = {}
                    LoadFile(full_path, f)
                    if not GADGET.Ignore and GADGET.PrintName then
                        GADGET.ClassName = string.lower(GADGET.ClassName or basename)
                        HORDE.gadgets[GADGET.ClassName] = GADGET
                        for k, v in pairs(GADGET.Hooks or {}) do
                            hook.Add(k, "horde_gadget_" .. GADGET.ClassName, v)
                        end
                        if dev then print("[Horde Loader]   gadget: " .. GADGET.ClassName) end
                    end
                    GADGET = nil

                elseif mt.dir == "spells" then
                    SPELL = {}
                    LoadFile(full_path, f)
                    if not SPELL.Ignore and SPELL.PrintName then
                        SPELL.ClassName = string.lower(SPELL.ClassName or basename)
                        HORDE.spells[SPELL.ClassName] = SPELL
                        for k, v in pairs(SPELL.Hooks or {}) do
                            hook.Add(k, "horde_spell_" .. SPELL.ClassName, v)
                        end
                        if dev then print("[Horde Loader]   spell: " .. SPELL.ClassName) end
                    end
                    SPELL = nil

                elseif mt.dir == "mutations" then
                    MUTATION = {}
                    LoadFile(full_path, f)
                    if not MUTATION.Ignore and MUTATION.PrintName then
                        MUTATION.ClassName = string.lower(MUTATION.ClassName or MUTATION.PrintName or basename)
                        HORDE.mutations[MUTATION.ClassName] = MUTATION
                        if not MUTATION.NoRand then
                            HORDE.mutations_rand[MUTATION.ClassName] = MUTATION
                        end
                        for k, v in pairs(MUTATION.Hooks or {}) do
                            hook.Add(k, "horde_mutation_" .. MUTATION.ClassName, v)
                        end
                        if dev then print("[Horde Loader]   mutation: " .. MUTATION.ClassName) end
                    end
                    MUTATION = nil

                elseif mt.dir == "subclasses" then
                    SUBCLASS = {}
                    LoadFile(full_path, f)
                    if not SUBCLASS.Ignore and SUBCLASS.PrintName then
                        SUBCLASS.SortOrder = SUBCLASS.SortOrder or 0
                        SUBCLASS.BasePerk  = SUBCLASS.BasePerk or (string.lower(SUBCLASS.PrintName) .. "_base")
                        HORDE.subclasses[SUBCLASS.PrintName] = SUBCLASS
                        local crc_val = util.CRC(SUBCLASS.PrintName)
                        HORDE.subclass_name_to_crc[SUBCLASS.PrintName]  = crc_val
                        HORDE.order_to_subclass_name[crc_val]            = SUBCLASS.PrintName
                        if SUBCLASS.ParentClass then
                            if HORDE.classes_to_subclasses[SUBCLASS.ParentClass] then
                                table.insert(HORDE.classes_to_subclasses[SUBCLASS.ParentClass], SUBCLASS.PrintName)
                            end
                            HORDE.subclasses_to_classes[SUBCLASS.PrintName] = SUBCLASS.ParentClass
                        else
                            HORDE.subclasses_to_classes[SUBCLASS.PrintName] = SUBCLASS.PrintName
                        end
                        if dev then print("[Horde Loader]   subclass: " .. SUBCLASS.PrintName) end
                    end
                    SUBCLASS = nil

                elseif mt.dir == "difficulties" then
                    LoadFile(full_path, f)

                else
                    LoadFile(full_path, f)
                end
            end
        end
    end

    -- Перки (рекурсивная структура по классам) — с полной регистрацией
    if dev then MsgC(Color(100, 200, 255), "[Horde Loader] Loading perks (tree)...\n") end
    local function LoadPerkFolder(folder_path)
        local pfiles, pdirs = file.Find(folder_path .. "/*", "LUA")
        if pfiles then
            table.sort(pfiles)
            for _, pf in ipairs(pfiles) do
                if pf:EndsWith(".lua") and pf:sub(1,1) ~= "_" then
                    local pbase = string.Explode(".", pf)[1]
                    PERK = {}
                    LoadFile(folder_path .. "/" .. pf, pf)
                    if not PERK.Ignore and (PERK.PrintName or PERK.ClassName) then
                        PERK.ClassName = string.lower(PERK.ClassName or pbase)
                        PERK.SortOrder = PERK.SortOrder or 0
                        hook.Run("Horde_OnLoadPerk", PERK)
                        HORDE.perks[PERK.ClassName] = PERK
                        for k, v in pairs(PERK.Hooks or {}) do
                            hook.Add(k, "horde_perk_" .. PERK.ClassName, v)
                        end
                        if dev then print("[Horde Loader]   perk: " .. PERK.ClassName) end
                    end
                    PERK = nil
                end
            end
        end
        if pdirs then
            table.sort(pdirs)
            for _, pd in ipairs(pdirs) do
                if pd:sub(1,1) ~= "_" then
                    LoadPerkFolder(folder_path .. "/" .. pd)
                end
            end
        end
    end
    LoadPerkFolder(modules_path .. "perks")
end

-- ============================================================
-- §8. ЗАГРУЗКА ArcCW АТТАЧМЕНТОВ
-- ============================================================

local function LoadArcCWAttachments(modules_path)
    local att_folder = modules_path .. "arccw/attachments"
    local files, _ = file.Find(att_folder .. "/*.lua", "LUA")
    if not files or #files == 0 then return end
    table.sort(files)
    for _, f in ipairs(files) do
        if f:sub(1, 1) ~= "_" then
            LoadFile(att_folder .. "/" .. f, f)
        end
    end
    print("[Horde Loader] ArcCW attachments: " .. #files)
end

-- ============================================================
-- §9. ЗАГРУЗКА ВНЕШНИХ АДДОН-МОДУЛЕЙ
-- Ищет файлы в lua/horde/modules/ во ВСЕХ аддонах
-- Грузится ПОСЛЕДНИМ — может переопределять встроенный контент
-- ============================================================

local EXTERNAL_MODULE_TYPES = {
    "perks", "gadgets", "spells", "mutations",
    "subclasses", "enemies", "classes",
    "status/buff", "status/debuff",
    "systems", "gui", "arccw/attachments",
}

local function LoadExternalModules()
    local dev = GetConVar("developer"):GetBool()
    local found_any = false

    for _, mtype in ipairs(EXTERNAL_MODULE_TYPES) do
        local ext_folder = EXT_PATH .. mtype
        local files, dirs = file.Find(ext_folder .. "/*", "LUA")

        -- Плоские файлы
        if files and #files > 0 then
            table.sort(files)
            for _, fname in ipairs(files) do
                if fname:EndsWith(".lua") and fname:sub(1, 1) ~= "_" then
                    local full = ext_folder .. "/" .. fname
                    if dev then MsgC(Color(255, 200, 100), "[Horde Loader] [EXT] " .. full .. "\n") end
                    LoadFile(full, fname)
                    found_any = true
                end
            end
        end

        -- Подпапки (отдельные модуль-системы)
        if dirs then
            table.sort(dirs)
            for _, dir in ipairs(dirs) do
                if dir:sub(1, 1) ~= "_" then
                    local module_folder = ext_folder .. "/" .. dir
                    if dev then MsgC(Color(255, 200, 100), "[Horde Loader] [EXT MODULE] " .. module_folder .. "\n") end
                    LoadFolder(module_folder, { recursive = false })
                    found_any = true
                end
            end
        end
    end

    if not found_any and dev then
        print("[Horde Loader] No external addon modules found.")
    end
end

-- ============================================================
-- §10. ГЛАВНАЯ ПОСЛЕДОВАТЕЛЬНОСТЬ
-- ============================================================

local function RunLoader()
    local t0  = SysTime()
    local dev = GetConVar("developer"):GetBool()

    MsgC(Color(255, 165, 0),
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" ..
        " HORDE Modular Loader v" .. LOADER_VERSION .. "\n" ..
        " Realm: " .. (SERVER and "SERVER" or "CLIENT") .. "\n" ..
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    )

    -- Шаг 1: compat shims (не зависят от HORDE)
    _CSLuaFile(GM_PATH .. "core/compat.lua")
    _Include(GM_PATH .. "core/compat.lua")

    -- Шаг 2: shared.lua (GMod requirement)
    _CSLuaFile(GM_PATH .. "shared.lua")
    _Include(GM_PATH .. "shared.lua")

    -- Шаг 3: Core системы (строгий порядок, sh_horde.lua первым)
    if dev then MsgC(Color(100, 200, 255), "[Horde Loader] === PHASE 1: Core Systems ===\n") end
    LoadCoreSystems()

    -- Шаг 4: registry.lua — ПОСЛЕ sh_horde.lua чтобы не затереть HORDE={}
    _CSLuaFile(GM_PATH .. "core/registry.lua")
    _Include(GM_PATH .. "core/registry.lua")

    -- Шаг 5: Контент-модули
    if dev then MsgC(Color(100, 255, 100), "[Horde Loader] === PHASE 2: Content Modules ===\n") end
    local modules_path = GM_PATH .. "modules/"
    LoadContentModules(modules_path)

    -- Шаг 6: ArcCW аттачменты
    LoadArcCWAttachments(modules_path)

    -- Шаг 7: Внешние аддоны (ПОСЛЕДНИМИ — могут переопределять)
    if dev then MsgC(Color(255, 200, 100), "[Horde Loader] === PHASE 3: External Addon Modules ===\n") end
    LoadExternalModules()

    local elapsed = math.Round((SysTime() - t0) * 1000, 2)
    MsgC(Color(0, 255, 0), "[Horde Loader] ✓ All modules loaded in " .. elapsed .. "ms\n")

    hook.Run("Horde_AllModulesLoaded")
end

-- ============================================================
-- §11. ЗАПУСК (защита от двойной загрузки)
-- ============================================================

if not HORDE_LOADER_INITIALIZED then
    HORDE_LOADER_INITIALIZED = true
    RunLoader()
end
