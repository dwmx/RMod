//==============================================================================
//	R_ArpgPawn_Goblin
//==============================================================================
class R_ArpgPawn_Goblin extends R_ArpgPawn;

event Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);

	SetRotation(Rotator(Velocity * Vect(1,1,0)));
}

function int GetMovementDirection()
{
	if(VSize(Velocity * Vect(1,1,0)) <= 8.0)
	{
		return MOVEDIR_NEUTRAL;
	}

	return MOVEDIR_FORWARD;
}

defaultproperties
{
	Skeletal=SkelModel'creatures.Goblin'
	CollisionRadius=16.000000
    CollisionHeight=32.000000
	GroundSpeed=60.0
	Mass=50.000000
    Buoyancy=35.000000
	AnimationSetDefaultClass=Class'RArpg.R_ArpgAnimationSet_Goblin'
}