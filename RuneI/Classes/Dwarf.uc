//=============================================================================
// Dwarf.
//=============================================================================
class Dwarf expands ScriptPawn;


/*
	Description:

	Types:
		Woodland Dwarf (same as generic Dwarf)
		Woodland Dwarf Small
		Woodland Dwarf Big
		Underground Dwarf1
		Underground Dwarf2
		Underground Dwarf3
		Underground Dwarf4
		Underground Dwarf5
		Underground Dwarf6
		Dark Dwarf
*/

var(Combat) bool	bThrowWeapon;
var(Combat) float	ThrowRange;
var() float	MaxBashThrust;
var() int BashDamage;

var bool bShieldBashing;
var vector bashVelocity;
var float decision;
var private int breathcounter;

var(Sounds) sound	BashSound;


//===================================================================
//
// PostBeginPlay
// 
//===================================================================

function PostBeginPlay()
{
	Super.PostBeginPlay();

	switch(Level.Game.Difficulty)
	{
	case 0: // Easy
		BashDamage = Default.BashDamage * 0.5;
		break;
	case 2: // Hard
		BashDamage = Default.BashDamage * 1.5;
		break;
	}
}

//------------------------------------------------
//
// AttitudeToCreature
//
//------------------------------------------------
function eAttitude AttitudeToCreature(Pawn Other)
{
	if (Other.IsA('Goblin'))
		return ATTITUDE_Hate;
	else
		return Super.AttitudeToCreature(Other);
}


//================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//================================================
function bool CanPickup(Inventory item)
{
	if (Health <= 0)
		return false;

	if (item.IsA('Weapon') && (BodyPartHealth[BODYPART_RARM1] > 0) && (Weapon == None))
	{
		return (item.IsA('axe') || item.IsA('hammer') || item.IsA('Sword') || item.IsA('Torch'));
	}
	else if (item.IsA('Shield') && (BodyPartHealth[BODYPART_LARM1] > 0) && (Shield == None))
	{
		return item.IsA('Shield');
	}
	return(false);
}


//================================================
//
// InAttackRange
//
//================================================
function bool InAttackRange(Actor Other)
{
	local float range;

	if (Pawn(Other) == None)
		return false;

	range = VSize(Location-Other.Location);

	if (range < CollisionRadius + Other.CollisionRadius + MeleeRange)
		return true;

	if (bLungeAttack && FRand()<0.1 && range < LungeRange)
		return true;

	if (bThrowWeapon && Weapon!=None && Pawn(Other).Health<20 && range<ThrowRange)
		return true;

	return false;
}


//------------------------------------------------
//
// Breath
//
//------------------------------------------------
function Breath()
{
	local int joint;
	local vector l;

	if (++breathcounter > 1)
	{
		breathcounter = 0;
		OpenMouth(0.5, 0.5);

		if (HeadRegion.Zone.bWaterZone)
		{
			// Spawn Bubbles
			joint = JointNamed('jaw');
			if (joint != 0)
			{
				l = GetJointPos(joint);
				if(FRand() < 0.3)
				{
					Spawn(class'BubbleSystemOneShot',,, l,);
				}
			}
		}
		else
		{
			PlaySound(BreathSound, SLOT_Interface,,,, 1.0 + FRand()*0.2-0.1);
		}
	}
	else
	{
		OpenMouth(0.0, 0.3);
	}
}


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
		case BODYPART_TORSO:
			SkelGroupSkins[1] = Texture'creatures.dwarfw_bodypain';
			SkelGroupSkins[4] = Texture'creatures.dwarfw_bodypain';
			SkelGroupSkins[7] = Texture'creatures.dwarfw_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[2]  = Texture'creatures.dwarfw_bodypain';
			SkelGroupSkins[12] = Texture'creatures.dwarfw_facepain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[11] = Texture'creatures.dwarfw_armpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[3] = Texture'creatures.dwarfw_armpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[10] = Texture'creatures.dwarfw_legpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[9] = Texture'creatures.dwarfw_legpain';
			break;
	}
	return None;
}

//================================================
//
// BodyPartForJoint
//
// Returns the body part a joint is associated with
//================================================
function int BodyPartForJoint(int joint)
{
	switch(joint)
	{
		case 2: case 3:	case 4: case 5:		return BODYPART_LLEG1;
		case 6: case 7:	case 8: case 9:		return BODYPART_RLEG1;
		case 17:							return BODYPART_HEAD;
		case 20: case 21: case 22:			return BODYPART_LARM1;
		case 26: case 27: case 28:			return BODYPART_RARM1;
		case 11:							return BODYPART_TORSO;
		default:							return BODYPART_BODY;
	}
}

//================================================
//
// BodyPartForPolyGroup
//
//================================================
function int BodyPartForPolyGroup(int polygroup)
{
	switch(polygroup)
	{
		case 1: case 4: case 7:
		case 5: case 6:	case 8:	return BODYPART_TORSO;
		case 2: case 12:		return BODYPART_HEAD;
		case 3:					return BODYPART_RARM1;
		case 11:				return BODYPART_LARM1;
		case 9:					return BODYPART_RLEG1;
		case 10:				return BODYPART_LLEG1;
		default:				return BODYPART_BODY;
	}
}


//================================================
//
// BodyPartSeverable
//
//================================================
function bool BodyPartSeverable(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LARM1:
		case BODYPART_RARM1:
		case BODYPART_LLEG1:
		case BODYPART_RLEG1:
		case BODYPART_HEAD:
			return true;
	}
	return false;
}


//================================================
//
// BodyPartCritical
//
//================================================
function bool BodyPartCritical(int BodyPart)
{
	return (BodyPart==BODYPART_LLEG1 || BodyPart==BODYPART_RLEG1 || BodyPart==BODYPART_HEAD);
}


//============================================================
//
// ApplyGoreCap
//
//============================================================
function ApplyGoreCap(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LARM1:
			SkelGroupSkins[6] = Texture'runefx.gore_bone';
			SkelGroupFlags[6] = SkelGroupFlags[6] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'runefx.gore_bone';
			SkelGroupFlags[5] = SkelGroupFlags[5] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[8] = Texture'runefx.w_neckgore';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
	}
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
		case BODYPART_LLEG1:
		case BODYPART_RLEG1:
			//TODO: Don't sever legs
			break;
		case BODYPART_LARM1:
			return class'WoodDwarfLArm';
			break;
		case BODYPART_RARM1:
			return class'WoodDwarfRArm';
			break;
		case BODYPART_HEAD:
			return class'WoodDwarfAHead';
			break;
	}

	return None;
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
		case BODYPART_LLEG1:
			joint = JointNamed('lhip');
			pos = GetJointPos(joint);
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.Velocity = -Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			part = Spawn(class'BloodSpurt', self,, pos, Rotation);
			if(part != None)
			{
				AttachActorToJoint(part, joint);
			}
			break;
		case BODYPART_RLEG1:
			joint = JointNamed('rhip');
			pos = GetJointPos(joint);
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.Velocity = -Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			part = Spawn(class'BloodSpurt', self,, pos, Rotation);
			if(part != None)
			{
				AttachActorToJoint(part, joint);
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
			part = Spawn(class'BloodSpurt', self,, pos, Rotation);
			if(part != None)
			{
				AttachActorToJoint(part, joint);
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
			part = Spawn(class'BloodSpurt', self,, pos, Rotation);
			if(part != None)
			{
				AttachActorToJoint(part, joint);
			}
			break;
		case BODYPART_HEAD:
			joint = JointNamed('head');
			pos = GetJointPos(joint);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.Velocity = 0.75 * (momentum / Mass) + vect(0, 0, 300);
				part.GotoState('Drop');
			}
			part = Spawn(class'BloodSpurt', self,, pos, Rotation);
			if(part != None)
			{
				AttachActorToJoint(part, joint);
			}
			break;
	}
}

//================================================
//
// JointDamaged
//
//================================================
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local vector vel;
	local bool rtn;
	if((DamageType == 'thrownweaponblunt' && FRand() < 0.4) 
		|| (DamageType == 'blunt' && Damage > 30 && FRand() < 0.5))
	{
		vel = Momentum/Mass;
		vel.Z = 50;
		Velocity = vel;
		SetPhysics(PHYS_Falling);

		GotoState('KnockedDown');
	}
	rtn = Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
	return rtn;
}



//-----------------------------------------------------------------------------
// Animation functions
//-----------------------------------------------------------------------------
function PlayWaiting(optional float tween)
{
	LoopAnim  ('idleA',    RandRange(0.8, 1.2), tween);
}
function PlayMoving(optional float tween)
{
	if (bHurrying)
	{
		LoopAnim  ('runA',     1.0, tween);
	}
	else
	{
		if (Weapon==None)						LoopAnim  ('walk',     1.0, tween);
		else if (Weapon.IsA('Torch'))			LoopAnim  ('walktorch',1.0, tween);
		else									LoopAnim  ('walk',     1.0, tween);
	}
}
function PlayStrafeLeft(optional float tween) { LoopAnim  ('strafeleft',	1.0, tween);	}
function PlayStrafeRight(optional float tween){ LoopAnim  ('straferight',	1.0, tween);	}
function PlayBackup(optional float tween)	  { LoopAnim  ('backupA',		1.0, tween);	}
function PlayJumping(optional float tween)    { PlayAnim  ('jump',		1.0, tween);	}
function PlayHuntStop(optional float tween)   { LoopAnim  ('idleA',		1.0, tween);	}
function PlayTurning(optional float tween)
{
												PlayAnim  ('runA',		1.0, tween);
}
function PlayAttack1(optional float tween)	{ PlayAnim('attackA',	1.0, tween);	}
function PlayAttack2(optional float tween)	{ PlayAnim('attackB',	1.0, tween);	}
function PlayAttack3(optional float tween)	{ PlayAnim('attackC',	1.0, tween);	}

function PlayCower(optional float tween)      { LoopAnim  ('cower',		1.0, tween);   }
function PlayThrowing(optional float tween)	  { PlayAnim  ('throwB',   1.0, tween); }
function PlayTaunting(optional float tween)   { PlayAnim  ('pain',      1.0, tween);   }
function PlayInAir(optional float tween)
{
	LoopAnim  ('fallingA',	1.0, tween);
}
function LongFall()
{
	if (AnimSequence != 'fallingC')
		LoopAnim  ('fallingC',	1.0, 0.1);
}
function PlayLanding(optional float tween)
{
	if (AnimSequence == 'fallingC')
		PlayAnim('landingC', 1.0, 0.1);
	else if (AnimSequence == 'fallingB')
		PlayAnim('landingB', 1.0, 0.1);
	else
		PlayAnim('landingA', 1.0, 0.1);
}

function PlayDodgeLeft(optional float tween)  { PlayAnim  ('runA',   1.0, tween);   }
function PlayDodgeRight(optional float tween) { PlayAnim  ('runA',   1.0, tween);   }
function PlayDodgeForward(optional float tween){PlayAnim  ('runA',   1.0, tween);   }
function PlayDodgeBack(optional float tween)  { PlayAnim  ('runA',   1.0, tween);   }
function PlayDodgeBackflip(optional float tween){PlayAnim ('jump',   1.0, tween);   }
function PlayDodgeDuck(optional float tween)  { PlayAnim  ('duck',   1.0, tween);   }
function PlayBlockHigh(optional float tween)  { LoopAnim  ('duck',   1.0, tween);   }
function PlayBlockLow(optional float tween)   { LoopAnim  ('block',  1.0, tween);   }

function PlayFrontHit(float tweentime){}
function PlayHeadHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);   }
function PlayBodyHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);   }
function PlayLArmHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);   }
function PlayRArmHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);   }
function PlayLLegHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);   }
function PlayRLegHit(optional float tween)    { PlayAnim  ('damage',   1.0, tween);   }
function PlayDrowning(optional float tween)   { LoopAnim  ('drown',  1.0, tween);	}

function PlayBackDeath(name DamageType)       { PlayAnim  ('deathf', 1.0, 0.1);		}
function PlayLeftDeath(name DamageType)       { PlayAnim  ('deathl', 1.0, 0.1);		}
function PlayRightDeath(name DamageType)      { PlayAnim  ('deathr', 1.0, 0.1);		}
function PlayHeadDeath(name DamageType)       { PlayAnim  ('deathf', 1.0, 0.1);		}
function PlayDeath(name DamageType)			  {	PlayAnim  ('deatha', 1.0, 0.1);		}
function PlayDrownDeath(name DamageType)      { PlayAnim  ('drown_death', 1.0, 0.1);}
function PlaySkewerDeath(name DamageType)	  { PlayAnim  ('deaths', 1.0, 0.1);		}

// Tween functions
function TweenToWaiting(float time)
{
	TweenAnim ('idleA',          time);
}
function TweenToMoving(float time)
{
	if (bHurrying)
	{
		TweenAnim ('runA',   time);
	}
	else
	{
		if (Weapon==None)						TweenAnim ('walk',     time);
		else if (Weapon.IsA('Torch'))			TweenAnim ('walktorch',time);
		else									TweenAnim ('walk',     time);
	}
}
function TweenToTurning(float time)           {	TweenAnim ('runA',    time);         }
function TweenToJumping(float time)           {	TweenAnim ('jump',    time);         }
function TweenToHuntStop(float time)          { TweenAnim ('idleA',   time);         }
function TweenToMeleeHigh(float time)
{
												TweenAnim ('attackA', time);
}
function TweenToMeleeLow(float time)
{
												TweenAnim ('attackA', time);
}
function TweenToThrowing(float time)          { TweenAnim ('throwA',  time);         }

//------------------------------------------------
//
// DoStow(notify)
//
// Creates a new weapon for the Dwarf (if he has already thrown his weapon)
//------------------------------------------------

function DoStow()
{
	local Weapon w;

	w = Spawn(StartWeapon, self,, Location);
	w.Touch(self);
}

//------------------------------------------------
//
// DoThrow (notify)
//
// Throws actor attached to weapon joint at
// Enemy or OrderObject
//------------------------------------------------
function DoThrow()
{
	local actor throwitem;
	local int traj;
	local vector throwloc;
	local vector dest;

	if (Enemy!=None)
		OrderObject = Enemy;
	
	throwloc = GetJointPos(JointNamed(WeaponJoint));
	throwitem = DetachActorFromJoint(JointNamed(WeaponJoint));
	if (throwitem != None && OrderObject != None)
	{
		if(throwItem.IsA('inventory'))
			DeleteInventory(Inventory(throwItem));

		traj = ThrowTrajectory;
		dest = OrderObject.Location + OrderObject.Velocity * 0.1; // Lead the enemy a bit with the throw
		// Throw the item
		throwitem.SetPhysics(PHYS_Falling);
//			throwitem.SetLocation(throwloc);	// More accurate this way for some reason
		throwitem.Acceleration = vect(0,0,0);
		throwitem.Velocity = CalcArcVelocity(traj, throwloc, dest);
		throwitem.GotoState('Throw');

		throwitem.SetOwner(self);

		if(Weapon == throwitem)
		{
			Weapon = None;
		}
	}
}

//-----------------------------------------------------------------------------
// Sound Functions
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// States
//-----------------------------------------------------------------------------

//================================================
//
// KnockedDown
//
//================================================
State KnockedDown
{
	ignores EnemyAcquired, SeePlayer, HearNoise;

Begin:
	PlayAnim('deatha', 1.0, 0.1);	// Fall down
	FinishAnim();

	Sleep(0.5);	// Stun Time
	WaitForLanding();

GettingUp:
	PlayAnim('getup', 1.0, 0.7);
	FinishAnim();
	GotoState('TacticalDecision');
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
		LookAt(Enemy);
		bHurrying = true;
		UpdateMovementSpeed();
		bAvoidLedges=true;
		SetTimer(0.1, true);
		AttackAction = AA_LUNGE;
		bStopMoveIfCombatRange = true;
	}

	function EndState()
	{
		Super.WeaponDeactivate();
		bAvoidLedges=false;
		SetTimer(0, false);
		if (Weapon!=None)
			Weapon.FinishAttack();
		LookAt(None);
		bStopMoveIfCombatRange = false;
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function Bump(actor Other)
	{
		local vector thrust;

		if (bShieldBashing)
		{
			if (Pawn(Other)!=None)
			{
				bashVelocity = Velocity;
				Velocity.Z = 5;
				thrust = (Velocity * 5 * Mass + Other.Velocity*Other.Mass)/(Mass+Other.Mass);
				if (VSize(thrust) > MaxBashThrust)
					thrust = Normal(thrust)*MaxBashThrust;
				Pawn(Other).AddVelocity(thrust);

				// Do bash damage if velocity > some amount				
				Other.JointDamaged(BashDamage, self, Other.Location, thrust, 'blunt', 0);

				//TODO: If velocity > some amount, knock enemy down

				// throw back, need to use timer because bump zeros velocity upon returning
				SpeechTime = 0.1;
			}

			bShieldBashing = false;	// Don't bash again
		}
	}

	function SpeechTimer()
	{
		SetPhysics(PHYS_Falling);
		Velocity = -bashVelocity*0.2;
	}

	function PickStrafeDestination()
	{		
		local vector V;
		local rotator R;
		local vector temp;
		
		V = Location - Enemy.Location;
		R = rotator(V);
		
		if (AttackAction == AA_STRAFE_LEFT)
			R.Yaw += 2000;
		else
			R.Yaw -= 2000;

		// Strafe using the enemy's XY location, but the viking's location ground plane		
		temp = Enemy.Location;
		temp.Z = Location.Z;

		Destination = temp + vector(R) * CombatRange;
	}
	
	function PickDestinationBackup()
	{
		local vector ToEnemy;

		ToEnemy = Normal(Enemy.Location - Location);
		Destination = Enemy.Location - ToEnemy * CombatRange;

	}

	// Determine AttackAction based upon enemy movement and position
	function Timer()
	{
		GetEnemyProximity();

		LastAction = AttackAction;

		if(Weapon != None && InMeleeRange(Enemy) || (EnemyMovement == MOVE_CLOSER && EnemyDist < MeleeRange * 2.5))
		{
			if (Shield != None && FRand()<0.1)
			{
				AttackAction = AA_BLOCK;
			}
			else if (Health < Default.Health*0.5)
			{
				AttackAction = AA_BACKUP;
			}
			else if (EnemyIncidence == INC_LEFT)
			{	// Swing left
				AttackAction = AA_ATTACKMELEE2;
			}
			else if (EnemyIncidence == INC_RIGHT)
			{
				AttackAction = AA_ATTACKMELEE3;
			}
			else if (FRand() < 0.2)
			{
				AttackAction = AA_ATTACKMELEE1;
			}
			else if (FRand() < 0.5)
			{
				AttackAction = AA_ATTACKMELEE2;
			}
			else
			{
				AttackAction = AA_ATTACKMELEE2;
			}
		}
		else if(Weapon == None && StartWeapon != None)
		{ // Grab a new weapon
			AttackAction = AA_RETRIEVE_WEAPON;
		}
		else if ((EnemyMovement == MOVE_STRAFE_LEFT || EnemyMovement == MOVE_STRAFE_RIGHT) &&
			!InRange(Enemy, MeleeRange * 3) && (FRand() < 0.9))
		{
			if(EnemyMovement == MOVE_STRAFE_LEFT)
			{
				AttackAction = AA_STRAFE_LEFT;
			}
			else
			{
				AttackAction = AA_STRAFE_RIGHT;
			}
		}
		else if(InRange(Enemy, MeleeRange * 5) && (FRand() < 0.6))
		{
			AttackAction = AA_STRAFE_LEFT;
		}
		else if(EnemyMovement == MOVE_STANDING && FRand() < 0.3)
		{
			if (!InRange(Enemy, MeleeRange) && FRand() < 0.19452) // Carefully tweaked value -cjr
				AttackAction = AA_LUNGE;
			else
				AttackAction = AA_WAIT;
		}
		else if(Weapon != None && bThrowWeapon && EnemyMovement == MOVE_FARTHER && FRand() < 0.7)
		{
			AttackAction = AA_THROW;
		}
		else
		{
			AttackAction = AA_WAIT;
		}
	}

	//===============================================================
	//
	// CalcLunge
	//
	// Calculates a lunge for the Dwarf
	//===============================================================

	function CalcLunge()
	{
		local vector dest;

		if(Enemy == None)
			return;

		dest = Enemy.Location;
		AddVelocity(CalcArcVelocity(4000, Location, dest));
	}

Begin:
	if(debugstates) SLog(name@"Fighting");
	Acceleration = vect(0,0,0);

Fight:
	if ( !ValidEnemy() )
		Goto('Finished');

	// Turn to face enemy
	if (NeedToTurn(Enemy.Location))
	{
		DesiredRotation.Yaw = rotator(Enemy.Location-Location).Yaw;
	}

	switch(AttackAction)
	{
	case AA_WAIT:
		PlayWaiting(0.1);
		Sleep(0.2);
		break;

	case AA_LUNGE:
		bStopMoveIfCombatRange = false;

		TweenAnim('shieldbash', 0.3);
bashturn:
		DesiredRotation = rotator(Enemy.Location-Location);

		if(Level.Game.Difficulty == 0) // Easy mode
			Sleep(0.75);
		else if(Level.Game.Difficulty == 1) // Medium mode
			Sleep(0.5);
		else // Hard mode
			Sleep(0.25);

		if (IsAnimating())
			Goto('bashturn');

		bShieldBashing = true;
		switch(Rand(4))
		{
			case 0:
				PlayAnim('AttackA', 1.0, 0.1);
				break;
			case 1:
				PlayAnim('AttackB', 1.0, 0.1);
				break;
			case 2:
				PlayAnim('AttackC', 1.0, 0.1);
				break;
			case 3:	// Normal lunge
				PlayAnim('shieldbash', 1.0, 0.1);
				Sleep(0.28);
				PlaySound(BashSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
				break;
		}
		CalcLunge();
		FinishAnim();
		WaitForLanding();
		Sleep(TimeBetweenAttacks);
		bShieldBashing = false;
		bStopMoveIfCombatRange = true;
		break;

	case AA_STRAFE_LEFT:
		bHurrying = false;
		UpdateMovementSpeed();
		PickStrafeDestination();
		PlayStrafeLeft(0.1);
		StrafeFacing(Destination, Enemy);
		bHurrying = true;
		UpdateMovementSpeed();
		break;

	case AA_STRAFE_RIGHT:
		bHurrying = false;
		UpdateMovementSpeed();
		PickStrafeDestination();
		PlayStrafeRight(0.1);
		StrafeFacing(Destination, Enemy);
		bHurrying = true;
		UpdateMovementSpeed();
		break;

	case AA_CHARGE:
		PlayMoving(0.1);
		MoveTo(Enemy.Location - VecToEnemy * MeleeRange, MovementSpeed);
		break;

	case AA_BACKUP:
		bHurrying = false;
		UpdateMovementSpeed();
		DesiredRotation = rotator(Enemy.Location-Location);
		PlayBackup(0.1);
		PickDestinationBackup();
		StrafeFacing(Destination, Enemy);
		bHurrying = true;
		UpdateMovementSpeed();
		PlayWaiting();
		break;

	case AA_ATTACKMELEE1:
		PlayAttack1(0.1);
		FinishAnim();
		Sleep(TimeBetweenAttacks);
		break;

	case AA_ATTACKMELEE2:
		PlayAttack2(0.1);
		FinishAnim();
		Sleep(TimeBetweenAttacks);
		break;

	case AA_ATTACKMELEE3:
		PlayAttack3(0.1);
		FinishAnim();
		Sleep(TimeBetweenAttacks);
		break;

	case AA_THROW:
		DesiredRotation = rotator(Enemy.Location-Location);
		Sleep(0.1);
		PlayThrowing();
		FinishAnim();
		break;

	case AA_BLOCK:
		ActivateShield(true);
		PlayBlockHigh(0.1);
		Sleep(RandRange(0.2, 1));
		FinishAnim();
		ActivateShield(false);
		break;

	case AA_RETRIEVE_WEAPON:
		PlayAnim('GetWeapon', 1.0, 0.1);
		FinishAnim();
		break;
	}

	if (InRange(Enemy, CombatRange))
	{
		Sleep(0.05);
		Goto('Begin');
	}

Finished:
	GotoState('Charging', 'ResumeFromFighting');
}


//================================================
//
// Statue
//
//================================================
State() Statue
{
ignores HearNoise, EnemyAcquired, Bump;

	function CreatureStatue()
	{
		SkelGroupSkins[0] = texture'statues.sb_body_stone';
		SkelGroupSkins[1] = texture'statues.sb_armleg_stone';
		SkelGroupSkins[2] = texture'statues.sb_body_stone';
		SkelGroupSkins[3] = texture'statues.sb_armleg_stone';
		SkelGroupSkins[4] = texture'statues.sb_body_stone';
		SkelGroupSkins[5] = texture'statues.sb_body_stone';
		SkelGroupSkins[6] = texture'statues.sb_body_stone';
		SkelGroupSkins[7] = texture'statues.sb_body_stone';
		SkelGroupSkins[8] = texture'statues.sb_armleg_stone';
		SkelGroupSkins[9] = texture'statues.sb_body_stone';
		SkelGroupSkins[10] = texture'statues.sb_armleg_stone';
		SkelGroupSkins[11] = texture'statues.sb_armleg_stone';
		SkelGroupSkins[12] = texture'statues.sb_armleg_stone';
		SkelGroupSkins[13] = texture'statues.sb_body_stone';
		SkelGroupSkins[14] = texture'statues.sb_body_stone';
		SkelGroupSkins[15] = texture'statues.sb_body_stone';
	}
}

defaultproperties
{
     bThrowWeapon=True
     ThrowRange=140.000000
     MaxBashThrust=750.000000
     BashDamage=10
     BashSound=Sound'CreaturesSnd.Dwarves.attack12'
     bLungeAttack=True
     FightOrFlight=1.000000
     FightOrDefend=0.200000
     HighOrLow=0.500000
     LatOrVertDodge=0.500000
     HighOrLowBlock=0.500000
     BlockChance=1.000000
     LungeRange=140.000000
     ThrowTrajectory=2500
     BreathSound=Sound'CreaturesSnd.Dwarves.breath06'
     AcquireSound=Sound'CreaturesSnd.Dwarves.word23'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Dwarves.word36'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Dwarves.word04'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Dwarves.word27'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Dwarves.attack14'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Dwarves.attack13'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Dwarves.attack15'
     AmbientWaitSoundDelay=12.000000
     AmbientFightSoundDelay=6.000000
     StartWeapon=Class'RuneI.DwarfWorkSword'
     StartShield=Class'RuneI.DwarfWoodShield'
     MinStopWait=0.400000
     MaxStopWait=1.000000
     ShadowScale=2.000000
     A_StepUp=pullupB
     bCanStrafe=True
     bCanGrabEdges=True
     MeleeRange=40.000000
     CombatRange=200.000000
     GroundSpeed=240.000000
     AccelRate=1000.000000
     JumpZ=400.000000
     MaxStepHeight=30.000000
     WalkingSpeed=160.000000
     ClassID=2
     Health=130
     BodyPartHealth(1)=100
     BodyPartHealth(3)=100
     BodyPartHealth(5)=100
     BodyPartHealth(6)=100
     BodyPartHealth(8)=100
     UnderWaterTime=2.000000
     Intelligence=BRAINS_HUMAN
     HitSound1=Sound'CreaturesSnd.Dwarves.hit02'
     HitSound2=Sound'CreaturesSnd.Dwarves.word26'
     HitSound3=Sound'CreaturesSnd.Dwarves.hit07'
     Die=Sound'CreaturesSnd.Dwarves.death09'
     Die2=Sound'CreaturesSnd.Dwarves.death10'
     Die3=Sound'CreaturesSnd.Dwarves.death12'
     FootStepWood(0)=None
     FootStepWood(1)=None
     FootStepWood(2)=None
     FootStepMetal(0)=Sound'FootstepsSnd.Metal.footmetal10'
     FootStepMetal(1)=Sound'FootstepsSnd.Metal.footmetal11'
     FootStepMetal(2)=Sound'FootstepsSnd.Metal.footmetal12'
     FootStepStone(0)=Sound'FootstepsSnd.Earth.footgravel13'
     FootStepStone(1)=Sound'FootstepsSnd.Earth.footgravel12'
     FootStepStone(2)=Sound'FootstepsSnd.Earth.footgravel13'
     FootStepIce(0)=Sound'FootstepsSnd.Ice.footice04'
     FootStepIce(1)=Sound'FootstepsSnd.Ice.footice05'
     FootStepIce(2)=Sound'FootstepsSnd.Ice.footice06'
     FootStepEarth(0)=Sound'FootstepsSnd.Earth.footgravel03'
     FootStepEarth(1)=Sound'FootstepsSnd.Earth.footgravel05'
     FootStepEarth(2)=Sound'FootstepsSnd.Earth.footgravel06'
     FootStepSnow(0)=Sound'FootstepsSnd.Snow.footsnow10'
     FootStepSnow(1)=Sound'FootstepsSnd.Snow.footsnow11'
     FootStepSnow(2)=Sound'FootstepsSnd.Snow.footsnow12'
     WeaponJoint=attach_hand
     ShieldJoint=attach_shielda
     bCanLook=True
     bHeadLookUpDouble=True
     MaxMouthRot=5000
     MaxMouthRotRate=65535
     DeathRadius=40.000000
     DeathHeight=8.000000
     bLeadEnemy=True
     AnimSequence=idleA
     TransientSoundRadius=1200.000000
     CollisionRadius=35.000000
     CollisionHeight=33.000000
     Mass=250.000000
     Buoyancy=200.000000
     RotationRate=(Pitch=0,Roll=0)
     Skeletal=SkelModel'creatures.Dwarf'
}
