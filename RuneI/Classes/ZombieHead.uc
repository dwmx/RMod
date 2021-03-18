//=============================================================================
// ZombieHead.
//=============================================================================
class ZombieHead expands Head;

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_EARTH;
}

defaultproperties
{
     bBloodyHead=False
     DrawScale=1.250000
     SkelMesh=25
     SkelGroupSkins(1)=Texture'RuneFX.gore_bone'
     SkelGroupSkins(2)=Texture'Players.Ragnarz_head'
}
