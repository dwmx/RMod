//=============================================================================
// Crusifix.
//=============================================================================
class Crusifix expands DecorationRune;


function EMatterType MatterForJoint(int joint)
{
	return MATTER_STONE;
}

defaultproperties
{
     DrawType=DT_SkeletalMesh
     CollisionRadius=45.000000
     CollisionHeight=77.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     Skeletal=SkelModel'objects.Crucifix'
}
