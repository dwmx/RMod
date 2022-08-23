//=============================================================================
// Raft.
//=============================================================================
class Raft expands Floater;


//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_WOOD;
}

defaultproperties
{
     CollisionRadius=100.000000
     CollisionHeight=10.000000
     Skeletal=SkelModel'objects.Raft'
}
