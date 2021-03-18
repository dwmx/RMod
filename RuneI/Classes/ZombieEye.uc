//=============================================================================
// ZombieEye.
//=============================================================================
class ZombieEye extends SarkEye;

function PostBeginPlay()
{
	local actor flame;

	// Right Eye Flame
	flame = Spawn(Class'ZombieEyeFlame', self);
	AttachActorToJoint(flame, JointNamed('R_Eye'));

	// Left Eye Flame
	flame = Spawn(Class'ZombieEyeFlame', self);
	AttachActorToJoint(flame, JointNamed('L_Eye'));
}

defaultproperties
{
     Skeletal=SkelModel'objects.SarkEyeAxe'
}
