//=============================================================================
// HangingChain.
//=============================================================================
class HangingChain extends DecorationRune;

var(Dynamics) float Dampening;
var(Dynamics) int	RotAngle;
var(Dynamics) float	AccelMag;
var(Dynamics) float TouchFactor;
var(Dynamics) float HitFactor;
var(Dynamics) float PropogationFactor;

var() float TimeBetweenBrushes;

var(Sounds) sound BrushSound;
var() name AttachmentTag;

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
	local actor A;

	foreach AllActors(class'actor', A, AttachmentTag)
	{
		if (A!=self)
		{
			A.SetCollision(false, false, false);
			AttachActorToJoint(A, JointNamed('rope_tip'));
			break;
		}
	}
	
	LastSoundPlayed = Level.TimeSeconds;
	Super.PreBeginPlay();
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

simulated function ApplyPropogatedForce(vector force, int joint)
{
	local vector vel;
	local int j;

	vel = force;
	j = joint;
	while ((JointFlags[j] & JOINT_FLAG_ACCELERATIVE)!=0)
	{
		ApplyJointForce(j, vel);
		vel *= PropogationFactor;
		j--;
	}
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	if (joint != 0)
	{
		ApplyPropogatedForce(Momentum*HitFactor, joint);
		PlayBrushSound(EventInstigator);
	}

	Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
	return true;
}

simulated function JointTouchedBy(actor Other, int joint)
{
	ApplyPropogatedForce(Other.Velocity*TouchFactor, joint);
	PlayBrushSound(Other);
}

function AddVelocity(vector NewVelocity)
{
	ApplyPropogatedForce(NewVelocity*TouchFactor, JointNamed('ropem'));
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
	Canvas.DrawText(" PropogationFactor: "$PropogationFactor);
	Canvas.CurY -= 8;
}

defaultproperties
{
     Dampening=0.010000
     RotAngle=8000
     AccelMag=1000.000000
     TouchFactor=0.002000
     HitFactor=0.020000
     PropogationFactor=0.900000
     TimeBetweenBrushes=1.500000
     BrushSound=Sound'FootstepsSnd.Bridge.footbridge01'
     bStatic=False
     AnimSequence=feetfirst
     DrawType=DT_SkeletalMesh
     CollisionRadius=5.000000
     CollisionHeight=134.399994
     bCollideActors=True
     bCollideWorld=True
     bJointsTouch=True
     Skeletal=SkelModel'objects.Rope'
}
