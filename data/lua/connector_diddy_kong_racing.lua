-- Diddy Kong Racing Connector Lua
-- Adapted by zakwiz from the Banjo-Tooie Connector Lua

-- Banjo-Tooie Connector Lua by Mike Jackson (jjjj12212) with the help of Rose (Oktorose),
-- the OOT Archipelago team, ScriptHawk BT.lua & kaptainkohl for BTrando.lua, modifications from Unalive & HemiJackson

local status, _ = pcall(require, "common")
if not status then
    print("ERROR: Missing required Lua dependencies, this Lua script must be placed in the data/lua folder of your Archipelago installation.")
    return
end

local socket = require("socket")
local json = require("json")

local APWORLD_VERSION = "DKRv0.6.1"
local REQUIRED_BIZHAWK_VERSION = "2.10"

local player
local seed
local victory_condition
local shuffle_wizpig_amulet
local shuffle_tt_amulet
local open_worlds
local door_requirement_progression
local maximum_door_requirement
local shuffle_door_requirements
local door_unlock_requirements
local boss_1_regional_balloons
local boss_2_regional_balloons
local wizpig_1_amulet_pieces
local wizpig_2_amulet_pieces
local wizpig_2_balloons
local randomize_character_on_map_change
local power_up_balloon_type
local skip_trophy_races

local STATE_OK = "Ok"
local STATE_TENTATIVELY_CONNECTED = "Tentatively Connected"
local STATE_INITIAL_CONNECTION_MADE = "Initial Connection Made"
local STATE_UNINITIALIZED = "Uninitialized"
local current_state = STATE_UNINITIALIZED
local frame = 0

local slot_loaded = false
local in_save_file = false
local in_save_file_counter = 0
local init_complete = false
local current_map = 0
local paused = false

local DKR_SOCK
local DKR_RAMOBJ
local hackPointerIndex

local receive_map = {}
local previous_checks
local message_queue = {}
local n64_sent_message_count = 0

local BYTE = "BYTE"
local BIT = "BIT"

local TIMBERS_ISLAND_BALLOON = "TIMBERS_ISLAND_BALLOON"
local DINO_DOMAIN_BALLOON = "DINO_DOMAIN_BALLOON"
local SNOWFLAKE_MOUNTAIN_BALLOON = "SNOWFLAKE_MOUNTAIN_BALLOON"
local SHERBET_ISLAND_BALLOON = "SHERBET_ISLAND_BALLOON"
local DRAGON_FOREST_BALLOON = "DRAGON_FOREST_BALLOON"
local FUTURE_FUN_LAND_BALLOON = "FUTURE_FUN_LAND_BALLOON"
local FIRE_MOUNTAIN_KEY = "FIRE_MOUNTAIN_KEY"
local ICICLE_PYRAMID_KEY = "ICICLE_PYRAMID_KEY"
local DARKWATER_BEACH_KEY = "DARKWATER_BEACH_KEY"
local SMOKEY_CASTLE_KEY = "SMOKEY_CASTLE_KEY"
local WIZPIG_AMULET_PIECE = "WIZPIG_AMULET_PIECE"
local TT_AMULET_PIECE = "TT_AMULET_PIECE"

DKR_RAM = {
    RDRAM_BASE = 0x80000000,
    RDRAM_SIZE = 0x800000,
    ADDRESS = {
        IN_SAVE_FILE_1 = 0x214E72,
        IN_SAVE_FILE_2 = 0x214E76,
        IN_SAVE_FILE_3 = 0x21545A,
        PAUSED = 0x115F79,
        CHARACTER_UNLOCKS = 0x0DFD9B,
        CURRENT_MAP = 0x121167,
        TIMBERS_ISLAND_BALLOONS_1 = 0x1FCAE8,
        TIMBERS_ISLAND_BALLOONS_2 = 0x1FCAE9,
        BOSS_COMPLETION_1 = 0x1FC9DC,
        BOSS_COMPLETION_2 = 0x1FC9DD,
        -- Dino Domain
        ANCIENT_LAKE = 0x1FCAFF,
        FOSSIL_CANYON = 0x1FCAF7,
        JUNGLE_FALLS = 0x1FCB5F,
        HOT_TOP_VOLCANO = 0x1FCB07,
        FIRE_MOUNTAIN = 0x1FCB17,
        -- Snowflake Mountain
        EVERFROST_PEAK = 0x1FCB1F,
        WALRUS_COVE = 0x1FCB03,
        SNOWBALL_VALLEY = 0x1FCB0F,
        FROSTY_VILLAGE = 0x1FCB5B,
        ICICLE_PYRAMID = 0x1FCB57,
        -- Sherbet Island
        WHALE_BAY = 0x1FCB0B,
        CRESCENT_ISLAND = 0x1FCB13,
        PIRATE_LAGOON = 0x1FCAFB,
        TREASURE_CAVES = 0x1FCB63,
        DARKWATER_BEACH = 0x1FCB53,
        -- Dragon Forest
        WINDMILL_PLAINS = 0x1FCB3B,
        GREENWOOD_VILLAGE = 0x1FCB33,
        BOULDER_CANYON = 0x1FCB37,
        HAUNTED_WOODS = 0x1FCB67,
        SMOKEY_CASTLE = 0x1FCB4F,
        -- Future Fun Land
        SPACEDUST_ALLEY = 0x1FCB2F,
        DARKMOON_CAVERNS = 0x1FCB6B,
        SPACEPORT_ALPHA = 0x1FCB27,
        STAR_CITY = 0x1FCB6F
    }
}

DKR_HACK = {
    BASE_INDEX = 0x400000,
    ITEMS = 0x0,
    DOOR_COSTS = 0xC,
    MESSAGE_TEXT = 0x41,
    N64_RECEIVED_MESSAGE_COUNT = 0x7C,
    SETTINGS = 0x7D,
      VICTORY_CONDITION = 0x0,
      OPEN_WORLDS = 0x1,
      SHUFFLE_WIZPIG_AMULET = 0x2,
      SHUFFLE_TT_AMULET = 0x3,
      DOOR_PROGRESSION = 0x4,
      MAX_DOOR_REQUIREMENT = 0x5,
      SHUFFLE_DOOR_REQUIREMENTS = 0x6,
      BOSS_1_REGIONAL_BALLOONS = 0x7,
      BOSS_2_REGIONAL_BALLOONS = 0x8,
      WIZPIG_1_AMULET_PIECES = 0x9,
      WIZPIG_2_AMULET_PIECES = 0xA,
      WIZPIG_2_BALLOONS = 0xB,
      SKIP_TROPHY_RACES = 0xC,
      RANDOMIZE_CHARACTER_ON_MAP_CHANGE = 0xD,
      CHANGE_BALLOONS = 0xE,
      BALLOON_TYPE = 0xF,
    N64_PROCESSED_MESSAGE_COUNT = 0x8D,
    N64_KEYS_LOCATION = 0x8E,
    N64_BALLOON_LOCATIONS = 0x90,
      N64_BALLOON_ID = 0x98,
      N64_BALLOON_COLLECTED = 0x9A,
      N64_BALLOON_INDEX = 0,
    TOTAL_BALLOONS = 0x491,
    ROM_MAJOR_VERSION = 0x4A0,
    ROM_MINOR_VERSION = 0x4A2,
    ROM_PATCH_VERSION = 0x4A3,
    MAX_MESSAGE_BYTES = 50
}

local ITEM_IDS = {
    TIMBERS_ISLAND_BALLOON = 1616000,
    DINO_DOMAIN_BALLOON = 1616001,
    SNOWFLAKE_MOUNTAIN_BALLOON = 1616002,
    SHERBET_ISLAND_BALLOON = 1616003,
    DRAGON_FOREST_BALLOON = 1616004,
    FUTURE_FUN_LAND_BALLOON = 1616005,
    FIRE_MOUNTAIN_KEY = 1616006,
    ICICLE_PYRAMID_KEY = 1616007,
    DARKWATER_BEACH_KEY = 1616008,
    SMOKEY_CASTLE_KEY = 1616009,
    WIZPIG_AMULET_PIECE = 1616010,
    TT_AMULET_PIECE = 1616011
}

local ITEM_ID_TO_RAMHACK_ITEM_INDEX = {
    [1616000] = 0,
    [1616001] = 1,
    [1616002] = 2,
    [1616003] = 3,
    [1616004] = 4,
    [1616005] = 5,
    [1616006] = 6,
    [1616007] = 7,
    [1616008] = 8,
    [1616009] = 9,
    [1616010] = 10,
    [1616011] = 11
}

local ITEM_TO_LOCATION_ADDRESSES = {
    [TIMBERS_ISLAND_BALLOON] = {
        ["1616100"] = { -- Bridge Balloon
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_1,
            [BIT] = 2
        },
        ["1616101"] = { -- Waterfall Balloon
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_1,
            [BIT] = 6
        },
        ["1616102"] = { -- River Balloon
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_2,
            [BIT] = 6
        },
        ["1616103"] = { -- Ocean Balloon
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_2,
            [BIT] = 2
        },
        ["1616104"] = { -- Taj Car Race
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_2,
            [BIT] = 3
        },
        ["1616105"] = { -- Taj Hovercraft Race
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_1,
            [BIT] = 3
        },
        ["1616106"] = { -- Taj Plane Race
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_1,
            [BIT] = 4
        }
    },
    [DINO_DOMAIN_BALLOON] = {
        ["1616200"] = { -- Ancient Lake 1
            [BYTE] = DKR_RAM.ADDRESS.ANCIENT_LAKE,
            [BIT] = 1
        },
        ["1616201"] = { -- Ancient Lake 2
            [BYTE] = DKR_RAM.ADDRESS.ANCIENT_LAKE,
            [BIT] = 2
        },
        ["1616202"] = { -- Fossil Canyon 1
            [BYTE] = DKR_RAM.ADDRESS.FOSSIL_CANYON,
            [BIT] = 1
        },
        ["1616203"] = { -- Fossil Canyon 2
            [BYTE] = DKR_RAM.ADDRESS.FOSSIL_CANYON,
            [BIT] = 2
        },
        ["1616204"] = { -- Jungle Falls 1
            [BYTE] = DKR_RAM.ADDRESS.JUNGLE_FALLS,
            [BIT] = 1
        },
        ["1616205"] = { -- Jungle Falls 2
            [BYTE] = DKR_RAM.ADDRESS.JUNGLE_FALLS,
            [BIT] = 2
        },
        ["1616206"] = { -- Hot Top Volcano 1
            [BYTE] = DKR_RAM.ADDRESS.HOT_TOP_VOLCANO,
            [BIT] = 1
        },
        ["1616207"] = { -- Hot Top Volcano 2
            [BYTE] = DKR_RAM.ADDRESS.HOT_TOP_VOLCANO,
            [BIT] = 2
        }
    },
    [SNOWFLAKE_MOUNTAIN_BALLOON] = {
        ["1616300"] = { -- Everfrost Peak 1
            [BYTE] = DKR_RAM.ADDRESS.EVERFROST_PEAK,
            [BIT] = 1
        },
        ["1616301"] = { -- Everfrost Peak 2
            [BYTE] = DKR_RAM.ADDRESS.EVERFROST_PEAK,
            [BIT] = 2
        },
        ["1616302"] = { -- Walrus Cove 1
            [BYTE] = DKR_RAM.ADDRESS.WALRUS_COVE,
            [BIT] = 1
        },
        ["1616303"] = { -- Walrus Cove 2
            [BYTE] = DKR_RAM.ADDRESS.WALRUS_COVE,
            [BIT] = 2
        },
        ["1616304"] = { -- Snowball Valley 1
            [BYTE] = DKR_RAM.ADDRESS.SNOWBALL_VALLEY,
            [BIT] = 1
        },
        ["1616305"] = { -- Snowball Valley 2
            [BYTE] = DKR_RAM.ADDRESS.SNOWBALL_VALLEY,
            [BIT] = 2
        },
        ["1616306"] = { -- Frosty Village 1
            [BYTE] = DKR_RAM.ADDRESS.FROSTY_VILLAGE,
            [BIT] = 1
        },
        ["1616307"] = { -- Frosty Village 2
            [BYTE] = DKR_RAM.ADDRESS.FROSTY_VILLAGE,
            [BIT] = 2
        }
    },
    [SHERBET_ISLAND_BALLOON] = {
        ["1616400"] = { -- Whale Bay 1
            [BYTE] = DKR_RAM.ADDRESS.WHALE_BAY,
            [BIT] = 1
        },
        ["1616401"] = { -- Whale Bay 2
            [BYTE] = DKR_RAM.ADDRESS.WHALE_BAY,
            [BIT] = 2
        },
        ["1616402"] = { -- Crescent Island 1
            [BYTE] = DKR_RAM.ADDRESS.CRESCENT_ISLAND,
            [BIT] = 1
        },
        ["1616403"] = { -- Crescent Island 2
            [BYTE] = DKR_RAM.ADDRESS.CRESCENT_ISLAND,
            [BIT] = 2
        },
        ["1616404"] = { -- Pirate Lagoon 1
            [BYTE] = DKR_RAM.ADDRESS.PIRATE_LAGOON,
            [BIT] = 1
        },
        ["1616405"] = { -- Pirate Lagoon 2
            [BYTE] = DKR_RAM.ADDRESS.PIRATE_LAGOON,
            [BIT] = 2
        },
        ["1616406"] = { -- Treasure Caves 1
            [BYTE] = DKR_RAM.ADDRESS.TREASURE_CAVES,
            [BIT] = 1
        },
        ["1616407"] = { -- Treasure Caves 2
            [BYTE] = DKR_RAM.ADDRESS.TREASURE_CAVES,
            [BIT] = 2
        }
    },
    [DRAGON_FOREST_BALLOON] = {
        ["1616500"] = { -- Windmill Plains 1
            [BYTE] = DKR_RAM.ADDRESS.WINDMILL_PLAINS,
            [BIT] = 1
        },
        ["1616501"] = { -- Windmill Plains 2
            [BYTE] = DKR_RAM.ADDRESS.WINDMILL_PLAINS,
            [BIT] = 2
        },
        ["1616502"] = { -- Greenwood Village 1
            [BYTE] = DKR_RAM.ADDRESS.GREENWOOD_VILLAGE,
            [BIT] = 1
        },
        ["1616503"] = { -- Greenwood Village 2
            [BYTE] = DKR_RAM.ADDRESS.GREENWOOD_VILLAGE,
            [BIT] = 2
        },
        ["1616504"] = { -- Boulder Canyon 1
            [BYTE] = DKR_RAM.ADDRESS.BOULDER_CANYON,
            [BIT] = 1
        },
        ["1616505"] = { -- Boulder Canyon 2
            [BYTE] = DKR_RAM.ADDRESS.BOULDER_CANYON,
            [BIT] = 2
        },
        ["1616506"] = { -- Haunted Woods 1
            [BYTE] = DKR_RAM.ADDRESS.HAUNTED_WOODS,
            [BIT] = 1
        },
        ["1616507"] = { -- Haunted Woods 2
            [BYTE] = DKR_RAM.ADDRESS.HAUNTED_WOODS,
            [BIT] = 2
        }
    },
    [FUTURE_FUN_LAND_BALLOON] = {
        ["1616600"] = { -- Spacedust Alley 1
            [BYTE] = DKR_RAM.ADDRESS.SPACEDUST_ALLEY,
            [BIT] = 1
        },
        ["1616601"] = { -- Spacedust Alley 2
            [BYTE] = DKR_RAM.ADDRESS.SPACEDUST_ALLEY,
            [BIT] = 2
        },
        ["1616602"] = { -- Darkmoon Caverns 1
            [BYTE] = DKR_RAM.ADDRESS.DARKMOON_CAVERNS,
            [BIT] = 1
        },
        ["1616603"] = { -- Darkmoon Caverns 2
            [BYTE] = DKR_RAM.ADDRESS.DARKMOON_CAVERNS,
            [BIT] = 2
        },
        ["1616604"] = { -- Spaceport Alpha 1
            [BYTE] = DKR_RAM.ADDRESS.SPACEPORT_ALPHA,
            [BIT] = 1
        },
        ["1616605"] = { -- Spaceport Alpha 2
            [BYTE] = DKR_RAM.ADDRESS.SPACEPORT_ALPHA,
            [BIT] = 2
        },
        ["1616606"] = { -- Star City 1
            [BYTE] = DKR_RAM.ADDRESS.STAR_CITY,
            [BIT] = 1
        },
        ["1616607"] = { -- Star City 2
            [BYTE] = DKR_RAM.ADDRESS.STAR_CITY,
            [BIT] = 2
        }
    },
    [FIRE_MOUNTAIN_KEY] = {
        ["1616208"] = {
            [BYTE] = DKR_HACK.N64_KEYS_LOCATION,
            [BIT] = 1
        }
    },
    [ICICLE_PYRAMID_KEY] = {
        ["1616308"] = {
            [BYTE] = DKR_HACK.N64_KEYS_LOCATION,
            [BIT] = 3
        }
    },
    [DARKWATER_BEACH_KEY] = {
        ["1616408"] = {
            [BYTE] = DKR_HACK.N64_KEYS_LOCATION,
            [BIT] = 2
        }
    },
    [SMOKEY_CASTLE_KEY] = {
        ["1616508"] = {
            [BYTE] = DKR_HACK.N64_KEYS_LOCATION,
            [BIT] = 4
        },
    },
    [WIZPIG_AMULET_PIECE] = {
        ["1616210"] = { -- Tricky 2
            [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_2,
            [BIT] = 7
        },
        ["1616310"] = { -- Bluey 2
            [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_1,
            [BIT] = 1
        },
        ["1616410"] = { -- Bubbler 2
            [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_1,
            [BIT] = 0
        },
        ["1616510"] = { -- Smokey 2
            [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_1,
            [BIT] = 2
        },
    },
    [TT_AMULET_PIECE] = {
        ["1616209"] = { -- Fire Mountain
            [BYTE] = DKR_RAM.ADDRESS.FIRE_MOUNTAIN,
            [BIT] = 1
        },
        ["1616309"] = { -- Icicle Pyramid
            [BYTE] = DKR_RAM.ADDRESS.ICICLE_PYRAMID,
            [BIT] = 1
        },
        ["1616409"] = { -- Darkwater Beach
            [BYTE] = DKR_RAM.ADDRESS.DARKWATER_BEACH,
            [BIT] = 1
        },
        ["1616509"] = { -- Smokey Castle
            [BYTE] = DKR_RAM.ADDRESS.SMOKEY_CASTLE,
            [BIT] = 1
        },
    }
}

local VICTORY_CONDITION_TO_ADDRESS = {
    [0] = { -- Wizpig 1
        [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_2,
        [BIT] = 0
    },
    [1] = { -- Wizpig 2
        [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_2,
        [BIT] = 5
    }
}

function DKR_RAM:new(t)
    t = t or {}
    setmetatable(t, self)
    self.__index = self
   return self
end

function DKR_RAM:is_file_loaded()
    return self:check_flag(DKR_RAM.ADDRESS.FILE_LOADED, 0, "File loaded check")
end

function DKR_RAM:check_flag(byte, _bit)
    local currentValue = mainmemory.readbyte(byte)

    return bit.check(currentValue, _bit)
end

function DKR_RAM:set_flag(byte, _bit)
    local currentValue = mainmemory.readbyte(byte)
    mainmemory.writebyte(byte, bit.set(currentValue, _bit))
end

function DKR_RAM:get_value(byte)
    return mainmemory.readbyte(byte)
end

function DKR_RAM:set_value(byte, value)
    return mainmemory.writebyte(byte, value)
end

function DKR_RAM:increment_counter(byte)
    local currentValue = mainmemory.readbyte(byte)
    mainmemory.writebyte(byte, currentValue + 1)
end

function DKR_RAM:decrement_counter(byte)
    local currentValue = mainmemory.readbyte(byte)
    mainmemory.writebyte(byte, currentValue - 1)
end

function DKR_RAM:check_ramhack_flag(byte, _bit)
    return DKR_RAM:check_flag(hackPointerIndex + byte, _bit)
end

function DKR_RAM:get_ramhack_value(byte)
    return DKR_RAM:get_value(hackPointerIndex + byte)
end

function DKR_RAM:set_ramhack_value(byte, value)
    return DKR_RAM:set_value(hackPointerIndex + byte, value)
end

function DKR_RAM:increment_ramhack_counter(byte)
    local current_value = DKR_RAM:get_ramhack_value(byte)
    DKR_RAM:set_ramhack_value(byte, current_value + 1)
end

function DKR_RAM:dereferencePointer(addr)
    if type(addr) == "number" and addr >= 0 and addr < (self.RDRAM_SIZE - 4) then
        local address = mainmemory.read_u32_be(addr);
        if self:isPointer(address) then
            return address - self.RDRAM_BASE;
        end
    end
end

function DKR_RAM:isPointer(value)
    return type(value) == "number" and value >= self.RDRAM_BASE and value < self.RDRAM_BASE + self.RDRAM_SIZE;
end

function main()
    local bizhawk_version = client.getversion()
    if bizhawk_version ~= REQUIRED_BIZHAWK_VERSION then
        print("Incorrect BizHawk version: " .. bizhawk_version)
        print("Please use version " .. REQUIRED_BIZHAWK_VERSION .. " instead")
        return
    end

    if gameinfo.getromhash() ~= "960691CF5E2A81C0D8293C9904F02FC90C603CB1" then
        print("Incorrect ROM hash, make sure you're running the patched Diddy Kong Racing ROM")
        return
    end

    print("Diddy Kong Racing Archipelago Version: " .. APWORLD_VERSION)
    print("----------------")
    server, error = socket.bind("localhost", 21221)
    DKR_RAMOBJ = DKR_RAM:new(nil)
    hackPointerIndex = DKR_RAMOBJ:dereferencePointer(DKR_HACK.BASE_INDEX)

    event.onframeend(handle_frame)
end

function handle_frame()
    frame = frame + 1
    if current_state == STATE_OK
            or current_state == STATE_INITIAL_CONNECTION_MADE
            or current_state == STATE_TENTATIVELY_CONNECTED then
        if frame % 60 == 1 then
            local new_map = DKR_RAMOBJ:get_value(DKR_RAM.ADDRESS.CURRENT_MAP)
            if new_map == 0x17 then
                DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.CHARACTER_UNLOCKS, 0) -- Unlock T.T.
                DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.CHARACTER_UNLOCKS, 1) -- Unlock Drumstick
            end
            if new_map ~= current_map then
                current_map = new_map
                client.saveram()
            end
            receive()
            display_next_message_if_no_message_displayed()
        elseif frame % 10 == 1 then
            check_if_in_save_file()
            if not init_complete then
                initialize_flags()
            end

            if init_complete then
                update_totals_if_paused()
                dpad_stats()
            end
        end
    elseif current_state == STATE_UNINITIALIZED then
        if  frame % 60 == 1 then
            server:settimeout(2)
            local client, timeout = server:accept()

            if timeout == nil then
                print("Initial connection made")
                print("----------------")

                current_state = STATE_INITIAL_CONNECTION_MADE
                DKR_SOCK = client
                DKR_SOCK:settimeout(0)
            else
                print("ERROR: Connection failed, ensure Diddy Kong Racing Client is running, connected and rerun connector_diddy_kong_racing.lua")
                print("----------------")

                return
            end
        end
    end
end

function check_if_in_save_file()
    local in_save_file_1 = DKR_RAMOBJ:get_value(DKR_RAM.ADDRESS.IN_SAVE_FILE_1) ~= 0
    local in_save_file_2 = DKR_RAMOBJ:get_value(DKR_RAM.ADDRESS.IN_SAVE_FILE_2) ~= 0
    local in_save_file_3 = DKR_RAMOBJ:get_value(DKR_RAM.ADDRESS.IN_SAVE_FILE_3) ~= 0

    if in_save_file then
        if not (in_save_file_1 and in_save_file_2 and in_save_file_3) then
            print("Exited save file")
            print("----------------")
            in_save_file = false
            init_complete = false
            in_save_file_counter = 0
        end
    else
        if in_save_file_1 and in_save_file_2 and in_save_file_3 then
            if in_save_file_counter == 6 then
                print("Entered save file")
                print("D-PAD UP to see collected regional balloons and keys")
                print("----------------")
                in_save_file = true
            else
                in_save_file_counter = in_save_file_counter + 1
            end
        end
    end
end

function initialize_flags()
    if slot_loaded and in_save_file then
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.VICTORY_CONDITION, victory_condition)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.OPEN_WORLDS, open_worlds and 1 or 0)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.SHUFFLE_WIZPIG_AMULET, shuffle_wizpig_amulet and 1 or 0)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.SHUFFLE_TT_AMULET, shuffle_tt_amulet and 1 or 0)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.DOOR_PROGRESSION, door_requirement_progression)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.MAX_DOOR_REQUIREMENT, maximum_door_requirement)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.SHUFFLE_DOOR_REQUIREMENTS, shuffle_door_requirements and 1 or 0)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.BOSS_1_REGIONAL_BALLOONS, boss_1_regional_balloons)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.BOSS_2_REGIONAL_BALLOONS, boss_2_regional_balloons)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.WIZPIG_1_AMULET_PIECES, wizpig_1_amulet_pieces)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.WIZPIG_2_AMULET_PIECES, wizpig_2_amulet_pieces)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.WIZPIG_2_BALLOONS, wizpig_2_balloons)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.SKIP_TROPHY_RACES, skip_trophy_races and 1 or 0)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.RANDOMIZE_CHARACTER_ON_MAP_CHANGE, randomize_character_on_map_change and 1 or 0)

        if door_unlock_requirements then
            for i, requirement in pairs(door_unlock_requirements) do
                local ramhack_door_offset
                if i < 5 then
                    -- Convert from 1-indexed to 0-indexed
                    ramhack_door_offset = i - 1
                else
                    -- Skip Future Fun Land door cost
                    ramhack_door_offset = i
                end
                DKR_RAMOBJ:set_ramhack_value(DKR_HACK.DOOR_COSTS + ramhack_door_offset, requirement)
            end
        end

        if (power_up_balloon_type ~= 0) then
            DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.CHANGE_BALLOONS, 1)

            local setting_to_value = {
                [1] = 5,
                [2] = 6,
                [3] = 0,
                [4] = 1,
                [5] = 2,
                [6] = 3,
                [7] = 4
            }
            DKR_RAMOBJ:set_ramhack_value(DKR_HACK.SETTINGS + DKR_HACK.BALLOON_TYPE, setting_to_value[power_up_balloon_type])
        end

        set_races_as_visited()
        update_in_game_totals()
		init_complete = true
	end
end

function set_races_as_visited()
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.ANCIENT_LAKE, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.FOSSIL_CANYON, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.JUNGLE_FALLS, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.HOT_TOP_VOLCANO, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.EVERFROST_PEAK, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.WALRUS_COVE, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.SNOWBALL_VALLEY, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.FROSTY_VILLAGE, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.WHALE_BAY, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.CRESCENT_ISLAND, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.PIRATE_LAGOON, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TREASURE_CAVES, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.WINDMILL_PLAINS, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.GREENWOOD_VILLAGE, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.BOULDER_CANYON, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.HAUNTED_WOODS, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.SPACEDUST_ALLEY, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.DARKMOON_CAVERNS, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.SPACEPORT_ALPHA, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.STAR_CITY, 0)
end

function update_totals_if_paused()
    local new_paused = DKR_RAMOBJ:check_flag(DKR_RAM.ADDRESS.PAUSED, 0)

    if new_paused and not paused then
        update_in_game_totals()
    end

    paused = new_paused
end

function update_in_game_totals()
    for item_id, ramhack_item_index in pairs(ITEM_ID_TO_RAMHACK_ITEM_INDEX) do
        local received_item_count = get_received_item_count(item_id)
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.ITEMS + ramhack_item_index, received_item_count)
    end
end

function dpad_stats()
    local check_controls = joypad.get()

    if check_controls then
        if check_controls['P1 DPad U'] then
            print("Dino Domain balloons: " .. get_received_item_count(ITEM_IDS.DINO_DOMAIN_BALLOON))
            print("Snowflake Mountain balloons: " .. get_received_item_count(ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON))
            print("Sherbet Island balloons: " .. get_received_item_count(ITEM_IDS.SHERBET_ISLAND_BALLOON))
            print("Dragon Forest balloons: " .. get_received_item_count(ITEM_IDS.DRAGON_FOREST_BALLOON))
            print("")
            print("Keys:")
            if get_received_item_count(ITEM_IDS.FIRE_MOUNTAIN_KEY) > 0 then
                print("Fire Mountain")
            end
            if get_received_item_count(ITEM_IDS.ICICLE_PYRAMID_KEY) > 0 then
                print("Icicle Pyramid")
            end
            if get_received_item_count(ITEM_IDS.DARKWATER_BEACH_KEY) > 0 then
                print("Darkwater Beach")
            end
            if get_received_item_count(ITEM_IDS.SMOKEY_CASTLE_KEY) > 0 then
                print("Smokey Castle")
            end
            print("")
            print("Wizpig amulet pieces: " .. get_received_item_count(ITEM_IDS.WIZPIG_AMULET_PIECE))
            print("T.T. amulet pieces: " .. get_received_item_count(ITEM_IDS.TT_AMULET_PIECE))
            print("----------------")
        end
    end
end

function get_local_checks()
    local checks = {}
    for check_type, location in pairs(ITEM_TO_LOCATION_ADDRESSES) do
        for location_id, table in pairs(location) do
            if not checks[check_type] then
                checks[check_type] = {}
            end

            local is_collected
            if check_type == FIRE_MOUNTAIN_KEY or check_type == ICICLE_PYRAMID_KEY or check_type == DARKWATER_BEACH_KEY or check_type == SMOKEY_CASTLE_KEY then
                is_collected = DKR_RAMOBJ:check_ramhack_flag(table[BYTE], table[BIT])
            else
                is_collected = DKR_RAMOBJ:check_flag(table[BYTE], table[BIT])
            end

            checks[check_type][location_id] = is_collected
        end
    end

    previous_checks = checks

    return checks
end

function get_received_item_count(item_id)
    local received_item_count = 0
    for _, item in pairs(receive_map) do
        if item == tostring(item_id) then
            received_item_count = received_item_count + 1
        end
    end

    return received_item_count
end

function receive()
    if not player and not seed then
        get_slot_data()
    else
        send_to_dkr_client()

        response, error = DKR_SOCK:receive()
        if error == "closed" then
            if current_state == STATE_OK then
                print("Connection closed")
                print("----------------")
            end

            current_state = STATE_UNINITIALIZED

            return
        elseif error == "timeout" then
            return
        elseif error then
            print(error)
            print("----------------")
            current_state = STATE_UNINITIALIZED

            return
        end

        process_block(json.decode(response))
    end
end

function get_slot_data()
    local retTable = {}
    retTable["getSlot"] = true

    local message = json.encode(retTable) .. "\n"
    DKR_SOCK:send(message)
    response, error = DKR_SOCK:receive()

    if error == "closed" then
        if current_state == STATE_OK then
            print("Connection closed")
            print("----------------")
        end

        current_state = STATE_UNINITIALIZED

        return
    elseif error == "timeout" then
        return
    elseif error then
        print(error)
        print("----------------")

        current_state = STATE_UNINITIALIZED

        return
    end

    process_slot(json.decode(response))
end

function process_slot(block)
    if block["slot_player"] and block["slot_player"] ~= "" then
        player = block["slot_player"]
    end

    if block["slot_seed"] and block["slot_seed"] ~= "" then
        seed = block["slot_seed"]
    end

    if block["slot_victory_condition"] and block["slot_victory_condition"] ~= "" then
        victory_condition = block["slot_victory_condition"]
    end

    if block["slot_shuffle_wizpig_amulet"] and block["slot_shuffle_wizpig_amulet"] == "true" then
        shuffle_wizpig_amulet = true
    else
        shuffle_wizpig_amulet = false
    end

    if block["slot_shuffle_tt_amulet"] and block["slot_shuffle_tt_amulet"] == "true" then
        shuffle_tt_amulet = true
    else
        shuffle_tt_amulet = false
    end

    if block["slot_open_worlds"] and block["slot_open_worlds"] == "true" then
        open_worlds = true
    else
        open_worlds = false
    end

    if block["slot_door_unlock_requirements"] and next(block["slot_door_unlock_requirements"]) ~= nil then
        door_unlock_requirements = block["slot_door_unlock_requirements"]
    end

    if block["slot_door_requirement_progression"] and block["slot_door_requirement_progression"] ~= "" then
        door_requirement_progression = block["slot_door_requirement_progression"]
    end

    if block["slot_maximum_door_requirement"] and block["slot_maximum_door_requirement"] ~= "" then
        slot_maximum_door_requirement = block["slot_maximum_door_requirement"]
    end

    if block["slot_shuffle_door_requirements"] and block["slot_shuffle_door_requirements"] == "true" then
        shuffle_door_requirements = true
    else
        shuffle_door_requirements = false
    end

    if block["slot_boss_1_regional_balloons"] and block["slot_boss_1_regional_balloons"] ~= "" then
        boss_1_regional_balloons = block["slot_boss_1_regional_balloons"]
    end

    if block["slot_boss_2_regional_balloons"] and block["slot_boss_2_regional_balloons"] ~= "" then
        boss_2_regional_balloons = block["slot_boss_2_regional_balloons"]
    end

    if block["slot_wizpig_1_amulet_pieces"] and block["slot_wizpig_1_amulet_pieces"] ~= "" then
        wizpig_1_amulet_pieces = block["slot_wizpig_1_amulet_pieces"]
    end

    if block["slot_wizpig_2_amulet_pieces"] and block["slot_wizpig_2_amulet_pieces"] ~= "" then
        wizpig_2_amulet_pieces = block["slot_wizpig_2_amulet_pieces"]
    end

    if block["slot_wizpig_2_balloons"] and block["slot_wizpig_2_balloons"] ~= "" then
        wizpig_2_balloons = block["slot_wizpig_2_balloons"]
    end

    if block["slot_skip_trophy_races"] and block["slot_skip_trophy_races"] == "true" then
        skip_trophy_races = true
    else
        skip_trophy_races = false
    end

    if block["slot_randomize_character_on_map_change"] and block["slot_randomize_character_on_map_change"] == "true" then
        randomize_character_on_map_change = true
    else
        randomize_character_on_map_change = false
    end

    if block["slot_power_up_balloon_type"] and block["slot_power_up_balloon_type"] ~= "" then
        power_up_balloon_type = block["slot_power_up_balloon_type"]
    end

    if seed then
        slot_loaded = true
    else
        return false
    end

    return true
end

function send_to_dkr_client()
    local retTable = {}
    retTable["playerName"] = player
    retTable["locations"] = get_local_checks()
    retTable["gameComplete"] = is_game_complete()
    retTable["currentMap"] = current_map

    if not in_save_file then
        retTable["sync_ready"] = "false"
    else
        retTable["sync_ready"] = "true"
    end

    local message = json.encode(retTable) .. "\n"
    local response, error = DKR_SOCK:send(message)
    if not response then
        print(error)
        print("----------------")
    elseif current_state == STATE_INITIAL_CONNECTION_MADE then
        current_state = STATE_TENTATIVELY_CONNECTED
    elseif current_state == STATE_TENTATIVELY_CONNECTED then
        print("Connected!")
        print("----------------")

        current_state = STATE_OK
    end
end

function is_game_complete()
    if victory_condition and in_save_file then
        local victory_condition_address = VICTORY_CONDITION_TO_ADDRESS[victory_condition]
        if DKR_RAM:check_flag(victory_condition_address[BYTE], victory_condition_address[BIT]) then
            return "true"
        end
    end
    return "false"
end

function process_block(block)
    if not block then
        return
    end

    if block["slot_player"] then
        return
    end

    if next(block["items"]) then
        process_item((block["items"]))
    end

    if next(block["messages"]) then
        process_messages(block["messages"])
    end
end

function process_item(item_list)
    local new_item_received = false
    for ap_id, item_id in pairs(item_list) do
        if not receive_map[tostring(ap_id)] then
            receive_map[tostring(ap_id)] = tostring(item_id)
            new_item_received = true

            local index = ITEM_ID_TO_RAMHACK_ITEM_INDEX[item_id]
            local item_count = DKR_RAMOBJ:increment_ramhack_counter(DKR_HACK.ITEMS + index)
        end
    end

    if new_item_received then
        client.saveram()
    end
end

function process_messages(messages)
    for _, message in pairs(messages) do
        if message["to_player"] == player then
            local message_start
            if message["from_player"] == player then
                message_start = "You found"
            else
                message_start = "Received"
            end

            local item_id = message["item_id"]
            local message_article
            if  item_id == ITEM_IDS.FIRE_MOUNTAIN_KEY or item_id == ITEM_IDS.ICICLE_PYRAMID_KEY or item_id == ITEM_IDS.DARKWATER_BEACH_KEY or item_id == ITEM_IDS.SMOKEY_CASTLE_KEY then
                message_article = "the"
            else
                message_article = "a"
            end

            local item_name = message["item_name"]
            add_message_to_queue(string.format("%s %s %s", message_start, message_article, item_name));
        end
    end
end

function add_message_to_queue(message)
    table.insert(message_queue, message)
end

function display_next_message_if_no_message_displayed()
    local n64_processed_message_count = DKR_RAMOBJ:get_ramhack_value(DKR_HACK.N64_PROCESSED_MESSAGE_COUNT)
    local n64_received_message_count = DKR_RAMOBJ:get_ramhack_value(DKR_HACK.N64_RECEIVED_MESSAGE_COUNT)
    if n64_processed_message_count == n64_received_message_count then
        local displayed_message_id
        for id, message in pairs(message_queue) do
            display_message(message)
            displayed_message_id = id
            break
        end
        if displayed_message_id then
            table.remove(message_queue, displayed_message_id)
        end
    end
end

function display_message(message)
    local num_bytes_written = 0
    local message_length = math.min(string.len(message), DKR_HACK.MAX_MESSAGE_BYTES)
    for i = 0, message_length - 1 do
        DKR_RAMOBJ:set_ramhack_value(DKR_HACK.MESSAGE_TEXT + i, message:byte(i + 1));
        num_bytes_written = num_bytes_written + 1
    end
    DKR_RAMOBJ:set_ramhack_value(DKR_HACK.MESSAGE_TEXT + num_bytes_written, 0);
    n64_sent_message_count = n64_sent_message_count + 1
    DKR_RAMOBJ:set_ramhack_value(DKR_HACK.N64_RECEIVED_MESSAGE_COUNT, n64_sent_message_count);
end

main()
