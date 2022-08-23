//=============================================================================
// Sark.
//=============================================================================
class Sark expands ScriptPawn
	abstract;


const DEFAULT_TWEEN = 0.15;


var(AI) class<Weapon>	StartStowWeapon;		// Startup stow weapon
var(Sounds) sound		PaceSound;
var(Sounds) sound		JumpSound;

var string EnemyStr;
var Weapon StowWeapon;
var private int breathcounter;
var name PreUninterrupedState;

var	bool bDisintegrating;

var vector JumpDestination;

var vector DebugJumpApex;
var vector DebugJumpLand;

//================================================
//
// Startup
//
//================================================
auto state Startup
{	
ignores EnemyAcquired, SeePlayer, HearNoise;

	function bool CanGotoPainState()
	{
		return(false);
	}

	function JumpOutOfBlood()
	{
		local vector vel;

		// If a Sark starts in Loki Blood, make it immediate jump out
		vel = 200 * vector(Rotation);
		vel.Z = 625;
		AddVelocity(vel);		
		SetPhysics(PHYS_Falling);
	}

Begin:
	if(debugstates) slog(name@"Starting");
	if (!bCanFly && bFallAtStartup)
		SetPhysics(PHYS_Falling);
	SetHome();
	SpawnStartInventory();
	TouchSurroundingObjects();
	AfterSpawningInventory();

	if(Region.Zone.bLokiBloodZone)
	{		
		JumpOutOfBlood();
		PlayJumping(DEFAULT_TWEEN);
		WaitForLanding();
		
		// Randomly play "I kick ass!" Taunt after the Sark has exited Loki Blood
		if(FRand() < 0.5)
		{
			// TODO:  Play Hellish scream here
			PlayAnim('s3_taunt', 1.0, 0.1);
			FinishAnim();
		}		
	}	

	GotoState('Startup', 'Restart');
}

//===================================================================
//
// PainTimer
//
//===================================================================

function PainTimer()
{
	if((Health < 0) || (Level.NetMode == NM_Client))
		return;
		
	if(FootRegion.Zone.bPainZone && FootRegion.Zone.bLokiBloodZone)
	{ // Sark is standing in a LokiBlood pool, don't let him take any damage from it
		return;
	}

	Super.PainTimer();
}

//------------------------------------------------
//
// AttitudeToCreature
//
//------------------------------------------------
function eAttitude AttitudeToCreature(Pawn Other)
{
	if (Other.IsA('Goblin') || Other.IsA('Viking'))
		return ATTITUDE_Hate;
	else
		return Super.AttitudeToCreature(Other);
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
		return (item.IsA('axe') || item.IsA('hammer') || item.IsA('Sword') || item.IsA('Torch')
			|| item.IsA('SarkClaw'));
	}
	else if (item.IsA('Shield') && (BodyPartHealth[BODYPART_LARM1] > 0) && (Shield == None))
	{
		return item.IsA('Shield');
	}
	return(false);
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
			return false;
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
		LoopAnim('sark_idle', RandRange(0.8, 1.2), 0.2);
	}
}

//============================================================
//
// PlayMoving
//
//============================================================

function PlayMoving(optional float tween)
{
//	LoopAnim('Sark_Run', 1.0, DEFAULT_TWEEN);

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
function PlayFlip(optional float tween)    { PlayAnim ('sark_flip', 1.0, tween);   }

function PlayMeleeHigh(optional float tween)
{
	if(Weapon != None)
	{
		PlayAnim(Weapon.A_AttackStandA, 1.3, tween);
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
	PlayAnim('MOV_ALL_jump1_AA0S', 1.0, tween);
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

function PlayDeath(name DamageType)           
{ 
	PlayAnim('sark_DeathV', 0.5, DEFAULT_TWEEN);

/*
	if(DamageType == 'thrownweaponsever')
		PlayAnim('deathb', 1.0, DEFAULT_TWEEN);  
	else
		PlayAnim('DTH_ALL_death1_AN0N', 1.0, DEFAULT_TWEEN);  
*/
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
				
		if(EnemyMovement == MOVE_STRAFE_LEFT && FRand() < 0.7 && CheckStrafeLeft())
		{
			AttackAction = AA_STRAFE_LEFT;
		}
		else if(EnemyMovement == MOVE_STRAFE_RIGHT && FRand() < 0.7 && CheckStrafeRight())
		{
			AttackAction = AA_STRAFE_RIGHT;
		}
		else if(FRand() < 0.2 && Physics == PHYS_Walking && CheckJumpLocation())
		{
			AttackAction = AA_JUMP;
		}
		else if(EnemyMovement == MOVE_STANDING && FRand() < 0.85)
		{
			AttackAction = AA_LUNGE;
		}		
	 	else if(FRand() < 0.75)
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
		local vector arcVel;

		traj = 70 * 65536 / 360;

		// JumpDestination is calculated in CheckJumpLocation
		arcVel = CalcArcVelocity(traj, Location, JumpDestination);

		AddVelocity(arcVel);
	}

	function bool CheckJumpLocation()
	{		
		local vector start, end;
		local vector extent;
		local vector HitLocation, HitNormal;

		if(Enemy == None)
			return(false);

		extent.X = CollisionRadius;
		extent.Y = CollisionRadius;
		extent.Z = CollisionHeight * 0.5;

		JumpDestination = Enemy.Location - Location;
		JumpDestination.Z = 0;
		JumpDestination = Enemy.Location + Normal(JumpDestination) * 200;

		start = Location;
		end = ((JumpDestination + start) / 2) + vect(0, 0, 280);

		DebugJumpApex = end;
		DebugJumpLand = JumpDestination;

		// Trace to check if the jump is valid
		if(Trace(HitLocation, HitNormal, end, start, true, extent) == None)
		{ // Nothing on the way up, check going down
			start = end;
			end = JumpDestination;

			if(Trace(HitLocation, HitNormal, end, start, true, extent) == None)
			{ // Nothing on the way back down, check to make sure that the Sark will land on valid ground
				start = JumpDestination;
				end = JumpDestination - vect(0, 0, 100);

				if(Trace(HitLocation, HitNormal, end, start, false) == None)
				{ // Not going to land on anything, so don't do the jump
					return(false);
				}

				// Otherwise, the jump is good!
				return(true);
			}
			DebugJumpLand = HitLocation;
		}

		return(false);
	}

	function RotateSark()
	{
		local rotator rot;
		rot = Rotation;
		rot.Yaw = Rotation.Yaw + 32768;
		SetRotation(rot);
	}

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
		
Begin:
	if(Enemy == None)
		Goto('BackFromSubState');

	Acceleration = vect(0,0,0);

	// Turn to face enemy
	DesiredRotation.Yaw = rotator(Enemy.Location-Location).Yaw;

	if(Weapon.MeleeType == MELEE_NON_STOW && StowWeapon != None)
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
	if ( !ValidEnemy() )
		Goto('BackFromSubState');

	GetEnemyProximity();
	
	// Attack if close enough
	if(Weapon != None && InMeleeRange(Enemy) || (EnemyMovement == MOVE_CLOSER && EnemyDist < MeleeRange * 2.5))
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
			PlayAnim(Weapon.A_AttackA, 1.3, 0.1);
			Sleep(0.1);
			WeaponActivate();
			Weapon.EnableSwipeTrail();
			FinishAnim();

			if(Weapon.A_AttackB != 'None' && FRand() < 0.5)
			{
//				ClearSwipeArray();
				PlayAnim(Weapon.A_AttackB, 1.3, 0.01);
				if(Enemy != None)
					TurnToward(Enemy);
				FinishAnim();

				// B-Return
				WeaponDeactivate();

				if(Weapon.A_AttackBReturn != 'None')
				{
					PlayAnim(Weapon.A_AttackBReturn, 1.3, 0.1);
					FinishAnim();
				}
			}
			else
			{ // A-Return
				WeaponDeactivate();

				if(Weapon.A_AttackAReturn != 'None')
				{
					PlayAnim(Weapon.A_AttackAReturn, 1.3, 0.1);
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
	{ // Strafe - Position is calculated in Timer, when the strafe is chosen
		PlayStrafeLeft();
		bStopMoveIfCombatRange = false;
		StrafeFacing(Destination, Enemy);
		bStopMoveIfCombatRange = true;
	}
	else if(AttackAction == AA_STRAFE_RIGHT)
	{ // Strafe - Position is calculated in Timer, when the strafe is chosen
		PlayStrafeRight();
		bStopMoveIfCombatRange = false;
		StrafeFacing(Destination, Enemy);
		bStopMoveIfCombatRange = true;
	}
	else if(AttackAction == AA_JUMP)
	{
		PlayFlip(0.1);
		Sleep(0.4); // Sleep for a bit before making the leap
		PlaySound(JumpSound);
		CalcJumpVelocity();
		WaitForLanding();

		RotateSark();
		PlayAnim('sark_land', 1.0, 0.0);
		if(Enemy != None)
			TurnToward(Enemy);
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

//============================================================
//
// Died
//
//============================================================

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local actor eyes;

	eyes = DetachActorFromJoint(JointNamed('head'));
	if(eyes != None)
		eyes.Destroy();

	Super.Died(Killer, damageType, HitLocation);
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
	}

	function FallBack()
	{
		local vector vel;
		local vector X, Y, Z;

		GetAxes(Rotation, X, Y, Z);

		vel = -200 * X + vect(0, 0, 75);
		AddVelocity(vel);
		SetPhysics(PHYS_Falling);
	}

	function Timer()
	{
		FallBack();
	}
	
	function Disintegrate()
	{		
		local int i;
		local vector v;
		local rotator r;
		local actor puff;
		
		bDisintegrating = true;
		LifeSpan = 1.0;
		ShadowScale = 0; // Turn off any shadow on the creature

/*		
		for(i = 0; i < Rand(5); i++)
		{
			v = VRand();
			r = Rotator(v);
			puff = Spawn(class'ZombieBreath', self,, Location, r);			
			puff.Velocity = v * 75;
			puff.SetPhysics(PHYS_Projectile);			
		}
*/
	}
	
begin:
	PlayDeath('');
	Sleep(0.4);
	SetTimer(0.25, true);
	Disintegrate();
}


function Bump(Actor Other)
{
	if(Other.IsA('Keg') || Other.IsA('Stool') || Other.IsA('Bucket'))
	{ // Vikings will smash kegs that are in the way
		UseActor = Other;

		if(FRand() < 0.2 || Other.Location.Z < Location.Z || Weapon == None)
		{
			PlayUninterruptedAnim(UseActor.GetUseAnim());
		}
		else
		{
			PlayUninterruptedAnim(Weapon.A_AttackA);
		}
	}
	else
	{
		Super.Bump(Other);
	}
}

simulated function Debug(Canvas canvas, int mode)
{
	local vector offset;
	
	Super.Debug(canvas, mode);
	
	Canvas.DrawText("Sark:");
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

	offset = DebugJumpApex;
	Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 0, 255, 0);
	Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 0, 255, 0);	
	Canvas.DrawLine3D(offset + vect(0, 0, 10), offset+ vect(0, 0, -10), 0, 255, 0);

	offset = DebugJumpLand;
	Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 255, 255, 0);
	Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 255, 255, 0);	
	Canvas.DrawLine3D(offset + vect(0, 0, 10), offset+ vect(0, 0, -10), 255, 255, 0);
}

defaultproperties
{
     bPaceAttack=True
     FightOrFlight=1.000000
     FightOrDefend=1.000000
     HighOrLow=0.500000
     HighOrLowBlock=0.500000
     BlockChance=1.000000
     LungeRange=100.000000
     PaceRange=100.000000
     ShadowScale=2.000000
     A_PullUp=intropullupA
     A_StepUp=pullupTest
     bCanStrafe=True
     bCanGrabEdges=True
     MeleeRange=40.000000
     CombatRange=175.000000
     GroundSpeed=250.000000
     AccelRate=1000.000000
     JumpZ=425.000000
     MaxStepHeight=30.000000
     AirControl=0.100000
     WalkingSpeed=250.000000
     ClassID=6
     Health=250
     BodyPartHealth(1)=250
     BodyPartHealth(3)=250
     BodyPartHealth(5)=250
     Intelligence=BRAINS_HUMAN
     FootStepWood(0)=Sound'CreaturesSnd.Sark.sarkfootstep01'
     FootStepWood(1)=Sound'CreaturesSnd.Sark.sarkfootstep02'
     FootStepWood(2)=Sound'CreaturesSnd.Sark.sarkfootstep03'
     FootStepMetal(0)=Sound'CreaturesSnd.Sark.sarkfootstep01'
     FootStepMetal(1)=Sound'CreaturesSnd.Sark.sarkfootstep02'
     FootStepMetal(2)=Sound'CreaturesSnd.Sark.sarkfootstep03'
     FootStepStone(0)=Sound'CreaturesSnd.Sark.sarkfootstep01'
     FootStepStone(1)=Sound'CreaturesSnd.Sark.sarkfootstep02'
     FootStepStone(2)=Sound'CreaturesSnd.Sark.sarkfootstep03'
     FootStepFlesh(0)=Sound'CreaturesSnd.Sark.sarkfootstep01'
     FootStepFlesh(1)=Sound'CreaturesSnd.Sark.sarkfootstep02'
     FootStepFlesh(2)=Sound'CreaturesSnd.Sark.sarkfootstep03'
     FootStepIce(0)=Sound'CreaturesSnd.Sark.sarkfootstep01'
     FootStepIce(1)=Sound'CreaturesSnd.Sark.sarkfootstep02'
     FootStepIce(2)=Sound'CreaturesSnd.Sark.sarkfootstep03'
     FootStepEarth(0)=Sound'CreaturesSnd.Sark.sarkfootstep01'
     FootStepEarth(1)=Sound'CreaturesSnd.Sark.sarkfootstep02'
     FootStepEarth(2)=Sound'CreaturesSnd.Sark.sarkfootstep03'
     FootStepSnow(0)=Sound'CreaturesSnd.Sark.sarkfootstep01'
     FootStepSnow(1)=Sound'CreaturesSnd.Sark.sarkfootstep02'
     FootStepSnow(2)=Sound'CreaturesSnd.Sark.sarkfootstep03'
     WeaponJoint=attach_hand
     ShieldJoint=attach_shielda
     StabJoint=spineb
     bCanLook=True
     bHeadLookUpDouble=True
     LFootJoint=5
     RFootJoint=9
     bLeadEnemy=True
     DrawScale=1.500000
     CollisionRadius=27.000000
     CollisionHeight=63.000000
     Buoyancy=400.000000
     RotationRate=(Pitch=0,Roll=0)
     Skeletal=SkelModel'Players.Ragnar'
}
