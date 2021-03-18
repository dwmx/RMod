//=============================================================================
// Plate.
//=============================================================================
class Plate expands DecorationRune;

function EMatterType MatterForJoint(int joint)
{
	return MATTER_ICE;
}

defaultproperties
{
     bDestroyable=True
     bStatic=False
     DrawType=DT_SkeletalMesh
     CollisionRadius=15.000000
     CollisionHeight=1.500000
     bCollideActors=True
     bCollideWorld=True
     Skeletal=SkelModel'objects.Plate'
}
