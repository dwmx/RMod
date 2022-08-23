//=============================================================================
// Plants.
//=============================================================================
class Plants extends DecorationRune
	abstract;


var(Dynamics) float Dampening;
var(Dynamics) int	RotAngle;
var(Dynamics) float	AccelMag;
var(Dynamics) float TouchFactor;
var(Dynamics) float HitFactor;
var() float TimeBetweenBrushes;

var(Sounds) sound BrushSound;

var float LastSoundPlayed;

simulated event GetAccelJointParms(int joint, out float DampFactor, out float RotThreshold)
{
	DampFactor = Dampening;
	RotThreshold = RotAngle;
}

simulated event float GetAccelJointMagnitude(int joint)
{
	return AccelMag;
}

function EMatterType MatterForJoint(int joint)
{	
	return MATTER_NONE;
}

function PostBeginPlay()
{
	LastSoundPlayed = Level.TimeSeconds;
	Super.PreBeginPlay();
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	if (joint != 0)
	{
		ApplyJointForce(joint, Momentum*HitFactor);

		if (Level.TimeSeconds - LastSoundPlayed > TimeBetweenBrushes)
		{
			LastSoundPlayed = Level.TimeSeconds;
			PlaySound(BrushSound, SLOT_None);
		}
	}

	Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
	return true;
}

simulated function JointTouchedBy(actor Other, int joint)
{
	local vector vel;

	vel = Other.Velocity * TouchFactor;
	ApplyJointForce(joint, vel);
	PlayBrushSound(Other);
}

function PlayBrushSound(actor Other)
{
	if (Level.TimeSeconds - LastSoundPlayed > TimeBetweenBrushes)
	{
		PlaySound(BrushSound, SLOT_None);
		LastSoundPlayed = Level.TimeSeconds;
		if (Pawn(Other) != None || Other.Instigator != None)
		{
			Other.MakeNoise(1.0);
		}
	}
}

function AddVelocity(vector NewVelocity)
{
	local int ix,num;
	num = NumJoints();
	for (ix=0; ix<num; ix++)
	{
		if ((JointFlags[ix] & JOINT_FLAG_COLLISION)!=0)
		{
			ApplyJointForce(ix, NewVelocity);
		}
	}
}

simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);
	
	Canvas.DrawText("Dynamics:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" Dampening:   "$Dampening);
	Canvas.CurY -= 8;
	Canvas.DrawText(" RotAngle:    "$RotAngle);
	Canvas.CurY -= 8;
	Canvas.DrawText(" AccelMag:    "$AccelMag);
	Canvas.CurY -= 8;
	Canvas.DrawText(" TouchFactor: "$TouchFactor);
	Canvas.CurY -= 8;
	Canvas.DrawText(" HitFactor:   "$HitFactor);
	Canvas.CurY -= 8;
}

defaultproperties
{
     Dampening=0.025000
     RotAngle=8000
     AccelMag=10000.000000
     TouchFactor=0.100000
     HitFactor=0.100000
     TimeBetweenBrushes=1.500000
     bBurnable=True
     bStatic=False
     DrawType=DT_SkeletalMesh
     TransientSoundRadius=1200.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsTouch=True
}
