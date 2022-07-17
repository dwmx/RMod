class R_Ball extends Head;

var R_BallState BallState;

replication
{
	reliable if(Role == ROLE_Authority)
		BallState;
}

event PostBeginPlay()
{
	Super.PostBeginPlay();

	BallState = Spawn(Class'RMod_Valball.R_BallState', self);
}

event Destroyed()
{
	if(BallState != None)
	{
		BallState.Destroy();
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

defaultproperties
{
	bAlwaysRelevant=True
	bExpireWhenTossed=False
	bNeverExpire=True
	LifeSpan=0
}