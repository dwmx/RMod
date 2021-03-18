//=============================================================================
// Tree1.
//=============================================================================
class Tree1 expands Plants;


simulated event GetAccelJointParms(int joint, out float DampFactor, out float RotThreshold)
{
	DampFactor = 0.025;
	RotThreshold = 8000;
}

simulated event float GetAccelJointMagnitude(int joint)
{
	return 10000;
}

function bool JointDamaged(int Damage, Pawn Instigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	ApplyJointForce(joint, Momentum);
	return true;
}

simulated function JointTouchedBy(actor Other, int joint)
{
	local vector vel;
//local rotator r;
	local int j;

/*
	// This to test grav points
	for (j=0; j<NumJoints(); j++)
	{
		if ((JointFlags[j] & JOINT_FLAG_ACCELERATIVE)!=0)
		{
			JointFlags[j] = JointFlags[j] & ~JOINT_FLAG_ACCELERATIVE;
			JointFlags[j] = JointFlags[j] | JOINT_FLAG_GRAVJOINT;
		}
	}
*/

	vel = Other.Velocity;
	ApplyJointForce(joint, vel);
//	r.Pitch = 0;
//	r.Yaw = 5000;
//	r.Roll = 0;
//	ApplyJointTorque(joint, r);
//	slog(Other.Name$" touched my "$GetJointName(joint)$" :"$r);
}

defaultproperties
{
     bStasis=False
     CollisionRadius=5.000000
     CollisionHeight=48.000000
     Skeletal=SkelModel'plants.Tree'
}
