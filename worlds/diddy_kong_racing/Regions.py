from __future__ import annotations

from BaseClasses import Region
from .Names import ItemName, LocationName, RegionName
from .Locations import DiddyKongRacingLocation
from .Rules import DiddyKongRacingRules


DIDDY_KONG_RACING_REGIONS: dict[str, list[str]] = {
    RegionName.MENU: [],
    RegionName.TIMBERS_ISLAND: [
        LocationName.BRIDGE_BALLOON,
        LocationName.WATERFALL_BALLOON,
        LocationName.OCEAN_BALLOON,
        LocationName.RIVER_BALLOON,
        LocationName.TAJ_CAR_RACE,
        LocationName.TAJ_HOVERCRAFT_RACE,
        LocationName.TAJ_PLANE_RACE,
        LocationName.WIZPIG_1
    ],
    RegionName.DINO_DOMAIN: [
        LocationName.ANCIENT_LAKE_1,
        LocationName.ANCIENT_LAKE_2,
        LocationName.FOSSIL_CANYON_1,
        LocationName.FOSSIL_CANYON_2,
        LocationName.JUNGLE_FALLS_1,
        LocationName.JUNGLE_FALLS_2,
        LocationName.HOT_TOP_VOLCANO_1,
        LocationName.HOT_TOP_VOLCANO_2,
        LocationName.FIRE_MOUNTAIN_KEY,
        LocationName.FIRE_MOUNTAIN,
        LocationName.TRICKY_2
    ],
    RegionName.SNOWFLAKE_MOUNTAIN: [
        LocationName.EVERFROST_PEAK_1,
        LocationName.EVERFROST_PEAK_2,
        LocationName.WALRUS_COVE_1,
        LocationName.WALRUS_COVE_2,
        LocationName.SNOWBALL_VALLEY_1,
        LocationName.SNOWBALL_VALLEY_2,
        LocationName.FROSTY_VILLAGE_1,
        LocationName.FROSTY_VILLAGE_2,
        LocationName.ICICLE_PYRAMID_KEY,
        LocationName.ICICLE_PYRAMID,
        LocationName.BLUEY_2
    ],
    RegionName.SHERBET_ISLAND: [
        LocationName.WHALE_BAY_1,
        LocationName.WHALE_BAY_2,
        LocationName.CRESCENT_ISLAND_1,
        LocationName.CRESCENT_ISLAND_2,
        LocationName.PIRATE_LAGOON_1,
        LocationName.PIRATE_LAGOON_2,
        LocationName.TREASURE_CAVES_1,
        LocationName.TREASURE_CAVES_2,
        LocationName.DARKWATER_BEACH_KEY,
        LocationName.DARKWATER_BEACH,
        LocationName.BUBBLER_2
    ],
    RegionName.DRAGON_FOREST: [
        LocationName.WINDMILL_PLAINS_1,
        LocationName.WINDMILL_PLAINS_2,
        LocationName.GREENWOOD_VILLAGE_1,
        LocationName.GREENWOOD_VILLAGE_2,
        LocationName.BOULDER_CANYON_1,
        LocationName.BOULDER_CANYON_2,
        LocationName.HAUNTED_WOODS_1,
        LocationName.HAUNTED_WOODS_2,
        LocationName.SMOKEY_CASTLE_KEY,
        LocationName.SMOKEY_CASTLE,
        LocationName.SMOKEY_2
    ],
    RegionName.FUTURE_FUN_LAND: [
        LocationName.SPACEDUST_ALLEY_1,
        LocationName.SPACEDUST_ALLEY_2,
        LocationName.DARKMOON_CAVERNS_1,
        LocationName.DARKMOON_CAVERNS_2,
        LocationName.SPACEPORT_ALPHA_1,
        LocationName.SPACEPORT_ALPHA_2,
        LocationName.STAR_CITY_1,
        LocationName.STAR_CITY_2,
        LocationName.WIZPIG_2
    ]
}


def create_regions(self) -> None:
    multiworld = self.multiworld
    player = self.player
    active_locations = self.location_name_to_id

    if self.options.victory_condition.value == 0:
        victory_item_location = LocationName.WIZPIG_1
    elif self.options.victory_condition.value == 1:
        victory_item_location = LocationName.WIZPIG_2
    else:
        raise Exception("Unexpected victory condition")

    multiworld.regions += [
        create_region(self, multiworld, player, active_locations, region, locations, victory_item_location)
        for region, locations in DIDDY_KONG_RACING_REGIONS.items()
    ]

    multiworld.get_location(victory_item_location, player).place_locked_item(
        multiworld.worlds[player].create_event_item(ItemName.VICTORY)
    )


def create_region(self, multiworld, player: int, active_locations, name: str, locations, victory_item_location) -> Region:
    region = Region(name, player, multiworld)
    if name == RegionName.MENU:
        region.add_locations({location: None for location in LocationName.DOOR_UNLOCK_LOCATIONS})

        if not self.options.open_worlds:
            region.add_locations({location: None for location in LocationName.WORLD_UNLOCK_LOCATIONS})
    elif locations:
        if victory_item_location in locations:
            region.add_locations({victory_item_location: None})

        location_to_id = {location: active_locations.get(location, 0) for location in locations if active_locations.get(location, None)}
        region.add_locations(location_to_id, DiddyKongRacingLocation)

    return region


def connect_regions(self) -> None:
    multiworld = self.multiworld
    player = self.player
    rules = DiddyKongRacingRules(self)

    region_menu = multiworld.get_region(RegionName.MENU, player)
    region_menu.add_exits({RegionName.TIMBERS_ISLAND})

    region_timbers_island = multiworld.get_region(RegionName.TIMBERS_ISLAND, player)
    region_timbers_island.add_exits(
        {
            RegionName.DINO_DOMAIN,
            RegionName.SNOWFLAKE_MOUNTAIN,
            RegionName.SHERBET_ISLAND,
            RegionName.DRAGON_FOREST,
            RegionName.FUTURE_FUN_LAND
        },
        {
            RegionName.DINO_DOMAIN: lambda state: rules.can_access_dino_domain(state),
            RegionName.SNOWFLAKE_MOUNTAIN: lambda state: rules.can_access_snowflake_mountain(state),
            RegionName.SHERBET_ISLAND: lambda state: rules.can_access_sherbet_island(state),
            RegionName.DRAGON_FOREST: lambda state: rules.can_access_dragon_forest(state),
            RegionName.FUTURE_FUN_LAND: lambda state: rules.can_access_future_fun_land(state)
        }
    )
