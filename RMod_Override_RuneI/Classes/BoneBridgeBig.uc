//=============================================================================
// BoneBridgeBig.
//=============================================================================
class BoneBridgeBig extends DecorationRune;


simulated event GetSpringJointParms(int joint, out float DampFactor, out float SpringConstant, out vector SpringThreshold)
{
	DampFactor = 3;
	SpringConstant = 50;
	SpringThreshold = vect(5,5,50);
}


simulated function FindAdjacents(int joint, out int prev, out int next)
{
	switch(joint)
	{
		case 3:		prev = 0;	next = 6;	break;
		case 6:		prev = 3;	next = 9;	break;
		case 9:		prev = 6;	next = 12;	break;
		case 12:	prev = 9;	next = 16;	break;
		case 16:	prev = 12;	next = 19;	break;
		case 19:	prev = 16;	next = 25;	break;
		case 25:	prev = 19;	next = 22;	break;
		case 22:	prev = 25;	next = 0;	break;
	}
}

function AddVelocity(vector NewVelocity)
{	// Momentum has come in from another actor
}

simulated function JointTouchedBy(actor Other, int joint)
{
	local vector vel,v;
	local int prev, next, dummy;
	local rotator torque;

	if ((JointFlags[joint] & JOINT_FLAG_SPRINGPOINT)==0)
		return;

	vel = Other.Velocity;
	if (VSize2D(vel) > 0 && vel.Z==0)
		vel.Z = -5;
	vel.X *= 0.05;
	vel.Y *= 0.05;
	vel.Z *= 0.5;

	ApplyJointForce(joint, vel);

	FindAdjacents(joint, prev, next);

	v = vel;
	while (prev != 0)
	{
		v *= 0.5;
		if (VSize(v) < 1)
			break;

		ApplyJointForce(prev, v);
		FindAdjacents(prev, prev, dummy);
	}
	until (prev == 0);

	v = vel;
	while (next != 0)
	{
		v *= 0.5;
		if (VSize(v) < 1)
			break;

		ApplyJointForce(next, v);
		FindAdjacents(next, dummy, next);
	}
}

defaultproperties
{
     bStatic=False
     DrawType=DT_SkeletalMesh
     bComplexOcclusion=True
     CollisionRadius=220.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     bJointsTouch=True
     Mass=50.000000
     Skeletal=SkelModel'objects.BoneBridge'
}
