//=============================================================================
// EmptyTubestriker.
//=============================================================================
class EmptyTubestriker expands DecorationRune;


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


function PostBeginPlay()
{
	Super.PostBeginPlay();
	JointFlags[5] = 0;
	JointFlags[6] = 0;
	JointFlags[9] = 0;
	JointFlags[10] = 0;
	JointFlags[11] = 0;
}

defaultproperties
{
     AnimSequence=idleA
     DrawType=DT_SkeletalMesh
     CollisionRadius=23.000000
     CollisionHeight=47.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     Skeletal=SkelModel'creatures.Striker'
     SkelGroupFlags(2)=1
     SkelGroupFlags(3)=1
}
