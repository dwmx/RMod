//==============================================================================
//  R_GameInfo_TDMRB
//  Round-based version of team death match.
//==============================================================================
class R_GameInfo_TDMRB extends R_GameInfo_TDM;

var float GameStateTimeStampSeconds;
var float GameStateDurationSeconds;

var config float GameStateDurationSeconds_PreGame;
var config float GameStateDurationSeconds_Loadout;
var config float GameStateDurationSeconds_PreRound;
var config float GameStateDurationSeconds_LiveRound;
var config float GameStateDurationSeconds_PostRound;

function SetGameStateTimerSeconds(float NewDurationSeconds)
{
    local R_GameReplicationInfo RGRI;

    GameStateTimeStampSeconds = Level.TimeSeconds;
    GameStateDurationSeconds = NewDurationSeconds;

    RGRI = R_GameReplicationInfo(GameReplicationInfo);
    if(RGRI != None)
    {
        RGRI.UpdateTimeLimit(int(GameStateDurationSeconds));
    }
}

function float GetGameStateTimeRemainingSeconds()
{
    local float TimeDeltaSeconds;
    local float TimeRemainingSeconds;

    TimeDeltaSeconds = Level.TimeSeconds - GameStateTimeStampSeconds;
    TimeRemainingSeconds = GameStateDurationSeconds - TimeDeltaSeconds;
    TimeRemainingSeconds = Max(0.0, TimeRemainingSeconds);

    return TimeRemainingSeconds;
}

function BroadcastOpenLoadoutMenu()
{
    local R_RunePlayer RRP;

    foreach AllActors(Class'RMod.R_RunePlayer', RRP)
    {
        RRP.ClientOpenLoadoutMenu();
    }
}

function BroadcastCloseLoadoutMenu()
{
    local R_RunePlayer RRP;

    foreach AllActors(Class'RMod.R_RunePlayer', RRP)
    {
        RRP.ClientCloseLoadoutMenu();
    }
}

/**
*   State PreGame
*   Warmup game state, gives a buffer to allow players to connect and get ready
*/
auto state PreGame
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        SetGameStateTimerSeconds(GameStateDurationSeconds_PreGame);
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());
    }

    event Tick(float DeltaSeconds)
    {
        if(GetGameStateTimeRemainingSeconds() <= 0.0)
        {
            GotoState('Loadout');
        }
    }
}

/**
*   State Loadout
*   State in which players are allowed to select their loadouts.
*/
state Loadout
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        SetGameStateTimerSeconds(GameStateDurationSeconds_Loadout);
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());
        BroadcastOpenLoadoutMenu();
    }

    event EndState()
    {
        BroadcastCloseLoadoutMenu();
    }

    event Tick(float DeltaSeconds)
    {
        if(GetGameStateTimeRemainingSeconds() <= 0.0)
        {
            GotoState('PreRound');
        }
    }
}

/**
*   State PreRound
*   Next round is about to begin
*/
state PreRound
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        SetGameStateTimerSeconds(GameStateDurationSeconds_PreRound);
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());

        // Reset without stat reset
        ResetLevelSoft();
    }

    event Tick(float DeltaSeconds)
    {
        if(GetGameStateTimeRemainingSeconds() <= 0.0)
        {
            GotoState('LiveRound');
        }
    }
}

/**
*   State LiveRound
*   Round is in progress
*/
state LiveRound
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        SetGameStateTimerSeconds(GameStateDurationSeconds_LiveRound);
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());
    }

    event Tick(float DeltaSeconds)
    {
        if(GetGameStateTimeRemainingSeconds() <= 0.0)
        {
            GotoState('PostRound');
        }
    }

    /**
    *   CheckAllowRestart (override)
    *   Disallow players from restarting while the round is live
    */
    function bool CheckAllowRestart(PlayerPawn P)
    {
        return false;
    }
}

/**
*   State PostRound
*   Round just finished
*/
state PostRound
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        SetGameStateTimerSeconds(GameStateDurationSeconds_PostRound);
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());
    }

    event Tick(float DeltaSeconds)
    {
        if(GetGameStateTimeRemainingSeconds() <= 0.0)
        {
            GotoState('Loadout');
        }
    }
}

defaultproperties
{
    GameStateDurationSeconds_PreGame=15.0
    GameStateDurationSeconds_Loadout=10.0
    GameStateDurationSeconds_PreRound=5.0
    GameStateDurationSeconds_LiveRound=30.0
    GameStateDurationSeconds_PostRound=5.0
}