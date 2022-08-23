//=============================================================================
// SarkEye.
//=============================================================================
class SarkEye extends Effects
	abstract;

var class<Actor> EyeFlame;

function PostBeginPlay()
{
	local actor flame;

	// Right Eye Flame
	flame = Spawn(EyeFlame, self);
	AttachActorToJoint(flame, JointNamed('R_Eye'));

	// Left Eye Flame
	flame = Spawn(EyeFlame, self);
	AttachActorToJoint(flame, JointNamed('L_Eye'));

	Super.PostBeginPlay();
}

defaultproperties
{
     EyeFlame=Class'RuneI.SarkEyeFlame'
     bNetTemporary=False
     DrawType=DT_SkeletalMesh
}
