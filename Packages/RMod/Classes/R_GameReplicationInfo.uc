class R_GameReplicationInfo extends RuneGameReplicationInfo;

var R_GameOptions GameOptions;

var int NewRemainingTime;
var int RemainingTimePendingUpdateSwitch;
var int RemainingTimePendingUpdateSwitchLocal;
var Name GameStateName;
var bool bLoadoutsEnabled;

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

defaultproperties
{
    NewRemainingTime=0
    RemainingTimePendingUpdateSwitch=0
    RemainingTimePendingUpdateSwitchLocal=0
}
