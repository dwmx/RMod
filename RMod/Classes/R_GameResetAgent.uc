////////////////////////////////////////////////////////////////////////////////
//	R_GameResetAgent
//	Spawned by R_GameInfo. Counts down and then resets the game.
class R_GameResetAgent extends Actor;

var int DurationSeconds;
var int ElapsedSeconds;

event PostBeginPlay()
{
	if(R_GameInfo(Level.Game) == None)
	{
		Destroy();
	}
	
	SetTimer(1, true);
}

event Timer()
{
	local int RemainingSeconds;
	
	ElapsedSeconds++;
	
	RemainingSeconds = DurationSeconds - ElapsedSeconds;
	if(RemainingSeconds <= 0)
	{
		R_GameInfo(Level.Game).ResetLevel();
		Destroy();
	}
	else
	{
		BroadcastMessage("Reset in " $ DurationSeconds - ElapsedSeconds);
	}
}

defaultproperties
{
     DurationSeconds=5
     RemoteRole=ROLE_None
}
