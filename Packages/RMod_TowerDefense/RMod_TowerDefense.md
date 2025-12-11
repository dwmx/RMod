# RMod Tower Defense

Special thanks to everyone who helped with the development of Tower Defense
- Contributors:
    - Xyster
    - Lanza
    - emmix

## How to Install
Tower Defense is a sub-package of RMod and RUI, and requires those packages
- Place RMod.u, RUI.u, and RMod_TowerDefense.u in your Rune/System directory
- Place RMod_TowerDefense.int in your Rune/System directory
- Add the following lines to your Rune.ini configuration file:
```
ServerPackages=RMod
ServerPackages=RUI
ServerPackages=RMod_TowerDefense
```

## How to Play
Once installed, you can start a game in the following ways:
- Launch a dedicated server from command line
    -  `UCC.exe server TD-MazeMap.run?game=RMod_TowerDefense.R_GameInfo_TD`
- Start a listen server from the in-game Game creation menu, or with the following in-game console command
    - `open TD-MazeMap.run?listen?game=RMod_TowerDefense.R_GameInfo_TD`
- Start a standalone game
    - `open TD-MazeMap.run?game=RMod_TowerDefense.R_GameInfo_TD`

## Multiplayer
Yes this mod is designed to work in multiplayer networked games and in all netmodes (standalone, dedicated and listen server)

## How to make your own maps
You are welcome and encouraged to make your own maps!
There are several important notes to keep in mind however:

- Buildings are locked to a grid of 16 units in size
- You can design your map any way you would like to, but keep in mind that buildings can only be placed on unit multiples of 16
- Mobs are NOT smart enough to path around obstacles, it is expected that the path will remain obstruction free at all times

You will need to make use of the following actors:

- `R_LevelDescription_TD` (extends Info)
    - Every map MUST contain one and only one of these Actors
    - This actor describes all of the critically important information about your level that the game mode needs to function

- `R_MobPathNode` (extends NavigationPoint)
    - This actor acts as a single node in the path that your mobs will follow
    - Path nodes must be linked together via their Name properties

- `R_BuildZone` (extends ZoneInfo)
    - Place this actor in your zones to add build related information to that zone
    - This allows you to control which zones can and cannot be built in
    - By default every zone can be built in

## Extending the mod
You are welcome to extend the mod if you would like to!

Tower and Mob actors are almost entirely modular

### Mobs
- You should not need to extend the `R_Mob` class unless you are planning to modify their behavior
- `R_AMobAppearance` is the primary class to look into for adapting new mobs

### Towers
- You likely will want to subclass `R_Tower`, as you will need to create its components