from dataclasses import dataclass

from Options import Choice, DefaultOnToggle, PerGameCommonOptions, Range, Toggle


class VictoryCondition(Choice):
    """
    The victory condition for the seed:
        Beat Wizpig 1: Find the 4 Wizpig amulet pieces and beat the first Wizpig race. Future Fun Land items will not be randomized.
        Beat Wizpig 2: Get access to Future Fun Land, find the 4 T.T. amulet pieces and all 47 golden balloons, and beat the second Wizpig race.
    """
    display_name = "Victory condition"
    option_beat_wizpig_1 = 0
    option_beat_wizpig_2 = 1
    default = option_beat_wizpig_1


class StartingBalloonCount(Range):
    """Start with golden balloons, speeding up game progression and reducing the number of checks required for Wizpig 2"""
    display_name = "Starting balloon count"
    range_start = 0
    range_end = 47
    default = range_start


class StartingRegionalBalloonCount(Range):
    """
    Start with regional balloons for each region, allowing earlier boss access and reducing the number of checks required for Wizpig 1.
    4 regional balloons unlock the first boss race, and 8 unlock the second boss race. This will not affect your total balloon count.
    """
    display_name = "Starting regional balloon count"
    range_start = 0
    range_end = 8
    default = range_start


class StartingWizpigAmuletPieceCount(Range):
    """Start with Wizpig amulet pieces"""
    display_name = "Starting Wizpig amulet piece count"
    range_start = 0
    range_end = 4
    default = range_start


class StartingTTAmuletPieceCount(Range):
    """Start with T.T. amulet pieces"""
    display_name = "Starting T.T. amulet piece count"
    range_start = 0
    range_end = 4
    default = range_start


class ShuffleWizpigAmulet(Toggle):
    """Shuffle the 4 Wizpig amulet pieces into the item pool"""
    display_name = "Shuffle Wizpig amulet"


class ShuffleTTAmulet(Toggle):
    """Shuffle the 4 T.T. amulet pieces into the item pool"""
    display_name = "Shuffle T.T. amulet"


class SkipTrophyRaces(DefaultOnToggle):
    """Start with all 1st place trophies, so you only need to beat Wizpig 1 to unlock Future Fun Land"""
    display_name = "Skip trophy races"


@dataclass
class DiddyKongRacingOptions(PerGameCommonOptions):
    victory_condition: VictoryCondition
    starting_balloon_count: StartingBalloonCount
    starting_regional_balloon_count: StartingRegionalBalloonCount
    starting_wizpig_amulet_piece_count: StartingWizpigAmuletPieceCount
    starting_tt_amulet_piece_count: StartingTTAmuletPieceCount
    shuffle_wizpig_amulet: ShuffleWizpigAmulet
    shuffle_tt_amulet: ShuffleTTAmulet
    skip_trophy_races: SkipTrophyRaces
