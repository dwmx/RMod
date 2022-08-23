//=============================================================================
// SeaWeed.
//=============================================================================
class SeaWeed expands WaterPlants;



simulated event GetAccelJointParms(int joint, out float DampFactor, out float RotThreshold)
{
	DampFactor = 0.25;
	RotThreshold = 8000;
}

simulated event float GetAccelJointMagnitude(int joint)
{
	return 100;
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local vector vel;

	vel = Momentum * 0.05;
	if (joint!=0)
		ApplyJointForce(joint, vel);
	return true;
}

simulated function JointTouchedBy(actor Other, int joint)
{
	local vector vel;

	vel = Other.Velocity * 0.05;
	ApplyJointForce(joint, vel);
}

function AddVelocity(vector NewVelocity)
{
	ApplyJointForce(3, NewVelocity);
}


auto State idle
{
Begin:
	LoopAnim('seaweed', 1.0, 0.1);
}

defaultproperties
{
     bStatic=False
     Style=STY_Masked
     DrawScale=2.000000
     CollisionRadius=15.000000
     CollisionHeight=100.000000
     bCollideActors=True
     bCollideWorld=True
     bJointsTouch=True
     Skeletal=SkelModel'plants.SeaWeed'
}
