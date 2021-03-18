//=============================================================================
// Crucifix2.
//=============================================================================
class Crucifix2 expands DecorationRune;


function EMatterType MatterForJoint(int joint)
{
	return MATTER_STONE;
}

defaultproperties
{
     DrawType=DT_SkeletalMesh
     LODCurve=LOD_CURVE_ULTRA_CONSERVATIVE
     CollisionRadius=45.000000
     CollisionHeight=71.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     Skeletal=SkelModel'objects.Crucifix2'
}
