from typing import NamedTuple

from BaseClasses import Item
from .Names import ItemName


class DiddyKongRacingItem(Item):
    game: str = "Diddy Kong Racing"


class ItemData(NamedTuple):
    dkr_id: int
    count: int


BALLOON_TABLE = {
    ItemName.TIMBERS_ISLAND_BALLOON: ItemData(1616000, 7),
    ItemName.DINO_DOMAIN_BALLOON: ItemData(1616001, 8),
    ItemName.SNOWFLAKE_MOUNTAIN_BALLOON: ItemData(1616002, 8),
    ItemName.SHERBET_ISLAND_BALLOON: ItemData(1616003, 8),
    ItemName.DRAGON_FOREST_BALLOON: ItemData(1616004, 8),
    ItemName.FUTURE_FUN_LAND_BALLOON: ItemData(1616005, 8)
}

KEY_TABLE = {
    ItemName.FIRE_MOUNTAIN_KEY: ItemData(1616006, 1),
    ItemName.ICICLE_PYRAMID_KEY: ItemData(1616007, 1),
    ItemName.DARKWATER_BEACH_KEY: ItemData(1616008, 1),
    ItemName.SMOKEY_CASTLE_KEY: ItemData(1616009, 1)
}

AMULET_TABLE = {
    ItemName.WIZPIG_AMULET_PIECE: ItemData(1616010, 4),
    ItemName.TT_AMULET_PIECE: ItemData(1616011, 4)
}

ALL_ITEM_TABLE = {
    **BALLOON_TABLE,
    **KEY_TABLE,
    **AMULET_TABLE
}
