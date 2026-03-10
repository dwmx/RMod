//==============================================================================
//	R_ArpgPawn_Goblin
//==============================================================================
class R_ArpgPawn_Goblin extends R_ArpgPawn;

function PlayMoving(optional float Tween)
{
	LoopPawnAnim('idleA', true, true, 1.0, 0.1);
}

function Actor FindTarget()
{
	local Pawn P;
	
	for(P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if(R_ArpgPawn_Hero(P) != None)
		{
			return P;
		}
	}
	return None;
}

event Tick(float DeltaSeconds)
{
	local Actor TargetActor;

	Target = FindTarget();
	if(Target != None)
	{
		AddMovementInput(Normal(Vect(1,1,0) * Target.Location - Self.Location));
	}

	Super.Tick(DeltaSeconds);
}

defaultproperties
{
	Skeletal=SkelModel'creatures.Goblin'
	CollisionRadius=16.000000
    CollisionHeight=32.000000
	Mass=50.000000
    Buoyancy=35.000000
}