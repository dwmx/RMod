//=============================================================================
// LionHead.
//=============================================================================
class LionHead expands FireObject;

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_METAL;
}

defaultproperties
{
     CollisionRadius=8.600000
     CollisionHeight=47.000000
     bBlockActors=True
     bBlockPlayers=True
     Skeletal=SkelModel'objects.LionHead'
}
