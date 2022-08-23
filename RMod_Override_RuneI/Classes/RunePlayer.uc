//=============================================================================
// RunePlayer.
//=============================================================================
class RunePlayer extends PlayerPawn
	config(user)
	abstract;

#exec AUDIO IMPORT FILE="Sounds\message.wav" NAME=MessageBeep

const ZTARGET_DIST = 600;

var() float CrouchHeight; // RUNE:  Crouching

// Combat versus Exploration Mode vars
var() float ExploreSpeed;
var() float CombatSpeed;

var(Advanced) bool        bBurnable;			// RUNE: Can be set on fire

// Client-side Camera Vars
var vector OldCameraStart;
var(Camera) float CameraDist;
var(Camera) float CameraAccel;
var(Camera) float CameraHeight;
var(Camera) float CameraPitch;
var(Camera) rotator CameraRotSpeed;
var(Camera) float TranslucentDist;
var rotator CurrentRotation;
var float LastTime;
var float CurrentTime;
var float CurrentDist;

var rotator	SavedCameraRot;
var vector	SavedCameraLoc;

var bool bGotoFP; // Go to first person
var bool bCameraLock;
var bool bCameraOverhead;
var bool bPlayedFallingSound;
var pawn ZTarget;
var ZTargetDecal ZTargetDecal;

var int i;
var string TestString;

// Debug!
var vector DropZFloor;
var vector DropZRag;
var vector DropZResult;
var vector DropZRoll;

var rotator velRot;
var rotator ragnarRot;
var rotator pelvisRot;
var rotator baseRot;

// Scripting support
var actor				NextPoint;			// For queueing OrderObject (NextState, NextLabel)
var int					SpeechPos;			// Position within controls for speech
var int					DispatchAction;		// Index of current action of ScriptDispatcher
var actor				OrderObject;		// Object containing current script orders
var bool				bScriptMoving;		// Call PlayMoving() to update move anim

// Rope variables
var Rope TheRope;
var float RopeDist;
const HandOffset = 10;

// Statue variables
var Pawn StatueInstigator;
var name StatueAnim;

enum MovementDir_e
{
	MD_FORWARD,
	MD_BACKWARD,
	MD_LEFT,
	MD_RIGHT,
	MD_FORWARDLEFT,
	MD_FORWARDRIGHT,
	MD_BACKWARDLEFT,
	MD_BACKWARDRIGHT
};

var(Sounds) sound breathagain;
var(Sounds) sound Die4;
var(Sounds) sound GaspSound;
var(Sounds) sound UnderWaterHitSound[3];
var(Sounds) sound PowerupFail;

var(Sounds) sound WeaponPickupSound;
var(Sounds) sound WeaponThrowSound;
var(Sounds) sound WeaponDropSound;
var(Sounds) sound JumpGruntSound[3];
var(Sounds) sound FallingDeathSound;
var(Sounds) sound FallingScreamSound;
var(Sounds) sound UnderWaterDeathSound;
var(Sounds) sound EdgeGrabSound;
var(Sounds) sound StepupSound;
var(Sounds) sound KickSound;
var(Sounds) sound HitSoundLow[3]; // Low damage
var(Sounds) sound HitSoundMed[3]; // Med damage
var(Sounds) sound HitSoundHigh[3]; // High damage
var(Sounds) sound UnderwaterAmbient[6];
var(Sounds) sound BerserkSoundStart;
var(Sounds) sound BerserkSoundEnd;
var(Sounds) sound BerserkSoundLoop;
var(Sounds) sound BerserkYellSound[6];
var(Sounds)	sound CrouchSound;
var(Sounds) sound RopeClimbSound[3];

var int BerserkLoopId; // RUNE:  Necessary to stop the berserk looping sound

var Weapon LastHeldWeapon;

var rotator ShakeDelta;
var actor BloodLustEyes; // RUNE:  The eye gear that toggles when the player bloodlusts

var bool bSurfaceSwimming;
var float GrabLocationDist; // RUNE:  Used in edge grab code 

var localized string NoRunePowerMsg;
var bool bCanRestart;	// RUNE: Used to allow/disallow player-restarting after death


replication
{
	// Things the server should send to the client.
	unreliable if(bNetOwner && Role == ROLE_Authority)
		CameraAccel, CameraDist, CameraPitch, CameraHeight, CameraRotSpeed,
		ZTarget, CrouchHeight, bGotoFP, TheRope;

	// Things the client should send to the server
//	unreliable if(Role < ROLE_Authority)
//		;

	// Functions client can call.
	reliable if(Role < ROLE_Authority)
		CameraIn, CameraOut, ZTargetToggle;

	// Functions server can call.
	unreliable if(Role==ROLE_Authority && RemoteRole==ROLE_AutonomousProxy)
		ClientTryPlayTorsoAnim;
}

//=============================================================================
//
// PreBeginPlay
//
//=============================================================================

function PreBeginPlay()
{
	Enable('Tick');

	Super.PreBeginPlay();

	// Spawn Torso Animation proxy
	AnimProxy = spawn(class'RunePlayerProxy', self);

	OldCameraStart = Location;
	OldCameraStart.Z += CameraHeight;

	CurrentDist = CameraDist;
	LastTime = 0;
	CurrentTime = 0;
	CurrentRotation = Rotation;

	// Adjust CrouchHeight to new DrawScale
	CrouchHeight = CrouchHeight * DrawScale;		
}

//=============================================================================
//
// PostBeginPlay
//
//=============================================================================

event PostBeginPlay()
{	
	Super(PlayerPawn).PostBeginPlay();

	Weapon = None;

	SetMovementMode();

	BloodLustEyes = Spawn(Class'SarkEyeRagnarRed');
	if(BloodLustEyes != None)
	{
		AttachActorToJoint(BloodLustEyes, JointNamed('head'));
		BloodLustEyes.bHidden = true;
	}
}

function PlayerRestart()
{
	// Add back on default attachments (eyes)
	BloodLustEyes = Spawn(Class'SarkEyeRagnarRed');
	if(BloodLustEyes != None)
	{
		AttachActorToJoint(BloodLustEyes, JointNamed('head'));
		BloodLustEyes.bHidden = true;
	}
}

function ClientReStart()
{
	local int i;

	// Reset client-side camera
	OldCameraStart = Location;
	OldCameraStart.Z += CameraHeight;
	CurrentDist = CameraDist;
	LastTime = 0;
	CurrentTime = 0;
	CurrentRotation = Rotation;

	Super.ClientRestart();
	SetMovementMode();

	// If the player was touching a rope when the level was saved, make certain the player
	// goes back into rope-grabbing state
	for(i = 0; i < ARRAYCOUNT(Touching); i++)
	{
		if(Touching[i] != None && Touching[i].IsA('Rope'))
		{
			SetPhysics(PHYS_Falling); // Can only grab ropes when in the air
			Touch(Touching[i]);
		}
	}
}

//=============================================================================
//
// TravelPostAccept
//
// Called after the player has entered a new level, and after the player's
// inventory has been accepted.  This simply sets the correct movement mode
// for the player.
//=============================================================================

function TravelPostAccept()
{
	SetMovementMode();

	Super.TravelPostAccept();
}


//=============================================================================
//
// PostRender
//
//=============================================================================
event PostRender( canvas Canvas )
{
	local Texture Tex;

	// Handle level fade in
	if (Level.bFadeIn)
	{
		LevelFadeAlpha = 1.0;
		Level.FadeRate = FClamp(Level.FadeRate, 0.5, 10.0);
		Level.bFadeIn = false;
	}
	if (LevelFadeAlpha > 0)
	{	// Draw black with fadealpha
		Tex = Texture'RuneFX.Letterbox';
		if (LevelFadeAlpha < 1.0)
			Canvas.Style = ERenderStyle.STY_AlphaBlend;
		Canvas.SetPos(0, 0);
		Canvas.AlphaScale = LevelFadeAlpha;
		Canvas.DrawTile(Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize);
		Canvas.Style = ERenderStyle.STY_Normal;
	}

	Super.PostRender(Canvas);
}

//=============================================================================
//
// FollowOrders
//
//=============================================================================
function bool FollowOrders(name order, name tag)
{
	if (Order != '')
	{
//		bTaskLocked = true;
		OrderObject = ActorTagged(Tag);
		GotoState(Order);
		return true;
	}

	return false;
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
			// [RMod]
			// Enable / disable headshots
			if(Level.Game != None)
			{
				return (Level.NetMode != NM_StandAlone && Level.Game.bAllowHeadSever);
			}
			else
			{
				return (Level.NetMode != NM_StandAlone);
			}
		case BODYPART_LARM1:
		case BODYPART_RARM1:
			if(Level.Game != None)
				return (Level.NetMode != NM_StandAlone && Level.Game.bAllowLimbSever);
			else
				return (Level.NetMode != NM_StandAlone);
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
// SeveredLimbClass
//
// Override in subclasses
//================================================
function class<Actor> SeveredLimbClass(int BodyPart)
{
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
	local vector X,Y,Z,pos;
	local class<actor> partclass;

	ApplyGoreCap(BodyPart);
	partclass = SeveredLimbClass(BodyPart);

	switch(BodyPart)
	{
		case BODYPART_LARM1:
			DropShield();
			joint = JointNamed('lshouldb');
			pos = GetJointPos(joint);
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.DrawScale = 1.0; // Necessary to scale down SarkArms
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
			LastHeldWeapon = None; // No retrieving
			DropWeapon();
			joint = JointNamed('rshouldb');
			pos = GetJointPos(joint);
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.DrawScale = 1.0; // Necessary to scale down SarkArms
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

	SetMovementMode(); // Set combat or exploration mode (player could lose an arm)
}


//=============================================================================
//
// DamageBodyPart
//
//=============================================================================

function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int bodypart)
{
	if(bBloodLust)
	{
		Damage /= 2;
		Strength -= Damage;
		if(Strength > 0)
			return(true);  // Damage to Ragnar takes away his bloodlust (but doesn't damage him)
		else
			Damage = -Strength * 2;
		
		// Force the strength to atrophy by removing the last strength point
		Strength = 1;
		StrengthDecay(999.0); // force the strength to atrophy

		// Then, this passes through and the remainder damage is applied to Ragnar
	}

	return(Super.DamageBodyPart(Damage, EventInstigator, HitLocation, Momentum, DamageType, bodyPart));
}

function SetOnFire(Pawn EventInstigator, int joint)
{
	local PawnFire F;

	if (bBurnable)
	{
		if (ActorAttachedTo(joint) == None)
		{
			F = Spawn(class'PawnFire',EventInstigator);
			if (F != None)
			{
				AttachActorToJoint(F, joint);
			}
		}
	}
}

//=============================================================================
//
// JointDamaged
//
// Only overridden for the VikingAxe Empathy powerup in multiplayer
//=============================================================================

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local int halfDamage;

	if(Weapon != None && Weapon.IsA('VikingAxe') && Weapon.bPoweredup && Level.Netmode != NM_StandAlone)
	{ // Multiplayer only Empathy weapon on the VikingAxe.  If a player with empathy enabled is hit
		// by an opponent, then the opponent will receive 1/2 of the damage
		halfDamage = Damage / 2;
		Damage -= halfDamage; // Adjust the amount of damage taken by this player

		if(!EventInstigator.IsA('PlayerPawn') || PlayerPawn(EventInstigator).Weapon == None
			|| !PlayerPawn(EventInstigator).Weapon.IsA('VikingAxe') || !PlayerPawn(EventInstigator).Weapon.bPoweredUp)
		{ // Guard against infinite loops if more than one person has empathy enabled
			EventInstigator.JointDamaged(halfDamage, EventInstigator, HitLoc, Momentum, DamageType, 0);
			Spawn(class'EmpathyFlash',,,HitLoc,);
		}
	}

	// Damage the originally struck player
	Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
}

// Animation Functions

//=============================================================================
//
// GetGroup
//
//=============================================================================

function Name GetGroup(Name AnimSequence)
{
	//TODO: Order these by how often they are playing for speed (waiting/running first)
	if(AnimSequence == 'MOV_ALL_jump1_AA0S')			return('Moving');
	else if(AnimSequence == 'MOV_ALL_run1_AA0N')		return('Moving');
	else if(AnimSequence == 'MOV_ALL_run1_AA0S')		return('Moving');
	else if(AnimSequence == 'MOV_ALL_run1_AN0N')		return('Moving');
	else if(AnimSequence == 'MOV_ALL_run1_AN0S')		return('Moving');
	else if(AnimSequence == 'MOV_ALL_lstrafe1_AA0S')	return('Moving');
	else if(AnimSequence == 'MOV_ALL_lstrafe1_AN0N')	return('Moving');
	else if(AnimSequence == 'MOV_ALL_rstrafe1_AA0S')	return('Moving');
	else if(AnimSequence == 'MOV_ALL_rstrafe1_AN0N')	return('Moving');
	else if(AnimSequence == 'MOV_ALL_runback1_AA0S')	return('Moving');
	else if(AnimSequence == 'MOV_ALL_pullup1_AA0N')		return('Moving');
	else if(AnimSequence == 'pullup')					return('Moving');
	else if(AnimSequence == 'ropetest')					return('Moving');

	// Waiting
	else if(AnimSequence == 'neutral_defend')			return('Waiting');
	else if(AnimSequence == 'neutral_idle')				return('Waiting');
	else if(AnimSequence == 'Neutral_kick')				return('Waiting');
	else if(AnimSequence == 's1_defendPose')			return('Waiting');
	else if(AnimSequence == 'IDL_ALL_crbreathe1_AN0N')	return('Waiting');
	else if(AnimSequence == 'IDL_ALL_crbreathe1_AA0N')	return('Waiting');
	else if(AnimSequence == 'IDL_ALL_crbreathe1_AN0S')	return('Waiting');
	else if(AnimSequence == 'IDL_ALL_crbreathe1_AA0S')	return('Waiting');

	else if(AnimSequence == 'S1_Throw')		return('Throwing');
	else if(AnimSequence == 'S2_Throw')		return('Throwing');
	else if(AnimSequence == 'S3_Throw')		return('Throwing');
	else if(AnimSequence == 'S4_Throw')		return('Throwing');
	else if(AnimSequence == 'S5_Throw')		return('Throwing');

	else if(AnimSequence == 'H1_Throw')		return('Throwing');
	else if(AnimSequence == 'H2_Throw')		return('Throwing');
	else if(AnimSequence == 'H3_Throw')		return('Throwing');
	else if(AnimSequence == 'H4_Throw')		return('Throwing');
	else if(AnimSequence == 'H5_Throw')		return('Throwing');

	else if(AnimSequence == 'X1_Throw')		return('Throwing');
	else if(AnimSequence == 'X2_Throw')		return('Throwing');
	else if(AnimSequence == 'X3_Throw')		return('Throwing');
	else if(AnimSequence == 'X4_Throw')		return('Throwing');
	else if(AnimSequence == 'X5_Throw')		return('Throwing');

	if(Weapon != None)
	{ // TODO!  Check weapon anims versus AnimSequence to see if Ragnar is moving
		if(AnimSequence == Weapon.A_Forward
			|| AnimSequence == Weapon.A_Backward
			|| AnimSequence == Weapon.A_StrafeLeft
			|| AnimSequence == Weapon.A_StrafeRight
			|| AnimSequence == Weapon.A_Forward45Left
			|| AnimSequence == Weapon.A_Forward45Right
			|| AnimSequence == Weapon.A_Backward45Left
			|| AnimSequence == Weapon.A_Backward45Right
			|| AnimSequence == Weapon.A_Jump)
		{ // Playing a movement attack animation
			return('Moving');		
		}
		else if(AnimSequence == Weapon.A_AttackA
			|| AnimSequence == Weapon.A_AttackAReturn
			|| AnimSequence == Weapon.A_AttackB
			|| AnimSequence == Weapon.A_AttackBReturn
			|| AnimSequence == Weapon.A_AttackC
			|| AnimSequence == Weapon.A_AttackCReturn
			|| AnimSequence == Weapon.A_AttackD
			|| AnimSequence == Weapon.A_AttackDReturn
			|| AnimSequence == Weapon.A_AttackBackupA
			|| AnimSequence == Weapon.A_AttackBackupAReturn
			|| AnimSequence == Weapon.A_AttackBackupB
			|| AnimSequence == Weapon.A_AttackBackupAReturn)
		{ // Playing a movement attack animation
			return('AttackMoving');		
		}
		else if(AnimSequence == Weapon.A_AttackStandA
			|| AnimSequence == Weapon.A_AttackStandAReturn
			|| AnimSequence == Weapon.A_AttackStandB
			|| AnimSequence == Weapon.A_AttackStandBReturn)
		{ // Playing a standing attack animation
			return('AttackStanding');		
		}
		else if(AnimSequence == Weapon.A_Throw)		return('Throwing');
		else if(AnimSequence == Weapon.A_Idle)		return('Waiting');
		else if(AnimSequence == Weapon.A_Powerup)	return('Powerup');
		else if(AnimSequence == Weapon.A_JumpAttack) return('JumpAttack');
	}

	return('None');	
}

//=============================================================================
//
// PlayJump
//
//=============================================================================

function PlayJump()
{
	local name anim;

	if(Weapon != None && Weapon.A_Jump != '')
		anim = Weapon.A_Jump;
	else
		anim = 'MOV_ALL_jump1_AA0S';
	
	PlayAnim(anim, 1.0, 0.1);

	if(AnimProxy != None)
		AnimProxy.TryPlayAnim(anim, 1.0, 0.1);

	// Play Jump Grunt Sound
	PlaySound(JumpGruntSound[Rand(3)], SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
}

//=============================================================================
//
// PlayRopeLeapOff
//
//=============================================================================

function PlayRopeLeapOff()
{
	PlayAnim('MOV_ALL_jump1_AA0S', 1.0, 0.1);

	if(AnimProxy != None)
		AnimProxy.PlayAnim('MOV_ALL_jump1_AA0S', 1.0, 0.1);

	// Play Jump Grunt Sound
	PlaySound(JumpGruntSound[Rand(3)], SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
}

//=============================================================================
//
// PlayTakeHit
//
//=============================================================================

function PlayTakeHit(float tweentime, int damage, vector HitLoc, name damageType, vector Momentum, int BodyPart)
{
	local float rnd;
	local float time;

	rnd = FClamp(Damage, 10, 40);
	if ( damageType == 'burned' )
		ClientFlash( -0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
	else if ( damageType == 'corroded' )
		ClientFlash( -0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
	else if ( damageType == 'drowned' )
		ClientFlash(-0.390, vect(312.5,468.75,468.75));
	else 
		ClientFlash( -0.017 * rnd, rnd * vect(24, 4, 4));

	time = 0.15 + 0.005 * Damage;
	ShakeView(time, Damage * 10, time * 0.5);

	Super.PlayTakeHit(tweentime, damage, HitLoc, damageType, Momentum, BodyPart);
}

//=============================================================================
//
// PlayTurning
//
//=============================================================================

function PlayTurning(optional float tween)
{
}

//=============================================================================
//
// PlayRising
//
// Obsolete Unreal Code
//=============================================================================

function PlayRising()
{
}

//=============================================================================
//
// PlayFeignDeath
//
// Obsolete Unreal Code
//=============================================================================

function PlayFeignDeath()
{
}

//=============================================================================
//
// PlayWeaponSwitch
//
// Obsolete Unreal Code
//=============================================================================
		
function PlayWeaponSwitch(Weapon NewWeapon)
{
}

//=============================================================================
//
// PlayFrontHit
//
// NOTE:  Hit functions force the torso to play the hit animation
//=============================================================================

function PlayFrontHit(float tweentime)
{
	if(Weapon == None)
	{ // Neutral anims
		TryPlayTorsoAnim('n_painFront', 1.0, 0.1);

		if(AnimProxy != None)
			AnimProxy.PlayAnim('n_painFront', 1.0, 0.1);
	}
	else
	{ // Weapon-specific
		TryPlayTorsoAnim(Weapon.A_PainFront, 1.0, 0.1);

		if(AnimProxy != None)
			AnimProxy.PlayAnim(Weapon.A_PainFront, 1.0, 0.1);
	}
}

//=============================================================================
//
// PlayBackHit
//
// NOTE:  Hit functions force the torso to play the hit animation
//=============================================================================

function PlayBackHit(float tweentime)
{
	if(Weapon == None)
	{ // Neutral anims
		TryPlayTorsoAnim('n_painBack', 1.0, 0.1);

		if(AnimProxy != None)
			AnimProxy.PlayAnim('n_painBack', 1.0, 0.1);
	}
	else
	{ // Weapon-specific
		TryPlayTorsoAnim(Weapon.A_PainBack, 1.0, 0.1);

		if(AnimProxy != None)
			AnimProxy.PlayAnim(Weapon.A_PainBack, 1.0, 0.1);
	}
}

//=============================================================================
//
// PlayGutHit
//
// NOTE:  Hit functions force the torso to play the hit animation
//=============================================================================

function PlayGutHit(float tweentime)
{
	PlayBackHit(tweentime);
}

//=============================================================================
//
// PlayHeadHit
//
// NOTE:  Hit functions force the torso to play the hit animation
//=============================================================================

function PlayHeadHit(float tweentime)
{
	PlayFrontHit(tweentime);
}

//=============================================================================
//
// PlayLeftHit
//
// NOTE:  Hit functions force the torso to play the hit animation
//=============================================================================

function PlayLeftHit(float tweentime)
{
	if(Weapon == None)
	{ // Neutral anims
		TryPlayTorsoAnim('s1_painLeft', 1.0, 0.08);

		if(AnimProxy != None)
			AnimProxy.PlayAnim('s1_painLeft', 1.0, 0.08);
	}
	else
	{ // Weapon-specific
		TryPlayTorsoAnim(Weapon.A_PainLeft, 1.0, 0.1);

		if(AnimProxy != None)
			AnimProxy.PlayAnim(Weapon.A_PainLeft, 1.0, 0.1);
	}
}

//=============================================================================
//
// PlayRightHit
//
// NOTE:  Hit functions force the torso to play the hit animation
//=============================================================================

function PlayRightHit(float tweentime)
{
	if(Weapon == None)
	{ // Neutral anims
		TryPlayTorsoAnim('s1_painRight', 1.0, 0.08);

		if(AnimProxy != None)
			AnimProxy.PlayAnim('s1_painRight', 1.0, 0.08);
	}
	else
	{ // Weapon-specific
		TryPlayTorsoAnim(Weapon.A_PainRight, 1.0, 0.1);

		if(AnimProxy != None)
			AnimProxy.PlayAnim(Weapon.A_PainRight, 1.0, 0.1);
	}
}

//=============================================================================
//
// PlayDrowning
//
// NOTE:  Hit functions force the torso to play the hit animation
//=============================================================================

function PlayDrowning(float tweentime)
{
	local int joint;
	local vector l;
	local name anim;

	if(HeadRegion.Zone.bWaterZone)
	{
		// Spawn Bubbles
		joint = JointNamed('jaw');
		l = GetJointPos(joint);
		if(FRand() < 0.75)
		{
			Spawn(class'BubbleSystemOneShot',,, l,);
		}
	}

	if(AnimSequence == 'SwimUnderWaterDown')
	{ // This anim sequence doesn't have a pain animation
		return;
	}

	if(AnimSequence == 'Treadwateridle' || AnimSequence == 'Swimbackwards' || AnimSequence == 'Swimbackwards45Left'
		|| AnimSequence == 'Swimbackwards45Right' || AnimSequence == 'SwimUnderWaterUp')
	{
		anim = 'treadpain'; // Treading in water pain
	}
	else
		anim = 'swimpain'; // normal swimming pain
		
	TryPlayTorsoAnim(anim, 1.0, 0.1);	
	if(AnimProxy != None)
		AnimProxy.PlayAnim(anim, 1.0, 0.1);
}

function PlayDeath(name DamageType)
{
	local name anim;
	local float tween;

	tween = 0.1;

	if(DamageType == 'fire')
		anim = 'DeathF';
	else if(DamageType == 'fell')
	{
		anim = 'DeathImpact';
	}
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
	}

	PlayAnim(anim, 1.0, tween);
	if(AnimProxy != None)
		AnimProxy.PlayAnim(anim, 1.0, tween);
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

function PlayLeftDeath(name DamageType)		{ PlayDeath(DamageType);			}
function PlayRightDeath(name DamageType)	{ PlayDeath(DamageType);			}
function PlayHeadDeath(name DamageType)		
{
	PlayAnim('DeathH', 1.0, 0.1);
	if(AnimProxy != None)
		AnimProxy.PlayAnim('DeathH', 1.0, 0.1);	
}

function PlayDrownDeath(name DamageType)	
{
	PlayAnim('Drown', 1.0, 0.1);
	if(AnimProxy != None)
		AnimProxy.PlayAnim('Drown', 1.0, 0.1);	
}

function PlayGibDeath(name DamageType)		{ Super.PlayGibDeath(DamageType);	}

function PlaySkewerDeath(name DamageType)	  
{
	PlayAnim('deathb', 1.0, 0.1);	
	if(AnimProxy != None)
		AnimProxy.PlayAnim('deathb', 1.0, 0.1);	
}

//=============================================================================
//
// PlayFiring
//
//=============================================================================

function PlayFiring()
{
	if(GetStateName() == 'PlayerSwimming')
		return;

	if(AnimProxy != None)
		AnimProxy.Attack();

	if(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y >= 1000)
		PlayMoving();
}

//=============================================================================
//
// PlayAltFiring 
//
//=============================================================================

function PlayAltFiring()
{
	if(GetStateName() == 'PlayerSwimming')
		return;

	if(AnimProxy != None)
		AnimProxy.Defend();
/*
	if(AnimProxy.Defend() && GetGroup(AnimSequence) == 'Waiting')
	{
		PlayAnim(RunePlayerProxy(AnimProxy).TorsoAnim, 1.0, 0.1);
	}
*/
}

//=============================================================================
//
// PlayMoving
//
//=============================================================================

function PlayMoving(optional float tween)
{
	local name LowerName, UpperName;
	local bool bDefending;
	local float dp;
	local vector X, Y, Z;
	local bool bRight;
	local MovementDir_e dir;

	if (health <= 0)
		return;
	
	if(AnimProxy != None)
		bDefending = (AnimProxy.GetStateName() == 'Defending');
	else
		bDefending = false;

	// Determine the direction the player is attempting to move
	GetAxes(Rotation, X, Y, Z);
	dp = vector(Rotation) dot Normal(Acceleration);

	if(Normal(Acceleration) dot Y >= 0)
	{
		bRight = true;
	}

	if(dp > 0.9)
	{ // Distinctly forward
		dir = MD_FORWARD;
	}
	else if(dp > 0.5)
	{ // forward left/right
		if(bRight)
		{
			if (!bMirrored)
				dir = MD_FORWARDRIGHT;
			else
				dir = MD_FORWARDLEFT;
		}
		else
		{
			if (!bMirrored)
				dir = MD_FORWARDLEFT;
			else
				dir = MD_FORWARDRIGHT;
		}
	}
	else if(dp < -0.9)
	{ // Distinctly backward
		dir = MD_BACKWARD;		
	}
	else if(dp < -0.5)
	{ // backward left/right
		if(bRight)
		{
			if (!bMirrored)
				dir = MD_BACKWARDRIGHT;
			else
				dir = MD_BACKWARDLEFT;
		}
		else
		{
			if (!bMirrored)
				dir = MD_BACKWARDLEFT;
			else
				dir = MD_BACKWARDRIGHT;
		}
	}
	else if(bRight)
	{ // Strafe right
		if (!bMirrored)
			dir = MD_RIGHT;
		else
			dir = MD_LEFT;
	}
	else
	{ // Strafe left
		if (!bMirrored)
			dir = MD_LEFT;
		else
			dir = MD_RIGHT;
	}

	// If Attacking and running foward or backward, then let the upper body handle the leg motion
	if(AnimProxy != None && AnimProxy.GetStateName() == 'Attacking')
	{
		if(GetGroup(AnimSequence) == 'JumpAttack')
			return;
		if((dir == MD_FORWARD || dir == MD_BACKWARD) && (GetGroup(AnimSequence) == 'AttackMoving'
			&& AnimSequence != 'ghostthrow'))
			return;
	}

	// Set the proper animation based upon the motion
	LowerName = 'MOV_ALL_run1_AA0N';

	if(Weapon == None)
	{ // Explore mode
		if(!bIsCrouching)
		{
			switch(dir)
			{
			case MD_FORWARD:
				LowerName = 'MOV_ALL_run1_AA0N';
				break;
			case MD_FORWARDRIGHT:
				LowerName = 'MOV_ALL_rstrafe1_AA0S';
				break;
			case MD_FORWARDLEFT:
				LowerName = 'MOV_ALL_lstrafe1_AA0S';
				break;
			case MD_BACKWARD:
				LowerName = 'MOV_ALL_runback1_AA0S';
				break;
			case MD_BACKWARDRIGHT:
				LowerName = 'MOV_ALL_lstrafe1_AA0S';
				break;
			case MD_BACKWARDLEFT:
				LowerName = 'MOV_ALL_rstrafe1_AA0S';
				break;
			case MD_RIGHT:
				LowerName = 'MOV_ALL_rstrafe1_AN0N';
				break;
			case MD_LEFT:
				LowerName = 'MOV_ALL_lstrafe1_AN0N';
				break;
			default:
				break;
			}

			if(LowerName == 'MOV_ALL_run1_AA0N')
			{
				// Upper-body animation
				if(Shield == None)
				{
					UpperName = 'MOV_ALL_run1_AN0N'; 
				}
				else
				{
					UpperName = 'MOV_ALL_run1_AN0S';
				}
			}
			else
			{ // Strafing, so match the upper-body with the lower-body
				UpperName = LowerName;
			}
		}
		else
		{ // Crouching
			switch(dir)
			{
			case MD_FORWARD:
				LowerName = 'crouch_walkforward';
				break;
			case MD_FORWARDRIGHT:
				LowerName = 'crouch_walkforward45Right';
				break;
			case MD_FORWARDLEFT:
				LowerName = 'crouch_walkforward45Left';
				break;
			case MD_BACKWARD:
				LowerName = 'crouch_walkbackward';
				break;
			case MD_BACKWARDRIGHT:
				LowerName = 'crouch_walkbackward45Right';
				break;
			case MD_BACKWARDLEFT:
				LowerName = 'crouch_walkbackward45Left';
				break;
			case MD_RIGHT:
				LowerName = 'crouch_straferight';
				break;
			case MD_LEFT:
				LowerName = 'crouch_strafeleft';
				break;
			default:
				break;
			}

			UpperName = LowerName;
		}
	}
	else
	{ // Combat Mode
		if(!bIsCrouching)
		{
			switch(dir)
			{
			case MD_FORWARD:
				if(!bDefending)
				{
					if(AnimProxy.GetStateName() == 'Attacking')
					{
						LowerName = Weapon.A_ForwardAttack;
					}
					else
					{
						LowerName = Weapon.A_Forward;
					}
				}
				else
					LowerName = 'weapon_DefendWalk'; //Weapon.ForwardAnim;
				break;
			case MD_FORWARDRIGHT:
				if(!bDefending)
					LowerName = Weapon.A_Forward45Right;
				else
					LowerName = 'weapon_DefendWalk45Right';
				break;
			case MD_FORWARDLEFT:
				if(!bDefending)
					LowerName = Weapon.A_Forward45Left;
				else
					LowerName = 'weapon_DefendWalk45Left';
				break;
			case MD_BACKWARD:
				if(!bDefending)
					LowerName = Weapon.A_Backward;
				else
					LowerName = 'weapon_DefendBackup';
				break;
			case MD_BACKWARDRIGHT:
				if(!bDefending)
					LowerName = Weapon.A_Backward45Right;
				else
					LowerName = 'weapon_DefendBackup45Right';
				break;
			case MD_BACKWARDLEFT:
				if(!bDefending)
					LowerName = Weapon.A_Backward45Left;
				else
					LowerName = 'weapon_DefendBackup45Left';
				break;
			case MD_RIGHT:
				if(!bDefending)
					LowerName = Weapon.A_StrafeRight;
				else
					LowerName = Weapon.A_StrafeRight;
				break;
			case MD_LEFT:
				if(!bDefending)
					LowerName = Weapon.A_StrafeLeft;
				else
					LowerName = Weapon.A_StrafeLeft;
				break;
			default:
				break;
			}
		}
		else
		{ // Crouch
			switch(dir)
			{
			case MD_FORWARD:
				if(Weapon.bCrouchTwoHands)
					LowerName = 'crouch_walkforward2hands';
				else
					LowerName = 'crouch_walkforward';
				break;
			case MD_FORWARDRIGHT:
				if(Weapon.bCrouchTwoHands)
					LowerName = 'crouch_walkforward45Right2hands';
				else
					LowerName = 'crouch_walkforward45Right';
				break;
			case MD_FORWARDLEFT:
				if(Weapon.bCrouchTwoHands)
					LowerName = 'crouch_walkforward45Left2hands';
				else
					LowerName = 'crouch_walkforward45Left';
				break;
			case MD_BACKWARD:
				if(Weapon.bCrouchTwoHands)
					LowerName = 'crouch_walkbackward2hands';
				else
					LowerName = 'crouch_walkbackward';
				break;
			case MD_BACKWARDRIGHT:
				if(Weapon.bCrouchTwoHands)
					LowerName = 'crouch_walkbackward45Right2hands';
				else
					LowerName = 'crouch_walkbackward45Right';
				break;
			case MD_BACKWARDLEFT:
				if(Weapon.bCrouchTwoHands)
					LowerName = 'crouch_walkbackward45Left2hands';
				else
					LowerName = 'crouch_walkbackward45Left';
				break;
			case MD_RIGHT:
				if(Weapon.bCrouchTwoHands)
					LowerName = 'crouch_straferight2hands';
				else
					LowerName = 'crouch_straferight';
				break;
			case MD_LEFT:
				if(Weapon.bCrouchTwoHands)
					LowerName = 'crouch_strafeleft2hands';
				else
					LowerName = 'crouch_strafeleft';
				break;
			default:
				break;
			}
		}

		UpperName = LowerName;
	}

	LoopAnim(LowerName, 1.0, 0.1);

	if(AnimProxy != None)
		AnimProxy.TryLoopAnim(UpperName, 1.0, 0.1);
}

//=============================================================================
//
// PlayInAir
//
//=============================================================================

function PlayInAir(optional float tween)
{
	local name anim;

	if(Weapon != None && Weapon.A_Jump != '')
		anim = Weapon.A_Jump;
	else
		anim = 'MOV_ALL_jump1_AA0S';
	
	PlayAnim(anim, 1.0, 0.1);

	if(AnimProxy != None)
		AnimProxy.TryPlayAnim(anim, 1.0, 0.1);
/*
	PlayAnim('MOV_ALL_run1_AA0N', 0.1, tween);

	if(AnimProxy != None)
		AnimProxy.TryPlayAnim('MOV_ALL_run1_AA0N', 0.1, tween);
*/
}

//=============================================================================
//
// PlayPullUp
//
//=============================================================================

function PlayPullUp(optional float tween)
{
	PlaySound(EdgeGrabSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.4 + 0.8);

	PlayAnim('intropullupA', 1.0, tween); // No tween

	if(AnimProxy != None)
		AnimProxy.TryPlayAnim('intropullupA', 1.0, tween);
}

//=============================================================================
//
// PlayStepUp
//
//=============================================================================

function PlayStepUp(optional float tween)
{
	PlaySound(StepupSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.4 + 0.8);

	PlayAnim('pullupTest', 1.0, tween);

	if(AnimProxy != None)
		AnimProxy.TryPlayAnim('pullupTest', 1.0, tween);
}

//=============================================================================
//
// PlayDuck
//
//=============================================================================

function PlayDuck(optional float tween)
{
	local name n;

	if(Weapon == None || !Weapon.bCrouchTwoHands)
		n = 'crouch_idle';
	else
		n = 'crouch_idle2hands';

	LoopAnim(n, 1.0, 0.1);
	if(AnimProxy != None)
		AnimProxy.TryPlayAnim(n, 1.0, 0.1);
}

//=============================================================================
//
// PlayCrawling
//
//=============================================================================

function PlayCrawling(optional float tween)
{
	PlayMoving(tween);
}


//=============================================================================
//
// PlayWaiting
//
//=============================================================================

function PlayWaiting(optional float tween)
{
	local Name n;
	local name group;

	if(Health <= 0)
		return;

	group = GetGroup(AnimSequence);
	if(group == 'Powerup')
	{ // Don't play wait anim if playing powerup animation
		return;
	}

	// Don't play anim if the legs are in a standing throw animation
	if(AnimProxy != None && AnimProxy.GetStateName() == 'Throwing' && group == 'Throwing')
		return;

	if(!bIsCrouching)
	{	
		if(Weapon==None)
		{ // Exploration mode
			if(AnimProxy != None && AnimProxy.GetStateName() == 'Defending')
			{
				n = 'neutral_defend';
			}	
			else
			{
				n = 'neutral_idle';
			}
		}
		else
		{ // Combat Mode
			if(AnimProxy != None && AnimProxy.GetStateName() == 'Defending' )
			{
				tween = 0.01; // Near instant bringing up of shields
				if(AnimProxy.AnimSequence != Weapon.A_Defend)
					n = AnimProxy.AnimSequence;
				else
					return;
			}
			else if(GetGroup(AnimSequence) == 'AttackStanding')
			{ // Don't play the animation if standing and attacking
				return;
			}
			else
			{
				n = Weapon.A_Idle;
			}
		}
	}
	else
	{ // Crouching
		tween = 0.1;
		if(Weapon == None || !Weapon.bCrouchTwoHands)
			n = 'crouch_idle';
		else
			n = 'crouch_idle2hands';
	}

	LoopAnim(n, 1.0, tween);
	if(AnimProxy != None)
		AnimProxy.TryLoopAnim(n, 1.0, tween);
}

//=============================================================================
//
// TweenToWaiting
//
//=============================================================================

function TweenToWaiting(float tweentime)
{	
	PlayWaiting(0.1);
}

//=============================================================================
//
// TweenToMoving
//
//=============================================================================

function TweenToMoving(float tweentime)
{
	PlayMoving();
}

//=============================================================================
//
// PlayLanded
//
//=============================================================================

function PlayLanded(float impactVel)
{		
	local EMatterType matter;
	local vector end;
	local sound snd;

	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if (!FootRegion.Zone.bWaterZone)
	{
		FootstepLeft();
		FootstepRight();
	}

	if ( Role == ROLE_Authority )
	{
		if(impactVel > 0.15)
			PlaySound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand() * 0.08 + 0.96);

		if(impactVel > 0.01)
		{ // Play Land Sound			
			if(FootRegion.Zone.bPainZone)
				matter = MATTER_LAVA;
			else if(FootRegion.Zone.bWaterZone)
				matter = MATTER_WATER;
			else
			{
				end = Location;
				end.Z -= CollisionHeight;
				matter = MatterTrace(end, Location, 10);
			}

			PlayLandSound(matter, impactVel);
		}
	}
	
	if(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000)
	{
		PlayWaiting(0.2);
	}
	else
	{
		PlayMoving();
	}
}

//=============================================================================
//
// PlaySwimming
//
//=============================================================================

function PlaySwimming()
{
	local name Anim;
	local float dp;
	local vector dir,X,Y,Z;

	// Recalculate these since they aren't known on clients
	GetAxes(Rotation,X,Y,Z);
	dir = Normal(Acceleration);
	dp = dir dot X;
	bWasForward	= dp >  0.5;
	bWasBack	= dp < -0.5;
	dp = dir dot Y;
	bWasLeft	= dp >  0.3 ;
	bWasRight	= dp < -0.3;

	if(bSurfaceSwimming)
		Anim = 'TreadOnWaterIdle';
	else
		Anim = 'Treadwateridle';
	
	if(bWasForward)
	{
		if(!bWasLeft && !bWasRight)
		{ // Normal running forwards
			if(bSurfaceSwimming)
				Anim = 'SwimOnWater';
			else
				Anim = 'SwimUnderWater';
		}
		else if(bWasLeft)
		{ // Strafe right 45
			if(bSurfaceSwimming)
			{
				if (!bMirrored)
					Anim = 'Swim45RightOnWater';
				else
					Anim = 'Swim45LeftOnWater';
			}
			else
			{
				if (!bMirrored)
					Anim = 'SwimUnderWater45Right';
				else
					Anim = 'SwimUnderWater45Left';
			}
		}
		else if(bWasRight)
		{ // Strafe left 45
			if(bSurfaceSwimming)
			{
				if (!bMirrored)
					Anim = 'Swim45LeftOnWater';
				else
					Anim = 'Swim45RightOnWater';
			}
			else
			{
				if (!bMirrored)
					Anim = 'SwimUnderWater45Left';
				else
					Anim = 'SwimUnderWater45Right';
			}
		}
	}
	else if(bWasBack)
	{
		if(!bWasLeft && !bWasRight)
		{ // Normal running backwards
			if(bSurfaceSwimming)
				Anim = 'SwimbackwardsOnWater';
			else
				Anim = 'Swimbackwards';
		}
		else if(bWasRight)
		{ // Strafe Left 45
			if(bSurfaceSwimming)
			{
				if (!bMirrored)
					Anim = 'TreadOnWaterIdle'; // BROKEN: 'SwimbackwardsLeftOnWater';
				else
					Anim = 'SwimbackwardsRightOnWater';
			}
			else
			{
				if (!bMirrored)
					Anim = 'Swimbackwards45Left';
				else
					Anim = 'Swimbackwards45Right';
			}
		}
		else if(bWasLeft)
		{ // Strafe right 45
			if(bSurfaceSwimming)
			{
				if (!bMirrored)
					Anim = 'SwimbackwardsRightOnWater';
				else
					Anim = 'TreadOnWaterIdle';	// BROKEN: 'SwimbackwardsLeftOnWater';
			}
			else
			{
				if (!bMirrored)
					Anim = 'Swimbackwards45Right';
				else
					Anim = 'Swimbackwards45Left';
			}
		}
	}
	else if(bWasLeft)
	{ // Strafe right
		if(bSurfaceSwimming)
		{
			if (!bMirrored)
				Anim = 'SwimRightOnWater';
			else
				Anim = 'SwimLeftOnWater';
		}
		else
		{
			if (!bMirrored)
				Anim = 'SwimRight';
			else
				Anim = 'SwimLeft';
		}
	}
	else if(bWasRight)
	{ // Strafe left
		if(bSurfaceSwimming)
		{
			if (!bMirrored)
				Anim = 'SwimLeftOnWater';
			else
				Anim = 'SwimRightOnWater';
		}
		else
		{
			if (!bMirrored)
				Anim = 'SwimLeft';
			else
				Anim = 'SwimRight';
		}
	}
	else if(Acceleration.Z > 50 && !bSurfaceSwimming)
	{
		Anim = 'SwimUnderWaterUp';
	}
	else if(Acceleration.Z < -50 && !bSurfaceSwimming)
	{
		Anim = 'SwimUnderWaterDown';
	}

	LoopAnim(Anim, 1.0, 0.3);	

	if(AnimProxy != None)
		AnimProxy.TryLoopAnim(Anim, 1.0, 0.3);
}

//=============================================================================
//
// TweenToSwimming
//
//=============================================================================

function TweenToSwimming(float tweentime)
{
	PlaySwimming();
}

//=============================================================================
//
// PlayRopeIdle
//
//=============================================================================

function PlayRopeIdle()
{
	LoopAnim('ropetest');	
	if(AnimProxy != None)
		AnimProxy.LoopAnim('ropetest');	
}

//=============================================================================
//
// TryPlayTorsoAnim
//
// Attempts to play the torso anim on the legs.
//=============================================================================

function TryPlayTorsoAnim(name TorsoAnim, float speed, float tween)
{
	DoTryPlayTorsoAnim(TorsoAnim, speed, tween);
	ClientTryPlayTorsoAnim(TorsoAnim);
}

simulated function ClientTryPlayTorsoAnim(name TorsoAnim)
{
	DoTryPlayTorsoAnim(TorsoAnim, 1.0, 0.01);
}

simulated function DoTryPlayTorsoAnim(name TorsoAnim, float speed, float tween)
{
	local vector X, Y, Z;
	local float dp;

	if(AnimProxy != None && AnimProxy.GetStateName() == 'Attacking' && Weapon != None)
	{
		// Determine the direction the player is attempting to move
		GetAxes(Rotation, X, Y, Z);
		dp = vector(Rotation) dot Normal(Acceleration);

		if(dp > 0.9 || dp < -0.9)
		{ // Distinctly forward or backward
			if(TorsoAnim == Weapon.A_AttackA || TorsoAnim == Weapon.A_AttackAReturn
				|| TorsoAnim == Weapon.A_AttackB // Note that AttackBReturn is NOT played on the legs to avoid sliding
				|| TorsoAnim == Weapon.A_AttackC || TorsoAnim == Weapon.A_AttackCReturn
				|| TorsoAnim == Weapon.A_AttackBackupA || TorsoAnim == Weapon.A_AttackBackupAReturn
				|| TorsoAnim == Weapon.A_AttackBackupB || TorsoAnim == Weapon.A_AttackBackupBReturn
				|| TorsoAnim == Weapon.A_JumpAttack)
			{
				PlayAnim(TorsoAnim, speed, tween);	
				return;
			}
		}
	}
/*
	if(GetGroup(AnimSequence) == 'Moving')
	{
		return;
	}
*/
	// Check Ragnar's movement with the movement on the weapon
	if(Weapon != None)
	{
		if(AnimSequence == Weapon.A_Forward
			|| AnimSequence == Weapon.A_Backward
			|| AnimSequence == Weapon.A_StrafeLeft
			|| AnimSequence == Weapon.A_StrafeRight
			|| AnimSequence == Weapon.A_Forward45Left
			|| AnimSequence == Weapon.A_Forward45Right
			|| AnimSequence == Weapon.A_Backward45Left
			|| AnimSequence == Weapon.A_Backward45Right
			|| AnimSequence == Weapon.A_Jump
			|| AnimSequence == Weapon.A_ForwardAttack)
		{ // Playing a movement animation
			return;
		}
	}
	
	PlayAnim(TorsoAnim, speed, tween);
}

// ----- LOOK Code -----

simulated function float ScoreLookActor(Actor A)
{
	local float score;
	local rotator r;
	local vector vectA, vectR;
	local float angle;
	
	vectA = A.Location - Location;
	r.Pitch = 0;
	r.Yaw = Rotation.Yaw;
	r.Roll = 0;
	vectR = vector(r);	
	
	angle = (Normal(vectA) dot vectR);
	
	if(angle < PeripheralVision)
	{
		return(9999999.0);
	}
	
	score = VSize(vectA) * (2.0 - angle);

	if(A.IsA('Pawn'))
	{
		score *= 0.5;
	}
	else if(A.IsA('LookTarget'))
	{
		score *= 0.25;
	}
			
	return(score);
}

//=============================================================================
//
// DetermineLookFocus
//
// Checks for the ideal actor for the player's focus
// TODO:
//	- Object priorities
//	- Proper distance usage
//  - Angle from RunePlayer(Owner) to object
//	- Special "chasing actor" mode that allows the player to look backwards
//=============================================================================
simulated function DetermineLookFocus()
{
	local Actor A;
	local float bestScore;
	local Actor bestActor;
	local float score;
	local vector delta;

	bestScore = 9999999.0;	
	bestActor = None;

	if (Health < 0)
		return;

	foreach VisibleActors(class'actor', A, 1000, Location)
	{
		if(A == self || A.Owner == self)
			continue;
		
		if(A.bLookFocusPlayer)
		{
			score = ScoreLookActor(A);
			if(score < bestScore)
			{
				bestScore = score;
				bestActor = A;
			}
		}
	}	
	LookTarget = bestActor;
	LookSpot = vect(0,0,0);

/*
	if(bestActor == None && Weapon==None)
	{
		LookSpot = Location + 100 * vector(DesiredRotation);
	}
*/
/* Uncomment this to make player look at the dropped camera spot -- a little weird right now
	if(bestActor == None && bCameraLock)
	{
		LookSpot = SavedCameraLoc;
	}
*/
}



function bool FindInventoryItem(Inventory testItem)
{
	local inventory Inv;

	if(testItem == None)
		return(true);

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if( Inv == testItem)
			return(true);

	return(false);
}

//=============================================================================
//
// Tick
//
//=============================================================================

simulated event Tick(float DeltaTime)
{
	local int i;
	local texture tex;

	// Update look target
	DetermineLookFocus();

	// Update Camera Timer
	CurrentTime += DeltaTime / Level.TimeDilation;

	// Atrophy Strength
	StrengthDecay(DeltaTime);

	// Handle level fade in
	if (LevelFadeAlpha > 0)
	{
		LevelFadeAlpha -= DeltaTime * Level.FadeRate;
		if (LevelFadeAlpha < 0)
			LevelFadeAlpha = 0;
	}

/*
	// DEBUG! DEBUG! DEBUG! DEBUG!
	// DEBUG! DEBUG! DEBUG! DEBUG!
	// DEBUG! DEBUG! DEBUG! DEBUG!
	// Iterate through the players inventory and if it mismatches with the what the 
	// player has in his hands/stowed, then print a warning message!

	if(Level.NetMode != NM_Client)
	{	// Client's may not receive the property for a few ticks

		if(!FindInventoryItem(Weapon) || !FindInventoryItem(Shield)
			|| !FindInventoryItem(StowSpot[0]) || !FindInventoryItem(StowSpot[1])
			|| !FindInventoryItem(StowSpot[2]))
		{
			Slog("WARNING!!  Inventory mismatch.  Pause the game and find a programmer IMMEDIATELY!");
		}
	}

	// DEBUG! DEBUG! DEBUG! DEBUG!
	// DEBUG! DEBUG! DEBUG! DEBUG!
	// DEBUG! DEBUG! DEBUG! DEBUG!
*/

	Super.Tick(DeltaTime);
}


//-----------------------------------------------------------------------------
// Utility functions

//=============================================================================
//
// SetMovementMode
//
//=============================================================================

function SetMovementMode()
{
	if(Weapon != None)
	{ // Combat Mode
//		GroundSpeed = CombatSpeed;
		bRotateTorso = False;

		if(Level.NetMode != NM_Standalone)
			SpeedScale = SS_Circular; // No elliptical movement in netplay
		else
			SpeedScale = SS_Elliptical;
	}
	else
	{ // Exploration Mode
//		GroundSpeed = ExploreSpeed;
		bRotateTorso = True;
		SpeedScale = SS_Circular;
	}
}

function SetCrouchHeight()
{
	local vector newloc;
	local float offset;

	SetCollisionSize(CollisionRadius, CrouchHeight);

	// Adjust so player is standing on ground
	offset = default.CollisionHeight - CrouchHeight;
	newloc = Location;
	newloc.Z -= offset;
	SetLocation(newloc);
	PrePivot.Z += offset;
	BaseEyeHeight = (CrouchHeight/Default.CollisionHeight) * Default.BaseEyeHeight;
}

function SetNormalHeight()
{
	local vector newloc;
	local float offset;

	SetCollisionSize(CollisionRadius, default.CollisionHeight);

	// Adjust so player is standing on ground
	offset = default.CollisionHeight - CrouchHeight;
	newloc = Location;
	newloc.Z += offset;
	SetLocation(newloc);
	PrePivot.Z += offset;
	BaseEyeHeight = Default.BaseEyeHeight;
}

function bool CanStandUp()
{
	local vector end, extent;
	local vector HitLocation, HitNormal;

	end = Location;
	end.Z += CollisionHeight + CrouchHeight; // Generous fudge factor

	extent.X = CollisionRadius;
	extent.Y = CollisionRadius;
	extent.Z = 8;

	if(Trace(HitLocation, HitNormal, end, Location, true, extent) == None)
	{
		return(true);
	}
	
	return(false);
}

//=============================================================================
//
// SetCrouch
//
//=============================================================================

function SetCrouch(bool crouch)
{
	if(crouch)
	{ // Set to explore mode all the time while crouching (with the exception of not rotating the torso)
		GroundSpeed = ExploreSpeed;
		bRotateTorso = False;
		SpeedScale = SS_Circular;		
		SetCrouchHeight();
		bIsCrouching = true;

		// Play CrouchSound
		PlaySound(CrouchSound, SLOT_Interact, 1.0, false, 1200, FRand() * 0.08 + 0.96);
	}
	else if(bIsCrouching)
	{
		if(CanStandUp())
		{ // Check if standing up is acceptable
			SetMovementMode();
			SetNormalHeight();
			bIsCrouching = false;
		}
		else
		{
			bIsCrouching = true;
		}
	}
}

//=============================================================================
//
// PlayerCalcView
//
//=============================================================================

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist, WallOutDist;

	local vector PlayerLocation;
	local vector loc;
	local rotator rot;
	local vector desiredLoc;
	local vector currentLoc;
	local vector cameraVect, newVect;
	local float accel;
	local float deltaTime;
	local vector startPt;
	local vector endPt;
	local bool done;
	local float desiredDist;
	local float diff;
	local rotator targetangle;
	
	local vector extent; // trace extent
	
	// Calculate time change
	deltaTime = CurrentTime - LastTime;

	// View rotation.
	ViewActor = Self;

	// Handle view shaking
	ViewShake(deltaTime);
	targetAngle = ViewRotation + ShakeDelta;
	
	PlayerLocation = Location + PrePivot;

	if(Region.Zone != None && Region.Zone.bTakeOverCamera)
	{
		CameraLocation = Region.Zone.Location;
		loc = PlayerLocation;
		loc.Z += EyeHeight;
		CameraRotation = rotator(loc - CameraLocation);
		ViewLocation = CameraLocation;
		return;
	}

	if(RemoteRole != ROLE_AutonomousProxy && (deltaTime < 0.1 && deltaTime > 0))
	{ // Local Player Only (deltaTime == 0.0 for remote players on the server)
		// Interpolate Yaw
		targetAngle.Yaw = targetAngle.Yaw & 65535;
		CurrentRotation.Yaw = CurrentRotation.Yaw & 65535;
		diff = targetAngle.Yaw - CurrentRotation.Yaw;
		if(abs(diff) > 32768)
		{ // Handle wrap around case
			if(targetAngle.Yaw > 32768)
			{
				targetAngle.Yaw -= 65536;;
			}
			else
			{
				targetAngle.Yaw += 65536;
			}
			
			diff = targetAngle.Yaw - CurrentRotation.Yaw;
		}	

		if(abs(diff) < 10)
		{
			CurrentRotation.Yaw = targetAngle.Yaw;
		}
		else
		{		
			CurrentRotation.Yaw += deltaTime * diff * CameraRotSpeed.Yaw;
			
			if((diff < 0 && CurrentRotation.Yaw < targetAngle.Yaw)
				|| (diff > 0 && CurrentRotation.Yaw > targetAngle.Yaw))
			{ // Guard against overshooting targetangle
				CurrentRotation.Yaw = targetAngle.Yaw;
			}		
		}

		// Interpolate Pitch
		targetAngle.Pitch = targetAngle.Pitch & 65535;
		CurrentRotation.Pitch = CurrentRotation.Pitch & 65535;
		diff = targetAngle.Pitch - CurrentRotation.Pitch;
		if(abs(diff) > 32768)
		{ // Handle wrap around case
			if(targetAngle.Pitch > 32768)
			{
				targetAngle.Pitch -= 65536;;
			}
			else
			{
				targetAngle.Pitch += 65536;
			}
			
			diff = targetAngle.Pitch - CurrentRotation.Pitch;
		}	
		if(abs(diff) < 10)
		{
			CurrentRotation.Pitch = targetAngle.Pitch;
		}
		else
		{		
			CurrentRotation.Pitch += deltaTime * diff * CameraRotSpeed.Pitch;
			
			if((diff < 0 && CurrentRotation.Pitch < targetAngle.Pitch)
				|| (diff > 0 && CurrentRotation.Pitch > targetAngle.Pitch))
			{ // Guard against overshooting targetangle
				CurrentRotation.Pitch = targetAngle.Pitch;
			}		
		}
		
		// Interpolate Roll
		targetAngle.Roll = targetAngle.Roll & 65535;
		CurrentRotation.Roll = CurrentRotation.Roll & 65535;
		diff = targetAngle.Roll - CurrentRotation.Roll;
		if(abs(diff) > 32768)
		{ // Handle wrap around case
			if(targetAngle.Roll > 32768)
			{
				targetAngle.Roll -= 65536;;
			}
			else
			{
				targetAngle.Roll += 65536;
			}
			
			diff = targetAngle.Roll - CurrentRotation.Roll;
		}	
		if(abs(diff) < 10)
		{
			CurrentRotation.Roll = targetAngle.Roll;
		}
		else
		{		
			CurrentRotation.Roll += deltaTime * diff * CameraRotSpeed.Roll;
			
			if((diff < 0 && CurrentRotation.Roll < targetAngle.Roll)
				|| (diff > 0 && CurrentRotation.Roll > targetAngle.Roll))
			{ // Guard against overshooting targetangle
				CurrentRotation.Roll = targetAngle.Roll;
			}		
		}
	}
	else
	{ // No interpolation
		targetAngle.Yaw = targetAngle.Yaw & 65535;
		targetAngle.Pitch = targetAngle.Pitch & 65535;
		targetAngle.Roll = targetAngle.Roll & 65535;

		CurrentRotation = targetAngle;
	}

	CameraRotation = CurrentRotation;

	if(bBehindView && !bCameraLock && !bCameraOverhead)
	{
		if(CameraRotation.Pitch < 32768 && CameraRotation.Pitch > 12000)
		{ // Clamp the camera to a given set of angles [should be done in control functions?]
			CameraRotation.Pitch = 12000;
		}

		WallOutDist = 15;
		rot = CameraRotation;
		endPt = PlayerLocation;

		ViewDist = CameraDist;
		if(Region.Zone.MaxCameraDist >= CollisionRadius)
		{ // Zone-based camera distance
			ViewDist = Region.Zone.MaxCameraDist;
		}

		rot.Pitch -= CameraPitch;
		endPt.Z += CameraHeight;

		View = vect(1,0,0) >> rot;

	    startPt = PlayerLocation;
	    if(Trace(HitLocation, HitNormal, endPt, startPt) != None)
		{
			loc = HitLocation;
		}
		else
		{
			loc = endPt;
		}

		if(RemoteRole != ROLE_AutonomousProxy && (deltaTime < 0.1 && deltaTime > 0))
		{ // Do interpolation of CurrentDist.  
			// Local Player Only (deltaTime == 0.0 for remote players on the server)
			diff = abs(CurrentDist - ViewDist);
			if(diff > 30)
			{
				diff = 30;
			}
			else if(diff < 0.25)
			{ // Close enough, force the camera to the desired position
				CurrentDist = ViewDist;
			}
			
			if(CurrentDist < ViewDist)
			{
				CurrentDist += deltaTime * diff * 10;
				if(CurrentDist > ViewDist)
				{
					CurrentDist = ViewDist;
				}
			}
			else if(CurrentDist > ViewDist)
			{
				CurrentDist -= deltaTime * diff * 10;
				if(CurrentDist < ViewDist)
				{
					CurrentDist = ViewDist;
				}
			}
		}
		else
		{
			CurrentDist = ViewDist;
		}

		cameraVect = (loc - OldCameraStart);
		accel = (ViewDist / CurrentDist) * CameraAccel;
		if(RemoteRole != ROLE_AutonomousProxy && (deltaTime < 0.1 && deltaTime > 0))
		{ // Local Player Only (deltaTime == 0.0 for remote players on the server)
			newVect = cameraVect * deltaTime * accel;
			if(VSize(newVect) < VSize(cameraVect))
				cameraVect = newVect;

			loc = OldCameraStart + cameraVect;
		}
		// Otherwise, loc is not interpolated

	    endPt = loc - (CurrentDist + WallOutDist) * vector(rot);
	    startPt = loc;

	    if(Trace(HitLocation, HitNormal, endPt, startPt) != None)
		{
			CurrentDist = FMin((loc - HitLocation) dot View, CurrentDist);
		}

		if(CurrentDist < WallOutDist)
		{ // Camera pulled in so close that the view should just go first person
			CurrentDist = WallOutDist;

			if(bGotoFP)
				bBehindView = false;
		}

		CameraLocation = loc - (CurrentDist - WallOutDist) * View;
		
		OldCameraStart = loc;

		// Set Tranlucency on local player if too close to a wall
		if (CurrentDist > TranslucentDist)
			SetClientAlpha(1.0);
		else
			SetClientAlpha(CurrentDist/TranslucentDist);
	}
	else if(bBehindView && bCameraLock)
	{
		loc = PlayerLocation;
		loc.Z += EyeHeight;
		CameraLocation = SavedCameraLoc;
		CameraRotation = rotator(loc - CameraLocation) + ShakeDelta;
	}
	else if(bBehindView && bCameraOverhead)
	{
		CameraLocation = PlayerLocation;
		CameraLocation.Z += (CameraDist - 50) * 10;
		
		CameraRotation.Pitch = -16384;
		CameraRotation.Yaw = Rotation.Yaw;
		CameraRotation.Roll = 0;		
	}
	else
	{
		// First-person view.
		CameraRotation = ViewRotation + ShakeDelta;
		CameraLocation = Location;
		CameraLocation.Z += EyeHeight;
		CameraLocation += WalkBob;
//		CameraRotation = GetJointRot(JointNamed('head'));	// too jerky, but cool
//		CameraLocation = GetJointPos(JointNamed('head'));	// too jerky
		OldCameraStart = CameraLocation;

		if(!bGotoFP)
		{ // Return from first-person
			bBehindView = true;
		}
	}

	SavedCameraRot = CameraRotation;
	SavedCameraLoc = CameraLocation;
	
	// Handle view target.  Done AFTER other code, so that SavedLoc/Rot are updated
	if(ViewTarget != None)
	{
		SetClientAlpha(1.0);
		ViewActor = ViewTarget;
		CameraLocation = ViewTarget.Location;
		CameraRotation = ViewTarget.Rotation + ShakeDelta; // Add in effect of earthquakes
		if(Pawn(ViewTarget) != None)
		{
			if((Level.NetMode == NM_StandAlone)	&& (ViewTarget.IsA('PlayerPawn')))
			{
				CameraRotation = Pawn(ViewTarget).ViewRotation;
			}

			CameraLocation.Z += Pawn(ViewTarget).EyeHeight;
		}
	}

	ViewLocation = CameraLocation;

	LastTime = CurrentTime;
}

//=============================================================================
//
// Touch
//
//=============================================================================

function Touch(Actor Other)
{
	local vector HandPos, pos;
	LookTarget = Other;
	Super.Touch(Other);

	if(Rope(Other) != None
		&& !Rope(Other).bActorAttached
		&& (Physics == PHYS_Falling || Physics == PHYS_Swimming)
		&& GetStateName() != 'PlayerRopeClimbing')
	{ // Only grab the rope if the player can and if the player is in the air/swimming
		HandPos = Location;
		HandPos.Z += HandOffset;

		TheRope = Rope(Other);
		TheRope.ComputeClimbingEndpoints(HandPos.Z);

		if (HandPos.Z < TheRope.RopeClimbBottom.Z)
			return;

		TheRope.AttachedToRope(self);

		// Make sure right on rope
		pos = TheRope.Location;
		pos.Z = Location.Z;
		SetLocation(pos);

		Acceleration = vect(0, 0, 0);
		Velocity = vect(0, 0, 0);
		RopeDist = TheRope.RopeClimbTop.Z - HandPos.Z;

		GotoState('PlayerRopeClimbing');
	}	
}

//=============================================================================
//
// DoJump
//
//=============================================================================

function DoJump( optional float F )
{	
	if(!bIsCrouching && (Physics == PHYS_Walking))
	{
		if ( Role == ROLE_Authority )
			PlaySound(JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
		if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
			MakeNoise(0.1 * Level.Game.Difficulty);

		PlayJump();

		Velocity.Z = JumpZ;

		if(Base != None && Base != Level)
		{
			Velocity.Z += Base.Velocity.Z; 
		}

		SetPhysics(PHYS_Falling);

		if(bCountJumps && (Role == ROLE_Authority) && Inventory != None)
		{
			Inventory.OwnerJumped();
		}
	}
}

//=============================================================================
//
// HitWall
//
//=============================================================================

function HitWall( vector HitNormal, actor HitWall )
{
/*	if (bBounce)
	{
		// Just landed on tarp: do whatever bounce animation you want
	}
*/
}

//------------------------------------------------------------
//
// BoostStrength
//
//------------------------------------------------------------

function BoostStrength(int amount)
{
	if(bBloodLust)
		return;

	Strength += amount;
	if (Strength >= MaxStrength)
	{
		bBloodlust = true;

		PlaySound(BerserkSoundStart, SLOT_None, 1.0);
		AmbientSound = BerserkSoundLoop;

		Strength = MaxStrength;
		DesiredPolyColorAdjust.X = 255;
		DesiredPolyColorAdjust.Y = 128;
		DesiredPolyColorAdjust.Z = 128;
		Spawn(Class'BloodlustStart', self,, Location, Rotation);

		if(BloodLustEyes != None)
			BloodLustEyes.bHidden = false;

		ShakeView(1, 100, 0.25);
	}
}

//------------------------------------------------------------
//
// StrengthDecay
//
//------------------------------------------------------------

function StrengthDecay(float Time)
{
	local float StrengthAtrophy;	// Time to atrophy 1 strength pt

	if (Strength > 0)
	{
		if(bBloodLust)
		{
			StrengthAtrophy = 0.2;
		}
		else
		{
			StrengthAtrophy = 1;
			if ( (Level.NetMode == NM_StandAlone) && (Level.Game != None) )
			{
				switch(Level.Game.Difficulty)
				{
					case 0:
						StrengthAtrophy = 1;
						break;
					case 1:
						StrengthAtrophy = 1;
						break;
					case 2:
						StrengthAtrophy = 0.5;
						break;
					case 3:
						StrengthAtrophy = 0.5;
						break;
				}
			}
		}

		AtrophyTimer += Time;
		if (AtrophyTimer > StrengthAtrophy)
		{
			AtrophyTimer = 0;
			Strength--;
				
			if(bBloodlust && Strength == 0)
			{
				bBloodlust = false;
				DesiredPolyColorAdjust.X = 255;
				DesiredPolyColorAdjust.Y = 255;
				DesiredPolyColorAdjust.Z = 255;
				Spawn(Class'BloodlustStart', self,, Location, Rotation);

				PlaySound(BerserkSoundEnd, SLOT_None, 1.0);
				AmbientSound = None;

				if(BloodLustEyes != None)
					BloodLustEyes.bHidden = true;
			}
		}
	}
}

//------------------------------------------------------------
//
// PawnDamageModifier
//
// Returns the modification of the damage amount 
// Used to increase damage for special attacks, or reduce damage
// for simple attack types
//------------------------------------------------------------

function float PawnDamageModifier(Weapon w)
{
	local float ContextBonus, DifficultyBonus, StrengthBonus;

	ContextBonus = 1.0;
	if(AnimProxy != None && Weapon != None)
	{
		if(w.GetStateName() == 'Throw')
		{	// Thrown
			ContextBonus = 1.5;
		}
		else if(AnimProxy.AnimSequence == Weapon.A_JumpAttack)
		{	// Jump Attack
			ContextBonus = 1.25;
		}
		else if(AnimProxy.AnimSequence == Weapon.A_AttackStrafeRight
			|| AnimProxy.AnimSequence == Weapon.A_AttackStrafeLeft)
		{	// Strafe Left/Right
			ContextBonus = 0.6;
		}
		else if(AnimProxy.AnimSequence == Weapon.A_AttackBackupA
			|| AnimProxy.AnimSequence == Weapon.A_AttackBackupB)
		{	// Backup attacks
			ContextBonus = 0.6;
		}
		else if(AnimProxy.AnimSequence == weapon.A_AttackB || AnimProxy.AnimSequence == weapon.A_AttackStandB)
		{ // Increase damage for combos
			ContextBonus = 1.15;
		}
		else if(AnimProxy.AnimSequence == weapon.A_AttackC || AnimProxy.AnimSequence == weapon.A_AttackD)
		{ // Increase damage much more for more extreme combos
			ContextBonus = 1.25;
		}
	}

	DifficultyBonus	= FClamp(2.0 * (2-Level.Game.Difficulty) * 0.5, 0, 2.0);
	if (bBloodLust)
		StrengthBonus = 1.0;
	else
		StrengthBonus = (float(Strength) / float(MaxStrength)) * 0.2;

	return(ContextBonus + DifficultyBonus + StrengthBonus);
}

//------------------------------------------------------------
//
// ViewShake
//
//------------------------------------------------------------

function ViewShake(float DeltaTime)
{
	if(shaketimer > 0.0)
	{	
		shaketimer -= DeltaTime;
		
		if(shaketimer <= 0)
		{
			ShakeDelta = rot(0, 0, 0);
			return;
		}

		if(shaketimer <= maxshake)
		{		
			verttimer -= DeltaTime * (float(shakemag) / maxshake);
			if(verttimer <= 0)
				verttimer = 0;
		}
		else
		{
			verttimer = shakemag;
		}
			
		ShakeDelta.Pitch = (100 * verttimer * (FRand() - 0.5)) * DeltaTime;
		ShakeDelta.Yaw = (100 * verttimer * (FRand() - 0.5)) * DeltaTime;
		ShakeDelta.Roll = (100 * verttimer * (FRand() - 0.5)) * DeltaTime;
	}
}


//-----------------------------------------------------------------------------
//	Powerup functions

function PowerupFire(Pawn EventInstigator)
{
	local int i;

	if (Level.Game!=None && Level.Game.bTeamGame && EventInstigator.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
		return;

	// Set all collision joints on fire
	for (i=0; i<NumJoints(); i++)
	{
		if ((JointFlags[i] & JOINT_FLAG_COLLISION)!=0)
			SetOnFire(EventInstigator, i);
	}
}
function PowerupBlaze(Pawn EventInstigator)
{
	local int i;

	if (Level.Game!=None && Level.Game.bTeamGame && EventInstigator.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
		return;

	// Set all collision joints on fire
	for (i=0; i<NumJoints(); i++)
	{
		if ((JointFlags[i] & JOINT_FLAG_COLLISION)!=0)
		{
			SetOnFire(EventInstigator, i);
		}
	}
}
function PowerupStone(Pawn EventInstigator)
{
	if (Level.Game!=None && Level.Game.bTeamGame && EventInstigator.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
		return;
	StatueInstigator = EventInstigator;		// For giving kill credit
	PlaySound(Sound'WeaponsSnd.Powerups.atfreezestone01', SLOT_Interface);
	GotoState('Statue');
}
function PowerupIce(Pawn EventInstigator)
{
	if (Level.Game!=None && Level.Game.bTeamGame && EventInstigator.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
		return;
	
	PlaySound(Sound'WeaponsSnd.Powerups.atfreezeice01', SLOT_Interface);
	GotoState('IceStatue');
}
function PowerupFriend(Pawn EventInstigator)
{
	if (Level.Game!=None && Level.Game.bTeamGame && EventInstigator.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
		return;
}
function UnPowerupFriend()
{
}
function PowerupElectricity(Pawn EventInstigator)
{
	if (Level.Game!=None && Level.Game.bTeamGame && EventInstigator.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
		return;
}


//-----------------------------------------------------------------------------
// Exec functions

exec function Damage( string parms)
{
	local actor A;
	local string bp;
	local int damage;
	local class<actor> aClass;
	local string ClassName;
	local int BodyPart;

	damage = 10;
	ClassName = GetToken(parms);
	BodyPart = int(GetToken(parms));

	if( instr(ClassName,".")==-1 )
		ClassName = "RuneI." $ ClassName;

	aClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if (aClass != None)
	{
		switch(BodyPart)
		{
			case BODYPART_BODY: bp="Body"; break;
			case BODYPART_LARM1: bp="LeftArm1"; break;
			case BODYPART_LARM2: bp="LeftArm2"; break;
			case BODYPART_RARM1: bp="RightArm1"; break;
			case BODYPART_RARM2: bp="RightArm2"; break;
			case BODYPART_HEAD: bp="Head"; break;
			case BODYPART_LLEG1: bp="LeftLeg1"; break;
			case BODYPART_LLEG2: bp="LeftLeg2"; break;
			case BODYPART_RLEG1: bp="RightLeg1"; break;
			case BODYPART_RLEG2: bp="RightLeg2"; break;
			case BODYPART_TORSO: bp="Torso"; break;
			case BODYPART_MISC1: bp="Misc1"; break;
			case BODYPART_MISC2: bp="Misc2"; break;
			case BODYPART_MISC3: bp="Misc3"; break;
			case BODYPART_MISC4: bp="Misc4"; break;
			default: return;
		}

		foreach AllActors(aClass, A)
		{
			slog("Applying"@damage@"to bodypart"@bp@"of"@A.name);
			A.DamageBodyPart(10, self, A.Location, vect(0,0,0), 'sever', BodyPart);
		}
	}
}

exec function CheckMatter()
{
	local vector X,Y,Z;
	local vector HL, HN;
	local vector start, end;
	local actor A,B;
	local texture hitTexture;
	local EMatterType matter;
	local string mattertext;

	GetAxes(ViewRotation,X,Y,Z);
	start = Location;
	end = start + X*5000;	
	matter = MatterTrace(end, start, 10, hitTexture);

	switch(matter)
	{
		case MATTER_NONE:				mattertext="MATTER_NONE";				break;
		case MATTER_WOOD:				mattertext="MATTER_WOOD";				break;
		case MATTER_METAL:				mattertext="MATTER_METAL";				break;
		case MATTER_STONE:				mattertext="MATTER_STONE";				break;
		case MATTER_FLESH:				mattertext="MATTER_FLESH";				break;
		case MATTER_ICE:				mattertext="MATTER_ICE";				break;
		case MATTER_WATER:				mattertext="MATTER_WATER";				break;
		case MATTER_EARTH:				mattertext="MATTER_EARTH";				break;
		case MATTER_SNOW:				mattertext="MATTER_SNOW";				break;
		case MATTER_BREAKABLEWOOD:		mattertext="MATTER_BREAKABLEWOOD";		break;
		case MATTER_BREAKABLESTONE:		mattertext="MATTER_BREAKABLESTONE";		break;
		case MATTER_SHIELD:				mattertext="MATTER_SHIELD";				break;
		case MATTER_WEAPON:				mattertext="MATTER_WEAPON";				break;
		case MATTER_MUD:				mattertext="MATTER_MUD";				break;
		case MATTER_LAVA:				mattertext="MATTER_LAVA";				break;
	}

	if (Weapon != None)
		Weapon.PlayHitMatterSound(matter);

	slog("Matter for"@hitTexture@"is"@mattertext);
}

exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	if( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	if( instr(ClassName,".")==-1 )
		ClassName = "RuneI." $ ClassName;
	Super.Summon( ClassName );
}

exec function BehindView( Bool B )
{
	// In this function, the bool B is ignored, so that this function acts as a toggle
	if(Level.NetMode == NM_Client)
		return;

	if (CameraDist == 0)
	{	// in first person, zoom out
		CameraDist = 120;
		bGotoFP = false;
		bBehindView = true;
	}
	else
	{	// in third person, zoom in
		CameraDist = 0;
		bGotoFP = true;
	}
}

exec function CameraIn()
{
	if(Level.NetMode == NM_Client)
		return;

	bGotoFP = false;
	CameraDist -= 60;
	if(CameraDist < 120)
	{ // Pull into first person
		CameraDist = 0;
		bGotoFP = true;
	}
}

exec function CameraOut()
{
	if(Level.NetMode == NM_Client)
		return;

	bGotoFP = false;
	CameraDist += 60;
	if(CameraDist > 240)
	{
		CameraDist = 240;
	}
	else if(CameraDist < 120)
	{
		bBehindView = true;
		CameraDist = 120;
	}
}

exec function ZTargetToggle()
{
	local float ZDist;

	if(Level.Netmode != NM_Standalone)
		return; // Disallow ztarget in multiplayer

	if(ZTarget == None)
	{
		if(LookTarget.IsA('Pawn'))
		{
			ZDist = VSize(LookTarget.Location - Location);
			if(ZDist <= ZTARGET_DIST)
			{
				ZTarget = Pawn(LookTarget);
			}
		}
	}
	else
	{
		ZTarget = None;
	}
}


exec function DumpWeaponInfo()
{
	if(Weapon == None)
		return;

	slog("----------------------------");
	slog("  WEAPON:  "$Weapon);
	slog("  A_Idle: " $Weapon.A_Idle);
	slog("  A_Forward: " $Weapon.A_Forward);
	slog("  A_Backward: " $Weapon.A_Backward);
	slog("  A_Forward45Right: " $Weapon.A_Forward45Right);
	slog("  A_Forward45Left: " $Weapon.A_Forward45Left);
	slog("  A_Backward45Right: " $Weapon.A_Backward45Right);
	slog("  A_Backward45Left: " $Weapon.A_Backward45Left);
	slog("  A_StrafeRight: " $Weapon.A_StrafeRight);
	slog("  A_StrafeLeft: " $Weapon.A_StrafeLeft);
	slog("  A_AttackA: " $Weapon.A_AttackA);
	slog("  A_AttackAReturn: " $Weapon.A_AttackAReturn);
	slog("  A_AttackB: " $Weapon.A_AttackB);
	slog("  A_AttackBReturn: " $Weapon.A_AttackBReturn);
	slog("  A_AttackC: " $Weapon.A_AttackC);
	slog("  A_AttackCReturn: " $Weapon.A_AttackCReturn);
	slog("  A_AttackD: " $Weapon.A_AttackD);
	slog("  A_AttackDReturn: " $Weapon.A_AttackDReturn);
	slog("  A_AttackStandA: " $Weapon.A_AttackStandA);
	slog("  A_AttackStandAReturn: " $Weapon.A_AttackStandAReturn);
	slog("  A_AttackStandB: " $Weapon.A_AttackStandB);
	slog("  A_AttackStandBReturn: " $Weapon.A_AttackStandBReturn);
	slog("  A_AttackBackupA: " $Weapon.A_AttackBackupA);
	slog("  A_AttackBackupAReturn: " $Weapon.A_AttackBackupAReturn);
	slog("  A_AttackBackupB: " $Weapon.A_AttackBackupB);
	slog("  A_AttackBackupBReturn: " $Weapon.A_AttackBackupBReturn);
	slog("  A_AttackStrafeRight: " $Weapon.A_AttackStrafeRight);
	slog("  A_AttackStrafeLeft: " $Weapon.A_AttackStrafeLeft);
	slog("  A_Throw: " $Weapon.A_Throw);
	slog("  A_Defend: " $Weapon.A_Defend);
	slog("  A_DefendIdle: " $Weapon.A_DefendIdle);
	slog("  A_PainFront: " $Weapon.A_PainFront);
	slog("  A_PainBack: " $Weapon.A_PainBack);
	slog("  A_PainLeft: " $Weapon.A_PainLeft);
	slog("  A_PainRight: " $Weapon.A_PainRight);
	slog("  A_PickupGroundLeft: " $Weapon.A_PickupGroundLeft);
	slog("  A_PickupHighLeft: " $Weapon.A_PickupHighLeft);
	slog("  A_Taunt: " $Weapon.A_Taunt);
	slog("  A_PumpTrigger: " $Weapon.A_PumpTrigger);
}

//=============================================================================
//
// DropZ
//
// TEST FUNCTION
//=============================================================================

exec function DropZ()
{
	local vector newLoc;
	local vector dropLoc;
	local vector HitLocation;
	local vector HitNormal;
	local vector X, Y, Z;
	local vector result;

	dropLoc = Location - vect(0, 0, 200);

	if(Trace(HitLocation, HitNormal, dropLoc, Location, false, vect(0, 0, 0)) != None)
	{
		Slog("HitZ: " $ HitNormal.Z);
	}

	// TEST slope calculation
	GetAxes(Rotation, X, Y, Z);

	result = Y cross HitNormal;

	SLog("Rot:  " $ (rotator(result)));

	DropZFloor = HitNormal;
	DropZRag = Y;
	DropZResult = result;
	DropZRoll = result cross HitNormal;
}

//=============================================================================
//
// TraceTex
//
//=============================================================================

exec function TraceTex()
{
	local vector newLoc;
	local vector X, Y, Z;
	local texture Tex;
	local int flags;
	local vector ScrollDir;

	GetAxes(Rotation, X, Y, Z);
	newLoc = Location - Z * 100;

	SLog("TraceTex Start:  " $ Location);
	SLog("TraceTex End:  " $ newLoc);

	Tex = TraceTexture(newLoc, Location, flags, ScrollDir);
	if(Tex != None)
	{
		Slog("Texture Material: " $ Tex.TextureMaterial);
		SLog("ScrollDir:  " $ ScrollDir);
	}
}

//=============================================================================
//
// Throw
//
//=============================================================================

exec function Throw()
{
	if(Weapon == None)
		return;

	if( bShowMenu || (Level.Pauser!="")) // || (Role < ROLE_Authority) )
		return;

	if(AnimProxy != None && AnimProxy.Throw())
		PlayAnim('ATK_ALL_throw1_AA0S', 1.0, 0.1);
}

//=============================================================================
//
// Use
//
//=============================================================================

exec function Use()
{
	local actor A;
	local vector v;
	local float dist;
	local float bestDist;
	local name useAnim;
	local int bestPriority;
	local int priority;

	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) || Health<=0)
		return;

	if(AnimProxy != None)
	{ // Can only use if the animation proxy is not busy
		if(AnimProxy.GetStateName() != 'Idle')
			return;
	}

	if(Physics != PHYS_Walking || (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y >= 1500))
	{ // Test:  Only allow Ragnar to pick things up if he's standing still and on the ground
		return;
	}

	// See if other actors want the use message
	bestDist = 999999.0;
	bestPriority = 999;
	UseActor = None;
	foreach RadiusActors(class'actor', A, 100, Location)
	{
/* Pickup Priority
		-1. Weapons	- 360 degree pickup
		-2. Shields	- 360 degree pickup
		-3. Food		- 360 degree pickup
		-4. Runes	- 360 degree pickup
		-5. Switches - 90 degree usage
		-6. Limbs	- 360 degree pickup
		-7. Kicking objects - 90 degree usage
		-8. Relighting torches - 90 degree usage
*/
				
		if(A.CanBeUsed(self))
		{
			priority = A.GetUsePriority();
			dist = VSize(A.Location - Location);

			if((priority < bestPriority) 
				|| (priority == bestPriority && dist < bestDist))
			{
				bestPriority = priority;
				bestDist = dist;
				UseActor = A;
			}
		}
	}

	if(UseActor != None)
	{
		if(UseActor.IsA('Inventory'))
		{ // Inventory item pickup is handled by the animation proxy
			if(AnimProxy != None)
				AnimProxy.Use();
		}
		else if(UseActor.IsA('Fire'))
		{ // Relight torch, pass the use to the weapon
			if(Weapon != None)
				Weapon.UseTrigger(self);
		}
		else
		{ // Otherwise, play the animation returned by GetUseAnim	
			useAnim = UseActor.GetUseAnim();

			if(useAnim != '')
			{
				if(useAnim == 'neutral_kick')
					PlaySound(KickSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);

				if(useAnim == 'PumpTrigger' && Weapon != None && Weapon.A_PumpTrigger != '')
				{ // Weapon-specific pump trigger anims
					useAnim = Weapon.A_PumpTrigger;
				}

				if(useAnim == 'LeverTrigger' && Weapon != None && Weapon.A_LeverTrigger != '')
				{ // Weapon-specific pump trigger anims
					useAnim = Weapon.A_LeverTrigger;
				}

				PlayUninterruptedAnim(useAnim);
			}
		}
	}
}

//=============================================================================
//
// Powerup
//
//=============================================================================

exec function Powerup()
{
	local int power;

	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) || Health <= 0)
		return;

	if(Weapon == None)
		return;

	// Don't allow the player to powerup if they are doing something like weapon switching or attacking
	if(AnimProxy != None && AnimProxy.GetStateName() != 'Idle')
		return;

	if(!Weapon.bCanBePoweredUp || Region.Zone.bWaterZone || Weapon.Region.Zone.bWaterZone
		|| Weapon.bPoweredUp)
	{
		PlaySound(PowerupFail, SLOT_Interface);
		return;
	}

	if(Weapon.RunePowerRequired > RunePower)
	{
		PlaySound(PowerupFail, SLOT_Interface);
		ClientMessage(NoRunePowerMsg, 'NoRunePower');
		return;
	}

	PowerUpWeapon();

	// Play powerup-anim
	if(Weapon.A_Powerup != '' && GetStateName() == 'PlayerWalking')
	{
		PlayAnim(Weapon.A_Powerup, 1.0, 0.1);
		if(AnimProxy != None)
			AnimProxy.PlayAnim(Weapon.A_Powerup, 1.0, 0.1);
	}
}

//------------------------------------------------------------
//
// Taunt
//
//------------------------------------------------------------

exec function Taunt()
{
	local name Sequence;

	if (Physics != PHYS_Walking)	// Disallow while falling
		return;

	if( bShowMenu || (Level.Pauser!=""))
		return;

	// Don't allow the player to taunt if they are doing something like weapon switching or attacking
	if(AnimProxy != None && AnimProxy.GetStateName() != 'Idle')
		return;

	if (Weapon != None)
		Sequence = Weapon.A_Taunt;
	else
		Sequence = 'S3_Taunt';

	if(Role < ROLE_Authority)
		ServerTaunt(Sequence);
//	PlayUninterruptedAnim(Sequence);
}


//-----------------------------------------------------------------------------
// Sound functions

simulated function PlayBeepSound()
{
	PlaySound(Sound'MessageBeep',SLOT_Interface, 1.4);
}

function PlayDyingSound(name DamageType)
{
	local float rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		PlaySound(UnderWaterDeathSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
		return;
	}

	if(DamageType == 'fell')
	{
		PlaySound(FallingDeathSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
		return;
	}

	rnd = FRand();
	if (rnd < 0.25)
		PlaySound(Die, SLOT_Talk);
	else if (rnd < 0.5)
		PlaySound(Die2, SLOT_Talk);
	else if (rnd < 0.75)
		PlaySound(Die3, SLOT_Talk);
	else 
		PlaySound(Die4, SLOT_Talk);

}

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
	if ( Level.TimeSeconds - LastPainSound < 0.3 )
		return;
	LastPainSound = Level.TimeSeconds;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( damageType == 'Drowned' )
			PlaySound(UnderWaterDeathSound, SLOT_Pain,2.0,,,FRand() * 0.08 + 0.96);
		else
		{
			PlaySound(UnderWaterHitSound[Rand(3)], SLOT_Pain,2.0,,,FRand() * 0.08 + 0.96);
		}
		return;
	}

	if(DamageType == 'fell')
	{
		PlaySound(FallingDeathSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
		return;
	}

	damage *= FRand();

	if(damage < 8)
		PlaySound(HitSoundLow[Rand(3)], SLOT_Pain, 2.0,,, Frand() * 0.1 + 0.95);
	else if(damage < 25)
		PlaySound(HitSoundMed[Rand(3)], SLOT_Pain, 2.0,,, Frand() * 0.1 + 0.95);
	else
		PlaySound(HitSoundHigh[Rand(3)], SLOT_Pain, 2.0,,, Frand() * 0.1 + 0.95);
}

function Gasp()
{
	if ( Role != ROLE_Authority )
		return;
	if ( PainTime < 2 )
		PlaySound(GaspSound, SLOT_Talk, 2.0);
	else
		PlaySound(BreathAgain, SLOT_Talk, 2.0);
}

// ===== Weapon Functions =====

//=============================================================================
//
// SelectWeapon
//
//=============================================================================

function SelectWeapon(Weapon newWeapon)
{
	local int joint;
	
	Weapon = newWeapon;
	
	joint = JointNamed(WeaponJoint);
	if(joint != 0)
	{
		AttachActorToJoint(Weapon, joint);
	}
}

//=============================================================================
//
// GetStowedWeapon
//
//=============================================================================

function Weapon GetStowedWeapon(int stowindex)
{
	if (stowindex>=0 && stowindex<=2)
	{
		return StowSpot[stowindex];
	}
	return None;
}


//=============================================================================
//
// SetStowedWeapon
//
//=============================================================================

function SetStowedWeapon(int stowindex, Weapon w)
{
	if (stowindex>=0 && stowindex<=2)
	{
		StowSpot[stowindex] = w;
	}
}


//=============================================================================
//
// StowWeapon
//
//=============================================================================

function StowWeapon(Weapon oldWeapon)
{
	local int joint;
	local int handJoint;
	local int stowIndex;
	
	if(Weapon == None)
	{
		return;
	}

	switch(Weapon.MeleeType)
	{
	case MELEE_SWORD:	
		joint = JointNamed('attatch_sword'); // Compensate for a spelling error...  for now.
		break;
	case MELEE_AXE:
		joint = JointNamed('attach_axe');
		break;
	case MELEE_HAMMER:
		joint = JointNamed('attach_hammer');
		break;
	default:
		joint = 0;
		break;
	}

	handJoint = JointNamed(WeaponJoint);
		
	if(joint != 0 && handJoint != 0)
	{
		DetachActorFromJoint(handJoint);
		AttachActorToJoint(Weapon, joint);

		if(RunePlayerProxy(AnimProxy) != None)	
			stowIndex = RunePlayerProxy(AnimProxy).GetStowIndex(Weapon);
		SetStowedWeapon(stowIndex, Weapon);
		Weapon.GotoState('Stow');
		Weapon = None;		
	}
}

//=============================================================================
//
// RetrieveWeapon
//
//=============================================================================

function RetrieveWeapon(int stowIndex)
{
	local int joint;
	local weapon cur;
	local weapon next;
		
	switch(stowIndex)
	{
	case 0: // MELEE_SWORD
		joint = JointNamed('attatch_sword'); // Compensate for a spelling error...  for now.
		break;
	case 1: // MELEE_HAMMER
		joint = JointNamed('attach_hammer');
		break;
	case 2: // MELEE_AXE
		joint = JointNamed('attach_axe');
		break;
	default:
		joint = 0;
		break;
	}

	cur = GetStowedWeapon(stowIndex);
	if(joint != 0 && cur != None)
	{
		DetachActorFromJoint(joint);
		SelectWeapon(cur);

		// Set the next available weapon to this stow spot
		SetStowedWeapon(stowIndex, None);
		next = GetNextWeapon(cur);
		if(next != None && next != cur)
		{
			AttachActorToJoint(next, joint);
			next.bHidden = false; // Reveal the next weapon
			SetStowedWeapon(stowIndex, next);
		}
	}
}


//=============================================================================
//
// SwapStowToNext
//
// Swaps a weapon in a given stow stop with the next available weapon in the inventory
//=============================================================================

function SwapStowToNext(int stowIndex)
{
	local weapon w;
	local weapon next;
	local int joint;

	w = GetStowedWeapon(stowIndex);
	if(w != None)
	{		
		next = GetNextWeapon(w);
		if(next != None && next != w)
		{ // No need to do this if there is no next weapon or if the next weapon is the current weapon
			w.bHidden = true; // Hide the stowed weapon
			next.bHidden = false; // Reveal the next weapon
			// Detach the currently stow
			switch(stowIndex)
			{
			case 0: // MELEE_SWORD
				joint = JointNamed('attatch_sword'); // Compensate for a spelling error...  for now.
				break;
			case 1: // MELEE_HAMMER
				joint = JointNamed('attach_hammer');
				break;
			case 2: // MELEE_AXE
				joint = JointNamed('attach_axe');
				break;
			default:
				joint = 0;
				break;
			}
				
			if(joint != 0)
			{
				DetachActorFromJoint(joint);
				AttachActorToJoint(next, joint);
				SetStowedWeapon(stowIndex, next);
			}
		}
	}		
}

//=============================================================================
//
// GetNextWeapon
//
// Returns the next sequential weapon of a certain type in the inventory.
// This function is circular, so it will wrap around to the first weapon in the
// inventory
//=============================================================================

function Weapon GetNextWeapon(Weapon current)
{
	local Inventory inv;
	local Weapon w;
	local Weapon higherWeapon, lowestWeapon;
	local int lowestRating, higherRating;

	if(current == None || Inventory == None)
		return(None);

	higherWeapon = None;
	lowestWeapon = None;
	lowestRating = 999;
	higherRating = 999; 

	// Iterate through inventory, finding the two weapons that match the following criteria:
	//	- The weapon of type current with the next higher rating than the current weapon
	//	- The weapon of type current with the lowest rating
	for(inv = Inventory; inv != None; inv = inv.Inventory)
	{
		if(inv.IsA('Weapon'))
		{
			w = Weapon(inv);
			if(w != None && w.MeleeType == current.MeleeType)
			{ // Same weapon type
				if(w.Rating < lowestRating)
				{
					lowestWeapon = w;
					lowestRating = w.Rating;
				}
				if(w.Rating > current.Rating && w.Rating < higherRating)
				{
					higherWeapon = w;
					higherRating = w.Rating;
				}
			}
		}
	}

	// Return the next higher weapon, otherwise, wrap around the list
	// NOTE: If only one weapon of type is in the inventory, then this will return the current weapon
	if(higherWeapon != None)
		return(higherWeapon);
	else
		return(lowestWeapon);
}


//=============================================================================
//
// InstantStow
//
// Instantly stows the current weapon, and properly updates LastHeldWeapon
// for later retrieval
//=============================================================================

function InstantStow()
{
	LastHeldWeapon = None;
	if(Weapon != None)
	{ // Handle the current weapon (drop it, do nothing, or stow it)		
		if(Weapon.IsA('NonStow'))
			DropWeapon();
		else
		{
			LastHeldWeapon = Weapon;
			WeaponDeactivate();
			Weapon.DisableSwipeTrail();
			StowWeapon(None);
		}

		SetMovementMode(); // Set combat or exploration mode
	}
}
	
/*
//=============================================================================
//
// DropShield
//
//=============================================================================
function DropShield()
{
	local vector X,Y,Z;
	local int joint;
	
	if(Shield == None)
		return;

	joint = JointNamed('attach_shielda');
	if (joint != 0)
	{
		DetachActorFromJoint(joint);
		
		GetAxes(Rotation, X, Y, Z);
		Shield.DropFrom(GetJointPos(joint));
	
		Shield.SetPhysics(PHYS_Falling);
		Shield.Velocity = Y * 100 + X * 75;
		Shield.Velocity.Z = 50;

		Shield.GotoState('Drop');

		Shield = None; // Remove the shield from the actor
	}
}	
*/

//=============================================================================
//
// ThrowWeapon
//
// RUNE:  Throw the current weapon
//=============================================================================

function ThrowWeapon()
{
	if(Weapon != None)
	{
		// Play Weapon Throw Sound
		PlaySound(WeaponThrowSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
	
		Super.ThrowWeapon();

		SetMovementMode(); // Set combat or exploration mode
	}
}

//=============================================================================
//
// ThrowGhost
//
// Notify for Throw powerup
//=============================================================================

function ThrowGhost()
{
	local vector X,Y,Z;
	local int joint;
	local Weapon theWeapon;

	if(Weapon == None)
	{
		return;
	}
	
	// Play Weapon Throw Sound
	PlaySound(WeaponThrowSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);

	joint = JointNamed(WeaponJoint);
	theWeapon = Spawn(class'GoblinAxePowerup',self,,GetJointPos(joint));
	if (theWeapon != None)
	{
		GetAxes(ViewRotation, X, Y, Z);
		theWeapon.SetPhysics(PHYS_Falling);
		theWeapon.Velocity = X * 750 + Z * 200;
		theWeapon.GotoState('Throw');
	}
}	

//=============================================================================
//
// AcquireInventory
//
//=============================================================================

function AcquireInventory(Inventory item)
{
	local int joint;
	local Weapon newWeapon;
	local actor a;

	if (Skeletal == None)
		return;

	if(AnimProxy != None)
		AnimProxy.AcquireInventory(item);

	SetMovementMode(); // Set combat or exploration mode
}

//=============================================================================
//
// SwitchWeapon
//
//=============================================================================

exec function SwitchWeapon(byte F)
{
	local Weapon newWeapon;
	local int index;
	
	if(bShowMenu || Level.Pauser != "")
		return;

	if (BodyPartMissing(BODYPART_RARM1))	// Disallow weapon switching when no weapon arm
		return;

	if(AnimProxy != None && AnimProxy.GetStateName() == 'Idle' && GetStateName() == 'PlayerWalking')
		RunePlayerProxy(AnimProxy).SwitchWeapon(F);

	SetMovementMode(); // Set combat or exploration mode
}

//=============================================================================
//
// CamPickUp
//
//=============================================================================

function bool CanPickup(Inventory item)
{
	if (item.IsA('Shield') && BodyPartMissing(BODYPART_LARM1))
		return false;
	if (item.IsA('Weapon') && BodyPartMissing(BODYPART_RARM1))
		return false;

	if(RunePlayerProxy(AnimProxy) != None)
		return(RunePlayerProxy(AnimProxy).CanPickUp(item));
	else
		return(false);
}

//------------------------------------------------------------
//
// WantsToPickup
//
// Returns whether the item is desired
//------------------------------------------------------------
function bool WantsToPickUp(Inventory item)
{
	return true;
}


// ===== STATES =====

//-----------------------------------------------------------------------------
//
// STATE PlayerWalking
//
// Player movement.
//-----------------------------------------------------------------------------

state PlayerWalking
{
	function AnimEnd()
	{
		local actor a;
		local rotator r;
		local vector l;
		local int joint;
		local vector X,Y,Z;

		bAnimTransition = false;
		
		if(Physics == PHYS_Walking)
		{
			if((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000)
			{
				PlayWaiting(0.2);
			}
			else
			{		
				PlayMoving();
			}
		}
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		Super.Landed(HitNormal, HitActor);
		if (Velocity.Z < -1.4 * JumpZ)
			ShakeView(0.175 - 0.00007 * Velocity.Z, -0.85 * Velocity.Z, -0.002 * Velocity.Z);
	}

	function bool GrabEdge(float grabDistance, vector grabNormal)
	{ // RUNE
		if(AnimProxy != None && AnimProxy.GetStateName() == 'Idle')
		{ // Only grab edges if in the idle state
			GrabLocationUp.X = Location.X;
			GrabLocationUp.Y = Location.Y;
			GrabLocationUp.Z = Location.Z + grabDistance + 8;
		
			GrabLocationIn.X = Location.X + grabNormal.X * (CollisionRadius + 4);
			GrabLocationIn.Y = Location.Y + grabNormal.Y * (CollisionRadius + 4);
			GrabLocationIn.Z = GrabLocationUp.Z + CollisionHeight;
		
			SetRotation(rotator(grabNormal));
			ViewRotation.Yaw = Rotation.Yaw; // Align View with Player position while grabbing edge

			// Save the final distance (used for choosing the correct anim)
			GrabLocationDist = GrabLocationUp.Z - Location.Z;

			// Final, absolute check if the player can fit in the new location.
			// if the player fits, then it is a valid edge grab
			if(SetLocation(GrabLocationIn))
			{
				if(AnimProxy != None)
					AnimProxy.GotoState('EdgeHanging');			
				GotoState('EdgeHanging');

				return(true);
			}
		}
		
		return(false);
	}

	function Dodge(eDodgeDir DodgeMove)
	{
		local vector X,Y,Z;

		if ( bIsCrouching || (Physics != PHYS_Walking) || Weapon==None)
			return;

		GetAxes(Rotation,X,Y,Z);
		if (DodgeMove == DODGE_Forward)
			Velocity = 1.3 * GroundSpeed*X + (Velocity Dot Y)*Y;
		else if (DodgeMove == DODGE_Back)
			Velocity = -1.3 * GroundSpeed*X + (Velocity Dot Y)*Y; 
		else if (DodgeMove == DODGE_Left)
			Velocity = 1.3 * GroundSpeed*Y + (Velocity Dot X)*X; 
		else if (DodgeMove == DODGE_Right)
			Velocity = -1.3 * GroundSpeed*Y + (Velocity Dot X)*X; 

		Velocity.Z = 180;
		if ( Role == ROLE_Authority )
			PlaySound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
		PlayDodge(DodgeMove);
		DodgeDir = DODGE_Active;
		SetPhysics(PHYS_Falling);
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		local vector OldAccel;

		OldAccel = Acceleration;
		Acceleration = NewAccel;
		bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 10000 ); // RUNE:  was 5000

		if ( (DodgeMove == DODGE_Active) && (Physics == PHYS_Falling) )
			DodgeDir = DODGE_Active;	
		else if ( (DodgeMove != DODGE_None) && (DodgeMove < DODGE_Active) )
			Dodge(DodgeMove);

		if(bPressedJump)
		{
			DoJump();
		}

		if((Physics == PHYS_Walking)) // && (GetGroup(AnimSequence) != 'Dodge'))
		{
			if(!bIsCrouching)
			{
				if(bDuck != 0)
				{
					SetCrouch(true);
					PlayDuck();
				}
			}
			else if(bDuck == 0)
			{
				OldAccel = vect(0,0,0);
				SetCrouch(false);
			}

			if ( !bIsCrouching )
			{
				if(VSize(Acceleration) >= 1)
				{
					PlayMoving();
				}
			 	else if(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000)
			 	{
					PlayWaiting(0.2);
/*
					if(bIsTurning)
					{
						PlayTurning();
					}
			 		else
					{
						PlayWaiting(0.2);
					}
*/
				}
			}
			else
			{
				if(VSize(Acceleration) >= 1)
					PlayCrawling();
				else
					PlayDuck();
			}
		}
	}

	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local rotator newRotation;
		local vector ToZTarget;

		if(ZTarget == None)
		{ // No ZTarget, so use the normal UpdateRotation
			Super.UpdateRotation(DeltaTime, maxPitch);
			return;
		}
		else
		{ // ZTarget			
			DesiredRotation = ViewRotation; //save old rotation
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}

			ToZTarget = ZTarget.Location - Location;
			ViewRotation.Yaw = rotator(ToZTarget).Yaw;
			ViewFlash(deltaTime);
				
			newRotation = Rotation;
			newRotation.Yaw = ViewRotation.Yaw;
			newRotation.Pitch = ViewRotation.Pitch;
			If ( (newRotation.Pitch > maxPitch * RotationRate.Pitch) && (newRotation.Pitch < 65536 - maxPitch * RotationRate.Pitch) )
			{
				If (ViewRotation.Pitch < 32768) 
					newRotation.Pitch = maxPitch * RotationRate.Pitch;
				else
					newRotation.Pitch = 65536 - maxPitch * RotationRate.Pitch;
			}
			setRotation(newRotation);			
		}
	}

	event PlayerTick( float DeltaTime )
	{
		local float ZDist;

		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);

		// Check to player falling death scream
		if(!bPlayedFallingSound && Physics == PHYS_Falling && Velocity.Z < -1300)
		{ // Play death scream
			bPlayedFallingSound = true;
			PlaySound(FallingScreamSound,SLOT_Talk,,true);
		}

		// Update ZTarget (only if in single-player)
		if(ZTarget != None && Level.Netmode == NM_Standalone)
		{
			ZDist = VSize(ZTarget.Location - Location);
			if(ZTarget.Health <= 0 || ZDist > ZTARGET_DIST)
			{
				ZTarget = None;
			}
			else
			{
				if(ZTargetDecal == None)
				{
					ZTargetDecal = Spawn(class'ZTargetDecal', ZTarget,, Location, Rotation);
				}

				ZTargetDecal.SetOwner(ZTarget);
				ZTargetDecal.Update(None);
			}
		}
	}

	function ZoneChange(ZoneInfo NewZone)
	{
		if(NewZone.bWaterZone && Physics == PHYS_Falling && Velocity.Z < -1300)
		{ // Player is falling and screaming, cut out the scream when he hits the water
			bPlayedFallingSound = false;
			PlaySound(UnderwaterHitSound[0], SLOT_Talk,, false);			
		}

		Super.ZoneChange(NewZone);
	}

	function BeginState()
	{
		WalkBob = vect(0,0,0);
		DodgeDir = DODGE_None;
		SetCrouch(false);
		bIsTurning = false;
		bPressedJump = false;
		if (Physics != PHYS_Falling) SetPhysics(PHYS_Walking);
		if ( !IsAnimating() )
			PlayWaiting(0.2);
		Enable('Tick');	
	}
	
	function EndState()
	{
		WalkBob = vect(0,0,0);
		SetCrouch(false);
		bPlayedFallingSound=false;
	}
}

//=============================================================================
//
// STATE EdgeHanging
//
//=============================================================================

state EdgeHanging
{
ignores SeePlayer, HearNoise, Bump, Fire, AltFire, GrabEdge, Jump, SwitchWeapon;

	exec function Taunt()	{}
	exec function Fly()		{}
	exec function Walk()	{}
	exec function Ghost()	{}
	exec function Powerup()	{}
	exec function Throw()	{}

	function EndState()
	{
		if(Weapon == None)
			bRotateTorso = true;

		CameraAccel = Default.CameraAccel;

		if(AnimProxy != None)
			AnimProxy.GotoState('Idle');
	}

	function AnimEnd()
	{
		if(AnimSequence == 'intropullupA')
		{ // Finished initial pullup, so step up
			PlayStepUp(0.1);
		}
		else if(AnimSequence == 'pullupTest')
		{ // Finished step up, so done with edge grab
			PlayWaiting(0.2);

			if(AnimProxy != None)
				AnimProxy.GotoState('Idle');

			GotoState('PlayerWalking');
		}
	}

	function BeginState()
	{
		if (Level.NetMode == NM_Client)
		{
			if(GrabLocationDist <= 5)
			{	// Nothing, possibly re-entered state
				GotoState('PlayerWalking');
				return;
			}
			else if(GrabLocationDist < 20)
			{	// Step up
				PlayStepUp(0.0); // No tween
			}
			else
			{	// Pull up
				PlayPullUp(0.0); // No tween
			}
		}
		else
		{
			// Play Grab Animation
			if(GrabLocationDist > 20)
			{
				PlayPullUp(0.0); // No tween
			}
			else
			{
				PlayStepUp(0.0); // No tween
			}
		}

		// Set up variables on the player
		SetPhysics(PHYS_Flying);
		Velocity = vect(0, 0, 0);
		Acceleration = vect(0, 0, 0);

		SetCrouch(false);
		bPressedJump = false;
		bRotateTorso = false;
		CameraAccel = 1;
	}

begin:
}

//=============================================================================
//
// StopAttack
//
//=============================================================================

function StopAttack()
{	
	if(AnimProxy != None)
		AnimProxy.StopAttack();
}

//-----------------------------------------------------------------------------
//
// STATE PlayerRopeClimbing
//
//-----------------------------------------------------------------------------

state PlayerRopeClimbing
{
ignores SeePlayer, HearNoise, Bump, AltFire, GrabEdge, Jump, SwitchWeapon, Touch;

	function PlayRopeClimb()
	{
		local name anim;

		if(Velocity.Z > 5)
			anim = 'ClimbUpRope';
		else if(Velocity.Z < -5)
			anim = 'ClimbDownRope';
		else
			anim = 'ClimbIdleRope';

		LoopAnim(anim, 1.0, 0.25);
		if(AnimProxy != None)
			AnimProxy.LoopAnim(anim, 1.0, 0.25);	
	}

	function AnimEnd()
	{
		PlayRopeClimb();
	}

	function BeginState()
	{
		// Sheath current weapon when climbing ropes
		InstantStow();

		if(AnimProxy != None)
			AnimProxy.GotoState('PlayerRopeClimbing');

		SetCrouch(false);
		bPressedJump = false;
		bRotateTorso = false;
		bCanFly = true;			// So client's don't simulate the fall

	    CameraAccel = 12;		

		PlayRopeClimb();
		Acceleration = vect(0, 0, 0);
	}

	function EndState()
	{
	    CameraAccel = Default.CameraAccel;		

		if (TheRope != None)
		{
			TheRope.DetachFromRope(self);
			TheRope = None;
		}
		bRotateTorso = Default.bRotateTorso;
		bCanFly = Default.bCanFly;

		if(AnimProxy != None)
			AnimProxy.GotoState('Idle');
	}

	function ZoneChange( ZoneInfo NewZone )
	{
		if (NewZone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
	}

	exec function Use()
	{
		LeapOff();
	}

	function FallOff()
	{ // Release -- Used to drop Ragnar off the rope (when damaged or other reasons)
	  // Ragnar falls backwards
		local vector X, Y, Z;

		GetAxes(Rotation, X, Y, Z);
		Velocity = -X * 50;
		SetPhysics(PHYS_Falling);
		TheRope.DetachFromRope(self);
		TheRope = None;
		PlayWaiting(0.2);
		if (Region.Zone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			NextStateAfterPain = 'PlayerSwimming';
		}
		else
		{
			if(AnimProxy != None)
				AnimProxy.GotoState('Idle');

			NextStateAfterPain = 'PlayerWalking';
		}
	}

	function LeapOff()
	{ // Release in the direction Ragnar is currently facing (when the Use key is pressed)
		local vector X, Y, Z;
		local vector deviation;
		local float jumpForce;

		deviation = (Location - TheRope.Location);
		if (VSize2D(deviation) > 50)
			jumpForce = 0.5;
		else
			jumpForce = 0.25;
		GetAxes(Rotation, X, Y, Z);
		AddVelocity(X*350 );//+ Z*JumpZ*jumpForce);
		SetPhysics(PHYS_Falling);
		TheRope.DetachFromRope(self);
		TheRope = None;

		PlayRopeLeapOff();

		if (Region.Zone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
		else
		{
			if(AnimProxy != None)
				AnimProxy.GotoState('Idle');

			GotoState('PlayerWalking');
		}
	}

	function PlayChatting()
	{
	}

	exec function Taunt()
	{
	}
	
	function Landed(vector HitNormal, actor HitActor)
	{
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		PlayRopeClimb();
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function ServerMove
	(
		float TimeStamp, 
		vector Accel, 
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus, 
		bool bFired,
		bool bAltFired,
		bool bForceFire,
		bool bForceAltFire,
		eDodgeDir DodgeMove, 
		byte ClientRoll, 
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(TimeStamp, Accel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,
							bFired, bAltFired, bForceFire, bForceAltFire, DodgeMove, ClientRoll, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)));
	}

	function PlayerMove( float DeltaTime)
	{
		local vector NewAccel;
		local vector HandPos;
		local vector X,Y,Z;
		local vector RopeVector, VelocityLookahead, RopeDir, NewLocation;

		if(TheRope == None)
			return;

		// Mangle controls
		aForward *= 0.00;
		aStrafe  *= 0.00;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		if(aUp > 0)
		{ // Move slightly slower going up than going down
			aUp *= 0.056;
		}
		else
		{
			aUp *= 0.084;
		}

		if (Physics != PHYS_Flying)
			SetPhysics(PHYS_Flying);

		// Apply controls to velocity and ropedist
		Acceleration.X = 0;
		Acceleration.Y = 0;
		Velocity.X = 0;
		Velocity.Y = 0;

		if (aUp == 0)
		{	// Stop on a dime
			Acceleration.Z = 0;
			Velocity.Z = 0;
		}

		Velocity.Z += aUp * DeltaTime;

		if (Location.Z <= TheRope.RopeClimbBottom.Z)
		{	// Hit Bottom
			if (Location.Z < TheRope.RopeClimbBottom.Z)
			{
				SetLocation(TheRope.RopeClimbBottom);
			}
			Velocity.Z = Max(0, Velocity.Z);
		}
		else if (Location.Z >= TheRope.RopeClimbTop.Z)
		{	// Hit Top
			if (Location.Z > TheRope.RopeClimbTop.Z)
			{
				SetLocation(TheRope.RopeClimbTop);
			}
			Velocity.Z = Min(0, Velocity.Z);
		}

		// Update view rotation
		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		bPressedJump = false;
	}

	function PlayTakeHit(float tweentime, int damage, vector HitLoc, name damageType, vector Momentum, int BodyPart)
	{
		Super.PlayTakeHit(tweentime, damage, HitLoc, damageType, Momentum, BodyPart);
		FallOff();
	}
	
	function PlayDying(name DamageType, vector HitLocation)
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		Super.PlayDying(DamageType, HitLocation);
	}
	
	function ChangedWeapon()
	{
		Inventory.ChangedWeapon();
		Weapon = None;
	}

}

//-----------------------------------------------------------------------------
//
// STATE PlayerSwimming
//
//-----------------------------------------------------------------------------

state PlayerSwimming
{
	function PlayMoving(optional float tween)
	{
		PlaySwimming();
	}

	function PlayUnderwaterSound()
	{
		AmbientSound = UnderwaterAmbient[Rand(5)];
	}

	function SetSurfaceSwim(bool surface)
	{
		bSurfaceSwimming = surface;
	}

	function StopUnderwaterSound()
	{
		AmbientSound = None;
	}

	function bool CanGotoPainState()
	{
		return(!bSurfaceSwimming);
	}

	function AnimEnd()
	{
		PlaySwimming();
	}

	function BeginState()
	{
		Super.BeginState();
		RotationRate.Pitch = 16000;
		PlayUnderwaterSound();
		bBurnable=False;

		InstantStow();		
		// Sheath current weapon when underwater
	}

	function EndState()
	{
		Super.EndState();
		RotationRate.Pitch = 0;
		SetSurfaceSwim(false);
		bBurnable=Default.bBurnable;

		WaterSpeed = 300;
		StopUnderwaterSound();
	}

	function HeadZoneChange(ZoneInfo NewZone)
	{
		local vector HitLocation, HitNormal;
		local vector Extent;
		
		Super.HeadZoneChange(NewZone);

		if(!NewZone.bWaterZone && !bSurfaceSwimming)
		{ // Surfaced
			SetSurfaceSwim(true);

			// Align the player directy to the surface
			GrabLocationUp = FindWaterLine(Location + vect(0, 0, 40), Location + vect(0, 0, -40));
			Extent.X = CollisionRadius;
			Extent.Y = CollisionRadius;
			Extent.Z = CollisionHeight;
			if(Trace(HitLocation, HitNormal, GrabLocationUp, Location, true, Extent) == None)
			{
				SetLocation(GrabLocationUp);
				Buoyancy = Mass; // Don't bob in the water!
				bNoSurfaceBob = true;
				Acceleration = vect(0, 0, 0);
				Velocity = vect(0, 0, 0);
				RotationRate.Pitch = 0;
				WaterSpeed = 200;
			}
			else
			{
				SetSurfaceSwim(false);
				RotationRate.Pitch = 16000;
				WaterSpeed = 300;
			}
		}
		else if(NewZone.bWaterZone && bSurfaceSwimming)
		{
			SetSurfaceSwim(false);
			RotationRate.Pitch = 16000;
			WaterSpeed = 300;
		}

		if(NewZone.bWaterZone)
			PlayUnderwaterSound();
		else
			StopUnderwaterSound();
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;
		local float Speed2D;

		if(bSurfaceSwimming)
		{
			GetAxes(ViewRotation,X,Y,Z);

			aForward *= 0.2;
			aStrafe  *= 0.1;
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			aUp		 *= 0.1;

			if (aUp >= 0)
				aUp = 0;
			else
			{
				aForward = 0;
				aStrafe = 0;
			}
			NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);
//			NewAccel = aForward*X + aStrafe*Y;

			// Update rotation.
			oldRotation = Rotation;
			UpdateRotation(DeltaTime, 2);

			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
			else
				ProcessMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
			bPressedJump = false;
		}
		else
		{
			Super.PlayerMove(DeltaTime);
		}
	}

	function bool CheckWaterJump(out vector WallNormal)
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, checkpoint, start, checkNorm, Extent;

		checkpoint = vector(Rotation);
		checkpoint.Z = 0.0;
		checkNorm = Normal(checkpoint);
		checkPoint = Location + CollisionRadius * checkNorm;
		Extent = CollisionRadius * vect(1,1,0);
		Extent.Z = CollisionHeight;
		HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true, Extent);
		if ( (HitActor != None) && (Pawn(HitActor) == None) )
		{
			WallNormal = -1 * HitNormal;
			start = Location;
			start.Z += 1.1 * MaxStepHeight;
			checkPoint = start + 2 * CollisionRadius * checkNorm;
			HitActor = Trace(HitLocation, HitNormal, checkpoint, start, true);
			if (HitActor == None)
				return true;
		}

		return false;
	}

	function CheckForSubmerge()
	{
		local float dp;

//		if((aUp < 0) || (ViewRotation.Pitch > 32768 && ViewRotation.Pitch < 55000 && aForward > 0))
		dp = Normal(Acceleration) dot vect(0,0,-1);
		if(Acceleration.Z<0 && dp>0.85)
		{
			SetSurfaceSwim(false);

			WaterSpeed = 300;
			Buoyancy = Default.Buoyancy;
			bNoSurfaceBob = false;
			Velocity = vect(0, 0, -50);
			RotationRate.Pitch = 16000;
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		local vector X,Y,Z, Temp;
	
		GetAxes(ViewRotation,X,Y,Z);
		Acceleration = NewAccel;

		PlaySwimming();

		if(bSurfaceSwimming)
			CheckForSubmerge();

/*
		if(bSurfaceSwimming && CheckWaterJump(Temp)) //check for waterjump
		{
			velocity.Z = 330 + 2 * CollisionRadius; //set here so physics uses this for remainder of tick
//			PlayDuck();
			GotoState('PlayerWalking');
		}				
*/
		if(bSurfaceSwimming)
		{
			Acceleration.Z = 0;
		}
	}

	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local rotator newRotation;

		// UpdateRotation to properly rotate Ragnar while swimming (does NOT rotate while surfaceswimming, though)
		if(!bSurfaceSwimming)
		{
			DesiredRotation = ViewRotation; //save old rotation
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
	//		ViewShake(deltaTime); // RUNE:  ViewShake is handled in the Camera code
			ViewFlash(deltaTime);
				
			newRotation = ViewRotation;
			If ( (newRotation.Pitch > maxPitch * RotationRate.Pitch) && (newRotation.Pitch < 65536 - maxPitch * RotationRate.Pitch) )
			{
				If (ViewRotation.Pitch < 32768) 
					newRotation.Pitch = maxPitch * RotationRate.Pitch;
				else
					newRotation.Pitch = 65536 - maxPitch * RotationRate.Pitch;
			}
			setRotation(newRotation);
		}
		else
		{
			Super.UpdateRotation(DeltaTime, maxPitch);
		}
	}

	function bool GrabEdge(float grabDistance, vector grabNormal)
	{ // RUNE	
		if(AnimProxy != None && AnimProxy.GetStateName() == 'Idle'
			&& !HeadRegion.Zone.bWaterZone)
		{ // Only grab edges if in the idle state and head is above water
			GrabLocationUp.X = Location.X;
			GrabLocationUp.Y = Location.Y;
			GrabLocationUp.Z = Location.Z + grabDistance + 8;
		
			GrabLocationIn.X = Location.X + grabNormal.X * (CollisionRadius + 4);
			GrabLocationIn.Y = Location.Y + grabNormal.Y * (CollisionRadius + 4);
			GrabLocationIn.Z = GrabLocationUp.Z + CollisionHeight;
		
			SetRotation(rotator(grabNormal));
			ViewRotation.Yaw = Rotation.Yaw; // Align View with Player position while grabbing edge

			// Save the final distance (used for choosing the correct anim)
			GrabLocationDist = GrabLocationUp.Z - Location.Z;

			// Final, absolute check if the player can fit in the new location.
			// if the player fits, then it is a valid edge grab
			if(SetLocation(GrabLocationIn))
			{
				if(AnimProxy != None)
					AnimProxy.GotoState('EdgeHanging');			
				GotoState('EdgeHanging');

				return(true);
			}
		}
		
		return(false);
	}
}

//------------------------------------------------------------
//
// Dying
//
//------------------------------------------------------------

state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, /*Landed,*/ SwitchWeapon;

	function ServerReStartPlayer()
	{
		if(!bCanRestart)
			return;

		Super.ServerReStartPlayer();

		PlayerRestart();
	}

	function BeginState()
	{
		local int i;
		local int joint;
		local vector X, Y, Z;

		Super.BeginState();

		// Drop any stowed weapons
		for(i = 0; i < 3; i++)
		{
			if(StowSpot[i] != None)
			{		
				switch(StowSpot[i].MeleeType)
				{
				case MELEE_SWORD:
					joint = JointNamed('attatch_sword');
					break;
				case MELEE_AXE:
					joint = JointNamed('attach_axe');
					break;
				case MELEE_HAMMER:
					joint = JointNamed('attach_hammer');
					break;
				default:
					// Unknown or non-stow item
					joint = 0;
					break;
				}

				if(joint != 0)
				{
					DetachActorFromJoint(joint);
						
					GetAxes(Rotation, X, Y, Z);
					StowSpot[i].DropFrom(GetJointPos(joint));
				
					StowSpot[i].SetPhysics(PHYS_Falling);
					StowSpot[i].Velocity = Y * 100 + X * 75;
					StowSpot[i].Velocity.Z = 50;
					
					StowSpot[i].GotoState('Drop');
					StowSpot[i].DisableSwipeTrail();

					StowSpot[i] = None; // Remove the StowWeapon from the actor
				}
			}		
		}

		Buoyancy = Mass + 5;
		LookTarget=None;
		LookSpot=vect(0,0,0);
		SetCollision(true, false, false);
		SetPhysics(PHYS_Falling);
	}

	function EndState()
	{
		Buoyancy=Default.Buoyancy;
		Super.EndState();
	}

/*	function Done()
	{	// Not run on clients
		SetPhysics(PHYS_None);
		SetCollision(false, false, false);
		bCollideWorld = false;
		ReplaceWithCarcass();
	}*/

	function Landed(vector HitNormal, actor HitActor)
	{
		SetPhysics(PHYS_None);
		SetCollision(false, false, false);
		bCollideWorld = true;
	}

	function AnimEnd()
	{
		ReplaceWithCarcass();
	}

Begin:
/* Changed to net friendly events
	// Override Pawn label (don't do collision size changes)
	WaitForLanding();
	FinishAnim();
	Done();
*/
}

//-----------------------------------------------------------------------------
//
// STATE Scripting
//
// This state disallows any player input until the cinema ends
//-----------------------------------------------------------------------------
function ReleaseFromCinematic();

state Scripting
{
ignores SeePlayer, HearNoise, Bump, GrabEdge, Jump, SwitchWeapon, Fire, AltFire;
	
	function Landed(vector HitNormal, actor HitActor)
	{
	}

	exec function Taunt()	{}
	exec function Fly()		{}
	exec function Walk()	{}
	exec function Ghost()	{}
	exec function Powerup()	{}
	exec function Throw()	{}

	simulated function DetermineLookFocus()	{}

	function bool CanBeStatued()		{	return false;	}
	function bool CanGotoPainState()	{	return(false);	}
	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		return false;
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		Acceleration = vect(0,0,0);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		PlayerMove(DeltaTime);

		if (bScriptMoving)
			PlayMoving();
	}

	function PlayerMove( float DeltaTime)
	{
	}

	function PlayTakeHit(float tweentime, int damage, vector HitLoc, name damageType, vector Momentum, int BodyPart)
	{
	}
	
	function PlayDying(name DamageType, vector HitLocation)
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		Super.PlayDying(DamageType, HitLocation);
	}
	
	function EndState()
	{
		bOverrideLookTarget=false;
		bScriptMoving = false;
		OrderObject = None;
	}

	function BeginState()
	{
		bPressedJump = false;		
	}

	function ReleaseFromCinematic()
	{	// Release the player/game from Cinema state
		CineCamera(ViewTarget).FireLastPointEvent();
		CineCamera(ViewTarget).ResetPath();

		ViewTarget = None;
		BlendAnimSequence = 'None';

		// Reset view parameters (gamespeed, screenflash, etc)
		DesiredFlashScale = Default.DesiredFlashScale;
		DesiredFlashFog = Default.DesiredFlashFog;
		FlashScale = Default.FlashScale;
		FlashFog = Default.FlashFog;
		InstantFlash = 0;
		InstantFog = vect(0,0,0);
		FovAngle = Default.FovAngle;
		ServerSetSloMo(1.0); // Reset game speed to normal
		bHidden = false;
				
		if(AnimProxy != None)
		{
			AnimProxy.BlendAnimSequence = 'None';
			AnimProxy.GotoState('Idle');
		}

		if(myHud != None)
			myHud.GotoState('Cinematic', 'end');

		if (Region.Zone.bWaterZone)
			GotoState('PlayerSwimming');
		else
			GotoState('PlayerWalking');
	}

	// Use, Fire, AltFire allow skipping cinematics
	exec function Use()
	{
		if (CineCamera(ViewTarget).bInteruptable)
		{
			StopAllSound();
			ReleaseFromCinematic();
		}
	}

	//============================================
	// ScriptPoint support functions
	//============================================

	function ExecuteScriptPoint()
	{
		local ScriptPoint Dest;
		local actor A;

		teststring = "ExecuteScriptPointScript";

		Dest = ScriptPoint(OrderObject);
		if (Dest != None)
		{
			if (Dest.ArriveSound != None)
				PlaySound(Dest.ArriveSound,,,true);
			
			FireEvent(Dest.ArriveEvent);

			NextState = Dest.NextOrder;
			NextLabel = '';
			NextPoint = ActorTagged( Dest.NextOrderTag );

			if (Dest.ArriveState != '')
			{
				OrderObject = ActorTagged( Dest.ArriveStateTag );
				GotoState( Dest.ArriveState, Dest.ArriveStateLabel );
			}
			else if (NextState != '')
			{
				OrderObject = NextPoint;
				GotoState(NextState, NextLabel);
			}
			else if (Dest.bReleaseUponArrival)
			{	// Release to normal AI
				OrderObject = None;
				ReleaseFromCinematic();
			}
		}
	}

	//============================================
	// ScriptAction support functions
	//============================================

	function ExecuteScriptAction()
	{
		local ScriptAction Action;

		Action = ScriptAction(OrderObject);
		if (Action != None)
		{
			NextState = Action.NextOrder;
			NextLabel = '';
			NextPoint = ActorTagged( Action.NextOrderTag );
			
			if (NextState != '')
			{
				OrderObject = NextPoint;
				GotoState(NextState, NextLabel);
			}
			else if (Action.bReleaseUponCompletion)
			{	// Release to normal AI
				OrderObject = None;
				ReleaseFromCinematic();
			}
		}
	}

	function SpeechTimer()
	{
		local string letter;
		local float alpha;
		local ScriptAction Action;
		local ScriptDispatcher Dispatch;

		if (ScriptAction(OrderObject) != None)
		{
			Action = ScriptAction(OrderObject);

			// parse control strings
			if (Len(Action.ControlMouth) > 0)
			{
				letter = Mid(Action.ControlMouth, SpeechPos, 1);
				alpha = float(Asc(letter) - Asc("A"))/25.0;
				OpenMouth(FClamp(alpha, 0, 1), 1.0);
			}
			if (Len(Action.ControlHead) > 0)
			{
				letter = Mid(Action.ControlHead, SpeechPos, 1);
				alpha = float(Asc(letter) - Asc("A"))/25.0;
				bOverrideLookTarget=true;
				targetangle.Yaw = MaxHeadAngle.Yaw * (alpha*2-1);
				targetangle.Pitch = 0;
				targetangle.Roll = 0;
			}
			SpeechTime = Action.ControlTimeGranularity;
			SpeechPos++;
		}
		else if (ScriptDispatcher(OrderObject) != None)
		{
			Dispatch = ScriptDispatcher(OrderObject);

			// parse control strings
			if (Len(Dispatch.ControlMouth[DispatchAction-1]) > 0)
			{
				letter = Mid(Dispatch.ControlMouth[DispatchAction-1], SpeechPos, 1);
			//slog("Speaking letter"@letter);
				alpha = float(Asc(letter) - Asc("A"))/25.0;
				OpenMouth(FClamp(alpha, 0, 1), 1.0);
			}
			if (Len(Dispatch.ControlHead[DispatchAction-1]) > 0)
			{
				letter = Mid(Dispatch.ControlHead[DispatchAction-1], SpeechPos, 1);
				alpha = float(Asc(letter) - Asc("A"))/25.0;
				bOverrideLookTarget=true;
				targetangle.Yaw = MaxHeadAngle.Yaw * (alpha*2-1);
				targetangle.Pitch = 0;
				targetangle.Roll = 0;
			}
			SpeechTime = Dispatch.ControlTimeGranularity;
			SpeechPos++;
		}
	}

	function Timer()
	{
		if (ScriptAction(OrderObject)!=None && ScriptAction(OrderObject).SoundToPlay != None)
			PlaySound(ScriptAction(OrderObject).SoundToPlay,SLOT_Talk,,true);
	}

	function FinishScriptDispatcher()
	{
		local ScriptDispatcher SD;

		SD = ScriptDispatcher(OrderObject);
		if (SD != None)
		{
			NextState = SD.NextOrder;
			NextLabel = '';
			NextPoint = ActorTagged( SD.NextOrderTag );
			
			if (NextState != '')
			{
				OrderObject = NextPoint;
				GotoState(NextState, NextLabel);
			}
			else
			{	// Release to normal AI
				OrderObject = None;
				ReleaseFromCinematic();
			}
		}
	}

	function ExecuteScriptDispatcherAction(int i)
	{
		local ScriptDispatcher SD;

		SD = ScriptDispatcher(OrderObject);


		if (SD.LookTarget[i] != '' ||
			SD.Actions[i].EventToFire != '' ||
			SD.Actions[i].AnimToPlay != '' ||
			SD.Actions[i].SoundToPlay != None)
		{
//			bTaskLocked = SD.Actions[i].bTaskLocked;
		}

		if (SD.LookTarget[i] != '')
		{	// Look at looktarget
			bOverrideLookTarget=false;
			LookAt(ActorTagged(SD.LookTarget[i]));
			SD.ControlHead[i] = "";
		}

		if (SD.ControlTimeGranularity > 0)
		{	// Setup for Sync controls
			SpeechPos = 0;
			SpeechTime = SD.ControlTimeGranularity;
			SD.ControlMouth[i] = Caps(SD.ControlMouth[i]);
			SD.ControlHead[i] = Caps(SD.ControlHead[i]);
		}

		FireEvent(SD.Actions[i].EventToFire);

		if (SD.Actions[i].SoundToPlay != None)
			PlaySound(SD.Actions[i].SoundToPlay,SLOT_Talk,,true);

		if (SD.Actions[i].AnimToPlay != '')
		{
			LoopAnim(SD.Actions[i].AnimToPlay, 1.0, 0.1);
			if(AnimProxy != None)
				AnimProxy.LoopAnim(SD.Actions[i].AnimToPlay, 1.0, 0.1);
		}
	}

HandleScriptDispatcher:
	if (ScriptDispatcher(OrderObject)!=None)
	{
		if (ScriptDispatcher(OrderObject).bWaitToBeTriggered)
		{	// Pend until trigger fires
			ScriptDispatcher(OrderObject).WaitingScripter = self;
			WaitForRelease();
		}

		for (DispatchAction=0; DispatchAction<12; DispatchAction++)
		{
			if (ScriptDispatcher(OrderObject).Actions[DispatchAction].Delay > 0)
				Sleep(ScriptDispatcher(OrderObject).Actions[DispatchAction].Delay);

			ExecuteScriptDispatcherAction(DispatchAction);
		}

		FinishScriptDispatcher();
	}

	Goto('done');

HandleScriptAction:
	teststring = "HandleScriptAction";

	if (ScriptAction(OrderObject)!=None)
	{
		//slog(name@"scripting"@OrderObject.tag);

		if (ScriptAction(OrderObject).bWaitToBeTriggered)
		{	// Pend until trigger fires
			ScriptAction(OrderObject).WaitingScripter = self;
			
			teststring = "WaitingToBeReleased";
			WaitForRelease();
			teststring = "Released";
		}

		if (ScriptAction(OrderObject).LookTarget != '')
		{	// Look at looktarget
			bOverrideLookTarget=false;
			LookAt(ActorTagged(ScriptAction(OrderObject).LookTarget));
			ScriptAction(OrderObject).ControlHead = "";
		}

		if (ScriptAction(OrderObject).ControlTimeGranularity > 0)
		{	// Setup for Sync controls
			SpeechPos = 0;
			SpeechTime = ScriptAction(OrderObject).ControlTimeGranularity;
			ScriptAction(OrderObject).ControlMouth = Caps(ScriptAction(OrderObject).ControlMouth);
			ScriptAction(OrderObject).ControlHead = Caps(ScriptAction(OrderObject).ControlHead);
		}

		if (ScriptAction(OrderObject).bTurnToRotation)
		{	// Turn to ScriptAction's Rotation
			DesiredRotation = OrderObject.Rotation;
			PlayTurning(0.2);
			FinishAnim();
		}

		if (ScriptAction(OrderObject).bFireEventImmediately)
		{	// Fire pre trigger
			//slog("triggering"@OrderObject.event);
			FireEvent(OrderObject.Event);
		}

		// Queue the sound
		if (ScriptAction(OrderObject).SoundToPlay != None)
			SetTimer(ScriptAction(OrderObject).PauseBeforeSound, false);

		if (ScriptAction(OrderObject).AnimToPlay != '')
		{	// Play/Loop the anim
			if (ScriptAction(OrderObject).AnimTimeToLoop > 0)
			{
				LoopAnim(ScriptAction(OrderObject).AnimToPlay, 1.0, 0.1);
				if(AnimProxy != None)
					AnimProxy.LoopAnim(ScriptAction(OrderObject).AnimToPlay, 1.0, 0.1);

				Sleep(ScriptAction(OrderObject).AnimTimeToLoop);
			}
			else
			{
				PlayAnim(ScriptAction(OrderObject).AnimToPlay, 1.0, 0.1);
				if(AnimProxy != None)
					AnimProxy.PlayAnim(ScriptAction(OrderObject).AnimToPlay, 1.0, 0.1);

				FinishAnim();
			}
		}

		if (!ScriptAction(OrderObject).bFireEventImmediately)
		{	// Fire post trigger
			//slog("triggering"@OrderObject.event);
			FireEvent(OrderObject.Event);
		}
	}

	ExecuteScriptAction();
	Goto('done');

HandleScriptPoint:
	teststring = "HandleScriptPoint";
	if (ScriptPoint(OrderObject) != None && ScriptPoint(OrderObject).LookTarget != '')
	{
		bOverrideLookTarget=false;
		LookAt(ActorTagged(ScriptPoint(OrderObject).LookTarget));
	}
	
ContinueScripting:
	if (actorReachable(OrderObject))
	{
	teststring = "reachable";
		bScriptMoving = true;
		MoveToward(OrderObject, MovementSpeed);
		bScriptMoving = false;
		PlayWaiting(0.1);

		if (ScriptPoint(OrderObject)!=None)
		{
			if (ScriptPoint(OrderObject).bTurnToRotation)
			{	// Turn to ScriptPoint rotation
				DesiredRotation = OrderObject.Rotation;
				PlayTurning(0.2);
				FinishAnim();
			}

			if (ScriptPoint(OrderObject).ArriveAnim != '')
			{	// Play anim
				if (ScriptPoint(OrderObject).ArrivePause > 0)
				{
					LoopAnim(ScriptPoint(OrderObject).ArriveAnim, 1.0, 0.1);
					if(AnimProxy != None)
						AnimProxy.LoopAnim(ScriptPoint(OrderObject).ArriveAnim, 1.0, 0.1);

					Sleep(ScriptPoint(OrderObject).ArrivePause);
				}
				else
				{
					PlayAnim(ScriptPoint(OrderObject).ArriveAnim, 1.0, 0.1);
					if(AnimProxy != None)
						AnimProxy.PlayAnim(ScriptPoint(OrderObject).ArriveAnim, 1.0, 0.1);

					FinishAnim();
				}
			}
		}
		ExecuteScriptPoint();
	}
	else if (FindBestPathToward(OrderObject))
	{
	teststring = "pathable";
		bScriptMoving = true;
		MoveToward(MoveTarget, MovementSpeed);
		bScriptMoving = false;
		PlayWaiting(0.1);
		Goto('ContinueScripting');
	}
	else
	{
	teststring = Orderobject@"unpathable";
		TweenToWaiting(0.2);
		FinishAnim();
		PlayWaiting();
		Sleep(1);
		Goto('HandleScriptPoint');
	}
	Goto('done');

begin:
	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);
	PlayWaiting(0.2);

	if (ScriptPoint(OrderObject) != None)
	{
		bHurrying = !ScriptPoint(OrderObject).bWalkToThisPoint;
		UpdateMovementSpeed();
		Goto('HandleScriptPoint');
	}
	else if (ScriptAction(OrderObject) != None)
	{
		Goto('HandleScriptAction');
	}
	else if (ScriptDispatcher(OrderObject) != None)
	{
		Goto('HandleScriptDispatcher');
	}

Done:

}

//------------------------------------------------------------
//
// Pain
//
// Ragnar pain does nothing but cause pain to occur on the torso
//------------------------------------------------------------

state Pain
{
	function bool CanGotoPainState()
	{ // Do not allow the actor to enter the painstate when already in pain
		return(false);
	}

begin:
	if(AnimProxy != None && !bBloodLust)
	{
		if(AnimProxy.CanGotoPainState())
		{
			AnimProxy.GotoState('Pain');
		}
	}

	GotoState(NextStateAfterPain);
}


//================================================
//
// Statue
//
//================================================
State() Statue
{
ignores PowerupFire, PowerupBlaze, PowerupStone, PowerupIce, PowerupFriend, SetOnFire, WeaponActivate, SwipeEffectStart;

	exec function Fire( optional float F )		{}
	exec function AltFire( optional float F )	{}
	exec function Use()							{}
	exec function Throw()						{}
	exec function Powerup()						{}
	exec function Taunt()						{}
	exec function SwitchWeapon(byte F)			{}

	function bool CanBeStatued()		{	return false;	}
	function bool CanGotoPainState()	{	return(false);	}

	function ZoneChange(ZoneInfo newZone)
	{
		// don't go to swimming
	}

	event Tick(float DeltaTime)
	{
		local int i;

		// Update Camera Timer
		CurrentTime += DeltaTime / Level.TimeDilation;

		// Atrophy Strength
		StrengthDecay(DeltaTime);

		// Handle level fade in
		if (LevelFadeAlpha > 0)
		{
			LevelFadeAlpha -= DeltaTime * Level.FadeRate;
			if (LevelFadeAlpha < 0)
				LevelFadeAlpha = 0;
		}
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		PlayerMove(DeltaTime);
	}

	function PlayerMove( float DeltaTime )
	{
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), Dodge_None, rot(0,0,0));
	}

	function EMatterType MatterForJoint(int joint)
	{
		return MATTER_STONE;
	}

	function SpawnDebris(vector Momentum)
	{
		local int numchunks;
		local debris d;
		local vector loc;
		local float scale;
		local int i;

		// Spawn cloud
		DebrisCloud();

		// Find appropriate size of chunks
		numchunks = Clamp(Mass/10, 2, 15);
		scale = (CollisionRadius*CollisionRadius*CollisionHeight) / (numchunks*500);
		scale = scale ** 0.3333333;

		// Spawn debris
		for (i=0; i<numchunks; i++)
		{
			loc = Location;
			loc.X += (FRand()*2-1)*CollisionRadius;
			loc.Y += (FRand()*2-1)*CollisionRadius;
			loc.Z += (FRand()*2-1)*CollisionHeight;
			d = Spawn(class'debrisstone',,,loc);
			if (d != None)
			{
				d.SetSize(scale);
				d.SetMomentum(Momentum);
			}
		}
	}

	function PlayDyingSound(name damageType)
	{
		PlaySound(Sound'WeaponsSnd.impcrashes.crashxstone01', SLOT_Pain);
	}

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		local actor A;

		if (DamageType=='sever' || DamageType=='thrownweaponsever' ||
			DamageType=='fire' || DamageType=='electricity')
			return false;

		SpawnDebris(Momentum);
		InventoryNormal();
		bHidden=true;
		Died(EventInstigator, DamageType, HitLoc);

		return false;
	}

	function CreatureStatue()
	{
		local int ix;

		for (ix=0; ix<16; ix++)
		{
			SkelGroupSkins[ix] = texture'statues.sb_body_stone';
		}
	}

	function DebrisCloud()
	{	// Spawn obscuring cloud
		local DebrisCloud c;
		c = Spawn(class'DebrisCloud');
		c.SetRadius(Max(CollisionRadius,CollisionHeight));
	}

	function CreatureNormal()
	{
		local int ix;

		// Transform creature to default skin
		for (ix=0; ix<16; ix++)
			SkelGroupSkins[ix] = Default.SkelGroupSkins[ix];
		SetDefaultPolygroups();
	}

	function InventoryStatue()
	{
		local Inventory inv;
		local int ix;

		// Transform inventory if visible
		inv = Inventory;
		while (inv != None)
		{
			if (!inv.bHidden)
			{
				for (ix=0; ix<16; ix++)
				{
					if (inv.SkelGroupSkins[ix] != None)
					{
						inv.SkelGroupSkins[ix] = texture'statues.sb_body_stone';
						inv.bSweepable=false;
					}
				}
			}
			inv = inv.Inventory;
		}
	}

	function InventoryNormal()
	{
		local Inventory inv;
		local int ix;

		// Transform inventory if visible
		inv = Inventory;
		while (inv != None)
		{
			if (!inv.bHidden)
			{
				for (ix=0; ix<16; ix++)
					inv.SkelGroupSkins[ix] = None;
				inv.SetDefaultPolygroups();
				inv.bSweepable=inv.Default.bSweepable;
			}
			inv = inv.Inventory;
		}
	}

	function Timer()
	{	// If no one kills, kill self
		SpawnDebris(vect(0,0,0));
		InventoryNormal();
		bHidden=true;
		Died(StatueInstigator, 'blunt', Location);
	}

	function BeginState()
	{
		Acceleration=vect(0,0,0);
		SetPhysics(PHYS_Falling);
		CreatureStatue();
		InventoryStatue();
		Buoyancy = 10;

		if (Weapon!=None && Weapon.bPoweredUp)
			Weapon.PowerupEnd();

		bCanLook = false;
		Target = None;
		bProjTarget = false;
		if (Weapon!=None)
			Weapon.FinishAttack();
		SlowAnimation();

		SetTimer(10, false);
	}

	function EndState()
	{
		Buoyancy = Default.Buoyancy;
		bCanLook = Default.bCanLook;
		SetTimer(0, false);
		bMovable = Default.bMovable;
		bProjTarget = Default.bProjTarget;
		if (AnimProxy != None)
			AnimProxy.GotoState('Idle');
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		bMovable = false;
		global.Landed(HitNormal, HitActor);
	}

	simulated function SlowAnimation()
	{
		//Should play slowing animation here
		PlayAnim('StatueAnim', 1.0, 0.3);
		if (AnimProxy != None)
		{
			AnimProxy.PlayAnim('StatueAnim', 1.0, 0.3);
			AnimProxy.GotoState('Dying');
		}
		bMovable=false;
	}
}


//================================================
//
// IceStatue
//
// Used only for Ice Powerup
//================================================
State() IceStatue
{
ignores PowerupFire, PowerupBlaze, PowerupStone, PowerupIce, PowerupFriend, SetOnFire, WeaponActivate, SwipeEffectStart;

	exec function Fire( optional float F )		{}
	exec function AltFire( optional float F )	{}
	exec function Use()							{}
	exec function Throw()						{}
	exec function Powerup()						{}
	exec function Taunt()						{}
	exec function SwitchWeapon(byte F)			{}

	function bool CanBeStatued()		{	return false;	}
	function bool CanGotoPainState()	{	return(false);	}

	event Tick(float DeltaTime)
	{
		local int i;

		// Update Camera Timer
		CurrentTime += DeltaTime / Level.TimeDilation;

		// Atrophy Strength
		StrengthDecay(DeltaTime);

		// Handle level fade in
		if (LevelFadeAlpha > 0)
		{
			LevelFadeAlpha -= DeltaTime * Level.FadeRate;
			if (LevelFadeAlpha < 0)
				LevelFadeAlpha = 0;
		}
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		PlayerMove(DeltaTime);
	}

	function PlayerMove( float DeltaTime )
	{
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), Dodge_None, rot(0,0,0));
	}

	function EMatterType MatterForJoint(int joint)
	{
		return MATTER_ICE;
	}

	function SpawnDebris(vector Momentum)
	{
		local int numchunks;
		local debris d;
		local vector loc;
		local float scale;
		local int i;

		// Find appropriate size of chunks
		numchunks = Clamp(Mass/10, 2, 15);
		scale = (CollisionRadius*CollisionRadius*CollisionHeight) / (numchunks*500);
		scale = scale ** 0.3333333;

		// Spawn debris
		for (i=0; i<numchunks; i++)
		{
			loc = Location;
			loc.X += (FRand()*2-1)*CollisionRadius;
			loc.Y += (FRand()*2-1)*CollisionRadius;
			loc.Z += (FRand()*2-1)*CollisionHeight;
			d = Spawn(class'debrisice',,,loc);
			if (d != None)
			{
				d.SetSize(scale);
				d.SetMomentum(Momentum);
			}
		}
	}

	function PlayDyingSound(name damageType)
	{
		PlaySound(Sound'WeaponsSnd.impcrashes.crashglass02', SLOT_Pain);
	}

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		local actor A;

		if (DamageType=='sever' || DamageType=='thrownweaponsever' ||
			DamageType=='fire' || DamageType=='electricity')
			return false;

		SpawnDebris(Momentum);
		InventoryNormal();
		bHidden=true;
		Died(EventInstigator, DamageType, HitLoc);
		return false;
	}

	function CreatureStatue()
	{
		local int ix;

		for (ix=0; ix<16; ix++)
		{
			SkelGroupSkins[ix] = texture'statues.ice1';
		}
	}

	function CreatureNormal()
	{
		local int ix;

		// Transform creature to default skin
		for (ix=0; ix<16; ix++)
			SkelGroupSkins[ix] = Default.SkelGroupSkins[ix];
		SetDefaultPolygroups();
	}

	function InventoryStatue()
	{
		local Inventory inv;
		local int ix;

		// Transform inventory if visible
		inv = Inventory;
		while (inv != None)
		{
			if (!inv.bHidden)
			{
				for (ix=0; ix<16; ix++)
				{
					if (inv.SkelGroupSkins[ix] != None)
					{
						inv.SkelGroupSkins[ix] = texture'statues.ice1';
						inv.bSweepable=false;
					}
				}
			}
			inv = inv.Inventory;
		}
	}

	function InventoryNormal()
	{
		local Inventory inv;
		local int ix;

		// Transform inventory if visible
		inv = Inventory;
		while (inv != None)
		{
			if (!inv.bHidden)
			{
				for (ix=0; ix<16; ix++)
					inv.SkelGroupSkins[ix] = None;
				inv.SetDefaultPolygroups();
				inv.bSweepable=inv.Default.bSweepable;
			}
			inv = inv.Inventory;
		}
	}

	function Timer()
	{	// After time expires, come back to life (timer set by powerup)
		SetTimer(0, false);
		SpawnDebris(vect(0,0,0));
		PlaySound(Sound'WeaponsSnd.impcrashes.crashglass02', SLOT_Pain);
		CreatureNormal();
		InventoryNormal();
		GotoState('PlayerWalking');
	}

	function BeginState()
	{
		if (Weapon!=None && Weapon.bPoweredUp)
			Weapon.PowerupEnd();
		if (Weapon!=None)
			Weapon.FinishAttack();

		Acceleration=vect(0,0,0);
		SetPhysics(PHYS_Falling);
		CreatureStatue();
		InventoryStatue();

		Buoyancy = 10;
		SetTimer(5, false);
		bCanLook = false;
		bProjTarget = false;
		SlowAnimation();
	}

	function EndState()
	{
		Buoyancy = Default.Buoyancy;
		bCanLook = Default.bCanLook;
		SetTimer(0, false);
		bMovable = Default.bMovable;
		bProjTarget = Default.bProjTarget;
		if (AnimProxy != None)
			AnimProxy.GotoState('Idle');
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		bMovable = false;
		global.Landed(HitNormal, HitActor);
	}

	function SlowAnimation()
	{
		//Should play slowing animation here
		PlayAnim('StatueAnim', 1.0, 0.3);
		if (AnimProxy != None)
		{
			AnimProxy.PlayAnim('StatueAnim', 1.0, 0.3);
			AnimProxy.GotoState('Dying');
		}
		bMovable=false;
	}
}


//================================================
//
// Unresponsive
//
// State which is used to ignore the user input
//================================================
state Unresponsive
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, Landed;

	exec function Taunt()						{}
	exec function Powerup()						{}
	exec function Throw()						{}
	exec function Fire(optional float F)		{}
	exec function AltFire(optional float F)		{}
	exec function Use()							{}
	exec function SwitchWeapon(byte F)			{}
	exec function Fly()							{}
	exec function Walk()						{}
	exec function Ghost()						{}
	exec function Suicide()						{}
	

	function bool CanBeStatued()		{	return false;	}
	function bool CanGotoPainState()	{	return(false);	}
	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		return false;
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		Acceleration = vect(0,0,0);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		PlayerMove(DeltaTime);
	}

	function PlayerMove( float DeltaTime )
	{
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), Dodge_None, rot(0,0,0));
	}

	function PlayTakeHit(float tweentime, int damage, vector HitLoc, name damageType, vector Momentum, int BodyPart)
	{
	}
		
	function EndState()
	{
		if(AnimProxy != None)
			AnimProxy.GotoState('Idle');
	}

	function BeginState()
	{
		Acceleration = vect(0,0,0);
		Velocity = vect(0,0,0);
		SetPhysics(PHYS_Falling);

		if (Weapon != None)
			Weapon.FinishAttack();

	//	if(AnimProxy != None)
	//		AnimProx.GotoState('Idle');
	}

	function AnimEnd()
	{
		PlayWaiting(0.2);
	}
}



event ShadowUpdate(int ShadowType)
{
	if(ShadowType == 1)
	{ // Blob
		if(shadow == None)
			shadow = Spawn(class'PlayerShadow', self,, Location, Rotation);

		shadow.DrawScale = 1.5 * DrawScale;
		if(shadow != None)
			shadow.Update(None);
	}
/*
	else if(ShadowType == 2)
	{ // Projected shadow
//		if(ShadowTexture == None)
//			ShadowTexture = Spawn(class'ShadowTex', self,,,);
	
	}
*/
}

exec function bool TraceIt()
{
	local vector end;
	local vector HitLocation, HitNormal;

	end = Location + vector(ViewRotation) * 4000;

	Trace(HitLocation, HitNormal, end, Location);

	Spawn(class'HitMetal',,, HitLocation, Rotator(HitNormal));
}


//=============================================================================
//
// Debug
//
//=============================================================================

simulated function Debug(Canvas canvas, int mode)
{
	local vector pos1, pos2;	// testing sweep
	local vector offset;
	local actor A,BestActor;
	local float score,BestScore;
	local int X,Y;

	Super.Debug(canvas, mode);
//	Super(Actor).Debug(canvas, mode);

	Canvas.DrawText("RunePlayer:");
	Canvas.CurY -= 8;
	if(SpeedScale == SS_Circular)
		Canvas.DrawText("  SpeedScale: SS_Circular");
	else if(SpeedScale == SS_Elliptical)
		Canvas.DrawText("  SpeedScale: SS_Elliptical");
	else
		Canvas.DrawText("  SpeedScale: SS_Other");
	Canvas.CurY -= 8;
	Canvas.DrawText("  GroundSpeed: "$GroundSpeed);

/*
	Canvas.DrawText("  LevelFadeAlpha:" $ LevelFadeAlpha);
	Canvas.CurY -= 8;
	Canvas.DrawText("  Vel:         " $ VSize(Velocity));
	Canvas.CurY -= 8;
	Canvas.DrawText("  GroundSpeed: " $ GroundSpeed);
	Canvas.CurY -= 8;
	Canvas.DrawText("  ExploreSpeed:" $ ExploreSpeed);
	Canvas.CurY -= 8;
	Canvas.DrawText("  CombatSpeed: " $ CombatSpeed);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bSurfaceSwim:" $ bSurfaceSwimming);
	Canvas.CurY -= 8;
	Canvas.DrawText("  EyeHeight:   " $ EyeHeight);
	Canvas.CurY -= 8;

	switch(SpeedScale)
	{
		case SS_Circular:
			Canvas.DrawText("  SpeedScale:  SS_Circular");
			break;
		case SS_Elliptical:
			Canvas.DrawText("  SpeedScale:  SS_Elliptical");
			break;
		case SS_Other:
			Canvas.DrawText("  SpeedScale:  SS_Other");
			break;
	}
	Canvas.CurY -= 8;

	// Camera stuff
	Canvas.DrawText("  OldLocation: " $ OldLocation);
	Canvas.CurY -= 8;
	Canvas.DrawText("  ViewLocation: " $ ViewLocation);
	Canvas.CurY -= 8;
	Canvas.DrawText("  ViewRotation: " $ ViewRotation);
	Canvas.CurY -= 8;
	Canvas.DrawText("  CameraDist: " $ CameraDist);
	Canvas.CurY -= 8;
	Canvas.DrawText("  CameraHeight: " $ CameraHeight);
	Canvas.CurY -= 8;
	Canvas.DrawText("  CameraAccel: " $ CameraAccel);
	Canvas.CurY -= 8;
	Canvas.DrawText("  CameraRotSpeed: " $ CameraRotSpeed);
	Canvas.CurY -= 8;
	Canvas.DrawText("  CurrentDist: " $ CurrentDist);
	Canvas.CurY -= 8;
	Canvas.DrawText("  OldCameraStart: " $ OldCameraStart);
	Canvas.CurY -= 8;
	Canvas.DrawText("  CurrentTime[Cam]: " $ CurrentTime);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bBehindView: " $ bBehindView);
*/

	Canvas.CurY -= 8;
	Canvas.DrawText("  OrderObject: " $ OrderObject);
	Canvas.CurY -= 8;
	Canvas.DrawText("  LastHeldWeapon:  " $ LastHeldWeapon);
	Canvas.CurY -= 8;
	if(Weapon != None)
	{
		Canvas.DrawText("  NextWeapon:  " $ GetNextWeapon(Weapon));
		Canvas.CurY -= 8;
	}
	Canvas.DrawText("  PrePivot:  " $ PrePivot);
	Canvas.CurY -= 8;
	Canvas.DrawText("  RopeDist: " $ RopeDist);
	Canvas.CurY -= 8;
	Canvas.DrawText("  SubstituteMesh: " $ SubstituteMesh);
	Canvas.CurY -= 8;
	Canvas.DrawText("  UninterruptedAnim: " $ UninterruptedAnim);
	Canvas.CurY -= 8;

	// Draw grab location
	offset = GrabLocationIn;
//	offset.Z += CollisionHeight * 0.5;
	Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 0, 255, 0);
	Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 0, 255, 0);	
	Canvas.DrawLine3D(offset + vect(0, 0, 10), offset+ vect(0, 0, -10), 0, 255, 0);

	// Test:  Draw Light position
	offset = Location - ShadowVector;
	Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 0, 0, 255);
	Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 0, 0, 255);	
	Canvas.DrawLine3D(offset + vect(0, 0, 10), offset+ vect(0, 0, -10), 0, 0, 255);

	// Draw sweep positions
	if (Weapon != None)
	{
		pos1 = Weapon.GetJointPos(0);
		pos2 = Weapon.GetJointPos(1);
		
		Canvas.DrawLine3D(pos1, pos2, 0,   0, 255);
		Canvas.DrawBox3D(pos1, vect(5,5,5), 0, 30, 255);
		Canvas.DrawBox3D(pos2, vect(5,5,5), 0, 30, 255);
	}

	// Draw look focus scores
	bestScore = 9999999.0;
	bestActor = None;
	foreach VisibleActors(class'actor', A, 1000, Location)
	{
		if(A == self || A.Owner == self)
			continue;
		
		if(A.bLookFocusPlayer)
		{
			score = ScoreLookActor(A);
			if(score < bestScore)
			{
				bestScore = score;
				bestActor = A;
			}

			Canvas.SetColor(255,255,0);
			Canvas.TransformPoint(A.Location, X, Y);
			Canvas.SetPos(X,Y);
			Canvas.DrawText(score, false);
		}
	}
	if (BestActor != None)
	{
		Canvas.SetColor(255,255,255);
		Canvas.TransformPoint(BestActor.Location, X, Y);
		Canvas.SetPos(X,Y);
		Canvas.DrawText(BestScore@"*", false);
	}


	// Test:  Draw DropZ stuff
	offset = Location + vect(0, 0, 60);
	Canvas.DrawLine3D(offset, offset + DropZFloor * 10, 0, 0, 255);
	Canvas.DrawLine3D(offset, offset + DropZRag * 10, 255, 0, 0);
	Canvas.DrawLine3D(offset, offset + DropZResult * 10, 0, 255, 0);
	Canvas.DrawLine3D(offset, offset + DropZRoll * 10, 255, 255, 255);
}

defaultproperties
{
     CrouchHeight=25.000000
     ExploreSpeed=315.000000
     CombatSpeed=225.000000
     bBurnable=True
     CameraDist=180.000000
     CameraAccel=7.000000
     CameraHeight=35.000000
     CameraPitch=450.000000
     CameraRotSpeed=(Pitch=20,Yaw=20,Roll=20)
     TranslucentDist=115.000000
     CurrentDist=200.000000
     StatueAnim=cine_vil_kneeldown
     Die4=Sound'CreaturesSnd.Ragnar.ragdeath04'
     UnderWaterHitSound(0)=Sound'CreaturesSnd.Ragnar.gasp01'
     UnderWaterHitSound(1)=Sound'CreaturesSnd.Ragnar.gasp01'
     UnderWaterHitSound(2)=Sound'CreaturesSnd.Ragnar.gasp01'
     PowerupFail=Sound'OtherSnd.Menu.menu01'
     WeaponPickupSound=Sound'CreaturesSnd.Ragnar.ragpickup02'
     WeaponThrowSound=Sound'CreaturesSnd.Ragnar.ragthrow03'
     WeaponDropSound=Sound'CreaturesSnd.Ragnar.ragdrop02'
     JumpGruntSound(0)=Sound'CreaturesSnd.Ragnar.ragjump01'
     JumpGruntSound(1)=Sound'CreaturesSnd.Ragnar.ragjump02'
     JumpGruntSound(2)=Sound'CreaturesSnd.Ragnar.ragjump03'
     FallingDeathSound=Sound'CreaturesSnd.Ragnar.ragland02'
     FallingScreamSound=Sound'CreaturesSnd.Ragnar.ragfall01'
     UnderWaterDeathSound=Sound'CreaturesSnd.Ragnar.drowned'
     EdgeGrabSound=Sound'CreaturesSnd.Ragnar.raggrab02'
     KickSound=Sound'CreaturesSnd.Ragnar.ragkick01'
     HitSoundLow(0)=Sound'CreaturesSnd.Ragnar.raghit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Ragnar.raghit02'
     HitSoundLow(2)=Sound'CreaturesSnd.Ragnar.raghit03'
     HitSoundMed(0)=Sound'CreaturesSnd.Ragnar.raghit04'
     HitSoundMed(1)=Sound'CreaturesSnd.Ragnar.raghit05'
     HitSoundMed(2)=Sound'CreaturesSnd.Ragnar.raghit06'
     HitSoundHigh(0)=Sound'CreaturesSnd.Ragnar.raghit07'
     HitSoundHigh(1)=Sound'CreaturesSnd.Ragnar.raghit08'
     HitSoundHigh(2)=Sound'CreaturesSnd.Ragnar.raghit09'
     UnderwaterAmbient(0)=Sound'EnvironmentalSnd.Water.underwater01L'
     UnderwaterAmbient(1)=Sound'EnvironmentalSnd.Water.underwater02L'
     UnderwaterAmbient(2)=Sound'EnvironmentalSnd.Water.underwater03L'
     UnderwaterAmbient(3)=Sound'EnvironmentalSnd.Water.underwater04L'
     UnderwaterAmbient(4)=Sound'EnvironmentalSnd.Water.underwater06L'
     UnderwaterAmbient(5)=Sound'EnvironmentalSnd.Water.underwater08L'
     BerserkSoundStart=Sound'WeaponsSnd.PowerUps.powerstart44'
     BerserkSoundEnd=Sound'WeaponsSnd.PowerUps.powerend19'
     BerserkSoundLoop=Sound'CreaturesSnd.Ragnar.ragberzerkL'
     BerserkYellSound(0)=Sound'CreaturesSnd.Ragnar.ragattack01'
     BerserkYellSound(1)=Sound'CreaturesSnd.Ragnar.ragattack02'
     BerserkYellSound(2)=Sound'CreaturesSnd.Ragnar.ragattack03'
     BerserkYellSound(3)=Sound'CreaturesSnd.Ragnar.ragattack04'
     BerserkYellSound(4)=Sound'CreaturesSnd.Ragnar.ragattack05'
     BerserkYellSound(5)=Sound'CreaturesSnd.Ragnar.ragattack06'
     CrouchSound=Sound'CreaturesSnd.Ragnar.ragpickup02'
     RopeClimbSound(0)=Sound'OtherSnd.Pickups.grab02'
     RopeClimbSound(1)=Sound'OtherSnd.Pickups.grab01'
     RopeClimbSound(2)=Sound'OtherSnd.Pickups.grab02'
     NoRunePowerMsg="Not enough RUNE POWER"
     bCanRestart=True
     bSinglePlayer=True
     CarcassType=Class'RuneI.PlayerCarcass'
     bBehindView=True
     bCanStrafe=True
     bIsHuman=True
     bCanGrabEdges=True
     MeleeRange=50.000000
     GroundSpeed=315.000000
     WaterSpeed=300.000000
     AirSpeed=400.000000
     AccelRate=2048.000000
     JumpZ=425.000000
     AirControl=0.250000
     PeripheralVision=-0.500000
     BaseEyeHeight=25.000000
     EyeHeight=25.000000
     BodyPartHealth(1)=75
     BodyPartHealth(3)=75
     BodyPartHealth(5)=75
     GibCount=10
     GibClass=Class'RuneI.DebrisFlesh'
     UnderWaterTime=60.000000
     Intelligence=BRAINS_HUMAN
     Die=Sound'CreaturesSnd.Ragnar.ragdeath01'
     Die2=Sound'CreaturesSnd.Ragnar.ragdeath02'
     Die3=Sound'CreaturesSnd.Ragnar.ragdeath03'
     LandGrunt=Sound'CreaturesSnd.Ragnar.ragland01'
     FootStepWood(0)=Sound'FootstepsSnd.Wood.footwood02'
     FootStepWood(1)=Sound'FootstepsSnd.Wood.footlandwood02'
     FootStepWood(2)=Sound'FootstepsSnd.Wood.footwood05'
     FootStepMetal(0)=Sound'FootstepsSnd.Metal.footmetal01'
     FootStepMetal(1)=Sound'FootstepsSnd.Metal.footmetal02'
     FootStepMetal(2)=Sound'FootstepsSnd.Metal.footmetal05'
     FootStepStone(0)=Sound'FootstepsSnd.Earth.footgravel09'
     FootStepStone(1)=Sound'FootstepsSnd.Earth.footgravel10'
     FootStepStone(2)=Sound'FootstepsSnd.Earth.footgravel09'
     FootStepFlesh(0)=Sound'FootstepsSnd.Earth.footsquish02'
     FootStepFlesh(1)=Sound'FootstepsSnd.Earth.footsquish07'
     FootStepFlesh(2)=Sound'FootstepsSnd.Earth.footsquish09'
     FootStepIce(0)=Sound'FootstepsSnd.Ice.footice01'
     FootStepIce(1)=Sound'FootstepsSnd.Ice.footice02'
     FootStepIce(2)=Sound'FootstepsSnd.Ice.footice03'
     FootStepEarth(0)=Sound'FootstepsSnd.Earth.footgravel01'
     FootStepEarth(1)=Sound'FootstepsSnd.Earth.footgravel02'
     FootStepEarth(2)=Sound'FootstepsSnd.Earth.footgravel04'
     FootStepSnow(0)=Sound'FootstepsSnd.Snow.footsnow01'
     FootStepSnow(1)=Sound'FootstepsSnd.Snow.footsnow02'
     FootStepSnow(2)=Sound'FootstepsSnd.Snow.footsnow04'
     FootStepWater(0)=Sound'FootstepsSnd.Water.footwaterwaist01'
     FootStepWater(1)=Sound'FootstepsSnd.Water.footwaterwaist02'
     FootStepWater(2)=Sound'FootstepsSnd.Water.footwaterwaist03'
     FootStepMud(0)=Sound'FootstepsSnd.Mud.footmud01'
     FootStepMud(1)=Sound'FootstepsSnd.Mud.footmud02'
     FootStepMud(2)=Sound'FootstepsSnd.Mud.footmud03'
     FootStepLava(0)=Sound'FootstepsSnd.Lava.footlava02'
     FootStepLava(1)=Sound'FootstepsSnd.Lava.footlava03'
     FootStepLava(2)=Sound'FootstepsSnd.Lava.footlava07'
     LandSoundWood=Sound'FootstepsSnd.Earth.footlandearth01'
     LandSoundMetal=Sound'FootstepsSnd.Metal.footmetal04'
     LandSoundStone=Sound'FootstepsSnd.Earth.footlandearth04'
     LandSoundFlesh=Sound'FootstepsSnd.Earth.footsquish06'
     LandSoundIce=Sound'FootstepsSnd.Earth.footlandearth02'
     LandSoundSnow=Sound'FootstepsSnd.Snow.footlandsnow05'
     LandSoundEarth=Sound'FootstepsSnd.Earth.footlandearth05'
     LandSoundWater=Sound'FootstepsSnd.Water.footlandwater02'
     LandSoundMud=Sound'FootstepsSnd.Mud.footlandmud01'
     LandSoundLava=Sound'FootstepsSnd.Lava.footlava01'
     WeaponJoint=attach_hand
     ShieldJoint=attach_shielda
     StabJoint=spineb
     bCanLook=True
     MaxBodyAngle=(Yaw=5000)
     MaxHeadAngle=(Yaw=7000)
     bHeadLookUpDouble=True
     LookDegPerSec=360.000000
     FootprintClass=Class'RuneI.footprint'
     WetFootprintClass=Class'RuneI.FootprintWet'
     BloodyFootprintClass=Class'RuneI.FootprintBloody'
     LFootJoint=5
     RFootJoint=9
     bFootsteps=True
     DeathRadius=40.000000
     DeathHeight=8.000000
     AnimSequence=WalkSm
     DrawType=DT_SkeletalMesh
     Sprite=Texture'RuneFX.shadow'
     Texture=Texture'Engine.S_Corpse'
     CollisionRadius=18.000000
     CollisionHeight=42.000000
     Buoyancy=99.000000
     Skeletal=SkelModel'Players.Ragnar'
}
