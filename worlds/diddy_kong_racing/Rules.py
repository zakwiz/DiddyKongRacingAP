from typing import TYPE_CHECKING, Any, Callable

from BaseClasses import CollectionState, Location
from worlds.generic.Rules import set_rule
from .DoorShuffle import get_requirement_for_location, vanilla_door_unlock_info_list
from .Names import ItemName, LocationName, RegionName
from .Regions import convert_region_name_to_vanilla_entrance_name

# Allows type hinting without circular imports
if TYPE_CHECKING:
    from . import DiddyKongRacingWorld
else:
    DiddyKongRacingWorld = object

VANILLA_RACE_2_LOCATIONS: list[list[str]] = [
    [LocationName.ANCIENT_LAKE_2, LocationName.FIRE_MOUNTAIN_KEY],
    [LocationName.FOSSIL_CANYON_2],
    [LocationName.JUNGLE_FALLS_2],
    [LocationName.HOT_TOP_VOLCANO_2],
    [LocationName.EVERFROST_PEAK_2],
    [LocationName.WALRUS_COVE_2],
    [LocationName.SNOWBALL_VALLEY_2, LocationName.ICICLE_PYRAMID_KEY],
    [LocationName.FROSTY_VILLAGE_2],
    [LocationName.WHALE_BAY_2],
    [LocationName.CRESCENT_ISLAND_2, LocationName.DARKWATER_BEACH_KEY],
    [LocationName.PIRATE_LAGOON_2],
    [LocationName.TREASURE_CAVES_2],
    [LocationName.WINDMILL_PLAINS_2],
    [LocationName.GREENWOOD_VILLAGE_2],
    [LocationName.BOULDER_CANYON_2, LocationName.SMOKEY_CASTLE_KEY],
    [LocationName.HAUNTED_WOODS_2],
    [LocationName.SPACEDUST_ALLEY_2],
    [LocationName.DARKMOON_CAVERNS_2],
    [LocationName.SPACEPORT_ALPHA_2],
    [LocationName.STAR_CITY_2]
]


def can_access_dino_domain(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return world.options.open_worlds or state.has(ItemName.DINO_DOMAIN_UNLOCK, world.player)


def can_access_snowflake_mountain(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return world.options.open_worlds or state.has(ItemName.SNOWFLAKE_MOUNTAIN_UNLOCK, world.player)


def can_access_sherbet_island(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return world.options.open_worlds or state.has(ItemName.SHERBET_ISLAND_UNLOCK, world.player)


def can_access_dragon_forest(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return world.options.open_worlds or state.has(ItemName.DRAGON_FOREST_UNLOCK, world.player)


def can_access_future_fun_land(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (world.options.open_worlds or
            wizpig_1(world, state) and
            (world.options.skip_trophy_races or
             (tricky_2(world, state) and bluey_2(world, state) and bubbler_2(world, state) and smokey_2(world, state)))
            )


def balloon_bridge(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return True


def balloon_waterfall(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return True


def balloon_river(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return True


def balloon_ocean(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return True


def balloon_taj_car(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return has_total_balloon_count(world, state, 5)


def balloon_taj_hovercraft(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return has_total_balloon_count(world, state, 10)


def balloon_taj_plane(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return has_total_balloon_count(world, state, 18)


def ancient_lake_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.ANCIENT_LAKE_DOOR_1_UNLOCK, world.player)


def ancient_lake_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.ANCIENT_LAKE_DOOR_2_UNLOCK, world.player)
            and tricky_1(world, state))


def fossil_canyon_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.FOSSIL_CANYON_DOOR_1_UNLOCK, world.player)


def fossil_canyon_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.FOSSIL_CANYON_DOOR_2_UNLOCK, world.player)
            and tricky_1(world, state))


def jungle_falls_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.JUNGLE_FALLS_DOOR_1_UNLOCK, world.player)


def jungle_falls_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.JUNGLE_FALLS_DOOR_2_UNLOCK, world.player)
            and tricky_1(world, state))


def hot_top_volcano_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.HOT_TOP_VOLCANO_DOOR_1_UNLOCK, world.player)


def hot_top_volcano_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.HOT_TOP_VOLCANO_DOOR_2_UNLOCK, world.player)
            and tricky_1(world, state))


def everfrost_peak_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.EVERFROST_PEAK_DOOR_1_UNLOCK, world.player)


def everfrost_peak_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.EVERFROST_PEAK_DOOR_2_UNLOCK, world.player)
            and bluey_1(world, state))


def walrus_cove_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.WALRUS_COVE_DOOR_1_UNLOCK, world.player)


def walrus_cove_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.WALRUS_COVE_DOOR_2_UNLOCK, world.player)
            and bluey_1(world, state))


def snowball_valley_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.SNOWBALL_VALLEY_DOOR_1_UNLOCK, world.player)


def snowball_valley_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.SNOWBALL_VALLEY_DOOR_2_UNLOCK, world.player)
            and bluey_1(world, state))


def frosty_village_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.FROSTY_VILLAGE_DOOR_1_UNLOCK, world.player)


def frosty_village_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.FROSTY_VILLAGE_DOOR_2_UNLOCK, world.player)
            and bluey_1(world, state))


def whale_bay_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.WHALE_BAY_DOOR_1_UNLOCK, world.player)


def whale_bay_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.WHALE_BAY_DOOR_2_UNLOCK, world.player)
            and bubbler_1(world, state))


def crescent_island_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.CRESCENT_ISLAND_DOOR_1_UNLOCK, world.player)


def crescent_island_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.CRESCENT_ISLAND_DOOR_2_UNLOCK, world.player)
            and bubbler_1(world, state))


def pirate_lagoon_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.PIRATE_LAGOON_DOOR_1_UNLOCK, world.player)


def pirate_lagoon_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.PIRATE_LAGOON_DOOR_2_UNLOCK, world.player)
            and bubbler_1(world, state))


def treasure_caves_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.TREASURE_CAVES_DOOR_1_UNLOCK, world.player)


def treasure_caves_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.TREASURE_CAVES_DOOR_2_UNLOCK, world.player)
            and bubbler_1(world, state))


def windmill_plains_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.WINDMILL_PLAINS_DOOR_1_UNLOCK, world.player)


def windmill_plains_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.WINDMILL_PLAINS_DOOR_2_UNLOCK, world.player)
            and smokey_1(world, state))


def greenwood_village_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.GREENWOOD_VILLAGE_DOOR_1_UNLOCK, world.player)


def greenwood_village_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.GREENWOOD_VILLAGE_DOOR_2_UNLOCK, world.player)
            and smokey_1(world, state))


def boulder_canyon_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.BOULDER_CANYON_DOOR_1_UNLOCK, world.player)


def boulder_canyon_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.BOULDER_CANYON_DOOR_2_UNLOCK, world.player)
            and smokey_1(world, state))


def haunted_woods_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.HAUNTED_WOODS_DOOR_1_UNLOCK, world.player)


def haunted_woods_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.HAUNTED_WOODS_DOOR_2_UNLOCK, world.player)
            and smokey_1(world, state))


def spacedust_alley_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.SPACEDUST_ALLEY_DOOR_1_UNLOCK, world.player)


def spacedust_alley_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.SPACEDUST_ALLEY_DOOR_2_UNLOCK, world.player)


def darkmoon_caverns_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.DARKMOON_CAVERNS_DOOR_1_UNLOCK, world.player)


def darkmoon_caverns_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.DARKMOON_CAVERNS_DOOR_2_UNLOCK, world.player)


def spaceport_alpha_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.SPACEPORT_ALPHA_DOOR_1_UNLOCK, world.player)


def spaceport_alpha_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.SPACEPORT_ALPHA_DOOR_2_UNLOCK, world.player)


def star_city_door_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.STAR_CITY_DOOR_1_UNLOCK, world.player)


def star_city_door_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.STAR_CITY_DOOR_2_UNLOCK, world.player)


def fire_mountain(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.FIRE_MOUNTAIN_KEY, world.player)


def icicle_pyramid(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.ICICLE_PYRAMID_KEY, world.player)


def darkwater_beach(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.DARKWATER_BEACH_KEY, world.player)


def smokey_castle(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.SMOKEY_CASTLE_KEY, world.player)


def tricky_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return can_access_boss_1(world, state, ItemName.DINO_DOMAIN_BALLOON)


def tricky_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return can_access_boss_2(world, state, ItemName.DINO_DOMAIN_BALLOON)


def bluey_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return can_access_boss_1(world, state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON)


def bluey_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return can_access_boss_2(world, state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON)


def bubbler_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return can_access_boss_1(world, state, ItemName.SHERBET_ISLAND_BALLOON)


def bubbler_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return can_access_boss_2(world, state, ItemName.SHERBET_ISLAND_BALLOON)


def smokey_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return can_access_boss_1(world, state, ItemName.DRAGON_FOREST_BALLOON)


def smokey_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return can_access_boss_2(world, state, ItemName.DRAGON_FOREST_BALLOON)


def wizpig_1(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return state.has(ItemName.WIZPIG_AMULET_PIECE, world.player, world.options.wizpig_1_amulet_pieces.value)


def wizpig_2(world: DiddyKongRacingWorld, state: CollectionState) -> bool:
    return (state.has(ItemName.TT_AMULET_PIECE, world.player, world.options.wizpig_2_amulet_pieces.value)
            and has_total_balloon_count(world, state, world.options.wizpig_2_balloons.value))


def door_unlock(world: DiddyKongRacingWorld, location) -> Callable[[Any], bool]:
    return lambda state: has_total_balloon_count(world, state, get_requirement_for_location(world, location))


def has_total_balloon_count(world: DiddyKongRacingWorld, state: CollectionState, balloon_count: int) -> bool:
    collected_balloon_count = state.count_from_list(
        [
            ItemName.TIMBERS_ISLAND_BALLOON,
            ItemName.DINO_DOMAIN_BALLOON,
            ItemName.SNOWFLAKE_MOUNTAIN_BALLOON,
            ItemName.SHERBET_ISLAND_BALLOON,
            ItemName.DRAGON_FOREST_BALLOON,
            ItemName.FUTURE_FUN_LAND_BALLOON
        ],
        world.player
    )

    return collected_balloon_count >= balloon_count


def can_access_boss_1(world: DiddyKongRacingWorld, state: CollectionState, regional_balloon_item_name: str):
    return state.has(regional_balloon_item_name, world.player, world.options.boss_1_regional_balloons.value)


def can_access_boss_2(world: DiddyKongRacingWorld, state: CollectionState, regional_balloon_item_name: str):
    return state.has(regional_balloon_item_name, world.player, world.options.boss_2_regional_balloons.value)


def set_rules(world: DiddyKongRacingWorld) -> None:
    # Skip for Universal Tracker, this will be called from interpret_slot_data, otherwise entrances won't exist yet
    if not hasattr(world.multiworld, "generation_is_fake"):
        set_region_access_rules(world)

    set_balloon_rules(world)
    set_race_2_location_rules(world)
    set_amulet_rules(world)
    set_door_unlock_rules(world)

    world.multiworld.completion_condition[world.player] = lambda state: state.has(ItemName.VICTORY, world.player)


def set_region_access_rules(world: DiddyKongRacingWorld) -> None:
    region_access_rules = {
        # Timber's Island
        RegionName.DINO_DOMAIN: lambda state: can_access_dino_domain(world, state),
        RegionName.SNOWFLAKE_MOUNTAIN: lambda state: can_access_snowflake_mountain(world, state),
        RegionName.SHERBET_ISLAND: lambda state: can_access_sherbet_island(world, state),
        RegionName.DRAGON_FOREST: lambda state: can_access_dragon_forest(world, state),
        RegionName.WIZPIG_1: lambda state: wizpig_1(world, state),
        RegionName.FUTURE_FUN_LAND: lambda state: can_access_future_fun_land(world, state),
        # Dino Domain
        RegionName.ANCIENT_LAKE: lambda state: ancient_lake_door_1(world, state),
        RegionName.FOSSIL_CANYON: lambda state: fossil_canyon_door_1(world, state),
        RegionName.JUNGLE_FALLS: lambda state: jungle_falls_door_1(world, state),
        RegionName.HOT_TOP_VOLCANO: lambda state: hot_top_volcano_door_1(world, state),
        RegionName.FIRE_MOUNTAIN: lambda state: fire_mountain(world, state),
        RegionName.TRICKY: lambda state: tricky_1(world, state),
        # Snowflake Mountain
        RegionName.EVERFROST_PEAK: lambda state: everfrost_peak_door_1(world, state),
        RegionName.WALRUS_COVE: lambda state: walrus_cove_door_1(world, state),
        RegionName.SNOWBALL_VALLEY: lambda state: snowball_valley_door_1(world, state),
        RegionName.FROSTY_VILLAGE: lambda state: frosty_village_door_1(world, state),
        RegionName.ICICLE_PYRAMID: lambda state: icicle_pyramid(world, state),
        RegionName.BLUEY: lambda state: bluey_1(world, state),
        # Sherbet Island
        RegionName.WHALE_BAY: lambda state: whale_bay_door_1(world, state),
        RegionName.CRESCENT_ISLAND: lambda state: crescent_island_door_1(world, state),
        RegionName.PIRATE_LAGOON: lambda state: pirate_lagoon_door_1(world, state),
        RegionName.TREASURE_CAVES: lambda state: treasure_caves_door_1(world, state),
        RegionName.DARKWATER_BEACH: lambda state: darkwater_beach(world, state),
        RegionName.BUBBLER: lambda state: bubbler_1(world, state),
        # Dragon Forest
        RegionName.WINDMILL_PLAINS: lambda state: windmill_plains_door_1(world, state),
        RegionName.GREENWOOD_VILLAGE: lambda state: greenwood_village_door_1(world, state),
        RegionName.BOULDER_CANYON: lambda state: boulder_canyon_door_1(world, state),
        RegionName.HAUNTED_WOODS: lambda state: haunted_woods_door_1(world, state),
        RegionName.SMOKEY_CASTLE: lambda state: smokey_castle(world, state),
        RegionName.SMOKEY: lambda state: smokey_1(world, state),
        # Future Fun Land
        RegionName.SPACEDUST_ALLEY: lambda state: spacedust_alley_door_1(world, state),
        RegionName.DARKMOON_CAVERNS: lambda state: darkmoon_caverns_door_1(world, state),
        RegionName.SPACEPORT_ALPHA: lambda state: spaceport_alpha_door_1(world, state),
        RegionName.STAR_CITY: lambda state: star_city_door_1(world, state),
        RegionName.WIZPIG_2: lambda state: wizpig_2(world, state),
    }

    for region, rule in region_access_rules.items():
        entrance_name = convert_region_name_to_vanilla_entrance_name(region)
        entrance = world.get_entrance(entrance_name)
        set_rule(entrance, rule)


def set_balloon_rules(world: DiddyKongRacingWorld) -> None:
    balloon_rules = {
        LocationName.BRIDGE_BALLOON: lambda state: balloon_bridge(world, state),
        LocationName.WATERFALL_BALLOON: lambda state: balloon_waterfall(world, state),
        LocationName.RIVER_BALLOON: lambda state: balloon_river(world, state),
        LocationName.OCEAN_BALLOON: lambda state: balloon_ocean(world, state),
        LocationName.TAJ_CAR_RACE: lambda state: balloon_taj_car(world, state),
        LocationName.TAJ_HOVERCRAFT_RACE: lambda state: balloon_taj_hovercraft(world, state),
        LocationName.TAJ_PLANE_RACE: lambda state: balloon_taj_plane(world, state)
    }

    for location, rule in balloon_rules.items():
        balloon_location = get_player_location(world, location)
        set_rule(balloon_location, rule)


def set_race_2_location_rules(world: DiddyKongRacingWorld) -> None:
    race_door_2_rules = [
        lambda state: ancient_lake_door_2(world, state),
        lambda state: fossil_canyon_door_2(world, state),
        lambda state: jungle_falls_door_2(world, state),
        lambda state: hot_top_volcano_door_2(world, state),
        lambda state: everfrost_peak_door_2(world, state),
        lambda state: walrus_cove_door_2(world, state),
        lambda state: snowball_valley_door_2(world, state),
        lambda state: frosty_village_door_2(world, state),
        lambda state: whale_bay_door_2(world, state),
        lambda state: crescent_island_door_2(world, state),
        lambda state: pirate_lagoon_door_2(world, state),
        lambda state: treasure_caves_door_2(world, state),
        lambda state: windmill_plains_door_2(world, state),
        lambda state: greenwood_village_door_2(world, state),
        lambda state: boulder_canyon_door_2(world, state),
        lambda state: haunted_woods_door_2(world, state),
        lambda state: spacedust_alley_door_2(world, state),
        lambda state: darkmoon_caverns_door_2(world, state),
        lambda state: spaceport_alpha_door_2(world, state),
        lambda state: star_city_door_2(world, state)
    ]

    for door_num, entrance_num in enumerate(world.entrance_order):
        race_door_2_rule = race_door_2_rules[door_num]
        for location in VANILLA_RACE_2_LOCATIONS[entrance_num]:
            set_rule(get_player_location(world, location), race_door_2_rule)


def set_amulet_rules(world: DiddyKongRacingWorld) -> None:
    amulet_rules = {
        LocationName.TRICKY_2: lambda state: tricky_2(world, state),
        LocationName.BLUEY_2: lambda state: bluey_2(world, state),
        LocationName.BUBBLER_2: lambda state: bubbler_2(world, state),
        LocationName.SMOKEY_2: lambda state: smokey_2(world, state)
    }

    for location, rule in amulet_rules.items():
        amulet_location = get_player_location(world, location)
        set_rule(amulet_location, rule)


def set_door_unlock_rules(world: DiddyKongRacingWorld) -> None:
    door_unlock_rules = {}
    for door_unlock_info in vanilla_door_unlock_info_list:
        door_unlock_rules[door_unlock_info.location] = door_unlock(world, door_unlock_info.location)

    for location, rule in door_unlock_rules.items():
        if not (world.options.open_worlds and location in LocationName.WORLD_UNLOCK_LOCATIONS):
            door_unlock_location = get_player_location(world, location)
            set_rule(door_unlock_location, rule)


def get_player_location(world: DiddyKongRacingWorld, location_name) -> Location:
    return world.get_location(location_name)
