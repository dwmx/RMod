//=============================================================================
// Floater.
//=============================================================================
class Floater expands DecorationRune
	abstract;


var vector ApplyVelocity;	// Used to re-apply velocity (hack)


simulated event GetSpringJointParms(int joint, out float DampFactor, out float SpringConstant, out vector SpringThreshold)
{
	DampFactor = 2;
	SpringConstant = 50;
	SpringThreshold = vect(15,15,100);
}

function Bump(actor Other)
{
	local vector vel2D;
	vel2D = Other.Velocity;
	vel2D.Z = 0;
	SetPhysics(PHYS_Falling);
	Velocity = vel2D;
	ApplyVelocity = vel2D;
}

function Tick(float DeltaSeconds)
{
	if (ApplyVelocity==vect(0,0,0))
		return;
	if (Velocity==vect(0,0,0))
	{
		ApplyVelocity=Velocity;
		return;
	}
	Velocity = ApplyVelocity;
}

/*
simulated function JointTouchedBy(actor Other, int joint)
{
	if (Other.Base != self)
		ApplyJointForce(joint, vect(0,0,1)*Other.Velocity.Z);
}
*/

defaultproperties
{
     bStatic=False
     bStasis=False
     DrawType=DT_SkeletalMesh
     CollisionRadius=48.000000
     CollisionHeight=18.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     bJointsTouch=True
     Mass=1000.000000
     Buoyancy=1200.000000
     bNoSurfaceBob=True
}
