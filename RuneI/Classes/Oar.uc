//=============================================================================
// Oar.
//=============================================================================
class Oar expands DecorationRune;


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
     DrawType=DT_SkeletalMesh
     CollisionRadius=46.000000
     CollisionHeight=2.000000
     bCollideActors=True
     bCollideWorld=True
     Skeletal=SkelModel'objects.Oar'
}
