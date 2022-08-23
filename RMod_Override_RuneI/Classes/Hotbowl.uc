//=============================================================================
// Hotbowl.
//=============================================================================
class Hotbowl expands FireObject;


//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_STONE;
}

defaultproperties
{
     FireClass=Class'RuneI.Fire'
     bStatic=False
     CollisionRadius=48.000000
     CollisionHeight=18.000000
     bBlockActors=True
     bBlockPlayers=True
     Skeletal=SkelModel'objects.Hotbowl'
}
