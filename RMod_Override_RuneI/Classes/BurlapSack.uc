//=============================================================================
// BurlapSack.
//=============================================================================
class BurlapSack expands DecorationRune
	abstract;

function EMatterType MatterForJoint(int joint)
{
	return MATTER_EARTH;
}

defaultproperties
{
     bDestroyable=True
     DestroyedSound=Sound'WeaponsSnd.ImpCrashes.crashxburlap01'
     bBurnable=True
     bStatic=False
     DrawType=DT_SkeletalMesh
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     Skeletal=SkelModel'objects.BurlapSack'
}
