-- Diddy Kong Racing Connector Lua
-- Adapted by zakwiz from the Banjo-Tooie Connector Lua

-- Banjo-Tooie Connector Lua by Mike Jackson (jjjj12212) with the help of Rose (Oktorose),
-- the OOT Archipelago team, ScriptHawk BT.lua & kaptainkohl for BTrando.lua, modifications from Unalive & HemiJackson

require('common')
local socket = require("socket")
local json = require('json')

local APWORLD_VERSION = "DKRv0.5.2"
local REQUIRED_BIZHAWK_VERSION = "2.10"

local player
local seed
local victory_condition
local open_worlds
local door_unlock_requirements
local boss_1_regional_balloons
local boss_2_regional_balloons
local wizpig_1_amulet_pieces
local wizpig_2_amulet_pieces
local wizpig_2_balloons
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
local force_wizpig_2_door = false

local DKR_SOCK
local DKR_RAMOBJ

local amm = {}
local agi = {}
local receive_map = {}
local previous_checks

local BYTE = "BYTE"
local BIT = "BIT"
local RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX = "RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX"
local RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX = "RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX"
local RACE_1_COMPLETION_ADDRESS = "RACE_1_COMPLETION_ADDRESS"
local RACE_2_COMPLETION_ADDRESS = "RACE_2_COMPLETION_ADDRESS"

local DOOR_NAMES = {
    DINO_DOMAIN = "DINO_DOMAIN",
    SNOWFLAKE_MOUNTAIN = "SNOWFLAKE_MOUNTAIN",
    SHERBET_ISLAND = "SHERBET_ISLAND",
    DRAGON_FOREST = "DRAGON_FOREST",
    ANCIENT_LAKE = "ANCIENT_LAKE",
    FOSSIL_CANYON = "FOSSIL_CANYON",
    JUNGLE_FALLS = "JUNGLE_FALLS",
    HOT_TOP_VOLCANO = "HOT_TOP_VOLCANO",
    EVERFROST_PEAK = "EVERFROST_PEAK",
    WALRUS_COVE = "WALRUS_COVE",
    SNOWBALL_VALLEY = "SNOWBALL_VALLEY",
    FROSTY_VILLAGE = "FROSTY_VILLAGE",
    WHALE_BAY = "WHALE_BAY",
    CRESCENT_ISLAND = "CRESCENT_ISLAND",
    PIRATE_LAGOON = "PIRATE_LAGOON",
    TREASURE_CAVES = "TREASURE_CAVES",
    WINDMILL_PLAINS = "WINDMILL_PLAINS",
    GREENWOOD_VILLAGE = "GREENWOOD_VILLAGE",
    BOULDER_CANYON = "BOULDER_CANYON",
    HAUNTED_WOODS = "HAUNTED_WOODS",
    SPACEDUST_ALLEY = "SPACEDUST_ALLEY",
    DARKMOON_CAVERNS = "DARKMOON_CAVERNS",
    SPACEPORT_ALPHA = "SPACEPORT_ALPHA",
    STAR_CITY = "STAR_CITY"
}

local WORLD_DOOR_NAMES = {
    [DOOR_NAMES.DINO_DOMAIN] = true,
    [DOOR_NAMES.SNOWFLAKE_MOUNTAIN] = true,
    [DOOR_NAMES.SHERBET_ISLAND] = true,
    [DOOR_NAMES.DRAGON_FOREST] = true
}

local ITEM_GROUPS = {
    TIMBERS_ISLAND_BALLOON = "TIMBERS_ISLAND_BALLOON",
    DINO_DOMAIN_BALLOON = "DINO_DOMAIN_BALLOON",
    SNOWFLAKE_MOUNTAIN_BALLOON = "SNOWFLAKE_MOUNTAIN_BALLOON",
    SHERBET_ISLAND_BALLOON = "SHERBET_ISLAND_BALLOON",
    DRAGON_FOREST_BALLOON = "DRAGON_FOREST_BALLOON",
    FUTURE_FUN_LAND_BALLOON = "FUTURE_FUN_LAND_BALLOON",
    KEY = "KEY",
    WIZPIG_AMULET_PIECE = "WIZPIG_AMULET_PIECE",
    TT_AMULET_PIECE = "TT_AMULET_PIECE"
}

local door_open_states = {
    [DOOR_NAMES.DINO_DOMAIN] = false,
    [DOOR_NAMES.SNOWFLAKE_MOUNTAIN] = false,
    [DOOR_NAMES.SHERBET_ISLAND] = false,
    [DOOR_NAMES.DRAGON_FOREST] = false,
    [DOOR_NAMES.ANCIENT_LAKE] = false,
    [DOOR_NAMES.FOSSIL_CANYON] = false,
    [DOOR_NAMES.JUNGLE_FALLS] = false,
    [DOOR_NAMES.HOT_TOP_VOLCANO] = false,
    [DOOR_NAMES.EVERFROST_PEAK] = false,
    [DOOR_NAMES.WALRUS_COVE] = false,
    [DOOR_NAMES.SNOWBALL_VALLEY] = false,
    [DOOR_NAMES.FROSTY_VILLAGE] = false,
    [DOOR_NAMES.WHALE_BAY] = false,
    [DOOR_NAMES.CRESCENT_ISLAND] = false,
    [DOOR_NAMES.PIRATE_LAGOON] = false,
    [DOOR_NAMES.TREASURE_CAVES] = false,
    [DOOR_NAMES.WINDMILL_PLAINS] = false,
    [DOOR_NAMES.GREENWOOD_VILLAGE] = false,
    [DOOR_NAMES.BOULDER_CANYON] = false,
    [DOOR_NAMES.HAUNTED_WOODS] = false,
    [DOOR_NAMES.SPACEDUST_ALLEY] = false,
    [DOOR_NAMES.DARKMOON_CAVERNS] = false,
    [DOOR_NAMES.SPACEPORT_ALPHA] = false,
    [DOOR_NAMES.STAR_CITY] = false
}

DKR_RAM = {
    ADDRESS = {
        IN_SAVE_FILE_1 = 0x214E72,
        IN_SAVE_FILE_2 = 0x214E76,
        IN_SAVE_FILE_3 = 0x21545A,
        PAUSED = 0x115F79,
        CHARACTER_UNLOCKS = 0x0DFD9B,
        CURRENT_MAP = 0x121167,
        TOTAL_BALLOON_COUNT = 0x1FCBED,
        DINO_DOMAIN_BALLOON_COUNT = 0x1FCBEF,
        SNOWFLAKE_MOUNTAIN_BALLOON_COUNT = 0x1FCBF3,
        SHERBET_ISLAND_BALLOON_COUNT = 0x1FCBF1,
        DRAGON_FOREST_BALLOON_COUNT = 0x1FCBF5,
        FUTURE_FUN_LAND_BALLOON_COUNT = 0x1FCBF7,
        TIMBERS_ISLAND_BALLOONS_AND_DOORS_1 = 0x1FCAE8,
        TIMBERS_ISLAND_BALLOONS_AND_DOORS_2 = 0x1FCAE9,
        DINO_DOMAIN_DOORS_1 = 0x1FCB18,
        DINO_DOMAIN_DOORS_2 = 0x1FCB19,
        SNOWFLAKE_MOUNTAIN_DOORS_1 = 0x1FCB48,
        SNOWFLAKE_MOUNTAIN_DOORS_2 = 0x1FCB49,
        SHERBET_ISLAND_DOORS_1 = 0x1FCB20,
        SHERBET_ISLAND_DOORS_2 = 0x1FCB21,
        DRAGON_FOREST_DOORS_1 = 0x1FCAF0,
        DRAGON_FOREST_DOORS_2 = 0x1FCAF1,
        FUTURE_FUN_LAND_DOORS_1 = 0x1FCB74,
        FUTURE_FUN_LAND_DOORS_2 = 0x1FCB75,
        BOSS_COMPLETION_1 = 0x1FC9DC,
        BOSS_COMPLETION_2 = 0x1FC9DD,
        WIZPIG_AMULET = 0x1FC9E7,
        TT_AMULET = 0x1FC9E6,
        TROPHIES_1 = 0x1FC9DE,
        TROPHIES_2 = 0x1FC9DF,
        KEYS = 0x1FC9D9,
        FUTURE_FUN_LAND_FLAGS = 0x1FC9E3,
        WIZPIG_2_LEFT_DOOR_ANGLE = 0x1EAD90,
        WIZPIG_2_RIGHT_DOOR_ANGLE = 0x1EABB0,
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

local BALLOON_ITEM_GROUP_TO_ITEM_ID = {
    [ITEM_GROUPS.TIMBERS_ISLAND_BALLOON] = ITEM_IDS.TIMBERS_ISLAND_BALLOON,
    [ITEM_GROUPS.DINO_DOMAIN_BALLOON] = ITEM_IDS.DINO_DOMAIN_BALLOON,
    [ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON] = ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON,
    [ITEM_GROUPS.SHERBET_ISLAND_BALLOON] = ITEM_IDS.SHERBET_ISLAND_BALLOON,
    [ITEM_GROUPS.DRAGON_FOREST_BALLOON] = ITEM_IDS.DRAGON_FOREST_BALLOON,
    [ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON] = ITEM_IDS.FUTURE_FUN_LAND_BALLOON,
}

local BALLOON_ITEM_ID_TO_COUNT_ADDRESS = {
    [ITEM_IDS.TIMBERS_ISLAND_BALLOON] = true,
    [ITEM_IDS.DINO_DOMAIN_BALLOON] = DKR_RAM.ADDRESS.DINO_DOMAIN_BALLOON_COUNT,
    [ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_BALLOON_COUNT,
    [ITEM_IDS.SHERBET_ISLAND_BALLOON] = DKR_RAM.ADDRESS.SHERBET_ISLAND_BALLOON_COUNT,
    [ITEM_IDS.DRAGON_FOREST_BALLOON] = DKR_RAM.ADDRESS.DRAGON_FOREST_BALLOON_COUNT,
    [ITEM_IDS.FUTURE_FUN_LAND_BALLOON] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_BALLOON_COUNT
}

local BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS = {
    [ITEM_IDS.DINO_DOMAIN_BALLOON] = {
        [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_2,
        [BIT] = 1
    },
    [ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON] = {
        [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_2,
        [BIT] = 3
    },
    [ITEM_IDS.SHERBET_ISLAND_BALLOON] = {
        [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_2,
        [BIT] = 2
    },
    [ITEM_IDS.DRAGON_FOREST_BALLOON] = {
        [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_2,
        [BIT] = 4
    }
}

local KEY_ITEM_ID_TO_DOOR_ADDRESS_INFO = {
    [ITEM_IDS.FIRE_MOUNTAIN_KEY] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DINO_DOMAIN_DOORS_1,
            [BIT] = 1
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.DINO_DOMAIN_DOORS_2,
            [BIT] = 0
        }
    },
    [ITEM_IDS.ICICLE_PYRAMID_KEY] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_DOORS_1,
            [BIT] = 7
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_DOORS_2,
            [BIT] = 0
        }
    },
    [ITEM_IDS.DARKWATER_BEACH_KEY] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SHERBET_ISLAND_DOORS_2,
            [BIT] = 4
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.SHERBET_ISLAND_DOORS_2,
            [BIT] = 7
        }
    },
    [ITEM_IDS.SMOKEY_CASTLE_KEY] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DRAGON_FOREST_DOORS_1,
            [BIT] = 0
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.DRAGON_FOREST_DOORS_2,
            [BIT] = 7
        }
    }
}

local DOOR_TO_ADDRESS_INFO = {
    [DOOR_NAMES.DINO_DOMAIN] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 0
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 1
        }
    },
    [DOOR_NAMES.SNOWFLAKE_MOUNTAIN] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 5
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 7
        }
    },
    [DOOR_NAMES.SHERBET_ISLAND] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 4
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 5
        }
    },
    [DOOR_NAMES.DRAGON_FOREST] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 1
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 0
        }
    },
    [DOOR_NAMES.ANCIENT_LAKE] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DINO_DOMAIN_DOORS_2,
            [BIT] = 2
        }
    },
    [DOOR_NAMES.FOSSIL_CANYON] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DINO_DOMAIN_DOORS_2,
            [BIT] = 1
        }
    },
    [DOOR_NAMES.JUNGLE_FALLS] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DINO_DOMAIN_DOORS_2,
            [BIT] = 3
        }
    },
    [DOOR_NAMES.HOT_TOP_VOLCANO] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DINO_DOMAIN_DOORS_2,
            [BIT] = 6
        }
    },
    [DOOR_NAMES.EVERFROST_PEAK] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_DOORS_2,
            [BIT] = 3
        }
    },
    [DOOR_NAMES.WALRUS_COVE] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_DOORS_2,
            [BIT] = 5
        }
    },
    [DOOR_NAMES.SNOWBALL_VALLEY] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_DOORS_2,
            [BIT] = 2
        }
    },
    [DOOR_NAMES.FROSTY_VILLAGE] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_DOORS_2,
            [BIT] = 1
        }
    },
    [DOOR_NAMES.WHALE_BAY] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SHERBET_ISLAND_DOORS_2,
            [BIT] = 0
        }
    },
    [DOOR_NAMES.CRESCENT_ISLAND] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SHERBET_ISLAND_DOORS_2,
            [BIT] = 1
        }
    },
    [DOOR_NAMES.PIRATE_LAGOON] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SHERBET_ISLAND_DOORS_2,
            [BIT] = 2
        }
    },
    [DOOR_NAMES.TREASURE_CAVES] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SHERBET_ISLAND_DOORS_2,
            [BIT] = 3
        }
    },
    [DOOR_NAMES.WINDMILL_PLAINS] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DRAGON_FOREST_DOORS_2,
            [BIT] = 2
        }
    },
    [DOOR_NAMES.GREENWOOD_VILLAGE] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DRAGON_FOREST_DOORS_2,
            [BIT] = 0
        }
    },
    [DOOR_NAMES.BOULDER_CANYON] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DRAGON_FOREST_DOORS_2,
            [BIT] = 3
        }
    },
    [DOOR_NAMES.HAUNTED_WOODS] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DRAGON_FOREST_DOORS_2,
            [BIT] = 4
        }
    },
    [DOOR_NAMES.SPACEDUST_ALLEY] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_DOORS_2,
            [BIT] = 1
        }
    },
    [DOOR_NAMES.DARKMOON_CAVERNS] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_DOORS_2,
            [BIT] = 0
        }
    },
    [DOOR_NAMES.SPACEPORT_ALPHA] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_DOORS_2,
            [BIT] = 2
        }
    },
    [DOOR_NAMES.STAR_CITY] = {
        {
            [BYTE] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_DOORS_2,
            [BIT] = 3
        }
    }
}

local AGI_MASTER_MAP = {
    [ITEM_GROUPS.TIMBERS_ISLAND_BALLOON] = {
        ["1616100"] = { -- Bridge Balloon
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 2
        },
        ["1616101"] = { -- Waterfall Balloon
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 6
        },
        ["1616102"] = { -- River Balloon
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 6
        },
        ["1616103"] = { -- Ocean Balloon
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 2
        },
        ["1616104"] = { -- Taj Car Race
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 3
        },
        ["1616105"] = { -- Taj Hovercraft Race
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 3
        },
        ["1616106"] = { -- Taj Plane Race
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 4
        }
    },
    [ITEM_GROUPS.DINO_DOMAIN_BALLOON] = {
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
    [ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON] = {
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
    [ITEM_GROUPS.SHERBET_ISLAND_BALLOON] = {
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
    [ITEM_GROUPS.DRAGON_FOREST_BALLOON] = {
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
    [ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON] = {
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
    [ITEM_GROUPS.KEY] = {
        ["1616208"] = { -- Fire Mountain Key
            [BYTE] = DKR_RAM.ADDRESS.KEYS,
            [BIT] = 1
        },
        ["1616308"] = { -- Icicle Pyramid Key
            [BYTE] = DKR_RAM.ADDRESS.KEYS,
            [BIT] = 3
        },
        ["1616408"] = { -- Darkwater Beach Key
            [BYTE] = DKR_RAM.ADDRESS.KEYS,
            [BIT] = 2
        },
        ["1616508"] = { -- Smokey Castle Key
            [BYTE] = DKR_RAM.ADDRESS.KEYS,
            [BIT] = 4
        },
    },
    [ITEM_GROUPS.WIZPIG_AMULET_PIECE] = {
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
    [ITEM_GROUPS.TT_AMULET_PIECE] = {
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

local COURSE_NAME_TO_INFO = {
    [DOOR_NAMES.ANCIENT_LAKE] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 5,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 6,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616200"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616201"]
    },
    [DOOR_NAMES.FOSSIL_CANYON] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 7,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 8,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616202"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616203"]
    },
    [DOOR_NAMES.JUNGLE_FALLS] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 9,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 10,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616204"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616205"]
    },
    [DOOR_NAMES.HOT_TOP_VOLCANO] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 11,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 12,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616206"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616207"]
    },
    [DOOR_NAMES.EVERFROST_PEAK] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 13,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 14,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616300"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616301"]
    },
    [DOOR_NAMES.WALRUS_COVE] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 15,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 16,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616302"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616303"]
    },
    [DOOR_NAMES.SNOWBALL_VALLEY] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 17,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 18,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616304"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616305"]
    },
    [DOOR_NAMES.FROSTY_VILLAGE] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 19,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 20,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616306"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616307"]
    },
    [DOOR_NAMES.WHALE_BAY] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 21,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 22,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616400"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616401"]
    },
    [DOOR_NAMES.CRESCENT_ISLAND] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 23,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 24,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616402"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616403"]
    },
    [DOOR_NAMES.PIRATE_LAGOON] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 25,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 26,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616404"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616405"]
    },
    [DOOR_NAMES.TREASURE_CAVES] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 27,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 28,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616406"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616407"]
    },
    [DOOR_NAMES.WINDMILL_PLAINS] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 29,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 30,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616500"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616501"]
    },
    [DOOR_NAMES.GREENWOOD_VILLAGE] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 31,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 32,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616502"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616503"]
    },
    [DOOR_NAMES.BOULDER_CANYON] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 33,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 34,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616504"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616505"]
    },
    [DOOR_NAMES.HAUNTED_WOODS] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 35,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 36,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616506"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616507"]
    },
    [DOOR_NAMES.SPACEDUST_ALLEY] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 37,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 38,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616600"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616601"]
    },
    [DOOR_NAMES.DARKMOON_CAVERNS] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 39,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 40,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616602"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616603"]
    },
    [DOOR_NAMES.SPACEPORT_ALPHA] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 41,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 42,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616604"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616605"]
    },
    [DOOR_NAMES.STAR_CITY] = {
        [RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX] = 43,
        [RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX] = 44,
        [RACE_1_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616606"],
        [RACE_2_COMPLETION_ADDRESS] = AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616607"]
    },
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

function DKR_RAM:clear_flag(byte, _bit)
    local currentValue = mainmemory.readbyte(byte)
    mainmemory.writebyte(byte, bit.clear(currentValue, _bit))
end

function DKR_RAM:set_flag(byte, _bit)
    local currentValue = mainmemory.readbyte(byte)
    mainmemory.writebyte(byte, bit.set(currentValue, _bit))
end

function DKR_RAM:get_counter(byte)
    return mainmemory.readbyte(byte)
end

function DKR_RAM:set_counter(byte, value)
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

function main()
    local bizhawk_version = client.getversion()
    if bizhawk_version ~= REQUIRED_BIZHAWK_VERSION then
        print("Incorrect BizHawk version: " .. bizhawk_version)
        print("Please use version " .. REQUIRED_BIZHAWK_VERSION .. " instead")
        return
    end

    print("Diddy Kong Racing Archipelago Version: " .. APWORLD_VERSION)
    print("----------------")
    server, error = socket.bind("localhost", 21221)
    DKR_RAMOBJ = DKR_RAM:new(nil)

    while true do
        frame = frame + 1
        if current_state == STATE_OK
                or current_state == STATE_INITIAL_CONNECTION_MADE
                or current_state == STATE_TENTATIVELY_CONNECTED then
            if frame % 60 == 1 then
                local new_map = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.CURRENT_MAP)
                if new_map ~= current_map then
                    current_map = new_map
                    client.saveram()
                end
                receive()
            elseif frame % 10 == 1 then
                check_if_in_save_file()
                if not init_complete then
					initialize_flags()
				end

                if init_complete then
                    if door_unlock_requirements or open_worlds then
                        update_door_open_states()
                    end
                    update_totals_if_paused()
                    dpad_stats()
                end
            end

            if init_complete then
                if door_unlock_requirements or open_worlds then
                    force_doors()
                end

                if force_wizpig_2_door then
                    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.WIZPIG_2_LEFT_DOOR_ANGLE, 160)
                    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.WIZPIG_2_RIGHT_DOOR_ANGLE, 196)
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
                    print("Connection failed, ensure Diddy Kong Racing Client is running, connected and rerun connector_diddy_kong_racing.lua")
                    print("----------------")

                    return
                end
            end
        end
        emu.frameadvance()
    end
end

function check_if_in_save_file()
    local in_save_file_1 = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.IN_SAVE_FILE_1) ~= 0
    local in_save_file_2 = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.IN_SAVE_FILE_2) ~= 0
    local in_save_file_3 = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.IN_SAVE_FILE_3) ~= 0

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
                print("D-PAD RIGHT if door requirements are non-vanilla to see open uncompleted doors")
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
        all_location_checks("AMM")

        if not DKR_RAMOBJ:check_flag(DKR_RAM.ADDRESS.STAR_CITY, 0) then
            DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.CHARACTER_UNLOCKS, 0) -- Unlock T.T.
            DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.CHARACTER_UNLOCKS, 1) -- Unlock Drumstick
            DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.FUTURE_FUN_LAND_FLAGS, 7) -- Skip Wizpig 2 door entry cutscene

            set_races_as_visited()

            if open_worlds then
                DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.FUTURE_FUN_LAND_FLAGS, 0) -- Open Future Fun Land
            end

            if skip_trophy_races then
                set_trophy_flags()
            end
        end

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

function set_trophy_flags()
    -- Dino Domain
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 0)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 1)
    -- Snowflake Mountain
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 4)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 5)
    -- Sherbet Island
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 2)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 3)
    -- Dragon Forest
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 6)
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 7)
end

function update_totals_if_paused()
    local new_paused = DKR_RAMOBJ:check_flag(DKR_RAM.ADDRESS.PAUSED, 0)

    if new_paused and not paused then
        update_in_game_totals()
    end

    paused = new_paused
end

function update_in_game_totals()
    -- Balloons
    update_total_balloon_count()
    update_regional_balloon_count(ITEM_IDS.DINO_DOMAIN_BALLOON)
    update_regional_balloon_count(ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON)
    update_regional_balloon_count(ITEM_IDS.SHERBET_ISLAND_BALLOON)
    update_regional_balloon_count(ITEM_IDS.DRAGON_FOREST_BALLOON)

    -- Keys
    for key_item_id, key_door_address_info in pairs(KEY_ITEM_ID_TO_DOOR_ADDRESS_INFO) do
        if get_received_item_count(key_item_id) == 0 then
            for _, key_door_ram_address in pairs(key_door_address_info) do
                DKR_RAMOBJ:clear_flag(key_door_ram_address[BYTE], key_door_ram_address[BIT])
            end
        else
            for _, key_door_ram_address in pairs(key_door_address_info) do
                DKR_RAMOBJ:set_flag(key_door_ram_address[BYTE], key_door_ram_address[BIT])
            end
        end
    end

    -- Amulets
    update_wizpig_amulet_count()
    update_tt_amulet_count()
end

function update_door_open_states()
    total_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.TOTAL_BALLOON_COUNT)

    door_open_states[DOOR_NAMES.DINO_DOMAIN] = open_worlds or total_balloon_count >= door_unlock_requirements[1]
    door_open_states[DOOR_NAMES.SNOWFLAKE_MOUNTAIN] = open_worlds or total_balloon_count >= door_unlock_requirements[2]
    door_open_states[DOOR_NAMES.SHERBET_ISLAND] = open_worlds or total_balloon_count >= door_unlock_requirements[3]
    door_open_states[DOOR_NAMES.DRAGON_FOREST] = open_worlds or total_balloon_count >= door_unlock_requirements[4]

    if door_unlock_requirements then
        dinos_domain_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.DINO_DOMAIN_BALLOON_COUNT)
        snowflake_mountain_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_BALLOON_COUNT)
        sherbet_island_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.SHERBET_ISLAND_BALLOON_COUNT)
        dragon_forest_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.DRAGON_FOREST_BALLOON_COUNT)
        dinos_domain_boss_1_completion_address = BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS[ITEM_IDS.DINO_DOMAIN_BALLOON]
        snowflake_mountain_boss_1_completion_address = BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS[ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON]
        sherbet_island_boss_1_completion_address = BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS[ITEM_IDS.SHERBET_ISLAND_BALLOON]
        dragon_forest_boss_1_completion_address = BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS[ITEM_IDS.DRAGON_FOREST_BALLOON]

        door_open_states[DOOR_NAMES.ANCIENT_LAKE] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.ANCIENT_LAKE], dinos_domain_boss_1_completion_address)
        door_open_states[DOOR_NAMES.FOSSIL_CANYON] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.FOSSIL_CANYON], dinos_domain_boss_1_completion_address)
        door_open_states[DOOR_NAMES.JUNGLE_FALLS] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.JUNGLE_FALLS], dinos_domain_boss_1_completion_address)
        door_open_states[DOOR_NAMES.HOT_TOP_VOLCANO] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.HOT_TOP_VOLCANO], dinos_domain_boss_1_completion_address)

        door_open_states[DOOR_NAMES.EVERFROST_PEAK] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.EVERFROST_PEAK], snowflake_mountain_boss_1_completion_address)
        door_open_states[DOOR_NAMES.WALRUS_COVE] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.WALRUS_COVE], snowflake_mountain_boss_1_completion_address)
        door_open_states[DOOR_NAMES.SNOWBALL_VALLEY] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.SNOWBALL_VALLEY], snowflake_mountain_boss_1_completion_address)
        door_open_states[DOOR_NAMES.FROSTY_VILLAGE] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.FROSTY_VILLAGE], snowflake_mountain_boss_1_completion_address)

        door_open_states[DOOR_NAMES.WHALE_BAY] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.WHALE_BAY], sherbet_island_boss_1_completion_address)
        door_open_states[DOOR_NAMES.CRESCENT_ISLAND] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.CRESCENT_ISLAND], sherbet_island_boss_1_completion_address)
        door_open_states[DOOR_NAMES.PIRATE_LAGOON] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.PIRATE_LAGOON], sherbet_island_boss_1_completion_address)
        door_open_states[DOOR_NAMES.TREASURE_CAVES] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.TREASURE_CAVES], sherbet_island_boss_1_completion_address)

        door_open_states[DOOR_NAMES.WINDMILL_PLAINS] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.WINDMILL_PLAINS], dragon_forest_boss_1_completion_address)
        door_open_states[DOOR_NAMES.GREENWOOD_VILLAGE] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.GREENWOOD_VILLAGE], dragon_forest_boss_1_completion_address)
        door_open_states[DOOR_NAMES.BOULDER_CANYON] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.BOULDER_CANYON], dragon_forest_boss_1_completion_address)
        door_open_states[DOOR_NAMES.HAUNTED_WOODS] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.HAUNTED_WOODS], dragon_forest_boss_1_completion_address)

        door_open_states[DOOR_NAMES.SPACEDUST_ALLEY] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.SPACEDUST_ALLEY])
        door_open_states[DOOR_NAMES.DARKMOON_CAVERNS] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.DARKMOON_CAVERNS])
        door_open_states[DOOR_NAMES.SPACEPORT_ALPHA] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.SPACEPORT_ALPHA])
        door_open_states[DOOR_NAMES.STAR_CITY] = get_new_race_door_open_state(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.STAR_CITY])
    end
end

function get_new_race_door_open_state(total_balloon_count, course_info, boss_1_completion_address)
    return total_balloon_count >= door_unlock_requirements[course_info[RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX]]
            or total_balloon_count >= door_unlock_requirements[course_info[RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX]]
            and (boss_1_completion_address and not DKR_RAMOBJ:check_flag(boss_1_completion_address[BYTE], boss_1_completion_address[BIT])
            or not DKR_RAMOBJ:check_flag(course_info[RACE_1_COMPLETION_ADDRESS][BYTE], course_info[RACE_1_COMPLETION_ADDRESS][BIT]))
end

function force_doors()
    for door_name, door_address_info_list in pairs(DOOR_TO_ADDRESS_INFO) do
        if door_unlock_requirements or WORLD_DOOR_NAMES[door_name] then
            for _, door_address_info in pairs(door_address_info_list) do
                force_door(door_open_states[door_name], door_address_info[BYTE], door_address_info[BIT], door_name)
            end
        end
    end
end

function force_door(is_open, byte, bit, door_name)
    if is_open then
        DKR_RAMOBJ:set_flag(byte, bit)
    else
        DKR_RAMOBJ:clear_flag(byte, bit)
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
        elseif door_unlock_requirements and check_controls['P1 DPad R'] then
            total_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.TOTAL_BALLOON_COUNT)
            dinos_domain_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.DINO_DOMAIN_BALLOON_COUNT)
            snowflake_mountain_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_BALLOON_COUNT)
            sherbet_island_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.SHERBET_ISLAND_BALLOON_COUNT)
            dragon_forest_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.DRAGON_FOREST_BALLOON_COUNT)

            dinos_domain_boss_1_completion_address = BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS[ITEM_IDS.DINO_DOMAIN_BALLOON]
            snowflake_mountain_boss_1_completion_address = BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS[ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON]
            sherbet_island_boss_1_completion_address = BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS[ITEM_IDS.SHERBET_ISLAND_BALLOON]
            dragon_forest_boss_1_completion_address = BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS[ITEM_IDS.DRAGON_FOREST_BALLOON]

            print("Open uncompleted doors:")
            if door_open_states[DOOR_NAMES.DINO_DOMAIN] then
                if door_open_states[DOOR_NAMES.ANCIENT_LAKE] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.ANCIENT_LAKE], dinos_domain_boss_1_completion_address) then
                    print("DD: Ancient Lake")
                end
                if door_open_states[DOOR_NAMES.FOSSIL_CANYON] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.FOSSIL_CANYON], dinos_domain_boss_1_completion_address) then
                    print("DD: Fossil Canyon")
                end
                if door_open_states[DOOR_NAMES.JUNGLE_FALLS] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.JUNGLE_FALLS], dinos_domain_boss_1_completion_address) then
                    print("DD: Jungle Falls")
                end
                if door_open_states[DOOR_NAMES.HOT_TOP_VOLCANO] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.HOT_TOP_VOLCANO], dinos_domain_boss_1_completion_address) then
                    print("DD: Hot Top Volcano")
                end
                local fire_mountain_completion_address = AGI_MASTER_MAP[ITEM_GROUPS.TT_AMULET_PIECE]["1616209"]
                if get_received_item_count(ITEM_IDS.FIRE_MOUNTAIN_KEY) > 0 and not DKR_RAMOBJ:check_flag(fire_mountain_completion_address[BYTE], fire_mountain_completion_address[BIT]) then
                    print("DD: Fire Mountain")
                end
                if is_accessible_boss_uncompleted(dinos_domain_balloon_count, dinos_domain_boss_1_completion_address, AGI_MASTER_MAP[ITEM_GROUPS.WIZPIG_AMULET_PIECE]["1616210"]) then
                    print("DD: Tricky")
                end
            end

            if door_open_states[DOOR_NAMES.SNOWFLAKE_MOUNTAIN] then
                if door_open_states[DOOR_NAMES.EVERFROST_PEAK] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.EVERFROST_PEAK], snowflake_mountain_boss_1_completion_address) then
                    print("SM: Everfrost Peak")
                end
                if door_open_states[DOOR_NAMES.WALRUS_COVE] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.WALRUS_COVE], snowflake_mountain_boss_1_completion_address) then
                    print("SM: Walrus Cove")
                end
                if door_open_states[DOOR_NAMES.SNOWBALL_VALLEY] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.SNOWBALL_VALLEY], snowflake_mountain_boss_1_completion_address) then
                    print("SM: Snowball Valley")
                end
                if door_open_states[DOOR_NAMES.FROSTY_VILLAGE] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.FROSTY_VILLAGE], snowflake_mountain_boss_1_completion_address) then
                    print("SM: Frosty Village")
                end
                local icicle_pyramid_completion_address = AGI_MASTER_MAP[ITEM_GROUPS.TT_AMULET_PIECE]["1616309"]
                if get_received_item_count(ITEM_IDS.ICICLE_PYRAMID_KEY) > 0 and not DKR_RAMOBJ:check_flag(icicle_pyramid_completion_address[BYTE], icicle_pyramid_completion_address[BIT]) then
                    print("SM: Icicle Pyramid")
                end
                if is_accessible_boss_uncompleted(snowflake_mountain_balloon_count, snowflake_mountain_boss_1_completion_address, AGI_MASTER_MAP[ITEM_GROUPS.WIZPIG_AMULET_PIECE]["1616310"]) then
                    print("SM: Bluey")
                end
            end

            if door_open_states[DOOR_NAMES.SHERBET_ISLAND] then
                if door_open_states[DOOR_NAMES.WHALE_BAY] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.WHALE_BAY], sherbet_island_boss_1_completion_address) then
                    print("SI: Whale Bay")
                end
                if door_open_states[DOOR_NAMES.CRESCENT_ISLAND] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.CRESCENT_ISLAND], sherbet_island_boss_1_completion_address) then
                    print("SI: Crescent Island")
                end
                if door_open_states[DOOR_NAMES.PIRATE_LAGOON] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.PIRATE_LAGOON], sherbet_island_boss_1_completion_address) then
                    print("SI: Pirate Lagoon")
                end
                if door_open_states[DOOR_NAMES.TREASURE_CAVES] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.TREASURE_CAVES], sherbet_island_boss_1_completion_address) then
                    print("SI: Treasure Caves")
                end
                local darkwater_beach_completion_address = AGI_MASTER_MAP[ITEM_GROUPS.TT_AMULET_PIECE]["1616409"]
                if get_received_item_count(ITEM_IDS.DARKWATER_BEACH_KEY) > 0 and not DKR_RAMOBJ:check_flag(darkwater_beach_completion_address[BYTE], darkwater_beach_completion_address[BIT]) then
                    print("SI: Darkwater Beach")
                end
                if is_accessible_boss_uncompleted(sherbet_island_balloon_count, sherbet_island_boss_1_completion_address, AGI_MASTER_MAP[ITEM_GROUPS.WIZPIG_AMULET_PIECE]["1616410"]) then
                    print("SI: Bubbler")
                end
            end

            if door_open_states[DOOR_NAMES.DRAGON_FOREST] then
                if door_open_states[DOOR_NAMES.WINDMILL_PLAINS] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.WINDMILL_PLAINS], dragon_forest_boss_1_completion_address) then
                    print("DF: Windmill Plains")
                end
                if door_open_states[DOOR_NAMES.GREENWOOD_VILLAGE] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.GREENWOOD_VILLAGE], dragon_forest_boss_1_completion_address) then
                    print("DF: Greenwood Village")
                end
                if door_open_states[DOOR_NAMES.BOULDER_CANYON] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.BOULDER_CANYON], dragon_forest_boss_1_completion_address) then
                    print("DF: Boulder Canyon")
                end
                if door_open_states[DOOR_NAMES.HAUNTED_WOODS] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.HAUNTED_WOODS], dragon_forest_boss_1_completion_address) then
                    print("DF: Haunted Woods")
                end
                local smokey_castle_completion_address = AGI_MASTER_MAP[ITEM_GROUPS.TT_AMULET_PIECE]["1616509"]
                if get_received_item_count(ITEM_IDS.SMOKEY_CASTLE_KEY) > 0 and not DKR_RAMOBJ:check_flag(smokey_castle_completion_address[BYTE], smokey_castle_completion_address[BIT]) then
                    print("DF: Smokey Castle")
                end
                if is_accessible_boss_uncompleted(dragon_forest_balloon_count, dragon_forest_boss_1_completion_address, AGI_MASTER_MAP[ITEM_GROUPS.WIZPIG_AMULET_PIECE]["1616510"]) then
                    print("DF: Smokey")
                end
            end

            local wizpig_1_completion_address = VICTORY_CONDITION_TO_ADDRESS[0]
            if (victory_condition == 0 or not open_worlds) and DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.WIZPIG_AMULET) == 4 and not DKR_RAMOBJ:check_flag(wizpig_1_completion_address[BYTE], wizpig_1_completion_address[BIT], "Check Wizpig 1 completion for open uncompleted doors") then
                print("Wizpig 1")
            end

            if open_worlds or DKR_RAMOBJ:check_flag(wizpig_1_completion_address[BYTE], wizpig_1_completion_address[BIT], "Check Wizpig 1 completion for open uncompleted doors") then
                if door_open_states[DOOR_NAMES.SPACEDUST_ALLEY] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.SPACEDUST_ALLEY]) then
                    print("FFL: Spacedust Alley")
                end
                if door_open_states[DOOR_NAMES.DARKMOON_CAVERNS] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.DARKMOON_CAVERNS]) then
                    print("FFL: Darkmoon Caverns")
                end
                if door_open_states[DOOR_NAMES.SPACEPORT_ALPHA] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.SPACEPORT_ALPHA]) then
                    print("FFL: Spaceport Alpha")
                end
                if door_open_states[DOOR_NAMES.STAR_CITY] and is_accessible_course_uncompleted(total_balloon_count, COURSE_NAME_TO_INFO[DOOR_NAMES.STAR_CITY]) then
                    print("FFL: Star City")
                end
                local wizpig_2_completion_address = VICTORY_CONDITION_TO_ADDRESS[1]
                if total_balloon_count >= wizpig_2_balloons and DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.TT_AMULET) == 4 and not DKR_RAMOBJ:check_flag(wizpig_2_completion_address[BYTE], wizpig_2_completion_address[BIT]) then
                    print("Wizpig 2")
                end
            end
            print("----------------")
        end
    end
end

function is_accessible_course_uncompleted(total_balloon_count, course_info, boss_1_completion_address)
    return total_balloon_count >= door_unlock_requirements[course_info[RACE_2_DOOR_UNLOCK_REQUIREMENT_INDEX]] and (not boss_1_completion_address or DKR_RAMOBJ:check_flag(boss_1_completion_address[BYTE], boss_1_completion_address[BIT])) and not DKR_RAMOBJ:check_flag(course_info[RACE_2_COMPLETION_ADDRESS][BYTE], course_info[RACE_2_COMPLETION_ADDRESS][BIT])
            or total_balloon_count >= door_unlock_requirements[course_info[RACE_1_DOOR_UNLOCK_REQUIREMENT_INDEX]] and not DKR_RAMOBJ:check_flag(course_info[RACE_1_COMPLETION_ADDRESS][BYTE], course_info[RACE_1_COMPLETION_ADDRESS][BIT])
end

function is_accessible_boss_uncompleted(regional_balloon_count, boss_1_completion_address, boss_2_completion_address)
    return regional_balloon_count == 8 and not DKR_RAMOBJ:check_flag(boss_2_completion_address[BYTE], boss_2_completion_address[BIT])
            or regional_balloon_count == 4 and not DKR_RAMOBJ:check_flag(boss_1_completion_address[BYTE], boss_1_completion_address[BIT])
end

function get_local_checks()
    local checks = {}
    for check_type, location in pairs(AGI_MASTER_MAP) do
        for location_id, table in pairs(location) do
            if not checks[check_type] then
                checks[check_type] = {}
            end

            checks[check_type][location_id] = DKR_RAMOBJ:check_flag(table[BYTE], table[BIT])

            if previous_checks and checks[check_type][location_id] ~= previous_checks[check_type][location_id] then
                if BALLOON_ITEM_GROUP_TO_ITEM_ID[check_type] then
                    update_total_balloon_count()

                    balloon_item_id = BALLOON_ITEM_GROUP_TO_ITEM_ID[check_type]
                    if balloon_item_id ~= ITEM_IDS.TIMBERS_ISLAND_BALLOON then
                        update_regional_balloon_count(balloon_item_id)
                    end
                elseif check_type == ITEM_GROUPS.WIZPIG_AMULET_PIECE then
                    update_wizpig_amulet_count()
                elseif check_type == ITEM_GROUPS.TT_AMULET_PIECE then
                    update_tt_amulet_count()
                elseif check_type == ITEM_GROUPS.KEY and not amm[ITEM_GROUPS.KEY][location_id] then
                    local key_ram_address = AGI_MASTER_MAP[ITEM_GROUPS.KEY][location_id]
                    DKR_RAMOBJ:clear_flag(key_ram_address[BYTE], key_ram_address[BIT])
                end
            end
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

    if block["slot_open_worlds"] and block["slot_open_worlds"] ~= "false" then
        open_worlds = true
    end

    if block["slot_door_unlock_requirements"] and next(block["slot_door_unlock_requirements"]) ~= nil then
        door_unlock_requirements = block["slot_door_unlock_requirements"]
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

    if block["slot_skip_trophy_races"] and block["slot_skip_trophy_races"] ~= "false" then
        skip_trophy_races = true
    end

    if seed then
        load_agi()
        slot_loaded = true
    else
        return false
    end

    return true
end

function load_agi()
    local file = io.open("DKR_" .. player .. "_" .. seed .. ".AGI", "r")
    if not file then
        agi = all_location_checks("AGI")
        file = io.open("DKR_" .. player .. "_" .. seed .. ".AGI", "w")

        file:write(json.encode(agi) .. "\n")
        file:write(json.encode(receive_map))
        file:close()
    else
        agi = json.decode(file:read("l"))
        receive_map = json.decode(file:read("l"))
        file:close()
    end
end

function send_to_dkr_client()
    local retTable = {}
    retTable["playerName"] = player
    retTable["locations"] = all_location_checks("AMM")
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
        process_agi_item((block["items"]))
    end
end

function process_agi_item(item_list)
    local new_item_received = false
    for ap_id, item_id in pairs(item_list) do
        if not receive_map[tostring(ap_id)] then
            receive_map[tostring(ap_id)] = tostring(item_id)
            new_item_received = true

            if BALLOON_ITEM_ID_TO_COUNT_ADDRESS[item_id] then
                update_total_balloon_count()

                if item_id ~= ITEM_IDS.TIMBERS_ISLAND_BALLOON then
                    update_regional_balloon_count(item_id)
                end
            elseif item_id == ITEM_IDS.WIZPIG_AMULET_PIECE then
                update_wizpig_amulet_count()
            elseif item_id == ITEM_IDS.TT_AMULET_PIECE then
                update_tt_amulet_count()
            elseif KEY_ITEM_ID_TO_DOOR_ADDRESS_INFO[item_id] then
                for _, key_door_ram_address in pairs(KEY_ITEM_ID_TO_DOOR_ADDRESS_INFO[item_id]) do
                    DKR_RAMOBJ:set_flag(key_door_ram_address[BYTE], key_door_ram_address[BIT])
                end
            end

            saving_agi()
        end
    end

    if new_item_received then
        client.saveram()
    end
end

function update_total_balloon_count()
    local total_balloon_count = get_total_balloon_count()
    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.TOTAL_BALLOON_COUNT, total_balloon_count)

    if not force_wizpig_2_door and total_balloon_count >= wizpig_2_balloons and DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.TT_AMULET) == 4 then
        force_wizpig_2_door = true
    end
end

function update_regional_balloon_count(item_id)
    local actual_regional_balloon_count = get_received_item_count(item_id)
    local effective_regional_balloon_count = 0
    if actual_regional_balloon_count >= boss_2_regional_balloons then
        effective_regional_balloon_count = 8
        set_boss_1_completion(item_id)
    elseif actual_regional_balloon_count >= boss_1_regional_balloons then
        effective_regional_balloon_count = 4
    end

    DKR_RAMOBJ:set_counter(BALLOON_ITEM_ID_TO_COUNT_ADDRESS[item_id], effective_regional_balloon_count)
end

function update_wizpig_amulet_count()
    local wizpig_amulet_piece_count = get_received_item_count(ITEM_IDS.WIZPIG_AMULET_PIECE)
    local effective_wizpig_amulet_count = 0
    if wizpig_amulet_piece_count >= wizpig_1_amulet_pieces then
        effective_wizpig_amulet_count = 4
    end

    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.WIZPIG_AMULET, effective_wizpig_amulet_count)
end

function update_tt_amulet_count()
    local tt_amulet_piece_count = get_received_item_count(ITEM_IDS.TT_AMULET_PIECE)
    local effective_tt_amulet_count = 0
    if tt_amulet_piece_count >= wizpig_2_amulet_pieces then
        effective_tt_amulet_count = 4

        if not force_wizpig_2_door and get_total_balloon_count() >= wizpig_2_balloons then
            force_wizpig_2_door = true
        end
    end

    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.TT_AMULET, effective_tt_amulet_count)
end

function get_total_balloon_count()
    return get_received_item_count(ITEM_IDS.TIMBERS_ISLAND_BALLOON) +
    get_received_item_count(ITEM_IDS.DINO_DOMAIN_BALLOON) +
    get_received_item_count(ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON) +
    get_received_item_count(ITEM_IDS.SHERBET_ISLAND_BALLOON) +
    get_received_item_count(ITEM_IDS.DRAGON_FOREST_BALLOON) +
    get_received_item_count(ITEM_IDS.FUTURE_FUN_LAND_BALLOON)
end

function set_boss_1_completion(balloon_item_id)
    if BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS[balloon_item_id] then
        local boss_1_completion_address = BALLOON_ITEM_ID_TO_BOSS_1_COMPLETION_ADDRESS[balloon_item_id]
        DKR_RAMOBJ:set_flag(boss_1_completion_address[BYTE], boss_1_completion_address[BIT])
    end
end

function saving_agi()
    local file = io.open("DKR_" .. player .. "_" .. seed .. ".AGI", "w")

    file:write(json.encode(agi) .. "\n")
    file:write(json.encode(receive_map))
    file:close()
end

function all_location_checks(type)
    local local_checks = get_local_checks(type)

    if type == "AMM" then
        for item_group, locations in pairs(local_checks) do
            if amm[item_group] == nil then
                amm[item_group] = {}
            end

            for location_id, value in pairs(locations) do
                amm[item_group][location_id] = value
            end
        end
    end
    if next(agi) == nil then -- Only runs first time starting the game.
        for item_group, locations in pairs(local_checks) do
            if agi[item_group] == nil then
                agi[item_group] = {}
            end

            for location_id, value in pairs(locations) do
                agi[item_group][location_id] = value
            end
        end
    end

    return local_checks
end

main()
