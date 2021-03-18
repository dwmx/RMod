//=============================================================================
// BoneBridgeSmall.
//=============================================================================
class BoneBridgeSmall extends DecorationRune;


simulated event GetSpringJointParms(int joint, out float DampFactor, out float SpringConstant, out vector SpringThreshold)
{
	DampFactor = 2;
	SpringConstant = 50;
	SpringThreshold = vect(15,15,100);
}

function AddVelocity(vector NewVelocity)
{	// Momentum has come in from another actor
}

simulated function FindAdjacents(int joint, out int prev, out int next)
{
	switch(joint)
	{
		case 4:		prev = 0;	next = 5;	break;
		case 5:		prev = 4;	next = 2;	break;
		case 2:		prev = 5;	next = 9;	break;
		case 9:		prev = 2;	next = 10;	break;
		case 10:	prev = 9;	next = 8;	break;
		case 8:		prev = 10;	next = 7;	break;
		case 7:		prev = 8;	next = 13;	break;
		case 13:	prev = 7;	next = 15;	break;
		case 15:	prev = 13;	next = 12;	break;
		case 12:	prev = 15;	next = 14;	break;
		case 14:	prev = 12;	next = 18;	break;
		case 18:	prev = 14;	next = 0;	break;
	}
}


simulated function JointTouchedBy(actor Other, int joint)
{
	local vector vel;

	vel = Other.Velocity;
	if (VSize2D(vel) > 0 && vel.Z==0)
		vel.Z = -5;
	vel.X *= 0.05;
	vel.Y *= 0.05;
	vel.Z *= 0.5;

	PropogateJointForce(joint, vel);
}

simulated function PropogateJointForce(int joint, vector vel)
{
	local vector v;
	local int prev, next, dummy;
	local rotator torque;

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
     Skeletal=SkelModel'objects.footbridge'
}
