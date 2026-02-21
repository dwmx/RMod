//==============================================================================
//	R_ArpgTraceProxy
//	Actor which acts as a hit-detection proxy for another Actor
//	Used for In-World UI interactions
//==============================================================================
class R_ArpgTraceProxy extends Actor;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if(Owner == None)
	{
		Destroy();
		return;
	}
}

event Tick(float DeltaSeconds)
{
	if(Owner == None)
	{
		Destroy();
		return;
	}

	SetCollisionSize(Owner.CollisionRadius, Owner.CollisionHeight);
	SetLocation(Owner.Location);
}

function Actor GetProxyOwner()
{
	return Owner;
}

defaultproperties
{
	RemoteRole=ROLE_None
	DrawType=DT_None
	bCollideActors=true
	bBlockActors=false
	bBlockPlayers=false
}