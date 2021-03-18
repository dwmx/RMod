//=============================================================================
// GiantCrab.
//=============================================================================
class GiantCrab expands ScriptPawn;


/* Description:
	Sidesteps around towards enemy.  When annoyed, rears up on back legs
	and tries to knock enemy down.  If enemy jumps on him, he rears up and
	knocks him off.  When severely damaged, will tuck back into it's shell.
	If rearing up, has the possiblity of being flipped over by a blow to
	underside. Will not willingly go in water.  Can only be damaged by striking
	on soft underbelly while reared up.

   Behaviors:
	-Free Roaming (sidesteps towards enemies)
	-Guarding a spot

   Resources needed:
	SnapMiss, SnapHit, idle, walk, pain sounds

   TODO:
	pause after throwing off
	sometimes defend by covering up
	Handle narrow walls, hitwalls better
*/

var() bool	bCamouflage;	// Uses start spot texture as camouflage
var() bool	bFightHigh;		// Whether to use rear up attack
var() float	ThrowZ;			// Z velocity to throw off when on back
var() bool	bInShell;		// Covered up inside shell
var CrabPincer LeftClaw;
var int stallcount;

var(Sounds) Sound		RearUpSound;
var(Sounds) Sound		UpsideDownSound;
var(Sounds) Sound		ThrowoffSound;


//================================================
//
// AfterSpawningInventory
//
// Used to spawn additional chained weapon
//================================================
function AfterSpawningInventory()
{

	LeftClaw = Spawn(class'crabpincer');
	LeftClaw.SetOwner(self);
	AttachActorToJoint(LeftClaw, 23);	// Attach to left wrist
	InvisibleWeapon(Weapon).ChainOnWeapon(LeftClaw);
	LeftClaw.GotoState('Active');
}

function DropLeftWeapon()
{
	LeftClaw=None;
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

function ThrowOffMonkeys()
{
	local actor Other;
	local vector X,Y,Z,vel;

	GetAxes(Rotation, X,Y,Z);
	vel = -200*X + ThrowZ*Z;
	foreach BasedActors(class'actor', Other)
	{
		Other.Velocity += vel;
		Other.SetPhysics(PHYS_Falling);
	}
}

//================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//================================================
function bool CanPickup(Inventory item)
{
	return item.IsA('CrabPincer');
}


function PostBeginPlay()
{
	local Texture tex;
	local int Flags;
	local vector ScrollDir;

	Super.PostBeginPlay();
//	bInShell = true;

	// Grab shell texture from surroundings
	if (bCamouflage)
	{
		tex = TraceTexture(Location+vect(0,0,-100), Location, Flags, ScrollDir);
		if (tex != None)
		{
			SkelGroupSkins[1] = tex;
		}
	}
}


function Attach(actor Other)
{	// Someone landed on me
	if (Health > 0 && AlertOrders != 'NoMove')
		GotoState('MonkeyOnBack');
}


//============================================================
// Localized Damage Support functions
//============================================================

//============================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//============================================================
function Texture PainSkin(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LARM1:
		case BODYPART_RARM1:
		case BODYPART_TORSO:
			break;

		case BODYPART_HEAD:		// undercarriage
			if (SkelGroupSkins[1] == Texture'creatures.giantcrabcrab3')
				SkelGroupSkins[1] = Texture'creatures.giantcrabcrabpain';
			break;
		case BODYPART_RLEG1:	// legs
			if (SkelGroupSkins[1] == Texture'creatures.giantcrabcrab3')
				SkelGroupSkins[1] = Texture'creatures.giantcrabcrabpain';
			SkelGroupSkins[7] = Texture'creatures.giantcrabcrabpain';
			break;
		case BODYPART_RLEG2:
			if (SkelGroupSkins[1] == Texture'creatures.giantcrabcrab3')
				SkelGroupSkins[1] = Texture'creatures.giantcrabcrabpain';
			SkelGroupSkins[8] = Texture'creatures.giantcrabcrabpain';
			break;
		case BODYPART_RARM2:
			if (SkelGroupSkins[1] == Texture'creatures.giantcrabcrab3')
				SkelGroupSkins[1] = Texture'creatures.giantcrabcrabpain';
			SkelGroupSkins[9] = Texture'creatures.giantcrabcrabpain';
			break;
		case BODYPART_LLEG1:
			if (SkelGroupSkins[1] == Texture'creatures.giantcrabcrab3')
				SkelGroupSkins[1] = Texture'creatures.giantcrabcrabpain';
			SkelGroupSkins[4] = Texture'creatures.giantcrabcrabpain';
			break;
		case BODYPART_LLEG2:
			if (SkelGroupSkins[1] == Texture'creatures.giantcrabcrab3')
				SkelGroupSkins[1] = Texture'creatures.giantcrabcrabpain';
			SkelGroupSkins[5] = Texture'creatures.giantcrabcrabpain';
			break;
		case BODYPART_LARM2:
			if (SkelGroupSkins[1] == Texture'creatures.giantcrabcrab3')
				SkelGroupSkins[1] = Texture'creatures.giantcrabcrabpain';
			SkelGroupSkins[6] = Texture'creatures.giantcrabcrabpain';
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
		case 1: case 18: case 22: case 10:
		case 12: case 14: case 3: case 5:
		case 7:							return MATTER_FLESH;

		case 24:						return MATTER_WOOD;
		
	}
	return MATTER_NONE;
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
		case 1:						return BODYPART_HEAD;
		case 18:					return BODYPART_RARM1;
		case 22:					return BODYPART_LARM1;
		case 24:					return BODYPART_TORSO;

		case 10:					return BODYPART_RARM2;	// legs
		case 12:					return BODYPART_RLEG1;
		case 14:					return BODYPART_RLEG2;
		case 3:						return BODYPART_LLEG1;
		case 5:						return BODYPART_LARM2;
		case 7:						return BODYPART_LLEG2;

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
	switch(polygroup)
	{
		case 11:					return BODYPART_LARM1;
		case 10:					return BODYPART_RARM1;
		case 1:						return BODYPART_TORSO;

		case 7:						return BODYPART_RLEG1;	// legs
		case 8:						return BODYPART_RLEG2;
		case 9:						return BODYPART_RARM2;
		case 4:						return BODYPART_LLEG1;
		case 5:						return BODYPART_LLEG2;
		case 6:						return BODYPART_LARM2;
	}
	return BODYPART_BODY;
}

//============================================================
//
// BodyPartSeverable
//
//============================================================
function bool BodyPartSeverable(int BodyPart)
{
	// When flipped over, allow leg severing
	if (GetGroup(AnimSequence) == 'flipped')
	{
		if (BodyPart == BODYPART_LLEG1 || BodyPart == BODYPART_LLEG2 ||
			BodyPart == BODYPART_RLEG1 || BodyPart == BODYPART_RLEG2 ||
			BodyPart == BODYPART_LARM2 || BodyPart == BODYPART_RARM2)
			return true;
	}

	return (BodyPart == BODYPART_LARM1 || BodyPart == BODYPART_RARM1);
}

//============================================================
//
// BodyPartCritical
//
//============================================================
function bool BodyPartCritical(int BodyPart)
{
	return false;
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
		case BODYPART_RARM1:
			return class'CrabClaw';
		case BODYPART_LARM2:
		case BODYPART_RARM2:
		case BODYPART_LLEG1:
		case BODYPART_RLEG1:
		case BODYPART_LLEG2:
		case BODYPART_RLEG2:
			return class'CrabLeg';
	}

	return None;
}

//============================================================
//
// LimbSevered
//
//============================================================
function LimbSevered(int BodyPart, vector Momentum)
{
	local int joint;
	local actor part;
	local vector X,Y,Z;
	local vector pos;
	local class<actor> partclass;

	partclass = SeveredLimbClass(BodyPart);

	switch(BodyPart)
	{
		case BODYPART_LARM1:
			SkelGroupSkins[12] = Texture'runefx.gore';
			DropLeftWeapon();
			joint = JointNamed('lwrist');
			GetAxes(Rotation, X, Y, Z);
			pos = GetJointPos(joint);
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
		case BODYPART_RARM1:
			SkelGroupSkins[13] = Texture'runefx.gore';
			DropRightWeapon();
			joint = JointNamed('rwrist');
			GetAxes(Rotation, X, Y, Z);
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

		// Little legs
		case BODYPART_LLEG1:
			joint = JointNamed('rkneea');
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, GetJointPos(joint), Rotation);
			if(part != None)
			{
				part.Velocity = VRand() * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;
		case BODYPART_LLEG2:
			joint = JointNamed('rkneeb');
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, GetJointPos(joint), Rotation);
			if(part != None)
			{
				part.Velocity = VRand() * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;
		case BODYPART_LARM2:
			joint = JointNamed('rkneec');
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, GetJointPos(joint), Rotation);
			if(part != None)
			{
				part.Velocity = VRand() * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;
		case BODYPART_RLEG1:
			joint = JointNamed('lkneea');
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, GetJointPos(joint), Rotation);
			if(part != None)
			{
				part.Velocity = VRand() * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;
		case BODYPART_RLEG2:
			joint = JointNamed('lkneeb');
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, GetJointPos(joint), Rotation);
			if(part != None)
			{
				part.Velocity = VRand() * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;
		case BODYPART_RARM2:
			joint = JointNamed('lkneec');
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, GetJointPos(joint), Rotation);
			if(part != None)
			{
				part.Velocity = VRand() * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;
	}

	if (BodyPartMissing(BODYPART_LARM1) && BodyPartMissing(BODYPART_RARM1) && GetGroup(AnimSequence) != 'flipped')
		GotoState('Fleeing');
}

//============================================================
//
// LimbPassThrough
//
// Determines what damage is passed through to body
//============================================================
function int LimbPassThrough(int BodyPart, int Blunt, int Sever)
{
	if (BodyPart == BODYPART_BODY)	// Falling damage, etc.
		return Blunt+Sever;

	if (BodyPart == BODYPART_TORSO)	// Shell doesn't accept sever damage
		return 0;
//		return Blunt;

	// Can only be killed when flipped
	if (GetGroup(AnimSequence) == 'flipped')
		return Blunt+Sever;

	return Blunt;
}

//============================================================
//
// DamageBodyPart
//
//============================================================
function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int bodypart)
{
	if (GetGroup(AnimSequence) == 'RearedUp')
		GotoState('Flipped');

	return Super.DamageBodyPart(Damage, EventInstigator, HitLocation, Momentum, DamageType, BodyPart);
}


//------------------------------------------------------------
//
// MakeTwitchable
//
// TODO: Move logic into carcass
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
			case 18: case 22:
				JointFlags[j] = JointFlags[j] | JOINT_FLAG_ACCELERATIVE;
//				SetJointRotThreshold(j, 16000);
//				SetJointDampFactor(j, 0.025);
//				SetAccelMagnitude(j, 8000);
				break;
		}
	}
}

//===================================================================
//
// Bump
//
// If Pawns bump a destroyable decoration, they should smash it
//===================================================================

function Bump(Actor Other)
{
	if(Other.IsA('DecorationRune') && DecorationRune(Other).bDestroyable)
	{
		CrabAttack();
	}
	else
	{
		Super.Bump(Other);
	}
}

//============================================================
// Animation functions
//============================================================
function CrabWalking(vector src, vector dst, rotator rot)
{
	local vector X,Y,Z;
	local vector dir;
	local float XdotDir;

	dir = Normal(dst - src);
	GetAxes(Rotation, X,Y,Z);
	XdotDir = X dot dir;

	if (XdotDir < -0.8)
	{
		LoopAnim('movebackward', 2.0, 0.1);
	}
	else if (XdotDir > 0.8)
	{
		LoopAnim('moveforward', 2.0, 0.1);
	}
	else if ((X cross dir).Z < 0)
	{	// Moving left
		LoopAnim('moveleft', 2.0, 0.1);
	}
	else
	{	// Moving right
		LoopAnim('moveright', 2.0, 0.1);
	}
}

function PlayTurnTo(rotator targetangle)
{
	local int YawErr;

	YawErr = targetangle.Yaw - Rotation.Yaw;
	
	// Fix angles (0..180,0..-180)
	while (YawErr > 32768)
		YawErr -= 65535;
	while (YawErr < -32768)
		YawErr += 65535;

//	if (YawErr > 0)
	if (YawErr < 0)	//test to see if anims are misnamed
	{
		LoopAnim('RotateRight', 3.0, 0.1);
	}
	else
	{
		LoopAnim('RotateLeft', 3.0, 0.1);
	}
}

function CrabAttack()
{
	local float choice;

	choice = FRand();
	if (choice < 0.3 && !BodyPartMissing(BODYPART_LARM1))
		PlayAnim('attackl', 1.0, 0.1);
	else if (choice < 0.6 && !BodyPartMissing(BODYPART_RARM1))
		PlayAnim('attackr', 1.0, 0.1);
	else
		PlayAnim('attackb', 1.0, 0.1);
}

function PlayMoving(optional float tween)
{
	LoopAnim('moveforward', 2.0, 0.1);
}

function PlayWaiting(optional float tween)
{
	if (bInShell)
		PlayAnim('Ground', 1.0, 0.1);
	else
		LoopAnim('Idle', 1.0, 0.1);
}

function PlayDeath(name DamageType)
{
	if (GetGroup(AnimSequence) == 'Flipped')
	{
		PlayAnim('FlippedDie', 1.0, 0.1);
	}
	else
	{
		PlayAnim('towake', 1.0, 0.1);	// just cover up
	}
}

function name GetGroup(name sequence)
{
	switch(sequence)
	{
		case 'rearup':
		case 'rearidle':
		case 'rearupattack':
		case 'backfromrear':
			return 'rearedup';

		case 'flippedidle':
		case 'flippeddie':
//		case 'transflipover':
			return 'Flipped';

		case 'ground':
		case 'towake':
			return 'Ground';
	}
	return 'none';
}



////////////////////////////////////////////////////////////////////////////////////////////
//
// Overridden ScriptPawn States
//
////////////////////////////////////////////////////////////////////////////////////////////

// Default orders (upon going home and starting up)
State InShell
{
	function AmbientSoundTimer()
	{	// Don't play it, just reset timer for next one
		AmbientSoundTime = (0.5 + FRand()*0.5) * AmbientWaitSoundDelay;
	}

	function bool SetEnemy( Actor NewEnemy )
	{
		bTaskLocked = false;		// always release from this state to attack
		Super.SetEnemy(NewEnemy);
	}

	function EndState()
	{
		SetMovementPhysics();
	}

Begin:
	bInShell = true;
	if (GetGroup(AnimSequence) != 'Ground')
	{
		PlayAnim('towake', 1.0, 0.1);
	}
	SetPhysics(PHYS_None);
}


//================================================
//
// Acquisition
//
//================================================
State Acquisition
{
ignores EnemyAcquired, SeePlayer, HearNoise;

Begin:
	if(debugstates) slog(name@"Acquiring"@Enemy.Name);
Acquire:
	Sleep(RandRange(0.5, 1.0));

Wake:
	if (bInShell)
	{
		PlayAnim('Wake', 1.0, 0.1);
		FinishAnim();
		bInShell = false;
	}
	Acceleration = vect(0,0,0);
	SetMovementPhysics();

Turn:
	LastSeenPos = Enemy.Location;
	PlayTurnTo(rotator(LastSeenPos - Location));
	TurnTo(LastSeenPos);
	PlayWaiting();

InformTeam:
	PlaySound(AcquireSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
	
	GotoState('TacticalDecision');
}


//================================================
//
// Fleeing
//
// Cover up and go dormant
//================================================
State Fleeing
{
	ignores SeePlayer, HearNoise, EnemyAcquired, Attach, DamageBodyPart;

	function AmbientSoundTimer()
	{	// Don't play it, just reset timer for next one
		AmbientSoundTime = (0.5 + FRand()*0.5) * AmbientWaitSoundDelay;
	}

Begin:
	PlayAnim('towake', 1.0, 0.1);
	bInShell = true;
	SetPhysics(PHYS_None);
}


//================================================
//
// Charging
//
//================================================
State Charging
{
ignores EnemyAcquired, SeePlayer, HearNoise, BeginState;//, EndState;

	function MayFall()
	{	// Only jump if reachable
		bCanJump = false;
	}

	function EnemyNotVisible()
	{
		GotoState('Hunting');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;

//		slog("hitwall: min="$MinHitWall);

		Focus = Destination;
		if (PickWallAdjust())
			GotoState('Charging', 'AdjustFromWall');
		else
			MoveTimer = -1.0;
	}

	function PickDestination()
	{
		local vector ToEnemy, ToSide, Up;
		Up = vect(0,0,1);
		ToEnemy = Enemy.Location - Location;
		ToSide = ToEnemy cross Up;
		if (FRand() < 0.5)
			ToSide *= -1;
		Destination = Location + ToEnemy*0.5 + ToSide*0.5;
	}

	function PickDestinationBackAway()
	{
		local vector ToEnemy, ToSide, Up;
		Up = vect(0,0,1);
		ToEnemy = Normal(Enemy.Location - Location);
		ToSide = ToEnemy cross Up;
		if (FRand() < 0.5)
			ToSide *= -1;
		Destination = Location - ToEnemy*RandRange(10,100) + ToSide*RandRange(10,100);
	}
	
AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Goto('CloseIn');

ResumeCharge:
	PlayMoving();
	Goto('Charge');

Begin:
	if(debugstates) slog(name@"Charging");

Charge:
	bFromWall = false;
	
CloseIn:
	if ( !ValidEnemy() )
		GotoState('GoingHome');
	if (BodyPartMissing(BODYPART_LARM1) && BodyPartMissing(BODYPART_RARM1) && GetGroup(AnimSequence) != 'flipped')
		GotoState('Fleeing');

	if ( Enemy.Region.Zone.bWaterZone )
	{	// Enemy entered water zone
		if (!bCanSwim)
			GotoState('TacticalDecision');
	}
	else if (!bCanFly && !bCanWalk)
		// Enemy left water zone
		GotoState('GoingHome');

	if (Physics == PHYS_Falling)
		WaitForLanding();

Move:
	if(!actorReachable(Enemy) )
		GotoState('Hunting');

	SoundChance(ThreatenSound, 0.3);
	PickDestination();
	if (pointReachable(Destination))
	{
		CrabWalking(Location, Destination, Rotation);
		StrafeFacing(Destination, Enemy);
		Acceleration = vect(0,0,0);
	}
	else
	{
		PlayMoving();
		MoveTo(Enemy.Location);
		FinishAnim();
		Acceleration = vect(0,0,0);
	}

	// if within melee range, goto attack
	if (InMeleeRange(Enemy))
	{
		if (FRand() < HighOrLow && bFightHigh)
			GotoState('FightingHigh');
		else
			GotoState('FightingLow');
	}
	
	PlayWaiting();
	Sleep(0.1);
	Goto('Charge');

ResumeFromFighting:
	if (!InMeleeRange(Enemy))
	{
		MoveTimer = 0.0;
		Goto('Charge');
	}

BackOff:
	PickDestinationBackAway();
	CrabWalking(Location, Destination, Rotation);
	StrafeFacing(Destination, Enemy);
	Acceleration = vect(0,0,0);
	if (FRand() < 0.3)
		Goto('BackOff');
	Goto('Charge');
}


//================================================
//
// FightingHigh
//
// Reared up on hind legs
//================================================
State FightingHigh
{
	function EndState()
	{
		WeaponDeactivate();
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function WeaponActivate()
	{
		bSwingingHigh = true;
		Super.WeaponActivate();
		if (LeftClaw != None)
			LeftClaw.StartAttack();
	}

	function WeaponDeactivate()
	{
		bSwingingHigh = false;
		Super.WeaponDeactivate();
		if (LeftClaw != None)
			LeftClaw.FinishAttack();
	}

	function CauseQuake()
	{
		local RunePlayer P;

		if(self.IsA('BabyCrab'))
			return; // BabyCrabs cannot cause a quake

		foreach RadiusActors(class'RunePlayer', P, 500, Location)
		{
			P.ShakeView(1.0, 800, 0.5);
		}
	}

Begin:
	Acceleration = vect(0,0,0);

AttackHigh:
	PlayAnim('rearup', 1.0, 0.1);
	FinishAnim();
	stallcount=0;
Stall:
	PlaySound(RearUpSound, SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
	PlayAnim('rearidle', 1.0, 0.1);
	FinishAnim();
	if (++stallcount < 3)
	{
		if (!NeedToTurn(Enemy.Location) && !InMeleeRange(Enemy))
			Goto('Stall');
	}
HighAttack:
	if (InMeleeRange(Enemy))
		PlayAnim('rearupattack', 1.0, 0.1);
	else
		PlayAnim('BackFromRear', 1.0, 0.1);
	FinishAnim();

	CauseQuake();

RearDown:
	GotoState('Charging', 'ResumeFromFighting');
}


//================================================
//
// FightingLow
//
//================================================
State FightingLow
{
	function WeaponActivate()
	{	// Right claw attack
		bSwingingLow = true;
		Super.WeaponActivate();

	}

	function WeaponDeactivate()
	{	// End of right claw attack
		bSwingingLow = false;
		Super.WeaponDeactivate();
	}

	function AltWeaponActivate()
	{	// Left claw attack
		bSwingingLow = true;
		if (LeftClaw != None)
			LeftClaw.StartAttack();
	}

	function AltWeaponDeactivate()
	{	// End of left claw attack
		if (LeftClaw != None)
			LeftClaw.FinishAttack();
		bSwingingLow = false;
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function EndState()
	{
		bSwingingLow = false;
	}

Begin:
	Acceleration = vect(0,0,0);

AttackLow:
	CrabAttack();
	FinishAnim();
	GotoState('Charging', 'ResumeFromFighting');
}


//================================================
//
// Flipped
//
// Flipped upside down
//================================================
State Flipped
{
	ignores SeePlayer, HearNoise, EnemyAcquired;

	function TryToGetUp()
	{
		local int numlegs;

		if (!BodyPartMissing(BODYPART_LLEG1))
			numlegs++;
		if (!BodyPartMissing(BODYPART_LLEG2))
			numlegs++;
		if (!BodyPartMissing(BODYPART_RLEG1))
			numlegs++;
		if (!BodyPartMissing(BODYPART_RLEG2))
			numlegs++;
		if (!BodyPartMissing(BODYPART_LARM2))
			numlegs++;
		if (!BodyPartMissing(BODYPART_RARM2))
			numlegs++;

		// flip over if no-one standing on me, and have enough legs
		if (StandingCount==0 && FRand()<0.6 && !Region.Zone.bWaterZone && numlegs>3)
		{
			GotoState('Flipped', 'Getup');
		}
	}

	function Timer()
	{
		if (FRand() < 0.3)
			PlaySound(UpsideDownSound, SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
	}

	function Attach(actor Other)
	{
		GotoState('Flipped', 'Rocking');
	}

	function KnockBack()
	{
		local vector vel;
		vel = -500*Normal(vector(Rotation));
		vel.Z = 100;
		AddVelocity(vel);		
	}

	function EndState()
	{
		SetTimer(0, false);
	}

Rocking:
	PlayAnim('Rock', 1.0, 0.1);
	FinishAnim();
	PlayAnim('Rock', 0.6, 0.1);
	FinishAnim();
	PlayAnim('Rock', 0.2, 0.1);
	FinishAnim();
	Goto('Idle');

GetUp:
	PlayAnim('flipup', 1.0, 0.1);
	FinishAnim();
	SetMovementPhysics();
	GotoState('TacticalDecision');

Begin:
	Acceleration = vect(0,0,0);
	KnockBack();
	if (GetGroup(AnimSequence) != 'flipped')
	{
		PlayAnim('transflipover', 1.0, 0.1);
		FinishAnim();
	}
	WaitForLanding();
	Velocity=vect(0,0,0);
	SetPhysics(PHYS_None);
	SetTimer(2, true);
Idle:
	LoopAnim('flippedidle', 1.0, 0.1);

	Sleep(RandRange(2, 3+(4-Level.Game.Difficulty)));
	TryToGetUp();
}


//================================================
//
// MonkeyOnBack
//
// Something on my back, rear up to get it off
//================================================
State MonkeyOnBack
{
	ignores Attach;

Begin:
	Acceleration = vect(0,0,0);
	PlayWaiting();
	FinishAnim();

Getup:	// If on ground, must wake
	if (bInShell)
	{
		PlayAnim('Wake', 1.0, 0.1);
		FinishAnim();
		bInShell = false;
	}
	
RearUp:
	if (StandingCount > 0)
	{
		PlayAnim('rearup', 1.0, 0.1);
		Sleep(0.3);
		PlaySound(ThrowoffSound, SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
		ThrowOffMonkeys();
		FinishAnim();
		PlayAnim('rearidle', 1.0, 0.1);
		FinishAnim();
		Goto('Rearup');
	}
	GotoState('TacticalDecision');
}



//============================================================
//
// STATE Dying
//
//============================================================
state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer;

	function Attach(actor Other)
	{
		// Someone jumped on my corpse
	}

	function BeginState()
	{
		local int BodyPart;

		// Turn most collision joints off
		for (BodyPart=0; BodyPart<NUM_BODYPARTS; BodyPart++)
		{
			if (BodyPart == BODYPART_LARM1 || BodyPart == BODYPART_RARM1 || BodyPart == BODYPART_TORSO)
				continue;

			BodyPartCollision(BodyPart, false);
		}

//		bJointsBlock = true;
	}

Begin:
	Velocity=vect(0,0,0);
}


state() NoMove
{
ignores EnemyAcquired;

	function bool SetEnemy( Actor NewEnemy )
	{
		bTaskLocked = false;
		Super.SetEnemy(NewEnemy);
		bTaskLocked = true;
	}

	function WeaponActivate()
	{	// Right claw attack
		bSwingingLow = true;
		Super.WeaponActivate();
	}

	function WeaponDeactivate()
	{	// End of right claw attack
		bSwingingLow = false;
		Super.WeaponDeactivate();
	}

	function AltWeaponActivate()
	{	// Left claw attack
		bSwingingLow = true;
		if (LeftClaw != None)
			LeftClaw.StartAttack();
	}

	function AltWeaponDeactivate()
	{	// End of left claw attack
		if (LeftClaw != None)
			LeftClaw.FinishAttack();
		bSwingingLow = false;
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function EndState()
	{
		bSwingingLow = false;
	}

	function Attach(actor Other)
	{
		if (Health > 0)
			GotoState('NoMove', 'OnBack');
	}

	function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int bodypart)
	{	// Don't flip
		return Super.DamageBodyPart(Damage, EventInstigator, HitLocation, Momentum, DamageType, BodyPart);
	}

Begin:
	Acceleration = vect(0,0,0);

	if (bInShell)
	{
		PlayAnim('Wake', 1.0, 0.1);
		FinishAnim();
		bInShell = false;
	}

Loop:
	if(Enemy != None)
	{
		if (NeedToTurn(Enemy.Location))
		{
			PlayTurnTo(rotator(Enemy.Location - Location));
KeepTurning:
			Sleep(0.2);
			TurnTo(Enemy.Location);

			if (NeedToTurn(Enemy.Location))
				Goto('KeepTurning');

			PlayWaiting(0.1);
		}

		if (InRange(Enemy, MeleeRange))
		{
			CrabAttack();
			FinishAnim();

			PlayWaiting(0.1);
		}
	}

	Sleep(0.1);
	Goto('Loop');

OnBack:
	if (StandingCount > 0)
	{
		PlayAnim('rearup', 1.0, 0.1);
		Sleep(0.3);
		PlaySound(ThrowoffSound, SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
		ThrowOffMonkeys();
		FinishAnim();
		PlayAnim('rearidle', 1.0, 0.1);
		FinishAnim();
		Goto('OnBack');
	}
	PlayWaiting(0.1);
	Goto('Loop');
}




simulated function Debug(Canvas canvas, int mode)
{
	local vector ToEnemy, ToSide, Up;

	Super.Debug(canvas, mode);
	
	Canvas.DrawText("Crab:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" Destination: "$Destination);
	Canvas.CurY -= 8;
	Canvas.DrawText(" bInShell: "$bInShell);
	Canvas.CurY -= 8;

	Canvas.DrawLine3D(Destination, Location, 255, 255, 255);

	if (Weapon != None && mode == 0)
		Weapon.Debug(canvas, mode);
}

defaultproperties
{
     bCamouflage=True
     bFightHigh=True
     ThrowZ=600.000000
     RearUpSound=Sound'CreaturesSnd.Crab.crabsee01'
     UpsideDownSound=Sound'CreaturesSnd.Crab.crabdeath04'
     ThrowoffSound=Sound'CreaturesSnd.Crab.crabdeath02'
     Orders=InShell
     FightOrFlight=1.000000
     FightOrDefend=1.000000
     HighOrLow=0.500000
     AcquireSound=Sound'CreaturesSnd.Crab.crabamb02'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Crab.crabamb03b'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Crab.crabamb02b'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Crab.crabamb03'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Crab.crabattack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Crab.crabattack04'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Crab.crabattack04'
     AmbientWaitSoundDelay=17.000000
     AmbientFightSoundDelay=15.000000
     StartWeapon=Class'RuneI.CrabPincer'
     ShadowScale=3.500000
     bCanStrafe=True
     bAlignToFloor=True
     MeleeRange=70.000000
     GroundSpeed=325.000000
     AccelRate=1000.000000
     JumpZ=0.000000
     MaxStepHeight=10.000000
     WalkingSpeed=150.000000
     ClassID=1
     BodyPartHealth(0)=100
     BodyPartHealth(1)=40
     BodyPartHealth(2)=5
     BodyPartHealth(3)=40
     BodyPartHealth(4)=5
     BodyPartHealth(5)=100
     BodyPartHealth(6)=5
     BodyPartHealth(7)=5
     BodyPartHealth(8)=5
     BodyPartHealth(9)=5
     UnderWaterTime=2.000000
     Intelligence=BRAINS_REPTILE
     HitSound1=Sound'CreaturesSnd.Crab.crabdeath02b'
     HitSound2=Sound'CreaturesSnd.Crab.crabdeath01b'
     HitSound3=Sound'CreaturesSnd.Crab.crabdeath04b'
     Die=Sound'CreaturesSnd.Crab.crabdeath01'
     Die2=Sound'CreaturesSnd.Crab.crabdeath02'
     Die3=Sound'CreaturesSnd.Crab.crabdeath03'
     FootStepWood(0)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepWood(1)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepWood(2)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepMetal(0)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepMetal(1)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepMetal(2)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepStone(0)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepStone(1)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepStone(2)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepFlesh(0)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepFlesh(1)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepFlesh(2)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepIce(0)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepIce(1)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepIce(2)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepEarth(0)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepEarth(1)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepEarth(2)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepSnow(0)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepSnow(1)=Sound'CreaturesSnd.Crab.crabfootstep05'
     FootStepSnow(2)=Sound'CreaturesSnd.Crab.crabfootstep05'
     LandSoundWood=None
     LandSoundMetal=None
     LandSoundStone=None
     LandSoundFlesh=None
     LandSoundIce=None
     LandSoundSnow=None
     LandSoundEarth=None
     LandSoundWater=None
     LandSoundMud=None
     LandSoundLava=None
     WeaponJoint=rthumb
     bRotateHead=False
     bRotateTorso=False
     LookDegPerSec=0.000000
     bAllowStandOn=True
     AnimSequence=ground
     CollisionRadius=45.000000
     CollisionHeight=32.000000
     Mass=300.000000
     RotationRate=(Pitch=1000,Roll=0)
     Skeletal=SkelModel'creatures.GiantCrab'
}
