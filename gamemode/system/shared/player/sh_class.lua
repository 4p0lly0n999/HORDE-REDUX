-- Class
HORDE.classes = {}
HORDE.order_to_class_name = {}
HORDE.Class_Survivor    = "Survivor"
HORDE.Class_Assault     = "Assault"
HORDE.Class_Heavy       = "Heavy"
HORDE.Class_Medic       = "Medic"
HORDE.Class_Demolition  = "Demolition"
HORDE.Class_Ghost       = "Ghost"
HORDE.Class_Engineer    = "Engineer"
HORDE.Class_Berserker   = "Berserker"
HORDE.Class_Warden      = "Warden"
HORDE.Class_Cremator    = "Cremator"

-- ─────────────────────────────────────────────────────────────
-- HORDE:CreateClass(data)
--
-- Creates a player class. Accepts a named-field table
-- instead of a long positional argument list.
--
-- Required fields:
--   name        (string)  — internal class name (HORDE.Class_*)
--   order       (number)  — sort order index
--   base_perk   (string)  — base perk for the class
--   perks       (table)   — perk tier table:
--                           { [1] = {title="...", choices={...}}, ... }
--
-- Optional fields:
--   description (string)  — class description text
--   max_hp      (number)  — maximum HP (default 100)
--   movespd     (number)  — walk speed
--   sprintspd   (number)  — sprint speed
--   display_name(string)  — display name (defaults to name)
--   model       (string)  — player model path
--   icon        (string)  — icon filename (default "<n>.png")
--   subclasses  (table)   — list of subclasses (default { name })
-- ─────────────────────────────────────────────────────────────
function HORDE:CreateClass(data)
    if not data or not data.name or data.name == "" then return end

    local class = {}
    class.name          = data.name
    class.extra_description = data.description or data.extra_description or ""
    class.max_hp        = data.max_hp    or 100
    class.movespd       = data.movespd   or GetConVar("horde_base_walkspeed"):GetInt()
    class.sprintspd     = data.sprintspd or GetConVar("horde_base_runspeed"):GetInt()
    class.base_perk     = data.base_perk
    class.perks         = data.perks     or {}
    class.order         = data.order     or 0
    class.display_name  = data.display_name or data.name
    class.model         = data.model     or nil
    class.icon          = data.icon      or (data.name .. ".png")
    class.infusions     = data.infusions or {}
	-- The class itself is always its first subclass (the free default)
	-- Paid subclasses (e.g. SpecOps, Psycho) are appended later by Horde_LoadSubclasses()
	class.subclasses    = data.subclasses or { data.name } 
	
    HORDE.order_to_class_name[class.order] = class.name
    HORDE.classes[class.name] = class
end

-- Alias — recommended way for external addons
HORDE.RegisterClass = HORDE.CreateClass

-- Only allow 1 change per wave
HORDE.player_class_changed = {}

function SyncClasses()
    if player then
        for _, ply in pairs(player.GetAll()) do
            net.Start("Horde_SyncClasses")
            net.WriteTable(HORDE.classes)
            net.Send(ply)
        end
    end
end

function HORDE:SetClassData()
    if SERVER then
        if GetConVar("horde_default_class_config"):GetInt() == 1 then return end
        if not file.IsDir("horde", "DATA") then
            file.CreateDir("horde")
        end

        file.Write("horde/class.txt", util.TableToJSON(HORDE.classes))
    end
end

local function GetClassData()
    if SERVER then
        if not file.IsDir("horde", "DATA") then
            file.CreateDir("horde", "DATA")
            return
        end

        if file.Read("horde/class.txt", "DATA") then
            local t = util.JSONToTable(file.Read("horde/class.txt", "DATA"))

            for _, class in pairs(t) do
                if class.display_name then
                    HORDE.classes[class.name].display_name = class.display_name
                end
                if class.extra_description then
                    HORDE.classes[class.name].extra_description = class.extra_description
                end
                if class.model then
                    HORDE.classes[class.name].model = class.model
                end
                if class.base_perk then
                    HORDE.classes[class.name].base_perk = class.base_perk
                end
                if class.perks then
                    HORDE.classes[class.name].perks = class.perks
                end
                if class.icon then
                    HORDE.classes[class.name].icon = class.icon
                end
            end
        end
    end
end

-- ─────────────────────────────────────────────────────────────
-- Default class definitions.
-- Uses the new named-field CreateClass format.
-- Walk/sprint speeds are taken from ConVars automatically
-- (movespd/sprintspd fields can be omitted — defaults will apply).
-- ─────────────────────────────────────────────────────────────
function HORDE:GetDefaultClassesData()
    HORDE:CreateClass({
        name        = HORDE.Class_Survivor,
        description = "Has access to all weapons except for exclusive and special weapons.\n\nLimited access to attachments.",
        base_perk   = "survivor_base",
        perks = {
            [1] = { title = "Survival",        choices = { "medic_antibiotics",    "assault_charge"          } },
            [2] = { title = "Improvise",        choices = { "berserker_breathing_technique", "demolition_frag_cluster" } },
            [3] = { title = "Imprinting",       choices = { "heavy_liquid_armor",   "cremator_entropy_shield" } },
            [4] = { title = "Inspired Learning",choices = { "ghost_headhunter",     "specops_flare"           } },
        },
        order       = 0,
        subclasses  = { HORDE.Class_Survivor },
    })

    HORDE:CreateClass({
        name        = HORDE.Class_Assault,
        description = "Has full access to assault rifles.",
        base_perk   = "assault_base",
        perks = {
            [1] = { title = "Maneuverability", choices = { "assault_ambush",             "assault_charge"            } },
            [2] = { title = "Adaptability",    choices = { "assault_drain",              "assault_overclock"         } },
            [3] = { title = "Aggression",      choices = { "assault_cardiac_resonance",  "assault_cardiac_overload"  } },
            [4] = { title = "Conditioning",    choices = { "assault_heightened_reflex",  "assault_merciless_assault" } },
        },
        order       = 1,
        subclasses  = { HORDE.Class_Assault },
    })

    HORDE:CreateClass({
        name        = HORDE.Class_Heavy,
        description = "Has full access to machine guns and high weight weapons.",
        base_perk   = "heavy_base",
        perks = {
            [1] = { title = "Suppression",      choices = { "heavy_sticky_compound",  "heavy_crude_casing"     } },
            [2] = { title = "Backup",            choices = { "heavy_repair_catalyst",  "heavy_floating_carrier" } },
            [3] = { title = "Armor Protection",  choices = { "heavy_liquid_armor",     "heavy_reactive_armor"   } },
            [4] = { title = "Technology",        choices = { "heavy_nanomachine",      "heavy_ballistic_shock"  } },
        },
        order       = 2,
        subclasses  = { HORDE.Class_Heavy },
    })

    HORDE:CreateClass({
        name        = HORDE.Class_Medic,
        description = "Has acesss to most light weapons and medical tools.",
        base_perk   = "medic_base",
        perks = {
            [1] = { title = "Medicine",         choices = { "medic_antibiotics",       "medic_painkillers"       } },
            [2] = { title = "Bio-Engineering",  choices = { "medic_berserk",           "medic_fortify"           } },
            [3] = { title = "Enhancement",      choices = { "medic_purify",            "medic_haste"             } },
            [4] = { title = "Natural Selection",choices = { "medic_cellular_implosion", "medic_xcele"            } },
        },
        order       = 3,
        subclasses  = { HORDE.Class_Medic },
    })

    HORDE:CreateClass({
        name        = HORDE.Class_Demolition,
        description = "Has full access to explosive weapons.",
        base_perk   = "demolition_base",
        perks = {
            [1] = { title = "Grenade",    choices = { "demolition_frag_impact",        "demolition_frag_cluster"        } },
            [2] = { title = "Weaponry",   choices = { "demolition_direct_hit",         "demolition_seismic_wave"        } },
            [3] = { title = "Approach",   choices = { "demolition_fragmentation",      "demolition_knockout"            } },
            [4] = { title = "Destruction",choices = { "demolition_chain_reaction",     "demolition_pressurized_warhead" } },
        },
        order       = 4,
        subclasses  = { HORDE.Class_Demolition },
    })

    HORDE:CreateClass({
        name        = HORDE.Class_Ghost,
        description = "Has access to sniper rifles and selected light weapons.\n\nHave access to suppressors and sniper scopes.",
        base_perk   = "ghost_base",
        perks = {
            [1] = { title = "Tactics",    choices = { "ghost_headhunter",    "ghost_sniper"         } },
            [2] = { title = "Reposition", choices = { "ghost_phase_walk",    "ghost_ghost_veil"     } },
            [3] = { title = "Trajectory", choices = { "ghost_brain_snap",    "ghost_kinetic_impact" } },
            [4] = { title = "Disposal",   choices = { "ghost_coup",          "ghost_decapitate"     } },
        },
        order       = 5,
        subclasses  = { HORDE.Class_Ghost },
    })

    HORDE:CreateClass({
        name        = HORDE.Class_Engineer,
        description = "Has access to special weapons and equipment.",
        base_perk   = "engineer_base",
        perks = {
            [1] = { title = "Craftsmanship", choices = { "engineer_tinkerer",         "engineer_pioneer"   } },
            [2] = { title = "Core",          choices = { "engineer_fusion",            "engineer_metabolism"} },
            [3] = { title = "Manipulation",  choices = { "engineer_antimatter_shield", "engineer_displacer" } },
            [4] = { title = "Experimental",  choices = { "engineer_symbiosis",         "engineer_kamikaze"  } },
        },
        order       = 6,
        subclasses  = { HORDE.Class_Engineer },
    })

    HORDE:CreateClass({
        name        = HORDE.Class_Berserker,
        description = "Has access to melee weapons and some ranged equipment.",
        base_perk   = "berserker_base",
        perks = {
            [1] = { title = "Fundamentals", choices = { "berserker_breathing_technique", "berserker_bloodlust"      } },
            [2] = { title = "Technique",    choices = { "berserker_bushido",              "berserker_savagery"       } },
            [3] = { title = "Parry",        choices = { "berserker_graceful_guard",       "berserker_unwavering_guard"} },
            [4] = { title = "Combat Arts",  choices = { "berserker_phalanx",              "berserker_rip_and_tear"   } },
        },
        order       = 7,
        subclasses  = { HORDE.Class_Berserker },
    })

    HORDE:CreateClass({
        name        = HORDE.Class_Warden,
        description = "Has full access to shotguns and watchtowers (horde_watchtower).",
        base_perk   = "warden_base",
        perks = {
            [1] = { title = "Sustain",               choices = { "warden_bulwark",          "warden_vitality"          } },
            [2] = { title = "Resource Utilization",  choices = { "warden_restock",           "warden_inoculation"       } },
            [3] = { title = "Escort",                choices = { "warden_rejection_pulse",   "warden_energize"          } },
            [4] = { title = "Coverage",              choices = { "warden_ex_machina",        "warden_resonance_cascade" } },
        },
        order       = 8,
        subclasses  = { HORDE.Class_Warden },
    })

    HORDE:CreateClass({
        name        = HORDE.Class_Cremator,
        description = "Has access to heat-based weaponry.",
        base_perk   = "cremator_base",
        perks = {
            [1] = { title = "Chemicals",       choices = { "cremator_methane",         "cremator_napalm"       } },
            [2] = { title = "Energy Absorption",choices = { "cremator_positron_array",  "cremator_entropy_shield"} },
            [3] = { title = "Heat Manipulation",choices = { "cremator_hyperthermia",    "cremator_ionization"   } },
            [4] = { title = "Energy Discharge", choices = { "cremator_firestorm",       "cremator_incineration" } },
        },
        order       = 9,
        subclasses  = { HORDE.Class_Cremator },
    })
end

if SERVER then
    util.AddNetworkString("Horde_SetClassData")
    util.AddNetworkString("Horde_SetSubclass")
    util.AddNetworkString("Horde_UnlockSubclass")
    util.AddNetworkString("Horde_SubclassUnlocked")
    util.AddNetworkString("Horde_SelectSameSubclass")
    util.AddNetworkString("Horde_SyncSubclassUnlocks")
    HORDE:GetDefaultClassesData()
    if GetConVar("horde_default_class_config"):GetInt() == 1 then
        -- Do nothing
    else
        GetClassData()
    end

    SyncClasses()
    
    net.Receive("Horde_SetClassData", function (len, ply)
        if not ply:IsSuperAdmin() then return end
        HORDE.classes = net.ReadTable()
        HORDE:SetClassData()
        SyncClasses()
    end)

    net.Receive("Horde_SetSubclass", function (len, ply)
        local class_name = net.ReadString()
        local subclass = net.ReadString()
        ply:Horde_SetSubclass(class_name, subclass)

        if not ply:IsValid() then return end

        -- Clear status
        net.Start("Horde_ClearStatus")
        net.Send(ply)

        ply:Horde_ApplyPerksForClass()
        ply:Horde_SyncEconomy()
    end)
    
    net.Receive("Horde_UnlockSubclass", function (len, ply)
        local subclass_name = net.ReadString()
        local subclass = HORDE.subclasses[subclass_name]
        if not subclass then return end
        local cost = subclass.UnlockCost

        if ply:Horde_GetSubclassUnlocked(subclass_name) == true then
            HORDE:SendNotification("Subclass " .. subclass.PrintName .. " is already unlocked!", 1, ply)
            return
        end

        if ply:Horde_GetSkullTokens() >= cost then
            ply:Horde_AddSkullTokens(-cost)
            ply:Horde_SetSubclassUnlocked(subclass_name, true)
            ply:Horde_SyncEconomy()
            
            HORDE:SendNotification("You unlocked " .. subclass.PrintName .. " subclass.", 0, ply)
        end
    end)
    
    net.Receive("Horde_SelectSameSubclass", function (len, ply)
        local subclass_name = net.ReadString()
        local subclass = HORDE.subclasses[subclass_name]
        if not subclass then return end

        if subclass_name == ply:Horde_GetCurrentSubclass() then
            HORDE:SendNotification("You are already this class.", 1, ply)
        end
    end)
end

if CLIENT then
    net.Receive("Horde_SyncClasses", function ()
        HORDE.classes = net.ReadTable()
        for name, c in pairs(HORDE.classes) do
            HORDE.order_to_class_name[c.order] = name
        end
        local class = MySelf:Horde_GetCurrentSubclass() or HORDE.Class_Survivor
    end)

    net.Receive("Horde_SyncSubclassUnlocks", function ()
        local table = net.ReadTable()
        MySelf.Horde_subclasses_unlocked = table
    end)
end

HORDE.subclasses = {}

-- ─────────────────────────────────────────────────────────────
-- Helper class mapping tables.
-- Populated automatically via CreateClass — no need to
-- duplicate data manually.
-- ─────────────────────────────────────────────────────────────
HORDE.classes_to_subclasses = {
    [HORDE.Class_Survivor]   = { HORDE.Class_Survivor   },
    [HORDE.Class_Assault]    = { HORDE.Class_Assault     },
    [HORDE.Class_Medic]      = { HORDE.Class_Medic       },
    [HORDE.Class_Heavy]      = { HORDE.Class_Heavy       },
    [HORDE.Class_Demolition] = { HORDE.Class_Demolition  },
    [HORDE.Class_Cremator]   = { HORDE.Class_Cremator    },
    [HORDE.Class_Ghost]      = { HORDE.Class_Ghost       },
    [HORDE.Class_Warden]     = { HORDE.Class_Warden      },
    [HORDE.Class_Berserker]  = { HORDE.Class_Berserker   },
    [HORDE.Class_Engineer]   = { HORDE.Class_Engineer    },
}

-- classes_to_order and order_to_class_name are derived from classes[].order,
-- so storing them separately is redundant. Kept for backwards compatibility,
-- but are populated automatically via CreateClass.
HORDE.classes_to_order = {}
-- order_to_class_name is declared above and populated inside CreateClass.

-- Hook after default classes load: sync the duplicate lookup tables.
hook.Add("Horde_AllModulesLoaded", "Horde_SyncClassOrderTables", function()
    for name, class in pairs(HORDE.classes) do
        HORDE.classes_to_order[name] = class.order
        HORDE.order_to_class_name[class.order] = name
    end
end)

HORDE.subclass_name_to_crc = {}
HORDE.subclasses_to_classes = {}
HORDE.order_to_subclass_name = {}
local prefix = "horde/gamemode/modules/subclasses/"
local function Horde_LoadSubclasses()
    local dev = GetConVar("developer"):GetBool()
    for _, f in ipairs(file.Find(prefix .. "*", "LUA")) do
        SUBCLASS = {}
        AddCSLuaFile(prefix .. f)
        include(prefix .. f)
        if SUBCLASS.Ignore then goto cont end
        SUBCLASS.SortOrder = SUBCLASS.SortOrder or 0
        SUBCLASS.BasePerk = SUBCLASS.BasePerk or (string.lower(SUBCLASS.PrintName).. "_base")

        HORDE.subclasses[SUBCLASS.PrintName] = SUBCLASS
        local crc_val = util.CRC(SUBCLASS.PrintName)
        HORDE.subclass_name_to_crc[SUBCLASS.PrintName] = crc_val
        HORDE.order_to_subclass_name[crc_val] = SUBCLASS.PrintName
        if SUBCLASS.ParentClass then
            table.insert(HORDE.classes_to_subclasses[SUBCLASS.ParentClass], SUBCLASS.PrintName)
            HORDE.subclasses_to_classes[SUBCLASS.PrintName] = SUBCLASS.ParentClass
        else
            HORDE.subclasses_to_classes[SUBCLASS.PrintName] = SUBCLASS.PrintName
    end

        if dev then print("[Horde] Loaded subclass '" .. SUBCLASS.PrintName .. "'.") end
        ::cont::
    end
    PERK = nil
end

-- Subclasses loaded by core/loader.lua
-- Horde_LoadSubclasses()

local plymeta = FindMetaTable("Player")

function plymeta:Horde_SetClass(class)
    self.Horde_class = class
    if GetConVarNumber("horde_enable_class_models") == 0 then return end
    self:Horde_SetClassModel(class)
end

function plymeta:Horde_SetSubclass(class_name, subclass_name)
    if not self.Horde_subclasses then self.Horde_subclasses = {} end
    self.Horde_subclasses[class_name] = subclass_name
    if SERVER then
        -- Check items
        if self:GetWeapons() then
            for _, wpn in pairs(self:GetWeapons()) do
                if HORDE.items[wpn:GetClass()] then
                    local item = HORDE.items[wpn:GetClass()]
                    if self:Horde_GetCurrentSubclass() == "Gunslinger" and item.category == "Pistol" then
                        continue
                    end
                    if item.whitelist and not item.whitelist[self:Horde_GetCurrentSubclass()] then
                        timer.Simple(0, function ()
                            self:DropWeapon(wpn)
                        end)
                        continue
                    end
                end
            end
        end
        
        --Check Gadget
        for _, gadget in pairs(HORDE.items) do
            if gadget.category == "Gadget" and self:Horde_GetGadget() == gadget.class and gadget.whitelist and not gadget.whitelist[self:Horde_GetCurrentSubclass()] then
                self:Horde_UnsetGadget()
                self:Horde_SyncEconomy()
            end
        end
        
        
        if self.Horde_subclasses[class_name] == self:Horde_GetCurrentSubclass() then
            --Check Minions
            self:Horde_RemoveMinionsAndDrops()
            
            -- Sell and remove all upgrades
            if self.Horde_Special_Upgrades then
                for upgrades in pairs(self.Horde_Special_Upgrades) do 
                    self:Horde_UnsetSpecialUpgrade(upgrades)
                end
            end
        end
        
        HORDE:SendNotification(class_name .. " subclass changed to " .. HORDE.subclasses[subclass_name].PrintName, 0, self)
    end
    if CLIENT then
        net.Start("Horde_SetSubclass")
            net.WriteString(class_name)
            net.WriteString(subclass_name)
        net.SendToServer()
    end
end

function HORDE:LoadSubclassUnlocks(ply)
    if not ply:IsValid() then return end
    if not file.IsDir("horde/subclass_unlocks", "DATA") then
		file.CreateDir("horde/subclass_unlocks", "DATA")
	end

    local path = "horde/subclass_unlocks/" .. HORDE:ScrubSteamID(ply) .. ".txt"

    ply.Horde_subclasses_unlocked = {}
    if not file.Exists(path, "DATA") then
        print("Path", path, "does not exist!")
        for subclass_name, subclass in pairs(HORDE.subclasses) do
            ply.Horde_subclasses_unlocked[subclass_name] = false
        end
        HORDE:SaveSubclassUnlocks(ply)
        return
    end

    local f = file.Open(path, "rb", "DATA")
    while not f:EndOfFile() do
        local subclass_order = f:ReadULong()
        local status = f:ReadBool()
        local subclass_name = HORDE.order_to_subclass_name[tostring(subclass_order)]
        if not subclass_name then goto cont end
        ply.Horde_subclasses_unlocked[subclass_name] = status
        ::cont::
    end
    f:Close()

    net.Start("Horde_SyncSubclassUnlocks")
        net.WriteTable(ply.Horde_subclasses_unlocked)
    net.Send(ply)
end

function HORDE:SaveSubclassUnlocks(ply)
    if GetConVar("horde_enable_sandbox"):GetInt() == 1 then return end
    if not file.IsDir("horde/subclass_unlocks", "DATA") then
        file.CreateDir("horde/subclass_unlocks", "DATA")
    end

    local path = "horde/subclass_unlocks/" .. HORDE:ScrubSteamID(ply) .. ".txt"
    local f = file.Open(path, "wb", "DATA")
    for subclass_name, status in pairs(ply.Horde_subclasses_unlocked) do
        f:WriteULong(HORDE.subclass_name_to_crc[subclass_name])
        f:WriteBool(status)
    end
    
    f:Close()
end

function plymeta:Horde_SetSubclassUnlocked(subclass, unlocked)
    if not self.Horde_subclasses_unlocked then return end
    self.Horde_subclasses_unlocked[subclass] = unlocked
    if SERVER and unlocked == true then
        net.Start("Horde_SubclassUnlocked")
            net.WriteString(subclass)
        net.Send(self)
        HORDE:SaveSubclassUnlocks(self)
    end
end

function plymeta:Horde_SetSubclassChoice(class_name, subclass_name)
    MySelf.Horde_subclass_choices[class_name] = subclass_name
    if CLIENT then
        HORDE:SaveSubclassChoices()
    end
end

function plymeta:Horde_GetClass()
    return self.Horde_class
end

function plymeta:Horde_GetSubclass(class_name)
    if self.Horde_subclasses and self.Horde_subclasses[class_name] then
        return self.Horde_subclasses[class_name]
    else
        -- return parent class
        return class_name
    end
end

function plymeta:Horde_GetSubclassUnlocked(subclass)
    if not self.Horde_subclasses_unlocked then self.Horde_subclasses_unlocked = {} end
    if not HORDE.subclasses[subclass].ParentClass then return true end
    return self.Horde_subclasses_unlocked[subclass] == true
end

function plymeta:Horde_GetCurrentSubclass()
    if not self:Horde_GetClass() then return end
    if self.Horde_subclasses and self.Horde_subclasses[self:Horde_GetClass().name] then
        return self.Horde_subclasses[self:Horde_GetClass().name]
    else
        return self:Horde_GetClass().name
    end
end

function HORDE:SaveSubclassChoices()
    local f = file.Open("horde/subclass_choices.txt", "wb", "DATA")
    for class, subclass in pairs(MySelf.Horde_subclass_choices) do
        f:WriteULong(HORDE.classes_to_order[class])
        f:WriteULong(HORDE.subclass_name_to_crc[subclass])
    end
    f:Close()
end

function HORDE:LoadSubclassChoices()
    MySelf.Horde_subclass_choices = {}
    if not file.Exists("horde/subclass_choices.txt", "DATA") then
        for class_name, _ in pairs(HORDE.classes_to_subclasses) do
            MySelf.Horde_subclass_choices[class_name] = class_name
        end
        HORDE:SaveSubclassChoices()
    else
        local f = file.Open("horde/subclass_choices.txt", "rb", "DATA")
        if not MySelf.Horde_subclasses then MySelf.Horde_subclasses = {} end
        while not f:EndOfFile() do
            local class_order = f:ReadULong()
            local subclass_order = f:ReadULong()
            local class_name    = HORDE.order_to_class_name[class_order]
            local subclass_name = HORDE.order_to_subclass_name[tostring(subclass_order)]
            -- Skip entries whose order values are not yet known (e.g. classes
            -- haven't synced from server yet, or the save is from an older version).
            if class_name and subclass_name then
                MySelf.Horde_subclass_choices[class_name] = subclass_name
                MySelf.Horde_subclasses[class_name]       = subclass_name
            end
        end
        f:Close()

        -- Double check that we have all the subclasses we need
        for class_name, _ in pairs(HORDE.classes_to_subclasses) do
            if not MySelf.Horde_subclass_choices[class_name] then
                MySelf.Horde_subclass_choices[class_name] = class_name
            end
        end
    end
end

if CLIENT then
hook.Add("InitPostEntity", "Horde_PlayerInit", function()
    timer.Simple(0, function ()
        HORDE:LoadSubclassChoices()
        local f = file.Read("horde/class_choices.txt", "DATA")
        if f then
            local class = f
            if not HORDE.subclasses[class] then
                class = HORDE.Class_Survivor
            end
            local f2 = file.Read("horde/class_choices.txt", "DATA")

            if f2 then
                HORDE:SendSavedPerkChoices(f2)
            else
                HORDE:SendSavedPerkChoices(class)
            end

            net.Start("Horde_InitClass")
            net.WriteString(class)
            net.SendToServer()
        end
        net.Start("Horde_PlayerInit")
        net.SendToServer()
    end)
end)

net.Receive("Horde_SubclassUnlocked", function ()
    local subclass = net.ReadString()
    MySelf:Horde_SetSubclassUnlocked(subclass, true)
end)
end
