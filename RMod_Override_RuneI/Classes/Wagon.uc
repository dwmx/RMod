//=============================================================================
// Wagon.
//=============================================================================
class Wagon expands DecorationRune;

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
     LODCurve=LOD_CURVE_ULTRA_CONSERVATIVE
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     Skeletal=SkelModel'objects.Wagon'
}
