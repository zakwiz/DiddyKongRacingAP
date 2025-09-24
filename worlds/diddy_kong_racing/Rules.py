from typing import TYPE_CHECKING, Any, Callable

from BaseClasses import CollectionState, Location
from worlds.generic.Rules import set_rule
from .DoorShuffle import get_requirement_for_location, vanilla_door_unlock_info_list
from .Names import ItemName, LocationName

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


class DiddyKongRacingRules:
    player: int
    world: DiddyKongRacingWorld
    balloon_rules: dict[str, Callable[[object], bool]] = {}
    door_rules: list[tuple[Callable[[object], bool], ...]] = []

    def __init__(self, world: DiddyKongRacingWorld) -> None:
        self.player = world.player
        self.world = world
        self.balloon_rules = {
            LocationName.BRIDGE_BALLOON: lambda state: self.balloon_bridge(state),
            LocationName.WATERFALL_BALLOON: lambda state: self.balloon_waterfall(state),
            LocationName.RIVER_BALLOON: lambda state: self.balloon_river(state),
            LocationName.OCEAN_BALLOON: lambda state: self.balloon_ocean(state),
            LocationName.TAJ_CAR_RACE: lambda state: self.balloon_taj_car(state),
            LocationName.TAJ_HOVERCRAFT_RACE: lambda state: self.balloon_taj_hovercraft(state),
            LocationName.TAJ_PLANE_RACE: lambda state: self.balloon_taj_plane(state)
        }
        self.door_rules = [
            (
                lambda state: self.ancient_lake_door_1(state),
                lambda state: self.ancient_lake_door_2(state)
            ),
            (
                lambda state: self.fossil_canyon_door_1(state),
                lambda state: self.fossil_canyon_door_2(state)
            ),
            (
                lambda state: self.jungle_falls_door_1(state),
                lambda state: self.jungle_falls_door_2(state)
            ),
            (
                lambda state: self.hot_top_volcano_door_1(state),
                lambda state: self.hot_top_volcano_door_2(state)
            ),
            (
                lambda state: self.everfrost_peak_door_1(state),
                lambda state: self.everfrost_peak_door_2(state)
            ),
            (
                lambda state: self.walrus_cove_door_1(state),
                lambda state: self.walrus_cove_door_2(state)
            ),
            (
                lambda state: self.snowball_valley_door_1(state),
                lambda state: self.snowball_valley_door_2(state)
            ),
            (
                lambda state: self.frosty_village_door_1(state),
                lambda state: self.frosty_village_door_2(state)
            ),
            (
                lambda state: self.whale_bay_door_1(state),
                lambda state: self.whale_bay_door_2(state)
            ),
            (
                lambda state: self.crescent_island_door_1(state),
                lambda state: self.crescent_island_door_2(state)
            ),
            (
                lambda state: self.pirate_lagoon_door_1(state),
                lambda state: self.pirate_lagoon_door_2(state)
            ),
            (
                lambda state: self.treasure_caves_door_1(state),
                lambda state: self.treasure_caves_door_2(state)
            ),
            (
                lambda state: self.windmill_plains_door_1(state),
                lambda state: self.windmill_plains_door_2(state)
            ),
            (
                lambda state: self.greenwood_village_door_1(state),
                lambda state: self.greenwood_village_door_2(state)
            ),
            (
                lambda state: self.boulder_canyon_door_1(state),
                lambda state: self.boulder_canyon_door_2(state)
            ),
            (
                lambda state: self.haunted_woods_door_1(state),
                lambda state: self.haunted_woods_door_2(state)
            ),
            (
                lambda state: self.spacedust_alley_door_1(state),
                lambda state: self.spacedust_alley_door_2(state)
            ),
            (
                lambda state: self.darkmoon_caverns_door_1(state),
                lambda state: self.darkmoon_caverns_door_2(state)
            ),
            (
                lambda state: self.spaceport_alpha_door_1(state),
                lambda state: self.spaceport_alpha_door_2(state)
            ),
            (
                lambda state: self.star_city_door_1(state),
                lambda state: self.star_city_door_2(state)
            ),
        ]
        self.amulet_rules = {
            LocationName.TRICKY_2: lambda state: self.tricky_2(state),
            LocationName.BLUEY_2: lambda state: self.bluey_2(state),
            LocationName.BUBBLER_2: lambda state: self.bubbler_2(state),
            LocationName.SMOKEY_2: lambda state: self.smokey_2(state)
        }
        self.door_unlock_rules = {}
        for door_unlock_info in vanilla_door_unlock_info_list:
            self.door_unlock_rules[door_unlock_info.location] = self.door_unlock(self.world, door_unlock_info.location)

    def can_access_dino_domain(self, state: CollectionState) -> bool:
        return self.world.options.open_worlds or state.has(ItemName.DINO_DOMAIN_UNLOCK, self.player)

    def can_access_snowflake_mountain(self, state: CollectionState) -> bool:
        return self.world.options.open_worlds or state.has(ItemName.SNOWFLAKE_MOUNTAIN_UNLOCK, self.player)

    def can_access_sherbet_island(self, state: CollectionState) -> bool:
        return self.world.options.open_worlds or state.has(ItemName.SHERBET_ISLAND_UNLOCK, self.player)

    def can_access_dragon_forest(self, state: CollectionState) -> bool:
        return self.world.options.open_worlds or state.has(ItemName.DRAGON_FOREST_UNLOCK, self.player)

    def can_access_future_fun_land(self, state: CollectionState) -> bool:
        return (self.world.options.open_worlds or
                self.wizpig_1(state) and
                (self.world.options.skip_trophy_races or
                 (self.tricky_2(state) and self.bluey_2(state) and self.bubbler_2(state) and self.smokey_2(state)))
                )

    def balloon_bridge(self, state: CollectionState) -> bool:
        return True

    def balloon_waterfall(self, state: CollectionState) -> bool:
        return True

    def balloon_river(self, state: CollectionState) -> bool:
        return True

    def balloon_ocean(self, state: CollectionState) -> bool:
        return True

    def balloon_taj_car(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 5)

    def balloon_taj_hovercraft(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 10)

    def balloon_taj_plane(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 18)

    def ancient_lake_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.ANCIENT_LAKE_DOOR_1_UNLOCK, self.player)

    def ancient_lake_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.ANCIENT_LAKE_DOOR_2_UNLOCK, self.player)
                and self.tricky_1(state))

    def fossil_canyon_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.FOSSIL_CANYON_DOOR_1_UNLOCK, self.player)

    def fossil_canyon_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.FOSSIL_CANYON_DOOR_2_UNLOCK, self.player)
                and self.tricky_1(state))

    def jungle_falls_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.JUNGLE_FALLS_DOOR_1_UNLOCK, self.player)

    def jungle_falls_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.JUNGLE_FALLS_DOOR_2_UNLOCK, self.player)
                and self.tricky_1(state))

    def hot_top_volcano_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.HOT_TOP_VOLCANO_DOOR_1_UNLOCK, self.player)

    def hot_top_volcano_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.HOT_TOP_VOLCANO_DOOR_2_UNLOCK, self.player)
                and self.tricky_1(state))

    def everfrost_peak_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.EVERFROST_PEAK_DOOR_1_UNLOCK, self.player)

    def everfrost_peak_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.EVERFROST_PEAK_DOOR_2_UNLOCK, self.player)
                and self.bluey_1(state))

    def walrus_cove_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.WALRUS_COVE_DOOR_1_UNLOCK, self.player)

    def walrus_cove_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.WALRUS_COVE_DOOR_2_UNLOCK, self.player)
                and self.bluey_1(state))

    def snowball_valley_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.SNOWBALL_VALLEY_DOOR_1_UNLOCK, self.player)

    def snowball_valley_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.SNOWBALL_VALLEY_DOOR_2_UNLOCK, self.player)
                and self.bluey_1(state))

    def frosty_village_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.FROSTY_VILLAGE_DOOR_1_UNLOCK, self.player)

    def frosty_village_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.FROSTY_VILLAGE_DOOR_2_UNLOCK, self.player)
                and self.bluey_1(state))

    def whale_bay_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.WHALE_BAY_DOOR_1_UNLOCK, self.player)

    def whale_bay_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.WHALE_BAY_DOOR_2_UNLOCK, self.player)
                and self.bubbler_1(state))

    def crescent_island_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.CRESCENT_ISLAND_DOOR_1_UNLOCK, self.player)

    def crescent_island_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.CRESCENT_ISLAND_DOOR_2_UNLOCK, self.player)
                and self.bubbler_1(state))

    def pirate_lagoon_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.PIRATE_LAGOON_DOOR_1_UNLOCK, self.player)

    def pirate_lagoon_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.PIRATE_LAGOON_DOOR_2_UNLOCK, self.player)
                and self.bubbler_1(state))

    def treasure_caves_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.TREASURE_CAVES_DOOR_1_UNLOCK, self.player)

    def treasure_caves_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.TREASURE_CAVES_DOOR_2_UNLOCK, self.player)
                and self.bubbler_1(state))

    def windmill_plains_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.WINDMILL_PLAINS_DOOR_1_UNLOCK, self.player)

    def windmill_plains_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.WINDMILL_PLAINS_DOOR_2_UNLOCK, self.player)
                and self.smokey_1(state))

    def greenwood_village_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.GREENWOOD_VILLAGE_DOOR_1_UNLOCK, self.player)

    def greenwood_village_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.GREENWOOD_VILLAGE_DOOR_2_UNLOCK, self.player)
                and self.smokey_1(state))

    def boulder_canyon_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.BOULDER_CANYON_DOOR_1_UNLOCK, self.player)

    def boulder_canyon_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.BOULDER_CANYON_DOOR_2_UNLOCK, self.player)
                and self.smokey_1(state))

    def haunted_woods_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.HAUNTED_WOODS_DOOR_1_UNLOCK, self.player)

    def haunted_woods_door_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.HAUNTED_WOODS_DOOR_2_UNLOCK, self.player)
                and self.smokey_1(state))

    def spacedust_alley_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.SPACEDUST_ALLEY_DOOR_1_UNLOCK, self.player)

    def spacedust_alley_door_2(self, state: CollectionState) -> bool:
        return state.has(ItemName.SPACEDUST_ALLEY_DOOR_2_UNLOCK, self.player)

    def darkmoon_caverns_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.DARKMOON_CAVERNS_DOOR_1_UNLOCK, self.player)

    def darkmoon_caverns_door_2(self, state: CollectionState) -> bool:
        return state.has(ItemName.DARKMOON_CAVERNS_DOOR_2_UNLOCK, self.player)

    def spaceport_alpha_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.SPACEPORT_ALPHA_DOOR_1_UNLOCK, self.player)

    def spaceport_alpha_door_2(self, state: CollectionState) -> bool:
        return state.has(ItemName.SPACEPORT_ALPHA_DOOR_2_UNLOCK, self.player)

    def star_city_door_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.STAR_CITY_DOOR_1_UNLOCK, self.player)

    def star_city_door_2(self, state: CollectionState) -> bool:
        return state.has(ItemName.STAR_CITY_DOOR_2_UNLOCK, self.player)

    def fire_mountain(self, state: CollectionState) -> bool:
        return state.has(ItemName.FIRE_MOUNTAIN_KEY, self.player)

    def icicle_pyramid(self, state: CollectionState) -> bool:
        return state.has(ItemName.ICICLE_PYRAMID_KEY, self.player)

    def darkwater_beach(self, state: CollectionState) -> bool:
        return state.has(ItemName.DARKWATER_BEACH_KEY, self.player)

    def smokey_castle(self, state: CollectionState) -> bool:
        return state.has(ItemName.SMOKEY_CASTLE_KEY, self.player)

    def tricky_1(self, state: CollectionState) -> bool:
        return self.can_access_boss_1(state, ItemName.DINO_DOMAIN_BALLOON)

    def tricky_2(self, state: CollectionState) -> bool:
        return self.can_access_boss_2(state, ItemName.DINO_DOMAIN_BALLOON)

    def bluey_1(self, state: CollectionState) -> bool:
        return self.can_access_boss_1(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON)

    def bluey_2(self, state: CollectionState) -> bool:
        return self.can_access_boss_2(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON)

    def bubbler_1(self, state: CollectionState) -> bool:
        return self.can_access_boss_1(state, ItemName.SHERBET_ISLAND_BALLOON)

    def bubbler_2(self, state: CollectionState) -> bool:
        return self.can_access_boss_2(state, ItemName.SHERBET_ISLAND_BALLOON)

    def smokey_1(self, state: CollectionState) -> bool:
        return self.can_access_boss_1(state, ItemName.DRAGON_FOREST_BALLOON)

    def smokey_2(self, state: CollectionState) -> bool:
        return self.can_access_boss_2(state, ItemName.DRAGON_FOREST_BALLOON)

    def wizpig_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.WIZPIG_AMULET_PIECE, self.player, self.world.options.wizpig_1_amulet_pieces.value)

    def wizpig_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.TT_AMULET_PIECE, self.player, self.world.options.wizpig_2_amulet_pieces.value)
                and self.has_total_balloon_count(state, self.world.options.wizpig_2_balloons.value))

    def door_unlock(self, world, location) -> Callable[[Any], bool]:
        return lambda state: self.has_total_balloon_count(state, get_requirement_for_location(world, location))

    def has_total_balloon_count(self, state: CollectionState, balloon_count: int) -> bool:
        collected_balloon_count = state.count_from_list(
            [
                ItemName.TIMBERS_ISLAND_BALLOON,
                ItemName.DINO_DOMAIN_BALLOON,
                ItemName.SNOWFLAKE_MOUNTAIN_BALLOON,
                ItemName.SHERBET_ISLAND_BALLOON,
                ItemName.DRAGON_FOREST_BALLOON,
                ItemName.FUTURE_FUN_LAND_BALLOON
            ],
            self.player
        )

        return collected_balloon_count >= balloon_count

    def can_access_boss_1(self, state: CollectionState, regional_balloon_item_name: str):
        return state.has(regional_balloon_item_name, self.player, self.world.options.boss_1_regional_balloons.value)

    def can_access_boss_2(self, state: CollectionState, regional_balloon_item_name: str):
        return state.has(regional_balloon_item_name, self.player, self.world.options.boss_2_regional_balloons.value)

    def set_rules(self) -> None:
        for location, rule in self.balloon_rules.items():
            balloon_location = self.get_player_location(location)
            set_rule(balloon_location, rule)

        for door_num, entrance_num in enumerate(self.world.entrance_order):
            door_2_unlock_rule = self.door_rules[door_num][1]
            for location in VANILLA_RACE_2_LOCATIONS[entrance_num]:
                set_rule(self.get_player_location(location), door_2_unlock_rule)

        for location, rule in self.amulet_rules.items():
            amulet_location = self.get_player_location(location)
            set_rule(amulet_location, rule)

        for location, rule in self.door_unlock_rules.items():
            if not (self.world.options.open_worlds and location in LocationName.WORLD_UNLOCK_LOCATIONS):
                door_unlock_location = self.get_player_location(location)
                set_rule(door_unlock_location, rule)

        self.world.multiworld.completion_condition[self.player] = lambda state: state.has(ItemName.VICTORY, self.player)

    def get_player_location(self, location_name) -> Location:
        return self.world.multiworld.get_location(location_name, self.player)
