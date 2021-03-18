//=============================================================================
// GrainSack.
//=============================================================================
class GrainSack expands DecorationRune
	abstract;

function EMatterType MatterForJoint(int joint)
{
	return MATTER_EARTH;
}

defaultproperties
{
     bDestroyable=True
     DestroyedSound=Sound'WeaponsSnd.ImpCrashes.crashxgrain01'
     bBurnable=True
     bStatic=False
     DrawType=DT_SkeletalMesh
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     Skeletal=SkelModel'objects.GrainSack'
}
