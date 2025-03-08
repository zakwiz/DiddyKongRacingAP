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


class ShuffleWizpigAmulet(Toggle):
    """Shuffle the 4 Wizpig amulet pieces into the item pool"""
    display_name = "Shuffle Wizpig amulet"


class ShuffleTTAmulet(Toggle):
    """Shuffle the 4 T.T. amulet pieces into the item pool"""
    display_name = "Shuffle T.T. amulet"


class OpenWorlds(Toggle):
    """All worlds, including Future Fun Land, will be open from the start"""
    display_name = "Open worlds"


class DoorRequirementProgression(Choice):
    """
    The progression of door requirement amounts:
        Vanilla: Same requirement amounts as vanilla, roughly exponential with a big jump at the end of Dragon Forest
            Looks like this: [1, 1, 2, 2, 2, 3, 3, 5, 6, 6, 7, 8, 9, 10, 10, 10, 10, 11, 11, 13, 14, 16, 16, 16, 16, 17, 17, 18, 20, 20, 22, 22, 23, 24, 30, 37, 39, 40, 41, 42, 43, 44, 45, 46]
        Linear: Door requirements go up at a consistent rate
            Looks like this if max door requirement = 46: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 46]
        Exponential: Door requirements are clustered towards lower numbers, same trend as vanilla but without big gaps
            Looks like this if max door requirement = 46: [1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 7, 7, 8, 8, 9, 10, 11, 12, 12, 13, 14, 16, 17, 18, 19, 21, 22, 24, 25, 27, 29, 31, 33, 36, 38, 41, 44, 46]
    """
    display_name = "Door requirement progression"
    option_vanilla = 0
    option_linear = 1
    option_exponential = 2


class MaximumDoorRequirement(Range):
    """Maximum balloon requirement for a numbered door (does not include the Wizpig 2 door). Only used if door requirement progression is not vanilla."""
    display_name = "Maximum door requirement"
    range_start = 1
    range_end = 46
    default = range_end


class ShuffleDoorRequirements(Toggle):
    """The balloon requirements to open all numbered doors will be shuffled"""
    display_name = "Shuffle door requirements"


class SkipTrophyRaces(DefaultOnToggle):
    """Start with all 1st place trophies, so you only need to beat Wizpig 1 to unlock Future Fun Land"""
    display_name = "Skip trophy races"


@dataclass
class DiddyKongRacingOptions(PerGameCommonOptions):
    victory_condition: VictoryCondition
    shuffle_wizpig_amulet: ShuffleWizpigAmulet
    shuffle_tt_amulet: ShuffleTTAmulet
    open_worlds: OpenWorlds
    door_requirement_progression: DoorRequirementProgression
    maximum_door_requirement: MaximumDoorRequirement
    shuffle_door_requirements: ShuffleDoorRequirements
    skip_trophy_races: SkipTrophyRaces
