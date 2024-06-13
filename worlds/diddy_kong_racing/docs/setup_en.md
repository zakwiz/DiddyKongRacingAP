# SETUP GUIDE FOR DIDDY KONG RACING ARCHIPELAGO

## Important

As we are using BizHawk, this guide is only applicable to Windows and Linux systems.

## Required Software/Files

-   BizHawk:  [BizHawk Releases from TASVideos](https://tasvideos.org/BizHawk/ReleaseHistory)
    -   Version 2.9.1 and later are supported.
    -   Detailed installation instructions for BizHawk can be found at the above link.
    -   Windows users must run the prereq installer first, which can also be found at the above link.
-   Grab the latest release from https://github.com/zakwiz/DiddyKongRacingAP
-   A Diddy Kong Racing v1.0 ROM (USA ONLY).

## Configuring BizHawk

Once BizHawk has been installed, open EmuHawk and change the following settings:

-   Under Config > Customize, check the "Run in background" and "Accept background input" boxes. This will allow you to continue playing in the background, even if another window is selected.
-   Under Config > Hotkeys, many hotkeys are listed, with many bound to common keys on the keyboard. You will likely want to disable most of these, which you can do quickly using  `Esc`.
-   If playing with a controller, when you bind controls, disable "P1 A Up", "P1 A Down", "P1 A Left", and "P1 A Right" as these interfere with aiming if bound. Set directional input using the Analog tab instead.
-   Under N64 enable "Use Expansion Slot". (The N64 menu only appears after loading a ROM.)

It is strongly recommended to associate N64 rom extensions (*.n64, *.z64) to the EmuHawk we've just installed. To do so, we simply have to search any N64 rom we happened to own, right click and select "Open with…", unfold the list that appears and select the bottom option "Look for another application", then browse to the BizHawk folder and select EmuHawk.exe.

## Prerequisites

## How to Install - Server Side
- Copy diddy_kong_racing.apworld into the worlds folder in your existing Archipelago folder (libs/worlds)

## How to install - Client Side

- Copy data/lua/connector_diddy_kong_racing.lua into data/lua in your existing Archipelago
- Copy diddy_kong_racing.apworld into the worlds folder in your existing Archipelago folder (libs/worlds)
- Run the Archipelago launcher and select Diddy Kong Racing Client
- Connect the Archipelago Client with the server.
- Open Bizhawk (2.9.1+) and open your Diddy Kong Racing ROM.
- Once you have entered a save file, run the diddy_kong_racing.apworld script (drag and drop it into Bizhawk)

## Generate your world
- Familiarize yourself on how Archipelago works. Here is a guide to learn how to generate your world: https://archipelago.gg/tutorial/Archipelago/setup/en#on-your-local-installation

## Connect to the Multiserver

To connect the client to the multiserver, simply put `<address>:<port>` in the textfield on top and press `connect` (if the server uses password, then it will prompt after connection).