//=============================================================================
// Statue.
//=============================================================================
class Statue extends DecorationRune
	abstract;

#exec OBJ LOAD FILE=..\Textures\Statues.utx PACKAGE=Statues

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
     bDestroyable=True
     bStatic=False
     DrawType=DT_SkeletalMesh
     LODPercentMax=0.400000
     LODCurve=LOD_CURVE_ULTRA_AGGRESSIVE
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
