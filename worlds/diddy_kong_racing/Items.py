from BaseClasses import Item
import typing
from .Names import ItemName


class DiddyKongRacingItem(Item):
    game: str = "Diddy Kong Racing"


class ItemData(typing.NamedTuple):
    dkr_id: int = 0
    qty: int = 0
    type: str = ""
    default_location: None | str = ""


BALLOON_TABLE = {
    ItemName.TIMBERS_ISLAND_BALLOON: ItemData(1616000, 7, "progress", None),
    ItemName.DINO_DOMAIN_BALLOON: ItemData(1616001, 8, "progress", None),
    ItemName.SNOWFLAKE_MOUNTAIN_BALLOON: ItemData(1616002, 8, "progress", None),
    ItemName.SHERBET_ISLAND_BALLOON: ItemData(1616003, 8, "progress", None),
    ItemName.DRAGON_FOREST_BALLOON: ItemData(1616004, 8, "progress", None),
    ItemName.FUTURE_FUN_LAND_BALLOON: ItemData(1616005, 8, "progress", None)
}

KEY_TABLE = {
    ItemName.FIRE_MOUNTAIN_KEY: ItemData(1616006, 1, "progress", None),
    ItemName.ICICLE_PYRAMID_KEY: ItemData(1616007, 1, "progress", None),
    ItemName.DARKWATER_BEACH_KEY: ItemData(1616008, 1, "progress", None),
    ItemName.SMOKEY_CASTLE_KEY: ItemData(1616009, 1, "progress", None)
}

AMULET_TABLE = {
    ItemName.WIZPIG_AMULET_PIECE: ItemData(1616010, 4, "progress", None),
    ItemName.TT_AMULET_PIECE: ItemData(1616011, 4, "progress", None)
}


ALL_ITEM_TABLE = {
    **BALLOON_TABLE,
    **KEY_TABLE,
    **AMULET_TABLE
}
