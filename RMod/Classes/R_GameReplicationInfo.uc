class R_GameReplicationInfo extends RuneGameReplicationInfo;

const UtilitiesLibrary = Class'RMod.R_AUtilities';

var R_GameOptions GameOptions;

var int NewRemainingTime;
var int RemainingTimePendingUpdateSwitch;
var int RemainingTimePendingUpdateSwitchLocal;
var Name GameStateName;
var bool bLoadoutsEnabled;

// GameMode-specific camera class to use when players enter spectator state
// If this is None, then R_RunePlayer will use their default configured class
// If this is set, then this will override whatever R_RunePlayer has set
var Class<R_ACamera> SpectatorCameraClass;

replication
{
    reliable if(Role == ROLE_Authority)
        GameOptions,
        NewRemainingTime,
        RemainingTimePendingUpdateSwitch,
        GameStateName,
        bLoadoutsEnabled;
}

event BeginPlay()
{
    if(SpectatorCameraClass != None)
    {
        UtilitiesLibrary.Static.RModLog("GRI" @ Class @ "is overriding SpectatorCameraClass with" @ SpectatorCameraClass);
    }
    
    RemainingTimePendingUpdateSwitch = 0;
    RemainingTimePendingUpdateSwitchLocal = RemainingTimePendingUpdateSwitch;
}

function UpdateTimeLimit(int NewTimeLimit)
{
    NewRemainingTime = NewTimeLimit;
    ++RemainingTimePendingUpdateSwitch;
}

simulated event Tick(float DeltaSeconds)
{
    if(RemainingTimePendingUpdateSwitchLocal != RemainingTimePendingUpdateSwitch)
    {
        RemainingTimePendingUpdateSwitchLocal = RemainingTimePendingUpdateSwitch;
        RemainingTime = NewRemainingTime;
    }
}

/**
*	CheckShouldPlayerRespawn
*	This is called client-side from R_RunePlayers to check whether or not they should treat some
*	player input (i.e. Fire) as a respawn request, or something else (i.e. Cycle spectator view target)
*
*	This is NOT a required part of the player respawn chain of command, it's only an optional step
*	that allows R_RunePlayer to redirect input elsewhere
*	Actual allow/deny respawn logic still occurs independently on the server
*
*	This is here rather than in R_RunePlayer to avoid subclassing R_RunePlayer for specific game modes
*	GRI is a reliable place to perform checks on client-side information specific to the current game mode
*/
simulated function bool CheckShouldPlayerRespawn(R_RunePlayer RP, Name RelevantState)
{
    // Override in specific game mode GRI class to implement client-side logic
    return true;
}

defaultproperties
{
    NewRemainingTime=0
    RemainingTimePendingUpdateSwitch=0
    RemainingTimePendingUpdateSwitchLocal=0
}
