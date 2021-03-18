//=============================================================================
// LavaChunk.
//=============================================================================
class LavaChunk expands Floater;


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
     CollisionRadius=64.000000
     CollisionHeight=16.000000
     Skeletal=SkelModel'objects.LavaChunk'
}
