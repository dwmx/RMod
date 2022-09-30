class R_GameReplicationInfo extends RuneGameReplicationInfo;

var R_GameOptions GameOptions;

var bool bRemainingTimePendingUpdate;
var bool bRemainingTimePendingUpdateToggle;
var int NewRemainingTime;
var Name GameStateName;

replication
{
	reliable if(Role == ROLE_Authority)
        GameOptions,
		bRemainingTimePendingUpdate,
		NewRemainingTime,
        GameStateName;
}

simulated event Tick(float DeltaSeconds)
{
	if(bRemainingTimePendingUpdateToggle == !bRemainingTimePendingUpdate)
	{
		RemainingTime = NewRemainingTime;
		bRemainingTimePendingUpdateToggle = bRemainingTimePendingUpdate;
	}
}

function UpdateTimeLimit(int NewTimeLimit)
{
	NewRemainingTime = NewTimeLimit;
	bRemainingTimePendingUpdate = !bRemainingTimePendingUpdateToggle;
}

defaultproperties
{
}
