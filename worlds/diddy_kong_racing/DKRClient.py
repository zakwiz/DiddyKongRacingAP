from __future__ import annotations

from asyncio import create_task, open_connection, run, StreamReader, StreamWriter, TimeoutError, wait_for
from copy import deepcopy
from json import dumps, loads
from multiprocessing import freeze_support
from sys import argv

# CommonClient import first to trigger ModuleUpdater
from CommonClient import ClientCommandProcessor, CommonContext, get_base_parser, gui_enabled, logger, server_loop
from Utils import async_start, init_logging
from worlds import network_data_package

SYSTEM_MESSAGE_ID = 0

CONNECTION_TIMING_OUT_STATUS = "Connection timing out. Please restart your emulator, then restart connector_diddy_kong_racing.lua"
CONNECTION_REFUSED_STATUS = "Connection refused. Please start your emulator and make sure connector_diddy_kong_racing.lua is running"
CONNECTION_RESET_STATUS = "Connection was reset. Please restart your emulator, then restart connector_diddy_kong_racing.lua"
CONNECTION_TENTATIVE_STATUS = "Initial Connection Made"
CONNECTION_CONNECTED_STATUS = "Connected"
CONNECTION_INITIAL_STATUS = "Connection has not been initiated"

"""
Payload: lua -> client
{
    playerName: string,
    locations: dict,
    gameComplete: bool
}

Payload: client -> lua
{
    items: list,
    playerNames: list,
    messages: string
}

"""

logger.info(network_data_package["games"].keys())
dkr_loc_name_to_id = network_data_package["games"]["Diddy Kong Racing"]["location_name_to_id"]
dkr_itm_name_to_id = network_data_package["games"]["Diddy Kong Racing"]["item_name_to_id"]

apworld_version: str = "DKRv0.5.2"


def get_item_value(ap_id):
    return ap_id


class DiddyKongRacingCommandProcessor(ClientCommandProcessor):
    def __init__(self, ctx): 
        super().__init__(ctx)

    def _cmd_n64(self):
        """Check N64 Connection State"""
        if isinstance(self.ctx, DiddyKongRacingContext):
            logger.info(f"N64 Status: {self.ctx.n64_status}")


class DiddyKongRacingContext(CommonContext):
    command_processor = DiddyKongRacingCommandProcessor
    items_handling = 0b111  # full

    def __init__(self, server_address, password):
        super().__init__(server_address, password)
        self.game = 'Diddy Kong Racing'
        self.n64_streams: (StreamReader, StreamWriter) = None  # type: ignore
        self.n64_sync_task = None
        self.n64_status = CONNECTION_INITIAL_STATUS
        self.awaiting_rom = False
        self.location_table = {}
        self.version_warning = False
        self.messages = {}
        self.slot_data = {}
        self.sendSlot = False
        self.sync_ready = False
        self.startup = False

    async def server_auth(self, password_requested: bool = False):
        if password_requested and not self.password:
            await super(DiddyKongRacingContext, self).server_auth(password_requested)

        if not self.auth:
            await self.get_username()
            await self.send_connect()
            self.awaiting_rom = True

            return

        return

    def _set_message(self, msg: str, msg_id: int | None):
        if msg_id is None:
            self.messages.update({len(self.messages)+1: msg})
        else:
            self.messages.update({msg_id: msg})

    def run_gui(self):
        from kvui import GameManager

        class DiddyKongRacingManager(GameManager):
            logging_pairs = [
                ("Client", "Archipelago")
            ]
            base_title = "Archipelago Diddy Kong Racing Client"

        self.ui = DiddyKongRacingManager(self)
        self.ui_task = create_task(self.ui.async_run(), name="UI")

    def on_package(self, cmd, args):
        if cmd == 'Connected':
            self.slot_data = args.get('slot_data')
            generated_apworld_version = self.slot_data["apworld_version"]

            if apworld_version != generated_apworld_version:
                error_message = "Your Diddy Kong Racing apworld version (" + apworld_version + ") does not match the generated world's apworld version (" + generated_apworld_version + ")."
                logger.error(error_message)
                raise Exception(error_message)

            logger.info("Please open Diddy Kong Racing and load connector_diddy_kong_racing.lua")
            self.n64_sync_task = create_task(n64_sync_task(self), name="N64 Sync")
        elif cmd == 'Print':
            msg = args['text']
            if ': !' not in msg:
                self._set_message(msg, SYSTEM_MESSAGE_ID)
        elif cmd == "ReceivedItems":
            if not self.startup:
                for item in args["items"]:
                    player = ""
                    item_name = ""
                    for (i, name) in self.player_names.items():
                        if i == item.player:
                            player = name
                            break

                    for (name, i) in dkr_itm_name_to_id.items():
                        if item.item == i:
                            item_name = name
                            break                    
                    logger.info(player + " sent " + item_name)
                logger.info("The above items will be sent when Diddy Kong Racing is loaded.")
                self.startup = True

    def on_print_json(self, args: dict):
        if self.ui:
            self.ui.print_json(deepcopy(args["data"]))
            relevant = args.get("type", None) in {"Hint", "ItemSend"}
            if relevant:
                relevant = False
                item = args["item"]
                if self.slot_concerns_self(args["receiving"]):
                    relevant = True 
                elif self.slot_concerns_self(item.player):
                    relevant = True

                if relevant:
                    msg = self.raw_text_parser(deepcopy(args["data"]))
                    self._set_message(msg, None)
        else:
            text = self.jsontotextparser(deepcopy(args["data"]))
            logger.info(text)
            relevant = args.get("type", None) in {"Hint", "ItemSend"}
            if relevant:
                msg = self.raw_text_parser(deepcopy(args["data"]))
                self._set_message(msg, None)


def get_payload(ctx: DiddyKongRacingContext):
    if ctx.sync_ready:
        ctx.startup = True
        payload = dumps({
                "items": [get_item_value(item.item) for item in ctx.items_received],
                "playerNames": [name for (i, name) in ctx.player_names.items() if i != 0],
                "messages": [message for (i, message) in ctx.messages.items() if i != 0],
            })
    else:
        ctx.startup = False
        payload = dumps({
                "items": [],
                "playerNames": [name for (i, name) in ctx.player_names.items() if i != 0],
                "messages": [message for (i, message) in ctx.messages.items() if i != 0],
            })

    if len(ctx.messages) > 0:
        ctx.messages = {}

    return payload


def get_slot_payload(ctx: DiddyKongRacingContext):
    payload = dumps({
            "slot_player": ctx.slot_data["player_name"],
            "slot_seed": ctx.slot_data["seed"],
            "slot_victory_condition": ctx.slot_data["victory_condition"],
            "slot_open_worlds": ctx.slot_data["open_worlds"],
            "slot_door_unlock_requirements": ctx.slot_data["door_unlock_requirements"],
            "slot_boss_1_regional_balloons": ctx.slot_data["boss_1_regional_balloons"],
            "slot_boss_2_regional_balloons": ctx.slot_data["boss_2_regional_balloons"],
            "slot_wizpig_1_amulet_pieces": ctx.slot_data["wizpig_1_amulet_pieces"],
            "slot_wizpig_2_amulet_pieces": ctx.slot_data["wizpig_2_amulet_pieces"],
            "slot_wizpig_2_balloons": ctx.slot_data["wizpig_2_balloons"],
            "slot_skip_trophy_races": ctx.slot_data["skip_trophy_races"]
        })
    ctx.sendSlot = False

    return payload


async def parse_payload(payload: dict, ctx: DiddyKongRacingContext):
    # Refuse to do anything if ROM is detected as changed
    if ctx.auth and payload['playerName'] != ctx.auth:
        logger.warning("ROM change detected. Disconnecting and reconnecting...")
        ctx.finished_game = False
        ctx.location_table = {}
        ctx.auth = payload['playerName']
        await ctx.send_connect()
        return

    if payload["gameComplete"] == "true" and not ctx.finished_game:
        await ctx.send_msgs([{
            "cmd": "StatusUpdate",
            "status": 30
        }])
        ctx.finished_game = True

    # Locations handling
    locations = payload['locations']

    # The Lua JSON library serializes an empty table into a list instead of a dict. Verify types for safety:
    if isinstance(locations, list):
        locations = {}

    if "DEMO" not in locations and ctx.sync_ready:
        if ctx.location_table != locations:
            updated_locations = []
            for item_group, dkr_location_table in locations.items():
                if len(dkr_location_table) == 0:
                    continue

                for locationId, value in dkr_location_table.items():
                    if value and locationId not in ctx.location_table:
                        updated_locations.append(int(locationId))
            if len(updated_locations) > 0:
                await ctx.send_msgs([{
                    "cmd": "LocationChecks",
                    "locations": updated_locations
                }])
            ctx.location_table = locations

    # Send Async Data.
    if "sync_ready" in payload:
        if payload["sync_ready"] == "true":
            ctx.sync_ready = True
        else:
            ctx.sync_ready = False


async def n64_sync_task(ctx: DiddyKongRacingContext):
    logger.info("Starting n64 connector. Use /n64 for status information.")
    while not ctx.exit_event.is_set():
        error_status = None
        if ctx.n64_streams:
            (reader, writer) = ctx.n64_streams
            if ctx.sendSlot:
                msg = get_slot_payload(ctx).encode()
            else:
                msg = get_payload(ctx).encode()
            writer.write(msg)
            writer.write(b'\n')

            try:
                await wait_for(writer.drain(), timeout=1.5)
                try:
                    data = await wait_for(reader.readline(), timeout=10)
                    data_decoded = loads(data.decode())
                    get_slot_data = data_decoded.get('getSlot', 0)
                    if get_slot_data:
                        ctx.sendSlot = True
                    else:
                        if ctx.game is not None and 'locations' in data_decoded:
                            # Not just a keep alive ping, parse
                            async_start(parse_payload(data_decoded, ctx))

                        if not ctx.auth:
                            ctx.auth = data_decoded['playerName']
                            if ctx.awaiting_rom:
                                await ctx.server_auth(False)
                except TimeoutError:
                    logger.debug("Read Timed Out, Reconnecting")
                    error_status = CONNECTION_TIMING_OUT_STATUS
                    writer.close()
                    ctx.n64_streams = None
                except ConnectionResetError:
                    logger.debug("Read failed due to Connection Lost, Reconnecting")
                    error_status = CONNECTION_RESET_STATUS
                    writer.close()
                    ctx.n64_streams = None
                except Exception as e:
                    logger.debug(e)
            except TimeoutError:
                logger.debug("Connection Timed Out, Reconnecting")
                error_status = CONNECTION_TIMING_OUT_STATUS
                writer.close()
                ctx.n64_streams = None
            except ConnectionResetError:
                logger.debug("Connection Lost, Reconnecting")
                error_status = CONNECTION_RESET_STATUS
                writer.close()
                ctx.n64_streams = None

            if ctx.n64_status == CONNECTION_TENTATIVE_STATUS:
                if not error_status:
                    logger.info("Successfully Connected to N64")
                    ctx.n64_status = CONNECTION_CONNECTED_STATUS
                else:
                    ctx.n64_status = f"Was tentatively connected but error occurred: {error_status}"
            elif error_status:
                ctx.n64_status = error_status
                logger.info("Lost connection to N64 and attempting to reconnect. Use /n64 for status updates")
        else:
            try:
                logger.debug("Attempting to connect to N64")
                ctx.n64_streams = await wait_for(open_connection("localhost", 21221), timeout=10)
                ctx.n64_status = CONNECTION_TENTATIVE_STATUS
            except TimeoutError:
                logger.debug("Connection Timed Out, Trying Again")
                ctx.n64_status = CONNECTION_TIMING_OUT_STATUS
                continue
            except ConnectionRefusedError:
                logger.debug("Connection Refused, Trying Again")
                ctx.n64_status = CONNECTION_REFUSED_STATUS
                continue


def main():
    init_logging("Diddy Kong Racing Client")
    parser = get_base_parser()
    args = argv[1:]
    if "Diddy Kong Racing Client" in args:
        args.remove("Diddy Kong Racing Client")
    args = parser.parse_args(args)

    async def _main():
        freeze_support()

        ctx = DiddyKongRacingContext(args.connect, args.password)
        ctx.server_task = create_task(server_loop(ctx), name="Server Loop")

        if gui_enabled:
            ctx.run_gui()
        ctx.run_cli()

        await ctx.exit_event.wait()
        ctx.server_address = None

        await ctx.shutdown()

        if ctx.n64_sync_task:
            await ctx.n64_sync_task

    import colorama

    colorama.init()

    run(_main())
    colorama.deinit()


if __name__ == '__main__':
    main()
