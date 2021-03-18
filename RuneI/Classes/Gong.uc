//=============================================================================
// Gong.
//=============================================================================
class Gong expands Instrument;


var(Sounds) Sound HitGong;


simulated event GetAccelJointParms(int joint, out float DampFactor, out float RotThreshold)
{
	DampFactor = 0.025;
	RotThreshold = 2000;
}

simulated event float GetAccelJointMagnitude(int joint)
{
	return 10000;
}

function PlayInstrument(actor Musician)
{
	Super.PlayInstrument(Musician);
	PlaySound(HitGong, SLOT_Misc,,,, FRand()*0.5 + 0.8);
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local vector vel;

	vel = Momentum * 0.05;
	ApplyJointForce(3, vel);

	PlayInstrument(EventInstigator);

	return false;
}

simulated function JointTouchedBy(actor Other, int joint)
{
	local vector vel;

	if (joint == 3)
	{
		vel = Other.Velocity * 0.25;
		ApplyJointForce(joint, vel);
	}
}

//============================================================================
//
// GetUseAnim
//
// Returns the animation that the player (or a viking) should play when
// this item is 'used'. 
//============================================================================

function name GetUseAnim()
{
	return('Neutral_kick'); // TEMP:  Using neutral_kick until we have proper instrument anims
}

//============================================================================
//
// UseTrigger
//
//============================================================================

function bool UseTrigger(actor Other)
{
	local vector v;

	v = Other.Location - Location;

	ApplyJointForce(3, v * 2);
	PlayInstrument(Other);
	return true;
}

defaultproperties
{
     HitGong=Sound'OtherSnd.Instruments.gong03'
     bStatic=False
     DrawType=DT_SkeletalMesh
     CollisionRadius=55.000000
     CollisionHeight=61.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     bJointsTouch=True
     Skeletal=SkelModel'objects.Gong'
}
