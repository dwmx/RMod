//=============================================================================
// Dangler.
//=============================================================================
class Dangler expands ScriptPawn;

/* Description: Tough, possibly unbeatable large fish that dangles a phosphous light emiting
	dealie in order to see in his domain which is deep dark water areas. Moves better horizontally
	than vertically.  Avoidance should be used against them as weapons are of no use against him.

   TODO:
*/


// EDITABLE INSTANCE VARIABLES ------------------------------------------------

var() byte			BiteDamage;
var() byte			RipDamage;
var(Sounds) sound	BiteMissSound;
var(Sounds) sound	BiteEatSound;
var(Sounds) sound	RipSound;
var(Sounds) sound	SwimSound;

// INSTANCE VARIABLES ---------------------------------------------------------

var float		AirTime;
var bool		bAttackBump;

var string 		debugstring;

// FUNCTIONS ------------------------------------------------------------------

function PostBeginPlay()
{
	local int j;
	local actor a;

	Super.PostBeginPlay();
	
	// Spawn his dealie light
	a = spawn(class'DanglerLight', self,, Location);
	if (a != None)
		AttachActorToJoint(a, JointNamed('danglerb'));
}

function Destroyed()
{
	local actor a;
	
	// Remove his dealie light
	a = DetachActorFromJoint(JointNamed('danglerb'));
	if (a!=None)
		a.Destroy();
	Super.Destroyed();
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	return false;
}

function PreSetMovement()
{
	bCanJump = false;
	bCanWalk = false;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
	bCanOpenDoors = false;
	bCanDoSpecial = false;
}

function Texture PainSkin(int BodyPart)
{
}


//------------------------------------------------
//
// InAttackRange
//
// When within attack range, state changes from
// charging to fighting
//------------------------------------------------
function bool InAttackRange(Actor Other)
{
	local float range;
	range = VSize(Location-Other.Location);
	return (range <= CollisionRadius + Other.CollisionRadius + LungeRange) &&
		(Abs(Other.Location.Z - Location.Z) < CollisionHeight) &&
		ActorInSector(Other, ANGLE_1*20);
}


function ZoneChange(ZoneInfo newZone)
{
	if(newZone.bWaterZone)
	{
		AirTime = 0;
		setPhysics(PHYS_Swimming);
		PlayMoving();
	}
	else
	{
		SetPhysics(PHYS_Falling);
	}
}

function SetMovementPhysics()
{
	if(Region.Zone.bWaterZone)
		SetPhysics(PHYS_Swimming);
	else
	{
		SetPhysics(PHYS_Falling);
		MoveTimer = -1.0;
	}
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other.IsA('Dangler') )
		return ATTITUDE_Friendly;
	else
		return ATTITUDE_Ignore;
}

function bool SetEnemy( Actor NewEnemy )
{
	local EAttitude attitude;

	if (bTaskLocked)
		return false;
	if (NewEnemy == IgnoreEnemy)
		return false;
	if (Pawn(NewEnemy)!=None && Pawn(NewEnemy).Health<=0)
		return false;

	// Attitude logic for choosing enemy
	if (Pawn(NewEnemy) != None)
		attitude = AttitudeTo(Pawn(NewEnemy));
	else
		attitude = ATTITUDE_IGNORE;	// ATTITUDE_CURIOUS
	if (attitude >= ATTITUDE_IGNORE)
		return false;

	if (Enemy==None || attitude < AttitudeTo(Enemy))
	{
		// Only set enemy if reachable
		if (!actorReachable(NewEnemy) && !FindBestPathToward(NewEnemy) )
			return false;

		Enemy = Pawn(NewEnemy);
		EnemyAcquired();
	}
	return true;

}


//=============================================================================
//
// Died
//
//=============================================================================

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local actor A;

	// Destroy the light when the Dangler is killed
	A = DetachActorFromJoint(JointNamed('danglerb'));
	if(A != None)
		A.Destroy();
	A = DetachActorFromJoint(JointNamed('head'));

	Super.Died(Killer, damagetype, HitLocation);
}

//=============================================================================
//
// FootStep Notify
// 
//=============================================================================
function FootStep()
{
	local EMatterType matter;
	local vector end;
	local sound snd;
	local int i;

	if(bFootsteps && Region.Zone.bWaterZone)
	{
		PlaySound(SwimSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
	}
}

//============================================================
// Animation functions
//============================================================

function PlayWaiting(optional float tween)
{
	LoopAnim('idle', 0.5 + 0.3 * FRand());
}

function PlayMoving(optional float tween)
{
	if (bHurrying)
		LoopAnim('Swimfast', -0.8/WaterSpeed,, 0.4);
	else
		LoopAnim('Swimfast', 0.5, 0.4);
}

function PlayTurning(optional float tween)
{
	LoopAnim('Swimfast', -0.8/WaterSpeed,, 0.4);
//	LoopAnim('Swimfast', 1.0, 0.1);
}

function PlayInAir(optional float tween)
{
	LoopAnim('Bite', 2.0, 0.1);
}
function PlayFrontHit(optional float tween)
{
	PlayAnim('Pain', 1.0, 0.1);
}

function PlayDeath(name DamageType)	          { PlayAnim  ('death', 1.0, 0.1);     }

function TweenToWaiting(float tweentime)
{
	TweenAnim('idle', tweentime);
}

function TweenToMoving(float tweentime)
{
	TweenAnim('Swimfast', tweentime);
}

function TweenToFalling()
{
	TweenAnim('Bite', 0.5);
}

function PlayRipping()		{	LoopAnim('thrash', 1.0, 0.1);	}	// Thrashing with creature in mouth



// STATES ---------------------------------------------------------------------

state StakeOut
{	// Overridden to roam
	ignores SeePlayer, HearNoise, EnemyAcquired;

Begin:
	Enemy = None;
	GotoState('Roaming');
}


state Fighting
{
ignores SeePlayer, HearNoise;

	function EndState()
	{
		bAttackBump = false;
		MaxDesiredSpeed = 1.0;
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	singular function Bump(actor Other)
	{
		if ( bAttackBump && Pawn(Other) != None)
		{
			if (Pawn(Other).ReducedDamageType == 'All' )
				return;

			Other.JointDamaged(Pawn(Other).Health*2, self, Other.Location, vect(0,0,0), 'gibbed', 0);
			PlaySound(BiteEatSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
			Velocity *= 0.5;
			Other.DrawType = DT_None;

/*
			if (Other.IsA('PlayerPawn'))
			{			
				AttachActorToJoint(Other, JointNamed('head'));
				//Other.LoopAnim('inmouth', 1.0, 0.1);

				// Drop the camera
				RunePlayer(Other).bCameraLock = true;
			}
*/

			GotoState('Ripping');
		}
	}

	function SoundNotify1()
	{
		PlaySound(BiteMissSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
		bAttackBump = false;	// missed
	}

	function LungeAttack()
	{
		local vector X,Y,Z;
		local vector ToEnemy;

		GetAxes(Rotation, X,Y,Z);

		// Lunge at enemy
		Acceleration = X*8000*WaterSpeed;
		Velocity += X*800*WaterSpeed;
	}

Begin:
	// Keep moving forward

	// Turn to enemy
	DesiredRotation = rotator(Enemy.Location - Location);

	if (ActorInSector(Enemy, ANGLE_1*20) && (Abs(Enemy.Location.Z - Location.Z) < CollisionHeight))
	{
		PlayAnim('Bite', 1.0, 0.1);
		bAttackBump = true;
		MaxDesiredSpeed = 8.0;

		LungeAttack();

		FinishAnim();
		MaxDesiredSpeed = 1.0;
		bAttackBump = false;
	}
/*	else
	{
		PlayAnim('SwimmingB', 1.0, 0.1);
		FinishAnim();
	}
*/

	GotoState('Charging', 'ResumeFromFighting');

}


State Ripping
{
ignores SeePlayer, HearNoise, Bump;

	function SoundNotify2()
	{
		PlaySound(RipSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
	}

Begin:
	PlayRipping();
	Sleep(1.0);
	GotoState('Roaming');
}


simulated function Debug(canvas Canvas, int mode)
{
	Super.Debug(canvas, mode);
	
	Canvas.DrawText("Dangler:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" RotationRate: "$RotationRate);
	Canvas.CurY -= 8;
	Canvas.DrawText(" Buoyancy: "$Buoyancy);
	Canvas.CurY -= 8;
	Canvas.DrawText(" bCanStrafe: "$bCanStrafe);
	Canvas.CurY -= 8;
	Canvas.DrawText(" MoveTimer: "$MoveTimer);
	Canvas.CurY -= 8;
	Canvas.DrawText(" MoveTarget: "$MoveTarget);
	Canvas.CurY -= 8;
	Canvas.DrawText(" Destination: "$Destination);
	Canvas.CurY -= 8;
	Canvas.DrawText(" debugstring: "$debugstring);
	Canvas.CurY -= 8;
}

defaultproperties
{
     BiteMissSound=Sound'CreaturesSnd.Dangler.danglerbite01'
     BiteEatSound=Sound'CreaturesSnd.Dangler.danglereats01'
     RipSound=Sound'CreaturesSnd.Dangler.danglerbite01'
     bLungeAttack=True
     FightOrFlight=1.000000
     FightOrDefend=1.000000
     HighOrLow=1.000000
     LungeRange=200.000000
     AcquireSound=Sound'CreaturesSnd.Dangler.danglerbite01'
     bRoamHome=True
     bGlider=True
     bWaitLook=False
     bBurnable=False
     WanderDistance=0.000000
     MeleeRange=200.000000
     GroundSpeed=0.000000
     WaterSpeed=300.000000
     AccelRate=1000.000000
     WalkingSpeed=200.000000
     ClassID=3
     HitSound1=Sound'CreaturesSnd.Dangler.danglerhit01'
     HitSound2=Sound'CreaturesSnd.Dangler.danglerhit01'
     HitSound3=Sound'CreaturesSnd.Dangler.danglerhit01'
     Die=Sound'CreaturesSnd.Dangler.danglerdeath01'
     Die2=Sound'CreaturesSnd.Dangler.danglerdeath01'
     Die3=Sound'CreaturesSnd.Dangler.danglerdeath01'
     bCanLook=True
     MaxHeadAngle=(Yaw=6917)
     bRotateTorso=False
     SoundRadius=34
     SoundVolume=119
     SoundPitch=50
     AmbientSound=Sound'CreaturesSnd.Dangler.danglerswim04L'
     TransientSoundRadius=800.000000
     CollisionRadius=80.000000
     CollisionHeight=66.000000
     bJointsTouch=True
     Mass=400.000000
     Buoyancy=400.000000
     RotationRate=(Pitch=1000,Yaw=16000)
     Skeletal=SkelModel'creatures.Dangler'
}
