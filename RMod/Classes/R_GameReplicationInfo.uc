class R_GameReplicationInfo extends RuneGameReplicationInfo;

var bool bRemainingTimePendingUpdate;
var bool bRemainingTimePendingUpdateToggle;
var int NewRemainingTime;

replication
{
	reliable if(Role == ROLE_Authority)
		bRemainingTimePendingUpdate,
		NewRemainingTime;
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
