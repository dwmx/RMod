class R_Ball extends Head;

var R_BallState BallState;
var R_BallEffects BallEffects;

replication
{
	reliable if(Role == ROLE_Authority)
		BallState;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Ball state child actor
	if(Role == ROLE_Authority)
	{
		BallState = Spawn(Class'RMod_Valball.R_BallState', self);
	}

	// Client-side ball effects actor
	if(Role < ROLE_Authority || Level.NetMode == NM_StandAlone)
	{
		BallEffects = Spawn(Class'RMod_Valball.R_BallEffects', Self);
	}
}

event Destroyed()
{
	if(BallState != None)
	{
		BallState.Destroy();
	}

	if(BallEffects != None)
	{
		BallEffects.Destroy();
	}
}

simulated function Name GetCurrentBallStateName()
{
	if(BallState == None)
	{
		return GetStateName();
	}

	return BallState.CurrentBallState;
}

simulated function float GetBallPreSpawnTimeRemainingSeconds()
{
	return 2.0;
}

auto state Pickup
{
	function bool CanBeUsed(Actor Other)
	{
		if(BallState.CurrentBallState != 'Active')
		{
			return false;
		}
		return Super.CanBeUsed(Other);
	}
}

state Active
{
	event BeginState()
	{
		Super.BeginState();

		if(Pawn(Owner) != None)
		{
			BroadcastMessage(Pawn(Owner).PlayerReplicationInfo.PlayerName @ "has the ball");
		}
	}
}

defaultproperties
{
	bAlwaysRelevant=True
	bExpireWhenTossed=False
	bNeverExpire=True
	LifeSpan=0
	Damage=1000
	DrawScale=3.0
	CollisionHeight=32.0
	CollisionRadius=32.0
}