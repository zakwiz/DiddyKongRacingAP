from typing import TYPE_CHECKING, Any, Callable

from BaseClasses import CollectionState
from .DoorShuffle import get_requirement_for_location, vanilla_door_unlock_info_list
from .Names import ItemName, LocationName
from worlds.generic.Rules import set_rule


# I don't know what is going on here, but it works.
if TYPE_CHECKING:
    from . import DiddyKongRacingWorld
else:
    DiddyKongRacingWorld = object

# Shamelessly Stolen from KH2 :D


class DiddyKongRacingRules:
    player: int
    world: DiddyKongRacingWorld
    balloon_rules = {}
    key_rules = {}
    amulet_rules = {}

    def __init__(self, world: DiddyKongRacingWorld) -> None:
        self.player = world.player
        self.world = world

        self.balloon_rules = {
            # Timber's Island
            LocationName.BRIDGE_BALLOON: lambda state: self.balloon_bridge(state),
            LocationName.WATERFALL_BALLOON: lambda state: self.balloon_waterfall(state),
            LocationName.RIVER_BALLOON: lambda state: self.balloon_river(state),
            LocationName.OCEAN_BALLOON: lambda state: self.balloon_ocean(state),
            LocationName.TAJ_CAR_RACE: lambda state: self.balloon_taj_car(state),
            LocationName.TAJ_HOVERCRAFT_RACE: lambda state: self.balloon_taj_hovercraft(state),
            LocationName.TAJ_PLANE_RACE: lambda state: self.balloon_taj_plane(state),
            # Dino Domain
            LocationName.ANCIENT_LAKE_1: lambda state: self.balloon_ancient_lake_1(state),
            LocationName.ANCIENT_LAKE_2: lambda state: self.balloon_ancient_lake_2(state),
            LocationName.FOSSIL_CANYON_1: lambda state: self.balloon_fossil_canyon_1(state),
            LocationName.FOSSIL_CANYON_2: lambda state: self.balloon_fossil_canyon_2(state),
            LocationName.JUNGLE_FALLS_1: lambda state: self.balloon_jungle_falls_1(state),
            LocationName.JUNGLE_FALLS_2: lambda state: self.balloon_jungle_falls_2(state),
            LocationName.HOT_TOP_VOLCANO_1: lambda state: self.balloon_hot_top_volcano_1(state),
            LocationName.HOT_TOP_VOLCANO_2: lambda state: self.balloon_hot_top_volcano_2(state),
            # Snowflake Mountain
            LocationName.EVERFROST_PEAK_1: lambda state: self.balloon_everfrost_peak_1(state),
            LocationName.EVERFROST_PEAK_2: lambda state: self.balloon_everfrost_peak_2(state),
            LocationName.WALRUS_COVE_1: lambda state: self.balloon_walrus_cove_1(state),
            LocationName.WALRUS_COVE_2: lambda state: self.balloon_walrus_cove_2(state),
            LocationName.SNOWBALL_VALLEY_1: lambda state: self.balloon_snowball_valley_1(state),
            LocationName.SNOWBALL_VALLEY_2: lambda state: self.balloon_snowball_valley_2(state),
            LocationName.FROSTY_VILLAGE_1: lambda state: self.balloon_frosty_village_1(state),
            LocationName.FROSTY_VILLAGE_2: lambda state: self.balloon_frosty_village_2(state),
            # Sherbet Island
            LocationName.WHALE_BAY_1: lambda state: self.balloon_whale_bay_1(state),
            LocationName.WHALE_BAY_2: lambda state: self.balloon_whale_bay_2(state),
            LocationName.CRESCENT_ISLAND_1: lambda state: self.balloon_crescent_island_1(state),
            LocationName.CRESCENT_ISLAND_2: lambda state: self.balloon_crescent_island_2(state),
            LocationName.PIRATE_LAGOON_1: lambda state: self.balloon_pirate_lagoon_1(state),
            LocationName.PIRATE_LAGOON_2: lambda state: self.balloon_pirate_lagoon_2(state),
            LocationName.TREASURE_CAVES_1: lambda state: self.balloon_treasure_caves_1(state),
            LocationName.TREASURE_CAVES_2: lambda state: self.balloon_treasure_caves_2(state),
            # Dragon Forest
            LocationName.WINDMILL_PLAINS_1: lambda state: self.balloon_windmill_plains_1(state),
            LocationName.WINDMILL_PLAINS_2: lambda state: self.balloon_windmill_plains_2(state),
            LocationName.GREENWOOD_VILLAGE_1: lambda state: self.balloon_greenwood_village_1(state),
            LocationName.GREENWOOD_VILLAGE_2: lambda state: self.balloon_greenwood_village_2(state),
            LocationName.BOULDER_CANYON_1: lambda state: self.balloon_boulder_canyon_1(state),
            LocationName.BOULDER_CANYON_2: lambda state: self.balloon_boulder_canyon_2(state),
            LocationName.HAUNTED_WOODS_1: lambda state: self.balloon_haunted_woods_1(state),
            LocationName.HAUNTED_WOODS_2: lambda state: self.balloon_haunted_woods_2(state),
            # Future Fun Land
            LocationName.SPACEDUST_ALLEY_1: lambda state: self.balloon_spacedust_alley_1(state),
            LocationName.SPACEDUST_ALLEY_2: lambda state: self.balloon_spacedust_alley_2(state),
            LocationName.DARKMOON_CAVERNS_1: lambda state: self.balloon_darkmoon_caverns_1(state),
            LocationName.DARKMOON_CAVERNS_2: lambda state: self.balloon_darkmoon_caverns_2(state),
            LocationName.SPACEPORT_ALPHA_1: lambda state: self.balloon_spaceport_alpha_1(state),
            LocationName.SPACEPORT_ALPHA_2: lambda state: self.balloon_spaceport_alpha_2(state),
            LocationName.STAR_CITY_1: lambda state: self.balloon_star_city_1(state),
            LocationName.STAR_CITY_2: lambda state: self.balloon_star_city_2(state)
        }
        self.key_rules = {
            LocationName.FIRE_MOUNTAIN_KEY: lambda state: self.balloon_ancient_lake_2(state),
            LocationName.ICICLE_PYRAMID_KEY: lambda state: self.balloon_snowball_valley_2(state),
            LocationName.DARKWATER_BEACH_KEY: lambda state: self.balloon_crescent_island_2(state),
            LocationName.SMOKEY_CASTLE_KEY: lambda state: self.balloon_boulder_canyon_2(state)
        }
        self.amulet_rules = {
            LocationName.FIRE_MOUNTAIN: lambda state: self.fire_mountain(state),
            LocationName.ICICLE_PYRAMID: lambda state: self.icicle_pyramid(state),
            LocationName.DARKWATER_BEACH: lambda state: self.darkwater_beach(state),
            LocationName.SMOKEY_CASTLE: lambda state: self.smokey_castle(state),
            LocationName.TRICKY_2: lambda state: self.tricky_2(state),
            LocationName.BLUEY_2: lambda state: self.bluey_2(state),
            LocationName.BUBBLER_2: lambda state: self.bubbler_2(state),
            LocationName.SMOKEY_2: lambda state: self.smokey_2(state)
        }
        self.door_unlock_rules = {}
        for door_unlock_info in vanilla_door_unlock_info_list:
            self.door_unlock_rules[door_unlock_info.location] = self.door_unlock(self.world, door_unlock_info.location)
        self.event_rules = {
            LocationName.WIZPIG_1: lambda state: self.wizpig_1(state),
            LocationName.WIZPIG_2: lambda state: self.wizpig_2(state)
        }

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
                 (self.tricky_2(state) and self.bluey_2(state) and self.bubbler_2(state) and self.smokey_2(state))
                  )
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

    def balloon_ancient_lake_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.ANCIENT_LAKE_1_UNLOCK, self.player)

    def balloon_ancient_lake_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.ANCIENT_LAKE_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.DINO_DOMAIN_BALLOON))

    def balloon_fossil_canyon_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.FOSSIL_CANYON_1_UNLOCK, self.player)

    def balloon_fossil_canyon_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.FOSSIL_CANYON_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.DINO_DOMAIN_BALLOON))

    def balloon_jungle_falls_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.JUNGLE_FALLS_1_UNLOCK, self.player)

    def balloon_jungle_falls_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.JUNGLE_FALLS_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.DINO_DOMAIN_BALLOON))

    def balloon_hot_top_volcano_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.HOT_TOP_VOLCANO_1_UNLOCK, self.player)

    def balloon_hot_top_volcano_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.HOT_TOP_VOLCANO_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.DINO_DOMAIN_BALLOON))

    def balloon_everfrost_peak_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.EVERFROST_PEAK_1_UNLOCK, self.player)

    def balloon_everfrost_peak_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.EVERFROST_PEAK_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON))

    def balloon_walrus_cove_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.WALRUS_COVE_1_UNLOCK, self.player)

    def balloon_walrus_cove_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.WALRUS_COVE_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON))

    def balloon_snowball_valley_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.SNOWBALL_VALLEY_1_UNLOCK, self.player)

    def balloon_snowball_valley_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.SNOWBALL_VALLEY_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON))

    def balloon_frosty_village_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.FROSTY_VILLAGE_1_UNLOCK, self.player)

    def balloon_frosty_village_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.FROSTY_VILLAGE_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON))

    def balloon_whale_bay_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.WHALE_BAY_1_UNLOCK, self.player)

    def balloon_whale_bay_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.WHALE_BAY_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.SHERBET_ISLAND_BALLOON))

    def balloon_crescent_island_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.CRESCENT_ISLAND_1_UNLOCK, self.player)

    def balloon_crescent_island_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.CRESCENT_ISLAND_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.SHERBET_ISLAND_BALLOON))

    def balloon_pirate_lagoon_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.PIRATE_LAGOON_1_UNLOCK, self.player)

    def balloon_pirate_lagoon_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.PIRATE_LAGOON_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.SHERBET_ISLAND_BALLOON))

    def balloon_treasure_caves_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.TREASURE_CAVES_1_UNLOCK, self.player)

    def balloon_treasure_caves_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.TREASURE_CAVES_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.SHERBET_ISLAND_BALLOON))

    def balloon_windmill_plains_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.WINDMILL_PLAINS_1_UNLOCK, self.player)

    def balloon_windmill_plains_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.WINDMILL_PLAINS_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.DRAGON_FOREST_BALLOON))

    def balloon_greenwood_village_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.GREENWOOD_VILLAGE_1_UNLOCK, self.player)

    def balloon_greenwood_village_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.GREENWOOD_VILLAGE_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.DRAGON_FOREST_BALLOON))

    def balloon_boulder_canyon_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.BOULDER_CANYON_1_UNLOCK, self.player)

    def balloon_boulder_canyon_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.BOULDER_CANYON_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.DRAGON_FOREST_BALLOON))

    def balloon_haunted_woods_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.HAUNTED_WOODS_1_UNLOCK, self.player)

    def balloon_haunted_woods_2(self, state: CollectionState) -> bool:
        return (state.has(ItemName.HAUNTED_WOODS_2_UNLOCK, self.player)
                and self.can_access_boss_1(state, ItemName.DRAGON_FOREST_BALLOON))

    def balloon_spacedust_alley_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.SPACEDUST_ALLEY_1_UNLOCK, self.player)

    def balloon_spacedust_alley_2(self, state: CollectionState) -> bool:
        return state.has(ItemName.SPACEDUST_ALLEY_2_UNLOCK, self.player)

    def balloon_darkmoon_caverns_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.DARKMOON_CAVERNS_1_UNLOCK, self.player)

    def balloon_darkmoon_caverns_2(self, state: CollectionState) -> bool:
        return state.has(ItemName.DARKMOON_CAVERNS_2_UNLOCK, self.player)

    def balloon_spaceport_alpha_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.SPACEPORT_ALPHA_1_UNLOCK, self.player)

    def balloon_spaceport_alpha_2(self, state: CollectionState) -> bool:
        return state.has(ItemName.SPACEPORT_ALPHA_2_UNLOCK, self.player)

    def balloon_star_city_1(self, state: CollectionState) -> bool:
        return state.has(ItemName.STAR_CITY_1_UNLOCK, self.player)

    def balloon_star_city_2(self, state: CollectionState) -> bool:
        return state.has(ItemName.STAR_CITY_2_UNLOCK, self.player)

    def fire_mountain(self, state: CollectionState) -> bool:
        return state.has(ItemName.FIRE_MOUNTAIN_KEY, self.player)

    def icicle_pyramid(self, state: CollectionState) -> bool:
        return state.has(ItemName.ICICLE_PYRAMID_KEY, self.player)

    def darkwater_beach(self, state: CollectionState) -> bool:
        return state.has(ItemName.DARKWATER_BEACH_KEY, self.player)

    def smokey_castle(self, state: CollectionState) -> bool:
        return state.has(ItemName.SMOKEY_CASTLE_KEY, self.player)

    def tricky_2(self, state: CollectionState) -> bool:
        return self.can_access_boss_2(state, ItemName.DINO_DOMAIN_BALLOON)

    def bluey_2(self, state: CollectionState) -> bool:
        return self.can_access_boss_2(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON)

    def bubbler_2(self, state: CollectionState) -> bool:
        return self.can_access_boss_2(state, ItemName.SHERBET_ISLAND_BALLOON)

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
        for location, rules in self.balloon_rules.items():
            balloon_location = self.world.multiworld.get_location(location, self.player)
            set_rule(balloon_location, rules)

        for location, rules in self.key_rules.items():
            key_location = self.world.multiworld.get_location(location, self.player)
            set_rule(key_location, rules)

        for location, rules in self.amulet_rules.items():
            amulet_location = self.world.multiworld.get_location(location, self.player)
            set_rule(amulet_location, rules)

        for location, rules in self.door_unlock_rules.items():
            if not (self.world.options.open_worlds and location in LocationName.WORLD_UNLOCK_LOCATIONS):
                door_unlock_location = self.world.multiworld.get_location(location, self.player)
                set_rule(door_unlock_location, rules)

        if self.world.options.victory_condition.value == 0:
            victory_location_name = LocationName.WIZPIG_1
        elif self.world.options.victory_condition.value == 1:
            victory_location_name = LocationName.WIZPIG_2
        else:
            raise Exception("Unexpected victory condition")

        event_item_location = self.world.multiworld.get_location(victory_location_name, self.player)
        set_rule(event_item_location, self.event_rules[victory_location_name])

        self.world.multiworld.completion_condition[self.player] = lambda state: state.has(ItemName.VICTORY, self.player)
