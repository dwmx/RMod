//=============================================================================
// Zombie.
//=============================================================================
class Zombie expands ScriptPawn;

const DEFAULT_TWEEN = 0.15;

var() name CrucifiedAnim;
var() float LungeChance;
var(Sounds) sound DecapitateSound;
var(Sounds) sound GreenPuffSound;
var(Sounds) sound ZombieGetUpSound;

var ZombieEye Eyes;

//============================================================
//
// PostBeginPlay
//
//============================================================

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Eyes = Spawn(Class'ZombieEye');
	AttachActorToJoint(Eyes, JointNamed('head'));
	Eyes.bHidden = true; // ZombieEyes initial are hidden
}

//------------------------------------------------
//
// AttitudeToCreature
//
//------------------------------------------------
function eAttitude AttitudeToCreature(Pawn Other)
{
	if (Other!=None && Other.IsA('Goblin'))
		return ATTITUDE_Hate;
	else
		return Super.AttitudeToCreature(Other);
}

//================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
// Zombies can only use their claws
//================================================
function bool CanPickup(Inventory item)
{
	if(item.IsA('Weapon') && (BodyPartHealth[BODYPART_RARM1] > 0) && (Weapon == None))
	{
		return(item.IsA('ZombieClaw'));
//		return(item.IsA('axe') || item.IsA('hammer') || item.IsA('sword') || item.IsA('ZombieClaw'));
	}
}


function GlowEyes(bool glow)
{
	if(Eyes != None)
	{
		if(glow)
			Eyes.bHidden = false;
		else
			Eyes.bHidden = true;
	}
}

function PlayDyingSound(name damageType)
{
	if (damageType == 'decapitated')
		PlaySound(DecapitateSound, SLOT_Talk);
	else
		Super.PlayDyingSound(damageType);
}

//===================================================================
//					Localized Damage Functions
//===================================================================

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_EARTH;
}

//============================================================
//
// BodyPartSeverable
//
//============================================================
function bool BodyPartSeverable(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_HEAD:
			return true;
	}
	return false;
}

//============================================================
//
// BodyPartCritical
//
//============================================================

function bool BodyPartCritical(int BodyPart)
{
	return (BodyPart == BODYPART_HEAD);
}


//============================================================
//
// DamageBodyPart
//
//============================================================

function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int bodypart)
{
	local int PassThrough;
	local int SeverDamage;
	local int BluntDamage;
	local bool bAlreadyDead;
	local int AppliedDamage;
	local Debris Gib;
	local float scale;
	local int i, NumChunks;

	local vector AdjMomentum;

	if(!class'GameInfo'.Default.bLowGore)
		PainSkin(BodyPart);

	GetDamageValues(Damage, DamageType, BluntDamage, SeverDamage);
	Level.Game.ReduceDamage(BluntDamage, SeverDamage, DamageType, self, EventInstigator);
	PassThrough = LimbPassThrough(BodyPart, BluntDamage, SeverDamage);

	if (BodyPart != BODYPART_BODY)
	{
		if (BodyPartSeverable(BodyPart) && (BodyPartHealth[BodyPart] > 0))
		{
			BodyPartHealth[BodyPart] -= SeverDamage;
	
			if(BodyPartHealth[BodyPart] <= 0)
			{	// Body Part was killed
				if (BodyPartCritical(BodyPart))
				{
					PassThrough = Max(Health, Damage);

					if (EventInstigator != None)
					{
						EventInstigator.BoostStrength(0.15 * Default.Health);
					}

					DamageType = 'decapitated';
				}

				// Sever the limb
				BodyPartVisibility(BodyPart, false);
				BodyPartCollision(BodyPart, false);

				if(!class'GameInfo'.Default.bLowGore )		
					LimbSevered(BodyPart, Momentum); // Lop off zombie head
			}
		}
	}

	if (DamageType=='sever' || DamageType=='bluntsever')
	{	// spawn chunks
		NumChunks = (Damage / 15) + 1;
		NumChunks = NumChunks * Level.Game.DebrisPercentage;
		for(i = 0; i < NumChunks; i++)
		{
			Gib = spawn(GibClass,,, HitLocation + VRand() * 2,);
			if (Gib != None)
			{
				Gib.SetSize(RandRange(0.1, 0.4));
				Gib.SetMomentum((-0.08 * Momentum));
			}
		}
	}
	else if (DamageType == 'crushed')
	{	// Force the gib when crushed
		PassThrough = Default.Health*3;
		bGibbable = true;
	}

	// Apply damage to body
	if(PassThrough != 0)
	{
		bAlreadyDead = (Health <= 0);

//		AppliedDamage = Level.Game.ReduceDamage(PassThrough, DamageType, self, EventInstigator);
		AppliedDamage = PassThrough;

		if(DamageType == 'decapitated' || DamageType == 'crushed' || DamageType == 'fire')
		{
			Health -= AppliedDamage;
		}

		if (Health > 0)
		{
			// Apply momentum
			// NOTE:  This code is duplicated in Shield.Active and Shield.Idle states
			AdjMomentum = momentum / Mass;
			if(Mass < VSize(AdjMomentum) && Velocity.Z <= 0)
			{			
				AdjMomentum.Z += (VSize(AdjMomentum) - Mass) * 0.5;
			}
			AddVelocity(AdjMomentum);

			if(CanGotoPainState() && DamageType != 'fire' && FRand() > 0.25)
			{ // Only goto the painstate if the pawn allows it 
				PlayTakeHitSound(AppliedDamage, DamageType, 1);

				if(PassThrough > 5) // DAMAGE_EPSILON = 5
				{ // Only go to the painstate if the damage is over a given level
					if (GetStateName() != 'Pain' && GetStateName() != 'pain')
					{
						NextStateAfterPain = GetStateName();

						// Play pain anim
						PlayTakeHit(0.1, AppliedDamage, HitLocation, DamageType, Momentum, BodyPart);
						GotoState('Pain');
					}
				}
			}
		}
		else if (bAlreadyDead)
		{	// Twitch corpse or Gib
			if(Health < -Default.Health && bGibbable)
			{ // Gib if beaten down far enough
				SpawnBodyGibs(Momentum);
				if (bIsPlayer)
					bHidden=true;
				else
					Destroy();
			}
		}
		else
		{ // Kill the creature
			AddVelocity(momentum * 2 / Mass);

			if (EventInstigator != self && PlayerPawn(EventInstigator) != None)
			{
				EventInstigator.BoostStrength(0.15 * Default.Health);
			}

			if(Health < -Default.Health && bGibbable)
			{ // Gib if beaten down far enough
				Died(EventInstigator, 'gibbed', HitLocation);
//				if (bIsPlayer)	// moved to died
//					bHidden=true;
//				else
//					Destroy();
			}
			else
			{
				// Apply momentum
				Died(EventInstigator, DamageType, HitLocation);
			}
		}
		MakeNoise(1.0);
	}

	return(false);
}

//============================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//============================================================
function Texture PainSkin(int BodyPart)
{
	return None;
}

//=============================================================================
//
// BodyPartForJoint
//
// Returns the body part a joint is associated with
//=============================================================================

function int BodyPartForJoint(int joint)
{
	switch(joint)
	{
		case 2: case 3:				return BODYPART_LLEG1;
		case 6: case 7:				return BODYPART_RLEG1;
		case 17:					return BODYPART_HEAD;
		case 21: case 23:			return BODYPART_LARM1;
		case 30: case 32:			return BODYPART_RARM1;
		default:					return BODYPART_BODY;
	}
}

function int JointForBodyPart(int BodyPart)
{
	switch(BodyPart)
	{
	case BODYPART_LLEG1:			return(3);
	case BODYPART_RLEG1:			return(7);
	case BODYPART_HEAD:				return(17);
	case BODYPART_LARM1:			return(23);
	case BODYPART_RARM1:			return(32);
	default:						return(0);
	}
}

//============================================================
//
// BodyPartForPolyGroup
//
//============================================================
function int BodyPartForPolyGroup(int polygroup)
{
	switch(polygroup)
	{
		case 1:	case 3:			return BODYPART_RARM1;
		case 2:					return BODYPART_RLEG1;
		case 4:					return BODYPART_TORSO;
		case 5:					return BODYPART_HEAD;
		case 6:					return BODYPART_LLEG1;
		case 7:	case 8:			return BODYPART_LARM1;
	}
	return BODYPART_BODY;
}

//================================================
//
// SeveredLimbClass
//
//================================================
function class<Actor> SeveredLimbClass(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LARM1:
			return class'ZombieLArm';
		case BODYPART_RARM1:
			return class'ZombieRArm';
		case BODYPART_HEAD:
			return class'ZombieHead';
			break;
	}

	return None;
}

//============================================================
//
// ApplyGoreCap
//
//============================================================
function ApplyGoreCap(int BodyPart)
{
}

//================================================
//
// LimbSevered
//
//================================================
function LimbSevered(int BodyPart, vector Momentum)
{
	local int joint;
	local vector X,Y,Z,pos;
	local actor part;
	local class<actor> partclass;
	
	Super.LimbSevered(BodyPart, Momentum);

	ApplyGoreCap(BodyPart);
	partclass = SeveredLimbClass(BodyPart);

	part = None;
	switch(BodyPart)
	{
		case BODYPART_HEAD:
			joint = JointNamed('head');
			pos = GetJointPos(joint);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.Velocity = 0.75 * (momentum / Mass) + vect(0, 0, 300);
				part.GotoState('Drop');
			}
			break;
		case BODYPART_LARM1:
			joint = JointNamed('lshoulda');
			pos = GetJointPos(joint);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.Velocity = Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;
		case BODYPART_RARM1:
			joint = JointNamed('rshoulda');
			pos = GetJointPos(joint);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.Velocity = Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;
	}
}

//------------------------------------------------------------
//
// MakeTwitchable
//
// TODO: Move to carcass
//------------------------------------------------------------
function MakeTwitchable()
{
	local int j;

	// Turn all collision joints accelerative
	for (j=0; j<NumJoints(); j++)
	{
		if ((JointFlags[j] & JOINT_FLAG_COLLISION)==0)
			continue;

		switch(j)
		{
			case 11: case 14: case 2: case 6:
				break;
			default:
				JointFlags[j] = JointFlags[j] | JOINT_FLAG_ACCELERATIVE;
//				SetJointRotThreshold(j, 16000);
//				SetJointDampFactor(j, 0.025);
//				SetAccelMagnitude(j, 8000);
				break;
		}
	}
}


function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local int i;

	if (DamageType == 'fire')
	{	// When damaged by fire, let fire spread to other joints
		for (i=0; i<NumJoints(); i++)
		{
			if ( ((JointFlags[i] & JOINT_FLAG_COLLISION)!=0) && JointChild[i] == None)
			{
				SetOnFire(EventInstigator, i);
				break;
			}
		}
	}
	return Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
}

function SetOnFire(Pawn EventInstigator, int Joint)
{
	Super.SetOnFire(EventInstigator, Joint);

	// Make the zombie go crazy when it's on fire!
	GroundSpeed = Default.GroundSpeed * 2;
	LungeChance = Default.LungeChance * 3;

	if(Weapon != None)
		Weapon.DamageType = 'fire';
}


//-----------------------------------------------------------------------------
// Animation functions
//-----------------------------------------------------------------------------

function PlayWaiting(optional float tween)
{
	LoopAnim ('weapon1_idle', 1.0, DEFAULT_TWEEN);
}

//============================================================
//
// PlayMoving
//
//============================================================

function PlayMoving(optional float tween)
{
	if (bHurrying)
	{
		LoopAnim('S1_Walk', 0.75, DEFAULT_TWEEN);
	}
	else
	{
		LoopAnim('z_walkN', 1.0, DEFAULT_TWEEN);
	}
}

//============================================================
//
// PlayStrafeLeft
//
//============================================================

function PlayStrafeLeft(optional float tween)
{
	LoopAnim('strafeleft', 0.75, DEFAULT_TWEEN);
}

//============================================================
//
// PlayStrafeRight
//
//============================================================

function PlayStrafeRight(optional float tween)
{
	LoopAnim('straferight', 0.75, DEFAULT_TWEEN);
}

//============================================================
//
// PlayBackup
//
//============================================================

function PlayBackup(optional float tween)
{
	LoopAnim('weapon1_backup', 0.75, DEFAULT_TWEEN);
}

/*
function PlayMoving(optional float tween)
{
	if (bHurrying)
	{
		LoopAnim  ('z_walk',     1.0, tween);
	}
	else
	{
		if (Weapon==None)						LoopAnim  ('z_walk',     1.0, tween);
		else if (Weapon.IsA('Torch'))			LoopAnim  ('z_walk',1.0, tween);
		else									LoopAnim  ('z_walk',     1.0, tween);
	}
}
*/

function PlayJumping(optional float tween)    { PlayAnim  ('z_idle',		1.0, tween);   }
function PlayHuntStop(optional float tween)   { LoopAnim  ('z_idle',		1.0, tween);   }

function PlayMeleeHigh(optional float tween)
{
	if(FRand() < 0.3)
		PlayAnim('atk_all_attack3_aa0s', 1.0, DEFAULT_TWEEN);
	else
		PlayAnim('z_breathe', 1.0, DEFAULT_TWEEN);
}
function PlayMeleeLow(optional float tween)
{
	PlayAnim  ('atk_all_attack3_aa0s', 1.0, DEFAULT_TWEEN);
}
function PlayTurning(optional float tween)
{
												PlayAnim  ('z_idle',		1.0, tween);
}

function PlayCower(optional float tween)      { LoopAnim  ('z_idle',		1.0, tween);   }
function PlayThrowing(optional float tween)
{	//TODO: Switch weapon type for different throws
												PlayAnim  ('z_idle',   1.0, tween);
}
function PlayTaunting(optional float tween)   { PlayAnim  ('z_idle',      1.0, tween);   }
function PlayInAir(optional float tween)
{
	LoopAnim  ('z_idle',	1.0, DEFAULT_TWEEN);
}
function LongFall()
{
	if (AnimSequence != 'z_idle')
		LoopAnim  ('z_idle',	1.0, 0.1);
}
function PlayLanding(optional float tween)
{
	if (AnimSequence == 'z_idle')
		PlayAnim('z_idle', 1.0, 0.1);
	else if (AnimSequence == 'z_idle')
		PlayAnim('z_idle', 1.0, 0.1);
	else
		PlayAnim('z_idle', 1.0, 0.1);
}

function PlayDodgeLeft(optional float tween)  { PlayAnim  ('z_idle',   1.0, tween);   }
function PlayDodgeRight(optional float tween) { PlayAnim  ('z_idle',   1.0, tween);   }
function PlayDodgeForward(optional float tween){PlayAnim  ('z_idle',   1.0, tween);   }
function PlayDodgeBack(optional float tween)  { PlayAnim  ('z_idle',   1.0, tween);   }
function PlayDodgeBackflip(optional float tween){PlayAnim ('z_idle',   1.0, tween);   }
function PlayDodgeDuck(optional float tween)  { PlayAnim  ('z_idle',   1.0, tween);   }
function PlayBlockHigh(optional float tween)  { LoopAnim  ('z_idle',   1.0, tween);   }
function PlayBlockLow(optional float tween)   { LoopAnim  ('z_idle',  1.0, tween);   }

function PlayFrontHit(float tweentime){}
function PlayHeadHit(optional float tween)    { /* PlayAnim  ('pain',   1.0, tween); */  }
function PlayBodyHit(optional float tween)    { /*PlayAnim  ('pain',   1.0, tween); */  }
function PlayLArmHit(optional float tween)    { /*PlayAnim  ('pain',   1.0, tween); */  }
function PlayRArmHit(optional float tween)    { /*PlayAnim  ('pain',   1.0, tween); */  }
function PlayLLegHit(optional float tween)    { /*PlayAnim  ('pain',   1.0, tween); */  }
function PlayRLegHit(optional float tween)    { /*PlayAnim  ('pain',   1.0, tween); */  }
function PlayDrowning(optional float tween)   { /*LoopAnim  ('drown',  1.0, tween);	*/}

function PlayDeath(name DamageType)	          
{ 
	PlayAnim('z_deadhead', 1.0, 0.1);
}

function PlayDrownDeath(name DamageType)      { PlayAnim  ('z_idle', 1.0, 0.1);	}

/*
// Tween functions
function TweenToWaiting(float time)
{
	TweenAnim ('z_idle',          time);
}
function TweenToMoving(float time)
{
	TweenAnim('z_walk',   time);
}
function TweenToTurning(float time)           {	TweenAnim ('z_walk',    time);         }
function TweenToJumping(float time)           {	TweenAnim ('z_idle',    time);         }
function TweenToHuntStop(float time)          { TweenAnim ('z_idle',   time);         }
function TweenToMeleeHigh(float time)
{
												TweenAnim ('z_idle', time);
}
function TweenToMeleeLow(float time)
{
												TweenAnim ('z_idle', time);
}
function TweenToThrowing(float time)          { TweenAnim ('z_idle',  time);         }
*/

function TweenToWaiting(float time)
{
	LoopAnim('weapon1_idle', time);
}

function TweenToMoving(float time)
{
	TweenAnim('S1_Walk', time);
}

function TweenToTurning(float time)
{ // TODO:  Need turning anims
	TweenAnim('weapon1_idle', time);
}

function TweenToJumping(float time)           {	TweenAnim ('MOV_ALL_jump1_AA0S', time); }
function TweenToMeleeHigh(float time)
{
/*
	if (Weapon==None)							TweenAnim ('swipe',     time);
	else										TweenAnim ('attackb',   time);
*/
}
function TweenToMeleeLow(float time)
{
/*
	if (Weapon==None)							TweenAnim ('swipe',     time);
	else										TweenAnim ('attackb',   time);
*/
}
function TweenToThrowing(float time)          { TweenAnim ('throwA',    time);         }

//===================================================================
//
// PlayTakeHit
//
//===================================================================

function PlayTakeHit(float tweentime, int damage, vector HitLoc, name damageType, vector Momentum, int BodyPart)
{
	PlayAnim('z_knockdown', 1.0, 0.1);
}

//================================================
//
// AltWeaponActivate
//
// Zombie Breath Attack
//================================================

function AltWeaponActivate()
{
	local actor a;
	local rotator r;
	local vector l;

	if(Enemy == None)
		return;

	r = rotator(Enemy.Location - Location);
	l = GetJointPos(JointNamed('head')) + vector(r) * 10;

	a = Spawn(class'ZombieBreath', self,, l, r);
	a.Velocity = vector(r) * 100;
	a.SetPhysics(PHYS_Projectile);

	PlaySound(GreenPuffSound);
}

//============================================================
//
// Died
//
//============================================================

function Died(pawn Killer, name damageType, vector HitLocation)
{
	GlowEyes(false);
	Super.Died(Killer, damageType, HitLocation);
}

//============================================================
//
// ZoneChange
//
//============================================================

function ZoneChange(ZoneInfo newZone)
{
	local rotator newRot;

	Super.ZoneChange(newZone);
	if(newZone.bLokiBloodZone)
	{
		GotoState('Sarkify');
	}
}

//================================================
//
// Sarkify
//
// A zombie transforming into a Sark
//================================================

State Sarkify
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, Landed, EnemyAcquired, CheckForEnemies;

	function SpawnSark()
	{
		local rotator newRot;
		local class<ScriptPawn> SarkClass;
		local ScriptPawn Sark;
		local pawn P;

		SetCollision(false, false, false); // Don't block the incoming Sark
		newRot = Rotation * -1;
//		Sark = Spawn(SarkClass,,, Location, newRot);

		SarkClass = class<ScriptPawn>(DynamicLoadObject("RuneI.SarkSpawn", class'Class'));
		if(SarkClass != None)
			Sark = Spawn(SarkClass,,, Location, newRot);

		if(Sark != None)
		{
			Sark.Event = Event; // Carry over death event			
			Sark.Tag = Tag;

			for(P = Level.PawnList; P != None; P = P.nextPawn)
			{
				if(P.bIsPlayer)
				{
					Sark.LookAt(P);
					break;
				}
			}

			// Set the Sark to roam to find the player
			Sark.Orders = 'roaming';
			Sark.OrdersTag = '';
		}
	}
	
begin:
	SetPhysics(PHYS_None);	
	bHidden = true; // Hide the zombie for a bit, it will be destroyed after the Sark is created
	Spawn(class'ZombieChangeFire',,, Location);
	Sleep(1.0 + FRand());
	SpawnSark();
	Destroy();
}

//================================================
//
// Fighting
//
//================================================
State Fighting
{
ignores EnemyAcquired;

	function BeginState()
	{
		bAvoidLedges = true;
		LookAt(Enemy);
		SetTimer(0.1, true);
		AttackAction = AA_LUNGE;
		bStopMoveIfCombatRange = true;
	}

	function EndState()
	{
		bAvoidLedges = false;

		bSwingingHigh = false;
		bSwingingLow  = false;

		if(Weapon != None)
		{
			Weapon.FinishAttack();
			Weapon.DisableSwipeTrail();
		}

		LookAt(None);
		SetTimer(1.0, false);
	}

	//============================================================
	//
	// InCombatRange
	//
	//============================================================

	function bool InCombatRange(Actor Other)
	{
		if(Other == None)
			return(false);

		return (VSize(Location - Other.Location) < CollisionRadius + Other.CollisionRadius + CombatRange);
	}
		
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function bool BlockRatherThanDodge()
	{
		if (Shield == None)
			return false;

		if (EnemyIncidence != INC_FRONT)
			return false;

		return (FRand() < BlockChance);
	}

	// Determine AttackAction based upon enemy movement and position
	function Timer()
	{
		GetEnemyProximity();

		LastAction = AttackAction;
				
		if(EnemyMovement == MOVE_STRAFE_LEFT && FRand() < 0.9)
		{
			AttackAction = AA_STRAFE_LEFT;
		}
		else if(EnemyMovement == MOVE_STRAFE_RIGHT && FRand() < 0.9)
		{
			AttackAction = AA_STRAFE_RIGHT;
		}
	 	else if(FRand() < 0.5)
	 	{
	 		if(FRand() < 0.5 && LastAction != AA_STRAFE_RIGHT || LastAction == AA_STRAFE_LEFT)
	 		{
	 			AttackAction = AA_STRAFE_LEFT;
	 		}
	 		else if(LastAction != AA_STRAFE_LEFT || LastAction == AA_STRAFE_RIGHT)
	 		{
	 			AttackAction = AA_STRAFE_RIGHT;
	 		}
			else
			{
				AttackAction = AA_WAIT;
			}
	 	}
		else if((EnemyMovement == MOVE_STANDING && FRand() < 0.2) || FRand() < LungeChance)
		{
			AttackAction = AA_LUNGE;
		}		
		else
		{
			AttackAction = AA_WAIT;
		}
		
/*	
		if (ShouldDefend())
		{
			GotoState('Fighting', 'Defend');
		}
*/		
	}

	function bool ShouldDefend()
	{
		return (FRand() > FightOrDefend && InDangerFromAttack());
	}
	
	function bool InDangerFromAttack()
	{
		if ((!Enemy.bSwingingHigh) && (!Enemy.bSwingingLow))
			return false;

		GetEnemyProximity();
			
		if (EnemyDist>CollisionRadius+Enemy.CollisionRadius+Enemy.MeleeRange)
			return false;

		return (EnemyVertical==VERT_LEVEL && EnemyFacing==FACE_FRONT);
	}

	function CalcStrafePosition()
	{		
		local vector V;
		local rotator R;
		local vector temp;
		
		V = Location - Enemy.Location;
		R = rotator(V);
		
		R.Yaw += 4000;

		// Strafe using the enemy's XY location, but the viking's location ground plane		
		temp = Enemy.Location;
		temp.Z = Location.Z;

		Destination = temp + vector(R) * CombatRange;
	}
	
	function CalcStrafePosition2()
	{		
		local vector V;
		local rotator R;
		local vector temp;
		
		V = Location - Enemy.Location;
		R = rotator(V);
		
		R.Yaw -= 4000;

		// Strafe using the enemy's XY location, but the viking's location ground plane		
		temp = Enemy.Location;
		temp.Z = Location.Z;

		Destination = temp + vector(R) * CombatRange;
	}

	function CalcJumpVelocity()
	{
		local float traj;
		local vector adjust;

		traj = (70 + Rand(5)) * 65536 / 360;
		adjust = Enemy.Location - Location; // Random adjustment to compensate for perfect accuracy
		AddVelocity(CalcArcVelocity(traj, Location, Enemy.Location + adjust));
	}

		
Begin:
	Acceleration = vect(0,0,0);

	// Turn to face enemy
	if(Enemy != None)
		DesiredRotation.Yaw = rotator(Enemy.Location-Location).Yaw;

//	PlayWaiting();

Fight:
	GetEnemyProximity();
	
	// Attack if close enough
	if(Weapon != None && Enemy != None && InMeleeRange(Enemy) || (EnemyMovement == MOVE_CLOSER && EnemyDist < MeleeRange * 2.5))
	{
		if(FRand() < 0.8)
		{
			GlowEyes(true);
			PlayMeleeHigh(0.1);
			FinishAnim();
			GlowEyes(false);
		}
		
		Sleep(TimeBetweenAttacks);
	}
	else if(AttackAction == AA_LUNGE)
	{ // Random lunge
		bStopMoveIfCombatRange = false;
		GlowEyes(true);
		PlayAnim('z_attackL', 1.0, 0.1);
		Sleep(0.25); // wait for a bit before doing the actual lunge
		if(Enemy != None)
			AddVelocity(Normal(Enemy.Location - Location) * 325 + vect(0, 0, 200));
		FinishAnim();
		WaitForLanding();
		GlowEyes(false);
		Sleep(TimeBetweenAttacks);
		bStopMoveIfCombatRange = true;
	}
	else if(AttackAction == AA_STRAFE_LEFT)
	{ // Strafe 
		CalcStrafePosition();
		PlayStrafeLeft();
		bStopMoveIfCombatRange = false;
		StrafeFacing(Destination, Enemy);
		bStopMoveIfCombatRange = true;
	}
	else if(AttackAction == AA_STRAFE_RIGHT)
	{
		CalcStrafePosition2();
		PlayStrafeRight();
		bStopMoveIfCombatRange = false;
		StrafeFacing(Destination, Enemy);
		bStopMoveIfCombatRange = true;
	}
	else if(AttackAction == AA_JUMP)
	{
		PlayJumping();
		CalcJumpVelocity();
		WaitForLanding();
		FinishAnim();		
	}
	else
	{
		PlayWaiting();
	}

	if(InCombatRange(Enemy))
	{
		Sleep(0.05);
		Goto('Begin');
	}
	
BackFromSubState:
	GotoState('Charging', 'ResumeFromFighting');
}

//------------------------------------------------------------
//
// Pain
//
//------------------------------------------------------------
state Pain
{
	function bool CanGotoPainState()
	{ // Do not allow the actor to enter the painstate when already in pain
		return(false);
	}

	function EndState()
	{
		Super.EndState();

		EndGetUpEffect();
	}

	function StartGetUpEffect()
	{
		local vector loc;

		// Spawn semi-magically get-up effect
		DesiredColorAdjust.X = 0;
		DesiredColorAdjust.Y = 128;
		DesiredColorAdjust.Z = 51;

		loc = Location;
		loc.Z -= CollisionHeight;
		
		Spawn(class'GroundDust',,, loc,);

		LightType=LT_Steady;
		LightEffect=LE_None;
		LightBrightness=230;
		LightHue=53;
		LightSaturation=20;
		LightRadius=10;

		if(Eyes != None)
		{
			Eyes.bHidden = false;
		}

		PlaySound(ZombieGetUpSound, SLOT_Talk);
	}

	function EndGetUpEffect()
	{
		DesiredColorAdjust.X = 0;
		DesiredColorAdjust.Y = 0;
		DesiredColorAdjust.Z = 0;

		LightType=LT_None;
		LightEffect=LE_None;
		LightBrightness=0;
		LightRadius=0;

		if(Eyes != None)
		{
			Eyes.bHidden = true;
		}
	}

Begin:
	bRotateTorso = false;
	bRotateHead = false;

	GlowEyes(false);

	if(PainDelay < 0)
	{ // If PainDelay is negative, the painstate waits until the anim has completed
		FinishAnim();
	}
	else
	{ // Otherwise, just use the PainDelay
		Sleep(PainDelay);
	}

	Sleep(1 + FRand()); // Lay on the ground for a moment

	bRotateTorso = true;
	bRotateHead = true;

	StartGetUpEffect();

	PlayAnim('z_getup', 1.0, 0.1);
	FinishAnim();

	GotoState(NextStateAfterPain);
}

//------------------------------------------------------------
//
// Crucified
//
//------------------------------------------------------------
state() Crucified
{
ignores AddVelocity;

	function BeginState()
	{
		SetPhysics(PHYS_None);
	}

	function bool CanPickup(Inventory item)
	{
		return false;
	}

	function bool CanGotoPainState()
	{
		return(false);
	}

	function bool JointDamaged(int damage, pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		if (Health > 10)
		{	// Concious
			Health -= damage;
			GotoState('Crucified', 'InPain');
		}
		else
		{	// Unconcious
			Health -= damage;
			if (Health <= 0)
			{
				Health = 1;	// Insure can be killed by final blow so death event fires
				if (damage > 10)
				{	// Only a big final blow will gib
					return Super.JointDamaged(1000, EventInstigator, HitLoc, Momentum, 'gibbed', 0);
				}
				else
				{
					return true;
				}
			}
		}

		return false;
	}

	function EndState()
	{
		SetMovementPhysics();
	}

	function bool BodyPartCritical(int BodyPart)
	{	// Don't flee when arm cut off, die
		return true;
	}

InPain:
	switch(CrucifiedAnim)
	{
		case 'CrucifiedAIdle':
			PlayAnim('CrucifiedAPain', 1.0, 0.1);
			FinishAnim();
			break;
		case 'CrucifiedBIdle':
			PlayAnim('CrucifiedBPain', 1.0, 0.1);
			FinishAnim();
			break;
		case 'CrucifiedC':
			break;
	}
	if (Health > 10)
		Goto('Concious');

Unconcious:
	switch(CrucifiedAnim)
	{
		case 'CrucifiedAIdle':
			PlayAnim('CrucifiedA', 1.0, 0.4);
			break;
		case 'CrucifiedBIdle':
			PlayAnim('CrucifiedB', 1.0, 0.4);
			break;
		case 'CrucifiedC':
			break;
	}
	Goto('Idle');

Begin:
Concious:
	LoopAnim(CrucifiedAnim, 1.0, 0.1);

Idle:
}

defaultproperties
{
     LungeChance=0.200000
     DecapitateSound=Sound'CreaturesSnd.Zombie.zombiedecap01'
     GreenPuffSound=Sound'CreaturesSnd.Zombie.zombiepuff01'
     ZombieGetUpSound=Sound'CreaturesSnd.Zombie.zombiegetup01'
     FightOrFlight=1.000000
     FightOrDefend=1.000000
     HighOrLow=1.000000
     LatOrVertDodge=1.000000
     HighOrLowBlock=1.000000
     LungeRange=100.000000
     PaceRange=100.000000
     TimeBetweenAttacks=0.100000
     AcquireSound=Sound'CreaturesSnd.Zombie.zombiesee01'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Zombie.zombieambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Zombie.zombieambient02'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Zombie.zombieambient03'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Zombie.zombieattack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Zombie.zombieattack01'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Zombie.zombieattack01'
     AmbientFightSoundDelay=8.000000
     StartWeapon=Class'RuneI.ZombieClaw'
     ShadowScale=1.500000
     A_PullUp=intropullupA
     A_StepUp=pullupTest
     CarcassType=Class'RuneI.ZombieCarcass'
     MeleeRange=60.000000
     CombatRange=140.000000
     GroundSpeed=170.000000
     MaxStepHeight=30.000000
     ClassID=10
     PeripheralVision=-1.000000
     Health=80
     BodyPartHealth(1)=30
     BodyPartHealth(3)=30
     BodyPartHealth(5)=30
     HitSound1=Sound'CreaturesSnd.Zombie.zombiehit01'
     HitSound2=Sound'CreaturesSnd.Zombie.zombiehit02'
     HitSound3=Sound'CreaturesSnd.Zombie.zombiehit03'
     Die=Sound'CreaturesSnd.Zombie.zombiedeath01'
     Die2=Sound'CreaturesSnd.Zombie.zombiedeath02'
     Die3=Sound'CreaturesSnd.Zombie.zombiedeath03'
     FootStepWood(0)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepWood(1)=Sound'CreaturesSnd.Zombie.zombiefoot02'
     FootStepWood(2)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepMetal(0)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepMetal(1)=Sound'CreaturesSnd.Zombie.zombiefoot02'
     FootStepMetal(2)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepStone(0)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepStone(1)=Sound'CreaturesSnd.Zombie.zombiefoot02'
     FootStepStone(2)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepFlesh(0)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepFlesh(1)=Sound'CreaturesSnd.Zombie.zombiefoot02'
     FootStepFlesh(2)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepIce(0)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepIce(1)=Sound'CreaturesSnd.Zombie.zombiefoot02'
     FootStepIce(2)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepEarth(0)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepEarth(1)=Sound'CreaturesSnd.Zombie.zombiefoot02'
     FootStepEarth(2)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepSnow(0)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     FootStepSnow(1)=Sound'CreaturesSnd.Zombie.zombiefoot02'
     FootStepSnow(2)=Sound'CreaturesSnd.Zombie.zombiefoot01'
     CombatStyle=1.000000
     WeaponJoint=rhand
     bCanLook=True
     bHeadLookUpDouble=True
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     LFootJoint=5
     RFootJoint=9
     bLeadEnemy=True
     DrawScale=1.250000
     TransientSoundRadius=1200.000000
     CollisionHeight=51.000000
     RotationRate=(Pitch=0,Roll=0)
     SkelMesh=11
     Skeletal=SkelModel'Players.Ragnar'
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarz_armleg'
     SkelGroupSkins(2)=Texture'Players.Ragnarz_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnarz_armleg'
     SkelGroupSkins(4)=Texture'Players.Ragnarz_body'
     SkelGroupSkins(5)=Texture'Players.Ragnarz_head'
     SkelGroupSkins(6)=Texture'Players.Ragnarz_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarz_armleg'
     SkelGroupSkins(8)=Texture'Players.Ragnarz_armleg'
     SkelGroupSkins(9)=Texture'Players.Ragnarz_head'
     SkelGroupSkins(10)=Texture'Players.Ragnarz_neckgore'
     SkelGroupSkins(11)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(12)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(13)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(14)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(15)=Texture'Players.Ragnarragd_arms'
}
