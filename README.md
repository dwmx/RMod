# RMod
## RMod for Rune: Halls of Valhalla

RMod is a quality-of-life mod for Rune: Halls of Valhalla, aiming to improve the modern player experience through bug fixes, multiplayer optimizations, game balances and new game features.

## Major Gameplay Updates
- Adopted player movement from UT community patch 469b for greatly improved client-side movement prediction
- Extended Rune's in-game command interface for improved server administration and client-side configuration
- Greatly improved spectator functionality
- Implemented features which the game originally had assets for, but no functionality for:
    - Shield bash
- Fixed multiplayer compatibility for features which originally only worked in single player, standalone games:
    - Rope climbing
    - Weapon swipe particle systems
- Added new game options specified on a per-game type basis:
    - Shield hit stun
    - Manually activated bloodlust

## Client Command Interface Extension
The following exec functions added to R_RunePlayer allow additional client-side and admin-authorized server functionality. The following commands are listed with their unrealscript declaration, along with an example of how they may be called using the in-game console.

#### ResetLevel (Administrator Only)
Performs a soft level reset. Resets the map state without reloading the map.
Useful for restarting maps only after all players have loaded in.

```
exec function ResetLevel(optional int DurationSeconds)
> ResetLevel 5
```

#### TimeLimit (Administrator Only)
Update the game's time limit on the fly.

```
exec function TimeLimit(int DurationMinutes)
> TimeLimit 20
```

#### Loadout
Opens the loadout menu when the game mode allows for it. `R_GameInfo.bLoadoutsEnabled` must be true

```
exec function Loadout()
> Loadout
```

#### Spectate
Allows clients to switch to spectator mode while in-game, unless denied by the current game mode.

```
exec function Spectate()
> Spectate
```

#### ToggleRModDebug
Enables client-side debug visualization in RMod game modes.
- Displays visual markers when client receives authoritative corrections via `ClientAdjustPosition`

```
exec function ToggleRmodDebug()
> ToggleRmodDebug
```

## Spectator Mode
All spectator functionality has been moved off of `SpectatorPawn` and into `R_RunePlayer` via the `PlayerSpectating` state.

### View Modes
While in spectator mode, players can adjust the spectator state in the following way:
- `Fire` input cycles through player view targets when relevant to the current view mode
- `Use` input cycles through camera view modes

The following view modes are available to spectators and may be cycled through via the `Use` input.

#### Free
Free roam spectator camera mode. Allows player to move freely with no view target.

#### FollowTarget
Camera locks onto a view target and follows them, allowing the spectator to freely rotate camera.

#### FollowTargetPov
Camera locks onto a view target and displays the game through their point of view. Moving the mouse will still allow the player to freely rotate camera, but will snap back to view target POV when idle.