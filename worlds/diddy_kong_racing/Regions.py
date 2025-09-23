from __future__ import annotations

from typing import TYPE_CHECKING

from BaseClasses import Region
from worlds.generic.Rules import set_rule
from .Locations import DiddyKongRacingLocation
from .Names import ItemName, LocationName, RegionName
from .Rules import DiddyKongRacingRules

if TYPE_CHECKING:
    from . import DiddyKongRacingWorld
else:
    DiddyKongRacingWorld = object

ENTRANCE_NAME_SUFFIX: str = " Door"
DATASTORAGE_KEY_PREFIX: str = "Diddy_Kong_Racing_{player}_"

DIDDY_KONG_RACING_REGIONS: dict[str, list[str]] = {
    RegionName.MENU: [],
    RegionName.TIMBERS_ISLAND: [
        LocationName.BRIDGE_BALLOON,
        LocationName.WATERFALL_BALLOON,
        LocationName.OCEAN_BALLOON,
        LocationName.RIVER_BALLOON,
        LocationName.TAJ_CAR_RACE,
        LocationName.TAJ_HOVERCRAFT_RACE,
        LocationName.TAJ_PLANE_RACE
    ],
    RegionName.DINO_DOMAIN: [],
    RegionName.ANCIENT_LAKE: [
        LocationName.ANCIENT_LAKE_1,
        LocationName.ANCIENT_LAKE_2,
        LocationName.FIRE_MOUNTAIN_KEY
    ],
    RegionName.FOSSIL_CANYON: [
        LocationName.FOSSIL_CANYON_1,
        LocationName.FOSSIL_CANYON_2
    ],
    RegionName.JUNGLE_FALLS: [
        LocationName.JUNGLE_FALLS_1,
        LocationName.JUNGLE_FALLS_2
    ],
    RegionName.HOT_TOP_VOLCANO: [
        LocationName.HOT_TOP_VOLCANO_1,
        LocationName.HOT_TOP_VOLCANO_2
    ],
    RegionName.FIRE_MOUNTAIN: [
        LocationName.FIRE_MOUNTAIN
    ],
    RegionName.TRICKY: [
        LocationName.TRICKY_2
    ],
    RegionName.SNOWFLAKE_MOUNTAIN: [],
    RegionName.EVERFROST_PEAK: [
        LocationName.EVERFROST_PEAK_1,
        LocationName.EVERFROST_PEAK_2
    ],
    RegionName.WALRUS_COVE: [
        LocationName.WALRUS_COVE_1,
        LocationName.WALRUS_COVE_2
    ],
    RegionName.SNOWBALL_VALLEY: [
        LocationName.SNOWBALL_VALLEY_1,
        LocationName.SNOWBALL_VALLEY_2,
        LocationName.ICICLE_PYRAMID_KEY
    ],
    RegionName.FROSTY_VILLAGE: [
        LocationName.FROSTY_VILLAGE_1,
        LocationName.FROSTY_VILLAGE_2
    ],
    RegionName.ICICLE_PYRAMID: [
        LocationName.ICICLE_PYRAMID
    ],
    RegionName.BLUEY: [
        LocationName.BLUEY_2
    ],
    RegionName.SHERBET_ISLAND: [],
    RegionName.WHALE_BAY: [
        LocationName.WHALE_BAY_1,
        LocationName.WHALE_BAY_2
    ],
    RegionName.CRESCENT_ISLAND: [
        LocationName.CRESCENT_ISLAND_1,
        LocationName.CRESCENT_ISLAND_2,
        LocationName.DARKWATER_BEACH_KEY
    ],
    RegionName.PIRATE_LAGOON: [
        LocationName.PIRATE_LAGOON_1,
        LocationName.PIRATE_LAGOON_2
    ],
    RegionName.TREASURE_CAVES: [
        LocationName.TREASURE_CAVES_1,
        LocationName.TREASURE_CAVES_2
    ],
    RegionName.DARKWATER_BEACH: [
        LocationName.DARKWATER_BEACH
    ],
    RegionName.BUBBLER: [
        LocationName.BUBBLER_2
    ],
    RegionName.DRAGON_FOREST: [],
    RegionName.WINDMILL_PLAINS: [
        LocationName.WINDMILL_PLAINS_1,
        LocationName.WINDMILL_PLAINS_2
    ],
    RegionName.GREENWOOD_VILLAGE: [
        LocationName.GREENWOOD_VILLAGE_1,
        LocationName.GREENWOOD_VILLAGE_2
    ],
    RegionName.BOULDER_CANYON: [
        LocationName.BOULDER_CANYON_1,
        LocationName.BOULDER_CANYON_2,
        LocationName.SMOKEY_CASTLE_KEY
    ],
    RegionName.HAUNTED_WOODS: [
        LocationName.HAUNTED_WOODS_1,
        LocationName.HAUNTED_WOODS_2
    ],
    RegionName.SMOKEY_CASTLE: [
        LocationName.SMOKEY_CASTLE
    ],
    RegionName.SMOKEY: [
        LocationName.SMOKEY_2
    ],
    RegionName.WIZPIG_1: [
        LocationName.WIZPIG_1
    ],
    RegionName.FUTURE_FUN_LAND: [],
    RegionName.SPACEDUST_ALLEY: [
        LocationName.SPACEDUST_ALLEY_1,
        LocationName.SPACEDUST_ALLEY_2
    ],
    RegionName.DARKMOON_CAVERNS: [
        LocationName.DARKMOON_CAVERNS_1,
        LocationName.DARKMOON_CAVERNS_2
    ],
    RegionName.SPACEPORT_ALPHA: [
        LocationName.SPACEPORT_ALPHA_1,
        LocationName.SPACEPORT_ALPHA_2
    ],
    RegionName.STAR_CITY: [
        LocationName.STAR_CITY_1,
        LocationName.STAR_CITY_2
    ],
    RegionName.WIZPIG_2: [
        LocationName.WIZPIG_2
    ]
}

VANILLA_REGION_ORDER: list[str] = [
    RegionName.ANCIENT_LAKE,
    RegionName.FOSSIL_CANYON,
    RegionName.JUNGLE_FALLS,
    RegionName.HOT_TOP_VOLCANO,
    RegionName.EVERFROST_PEAK,
    RegionName.WALRUS_COVE,
    RegionName.SNOWBALL_VALLEY,
    RegionName.FROSTY_VILLAGE,
    RegionName.WHALE_BAY,
    RegionName.CRESCENT_ISLAND,
    RegionName.PIRATE_LAGOON,
    RegionName.TREASURE_CAVES,
    RegionName.WINDMILL_PLAINS,
    RegionName.GREENWOOD_VILLAGE,
    RegionName.BOULDER_CANYON,
    RegionName.HAUNTED_WOODS,
    RegionName.SPACEDUST_ALLEY,
    RegionName.DARKMOON_CAVERNS,
    RegionName.SPACEPORT_ALPHA,
    RegionName.STAR_CITY
]

MAP_VALUE_TO_REGION_NAME: dict[int, str] = {
    5: RegionName.ANCIENT_LAKE,
    3: RegionName.FOSSIL_CANYON,
    29: RegionName.JUNGLE_FALLS,
    7: RegionName.HOT_TOP_VOLCANO,
    13: RegionName.EVERFROST_PEAK,
    6: RegionName.WALRUS_COVE,
    9: RegionName.SNOWBALL_VALLEY,
    28: RegionName.FROSTY_VILLAGE,
    8: RegionName.WHALE_BAY,
    10: RegionName.CRESCENT_ISLAND,
    4: RegionName.PIRATE_LAGOON,
    30: RegionName.TREASURE_CAVES,
    20: RegionName.WINDMILL_PLAINS,
    18: RegionName.GREENWOOD_VILLAGE,
    19: RegionName.BOULDER_CANYON,
    31: RegionName.HAUNTED_WOODS,
    17: RegionName.SPACEDUST_ALLEY,
    32: RegionName.DARKMOON_CAVERNS,
    15: RegionName.SPACEPORT_ALPHA,
    33: RegionName.STAR_CITY
}


def create_regions(world: DiddyKongRacingWorld) -> None:
    if world.options.victory_condition.value == 0:
        victory_item_location = LocationName.WIZPIG_1
    elif world.options.victory_condition.value == 1:
        victory_item_location = LocationName.WIZPIG_2
    else:
        raise Exception("Unexpected victory condition")

    world.multiworld.regions += [
        create_region(world, region_name, locations, victory_item_location)
        for region_name, locations in DIDDY_KONG_RACING_REGIONS.items()
    ]

    world.multiworld.get_location(victory_item_location, world.player).place_locked_item(
        world.multiworld.worlds[world.player].create_event_item(ItemName.VICTORY)
    )


def create_region(world: DiddyKongRacingWorld, name: str, locations: list[str], victory_item_location: str) -> Region:
    region = Region(name, world.player, world.multiworld)
    if name == RegionName.MENU:
        region.add_locations({location: None for location in LocationName.DOOR_UNLOCK_LOCATIONS})

        if not world.options.open_worlds:
            region.add_locations({location: None for location in LocationName.WORLD_UNLOCK_LOCATIONS})
    elif locations:
        if victory_item_location in locations:
            region.add_locations({victory_item_location: None})

        active_locations = world.location_name_to_id
        location_to_id = {
            location: active_locations.get(location, 0) for location in locations
            if active_locations.get(location, None)
        }
        region.add_locations(location_to_id, DiddyKongRacingLocation)

    return region


def connect_regions(world: DiddyKongRacingWorld) -> None:
    multiworld = world.multiworld
    player = world.player
    rules = DiddyKongRacingRules(world)

    region_menu = multiworld.get_region(RegionName.MENU, player)
    region_menu.add_exits({RegionName.TIMBERS_ISLAND})

    multiworld.get_region(RegionName.TIMBERS_ISLAND, player).add_exits(
        {
            RegionName.DINO_DOMAIN,
            RegionName.SNOWFLAKE_MOUNTAIN,
            RegionName.SHERBET_ISLAND,
            RegionName.DRAGON_FOREST,
            RegionName.WIZPIG_1,
            RegionName.FUTURE_FUN_LAND
        },
        {
            RegionName.DINO_DOMAIN: lambda state: rules.can_access_dino_domain(state),
            RegionName.SNOWFLAKE_MOUNTAIN: lambda state: rules.can_access_snowflake_mountain(state),
            RegionName.SHERBET_ISLAND: lambda state: rules.can_access_sherbet_island(state),
            RegionName.DRAGON_FOREST: lambda state: rules.can_access_dragon_forest(state),
            RegionName.WIZPIG_1: lambda state: rules.wizpig_1(state),
            RegionName.FUTURE_FUN_LAND: lambda state: rules.can_access_future_fun_land(state)
        }
    )
    multiworld.get_region(RegionName.DINO_DOMAIN, player).add_exits(
        {
            RegionName.FIRE_MOUNTAIN,
            RegionName.TRICKY
        },
        {
            RegionName.FIRE_MOUNTAIN: lambda state: rules.fire_mountain(state),
            RegionName.TRICKY: lambda state: rules.tricky_1(state),
        }
    )
    multiworld.get_region(RegionName.SNOWFLAKE_MOUNTAIN, player).add_exits(
        {
            RegionName.ICICLE_PYRAMID,
            RegionName.BLUEY
        },
        {
            RegionName.ICICLE_PYRAMID: lambda state: rules.icicle_pyramid(state),
            RegionName.BLUEY: lambda state: rules.bluey_1(state),
        }
    )
    multiworld.get_region(RegionName.SHERBET_ISLAND, player).add_exits(
        {
            RegionName.DARKWATER_BEACH,
            RegionName.BUBBLER
        },
        {
            RegionName.DARKWATER_BEACH: lambda state: rules.darkwater_beach(state),
            RegionName.BUBBLER: lambda state: rules.bubbler_1(state),
        }
    )
    multiworld.get_region(RegionName.DRAGON_FOREST, player).add_exits(
        {
            RegionName.SMOKEY_CASTLE,
            RegionName.SMOKEY
        },
        {
            RegionName.SMOKEY_CASTLE: lambda state: rules.smokey_castle(state),
            RegionName.SMOKEY: lambda state: rules.smokey_1(state),
        }
    )
    multiworld.get_region(RegionName.FUTURE_FUN_LAND, player).add_exits(
        {
            RegionName.WIZPIG_2
        },
        {
            RegionName.WIZPIG_2: lambda state: rules.wizpig_2(state),
        }
    )

    # Skip for Universal Tracker, this will be done from slot_data
    if not hasattr(multiworld, "generation_is_fake"):
        if world.options.shuffle_race_entrances:
            world.random.shuffle(world.entrance_order)

            while not is_entrance_order_valid(world.entrance_order):
                world.random.shuffle(world.entrance_order)

        connect_track_regions(world)


# Can't put tracks with keys in FFL when it's not accessible because of location/item imbalance
def is_entrance_order_valid(entrance_order: list[int]) -> bool:
    tracks_with_keys = (0, 6, 9, 14)

    for i in range(16, 20):
        if entrance_order[i] in tracks_with_keys:
            return False

    return True


def connect_track_regions(world: DiddyKongRacingWorld) -> None:
    rules = DiddyKongRacingRules(world)
    use_ut_deferred_entrances = (world.options.shuffle_race_entrances.value
                                 and hasattr(world.multiworld, "generation_is_fake")
                                 and hasattr(world.multiworld, "enforce_deferred_connections")
                                 and world.multiworld.enforce_deferred_connections in ("on", "default"))

    for door_num, entrance_num in enumerate(world.entrance_order):
        if door_num < 4:
            start_region_name = RegionName.DINO_DOMAIN
        elif door_num < 8:
            start_region_name = RegionName.SNOWFLAKE_MOUNTAIN
        elif door_num < 12:
            start_region_name = RegionName.SHERBET_ISLAND
        elif door_num < 16:
            start_region_name = RegionName.DRAGON_FOREST
        else:
            start_region_name = RegionName.FUTURE_FUN_LAND

        start_region = world.multiworld.get_region(start_region_name, world.player)
        vanilla_end_region = VANILLA_REGION_ORDER[door_num]
        entrance_name = convert_region_name_to_vanilla_entrance_name(vanilla_end_region)
        entrance = start_region.create_exit(entrance_name)
        set_rule(entrance, rules.door_rules[door_num][0])

        if use_ut_deferred_entrances:
            for map_value, region_name in MAP_VALUE_TO_REGION_NAME.items():
                if region_name == vanilla_end_region:
                    datastorage_key = DATASTORAGE_KEY_PREFIX + str(map_value)
                    world.found_entrances_datastorage_key.append(datastorage_key)
                    break
        else:
            end_region_name = VANILLA_REGION_ORDER[entrance_num]
            end_region = world.multiworld.get_region(end_region_name, world.player)
            entrance.connect(end_region)


def reconnect_found_entrance(world: DiddyKongRacingWorld, key: str) -> None:
    found_region_map_value = int(key.removeprefix(DATASTORAGE_KEY_PREFIX.replace("{player}", str(world.player))))
    found_region_name = MAP_VALUE_TO_REGION_NAME[found_region_map_value]
    found_region_index = VANILLA_REGION_ORDER.index(found_region_name)
    found_region = world.multiworld.get_region(found_region_name, world.player)
    found_entrance_index = world.entrance_order.index(found_region_index)
    found_entrance_vanilla_region = VANILLA_REGION_ORDER[found_entrance_index]
    found_entrance_name = convert_region_name_to_vanilla_entrance_name(found_entrance_vanilla_region)
    found_entrance = world.multiworld.get_entrance(found_entrance_name, world.player)

    found_entrance.connect(found_region)


def convert_region_name_to_vanilla_entrance_name(region_name: str) -> str:
    return region_name + ENTRANCE_NAME_SUFFIX
