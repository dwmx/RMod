//=============================================================================
// TarpFrame.
//=============================================================================
class TarpFrame expands DecorationRune;

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
     bStatic=False
     DrawType=DT_SkeletalMesh
     CollisionRadius=17.000000
     CollisionHeight=15.000000
     Skeletal=SkelModel'objects.TarpFrame'
}
