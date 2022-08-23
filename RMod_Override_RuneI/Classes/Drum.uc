//=============================================================================
// Drum.
//=============================================================================
class Drum expands Instrument
	abstract;

var(Sounds) Sound HitDrum;
var float LastPlayed;

simulated event GetSpringJointParms(int joint, out float DampFactor, out float SpringConstant, out vector SpringThreshold)
{
	DampFactor = 10;
	SpringConstant = 3000;
	SpringThreshold = vect(0,0,5);
}

function PlayInstrument(actor Musician)
{
	Super.PlayInstrument(Musician);

	if (Level.TimeSeconds - LastPlayed > 0.5)
	{
		LastPlayed = Level.TimeSeconds;
		PlaySound(HitDrum, SLOT_Misc,,,, FRand()*0.5 + 0.8);
	}
}

function AddVelocity(vector NewVelocity)
{	// Blast radius has no effect
}

function Trigger(actor Other, pawn EventInstigator)
{
	Super.Trigger(Other, EventInstigator);
	ApplyJointForce(JointNamed('drum'), vect(0,0,-50));
}

function bool UseTrigger(actor Other)
{
	ApplyJointForce(JointNamed('drum'), vect(0,0,-50));
	return Super.UseTrigger(Other);
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	if (DamageType == 'fire')
		return Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);

	ApplyJointForce(JointNamed('drum'), Momentum*0.1);
	PlayInstrument(EventInstigator);
	return false;
}

/*
simulated function JointTouchedBy(actor Other, int joint)
{
	local vector vel;
	vel = Other.Velocity*0.5;
	ApplyJointForce(joint, vel);
	PlayInstrument(Other);
}
*/

defaultproperties
{
     bBurnable=True
     bStatic=False
     DrawType=DT_SkeletalMesh
     DrawScale=1.280000
     LODCurve=LOD_CURVE_NONE
     CollisionRadius=38.000000
     CollisionHeight=18.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsTouch=True
     Skeletal=SkelModel'objects.Drum'
}
