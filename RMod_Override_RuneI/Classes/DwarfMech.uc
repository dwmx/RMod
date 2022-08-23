//=============================================================================
// DwarfMech.
//=============================================================================
class DwarfMech expands ScriptPawn;

/*
	Description: Once in range, he plants himself and does blade attacks when you
	are in range, and rocket attacks when you are further away.

	Combat strategy:
		use blunt damage to disarm blades
		use sever damage to take off arms
		then kill with anything
*/

var float AttackRange;		// Longest range for ranged attacks
var bool bPlanted;

var(Sounds) Sound	PlantSound;				// SLOT_Interact
var(Sounds) Sound	UnplantSound;			// SLOT_Interact
var(Sounds) Sound	UpDownSound;			// SLOT_Talk
var(Sounds) Sound	FireSound;				// SLOT_Misc
var(Sounds) Sound	ExplodeSound;			// SLOT_None
var(Sounds) Sound	GrindSoundLOOP;			// SLOT_Ambient
var(Sounds) Sound	AliveSoundLOOP;			// SLOT_Ambient
var(Sounds) Sound	DyingSpinSound;			// SLOT_None

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Make upper body wobble when hit
//	JointFlags[5] = JointFlags[5] | JOINT_FLAG_ACCELERATIVE;	// moved to SCM file
}

simulated event GetAccelJointParms(int joint, out float DampFactor, out float RotThreshold)
{
	DampFactor = 0.035;
	RotThreshold = 8192;
}

simulated event float GetAccelJointMagnitude(int joint)
{
	return 9000;
}

function ApplyPainToJoint(int joint, vector Momentum)
{
	ApplyJointForce(5, Momentum*0.5);
}

//================================================
//
// AfterSpawningInventory
//
// Used to spawn additional chained weapon
//================================================
function AfterSpawningInventory()
{
	local Weapon W;
	W = Spawn(class'mechblade');
	W.SetOwner(self);
	AttachActorToJoint(W, 23);	// Attach to left wrist
	InvisibleWeapon(Weapon).ChainOnWeapon(W);
	W.GotoState('Active');
}

function DropLeftWeapon()
{
	if (Weapon != None && InvisibleWeapon(Weapon) != None)
	{
		if (InvisibleWeapon(Weapon).ChainedWeapon == None)
		{
			DetachActorFromJoint(23);
			Weapon.Destroy();
			Weapon = None;
		}
		else
		{
			DetachActorFromJoint(23);
			InvisibleWeapon(Weapon).ChainedWeapon.Destroy();
			InvisibleWeapon(Weapon).ChainedWeapon = None;
		}
	}
}

function DropRightWeapon()
{
	local InvisibleWeapon removing;

	if (Weapon != None && InvisibleWeapon(Weapon) != None)
	{
		removing = InvisibleWeapon(Weapon);
		DetachActorFromJoint(JointNamed(WeaponJoint));
		Weapon = removing.ChainedWeapon;
		removing.ChainedWeapon = None;
		removing.Destroy();
	}
}

function SetHeadLook()
{
	bRotateHead=true;
	bRotateTorso=false;
	MaxBodyAngle.Yaw=0;
	MaxBodyAngle.Pitch=0;
	MaxHeadAngle.Yaw=32768;
	MaxHeadAngle.Pitch=0;
}

function SetTorsoLook()
{
	bRotateHead=false;
	bRotateTorso=true;
	MaxBodyAngle.Yaw=32768;
	MaxBodyAngle.Pitch=0;
	MaxHeadAngle.Yaw=0;
	MaxHeadAngle.Pitch=0;
}

//================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//================================================
function bool CanPickup(Inventory item)
{
	return item.IsA('MechBlade');
}


//================================================
//
// InAttackRange
//
//================================================
function bool InAttackRange(actor Other)
{
	local float range;

	range = VSize(Location-Other.Location);

	if (range < CollisionRadius + Other.CollisionRadius + AttackRange)
		return true;

	return false;
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
			SkelGroupSkins[3] = Texture'creatures.mechadwarfbodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[2] = Texture'creatures.mechadwarfheadpain';
			break;
		case BODYPART_MISC1:
			SkelGroupSkins[14] = Texture'creatures.mechadwarfarmlegpain';
			break;
		case BODYPART_MISC2:
			SkelGroupSkins[13] = Texture'creatures.mechadwarfarmlegpain';
			break;
	}
	return None;
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	switch(joint)
	{
		case 33:			return MATTER_METAL;	// leg
		case 29:			return MATTER_METAL;	// leg
		case 7:				return MATTER_FLESH;	// head
		case 20:			return MATTER_FLESH;	// Left Arm (flesh)
		case 10:			return MATTER_FLESH;	// Right Arm (flesh)
		case 12:			return MATTER_METAL;	// Right Arm (metal)
		case 22:			return MATTER_METAL;	// Left Arm (metal)
		case 25:			return MATTER_METAL;	// Left top blade
		case 27:			return MATTER_METAL;	// Left bottom Blade
		case 15:			return MATTER_METAL;	// Right top blade
		case 17:			return MATTER_METAL;	// Right Bottom Blade
		case 5:				return MATTER_METAL;	// torso
		default:			return MATTER_METAL;
	}
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
		case 33:			return BODYPART_LLEG1;
		case 29:			return BODYPART_RLEG1;
		case 7:				return BODYPART_HEAD;
		case 20: case 22:	return BODYPART_MISC1;	// Left Arm (flesh/metal)
		case 10: case 12:	return BODYPART_MISC2;	// Right Arm (flesh/metal)
		case 25:			return BODYPART_LARM1;	// Left top blade
		case 27:			return BODYPART_LARM2;	// Left bottom Blade
		case 15:			return BODYPART_RARM1;	// Right top blade
		case 17:			return BODYPART_RARM2;	// Right Bottom Blade
		case 5:				return BODYPART_TORSO;
		default:			return BODYPART_BODY;
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
		case 2:				return BODYPART_HEAD;
		case 14:			return BODYPART_MISC1;	// left arm
		case 13:			return BODYPART_MISC2;	// right arm
		case 9:				return BODYPART_LARM2;	// left bottom blade
		case 10:			return BODYPART_LARM1;	// left top blade
		case 7:			 	return BODYPART_RARM2;	// right bottom blade
		case 8:				return BODYPART_RARM1;	// right top blade
		case 5:	case 12:	return BODYPART_LLEG1;
		case 4:	case 11:	return BODYPART_RLEG1;
		case 3: case 6:
		case 15: case 0:	return BODYPART_TORSO;
		default:			return BODYPART_BODY;
	}
}


//============================================================
//
// LimbPassThrough
//
// Determines what damage is passed through to body
//============================================================
function int LimbPassThrough(int BodyPart, out int Blunt, out int Sever)
{
	if (BodyPart == BODYPART_BODY)	// Falling damage, etc.
		return Blunt+Sever;

	if (BodyPart == BODYPART_TORSO)
		return Blunt+Sever;

	if (BodyPart == BODYPART_HEAD)
		return Blunt+Sever;

	if (BodyPart == BODYPART_LARM1 ||
		BodyPart == BODYPART_LARM2 ||
		BodyPart == BODYPART_RARM1 ||
		BodyPart == BODYPART_RARM2)
	{	// Blades
		Sever = Blunt;
		return 0;
	}

	if (BodyPart == BODYPART_MISC1 ||
		BodyPart == BODYPART_MISC2)
	{	// Arms
		return 0;
	}

	return 0;
}


//================================================
//
// BodyPartSeverable
//
//================================================
function bool BodyPartSeverable(int BodyPart)
{
	//TODO:  do this only if blades gone?
	return (BodyPart==BODYPART_MISC1 ||
			BodyPart==BODYPART_MISC2 ||
			BodyPart==BODYPART_LARM1 ||
			BodyPart==BODYPART_LARM2 ||
			BodyPart==BODYPART_RARM1 ||
			BodyPart==BODYPART_RARM2);
}


//================================================
//
// BodyPartCritical
//
//================================================
function bool BodyPartCritical(int BodyPart)
{
	return false;
}


//================================================
//
// LimbSevered
//
//================================================
function LimbSevered(int BodyPart, vector Momentum)
{
	local int joint;
	local vector X,Y,Z;
	local class<actor> partclass;
	local actor part;
	
	Super.LimbSevered(BODYPART_BODY, Momentum);		// Disallow fleeing by passing None

	if (BodyPart == BODYPART_LARM1 || BodyPart == BODYPART_lARM2)
	{
		if (BodyPartMissing(BODYPART_LARM1) && BodyPartMissing(BODYPART_LARM2))
		{	// left blades gone, drop invisible weapon
			DropLeftWeapon();
		}
	}
	else if (BodyPart == BODYPART_RARM1 || BodyPart == BODYPART_RARM2)
	{
		if (BodyPartMissing(BODYPART_RARM1) && BodyPartMissing(BODYPART_RARM2))
		{	// right blades gone, drop invisible weapon
			DropRightWeapon();
		}
	}
	else if (BodyPart == BODYPART_MISC1 || BodyPart == BODYPART_MISC2)
	{
		if (BodyPart == BODYPART_MISC1)
		{	// left arm gone, drop weapon and hide blades
			DropLeftWeapon();
			BodyPartVisibility(BODYPART_LARM1, false);
			BodyPartVisibility(BODYPART_LARM2, false);
		}
		else if (BodyPart == BODYPART_MISC2)
		{	// right arm gone, drop weapon and hide blades
			DropRightWeapon();
			BodyPartVisibility(BODYPART_RARM1, false);
			BodyPartVisibility(BODYPART_RARM2, false);
		}

		if (BodyPartMissing(BODYPART_MISC1) && BodyPartMissing(BODYPART_MISC2))
		{	// both arms gone, flee
			if (Health > 0)
				GotoState('Fleeing');
		}
	}

	partclass = SeveredLimbClass(BodyPart);
	switch(BodyPart)
	{
		case BODYPART_LARM1:
		case BODYPART_LARM2:
			joint = JointNamed('lwrist');
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, GetJointPos(joint), Rotation);
			if(part != None)
			{
				part.Velocity = -Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;

		case BODYPART_RARM1:
		case BODYPART_RARM2:
			joint = JointNamed('rwrist');
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, GetJointPos(joint), Rotation);
			if(part != None)
			{
				part.Velocity = -Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;

		case BODYPART_MISC1:
			joint = JointNamed('lshouldb');
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, GetJointPos(joint), Rotation);
			if(part != None)
			{
				part.Velocity = -Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;
		case BODYPART_MISC2:
			joint = JointNamed('rshouldb');
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, GetJointPos(joint), Rotation);
			if(part != None)
			{
				part.Velocity = -Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
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
		case BODYPART_LARM1:
		case BODYPART_LARM2:
		case BODYPART_RARM1:
		case BODYPART_RARM2:
			return class'MechBladeArm';
		case BODYPART_MISC1:
		case BODYPART_MISC2:
			return class'MechArm';
	}
	return None;
}

//-----------------------------------------------------------------------------
// Animation functions
//-----------------------------------------------------------------------------
function PlayWaiting(optional float tween)
{
	if (bPlanted)
		LoopAnim  ('plant_idle',    1.0, tween);
	else
		LoopAnim  ('idle',    1.0, tween);
}
function PlayMoving(optional float tween)
{
	if (bHurrying)
	{
		LoopAnim  ('run',     1.0, tween);
	}
	else
	{
		if (Weapon==None)						LoopAnim  ('walk',     1.0, tween);
		else if (Weapon.IsA('Torch'))			LoopAnim  ('walk',     1.0, tween);
		else									LoopAnim  ('walk',     1.0, tween);
	}
}
function PlayJumping(optional float tween)		{ PlayAnim  ('jump',	1.0, tween);	}
function PlayHuntStop(optional float tween)		{ LoopAnim  ('idle',	1.0, tween);	}
function PlayMeleeHigh(optional float tween)	{ PlayAnim  ('attackB', 1.0, tween);	}
function PlayTurning(optional float tween)		{ PlayAnim  ('run',		1.0, tween);	}
function PlayThrowing(optional float tween)		{}
function PlayTaunting(optional float tween)		{ PlayAnim  ('pain',	1.0, tween);	}
function PlayInAir(optional float tween)		{}
function LongFall()								{}
function PlayLanding(optional float tween)		{}

function PlayHeadHit(optional float tween)		{}
function PlayBodyHit(optional float tween)		{}
function PlayLArmHit(optional float tween)		{}
function PlayRArmHit(optional float tween)		{}
function PlayLLegHit(optional float tween)		{}
function PlayRLegHit(optional float tween)		{}
function PlayDeath(name DamageType)				{ PlayAnim  ('startblowup',	1.0, 0.2);		}
function PlayFrontHit(float tweentime)			{}

// Tween functions
function TweenToWaiting(float time)
{
	if (bPlanted)
		TweenAnim ('plant_idle',	time);
	else
		TweenAnim ('idleA',			time);
}
function TweenToMoving(float time)
{
	if (bHurrying)
	{
		TweenAnim ('run',   time);
	}
	else
	{
		if (Weapon==None)						TweenAnim ('walk',     time);
		else if (Weapon.IsA('Torch'))			TweenAnim ('walktorch',time);
		else									TweenAnim ('walk',     time);
	}
}
function TweenToTurning(float time)				{	TweenAnim ('run',    time);			}
function TweenToJumping(float time)				{	TweenAnim ('jump',   time);			}
function TweenToHuntStop(float time)			{	TweenAnim ('idle',   time);			}
function TweenToMeleeHigh(float time)			{	TweenAnim ('attackB', time);			}
function TweenToThrowing(float time)			{	TweenAnim ('throwA',  time);			}

function PlayPlant()							{	PlayAnim('plant',		1.0, 0.2);	}
function PlayUnPlant()							{	PlayAnim('unplant',		1.0, 0.2);	}
function PlayPlantIdle()						{	LoopAnim('fire_idle',	1.0, 0.1);	}
function PlayPropAttack()						{	LoopAnim('prop_cycle',	1.0, 0.1);	}
function PlayClawAttack()						{	PlayAnim('attackB',		1.0, 0.1);	}
function PlayMissileAttack()					{	PlayAnim('fire_windup',	1.0, 0.2);	}
function PlayFire()								{	LoopAnim('fire_cycle',	1.0, 0.1);	}

function PlayLowAttack()						{	LoopAnim('saw_cycle',	1.0, 0.5);	}
function PlayHighAttack()						{	LoopAnim('spin_cycle',	1.0, 0.5);	}


//================================================
//
// Fighting
//
//================================================
State Fighting
{
ignores EnemyAcquired, BeginState, EndState;

/*	function EnemyNotVisible()
	{	// Out of sight, unplant and hunt
		GotoState('Fighting', 'Done');
	}*/

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function SoundNotify1()
	{
		PlaySound(PlantSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
	}

	function SoundNotify2()
	{
		PlaySound(UnplantSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
	}

Begin:
	if(debugstates) SLog(name@"Fighting");
	Acceleration = vect(0,0,0);

	// Turn towards enemy during attack
	DesiredRotation = rotator(Enemy.Location-Location);

Plant:
	PlayPlant();
	FinishAnim();
	bPlanted=true;
	LookAt(Enemy);

Planted:
	// Evaluate and goto substates

Evaluate:
	if ( !ValidEnemy() )
	{
		NextState = 'GoingHome';
		NextLabel = '';
		Goto('Done');
	}

Fight:
	//TODO: Check for existence of blades

	if (InRange(Enemy, MeleeRange))
	{	// Melee Range
		if ( PlayerPawn(Enemy)!=None )
		{	// Players
			if ( PlayerPawn(Enemy).bIsCrouching )
			{
				GotoState('FightingLow');
			}
			else
			{
				GotoState('FightingHigh');
			}
		}
		else
		{	// Creatures
			if (Enemy.Location.Z + Enemy.CollisionHeight < Location.Z + 15)
			{
				GotoState('FightingLow');
			}
			else
			{
				GotoState('FightingHigh');
			}
		}
	}
	else if (InRange(Enemy, AttackRange))
	{	// Missile Range
		GotoState('FightingRanged');
	}

	NextState = 'Charging';
	NextLabel = 'ResumeFromFighting';

Done:
	bSwingingHigh = false;
	SwipeEffectEnd();
	WeaponDeactivate();
	SetTorsoLook();
	LookAt(None);
	PlayUnplant();
	FinishAnim();
	bPlanted=false;
	GotoState(NextState, NextLabel);
}


//================================================
//
// FightingLow
//
//================================================
State FightingLow
{
	function EndState()
	{
		//TODO: Use timer to use an attack for a limited time before switching (unless damage has been inflicted)
		//LastAttack=LA_LOW1;
		AmbientSound = AliveSoundLOOP;
	}

	function BeginState()
	{
		local InvisibleWeapon W;

		W = InvisibleWeapon(Weapon);
		if (W!=None)
			W.ExtendedLength = 10;
		if (W.ChainedWeapon!=None)
			W.ChainedWeapon.ExtendedLength = 10;
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

Begin:
//	SetHeadLook();
	LookAt(None);

	// Tween into Low
	if (AnimSequence == 'high_tran')
	{
		PlaySound(UpdownSound, SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
		TweenAnim('low_tran', 0.5);
		FinishAnim();
		Sleep(0.5);

		// Cycle up
	}

	PlayLowAttack();
	AmbientSound = GrindSoundLOOP;
	SwipeEffectStart();

ContinueAttack:
	WeaponDeactivate();
	WeaponActivate();
	Sleep(0.5);

	// Evaluate exit conditions
	if (InRange(Enemy, MeleeRange))
	{
		Goto('ContinueAttack');
	}

Done:
	// Cycle down for transition to next move
	FinishAnim();
	AmbientSound = AliveSoundLOOP;
	SwipeEffectEnd();
	WeaponDeactivate();

	// Tween to idle low
	TweenAnim('low_tran', 0.5);
	FinishAnim();
	Sleep(0.5);

	GotoState('Fighting', 'Planted');

AlternateLow:	//(unused)
	// Claw attack
	SetTorsoLook();
	PlayClawAttack();
	FinishAnim();
}


//================================================
//
// FightingHigh
//
//================================================
State FightingHigh
{
	function BeginState()
	{
		local InvisibleWeapon W;

		W = InvisibleWeapon(Weapon);
		if (W!=None)
			W.ExtendedLength = 40;
		if (W.ChainedWeapon!=None)
			W.ChainedWeapon.ExtendedLength = 40;
	}

	function EndState()
	{
		AmbientSound = AliveSoundLOOP;
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

Begin:
//	SetHeadLook();
	LookAt(None);

	// Tween into high
	if (AnimSequence == 'low_tran')
	{
		PlaySound(UpdownSound, SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);

		TweenAnim('high_tran', 0.5);
		FinishAnim();
		Sleep(0.5);

		// Cycle up
	}

	PlayHighAttack();
	AmbientSound = GrindSoundLOOP;
	SwipeEffectStart();

ContinueAttack:
	WeaponDeactivate();
	WeaponActivate();
	Sleep(0.5);

	// Evaluate exit conditions
	if ((InRange(Enemy, MeleeRange)) &&
		!(PlayerPawn(Enemy)!=None && PlayerPawn(Enemy).bIsCrouching) )
	{
		Goto('ContinueAttack');
	}

Done:
	// Cycle down for transition to next move
	FinishAnim();
	AmbientSound = AliveSoundLOOP;
	SwipeEffectEnd();
	WeaponDeactivate();

	// Tween to idle high
	TweenAnim('high_tran', 0.5);
	FinishAnim();
	Sleep(0.5);

	GotoState('Fighting', 'Planted');

AlternateHigh: //(unused)
	// Propeller attack
	SetHeadLook();

	PlayHighAttack();
	//PlayPropAttack();
	Sleep(0.5);
	FinishAnim();

	if (InRange(Enemy, MeleeRange))
		Goto('Melee');
	else
	{
		PlayWaiting(0.1);
		FinishAnim();
	}
}


//================================================
//
// FightingRanged
//
//================================================
State FightingRanged
{
	
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function DoThrow()
	{
		local Projectile ball;
		local vector FireLocation;
		local bool bfired;

		//TODO: Fire out in actual direction dictated by look
		
		if (BodyPartHealth[BODYPART_MISC2] > 0)
		{	// Throw out right missile
			FireLocation = GetJointPos(JointNamed('rwrist'));
			ball = Spawn(class'MechRocket', self,,FireLocation,rotator(Normal(Enemy.Location - FireLocation)));
			ball.SetPhysics(PHYS_Projectile);
			ball.Velocity = Normal(Enemy.Location - FireLocation) * ball.Speed;
			bfired=true;
		}

		if (BodyPartHealth[BODYPART_MISC1] > 0)
		{	// Throw out left missile
			FireLocation = GetJointPos(JointNamed('lwrist'));
			ball = Spawn(class'MechRocket', self,,FireLocation,rotator(Normal(Enemy.Location - FireLocation)));
			ball.SetPhysics(PHYS_Projectile);
			ball.Velocity = Normal(Enemy.Location - FireLocation) * ball.Speed;
			bfired=true;
		}

		if (bfired)
			PlaySound(FireSound, SLOT_Misc,,,, 1.0 + FRand()*0.4-0.2);
	}

Begin:
	SetTorsoLook();
	LookAt(Enemy);

	// Tween into Low
	if (AnimSequence == 'high_tran')
	{
		TweenAnim('low_tran', 0.5);
		FinishAnim();
		Sleep(0.5);
	}

	
	PlayMissileAttack();
	FinishAnim();

ContinueAttack:
	
	if(abs(GetJointRot(JointNamed('torso')).Yaw - (rotator(Enemy.Location - Location)).Yaw) < 1000)
	{
		PlayFire();
	}
	
	FinishAnim();
	PlayPlantIdle();

	if (InRange(Enemy, AttackRange) && !InRange(Enemy, MeleeRange))
	{
		Goto('ContinueAttack');
	}

Done:
	// Cycle down for transition to next move

	// Tween to idle high
	TweenAnim('high_tran', 0.5);
	FinishAnim();
	Sleep(0.5);

	GotoState('Fighting', 'Planted');
}


//============================================================
//
// Dying
//
//============================================================
state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, Landed, EnemyAcquired;

	function BeginState()
	{
		AmbientSound = None;
		Super.BeginState();
	}

PreDeath:
	Acceleration=vect(0,0,0);
	PlaySound(DyingSpinSound,SLOT_None,,,, 1.0 + FRand()*0.2-0.1);
	FinishAnim();
	LoopAnim('blowupcycle', 1.0, 0.1);

	// Explode
	spawn(class'Explosion',,,GetJointPos(JointNamed('spinea')));
	PlaySound(ExplodeSound,,,,, 1.0 + FRand()*0.2-0.1);
	AttachActorToJoint(spawn(class'blacksmoke'), JointNamed('spinea'));

	BodyPartCollision(BODYPART_TORSO, false);
	BodyPartCollision(BODYPART_HEAD, false);
	BodyPartCollision(BODYPART_MISC1, false);
	BodyPartCollision(BODYPART_MISC2, false);
	BodyPartCollision(BODYPART_LARM2, false);
	BodyPartCollision(BODYPART_LARM1, false);
	BodyPartCollision(BODYPART_RARM2, false);
	BodyPartCollision(BODYPART_RARM1, false);

	BodyPartVisibility(BODYPART_TORSO, false);
	BodyPartVisibility(BODYPART_HEAD, false);
	BodyPartVisibility(BODYPART_MISC1, false);
	BodyPartVisibility(BODYPART_MISC2, false);
	BodyPartVisibility(BODYPART_LARM2, false);
	BodyPartVisibility(BODYPART_LARM1, false);
	BodyPartVisibility(BODYPART_RARM2, false);
	BodyPartVisibility(BODYPART_RARM1, false);
	Goto('Death');
}


simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);
	
	Canvas.DrawText("DwarfMech:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  MaxBodyAngle="$MaxBodyAngle);
	Canvas.CurY -= 8;
	
}

defaultproperties
{
     AttackRange=500.000000
     PlantSound=Sound'CreaturesSnd.Mech.mechfoot02'
     UnplantSound=Sound'CreaturesSnd.Mech.mechfoot01'
     UpDownSound=Sound'CreaturesSnd.Mech.mechservo04'
     FireSound=Sound'CreaturesSnd.Mech.mechfire01'
     ExplodeSound=Sound'OtherSnd.Explosions.explosion06'
     GrindSoundLOOP=Sound'CreaturesSnd.Mech.mechspin02L'
     AliveSoundLOOP=Sound'CreaturesSnd.Mech.mechalive01L'
     DyingSpinSound=Sound'CreaturesSnd.Mech.mechspin'
     FightOrFlight=1.000000
     FightOrDefend=1.000000
     AcquireSound=Sound'CreaturesSnd.Mech.mechsee01'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Mech.mechmove09'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Mech.mechcock04'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Mech.mechservo06'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Mech.mechmove02'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Mech.mechcock02'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Mech.mechmove08'
     AmbientWaitSoundDelay=3.000000
     AmbientFightSoundDelay=3.000000
     StartWeapon=Class'RuneI.MechBlade'
     bWaitLook=False
     bBurnable=False
     A_StepUp=pullup
     CarcassType=Class'RuneI.CarcassMechDwarf'
     bAlignToFloor=True
     MeleeRange=175.000000
     GroundSpeed=150.000000
     AccelRate=1000.000000
     WalkingSpeed=122.000000
     ClassID=2
     PeripheralVision=-1.000000
     Health=150
     BodyPartHealth(1)=50
     BodyPartHealth(2)=50
     BodyPartHealth(3)=50
     BodyPartHealth(4)=50
     BodyPartHealth(5)=50
     BodyPartHealth(11)=75
     BodyPartHealth(12)=75
     UnderWaterTime=2.000000
     Intelligence=BRAINS_HUMAN
     HitSound1=Sound'CreaturesSnd.Mech.mechhit02'
     HitSound2=Sound'CreaturesSnd.Mech.mechhit01'
     HitSound3=Sound'CreaturesSnd.Mech.mechhit02'
     Die=Sound'OtherSnd.Explosions.explosion08'
     Die2=Sound'OtherSnd.Explosions.explosion08'
     Die3=Sound'OtherSnd.Explosions.explosion08'
     FootstepVolume=1.400000
     FootStepWood(0)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepWood(1)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepWood(2)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepMetal(0)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepMetal(1)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepMetal(2)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepStone(0)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepStone(1)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepStone(2)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepFlesh(0)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepFlesh(1)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepFlesh(2)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepIce(0)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepIce(1)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepIce(2)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepEarth(0)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepEarth(1)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepEarth(2)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepSnow(0)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepSnow(1)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepSnow(2)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepWater(0)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepWater(1)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepWater(2)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepMud(0)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepMud(1)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepMud(2)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepLava(0)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepLava(1)=Sound'CreaturesSnd.Mech.mechfoot07'
     FootStepLava(2)=Sound'CreaturesSnd.Mech.mechfoot07'
     LandSoundWood=Sound'CreaturesSnd.Mech.mechland01'
     LandSoundMetal=Sound'CreaturesSnd.Mech.mechland01'
     LandSoundStone=Sound'CreaturesSnd.Mech.mechland01'
     LandSoundFlesh=Sound'CreaturesSnd.Mech.mechland01'
     LandSoundIce=Sound'CreaturesSnd.Mech.mechland01'
     LandSoundSnow=Sound'CreaturesSnd.Mech.mechland01'
     LandSoundEarth=Sound'CreaturesSnd.Mech.mechland01'
     LandSoundWater=Sound'CreaturesSnd.Mech.mechland01'
     LandSoundMud=Sound'CreaturesSnd.Mech.mechland01'
     LandSoundLava=Sound'CreaturesSnd.Mech.mechland01'
     WeaponJoint=rwrist
     bCanLook=True
     MaxBodyAngle=(Yaw=32768)
     MaxHeadAngle=(Pitch=0,Yaw=0)
     bRotateHead=False
     DeathRadius=40.000000
     DeathHeight=33.000000
     AnimSequence=Idle
     LODCurve=LOD_CURVE_NONE
     SoundRadius=64
     CollisionRadius=50.000000
     CollisionHeight=47.000000
     Mass=250.000000
     Buoyancy=200.000000
     RotationRate=(Pitch=0,Roll=0)
     Skeletal=SkelModel'creatures.MechaDwarf'
}
