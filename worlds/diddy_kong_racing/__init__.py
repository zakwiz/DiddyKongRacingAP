from __future__ import annotations

from BaseClasses import Item, ItemClassification, Tutorial
from worlds.AutoWorld import WebWorld, World
from worlds.LauncherComponents import Component, components, launch_subprocess, Type

from .DoorShuffle import get_door_unlock_requirements, place_door_unlock_items, place_vanilla_door_unlock_items, shuffle_door_unlock_items
from .Items import DiddyKongRacingItem, ALL_ITEM_TABLE
from .Locations import ALL_LOCATION_TABLE
from .Regions import connect_regions, create_regions
from .Options import DiddyKongRacingOptions
from .Rules import DiddyKongRacingRules
from .Names import ItemName, LocationName


def run_client():
    from worlds.diddy_kong_racing.DKRClient import main
    launch_subprocess(main)


components.append(Component("Diddy Kong Racing Client", func=run_client, component_type=Type.CLIENT))


class DiddyKongRacingWeb(WebWorld):
    setup = Tutorial("Setup Diddy Kong Racing",
                     """A guide to setting up Archipelago Diddy Kong Racing on your computer.""",
                     "English",
                     "setup_en.md",
                     "setup/en",
                     ["zakwiz"])

    tutorials = [setup]


class DiddyKongRacingWorld(World):
    """Diddy Kong Racing is a kart racing game with a story mode, complete with bosses and hidden collectibles."""

    game = "Diddy Kong Racing"
    apworld_version = "DKRv0.6.1"
    web = DiddyKongRacingWeb()
    topology_preset = True
    item_name_to_id = {}

    for name, data in ALL_ITEM_TABLE.items():
        if data.dkr_id is None:  # Skip Victory Item
            continue
        item_name_to_id[name] = data.dkr_id

    location_name_to_id = {name: data.dkr_id for name, data in ALL_LOCATION_TABLE.items()}

    options_dataclass = DiddyKongRacingOptions
    options: DiddyKongRacingOptions

    def __init__(self, world, player) -> None:
        self.slot_data = []
        super(DiddyKongRacingWorld, self).__init__(world, player)

    def create_item(self, item_name: str) -> Item:
        item = ALL_ITEM_TABLE.get(item_name)

        item_classification = ItemClassification.progression
        if self.options.victory_condition.value != 1:
            if item_name == ItemName.TT_AMULET_PIECE:
                item_classification = ItemClassification.filler

        created_item = DiddyKongRacingItem(
            self.item_id_to_name[item.dkr_id],
            item_classification,
            item.dkr_id,
            self.player
        )

        return created_item

    def create_event_item(self, name: str) -> Item:
        created_item = DiddyKongRacingItem(name, ItemClassification.progression, None, self.player)

        return created_item

    def create_items(self) -> None:
        for name, dkr_id in ALL_ITEM_TABLE.items():
            if not self.item_pre_filled(name):
                for _ in range(dkr_id.count):
                    item = self.create_item(name)
                    self.multiworld.itempool.append(item)

    def item_pre_filled(self, item_name: str) -> bool:
        if self.options.victory_condition.value == 0 and item_name == ItemName.FUTURE_FUN_LAND_BALLOON:
            return True

        if not self.options.shuffle_wizpig_amulet and item_name == ItemName.WIZPIG_AMULET_PIECE:
            return True

        if not self.options.shuffle_tt_amulet and item_name == ItemName.TT_AMULET_PIECE:
            return True

        if item_name in ItemName.DOOR_UNLOCK_ITEMS:
            return True

        return False

    def create_regions(self) -> None:
        create_regions(self)
        connect_regions(self)

    def set_rules(self) -> None:
        rules = DiddyKongRacingRules(self)

        return rules.set_rules()

    def pre_fill(self) -> None:
        if self.options.victory_condition.value == 0:
            future_fun_land_balloon = self.create_item(ItemName.FUTURE_FUN_LAND_BALLOON)
            self.place_locked_item(LocationName.SPACEDUST_ALLEY_1, future_fun_land_balloon)
            self.place_locked_item(LocationName.SPACEDUST_ALLEY_2, future_fun_land_balloon)
            self.place_locked_item(LocationName.DARKMOON_CAVERNS_1, future_fun_land_balloon)
            self.place_locked_item(LocationName.DARKMOON_CAVERNS_2, future_fun_land_balloon)
            self.place_locked_item(LocationName.SPACEPORT_ALPHA_1, future_fun_land_balloon)
            self.place_locked_item(LocationName.SPACEPORT_ALPHA_2, future_fun_land_balloon)
            self.place_locked_item(LocationName.STAR_CITY_1, future_fun_land_balloon)
            self.place_locked_item(LocationName.STAR_CITY_2, future_fun_land_balloon)

        if not self.options.shuffle_wizpig_amulet:
            wizpig_amulet_item = self.create_item(ItemName.WIZPIG_AMULET_PIECE)
            self.place_locked_item(LocationName.TRICKY_2, wizpig_amulet_item)
            self.place_locked_item(LocationName.BLUEY_2, wizpig_amulet_item)
            self.place_locked_item(LocationName.BUBBLER_2, wizpig_amulet_item)
            self.place_locked_item(LocationName.SMOKEY_2, wizpig_amulet_item)

        if not self.options.shuffle_tt_amulet:
            tt_amulet_item = self.create_item(ItemName.TT_AMULET_PIECE)
            self.place_locked_item(LocationName.FIRE_MOUNTAIN, tt_amulet_item)
            self.place_locked_item(LocationName.ICICLE_PYRAMID, tt_amulet_item)
            self.place_locked_item(LocationName.DARKWATER_BEACH, tt_amulet_item)
            self.place_locked_item(LocationName.SMOKEY_CASTLE, tt_amulet_item)

        if self.options.shuffle_door_requirements:
            shuffle_door_unlock_items(self)
        else:
            place_vanilla_door_unlock_items(self)

    def place_locked_item(self, location_name: str, item: Item) -> None:
        self.multiworld.get_location(location_name, self.player).place_locked_item(item)

    def fill_slot_data(self) -> dict[str, any]:
        door_unlock_requirements = []
        if self.options.shuffle_door_requirements or self.options.door_requirement_progression != 0:
            door_unlock_requirements = get_door_unlock_requirements(self)

        dkr_options: dict[str, any] = {
            "apworld_version": self.apworld_version,
            "player_name": self.multiworld.player_name[self.player],
            "seed": self.random.randint(12212, 69996),
            "victory_condition": self.options.victory_condition.value,
            "shuffle_wizpig_amulet": "true" if self.options.shuffle_wizpig_amulet else "false",
            "shuffle_tt_amulet": "true" if self.options.shuffle_tt_amulet else "false",
            "open_worlds": "true" if self.options.open_worlds else "false",
            "door_requirement_progression": self.options.door_requirement_progression.value,
            "maximum_door_requirement": self.options.maximum_door_requirement.value,
            "shuffle_door_requirements": self.options.shuffle_door_requirements.value,
            "door_unlock_requirements": door_unlock_requirements,
            "boss_1_regional_balloons": self.options.boss_1_regional_balloons.value,
            "boss_2_regional_balloons": self.options.boss_2_regional_balloons.value,
            "wizpig_1_amulet_pieces": self.options.wizpig_1_amulet_pieces.value,
            "wizpig_2_amulet_pieces": self.options.wizpig_2_amulet_pieces.value,
            "wizpig_2_balloons": self.options.wizpig_2_balloons.value,
            "skip_trophy_races": "true" if self.options.skip_trophy_races else "false"
        }

        return dkr_options

    # For Universal Tracker, doesn't get called in standard generation
    def interpret_slot_data(self, slot_data: dict[str, any]) -> None:
        place_door_unlock_items(self, slot_data["door_unlock_requirements"])
