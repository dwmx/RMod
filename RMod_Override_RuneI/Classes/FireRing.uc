//=============================================================================
// FireRing.
//=============================================================================
class FireRing expands DecorationRune;

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
     DrawType=DT_SkeletalMesh
     DrawScale=1.500000
     CollisionRadius=24.000000
     CollisionHeight=5.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     Skeletal=SkelModel'objects.FireRing'
}
