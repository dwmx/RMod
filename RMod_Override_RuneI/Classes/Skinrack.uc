//=============================================================================
// SkinRack.
//=============================================================================
class SkinRack expands DecorationRune;


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
     DrawScale=2.000000
     CollisionRadius=107.000000
     CollisionHeight=75.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     Skeletal=SkelModel'objects.Skinrack'
}
