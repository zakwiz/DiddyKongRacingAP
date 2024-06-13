import random
from multiprocessing import Process
import typing
from .Items import DiddyKongRacingItem, ALL_ITEM_TABLE
from .Locations import DiddyKongRacingLocation, ALL_LOCATION_TABLE
from .Regions import DIDDY_KONG_RACING_REGIONS, create_regions, connect_regions
from .Options import DiddyKongRacingOptions
from .Rules import DiddyKongRacingRules
from .Names import ItemName, LocationName, RegionName

from BaseClasses import ItemClassification, Tutorial, Item
from ..AutoWorld import World, WebWorld
from ..LauncherComponents import Component, components, Type


def run_client():
    from worlds.diddy_kong_racing.DKRClient import main
    p = Process(target=main)
    p.start()


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
    """
    Diddy Kong Racing is a kart racing game with a story mode, complete with bosses and hidden collectibles.
    """

    game: str = "Diddy Kong Racing"
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

    def __init__(self, world, player):
        self.slot_data = []
        super(DiddyKongRacingWorld, self).__init__(world, player)

    def create_item(self, item_name: str) -> Item:
        dkr_item = ALL_ITEM_TABLE.get(item_name)

        if dkr_item.type == "victory":
            return DiddyKongRacingItem(ItemName.VICTORY, ItemClassification.filler, None, self.player)

        created_item = DiddyKongRacingItem(
            self.item_id_to_name[dkr_item.dkr_id],
            ItemClassification.progression,
            dkr_item.dkr_id,
            self.player
        )

        return created_item

    def create_event_item(self, name: str) -> Item:
        item_classification = ItemClassification.progression
        created_item = DiddyKongRacingItem(name, item_classification, None, self.player)

        return created_item

    def create_items(self) -> None:
        for name, item_id in ALL_ITEM_TABLE.items():
            if self.item_not_pre_filled(name):
                for i in range(item_id.qty):
                    item = self.create_item(name)
                    self.multiworld.itempool.append(item)

    def item_not_pre_filled(self, item_name: str) -> bool:
        if self.options.victory_condition.value == 0 and item_name == ItemName.FUTURE_FUN_LAND_BALLOON:
            return False

        if not self.options.shuffle_wizpig_amulet and item_name == ItemName.WIZPIG_AMULET_PIECE:
            return False

        if not self.options.shuffle_tt_amulet and item_name == ItemName.TT_AMULET_PIECE:
            return False

        return True

    def create_regions(self) -> None:
        create_regions(self)
        connect_regions(self)

    def set_rules(self) -> None:
        rules = Rules.DiddyKongRacingRules(self)

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

    def place_locked_item(self, location_name: str, item: Item) -> None:
        self.multiworld.get_location(location_name, self.player).place_locked_item(item)

    def fill_slot_data(self) -> dict[str, any]:
        dkr_options = dict[str, any]()
        dkr_options["player_name"] = self.multiworld.player_name[self.player]
        dkr_options["seed"] = random.randint(12212, 69996)
        dkr_options["skip_trophy_races"] = "true" if self.options.skip_trophy_races else "false"
        dkr_options["victory_condition"] = self.options.victory_condition.value

        return dkr_options

    # For the universal tracker, doesn't get called in standard gen
    @staticmethod
    def interpret_slot_data(slot_data: typing.Dict[str, typing.Any]) -> typing.Dict[str, typing.Any]:
        # Returning slot_data so it regens, giving it back in multiworld.re_gen_passthrough
        return slot_data
