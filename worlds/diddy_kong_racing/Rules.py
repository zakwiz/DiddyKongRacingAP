from BaseClasses import CollectionState
from typing import TYPE_CHECKING
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
            LocationName.FIRE_MOUNTAIN_KEY: lambda state: self.balloon_ancient_lake_1(state),
            LocationName.ICICLE_PYRAMID_KEY: lambda state: self.balloon_snowball_valley_1(state),
            LocationName.DARKWATER_BEACH_KEY: lambda state: self.balloon_crescent_island_1(state),
            LocationName.SMOKEY_CASTLE_KEY: lambda state: self.balloon_boulder_canyon_1(state)
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
        self.event_rules = {
            LocationName.WIZPIG_1: lambda state: self.wizpig_1(state),
            LocationName.WIZPIG_2: lambda state: self.wizpig_2(state)
        }

    def can_access_dino_domain(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 1)

    def can_access_snowflake_mountain(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 2)

    def can_access_sherbet_island(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 10)

    def can_access_dragon_forest(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 16)

    def can_access_future_fun_land(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 37)
                and self.wizpig_1(state))

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
        return self.has_total_balloon_count(state, 1)

    def balloon_ancient_lake_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 6)
                and self.can_access_boss_1(state, ItemName.DINO_DOMAIN_BALLOON))

    def balloon_fossil_canyon_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 2)

    def balloon_fossil_canyon_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 7)
                and self.can_access_boss_1(state, ItemName.DINO_DOMAIN_BALLOON))

    def balloon_jungle_falls_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 3)

    def balloon_jungle_falls_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 8)
                and self.can_access_boss_1(state, ItemName.DINO_DOMAIN_BALLOON))

    def balloon_hot_top_volcano_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 5)

    def balloon_hot_top_volcano_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 10)
                and self.can_access_boss_1(state, ItemName.DINO_DOMAIN_BALLOON))

    def balloon_everfrost_peak_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 2)

    def balloon_everfrost_peak_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 10)
                and self.can_access_boss_1(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON))

    def balloon_walrus_cove_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 3)

    def balloon_walrus_cove_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 11)
                and self.can_access_boss_1(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON))

    def balloon_snowball_valley_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 6)

    def balloon_snowball_valley_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 14)
                and self.can_access_boss_1(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON))

    def balloon_frosty_village_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 9)

    def balloon_frosty_village_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 16)
                and self.can_access_boss_1(state, ItemName.SNOWFLAKE_MOUNTAIN_BALLOON))

    def balloon_whale_bay_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 10)

    def balloon_whale_bay_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 17)
                and self.can_access_boss_1(state, ItemName.SHERBET_ISLAND_BALLOON))

    def balloon_crescent_island_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 11)

    def balloon_crescent_island_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 18)
                and self.can_access_boss_1(state, ItemName.SHERBET_ISLAND_BALLOON))

    def balloon_pirate_lagoon_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 13)

    def balloon_pirate_lagoon_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 20)
                and self.can_access_boss_1(state, ItemName.SHERBET_ISLAND_BALLOON))

    def balloon_treasure_caves_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 16)

    def balloon_treasure_caves_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 22)
                and self.can_access_boss_1(state, ItemName.SHERBET_ISLAND_BALLOON))

    def balloon_windmill_plains_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 16)

    def balloon_windmill_plains_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 23)
                and self.can_access_boss_1(state, ItemName.DRAGON_FOREST_BALLOON))

    def balloon_greenwood_village_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 17)

    def balloon_greenwood_village_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 24)
                and self.can_access_boss_1(state, ItemName.DRAGON_FOREST_BALLOON))

    def balloon_boulder_canyon_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 20)

    def balloon_boulder_canyon_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 30)
                and self.can_access_boss_1(state, ItemName.DRAGON_FOREST_BALLOON))

    def balloon_haunted_woods_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 22)

    def balloon_haunted_woods_2(self, state: CollectionState) -> bool:
        return (self.has_total_balloon_count(state, 37)
                and self.can_access_boss_1(state, ItemName.DRAGON_FOREST_BALLOON))

    def balloon_spacedust_alley_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 39)

    def balloon_spacedust_alley_2(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 43)

    def balloon_darkmoon_caverns_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 40)

    def balloon_darkmoon_caverns_2(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 44)

    def balloon_spaceport_alpha_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 41)

    def balloon_spaceport_alpha_2(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 45)

    def balloon_star_city_1(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 42)

    def balloon_star_city_2(self, state: CollectionState) -> bool:
        return self.has_total_balloon_count(state, 46)

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
        num_required_amulet_pieces = 4 - self.world.options.starting_wizpig_amulet_piece_count

        return state.has(ItemName.WIZPIG_AMULET_PIECE, self.player, num_required_amulet_pieces)

    def wizpig_2(self, state: CollectionState) -> bool:
        num_required_amulet_pieces = 4 - self.world.options.starting_tt_amulet_piece_count

        return (state.has(ItemName.TT_AMULET_PIECE, self.player, num_required_amulet_pieces)
                and self.has_total_balloon_count(state, 47))

    def has_total_balloon_count(self, state: CollectionState, balloon_count: int) -> bool:
        collected_balloon_count = (state.count(ItemName.TIMBERS_ISLAND_BALLOON, self.player)
                                   + state.count(ItemName.DINO_DOMAIN_BALLOON, self.player)
                                   + state.count(ItemName.SNOWFLAKE_MOUNTAIN_BALLOON, self.player)
                                   + state.count(ItemName.SHERBET_ISLAND_BALLOON, self.player)
                                   + state.count(ItemName.DRAGON_FOREST_BALLOON, self.player)
                                   + state.count(ItemName.FUTURE_FUN_LAND_BALLOON, self.player))

        return self.world.options.starting_balloon_count + collected_balloon_count >= balloon_count

    def can_access_boss_1(self, state: CollectionState, regional_balloon_item_name: str):
        num_required_regional_balloons = max(0, 4 - self.world.options.starting_regional_balloon_count.value)

        return state.has(regional_balloon_item_name, self.player, num_required_regional_balloons)

    def can_access_boss_2(self, state: CollectionState, regional_balloon_item_name: str):
        num_required_regional_balloons = max(0, 8 - self.world.options.starting_regional_balloon_count.value)

        return state.has(regional_balloon_item_name, self.player, num_required_regional_balloons)

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

        if self.world.options.victory_condition.value == 0:
            victory_location_name = LocationName.WIZPIG_1
        elif self.world.options.victory_condition.value == 1:
            victory_location_name = LocationName.WIZPIG_2
        else:
            raise Exception("Unexpected victory condition")

        event_item_location = self.world.multiworld.get_location(victory_location_name, self.player)
        set_rule(event_item_location, self.event_rules[victory_location_name])

        self.world.multiworld.completion_condition[self.player] = lambda state: state.has(ItemName.VICTORY, self.player)
