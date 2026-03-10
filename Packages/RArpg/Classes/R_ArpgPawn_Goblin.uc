//==============================================================================
//	R_ArpgPawn_Goblin
//==============================================================================
class R_ArpgPawn_Goblin extends R_ArpgPawn;

function PlayMoving(optional float Tween)
{
	LoopPawnAnim('idleA', true, true, 1.0, 0.1);
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