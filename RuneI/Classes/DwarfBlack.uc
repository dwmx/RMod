//=============================================================================
// DwarfBlack.
//=============================================================================
class DwarfBlack expands Dwarf;

/*
	Description:
		Boss.  Accumulates electricity through his back and releases it as energy balls
		5 spigots of electricity
		twitch and smoke when 5th switch turned on...
		stays in a radius
		each switch makes more and more powerful, but closer to overload

	Anims:
		Muttering
		Laughing

	TODO:
		Lead Target when shooting
		Death Explosion
		twitch and smoke at higher power levels
		attack beam support for tracing to target
*/

var private int PowerLevel;
var private int loop;
var private DarkDwarfChargeup chargeup;		// chargeup actor in hand
var private DarkDwarfBolt bolt;				// attack bolt
var private actor LightningTarget;
var float MoveRadius;
var float SpringMag;

var(Sounds) sound	ChargeupSoundLOOP;
var(Sounds) sound	ReleaseSoundLOOP;
var(Sounds) sound	OverchargedSoundLOOP;


//================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//================================================
function Texture PainSkin(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_BODY:
		case BODYPART_HEAD:
		case BODYPART_LARM1:
		case BODYPART_RARM1:
		case BODYPART_LLEG1:
		case BODYPART_RLEG1:
		case BODYPART_LLEG2:
		case BODYPART_LARM2:
		case BODYPART_RARM2:
		case BODYPART_RLEG2:
			break;
	}
	return None;
}


function PostBeginPlay()
{
	Super.PostBeginPlay();

	chargeup = spawn(class'DarkDwarfChargeup',,,,);
	AttachActorToJoint(chargeup, 28);

	// Spawn charge up electricity
	bolt = Spawn(class'darkdwarfbolt',self,'bolt',,);
	AttachActorToJoint(bolt, 29);
	bolt.bHidden = true;
	bolt.Target = None;
}

//================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//================================================
function bool CanPickup(Inventory item)
{
	return false;
}

function CheckForEnemies()	{}


//================================================
//
// Trigger
//
// Each time he is triggered raises power level
//================================================
function Trigger(actor Other, pawn EventInstigator)
{
	PowerLevel++;

	if (PowerLevel >= 5)
	{
		GotoState('OverCharged');
	}
	else
	{
		chargeup.SetPowerLevel(PowerLevel);
		bolt.SetPowerLevel(PowerLevel);
	}
}


//================================================
//
// JointDamaged
//
//================================================
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	return false;
}

//-----------------------------------------------------------------------------
// Animation functions
//-----------------------------------------------------------------------------
function PlayWaiting(optional float tween)
{
	LoopAnim('dd_idlea', 1.0, 0.1);
}
function TweenToWaiting(float time)
{
	TweenAnim ('dd_idlea',          time);
}

function PlayVictoryDance()
{
	LoopAnim('dd_idleb', 1.0, 0.1);
}

function PlayMissileAttack()
{
	PlayAnim('dd_attacka', 1.0, 0.1);
}

function PlayDeath(name DamageType)
{
	LoopAnim('dd_death', 1.0, 0.1);
}



//-----------------------------------------------------------------------------
// States
//-----------------------------------------------------------------------------

// Used to stop attacking when conditions are met
// Player is still valid with DarkDwarf even if player goes invisible
function bool ValidEnemy()
{
	if (AttitudeToPlayer==ATTITUDE_Follow && ScriptPawn(Enemy)!=None && ScriptPawn(Enemy).Ally==Ally)
		return false;

	return (Enemy!=None && Enemy.Health > 0);
}

State Fighting
{
	function EndState()
	{
		BoltOff();
		AmbientSound=None;
		chargeup.StopExpanding();
		chargeup.Hide();
	}

	// Notify callback to throw energy ball
	function DoThrow()
	{
		if (bolt!=None)
			bolt.DoDamage();
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function BoltOn()
	{
		bolt.bHidden = false;
		bolt.ResetTargetting();
	}

	function BoltOff()
	{
		bolt.bHidden = true;
	}

	function bool ShouldShoot()
	{
		local Actor HitActor;
		local vector HitLocation, HitNormal;
		local vector FireLocation;

		FireLocation = GetJointPos(JointNamed('attach_hand'));

		// Make sure have LOS to enemy or blocked by destroyable
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location+(vect(0,0,1)*Enemy.EyeHeight), FireLocation, true, vect(5,5,5));
		if (HitActor != None)
		{
			bolt.SetTarget(HitActor);
			if (HitActor.IsA('LevelInfo'))
				return false;
			else if (HitActor.IsA('PolyObj'))
				return (powerlevel > 1);
			else if (HitActor == Enemy)
				return true;
			else
				return false;
		}
		return true;
	}

	function bool PickDestination()
	{
		local int i;
		local actor HitActor;
		local vector HitLocation, HitNormal, newloc;

		bHurrying = false; //Rand(2) == 0;
		UpdateMovementSpeed();

		// Try to find a position within MoveRadius that gives LOS
		Destination = Location;
		for (i=0; i<10; i++)
		{
			newloc = HomeBase + VRand()*MoveRadius;
			newloc.Z = HomeBase.Z;
			HitActor = Trace(HitLocation, HitNormal, newloc, Enemy.Location, false, vect(5,5,5));
			if (HitActor == None)
			{
				Destination = newloc;
				return true;
			}
		}

		return false;
	}

Begin:

Think:
	if ( !ValidEnemy() )
	{
		PlayVictoryDance();
		Sleep(5);
		FinishAnim();
		GotoState('GoingHome');
	}

	if (NeedToTurn(Enemy.Location))
	{
		PlayTurning(0.1);
		TurnToward(Enemy);
	}

	if (ShouldShoot())
	{	// Throw
		PlayAnim('dd_windupa', 1.0, 0.1);
		Sleep(0.2);
		AmbientSound=ChargeupSoundLOOP;
		chargeup.StartExpanding();
		FinishAnim();
		PlayAnim('dd_attacka', 1.0, 0.1);
		FinishAnim();

		// Looping fire
		loop = PowerLevel;
		LoopAnim('dd_fireA', 1.0, 0.1);
		chargeup.StopExpanding();
		AmbientSound=ReleaseSoundLOOP;
		BoltOn();
		Sleep(1*PowerLevel);
		BoltOff();
		AmbientSound=None;

donelooping:
		chargeup.Hide();
		FinishAnim();
		PlayWaiting(0.5);	// Refire rate
		Sleep(0.5);
		FinishAnim();

		// Play Laugh anim
	}

	if (PickDestination())
	{
		// Maneuver for better vantage point
		PlayMoving(0.1);
		MoveTo(Destination, MovementSpeed);
		Acceleration=vect(0,0,0);
		TurnToward(Enemy);
//		FinishAnim();
	}
	else
	{
		PlayWaiting(0.1);
		FinishAnim();
	}

	Goto('think');
}


State Overcharged
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, PainTimer, Landed, EnemyAcquired, JointDamaged;

	function BeginState()
	{
		MakeSpringy();
		Timer();
	}

	function EndState()
	{
		SetTimer(0, false);
	}

	function MakeSpringy()
	{
		local int i;
		for (i=1; i<NumJoints(); i++)
		{
			JointFlags[i] = JointFlags[i] | JOINT_FLAG_SPRINGPOINT;
		}
	}

	function Spring()
	{
		local int i;
		for (i=1; i<NumJoints(); i++)
			ApplyJointForce(i, VRand()*Rand(SpringMag));
	}

	function Timer()
	{
		DesiredFatness=Rand(255);
		if (FRand() < 0.4)
			PlaySound(Sound'OtherSnd.Explosions.explosion10', SLOT_None);
		else
			PlaySound(Sound'OtherSnd.Explosions.explosion11', SLOT_None);

		SetTimer(FRand()*0.5, false);

		Spring();
	}

	function RemoveLightning()
	{
		local actor A;
		local DarkDwarfLightning B;
		local SparkSystem C;
		
		foreach AllActors( class 'DarkDwarfLightning', B,)
			B.Target = LightningTarget;

		foreach AllActors( class 'actor', A, 'Concentrator' )
		{
			A.Target = None;
			A.bHidden = true;
		}	
	}

	function ResetLightning()
	{
		local DarkDwarfLightning A;
			
		foreach AllActors(class 'DarkDwarfLightning', A,)
		{
			if(LightningTarget == None)
				LightningTarget = A.Target;
			A.Target = self;
			A.TargetJointIndex = Rand(NumJoints() - 1); 
		}
	}
Begin:
	Acceleration=vect(0,0,0);
	ResetLightning();
	PlayDeath('overcharged');
	AmbientSound=OverchargedSoundLoop;
	Sleep(5);

	AmbientSound=None;
	SetTimer(0, false);
	RemoveLightning();
	spawn(class'DarkDwarfExplosion',,,,);
	spawn(class'DarkDwarfBlast',,,Location + vect(0,0,-50),);
	Died(self, 'overcharged', Location);
}


State Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, Landed, EnemyAcquired, JointDamaged;

Begin:
	Destroy();
}

defaultproperties
{
     PowerLevel=1
     MoveRadius=375.000000
     SpringMag=100.000000
     ChargeupSoundLOOP=Sound'EnvironmentalSnd.Scifi.scifi14L'
     ReleaseSoundLOOP=Sound'EnvironmentalSnd.Scifi.scifi11L'
     OverchargedSoundLOOP=Sound'EnvironmentalSnd.Scifi.scifi12L'
     bThrowWeapon=False
     BashSound=None
     AlertOrders=Fighting
     bLungeAttack=False
     BlockChance=0.000000
     BreathSound=None
     AcquireSound=Sound'CreaturesSnd.Dwarves.bosssee01'
     AmbientWaitSounds(0)=None
     AmbientWaitSounds(1)=None
     AmbientWaitSounds(2)=None
     AmbientFightSounds(0)=Sound'CreaturesSnd.Dwarves.boss08'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Dwarves.boss10'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Dwarves.boss09'
     AmbientFightSoundDelay=8.000000
     bIsBoss=True
     StartWeapon=None
     StartShield=None
     MeleeRange=100.000000
     GroundSpeed=642.000000
     AccelRate=5000.000000
     WalkingSpeed=399.000000
     Health=1000
     Die=Sound'CreaturesSnd.Dwarves.bossdeath01'
     Die2=Sound'CreaturesSnd.Dwarves.bossdeath01'
     Die3=Sound'CreaturesSnd.Dwarves.bossdeath01'
     FootstepVolume=1.000000
     FootStepWood(0)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepWood(1)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepWood(2)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepMetal(0)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepMetal(1)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepMetal(2)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepStone(0)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepStone(1)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepStone(2)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepFlesh(0)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepFlesh(1)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepFlesh(2)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepIce(0)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepIce(1)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepIce(2)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepEarth(0)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepEarth(1)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepEarth(2)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepSnow(0)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepSnow(1)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepSnow(2)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepWater(0)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepWater(1)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepWater(2)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepMud(0)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepMud(1)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepMud(2)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepLava(0)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepLava(1)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     FootStepLava(2)=Sound'CreaturesSnd.Dwarves.bossfoot01'
     MaxBodyAngle=(Yaw=22768)
     MaxHeadAngle=(Pitch=2048,Yaw=2048)
     DrawScale=3.000000
     SoundRadius=64
     SoundVolume=200
     TransientSoundRadius=2500.000000
     CollisionRadius=105.000000
     CollisionHeight=99.000000
     SkelMesh=9
}
