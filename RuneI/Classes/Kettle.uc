//=============================================================================
// Kettle.
//=============================================================================
class Kettle expands DecorationRune;

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
     CollisionRadius=27.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     Skeletal=SkelModel'objects.Kettle'
}
