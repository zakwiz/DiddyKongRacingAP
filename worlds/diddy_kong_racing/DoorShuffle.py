from __future__ import annotations

from .Names import ItemName, LocationName

door_unlock_item_order = [
    ItemName.DINO_DOMAIN_UNLOCK,
    ItemName.SNOWFLAKE_MOUNTAIN_UNLOCK,
    ItemName.SHERBET_ISLAND_UNLOCK,
    ItemName.DRAGON_FOREST_UNLOCK,
    ItemName.ANCIENT_LAKE_1_UNLOCK,
    ItemName.ANCIENT_LAKE_2_UNLOCK,
    ItemName.FOSSIL_CANYON_1_UNLOCK,
    ItemName.FOSSIL_CANYON_2_UNLOCK,
    ItemName.JUNGLE_FALLS_1_UNLOCK,
    ItemName.JUNGLE_FALLS_2_UNLOCK,
    ItemName.HOT_TOP_VOLCANO_1_UNLOCK,
    ItemName.HOT_TOP_VOLCANO_2_UNLOCK,
    ItemName.EVERFROST_PEAK_1_UNLOCK,
    ItemName.EVERFROST_PEAK_2_UNLOCK,
    ItemName.WALRUS_COVE_1_UNLOCK,
    ItemName.WALRUS_COVE_2_UNLOCK,
    ItemName.SNOWBALL_VALLEY_1_UNLOCK,
    ItemName.SNOWBALL_VALLEY_2_UNLOCK,
    ItemName.FROSTY_VILLAGE_1_UNLOCK,
    ItemName.FROSTY_VILLAGE_2_UNLOCK,
    ItemName.WHALE_BAY_1_UNLOCK,
    ItemName.WHALE_BAY_2_UNLOCK,
    ItemName.CRESCENT_ISLAND_1_UNLOCK,
    ItemName.CRESCENT_ISLAND_2_UNLOCK,
    ItemName.PIRATE_LAGOON_1_UNLOCK,
    ItemName.PIRATE_LAGOON_2_UNLOCK,
    ItemName.TREASURE_CAVES_1_UNLOCK,
    ItemName.TREASURE_CAVES_2_UNLOCK,
    ItemName.WINDMILL_PLAINS_1_UNLOCK,
    ItemName.WINDMILL_PLAINS_2_UNLOCK,
    ItemName.GREENWOOD_VILLAGE_1_UNLOCK,
    ItemName.GREENWOOD_VILLAGE_2_UNLOCK,
    ItemName.BOULDER_CANYON_1_UNLOCK,
    ItemName.BOULDER_CANYON_2_UNLOCK,
    ItemName.HAUNTED_WOODS_1_UNLOCK,
    ItemName.HAUNTED_WOODS_2_UNLOCK,
    ItemName.SPACEDUST_ALLEY_1_UNLOCK,
    ItemName.SPACEDUST_ALLEY_2_UNLOCK,
    ItemName.DARKMOON_CAVERNS_1_UNLOCK,
    ItemName.DARKMOON_CAVERNS_2_UNLOCK,
    ItemName.SPACEPORT_ALPHA_1_UNLOCK,
    ItemName.SPACEPORT_ALPHA_2_UNLOCK,
    ItemName.STAR_CITY_1_UNLOCK,
    ItemName.STAR_CITY_2_UNLOCK
]

door_unlock_location_to_requirement = {
    LocationName.WORLD_1_UNLOCK: 1,
    LocationName.WORLD_2_UNLOCK: 2,
    LocationName.WORLD_3_UNLOCK: 10,
    LocationName.WORLD_4_UNLOCK: 16,
    LocationName.RACE_1_1_UNLOCK: 1,
    LocationName.RACE_1_2_UNLOCK: 6,
    LocationName.RACE_2_1_UNLOCK: 2,
    LocationName.RACE_2_2_UNLOCK: 7,
    LocationName.RACE_3_1_UNLOCK: 3,
    LocationName.RACE_3_2_UNLOCK: 8,
    LocationName.RACE_4_1_UNLOCK: 5,
    LocationName.RACE_4_2_UNLOCK: 10,
    LocationName.RACE_5_1_UNLOCK: 2,
    LocationName.RACE_5_2_UNLOCK: 10,
    LocationName.RACE_6_1_UNLOCK: 3,
    LocationName.RACE_6_2_UNLOCK: 11,
    LocationName.RACE_7_1_UNLOCK: 6,
    LocationName.RACE_7_2_UNLOCK: 14,
    LocationName.RACE_8_1_UNLOCK: 9,
    LocationName.RACE_8_2_UNLOCK: 16,
    LocationName.RACE_9_1_UNLOCK: 10,
    LocationName.RACE_9_2_UNLOCK: 17,
    LocationName.RACE_10_1_UNLOCK: 11,
    LocationName.RACE_10_2_UNLOCK: 18,
    LocationName.RACE_11_1_UNLOCK: 13,
    LocationName.RACE_11_2_UNLOCK: 20,
    LocationName.RACE_12_1_UNLOCK: 16,
    LocationName.RACE_12_2_UNLOCK: 22,
    LocationName.RACE_13_1_UNLOCK: 16,
    LocationName.RACE_13_2_UNLOCK: 23,
    LocationName.RACE_14_1_UNLOCK: 17,
    LocationName.RACE_14_2_UNLOCK: 24,
    LocationName.RACE_15_1_UNLOCK: 20,
    LocationName.RACE_15_2_UNLOCK: 30,
    LocationName.RACE_16_1_UNLOCK: 22,
    LocationName.RACE_16_2_UNLOCK: 37,
    LocationName.RACE_17_1_UNLOCK: 39,
    LocationName.RACE_17_2_UNLOCK: 43,
    LocationName.RACE_18_1_UNLOCK: 40,
    LocationName.RACE_18_2_UNLOCK: 44,
    LocationName.RACE_19_1_UNLOCK: 41,
    LocationName.RACE_19_2_UNLOCK: 45,
    LocationName.RACE_20_1_UNLOCK: 42,
    LocationName.RACE_20_2_UNLOCK: 46
}


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

    available_doors = [
        ItemName.DINO_DOMAIN_UNLOCK,
        ItemName.SNOWFLAKE_MOUNTAIN_UNLOCK,
        ItemName.SHERBET_ISLAND_UNLOCK,
        ItemName.DRAGON_FOREST_UNLOCK
    ]

    race_2_unlock_count = 0

    for location, requirement in sorted(door_unlock_location_to_requirement.items(), key=lambda x: x[1]):
        self.random.shuffle(available_doors)
        item = available_doors.pop()
        self.place_locked_item(location, self.create_event_item(item))

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
        else:
            race_2_unlock_count += 1
            if race_2_unlock_count == 16:
                available_doors.extend(future_fun_land_race_1_unlocks)


def place_vanilla_door_unlock_items(self) -> None:
    for door_unlock_location, door_unlock_item in zip(door_unlock_location_to_requirement.keys(), door_unlock_item_order):
        self.place_locked_item(door_unlock_location, self.create_event_item(door_unlock_item))


def place_door_unlock_items(self, door_unlock_requirements) -> None:
    filled_door_unlock_locations = set()

    for door_unlock_item, item_door_unlock_requirement in zip(door_unlock_item_order, door_unlock_requirements):
        for door_unlock_location, location_door_unlock_requirement in door_unlock_location_to_requirement.items():
            if item_door_unlock_requirement == location_door_unlock_requirement and door_unlock_location not in filled_door_unlock_locations:
                self.place_locked_item(door_unlock_location, self.create_event_item(door_unlock_item))
                filled_door_unlock_locations.add(door_unlock_location)
                break


def get_door_unlock_requirements(self) -> list[int]:
    door_unlock_requirements = []
    for door_unlock_item in door_unlock_item_order:
        door_unlock_requirements.append(
            door_unlock_location_to_requirement[self.multiworld.find_item(door_unlock_item, self.player).name]
        )

    return door_unlock_requirements
