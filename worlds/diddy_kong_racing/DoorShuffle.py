from __future__ import annotations

import math

from .Names import ItemName, LocationName


class DoorUnlockInfo:
    def __init__(self, item, location, requirement):
        self.item = item
        self.location = location
        self.requirement = requirement

vanilla_door_unlock_info_list: list[DoorUnlockInfo] = [
    DoorUnlockInfo(ItemName.DINO_DOMAIN_UNLOCK, LocationName.WORLD_1_UNLOCK, 1),
    DoorUnlockInfo(ItemName.SNOWFLAKE_MOUNTAIN_UNLOCK, LocationName.WORLD_2_UNLOCK, 2),
    DoorUnlockInfo(ItemName.SHERBET_ISLAND_UNLOCK, LocationName.WORLD_3_UNLOCK, 10),
    DoorUnlockInfo(ItemName.DRAGON_FOREST_UNLOCK, LocationName.WORLD_4_UNLOCK, 16),
    DoorUnlockInfo(ItemName.ANCIENT_LAKE_1_UNLOCK, LocationName.RACE_1_1_UNLOCK, 1),
    DoorUnlockInfo(ItemName.ANCIENT_LAKE_2_UNLOCK, LocationName.RACE_1_2_UNLOCK, 6),
    DoorUnlockInfo(ItemName.FOSSIL_CANYON_1_UNLOCK, LocationName.RACE_2_1_UNLOCK, 2),
    DoorUnlockInfo(ItemName.FOSSIL_CANYON_2_UNLOCK, LocationName.RACE_2_2_UNLOCK, 7),
    DoorUnlockInfo(ItemName.JUNGLE_FALLS_1_UNLOCK, LocationName.RACE_3_1_UNLOCK, 3),
    DoorUnlockInfo(ItemName.JUNGLE_FALLS_2_UNLOCK, LocationName.RACE_3_2_UNLOCK, 8),
    DoorUnlockInfo(ItemName.HOT_TOP_VOLCANO_1_UNLOCK, LocationName.RACE_4_1_UNLOCK, 5),
    DoorUnlockInfo(ItemName.HOT_TOP_VOLCANO_2_UNLOCK, LocationName.RACE_4_2_UNLOCK, 10),
    DoorUnlockInfo(ItemName.EVERFROST_PEAK_1_UNLOCK, LocationName.RACE_5_1_UNLOCK, 2),
    DoorUnlockInfo(ItemName.EVERFROST_PEAK_2_UNLOCK, LocationName.RACE_5_2_UNLOCK, 10),
    DoorUnlockInfo(ItemName.WALRUS_COVE_1_UNLOCK, LocationName.RACE_6_1_UNLOCK, 3),
    DoorUnlockInfo(ItemName.WALRUS_COVE_2_UNLOCK, LocationName.RACE_6_2_UNLOCK, 11),
    DoorUnlockInfo(ItemName.SNOWBALL_VALLEY_1_UNLOCK, LocationName.RACE_7_1_UNLOCK, 6),
    DoorUnlockInfo(ItemName.SNOWBALL_VALLEY_2_UNLOCK, LocationName.RACE_7_2_UNLOCK, 14),
    DoorUnlockInfo(ItemName.FROSTY_VILLAGE_1_UNLOCK, LocationName.RACE_8_1_UNLOCK, 9),
    DoorUnlockInfo(ItemName.FROSTY_VILLAGE_2_UNLOCK, LocationName.RACE_8_2_UNLOCK, 16),
    DoorUnlockInfo(ItemName.WHALE_BAY_1_UNLOCK, LocationName.RACE_9_1_UNLOCK, 10),
    DoorUnlockInfo(ItemName.WHALE_BAY_2_UNLOCK, LocationName.RACE_9_2_UNLOCK, 17),
    DoorUnlockInfo(ItemName.CRESCENT_ISLAND_1_UNLOCK, LocationName.RACE_10_1_UNLOCK, 11),
    DoorUnlockInfo(ItemName.CRESCENT_ISLAND_2_UNLOCK, LocationName.RACE_10_2_UNLOCK, 18),
    DoorUnlockInfo(ItemName.PIRATE_LAGOON_1_UNLOCK, LocationName.RACE_11_1_UNLOCK, 13),
    DoorUnlockInfo(ItemName.PIRATE_LAGOON_2_UNLOCK, LocationName.RACE_11_2_UNLOCK, 20),
    DoorUnlockInfo(ItemName.TREASURE_CAVES_1_UNLOCK, LocationName.RACE_12_1_UNLOCK, 16),
    DoorUnlockInfo(ItemName.TREASURE_CAVES_2_UNLOCK, LocationName.RACE_12_2_UNLOCK, 22),
    DoorUnlockInfo(ItemName.WINDMILL_PLAINS_1_UNLOCK, LocationName.RACE_13_1_UNLOCK, 16),
    DoorUnlockInfo(ItemName.WINDMILL_PLAINS_2_UNLOCK, LocationName.RACE_13_2_UNLOCK, 23),
    DoorUnlockInfo(ItemName.GREENWOOD_VILLAGE_1_UNLOCK, LocationName.RACE_14_1_UNLOCK, 17),
    DoorUnlockInfo(ItemName.GREENWOOD_VILLAGE_2_UNLOCK, LocationName.RACE_14_2_UNLOCK, 24),
    DoorUnlockInfo(ItemName.BOULDER_CANYON_1_UNLOCK, LocationName.RACE_15_1_UNLOCK, 20),
    DoorUnlockInfo(ItemName.BOULDER_CANYON_2_UNLOCK, LocationName.RACE_15_2_UNLOCK, 30),
    DoorUnlockInfo(ItemName.HAUNTED_WOODS_1_UNLOCK, LocationName.RACE_16_1_UNLOCK, 22),
    DoorUnlockInfo(ItemName.HAUNTED_WOODS_2_UNLOCK, LocationName.RACE_16_2_UNLOCK, 37),
    DoorUnlockInfo(ItemName.SPACEDUST_ALLEY_1_UNLOCK, LocationName.RACE_17_1_UNLOCK, 39),
    DoorUnlockInfo(ItemName.SPACEDUST_ALLEY_2_UNLOCK, LocationName.RACE_17_2_UNLOCK, 43),
    DoorUnlockInfo(ItemName.DARKMOON_CAVERNS_1_UNLOCK, LocationName.RACE_18_1_UNLOCK, 40),
    DoorUnlockInfo(ItemName.DARKMOON_CAVERNS_2_UNLOCK, LocationName.RACE_18_2_UNLOCK, 44),
    DoorUnlockInfo(ItemName.SPACEPORT_ALPHA_1_UNLOCK, LocationName.RACE_19_1_UNLOCK, 41),
    DoorUnlockInfo(ItemName.SPACEPORT_ALPHA_2_UNLOCK, LocationName.RACE_19_2_UNLOCK, 45),
    DoorUnlockInfo(ItemName.STAR_CITY_1_UNLOCK, LocationName.RACE_20_1_UNLOCK, 42),
    DoorUnlockInfo(ItemName.STAR_CITY_2_UNLOCK, LocationName.RACE_20_2_UNLOCK, 46)
]

vanilla_door_unlock_info_sorted_by_requirement: list[DoorUnlockInfo] = sorted(vanilla_door_unlock_info_list, key=lambda x: x.requirement)
cached_door_requirement_progression: list[int] | None = None


def get_door_requirement_progression(self) -> list[int]:
    global cached_door_requirement_progression
    if cached_door_requirement_progression:
        return cached_door_requirement_progression

    if self.options.door_requirement_progression == 0: # Vanilla
        door_requirement_progression = [x.requirement for x in vanilla_door_unlock_info_sorted_by_requirement]
    elif self.options.door_requirement_progression == 1: # Linear
        door_unlock_requirement_interval = (self.options.maximum_door_requirement - 1) / (len(vanilla_door_unlock_info_list) - 1)
        door_requirement_progression = []
        door_unlock_requirement = 1
        for _ in range(len(vanilla_door_unlock_info_list)):
            door_requirement_progression.append(math.floor(door_unlock_requirement))
            door_unlock_requirement += door_unlock_requirement_interval
    else: # Exponential
        door_requirement_progression = []
        ratio = self.options.maximum_door_requirement / 46
        for i in range(len(vanilla_door_unlock_info_list) - 1):
            door_requirement_progression.append(max(1, math.floor(ratio * 3.31 * math.exp(0.0628 * i) - 2)))

        door_requirement_progression.append(int(self.options.maximum_door_requirement))

    cached_door_requirement_progression = door_requirement_progression
    return door_requirement_progression


def get_requirement_for_location(self, location) -> int:
    for i in range(len(vanilla_door_unlock_info_sorted_by_requirement)):
        if vanilla_door_unlock_info_sorted_by_requirement[i].location == location:
            return get_door_requirement_progression(self)[i]


def shuffle_door_unlock_items(self) -> None:
    race_1_unlock_to_race_2_unlock = {
        ItemName.ANCIENT_LAKE_1_UNLOCK: ItemName.ANCIENT_LAKE_2_UNLOCK,
        ItemName.FOSSIL_CANYON_1_UNLOCK: ItemName.FOSSIL_CANYON_2_UNLOCK,
        ItemName.JUNGLE_FALLS_1_UNLOCK: ItemName.JUNGLE_FALLS_2_UNLOCK,
        ItemName.HOT_TOP_VOLCANO_1_UNLOCK: ItemName.HOT_TOP_VOLCANO_2_UNLOCK,
        ItemName.EVERFROST_PEAK_1_UNLOCK: ItemName.EVERFROST_PEAK_2_UNLOCK,
        ItemName.WALRUS_COVE_1_UNLOCK: ItemName.WALRUS_COVE_2_UNLOCK,
        ItemName.SNOWBALL_VALLEY_1_UNLOCK: ItemName.SNOWBALL_VALLEY_2_UNLOCK,
        ItemName.FROSTY_VILLAGE_1_UNLOCK: ItemName.FROSTY_VILLAGE_2_UNLOCK,
        ItemName.WHALE_BAY_1_UNLOCK: ItemName.WHALE_BAY_2_UNLOCK,
        ItemName.CRESCENT_ISLAND_1_UNLOCK: ItemName.CRESCENT_ISLAND_2_UNLOCK,
        ItemName.PIRATE_LAGOON_1_UNLOCK: ItemName.PIRATE_LAGOON_2_UNLOCK,
        ItemName.TREASURE_CAVES_1_UNLOCK: ItemName.TREASURE_CAVES_2_UNLOCK,
        ItemName.WINDMILL_PLAINS_1_UNLOCK: ItemName.WINDMILL_PLAINS_2_UNLOCK,
        ItemName.GREENWOOD_VILLAGE_1_UNLOCK: ItemName.GREENWOOD_VILLAGE_2_UNLOCK,
        ItemName.BOULDER_CANYON_1_UNLOCK: ItemName.BOULDER_CANYON_2_UNLOCK,
        ItemName.HAUNTED_WOODS_1_UNLOCK: ItemName.HAUNTED_WOODS_2_UNLOCK,
        ItemName.SPACEDUST_ALLEY_1_UNLOCK: ItemName.SPACEDUST_ALLEY_2_UNLOCK,
        ItemName.DARKMOON_CAVERNS_1_UNLOCK: ItemName.DARKMOON_CAVERNS_2_UNLOCK,
        ItemName.SPACEPORT_ALPHA_1_UNLOCK: ItemName.SPACEPORT_ALPHA_2_UNLOCK,
        ItemName.STAR_CITY_1_UNLOCK: ItemName.STAR_CITY_2_UNLOCK
    }

    dino_domain_race_1_unlocks = (
        ItemName.ANCIENT_LAKE_1_UNLOCK,
        ItemName.FOSSIL_CANYON_1_UNLOCK,
        ItemName.JUNGLE_FALLS_1_UNLOCK,
        ItemName.HOT_TOP_VOLCANO_1_UNLOCK
    )
    snowflake_mountain_race_1_unlocks = (
        ItemName.EVERFROST_PEAK_1_UNLOCK,
        ItemName.WALRUS_COVE_1_UNLOCK,
        ItemName.SNOWBALL_VALLEY_1_UNLOCK,
        ItemName.FROSTY_VILLAGE_1_UNLOCK
    )
    sherbet_island_race_1_unlocks = (
        ItemName.WHALE_BAY_1_UNLOCK,
        ItemName.CRESCENT_ISLAND_1_UNLOCK,
        ItemName.PIRATE_LAGOON_1_UNLOCK,
        ItemName.TREASURE_CAVES_1_UNLOCK
    )
    dragon_forest_race_1_unlocks = (
        ItemName.WINDMILL_PLAINS_1_UNLOCK,
        ItemName.GREENWOOD_VILLAGE_1_UNLOCK,
        ItemName.BOULDER_CANYON_1_UNLOCK,
        ItemName.HAUNTED_WOODS_1_UNLOCK
    )
    future_fun_land_race_1_unlocks = (
        ItemName.SPACEDUST_ALLEY_1_UNLOCK,
        ItemName.DARKMOON_CAVERNS_1_UNLOCK,
        ItemName.SPACEPORT_ALPHA_1_UNLOCK,
        ItemName.STAR_CITY_1_UNLOCK
    )

    if self.options.open_worlds:
        available_doors = [
            *dino_domain_race_1_unlocks,
            *snowflake_mountain_race_1_unlocks,
            *sherbet_island_race_1_unlocks,
            *dragon_forest_race_1_unlocks,
            *future_fun_land_race_1_unlocks
        ]
    else:
        available_doors = [
            ItemName.DINO_DOMAIN_UNLOCK,
            ItemName.SNOWFLAKE_MOUNTAIN_UNLOCK,
            ItemName.SHERBET_ISLAND_UNLOCK,
            ItemName.DRAGON_FOREST_UNLOCK
        ]

    race_2_unlock_count = 0

    for door_unlock_info, requirement in zip(vanilla_door_unlock_info_sorted_by_requirement, get_door_requirement_progression(self)):
        if not (self.options.open_worlds and door_unlock_info.location in LocationName.WORLD_UNLOCK_LOCATIONS):
            self.random.shuffle(available_doors)
            item = available_doors.pop()
            self.place_locked_item(door_unlock_info.location, self.create_event_item(item))

            if item == ItemName.DINO_DOMAIN_UNLOCK:
                available_doors.extend(dino_domain_race_1_unlocks)
            elif item == ItemName.SNOWFLAKE_MOUNTAIN_UNLOCK:
                available_doors.extend(snowflake_mountain_race_1_unlocks)
            elif item == ItemName.SHERBET_ISLAND_UNLOCK:
                available_doors.extend(sherbet_island_race_1_unlocks)
            elif item == ItemName.DRAGON_FOREST_UNLOCK:
                available_doors.extend(dragon_forest_race_1_unlocks)
            elif item in race_1_unlock_to_race_2_unlock:
                available_doors.append(race_1_unlock_to_race_2_unlock[item])
            elif not self.options.open_worlds:
                race_2_unlock_count += 1
                if race_2_unlock_count == 16:
                    available_doors.extend(future_fun_land_race_1_unlocks)


def place_vanilla_door_unlock_items(self) -> None:
    for door_unlock_info in vanilla_door_unlock_info_list:
        if not (self.options.open_worlds and door_unlock_info.location in LocationName.WORLD_UNLOCK_LOCATIONS):
            self.place_locked_item(door_unlock_info.location, self.create_event_item(door_unlock_info.item))


def place_door_unlock_items(self, door_unlock_requirements) -> None:
    filled_door_unlock_locations = set()

    for item_door_unlock_info, item_door_unlock_requirement in zip(vanilla_door_unlock_info_list, door_unlock_requirements):
        if not (self.options.open_worlds and item_door_unlock_info.location in LocationName.WORLD_UNLOCK_LOCATIONS):
            for location_door_unlock_info, location_door_unlock_requirement in zip(vanilla_door_unlock_info_sorted_by_requirement, get_door_requirement_progression(self)):
                location = location_door_unlock_info.location
                if item_door_unlock_requirement == location_door_unlock_requirement and location not in filled_door_unlock_locations:
                    self.place_locked_item(location, self.create_event_item(item_door_unlock_info.item))
                    filled_door_unlock_locations.add(location)
                    break


def get_door_unlock_requirements(self) -> list[int]:
    door_unlock_requirements = []
    for door_unlock_info in vanilla_door_unlock_info_list:
        if self.options.open_worlds and door_unlock_info.location in LocationName.WORLD_UNLOCK_LOCATIONS:
            door_unlock_requirements.append(0)
        else:
            location = self.multiworld.find_item(door_unlock_info.item, self.player).name
            door_unlock_requirements.append(get_requirement_for_location(self, location))

    return door_unlock_requirements
