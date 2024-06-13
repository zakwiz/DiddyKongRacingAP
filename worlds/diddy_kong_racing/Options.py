from dataclasses import dataclass
from Options import Choice, DefaultOnToggle, PerGameCommonOptions, Toggle


class VictoryCondition(Choice):
    """
    The victory condition for the seed:
        Beat Wizpig 1: Find the 4 Wizpig amulet pieces and beat the first Wizpig race. Future Fun Land will not be part of the seed.
        Beat Wizpig 2: Get access to Future Fun Land, find the 4 T.T. amulet pieces and all 47 golden balloons, and beat the second Wizpig race.
    """
    display_name: "Victory condition"
    option_beat_wizpig_1 = 0
    option_beat_wizpig_2 = 1
    default = 0


class ShuffleWizpigAmulet(Toggle):
    """Shuffle the 4 Wizpig amulet pieces into the item pool"""
    display_name: "Shuffle Wizpig amulet"


class ShuffleTTAmulet(Toggle):
    """Shuffle the 4 T.T. amulet pieces into the item pool"""
    display_name: "Shuffle T.T. amulet"


class SkipTrophyRaces(DefaultOnToggle):
    """Start with all 1st place trophies, so you only need to beat Wizpig 1 to unlock Future Fun Land"""
    display_name: "Skip trophy races"


@dataclass
class DiddyKongRacingOptions(PerGameCommonOptions):
    victory_condition: VictoryCondition
    shuffle_wizpig_amulet: ShuffleWizpigAmulet
    shuffle_tt_amulet: ShuffleTTAmulet
    skip_trophy_races: SkipTrophyRaces
