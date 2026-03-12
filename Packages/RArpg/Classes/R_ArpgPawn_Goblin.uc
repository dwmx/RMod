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

function PlayMoving(optional float Tween)
{
	switch(GetMovementDirection())
	{
	case MOVEDIR_FORWARD:	LoopPawnAnim('walkB', true, true, 1.0, 0.1);	break;
	default:				LoopPawnAnim('idleA', true, true, 1.0, 0.1);	break;
	}
}

defaultproperties
{
	Skeletal=SkelModel'creatures.Goblin'
	CollisionRadius=16.000000
    CollisionHeight=32.000000
	GroundSpeed=60.0
	Mass=50.000000
    Buoyancy=35.000000
}