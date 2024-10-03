-- Diddy Kong Racing Connector Lua
-- Adapted by zakwiz from the Banjo-Tooie Connector Lua

-- Banjo-Tooie Connector Lua by Mike Jackson (jjjj12212) with the help of Rose (Oktorose),
-- the OOT Archipelago team, ScriptHawk BT.lua & kaptainkohl for BTrando.lua, modifications from Unalive & HemiJackson

require('common')
local socket = require("socket")
local json = require('json')

local SCRIPT_VERSION = 9
local DKR_VERSION = "v0.3.0"

local player
local seed
local victory_condition
local shuffle_door_requirements
local door_unlock_requirements
local skip_trophy_races
local starting_balloon_count = 0
local starting_regional_balloon_count = 0
local starting_wizpig_amulet_piece_count = 0
local starting_tt_amulet_piece_count = 0

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
local paused = false

local debug_level_1 = false
local debug_level_2 = false
local debug_level_3 = false

local DKR_SOCK
local DKR_RAMOBJ

local amm = {}
local agi = {}
local receive_map = {}
local previous_checks

local BYTE = "byte"
local BIT = "bit"
local NAME = "name"

local door_open_states = {
    DINO_DOMAIN = false,
    SNOWFLAKE_MOUNTAIN = false,
    SHERBET_ISLAND = false,
    DRAGON_FOREST = false,
    ANCIENT_LAKE = false,
    FOSSIL_CANYON = false,
    JUNGLE_FALLS = false,
    HOT_TOP_VOLCANO = false,
    EVERFROST_PEAK = false,
    WALRUS_COVE = false,
    SNOWBALL_VALLEY = false,
    FROSTY_VILLAGE = false,
    WHALE_BAY = false,
    CRESCENT_ISLAND = false,
    PIRATE_LAGOON = false,
    TREASURE_CAVES = false,
    WINDMILL_PLAINS = false,
    GREENWOOD_VILLAGE = false,
    BOULDER_CANYON = false,
    HAUNTED_WOODS = false,
    SPACEDUST_ALLEY = false,
    DARKMOON_CAVERNS = false,
    SPACEPORT_ALPHA = false,
    STAR_CITY = false
}

DKR_RAM = {
    ADDRESS = {
        IN_SAVE_FILE_1 = 0x214E72,
        IN_SAVE_FILE_2 = 0x214E76,
        IN_SAVE_FILE_3 = 0x21545A,
        PAUSED = 0x115F79,
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

local BALLOON_ITEM_GROUP_TO_COUNT_ADDRESS = {
    [ITEM_GROUPS.TIMBERS_ISLAND_BALLOON] = true,
    [ITEM_GROUPS.DINO_DOMAIN_BALLOON] = DKR_RAM.ADDRESS.DINO_DOMAIN_BALLOON_COUNT,
    [ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_BALLOON_COUNT,
    [ITEM_GROUPS.SHERBET_ISLAND_BALLOON] = DKR_RAM.ADDRESS.SHERBET_ISLAND_BALLOON_COUNT,
    [ITEM_GROUPS.DRAGON_FOREST_BALLOON] = DKR_RAM.ADDRESS.DRAGON_FOREST_BALLOON_COUNT,
    [ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_BALLOON_COUNT,
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

local BALLOON_ITEM_ID_TO_COUNT_ADDRESS = {
    [ITEM_IDS.TIMBERS_ISLAND_BALLOON] = true,
    [ITEM_IDS.DINO_DOMAIN_BALLOON] = DKR_RAM.ADDRESS.DINO_DOMAIN_BALLOON_COUNT,
    [ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_BALLOON_COUNT,
    [ITEM_IDS.SHERBET_ISLAND_BALLOON] = DKR_RAM.ADDRESS.SHERBET_ISLAND_BALLOON_COUNT,
    [ITEM_IDS.DRAGON_FOREST_BALLOON] = DKR_RAM.ADDRESS.DRAGON_FOREST_BALLOON_COUNT,
    [ITEM_IDS.FUTURE_FUN_LAND_BALLOON] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_BALLOON_COUNT
}

local BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO = {
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
    DINO_DOMAIN = {
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 0
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 1
        }
    },
    SNOWFLAKE_MOUNTAIN = {
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 5
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 7
        }
    },
    SHERBET_ISLAND = {
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 4
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 5
        }
    },
    DRAGON_FOREST = {
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 1
        },
        {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 0
        }
    },
    ANCIENT_LAKE = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DINO_DOMAIN_DOORS_2,
            [BIT] = 2
        }
    },
    FOSSIL_CANYON = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DINO_DOMAIN_DOORS_2,
            [BIT] = 1
        }
    },
    JUNGLE_FALLS = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DINO_DOMAIN_DOORS_2,
            [BIT] = 3
        }
    },
    HOT_TOP_VOLCANO = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DINO_DOMAIN_DOORS_2,
            [BIT] = 6
        }
    },
    EVERFROST_PEAK = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_DOORS_2,
            [BIT] = 3
        }
    },
    WALRUS_COVE = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_DOORS_2,
            [BIT] = 5
        }
    },
    SNOWBALL_VALLEY = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_DOORS_2,
            [BIT] = 2
        }
    },
    FROSTY_VILLAGE = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_DOORS_2,
            [BIT] = 1
        }
    },
    WHALE_BAY = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SHERBET_ISLAND_DOORS_2,
            [BIT] = 0
        }
    },
    CRESCENT_ISLAND = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SHERBET_ISLAND_DOORS_2,
            [BIT] = 1
        }
    },
    PIRATE_LAGOON = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SHERBET_ISLAND_DOORS_2,
            [BIT] = 2
        }
    },
    TREASURE_CAVES = {
        {
            [BYTE] = DKR_RAM.ADDRESS.SHERBET_ISLAND_DOORS_2,
            [BIT] = 3
        }
    },
    WINDMILL_PLAINS = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DRAGON_FOREST_DOORS_2,
            [BIT] = 2
        }
    },
    GREENWOOD_VILLAGE = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DRAGON_FOREST_DOORS_2,
            [BIT] = 0
        }
    },
    BOULDER_CANYON = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DRAGON_FOREST_DOORS_2,
            [BIT] = 3
        }
    },
    HAUNTED_WOODS = {
        {
            [BYTE] = DKR_RAM.ADDRESS.DRAGON_FOREST_DOORS_2,
            [BIT] = 4
        }
    },
    SPACEDUST_ALLEY = {
        {
            [BYTE] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_DOORS_2,
            [BIT] = 1
        }
    },
    DARKMOON_CAVERNS = {
        {
            [BYTE] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_DOORS_2,
            [BIT] = 0
        }
    },
    SPACEPORT_ALPHA = {
        {
            [BYTE] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_DOORS_2,
            [BIT] = 2
        }
    },
    STAR_CITY = {
        {
            [BYTE] = DKR_RAM.ADDRESS.FUTURE_FUN_LAND_DOORS_2,
            [BIT] = 3
        }
    }
}

local AGI_MASTER_MAP = {
    [ITEM_GROUPS.TIMBERS_ISLAND_BALLOON] = {
        ["1616100"] = {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 2,
            [NAME] = "Bridge Balloon"
        },
        ["1616101"] = {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 6,
            [NAME] = "Waterfall Balloon"
        },
        ["1616102"] = {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 6,
            [NAME] = "River Balloon"
        },
        ["1616103"] = {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 2,
            [NAME] = "Ocean Balloon"
        },
        ["1616104"] = {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_2,
            [BIT] = 3,
            [NAME] = "Taj Car Race"
        },
        ["1616105"] = {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 3,
            [NAME] = "Taj Hovercraft Race"
        },
        ["1616106"] = {
            [BYTE] = DKR_RAM.ADDRESS.TIMBERS_ISLAND_BALLOONS_AND_DOORS_1,
            [BIT] = 4,
            [NAME] = "Taj Plane Race"
        }
    },
    [ITEM_GROUPS.DINO_DOMAIN_BALLOON] = {
        ["1616200"] = {
            [BYTE] = DKR_RAM.ADDRESS.ANCIENT_LAKE,
            [BIT] = 1,
            [NAME] = "Ancient Lake 1"
        },
        ["1616201"] = {
            [BYTE] = DKR_RAM.ADDRESS.ANCIENT_LAKE,
            [BIT] = 2,
            [NAME] = "Ancient Lake 2"
        },
        ["1616202"] = {
            [BYTE] = DKR_RAM.ADDRESS.FOSSIL_CANYON,
            [BIT] = 1,
            [NAME] = "Fossil Canyon 1"
        },
        ["1616203"] = {
            [BYTE] = DKR_RAM.ADDRESS.FOSSIL_CANYON,
            [BIT] = 2,
            [NAME] = "Fossil Canyon 2"
        },
        ["1616204"] = {
            [BYTE] = DKR_RAM.ADDRESS.JUNGLE_FALLS,
            [BIT] = 1,
            [NAME] = "Jungle Falls 1"
        },
        ["1616205"] = {
            [BYTE] = DKR_RAM.ADDRESS.JUNGLE_FALLS,
            [BIT] = 2,
            [NAME] = "Jungle Falls 2"
        },
        ["1616206"] = {
            [BYTE] = DKR_RAM.ADDRESS.HOT_TOP_VOLCANO,
            [BIT] = 1,
            [NAME] = "Hot Top Volcano 1"
        },
        ["1616207"] = {
            [BYTE] = DKR_RAM.ADDRESS.HOT_TOP_VOLCANO,
            [BIT] = 2,
            [NAME] = "Hot Top Volcano 2"
        }
    },
    [ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON] = {
        ["1616300"] = {
            [BYTE] = DKR_RAM.ADDRESS.EVERFROST_PEAK,
            [BIT] = 1,
            [NAME] = "Everfrost Peak 1"
        },
        ["1616301"] = {
            [BYTE] = DKR_RAM.ADDRESS.EVERFROST_PEAK,
            [BIT] = 2,
            [NAME] = "Everfrost Peak 2"
        },
        ["1616302"] = {
            [BYTE] = DKR_RAM.ADDRESS.WALRUS_COVE,
            [BIT] = 1,
            [NAME] = "Walrus Cove 1"
        },
        ["1616303"] = {
            [BYTE] = DKR_RAM.ADDRESS.WALRUS_COVE,
            [BIT] = 2,
            [NAME] = "Walrus Cove 2"
        },
        ["1616304"] = {
            [BYTE] = DKR_RAM.ADDRESS.SNOWBALL_VALLEY,
            [BIT] = 1,
            [NAME] = "Snowball Valley 1"
        },
        ["1616305"] = {
            [BYTE] = DKR_RAM.ADDRESS.SNOWBALL_VALLEY,
            [BIT] = 2,
            [NAME] = "Snowball Valley 2"
        },
        ["1616306"] = {
            [BYTE] = DKR_RAM.ADDRESS.FROSTY_VILLAGE,
            [BIT] = 1,
            [NAME] = "Frosty Village 1"
        },
        ["1616307"] = {
            [BYTE] = DKR_RAM.ADDRESS.FROSTY_VILLAGE,
            [BIT] = 2,
            [NAME] = "Frosty Village 2"
        }
    },
    [ITEM_GROUPS.SHERBET_ISLAND_BALLOON] = {
        ["1616400"] = {
            [BYTE] = DKR_RAM.ADDRESS.WHALE_BAY,
            [BIT] = 1,
            [NAME] = "Whale Bay 1"
        },
        ["1616401"] = {
            [BYTE] = DKR_RAM.ADDRESS.WHALE_BAY,
            [BIT] = 2,
            [NAME] = "Whale Bay 2"
        },
        ["1616402"] = {
            [BYTE] = DKR_RAM.ADDRESS.CRESCENT_ISLAND,
            [BIT] = 1,
            [NAME] = "Crescent Island 1"
        },
        ["1616403"] = {
            [BYTE] = DKR_RAM.ADDRESS.CRESCENT_ISLAND,
            [BIT] = 2,
            [NAME] = "Crescent Island 2"
        },
        ["1616404"] = {
            [BYTE] = DKR_RAM.ADDRESS.PIRATE_LAGOON,
            [BIT] = 1,
            [NAME] = "Pirate Lagoon 1"
        },
        ["1616405"] = {
            [BYTE] = DKR_RAM.ADDRESS.PIRATE_LAGOON,
            [BIT] = 2,
            [NAME] = "Pirate Lagoon 2"
        },
        ["1616406"] = {
            [BYTE] = DKR_RAM.ADDRESS.TREASURE_CAVES,
            [BIT] = 1,
            [NAME] = "Treasure Caves 1"
        },
        ["1616407"] = {
            [BYTE] = DKR_RAM.ADDRESS.TREASURE_CAVES,
            [BIT] = 2,
            [NAME] = "Treasure Caves 2"
        }
    },
    [ITEM_GROUPS.DRAGON_FOREST_BALLOON] = {
        ["1616500"] = {
            [BYTE] = DKR_RAM.ADDRESS.WINDMILL_PLAINS,
            [BIT] = 1,
            [NAME] = "Windmill Plains 1"
        },
        ["1616501"] = {
            [BYTE] = DKR_RAM.ADDRESS.WINDMILL_PLAINS,
            [BIT] = 2,
            [NAME] = "Windmill Plains 2"
        },
        ["1616502"] = {
            [BYTE] = DKR_RAM.ADDRESS.GREENWOOD_VILLAGE,
            [BIT] = 1,
            [NAME] = "Greenwood Village 1"
        },
        ["1616503"] = {
            [BYTE] = DKR_RAM.ADDRESS.GREENWOOD_VILLAGE,
            [BIT] = 2,
            [NAME] = "Greenwood Village 2"
        },
        ["1616504"] = {
            [BYTE] = DKR_RAM.ADDRESS.BOULDER_CANYON,
            [BIT] = 1,
            [NAME] = "Boulder Canyon 1"
        },
        ["1616505"] = {
            [BYTE] = DKR_RAM.ADDRESS.BOULDER_CANYON,
            [BIT] = 2,
            [NAME] = "Boulder Canyon 2"
        },
        ["1616506"] = {
            [BYTE] = DKR_RAM.ADDRESS.HAUNTED_WOODS,
            [BIT] = 1,
            [NAME] = "Haunted Woods 1"
        },
        ["1616507"] = {
            [BYTE] = DKR_RAM.ADDRESS.HAUNTED_WOODS,
            [BIT] = 2,
            [NAME] = "Haunted Woods 2"
        }
    },
    [ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON] = {
        ["1616600"] = {
            [BYTE] = DKR_RAM.ADDRESS.SPACEDUST_ALLEY,
            [BIT] = 1,
            [NAME] = "Spacedust Alley 1"
        },
        ["1616601"] = {
            [BYTE] = DKR_RAM.ADDRESS.SPACEDUST_ALLEY,
            [BIT] = 2,
            [NAME] = "Spacedust Alley 2"
        },
        ["1616602"] = {
            [BYTE] = DKR_RAM.ADDRESS.DARKMOON_CAVERNS,
            [BIT] = 1,
            [NAME] = "Darkmoon Caverns 1"
        },
        ["1616603"] = {
            [BYTE] = DKR_RAM.ADDRESS.DARKMOON_CAVERNS,
            [BIT] = 2,
            [NAME] = "Darkmoon Caverns 2"
        },
        ["1616604"] = {
            [BYTE] = DKR_RAM.ADDRESS.SPACEPORT_ALPHA,
            [BIT] = 1,
            [NAME] = "Spaceport Alpha 1"
        },
        ["1616605"] = {
            [BYTE] = DKR_RAM.ADDRESS.SPACEPORT_ALPHA,
            [BIT] = 2,
            [NAME] = "Spaceport Alpha 2"
        },
        ["1616606"] = {
            [BYTE] = DKR_RAM.ADDRESS.STAR_CITY,
            [BIT] = 1,
            [NAME] = "Star City 1"
        },
        ["1616607"] = {
            [BYTE] = DKR_RAM.ADDRESS.STAR_CITY,
            [BIT] = 2,
            [NAME] = "Star City 2"
        }
    },
    [ITEM_GROUPS.KEY] = {
        ["1616208"] = {
            [BYTE] = DKR_RAM.ADDRESS.KEYS,
            [BIT] = 1,
            [NAME] = "Fire Mountain Key"
        },
        ["1616308"] = {
            [BYTE] = DKR_RAM.ADDRESS.KEYS,
            [BIT] = 3,
            [NAME] = "Icicle Pyramid Key"
        },
        ["1616408"] = {
            [BYTE] = DKR_RAM.ADDRESS.KEYS,
            [BIT] = 2,
            [NAME] = "Darkwater Beach Key"
        },
        ["1616508"] = {
            [BYTE] = DKR_RAM.ADDRESS.KEYS,
            [BIT] = 4,
            [NAME] = "Smokey Castle Key"
        },
    },
    [ITEM_GROUPS.WIZPIG_AMULET_PIECE] = {
        ["1616210"] = {
            [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_2,
            [BIT] = 7,
            [NAME] = "Tricky 2"
        },
        ["1616310"] = {
            [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_1,
            [BIT] = 1,
            [NAME] = "Bluey 2"
        },
        ["1616410"] = {
            [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_1,
            [BIT] = 0,
            [NAME] = "Bubbler 2"
        },
        ["1616510"] = {
            [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_1,
            [BIT] = 2,
            [NAME] = "Smokey 2"
        },
    },
    [ITEM_GROUPS.TT_AMULET_PIECE] = {
        ["1616209"] = {
            [BYTE] = DKR_RAM.ADDRESS.FIRE_MOUNTAIN,
            [BIT] = 1,
            [NAME] = "Fire Mountain"
        },
        ["1616309"] = {
            [BYTE] = DKR_RAM.ADDRESS.ICICLE_PYRAMID,
            [BIT] = 1,
            [NAME] = "Icicle Pyramid"
        },
        ["1616409"] = {
            [BYTE] = DKR_RAM.ADDRESS.DARKWATER_BEACH,
            [BIT] = 1,
            [NAME] = "Darkwater Beach"
        },
        ["1616509"] = {
            [BYTE] = DKR_RAM.ADDRESS.SMOKEY_CASTLE,
            [BIT] = 1,
            [NAME] = "Smokey Castle"
        },
    }
}

local VICTORY_CONDITION_TO_ADDRESS = {
    [0] = {
        [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_2,
        [BIT] = 0,
        [NAME] = "Wizpig 1"
    },
    [1] = {
        [BYTE] = DKR_RAM.ADDRESS.BOSS_COMPLETION_2,
        [BIT] = 5,
        [NAME] = "Wizpig 2"
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

function DKR_RAM:check_flag(byte, _bit, fromFuncDebug)
    if debug_level_2 then
        print(fromFuncDebug)
    end

    if not byte then
        print("check_flag: null found in " .. fromFuncDebug)
    end

    local currentValue = mainmemory.readbyte(byte)
    if bit.check(currentValue, _bit) then
        return true
    else
        return false
    end
end

function DKR_RAM:clear_flag(byte, _bit, fromFuncDebug)
    if debug_level_2 then
        print(fromFuncDebug)
    end

    if not byte then
        print("clear_flag: null found in " .. fromFuncDebug)
    end

    local currentValue = mainmemory.readbyte(byte)
    mainmemory.writebyte(byte, bit.clear(currentValue, _bit))
end

function DKR_RAM:set_flag(byte, _bit, fromFuncDebug)
    if debug_level_2 then
        print(fromFuncDebug)
    end
    if not byte then
        print("set_flag: null found in " .. fromFuncDebug)
    end

    local currentValue = mainmemory.readbyte(byte)
    mainmemory.writebyte(byte, bit.set(currentValue, _bit))
end

function DKR_RAM:get_counter(byte, fromFuncDebug)
    if debug_level_2 then
        print(fromFuncDebug)
    end

    if not byte then
        print("get_counter: null found in " .. fromFuncDebug)
    end

    return mainmemory.readbyte(byte)
end

function DKR_RAM:set_counter(byte, value, fromFuncDebug)
    if debug_level_2 then
        print(fromFuncDebug)
    end

    if not byte then
        print("set_counter: null found in " .. fromFuncDebug)
    end

    return mainmemory.writebyte(byte, value)
end

function DKR_RAM:increment_counter(byte, fromFuncDebug)
    if debug_level_2 then
        print(fromFuncDebug)
    end

    if not byte then
        print("increment_counter: null found in " .. fromFuncDebug)
    end

    local currentValue = mainmemory.readbyte(byte)
    mainmemory.writebyte(byte, currentValue + 1)
end

function DKR_RAM:decrement_counter(byte, fromFuncDebug)
    if debug_level_2 then
        print(fromFuncDebug)
    end

    if not byte then
        print("decrement_counter: null found in " .. fromFuncDebug)
    end

    local currentValue = mainmemory.readbyte(byte)
    mainmemory.writebyte(byte, currentValue - 1)
end

function main()
    if not checkBizHawkVersion() then
        return
    end

    print("Diddy Kong Racing Archipelago Version " .. DKR_VERSION)
    print("----------------")
    server, error = socket.bind("localhost", 21221)
    DKR_RAMOBJ = DKR_RAM:new(nil)

    while true do
        frame = frame + 1
        if current_state == STATE_OK
                or current_state == STATE_INITIAL_CONNECTION_MADE
                or current_state == STATE_TENTATIVELY_CONNECTED then
            if frame % 60 == 1 then
                receive()
            elseif frame % 10 == 1 then
                check_if_in_save_file()
                if not init_complete then
					initialize_flags()
				end

                if init_complete then
                    if shuffle_door_requirements then
                        update_door_open_states()
                    end
                    update_totals_if_paused()
                    dpad_stats()
                end
            end

            if init_complete and shuffle_door_requirements then
                force_doors()
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
                    return
                end
            end
        end
        emu.frameadvance()
    end
end

function check_if_in_save_file()
    local in_save_file_1 = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.IN_SAVE_FILE_1, "Check if in a save file") ~= 0
    local in_save_file_2 = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.IN_SAVE_FILE_2, "Check if in a save file") ~= 0
    local in_save_file_3 = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.IN_SAVE_FILE_3, "Check if in a save file") ~= 0

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

        if not DKR_RAMOBJ:check_flag(DKR_RAM.ADDRESS.STAR_CITY, 0, "Check if flags have been initialized") then
            set_races_as_visited()

            if starting_balloon_count > 0 and DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.TOTAL_BALLOON_COUNT) == 0 then
                DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.TOTAL_BALLOON_COUNT, starting_balloon_count)
            end

            if starting_regional_balloon_count > 0 and DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.DINO_DOMAIN_BALLOON_COUNT) == 0 then
                DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.DINO_DOMAIN_BALLOON_COUNT, starting_regional_balloon_count)
                DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_BALLOON_COUNT, starting_regional_balloon_count)
                DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.SHERBET_ISLAND_BALLOON_COUNT, starting_regional_balloon_count)
                DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.DRAGON_FOREST_BALLOON_COUNT, starting_regional_balloon_count)
            end

            if starting_wizpig_amulet_piece_count > 0 and DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.WIZPIG_AMULET) == 0 then
                DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.WIZPIG_AMULET, starting_wizpig_amulet_piece_count)
            end

            if starting_tt_amulet_piece_count > 0 and DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.TT_AMULET) == 0 then
                DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.TT_AMULET, starting_tt_amulet_piece_count)
            end

            if skip_trophy_races then
                set_trophy_flags()
            end
        end

		init_complete = true
	end
end

function set_races_as_visited()
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.ANCIENT_LAKE, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.FOSSIL_CANYON, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.JUNGLE_FALLS, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.HOT_TOP_VOLCANO, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.EVERFROST_PEAK, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.WALRUS_COVE, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.SNOWBALL_VALLEY, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.FROSTY_VILLAGE, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.WHALE_BAY, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.CRESCENT_ISLAND, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.PIRATE_LAGOON, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TREASURE_CAVES, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.WINDMILL_PLAINS, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.GREENWOOD_VILLAGE, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.BOULDER_CANYON, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.HAUNTED_WOODS, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.SPACEDUST_ALLEY, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.DARKMOON_CAVERNS, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.SPACEPORT_ALPHA, 0, "Set races as visited")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.STAR_CITY, 0, "Set races as visited")
end

function set_trophy_flags()
    -- Dino Domain
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 0, "Skip trophy races")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 1, "Skip trophy races")
    -- Snowflake Mountain
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 4, "Skip trophy races")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 5, "Skip trophy races")
    -- Sherbet Island
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 2, "Skip trophy races")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 3, "Skip trophy races")
    -- Dragon Forest
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 6, "Skip trophy races")
    DKR_RAMOBJ:set_flag(DKR_RAM.ADDRESS.TROPHIES_2, 7, "Skip trophy races")
end

function update_totals_if_paused()
    local new_paused = DKR_RAMOBJ:check_flag(DKR_RAM.ADDRESS.PAUSED, 0, "Check if paused")

    if new_paused and not paused then
        update_in_game_totals()
    end

    paused = new_paused
end

function update_in_game_totals()
    -- Balloons
    local timbers_island_balloon_count = get_received_item_count(ITEM_IDS.TIMBERS_ISLAND_BALLOON)
    local dinos_domain_balloon_count = get_received_item_count(ITEM_IDS.DINO_DOMAIN_BALLOON)
    local snowflake_mountain_balloon_count = get_received_item_count(ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON)
    local sherbet_island_balloon_count = get_received_item_count(ITEM_IDS.SHERBET_ISLAND_BALLOON)
    local dragon_forest_balloon_count = get_received_item_count(ITEM_IDS.DRAGON_FOREST_BALLOON)
    local future_fun_land_balloon_count = get_received_item_count(ITEM_IDS.FUTURE_FUN_LAND_BALLOON)
    local total_balloon_count = timbers_island_balloon_count + dinos_domain_balloon_count + snowflake_mountain_balloon_count + sherbet_island_balloon_count + dragon_forest_balloon_count + future_fun_land_balloon_count
    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.TOTAL_BALLOON_COUNT, total_balloon_count + starting_balloon_count, "Set total balloon count on pause")
    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.DINO_DOMAIN_BALLOON_COUNT, dinos_domain_balloon_count + starting_regional_balloon_count, "Set Dino Domain balloon count on pause")
    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_BALLOON_COUNT, snowflake_mountain_balloon_count + starting_regional_balloon_count, "Set Snowflake Mountain balloon count on pause")
    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.SHERBET_ISLAND_BALLOON_COUNT, sherbet_island_balloon_count + starting_regional_balloon_count, "Set Sherbet Island count on pause")
    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.DRAGON_FOREST_BALLOON_COUNT, dragon_forest_balloon_count + starting_regional_balloon_count, "Set Dragon Forest balloon count on pause")
    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.FUTURE_FUN_LAND_BALLOON_COUNT, future_fun_land_balloon_count, "Set Future Fun Land balloon count on pause")

    for balloon_item_id, _ in pairs(BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO) do
        set_boss_1_completion_if_boss_2_unlocked(balloon_item_id)
    end

    -- Keys
    for key_item_id, key_door_address_info in pairs(KEY_ITEM_ID_TO_DOOR_ADDRESS_INFO) do
        if get_received_item_count(key_item_id) == 0 then
            for _, key_door_ram_address in pairs(key_door_address_info) do
                DKR_RAMOBJ:clear_flag(key_door_ram_address[BYTE], key_door_ram_address[BIT], "Clear key door flag")
            end
        else
            for _, key_door_ram_address in pairs(key_door_address_info) do
                DKR_RAMOBJ:set_flag(key_door_ram_address[BYTE], key_door_ram_address[BIT], "Set key door flag")
            end
        end
    end

    -- Amulets
    local wizpig_amulet_piece_count = get_received_item_count(ITEM_IDS.WIZPIG_AMULET_PIECE)
    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.WIZPIG_AMULET, math.min(4, wizpig_amulet_piece_count + starting_wizpig_amulet_piece_count))
    local tt_amulet_piece_count = get_received_item_count(ITEM_IDS.TT_AMULET_PIECE)
    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.TT_AMULET, math.min(4, tt_amulet_piece_count + starting_tt_amulet_piece_count))
end

function update_door_open_states()
    total_balloon_count = DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.TOTAL_BALLOON_COUNT, "Get total balloon count to update door open states")
    door_open_states.DINO_DOMAIN = total_balloon_count >= door_unlock_requirements[1]
    door_open_states.SNOWFLAKE_MOUNTAIN = total_balloon_count >= door_unlock_requirements[2]
    door_open_states.SHERBET_ISLAND = total_balloon_count >= door_unlock_requirements[3]
    door_open_states.DRAGON_FOREST = total_balloon_count >= door_unlock_requirements[4]

    door_open_states.ANCIENT_LAKE = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[5], door_unlock_requirements[6], AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616200"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.DINO_DOMAIN_BALLOON])
    door_open_states.FOSSIL_CANYON = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[7], door_unlock_requirements[8], AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616202"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.DINO_DOMAIN_BALLOON])
    door_open_states.JUNGLE_FALLS = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[9], door_unlock_requirements[10], AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616204"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.DINO_DOMAIN_BALLOON])
    door_open_states.HOT_TOP_VOLCANO = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[11], door_unlock_requirements[12], AGI_MASTER_MAP[ITEM_GROUPS.DINO_DOMAIN_BALLOON]["1616206"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.DINO_DOMAIN_BALLOON])
    door_open_states.EVERFROST_PEAK = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[13], door_unlock_requirements[14], AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616300"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON])
    door_open_states.WALRUS_COVE = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[15], door_unlock_requirements[16], AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616302"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON])
    door_open_states.SNOWBALL_VALLEY = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[17], door_unlock_requirements[18], AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616304"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON])
    door_open_states.FROSTY_VILLAGE = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[19], door_unlock_requirements[20], AGI_MASTER_MAP[ITEM_GROUPS.SNOWFLAKE_MOUNTAIN_BALLOON]["1616306"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.SNOWFLAKE_MOUNTAIN_BALLOON])
    door_open_states.WHALE_BAY = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[21], door_unlock_requirements[22], AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616400"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.SHERBET_ISLAND_BALLOON])
    door_open_states.CRESCENT_ISLAND = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[23], door_unlock_requirements[24], AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616402"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.SHERBET_ISLAND_BALLOON])
    door_open_states.PIRATE_LAGOON = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[25], door_unlock_requirements[26], AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616404"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.SHERBET_ISLAND_BALLOON])
    door_open_states.TREASURE_CAVES = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[27], door_unlock_requirements[28], AGI_MASTER_MAP[ITEM_GROUPS.SHERBET_ISLAND_BALLOON]["1616406"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.SHERBET_ISLAND_BALLOON])
    door_open_states.WINDMILL_PLAINS = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[29], door_unlock_requirements[30], AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616500"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.DRAGON_FOREST_BALLOON])
    door_open_states.GREENWOOD_VILLAGE = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[31], door_unlock_requirements[32], AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616502"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.DRAGON_FOREST_BALLOON])
    door_open_states.BOULDER_CANYON = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[33], door_unlock_requirements[34], AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616504"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.DRAGON_FOREST_BALLOON])
    door_open_states.HAUNTED_WOODS = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[35], door_unlock_requirements[36], AGI_MASTER_MAP[ITEM_GROUPS.DRAGON_FOREST_BALLOON]["1616506"], BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[ITEM_IDS.DRAGON_FOREST_BALLOON])
    door_open_states.SPACEDUST_ALLEY = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[37], door_unlock_requirements[38], AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616600"])
    door_open_states.DARKMOON_CAVERNS = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[39], door_unlock_requirements[40], AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616602"])
    door_open_states.SPACEPORT_ALPHA = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[41], door_unlock_requirements[42], AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616604"])
    door_open_states.STAR_CITY = get_new_race_door_open_state(total_balloon_count, door_unlock_requirements[43], door_unlock_requirements[44], AGI_MASTER_MAP[ITEM_GROUPS.FUTURE_FUN_LAND_BALLOON]["1616606"])
end

function get_new_race_door_open_state(total_balloon_count, race_1_door_unlock_requirement, race_2_door_unlock_requirement, race_1_completion_address, boss_1_completion_address)
    return total_balloon_count >= race_2_door_unlock_requirement
            or total_balloon_count >= race_1_door_unlock_requirement
            and (boss_1_completion_address and not DKR_RAMOBJ:check_flag(boss_1_completion_address[BYTE], boss_1_completion_address[BIT], "Check boss 1 completion for door status check")
            or not DKR_RAMOBJ:check_flag(race_1_completion_address[BYTE], race_1_completion_address[BIT], "Check race 1 location for door status check"))
end

function force_doors()
    for door_name, door_address_info_list in pairs(DOOR_TO_ADDRESS_INFO) do
        for _, door_address_info in pairs(door_address_info_list) do
            force_door(door_open_states[door_name], door_address_info[BYTE], door_address_info[BIT], door_name)
        end
    end
end

function force_door(is_open, byte, bit, door_name)
    if is_open then
        DKR_RAMOBJ:set_flag(byte, bit, "Force " .. door_name .. " door open")
    else
        DKR_RAMOBJ:clear_flag(byte, bit, "Force " .. door_name .. " door open")
    end
end

function dpad_stats()
    local check_controls = joypad.get()

    if check_controls and check_controls['P1 DPad U'] then
        print("----------------")
        print("Dino Domain balloons: " .. DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.DINO_DOMAIN_BALLOON_COUNT))
        print("Snowflake Mountain balloons: " .. DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.SNOWFLAKE_MOUNTAIN_BALLOON_COUNT))
        print("Sherbet Island balloons: " .. DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.SHERBET_ISLAND_BALLOON_COUNT))
        print("Dragon Forest balloons: " .. DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.DRAGON_FOREST_BALLOON_COUNT))
        print("")
        print("Keys:")
        for _, item in pairs(receive_map) do
            if item == tostring(ITEM_IDS.FIRE_MOUNTAIN_KEY) then
                print("Fire Mountain")
            elseif item == tostring(ITEM_IDS.ICICLE_PYRAMID_KEY) then
                print("Icicle Pyramid")
            elseif item == tostring(ITEM_IDS.DARKWATER_BEACH_KEY) then
                print("Darkwater Beach")
            elseif item == tostring(ITEM_IDS.SMOKEY_CASTLE_KEY) then
                print("Smokey Castle")
            end
        end
    end
end

function get_local_checks()
    local checks = {}
    for check_type, location in pairs(AGI_MASTER_MAP) do
        for location_id, table in pairs(location) do
            if not checks[check_type] then
                checks[check_type] = {}
            end

            checks[check_type][location_id] = DKR_RAMOBJ:check_flag(table[BYTE], table[BIT], "Check item flag: " .. table[NAME])

            if previous_checks and checks[check_type][location_id] ~= previous_checks[check_type][location_id] then
                if BALLOON_ITEM_GROUP_TO_COUNT_ADDRESS[check_type] then
                    DKR_RAMOBJ:decrement_counter(DKR_RAM.ADDRESS.TOTAL_BALLOON_COUNT, "Decrement total balloon count")

                    if check_type ~= ITEM_GROUPS.TIMBERS_ISLAND_BALLOON then
                        local regional_balloon_count = get_received_item_count(ITEM_IDS[check_type]) + starting_regional_balloon_count
                        DKR_RAMOBJ:set_counter(BALLOON_ITEM_GROUP_TO_COUNT_ADDRESS[check_type], math.min(8, regional_balloon_count), "Decrement region balloon count")
                    end
                elseif check_type == ITEM_GROUPS.WIZPIG_AMULET_PIECE then
                    local wizpig_amulet_piece_count = get_received_item_count(ITEM_IDS.WIZPIG_AMULET_PIECE) + starting_wizpig_amulet_piece_count
                    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.WIZPIG_AMULET, math.min(4, wizpig_amulet_piece_count), "Decrement Wizpig amulet piece count")
                elseif check_type == ITEM_GROUPS.TT_AMULET_PIECE then
                    local tt_amulet_piece_count = get_received_item_count(ITEM_IDS.TT_AMULET_PIECE) + starting_tt_amulet_piece_count
                    DKR_RAMOBJ:set_counter(DKR_RAM.ADDRESS.TT_AMULET, math.min(4, tt_amulet_piece_count), "Decrement T.T. amulet piece count")
                elseif check_type == ITEM_GROUPS.KEY and not amm[ITEM_GROUPS.KEY][location_id] then
                    local key_ram_address = AGI_MASTER_MAP[ITEM_GROUPS.KEY][location_id]
                    DKR_RAMOBJ:clear_flag(key_ram_address[BYTE], key_ram_address[BIT], "Clear key flag")
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
            end

            current_state = STATE_UNINITIALIZED

            return
        elseif error == "timeout" then
            return
        elseif error then
            print(error)
            current_state = STATE_UNINITIALIZED

            return
        end

        if debug_level_3 then
            print("Processing Block")
        end

        process_block(json.decode(response))

        if debug_level_3 then
            print("Finish")
        end
    end
end

function get_slot_data()
    local retTable = {}
    retTable["getSlot"] = true

    if debug_level_2 then
        print("Encoding getSlot")
    end

    local message = json.encode(retTable) .. "\n"
    DKR_SOCK:send(message)
    response, error = DKR_SOCK:receive()

    if error == "closed" then
        if current_state == STATE_OK then
            print("Connection closed")
        end

        current_state = STATE_UNINITIALIZED

        return
    elseif error == "timeout" then
        return
    elseif error then
        print(error)
        current_state = STATE_UNINITIALIZED

        return
    end

    if debug_level_2 then
        print("Processing Slot Data")
    end

    process_slot(json.decode(response))
end

function process_slot(block)
    if debug_level_3 then
        print("slot_data")
        print(block)
        print("EO_slot_data")
    end

    if block["slot_player"] and block["slot_player"] ~= "" then
        player = block["slot_player"]
    end

    if block["slot_seed"] and block["slot_seed"] ~= "" then
        seed = block["slot_seed"]
    end

    if block["slot_victory_condition"] and block["slot_victory_condition"] ~= "" then
        victory_condition = block["slot_victory_condition"]
    end

    if block["slot_shuffle_door_requirements"] and block["slot_shuffle_door_requirements"] ~= "false" then
        shuffle_door_requirements = true
    end

    if block["slot_door_unlock_requirements"] and block["slot_door_unlock_requirements"] ~= "" then
        door_unlock_requirements = block["slot_door_unlock_requirements"]
    end

    if block["slot_skip_trophy_races"] and block["slot_skip_trophy_races"] ~= "false" then
        skip_trophy_races = true
    end

    if block["slot_starting_balloon_count"] and block["slot_starting_balloon_count"] ~= "" then
        starting_balloon_count = block["slot_starting_balloon_count"]
    end

    if block["slot_starting_regional_balloon_count"] and block["slot_starting_regional_balloon_count"] ~= "" then
        starting_regional_balloon_count = block["slot_starting_regional_balloon_count"]
    end

    if block["slot_starting_wizpig_amulet_piece_count"] and block["slot_starting_wizpig_amulet_piece_count"] ~= "" then
        starting_wizpig_amulet_piece_count = block["slot_starting_wizpig_amulet_piece_count"]
    end

    if block["slot_starting_tt_amulet_piece_count"] and block["slot_starting_tt_amulet_piece_count"] ~= "" then
        starting_tt_amulet_piece_count = block["slot_starting_tt_amulet_piece_count"]
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

        if debug_level_2 then
            print("Writing AGI File from LoadAGI")
            print(agi)
        end

        file:write(json.encode(agi) .. "\n")
        file:write(json.encode(receive_map))
        file:close()
    else
        if debug_level_2 then
            print("Loading AGI File")
        end

        agi = json.decode(file:read("l"))
        receive_map = json.decode(file:read("l"))
        file:close()
    end
end

function send_to_dkr_client()
    local retTable = {}
    retTable["scriptVersion"] = SCRIPT_VERSION
    retTable["playerName"] = player
    retTable["locations"] = all_location_checks("AMM")
    retTable["gameComplete"] = is_game_complete()

    if not in_save_file then
        retTable["sync_ready"] = "false"
    else
        retTable["sync_ready"] = "true"
    end

    if debug_level_3 then
        print("Send Data")
    end

    local message = json.encode(retTable) .. "\n"
    local response, error = DKR_SOCK:send(message)
    if not response then
        print(error)
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
        if DKR_RAM:check_flag(victory_condition_address[BYTE], victory_condition_address[BIT], "Check victory condition") then
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

    if debug_level_3 then
        print(block)
    end
end

function process_agi_item(item_list)
    for ap_id, item_id in pairs(item_list) do
        if not receive_map[tostring(ap_id)] then
            if BALLOON_ITEM_ID_TO_COUNT_ADDRESS[item_id] then
                if debug_level_1 then
                    print("Balloon Obtained")
                end
                DKR_RAMOBJ:increment_counter(DKR_RAM.ADDRESS.TOTAL_BALLOON_COUNT, "Increment total balloon count")

                if item_id ~= ITEM_IDS.TIMBERS_ISLAND_BALLOON and DKR_RAMOBJ:get_counter(BALLOON_ITEM_ID_TO_COUNT_ADDRESS[item_id], "Check if already at max regional balloons") < 8 then
                    DKR_RAMOBJ:increment_counter(BALLOON_ITEM_ID_TO_COUNT_ADDRESS[item_id], "Increment regional balloon count")

                    set_boss_1_completion_if_boss_2_unlocked(item_id)
                end
            elseif item_id == ITEM_IDS.WIZPIG_AMULET_PIECE and DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.WIZPIG_AMULET, "Check if Wizpig amulet is already complete") < 4 then
                DKR_RAMOBJ:increment_counter(DKR_RAM.ADDRESS.WIZPIG_AMULET, "Increment Wizpig amulet piece count")
            elseif item_id == ITEM_IDS.TT_AMULET_PIECE and DKR_RAMOBJ:get_counter(DKR_RAM.ADDRESS.TT_AMULET, "Check if T.T. amulet is already complete") < 4 then
                DKR_RAMOBJ:increment_counter(DKR_RAM.ADDRESS.TT_AMULET, "Increment T.T. amulet piece count")
            elseif KEY_ITEM_ID_TO_DOOR_ADDRESS_INFO[item_id] then
                for _, key_door_ram_address in pairs(KEY_ITEM_ID_TO_DOOR_ADDRESS_INFO[item_id]) do
                    DKR_RAMOBJ:set_flag(key_door_ram_address[BYTE], key_door_ram_address[BIT], "Set key door flag")
                end
            end

            receive_map[tostring(ap_id)] = tostring(item_id)
            saving_agi()
        end
    end
end

function set_boss_1_completion_if_boss_2_unlocked(item_id)
    if BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[item_id]
            and DKR_RAMOBJ:get_counter(BALLOON_ITEM_ID_TO_COUNT_ADDRESS[item_id], "Check if boss 1 should be unlocked") == 8 then
        local boss_1_completion_address = BALLOON_ITEM_ID_TO_BOSS_COMPLETION_1_INFO[item_id]
        DKR_RAMOBJ:set_flag(boss_1_completion_address[BYTE], boss_1_completion_address[BIT], "Set boss 1 completion")
    end
end

function saving_agi()
    local file = io.open("DKR_" .. player .. "_" .. seed .. ".AGI", "w")

    if debug_level_2 then
        print("Writing AGI File from Saving")
        print(agi)
        print(receive_map)
    end

    file:write(json.encode(agi) .. "\n")

    if debug_level_2 then
        print("Writing Received_Map")
    end

    file:write(json.encode(receive_map))
    file:close()

    if debug_level_1 then
        print("AGI Table Saved")
    end
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
