//=============================================================================
// Lizard.
//=============================================================================
class Lizard expands Food;

var() bool bWallLizard;
var() bool bChameleon;

var() Sound AmbientSound[3];
var() float AmbientDelay;

function PostBeginPlay()
{
	local Texture tex;
	local int Flags;
	local vector ScrollDir;
	local vector X, Y, Z;

	Super.PostBeginPlay();

	// Grab texture from surroundings
	if(bChameleon)
	{
		if (Level.Netmode == NM_StandAlone)
			Nutrition = 25; // Chameleon lizards are more nutritious

		GetAxes(Rotation, X, Y, Z);

		tex = TraceTexture(Location - Z * 100, Location, Flags, ScrollDir);
		if(tex != None)
		{
			SkelGroupSkins[1] = tex;
			SkelGroupSkins[2] = tex;
			SkelGroupSkins[3] = tex;
			SkelGroupSkins[4] = tex;
			SkelGroupSkins[5] = tex;
		}
	}
}

function Trigger(actor Other, pawn EventInstigator)
{
	FallToGround(EventInstigator);
}

function FallToGround(pawn EventInstigator)
{
	local rotator rot;
	local vector X, Y, Z;
	local Actor A;

	if(bWallLizard)
	{
		bWallLizard = false;
	
		// Thrust the lizard from the wall a bit
		GetAxes(Rotation, X, Y, Z);
		Velocity = Z * 60;
	}

	SetPhysics(PHYS_Falling);
	rot.Yaw = Rotation.Yaw;
	rot.Pitch = 0;
	rot.Roll = 0;
	SetRotation(rot);

	SetTimer(0, false);
	PlayAnim('base', 1.0, 0.1);

	// Trigger any events
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, EventInstigator );
}

auto state Pickup
{
	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		FallToGround(EventInstigator);
		return true;
	}

	function ChangeBehavior()
	{
		RotationRate.Pitch = 0;
		RotationRate.Roll = 0;

		if(FRand() < 0.4)
		{ // Standing still
			LoopAnim('idle', 1.0, 0.1);
			DesiredRotation.Yaw = Rotation.Yaw;
		}
		else
		{ // Rotating
			LoopAnim('run', 1.0, 0.1);
			if(FRand() < 0.5)
			{
				DesiredRotation.Yaw = Rotation.Yaw - 8000;		
				RotationRate.Yaw = -4000;
			}
			else
			{
				DesiredRotation.Yaw = Rotation.Yaw + 8000;
				RotationRate.Yaw = 4000;
			}
		}
				
		// Make random lizard noise
		PlaySound(AmbientSound[Rand(3)], SLOT_Talk, 1.0, true, 700, 0.95 + FRand() * 0.1);
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		SetPhysics(PHYS_Falling);
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		SetPhysics(PHYS_Falling);
	}

	
begin:
	bFixedRotationDir = true;
	bRotateToDesired = true;

	if(bWallLizard)
	{
		SetPhysics(PHYS_None);
	}
	else
	{
		SetPhysics(PHYS_Falling); // don't fall at start
	}
	
	LoopAnim('idle', 1.0, 0.1);

	Sleep(FRand()); // So that multiple lizards are offset by a bit

loop:
	Sleep(5);
	ChangeBehavior();
	Goto('loop');
}

simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);
	
	Canvas.DrawText("Lizard:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  bWallLizard: " $ bWallLizard);
	Canvas.CurY -= 8;
}

defaultproperties
{
     AmbientSound(0)=Sound'CreaturesSnd.Lizard.lizard01'
     AmbientSound(1)=Sound'CreaturesSnd.Lizard.lizard02'
     AmbientSound(2)=Sound'CreaturesSnd.Lizard.lizard03'
     AmbientDelay=15.000000
     Nutrition=15
     JunkActor=Class'RuneI.EatenLizard'
     UseSound=Sound'OtherSnd.Pickups.pickuplizard01'
     PickupMessage="You consumed a lizard"
     DrawScale=1.250000
     ScaleGlow=1.250000
     LODCurve=LOD_CURVE_CONSERVATIVE
     CollisionRadius=25.000000
     CollisionHeight=20.000000
     bCollideWorld=True
     Skeletal=SkelModel'creatures.Lizard'
}
