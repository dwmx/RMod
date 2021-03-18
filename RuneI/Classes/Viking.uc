//=============================================================================
// Viking.
//=============================================================================
class Viking expands ScriptPawn
	abstract;

const DEFAULT_TWEEN = 0.15;

var string EnemyStr;

var Weapon StowWeapon;

var(AI) class<Weapon>	StartStowWeapon;		// Startup stow weapon

var(Sounds) sound		PaceSound;
var private int breathcounter;

var name PreUninterrupedState;

var() name CrucifiedAnim;


//------------------------------------------------
//
// AttitudeToCreature
//
//------------------------------------------------
function eAttitude AttitudeToCreature(Pawn Other)
{
	if (Other.IsA('Sark') || Other.IsA('Goblin'))
		return ATTITUDE_Hate;
	else
		return Super.AttitudeToCreature(Other);
}

auto State Startup
{
	//============================================================
	//
	// SpawnStartInventory
	//
	//============================================================
	
	function SpawnStartInventory()
	{
		Super.SpawnStartInventory();

		bStopMoveIfCombatRange = true;
		
		if(StartStowWeapon != None && StartStowWeapon.Default.MeleeType != MELEE_NON_STOW)
		{
			if(StartWeapon != None)
			{
				if(StartWeapon.Default.MeleeType == StartStowWeapon.Default.MeleeType)
				{ // The start weapon and stow weapon are of the same class, don't spawn the stow weapon
					return;
				}
			}
			StowWeapon = Spawn(StartStowWeapon, self);
		}
	}
	
	//============================================================
	//
	// TouchSurroundingObjects
	//
	//============================================================

	function TouchSurroundingObjects()
	{
		if(StowWeapon != None)
		{
			AddInventory(StowWeapon);

			switch(StowWeapon.MeleeType)
			{
			case MELEE_SWORD:
				AttachActorToJoint(StowWeapon, JointNamed('attatch_sword'));
				break;
			case MELEE_AXE:
				AttachActorToJoint(StowWeapon, JointNamed('attach_axe'));
				break;
			case MELEE_AXE:
				AttachActorToJoint(StowWeapon, JointNamed('attach_hammer'));
				break;
			default:
				// Unknown or non-stow item
				StowWeapon.Destroy();
			}

			StowWeapon.GotoState('Stow');
		}

		Super.TouchSurroundingObjects();
	}
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

//============================================================
//
// BodyPartForJoint
//
// Returns the body part a joint is associated with
//============================================================
function int BodyPartForJoint(int joint)
{
	switch(joint)
	{
		case 24:					return BODYPART_LARM1;
		case 31:					return BODYPART_RARM1;
		case 6:  case 7:			return BODYPART_RLEG1;
		case 2:  case 3:			return BODYPART_LLEG1;
		case 17:					return BODYPART_HEAD;
		case 11:					return BODYPART_TORSO;
		default:					return BODYPART_BODY;
	}
}

//============================================================
//
// BodyPartForPolyGroup
//
//============================================================
function int BodyPartForPolyGroup(int polygroup)
{
	return BODYPART_BODY;
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
		case BODYPART_LARM1:
		case BODYPART_RARM1:
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
			case 11: case 2: case 6:
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

//============================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//============================================================
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

//============================================================
// Animation functions
//============================================================

function PlayWaiting(optional float tween)
{
	if(Weapon != None)
	{
		LoopAnim(Weapon.A_Idle, RandRange(0.8, 1.2), 0.2);
	}
	else
	{
		LoopAnim('neutral_idle', RandRange(0.8, 1.2), 0.2);
	}
}

//============================================================
//
// PlayMoving
//
//============================================================

function PlayMoving(optional float tween)
{
	if (Weapon == None)
		LoopAnim('MOV_ALL_run1_AA0N', 1.0, DEFAULT_TWEEN);
	else									
		LoopAnim(Weapon.A_Forward, 1.0, DEFAULT_TWEEN);
}

//============================================================
//
// PlayStrafeLeft
//
//============================================================

function PlayStrafeLeft(optional float tween)
{
	if (Weapon == None)
		LoopAnim('MOV_ALL_lstrafe1_AN0N', 1.0, DEFAULT_TWEEN);
	else									
		LoopAnim(Weapon.A_StrafeLeft, 1.0, DEFAULT_TWEEN);
}

//============================================================
//
// PlayStrafeRight
//
//============================================================

function PlayStrafeRight(optional float tween)
{
	if (Weapon == None)
		LoopAnim('MOV_ALL_rstrafe1_AN0N', 1.0, DEFAULT_TWEEN);
	else									
		LoopAnim(Weapon.A_StrafeRight, 1.0, DEFAULT_TWEEN);
}

//============================================================
//
// PlayBackup
//
//============================================================

function PlayBackup(optional float tween)
{
	if (Weapon == None)
		LoopAnim('MOV_ALL_runback1_AA0S', 1.0, DEFAULT_TWEEN);
	else									
		LoopAnim(Weapon.A_Backward, 1.0, DEFAULT_TWEEN);
}

function PlayJumping(optional float tween)    { PlayAnim  ('MOV_ALL_jump1_AA0S',      1.0, tween);   }

function PlayMeleeHigh(optional float tween)
{
	if(Weapon != None)
	{
		PlayAnim(Weapon.A_AttackA, 1.0, tween);
	}
}
function PlayMeleeLow(optional float tween)
{
	if(Weapon==None)							PlayAnim  ('swipe',     1.0, tween);
	else										PlayAnim  ('attackb',   1.0, tween);
}

function PlayTurning(optional float tween)
{
	if(Weapon != None)
		LoopAnim(Weapon.A_Idle, 1.0, tween);
	else
		LoopAnim('neutral_idle', 1.0, tween);
}

function PlayThrowing(optional float tween)   { PlayAnim('throwA',    1.0, tween); }
function PlayTaunting(optional float tween)   { PlayAnim('s3_taunt', 1.0, tween); }
function PlayInAir(optional float tween) 
{
	local name anim;

	if(Weapon != None && Weapon.A_Jump != '')
		anim = Weapon.A_Jump;
	else
		anim = 'MOV_ALL_jump1_AA0S';
	
	PlayAnim(anim, 1.0, 0.1);
}

function PlayBlockHigh(optional float tween)  { LoopAnim  ('blocklow',  1.0, tween);   }
function PlayBlockLow(optional float tween)   { LoopAnim  ('blocklow',  1.0, tween);   }

// Pains
function PlayFrontHit(float tweentime)        
{
	if(Weapon == None)
	{ // Neutral anims
		PlayAnim('n_painFront', 1.0, 0.1);
	}
	else
	{ // Weapon-specific
		PlayAnim(Weapon.A_PainFront, 1.0, 0.1);
	}
}

function PlayBackHit(float tweentime)
{
	if(Weapon == None)
	{ // Neutral anims
		PlayAnim('n_painBack', 1.0, 0.1);
	}
	else
	{ // Weapon-specific
		PlayAnim(Weapon.A_PainBack, 1.0, 0.1);
	}
}

function PlayLeftHit(float tweentime)         { PlayAnim('S1_painLeft', 1.0, 0.08); }
function PlayRightHit(float tweentime)         { PlayAnim('S1_painRight', 1.0, 0.08); }

function PlaySkewerDeath(name DamageType)	  { PlayAnim  ('deathb', 1.0, DEFAULT_TWEEN);	}
function PlayDeath(name DamageType)           
{ 
	local name anim;

	if(DamageType == 'decapitated')
		PlayAnim('DeathH', 1.0, DEFAULT_TWEEN);
	if(DamageType == 'fire')
		PlayAnim('DeathF', 1.0, DEFAULT_TWEEN);
	else
	{ // Normal death, randomly choose one
		anim = 'DTH_ALL_death1_AN0N';

		switch(RandRange(0, 5))
		{
		case 0:
			anim = 'DTH_ALL_death1_AN0N';
			break;
		case 1:
			anim = 'DeathH';
			break;
		case 2:
			anim = 'DeathL';
			break;
		case 3:
			anim = 'DeathB';
			break;
		case 4:
			anim = 'DeathKnockback';
			break;
		default:
			anim = 'DTH_ALL_death1_AN0N';
			break;
		}

		PlayAnim(anim, 1.0, DEFAULT_TWEEN);
	}
}

function PlayBackDeath(name DamageType)		
{
	local name anim;

	if(FRand() < 0.25)
		anim = 'DeathH';
	else
		anim  = 'DeathFront';

	PlayAnim(anim, 1.0, 0.1);
	if(AnimProxy != None)
		AnimProxy.PlayAnim(anim, 1.0, 0.1);	
}

// Tween functions
function TweenToWaiting(float time)
{
	if(Weapon != None)
		TweenAnim(Weapon.A_Idle, time);
	else
		LoopAnim('neutral_idle', time);
}

function TweenToMoving(float time)
{
	if(Weapon != None)
		TweenAnim(Weapon.A_Forward, time);
	else									
		TweenAnim('MOV_ALL_run1_AA0N', time);
}

function TweenToTurning(float time)
{ // TODO:  Need turning anims
	if(Weapon != None)
		TweenAnim(Weapon.A_Idle, time);
	else
		TweenAnim('neutral_idle', time);
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
// DoStow
//
// DoStow Notify
//===================================================================

function DoStow()
{
	if(Weapon != None && Weapon.MeleeType == MELEE_NON_STOW)
	{ // Drop the weapon
		DropWeapon();
		Weapon = None;
		return;
	}

	Weapon = StowWeapon;
	
	switch(Weapon.MeleeType)
	{
	case MELEE_SWORD:
		DetachActorFromJoint(JointNamed('attatch_sword'));
		break;
	case MELEE_AXE:
		DetachActorFromJoint(JointNamed('attach_axe'));
		break;
	case MELEE_AXE:
		DetachActorFromJoint(JointNamed('attach_hammer'));
		break;
	case MELEE_NON_STOW:
		DropWeapon();
		break;
	}
	
	AttachActorToJoint(Weapon, JointNamed(WeaponJoint));
	Weapon.GotoState('Active');
	StowWeapon = None;
}

//===================================================================
//					States
//===================================================================

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
		SetTimer(0, false);
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

	function bool CheckStrafeLeft()
	{ // Checks if the left strafe move is valid (not going to strafe into a wall)
		local vector HitLocation, HitNormal;
		local vector extent, end;

		extent.X = CollisionRadius;
		extent.Y = CollisionRadius;
		extent.Z = CollisionHeight * 0.5;

		CalcStrafePosition();

		end = Normal(Destination - Location) * 75;

		if(Trace(HitLocation, HitNormal, end, Location, true, extent) == None)
			return(true); // Nothing in the way
		else
			return(false);
	}

	function bool CheckStrafeRight()
	{ // Checks if the right strafe move is valid (not going to strafe into a wall)
		local vector HitLocation, HitNormal;
		local vector extent, end;

		extent.X = CollisionRadius;
		extent.Y = CollisionRadius;
		extent.Z = CollisionHeight * 0.5;

		CalcStrafePosition2();

		end = Normal(Destination - Location) * 75;

		if(Trace(HitLocation, HitNormal, end, Location, true, extent) == None)
			return(true); // Nothing in the way
		else
			return(false);
	}

	// Determine AttackAction based upon enemy movement and position
	function Timer()
	{
		GetEnemyProximity();

		LastAction = AttackAction;
				
		if(EnemyMovement == MOVE_STRAFE_LEFT && FRand() < 0.8 && CheckStrafeLeft())
		{
			AttackAction = AA_STRAFE_LEFT;
		}
		else if(EnemyMovement == MOVE_STRAFE_RIGHT && FRand() < 0.8 && CheckStrafeRight())
		{
			AttackAction = AA_STRAFE_RIGHT;
		}
		else if((EnemyMovement == MOVE_STANDING && FRand() < 0.65) || FRand() < 0.2)
		{
			AttackAction = AA_LUNGE;
		}		
	 	else if(FRand() < 0.9)
	 	{
	 		if(FRand() < 0.5 && LastAction != AA_STRAFE_RIGHT || LastAction == AA_STRAFE_LEFT
				&& CheckStrafeLeft())
	 		{
	 			AttackAction = AA_STRAFE_LEFT;
	 		}
	 		else if(LastAction != AA_STRAFE_LEFT || LastAction == AA_STRAFE_RIGHT && CheckStrafeRight())
	 		{
	 			AttackAction = AA_STRAFE_RIGHT;
	 		}
			else
			{
				AttackAction = AA_WAIT;
			}
	 	}
		else
		{
			AttackAction = AA_WAIT;
		}
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
		
		if(Enemy == None)
		{
			Destination = Location;
			return;
		}

		V = Location - Enemy.Location;
		R = rotator(V);
		
		R.Yaw += 2000;

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

		if(Enemy == None)
		{
			Destination = Location;
			return;
		}
		
		V = Location - Enemy.Location;
		R = rotator(V);
		
		R.Yaw -= 2000;

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
	if(Enemy == None)
		Goto('BackFromSubState');

	Acceleration = vect(0,0,0);

	// Turn to face enemy
	DesiredRotation.Yaw = rotator(Enemy.Location-Location).Yaw;

	if(Weapon != None && Weapon.MeleeType == MELEE_NON_STOW && StowWeapon != None)
	{ // The creature is carrying a non-stow (probably a torch), but 
		// has a weapon stowed, ditch the non-stow in favor of the stowed weapon
		PlayAnim('IDL_ALL_drop1_AA0S', 1.0, DEFAULT_TWEEN);
		FinishAnim();
	}

	// If the creature has a weapon stowed, unsheath it before attacking
	if(Weapon == None && StowWeapon != None)
	{ // Unsheath the stow weapon
		switch(StowWeapon.MeleeType)
		{
		case MELEE_SWORD:
			PlayAnim('IDL_ALL_sstow1_AA0S', 1.0, DEFAULT_TWEEN);
			break;
		case MELEE_AXE:
			PlayAnim('IDL_ALL_xstow1_AA0S', 1.0, DEFAULT_TWEEN);
			break;
		case MELEE_HAMMER:
			PlayAnim('IDL_ALL_hstow1_AA0S', 1.0, DEFAULT_TWEEN);
			break;
		}
		
		FinishAnim();	
	}

//	PlayWaiting();

Fight:
	if(!ValidEnemy())
		Goto('BackFromSubState');

	GetEnemyProximity();
	
	// Attack if close enough
	if(Weapon != None && (InMeleeRange(Enemy) || (EnemyMovement == MOVE_CLOSER && EnemyDist < MeleeRange * 2.5)))
	{
		if(LastAction != AA_LUNGE && FRand() < 0.2)
		{ // Random chance that the creature will dodge
			PlayMoving();
			if(FRand() < 0.7)
			{ // Either jump to the side, or back up
				// Back up
				bStopMoveIfCombatRange = false;
				ActivateShield(true);
				PlayBackup();
				StrafeFacing(Location - vector(Rotation) * (CombatRange - EnemyDist), Enemy);
				ActivateShield(false);
				bStopMoveIfCombatRange = true;
			}
			else
			{ // Dodge to the side
				bStopMoveIfCombatRange = false;
				ActivateShield(true);
				PlayStrafeRight();
				StrafeFacing(Location + vector(Rotation + rot(0, 16384, 0)) * CombatRange, Enemy);
				ActivateShield(false);
				bStopMoveIfCombatRange = true;				
			}
		}		
		else
		{
			WeaponActivate();
			Weapon.EnableSwipeTrail();

			PlayAnim(Weapon.A_AttackStandA, 1.0, 0.1);
			FinishAnim();

			if(Weapon.A_AttackStandB != 'None' && FRand() < 0.5)
			{
				ClearSwipeArray();
				PlayAnim(Weapon.A_AttackStandB, 1.0, 0.01);
				if(Enemy != None)
					TurnToward(Enemy);
				FinishAnim();

				// B-Return
				WeaponDeactivate();

				if(Weapon.A_AttackStandBReturn != 'None')
				{
					PlayAnim(Weapon.A_AttackStandBReturn, 1.0, 0.1);
					FinishAnim();
				}
			}
			else
			{ // A-Return
				WeaponDeactivate();

				if(Weapon.A_AttackStandAReturn != 'None')
				{
					PlayAnim(Weapon.A_AttackStandAReturn, 1.0, 0.1);
					FinishAnim();
				}
			}

			Weapon.DisableSwipeTrail();
		}
		
		Sleep(TimeBetweenAttacks);
	}
	else if(AttackAction == AA_LUNGE)
	{ // Random lunge
		PlayMoving();
		bStopMoveIfCombatRange = false;
		MoveTo(Enemy.Location - VecToEnemy * MeleeRange, MovementSpeed);
		bStopMoveIfCombatRange = true;
	}
	else if(AttackAction == AA_STRAFE_LEFT)
	{ // Strafe - Destination is calculated from Timer, when the strafe is initial decided upon
		PlayStrafeLeft();
		bStopMoveIfCombatRange = false;
		StrafeFacing(Destination, Enemy);
		bStopMoveIfCombatRange = true;
	}
	else if(AttackAction == AA_STRAFE_RIGHT)
	{ // Strafe - Destination is calculated from Timer, when the strafe is initial decided upon
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


//================================================
//
// Dying
//
//================================================

state Dying
{
	function BeginState()
	{
		local int joint;
		local vector X, Y, Z;

		// Drop any stowed weapons
		if(StowWeapon != None)
		{		
			switch(StowWeapon.MeleeType)
			{
			case MELEE_SWORD:
				joint = JointNamed('attatch_sword');
				break;
			case MELEE_AXE:
				joint = JointNamed('attach_axe');
				break;
			case MELEE_AXE:
				joint = JointNamed('attach_hammer');
				break;
			default:
				// Unknown or non-stow item
				return;
			}

			DetachActorFromJoint(joint);
				
			GetAxes(Rotation, X, Y, Z);
			StowWeapon.DropFrom(GetJointPos(joint));
		
			StowWeapon.SetPhysics(PHYS_Falling);
			StowWeapon.Velocity = Y * 100 + X * 75;
			StowWeapon.Velocity.Z = 50;
			
			StowWeapon.GotoState('Drop');
			StowWeapon.DisableSwipeTrail();

			StowWeapon = None; // Remove the StowWeapon from the actor
		}

		Super.BeginState();
	}
}

/*
function eAttitude AttitudeToCreature(Pawn Other)
{
	return(ATTITUDE_Hate);
}
*/

function AttackBuddy()
{
	local Pawn V;
	
	foreach AllActors(class'Pawn', V)
	{
		if(V != self && V.Health > 0 && !V.IsA('PlayerPawn'))
		{
			SetEnemy(V);
			return;
		}
	}
}

function Bump(Actor Other)
{
	if(Other.IsA('Keg') || Other.IsA('Stool') || Other.IsA('Bucket'))
	{ // Vikings will smash kegs that are in the way
		UseActor = Other;

		if(Other.Location.Z < Location.Z || Weapon == None)
		{
			PlayUninterruptedAnim(UseActor.GetUseAnim());
		}
	}
/*
	else if(Other.IsA('DecorationRune') && DecorationRune(Other).bDestroyable && Weapon != None)
	{ // Other things that the viking should just swipe at
		Weapon.StartAttack();
		Weapon.EnableSwipeTrail();
		PlayUninterruptedAnim(Weapon.A_AttackA);
	}
*/
	else
	{
		Super.Bump(Other);
	}
}

simulated function Debug(Canvas canvas, int mode)
{
	local vector offset;
	
	Super.Debug(canvas, mode);
	
	Canvas.DrawText("	DarkViking:");
	Canvas.CurY -= 8;
	Canvas.DrawText("	PreUninterrupt: " $ PreUninterrupedState);
	Canvas.CurY -= 8;
	Canvas.DrawText("	NextOrder/Tag: " $ NextState@NextLabel);
	Canvas.CurY -= 8;
	Canvas.DrawText("	Enemy String: " $ EnemyStr);
	EnemyStr = "None";

	Canvas.CurY -= 8;
	if(EnemyFacing == FACE_FRONT)
	{
		Canvas.DrawText("	Enemy Facing:  FRONT");		
	}
	else if(EnemyFacing == FACE_BACK)
	{
		Canvas.DrawText("	Enemy Facing:  BACK");		
	}
	else
	{
		Canvas.DrawText("	Enemy Facing:  SIDE");		
	}
	
	Canvas.CurY -= 8;
	if(EnemyVertical == VERT_ABOVE)
	{
		Canvas.DrawText("	Enemy Vertical:  ABOVE");		
	}
	else if(EnemyVertical == VERT_BELOW)
	{
		Canvas.DrawText("	Enemy Vertical:  BELOW");		
	}
	else
	{
		Canvas.DrawText("	Enemy Vertical:  LEVEL");		
	}

	Canvas.CurY -= 8;
	if(EnemyMovement == MOVE_CLOSER)
	{
		Canvas.DrawText("	Enemy Movement:  CLOSER");		
	}
	else if(EnemyMovement == MOVE_FARTHER)
	{
		Canvas.DrawText("	Enemy Movement:  FARTHER");		
	}
	else if(EnemyMovement == MOVE_STRAFE_LEFT)
	{
		Canvas.DrawText("	Enemy Movement:  STRAFE_LEFT");		
	}
	else if(EnemyMovement == MOVE_STRAFE_RIGHT)
	{
		Canvas.DrawText("	Enemy Movement:  STRAFE_RIGHT");		
	}
	else
	{
		Canvas.DrawText("	Enemy Movement:  STANDING");				
	}
	
	Canvas.CurY -= 8;
	Canvas.DrawText("   AttackAction:  " $ AttackAction);
	
	offset = Destination;
	Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 255, 0, 0);
	Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 255, 0, 0);	
	Canvas.DrawLine3D(offset + vect(0, 0, 10), offset+ vect(0, 0, -10), 255, 0, 0);

}

defaultproperties
{
     StartStowWeapon=Class'RuneI.VikingBroadSword'
     CrucifiedAnim=CrucifiedAidle
     FightOrFlight=1.000000
     FightOrDefend=1.000000
     HighOrLow=0.500000
     HighOrLowBlock=0.500000
     BlockChance=1.000000
     LungeRange=100.000000
     PaceRange=100.000000
     TimeBetweenAttacks=0.100000
     StartShield=Class'RuneI.DarkShield'
     ShadowScale=1.500000
     A_PullUp=intropullupA
     A_StepUp=pullupTest
     CarcassType=Class'RuneI.CarcassDarkViking'
     bCanStrafe=True
     bCanGrabEdges=True
     MeleeRange=60.000000
     CombatRange=180.000000
     GroundSpeed=200.000000
     AccelRate=1000.000000
     JumpZ=425.000000
     MaxStepHeight=30.000000
     AirControl=0.100000
     WalkingSpeed=200.000000
     ClassID=8
     BodyPartHealth(1)=90
     BodyPartHealth(3)=90
     BodyPartHealth(5)=80
     Intelligence=BRAINS_HUMAN
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
     StabJoint=spineb
     bCanLook=True
     bHeadLookUpDouble=True
     LFootJoint=5
     RFootJoint=9
     bLeadEnemy=True
     CollisionRadius=24.000000
     CollisionHeight=46.000000
     Buoyancy=400.000000
     RotationRate=(Pitch=0,Roll=0)
     SkelMesh=2
     Skeletal=SkelModel'Players.Ragnar'
}
