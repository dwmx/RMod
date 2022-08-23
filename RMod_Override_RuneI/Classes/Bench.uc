//=============================================================================
// Bench.
//=============================================================================
class Bench expands DecorationRune;


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
     bDestroyable=True
     DestroyedSound=Sound'WeaponsSnd.ImpCrashes.crashxbench01'
     bBurnable=True
     bStatic=False
     DrawType=DT_SkeletalMesh
     LODCurve=LOD_CURVE_CONSERVATIVE
     CollisionRadius=84.000000
     CollisionHeight=15.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     Skeletal=SkelModel'objects.Bench'
}
