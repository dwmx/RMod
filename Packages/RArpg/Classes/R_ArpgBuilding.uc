//==============================================================================
//	R_ArpgBuilding
//	Base class for all building Actors
//==============================================================================
class R_ArpgBuilding extends R_ArpgPawn;

state PlayerWalking
{
	function PlayerMove( float DeltaTime )
	{
		ConsumeMovementInput();
	}
}

defaultproperties
{
	Skeletal=SkelModel'plants.Tree'
	AnimationControllerClass=None
	DisplayNameString="Building"
}