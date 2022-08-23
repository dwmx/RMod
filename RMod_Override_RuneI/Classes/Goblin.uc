//=============================================================================
// Goblin.
//=============================================================================
class Goblin expands ScriptPawn;

/* Description:

   Walk speed = 54 @ 20Hx
   Run speed = 260 @ 15Hz
   
   ANIMS:
   	HuntStop Animation (sniffing)
   	Threaten anim

   TODO:
*/

var(Sounds) sound		RollSound;
var(Sounds) sound		PaceSound;


enum EGoblinLimb
{
	LIMB_RANDOM,
	LIMB_RANDOMWARPAINT,
	LIMB_NORMAL,
	LIMB_WARPAINT1
};

enum EGoblinTorso
{
	TORSO_RANDOM,
	TORSO_RANDOMWARPAINT,
	TORSO_NORMAL,
	TORSO_WARPAINT1,
	TORSO_WARPAINT2,
	TORSO_WARPAINT3
};

enum EGoblinHead
{
	HEAD_RANDOM,
	HEAD_RANDOMWARPAINT,
	HEAD_NORMAL,
	HEAD_WARPAINT1,
	HEAD_WARPAINT2,
	HEAD_WARPAINT3
};


var() EGoblinLimb	GoblinLimb;
var() EGoblinTorso	GoblinTorso;
var() EGoblinHead	GoblinHead;
var() bool			bGoblinMask;

var Actor CurrentPoint;
var private int breathcounter;


//===================================================================
//					Functions
//===================================================================

//============================================================
//
// PreBeginPlay
//
//============================================================
function PreBeginPlay()
{
	Super.PreBeginPlay();

	SetupGoblin();
}

//------------------------------------------------
//
// AttitudeToCreature
//
//------------------------------------------------
function eAttitude AttitudeToCreature(Pawn Other)
{
	if (Other.IsA('Dwarf') || Other.IsA('Viking') || Other.IsA('Zombie') || Other.IsA('Sark'))
		return ATTITUDE_Hate;
	else if (Other.IsA('Snowbeast'))
		return ATTITUDE_Fear;
	else
		return Super.AttitudeToCreature(Other);
}


//============================================================
//
// SetupGoblin
//
//============================================================
function SetupGoblin()
{
	local EGoblinLimb limbs;
	local EGoblinTorso torso;
	local EGoblinHead head;

	limbs = GoblinLimb;
	switch(GoblinLimb)
	{
		case LIMB_RANDOM:
			switch(Rand(2))
			{
				case 0:	limbs = LIMB_NORMAL;	break;
				case 1:	limbs = LIMB_WARPAINT1;	break;
			}
			break;
		case LIMB_RANDOMWARPAINT:
			limbs = LIMB_WARPAINT1;
			break;
	}

	torso = GoblinTorso;
	switch(GoblinTorso)
	{
		case TORSO_RANDOM:
			switch(Rand(4))
			{
				case 0:	torso = TORSO_NORMAL;		break;
				case 1:	torso = TORSO_WARPAINT1;	break;
				case 2:	torso = TORSO_WARPAINT2;	break;
				case 3:	torso = TORSO_WARPAINT3;	break;
			}
			break;
		case TORSO_RANDOMWARPAINT:
			switch(Rand(3))
			{
				case 0:	torso = TORSO_WARPAINT1;	break;
				case 1:	torso = TORSO_WARPAINT2;	break;
				case 2:	torso = TORSO_WARPAINT3;	break;
			}
			break;
	}
	
	head = GoblinHead;
	switch(GoblinHead)
	{
		case HEAD_RANDOM:
			switch(Rand(4))
			{
				case 0:	head = HEAD_NORMAL;		break;
				case 1:	head = HEAD_WARPAINT1;	break;
				case 2:	head = HEAD_WARPAINT2;	break;
				case 3:	head = HEAD_WARPAINT3;	break;
			}
			break;
		case HEAD_RANDOMWARPAINT:
			switch(Rand(3))
			{
				case 0:	head = HEAD_WARPAINT1;	break;
				case 1:	head = HEAD_WARPAINT2;	break;
				case 2:	head = HEAD_WARPAINT3;	break;
			}
			break;
	}

	SetGoblinSkins(limbs, torso, head);

	if (bGoblinMask)
		AttachMask();
}


//============================================================
//
// AttachMask
//
//============================================================
function AttachMask()
{
	local actor mask;
	mask = Spawn(class'GoblinMask',,, GetJointPos(JointNamed('head')),);
	if (mask != None)
	{
		AttachActorToJoint(mask, JointNamed('head'));
		mask.PlayAnim('on_face', 1.0, 0.1);
	}
	else slog("No spawn mask");
}


//============================================================
//
// SetGoblinSkins
//
//============================================================
function SetGoblinSkins(EGoblinLimb arms, EGoblinTorso torso, EGoblinHead head)
{
	switch(arms)
	{
		case LIMB_NORMAL:
			break;
		case LIMB_WARPAINT1:
			SkelGroupSkins[2] = texture'runei.goblinpaintedarmleg';
			SkelGroupSkins[12] = texture'runei.goblinpaintedarmleg';
			SkelGroupSkins[8] = texture'runei.goblinpaintedarmleg';
			SkelGroupSkins[11] = texture'runei.goblinpaintedarmleg';
			break;
	}
	switch(torso)
	{
		case TORSO_NORMAL:
			break;
		case TORSO_WARPAINT1:
			SkelGroupSkins[7] = texture'runei.goblinpaintedbody';
			break;
		case TORSO_WARPAINT2:
			SkelGroupSkins[7] = texture'runei.goblinpaintedbody2';
			break;
		case TORSO_WARPAINT3:
			SkelGroupSkins[7] = texture'runei.goblinpaintedbody3';
			break;
	}
	switch(head)
	{
		case HEAD_NORMAL:
			break;
		case HEAD_WARPAINT1:
			SkelGroupSkins[1] = texture'runei.goblinpaintedhead';
			SkelGroupSkins[6] = texture'runei.goblinpaintedhead';
			break;
		case HEAD_WARPAINT2:
			SkelGroupSkins[1] = texture'runei.goblinpaintedhead2';
			SkelGroupSkins[6] = texture'runei.goblinpaintedhead2';
			break;
		case HEAD_WARPAINT3:
			SkelGroupSkins[1] = texture'runei.goblinpaintedhead3';
			SkelGroupSkins[6] = texture'runei.goblinpaintedhead3';
			break;
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
		return (item.IsA('axe') || item.IsA('hammer') || item.IsA('Torch'));
	}
	else if (item.IsA('Shield') && (BodyPartHealth[BODYPART_LARM1] > 0) && (Shield == None))
	{
		return item.IsA('Shield');
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
	local Texture newpage;
	local Texture oldpage;
	
	switch(BodyPart)
	{
		case BODYPART_TORSO:
			oldpage = SkelGroupSkins[7];
			if (oldpage == Texture'creatures.goblinbody')
				newpage = Texture'creatures.goblinpainbody';
			else if (oldpage == Texture'creatures.goblinpaintedbody')
				newpage = Texture'creatures.goblinpainbodypainted1';
			else if (oldpage == Texture'creatures.goblinpaintedbody2')
				newpage = Texture'creatures.goblinpainbodypainted2';
			else if (oldpage == Texture'creatures.goblinpaintedbody3')
				newpage = Texture'creatures.goblinpainbodypainted3';
			else
				newpage = oldpage;
			SkelGroupSkins[7] = newpage;
			break;
		case BODYPART_HEAD:
			oldpage = SkelGroupSkins[1];
			if (oldpage == Texture'creatures.goblinhead')
				newpage = Texture'creatures.goblinpainhead';
			else if (oldpage == Texture'creatures.goblinpaintedhead')
				newpage = Texture'creatures.goblinpainheadpainted';
			else if (oldpage == Texture'creatures.goblinpaintedhead2')
				newpage = Texture'creatures.goblinpainheadpainted2';
			else if (oldpage == Texture'creatures.goblinpaintedhead3')
				newpage = Texture'creatures.goblinpainheadpainted3';
			else
				newpage = oldpage;
			SkelGroupSkins[1] = newpage;
			SkelGroupSkins[6] = newpage;
			break;
		case BODYPART_LARM1:
			oldpage = SkelGroupSkins[2];
			if (oldpage == Texture'creatures.goblinarmleg')
				newpage = Texture'creatures.goblinpainarmleg';
			else if (oldpage == Texture'creatures.goblinpaintedarmleg')
				newpage = Texture'creatures.goblinpainarmlegpainted';
			else
				newpage = oldpage;
			SkelGroupSkins[2] = newpage;
			SkelGroupSkins[8] = newpage;
			break;
		case BODYPART_RARM1:
			oldpage = SkelGroupSkins[11];
			if (oldpage == Texture'creatures.goblinarmleg')
				newpage = Texture'creatures.goblinpainarmleg';
			else if (oldpage == Texture'creatures.goblinpaintedarmleg')
				newpage = Texture'creatures.goblinpainarmlegpainted';
			else
				newpage = oldpage;
			SkelGroupSkins[11] = newpage;
			SkelGroupSkins[12] = newpage;
			break;
		case BODYPART_LLEG1:
			oldpage = SkelGroupSkins[3];
			if (oldpage == Texture'creatures.goblinarmleg')
				newpage = Texture'creatures.goblinpainarmleg';
			else if (oldpage == Texture'creatures.goblinpaintedarmleg')
				newpage = Texture'creatures.goblinpainarmlegpainted';
			else
				newpage = oldpage;
			SkelGroupSkins[3] = newpage;
			break;
		case BODYPART_RLEG1:
			oldpage = SkelGroupSkins[4];
			if (oldpage == Texture'creatures.goblinarmleg')
				newpage = Texture'creatures.goblinpainarmleg';
			else if (oldpage == Texture'creatures.goblinpaintedarmleg')
				newpage = Texture'creatures.goblinpainarmlegpainted';
			else
				newpage = oldpage;
			SkelGroupSkins[4] = newpage;
			break;
	}
	return None;
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
		case 9:						return BODYPART_LARM1;
		case 15:					return BODYPART_RARM1;
		case 24:					return BODYPART_RLEG1;
		case 27:					return BODYPART_LLEG1;
		case 20:					return BODYPART_HEAD;
		case 1: case 4: case 5:		return BODYPART_TORSO;
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
		case 1: case 6:						return BODYPART_HEAD;
		case 2:								return BODYPART_LARM1;
		case 12:							return BODYPART_RARM1;
		case 3:								return BODYPART_LLEG1;
		case 4:								return BODYPART_RLEG1;
		case 5: case 7: case 8: case 9:
			case 10: case 11:				return BODYPART_TORSO;
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
	switch(BodyPart)
	{
		case BODYPART_LARM1:
			SkelGroupSkins[9] = Texture'runefx.gore_bone';
			SkelGroupFlags[9] = SkelGroupFlags[9] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[10] = Texture'runefx.gore_bone';
			SkelGroupFlags[10] = SkelGroupFlags[10] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[5] = Texture'runefx.gore_bone';
			SkelGroupFlags[5] = SkelGroupFlags[5] & ~POLYFLAG_INVISIBLE;
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
			return class'GoblinLArm';
		case BODYPART_RARM1:
			return class'GoblinRArm';
		case BODYPART_HEAD:
			return class'GoblinHead';
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
	local vector X,Y,Z,pos;
	local vector cameralocation;
	local actor dummyactor;
	local rotator camerarotation;
	local class<actor> partclass;

	Super.LimbSevered(BodyPart, Momentum);
	
	ApplyGoreCap(BodyPart);
	partclass = SeveredLimbClass(BodyPart);

	switch(BodyPart)
	{
		case BODYPART_LARM1:
			joint = JointNamed('lshould');
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
	
		case BODYPART_RARM1:
			joint = JointNamed('rshould');
			pos = GetJointPos(joint);
			GetAxes(Rotation, X, Y, Z);
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
/*
				if (Enemy != None && PlayerPawn(Enemy) != None && VSize(Enemy.Location-part.Location)<1000)
				{
					PlayerPawn(Enemy).PlayerCalcView(dummyactor, cameralocation, camerarotation);
					part.Velocity = CalcArcVelocity(8192, part.Location, cameralocation);
					part.Velocity *= 0.6;//testfloat;
				}
				else
				{
					part.Velocity = 0.75 * (momentum / Mass) + vect(0, 0, 300);
				}
*/
				part.Velocity = 0.75 * (momentum / Mass) + vect(0, 0, 300);

				part.GotoState('Drop');
				part.SkelGroupSkins[4] = SkelGroupSkins[6]; // Set the Head texture properly
			}
			part = Spawn(class'BloodSpurt', self,, pos, Rotation);
			if(part != None)
			{
				AttachActorToJoint(part, joint);
			}
			break;
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
	if(Other.IsA('DecorationRune') && DecorationRune(Other).bDestroyable && Health>0)
	{
		if(Weapon == None)
			PlayUninterruptedAnim('swipe');
		else
			PlayUninterruptedAnim('attackb');
	}
	else
	{
		Super.Bump(Other);
	}
}


//============================================================
// Animation functions
//============================================================

function PlayWaiting(optional float tween)
{
	if (BodyPartHealth[BODYPART_LARM1] <= 0 ^^
		BodyPartHealth[BODYPART_RARM1] <= 0)
	{
		if (BodyPartHealth[BODYPART_LARM1]<=0)
			LoopAnim  ('idleA_leftpain',  RandRange(0.8, 1.2), 0.1);
		else
			LoopAnim  ('idleA_rightpain', RandRange(0.8, 1.2), 0.1);
	}
	else if (Weapon==None)
		LoopAnim  ('idleA',           RandRange(0.8, 1.2), 0.1);
	else if (Weapon.IsA('Torch'))
		LoopAnim  ('idleA_torch',     RandRange(0.8, 1.2), 0.1);
	else
		LoopAnim  ('w_idleA',         RandRange(0.8, 1.2), 0.1);
}
function PlayMoving(optional float tween)
{
	if (bHurrying)
	{
		if (Weapon==None)						LoopAnim  ('w_gallopB',		1.0, tween);
		else if (Weapon.IsA('Torch'))			LoopAnim  ('w_gallopB_torch', 1.0, tween);
		else									LoopAnim  ('w_gallopB_weapon',1.0, tween);
	}
	else
	{
		if (Weapon==None)						LoopAnim  ('walkB',			1.0, tween);
		else									LoopAnim  ('walkB',			1.0, tween);
	}
}
function PlayJumping(optional float tween)    { PlayAnim  ('jump',			1.0, tween);   }
function PlayHuntStop(optional float tween)   { LoopAnim  ('w_idleA',		1.0, tween);   }
function PlayMeleeHigh(optional float tween)
{
	if (Weapon==None)							PlayAnim  ('swipe',			1.0, tween);
	else										PlayAnim  ('attackb',		1.0, tween);
}
function PlayMeleeLow(optional float tween)
{
	if (Weapon==None)							PlayAnim  ('swipe',			1.0, tween);
	else										PlayAnim  ('attackb',		1.0, tween);
}
function PlayTurning(optional float tween)
{
	local int YawErr;
	YawErr = Abs(DesiredRotation.Yaw - Rotation.Yaw);
	//TODO: based on turn rate, turn amount, vary length of hop
												PlayAnim  ('hopA',			1.0, tween);
}
function PlayCower(optional float tween)      { LoopAnim  ('cower',			1.0, tween);   }
function PlayThrowing(optional float tween)   { PlayAnim  ('throwA',		1.0, tween);   }
function PlayTaunting(optional float tween)   { PlayAnim  ('pain',			1.0, tween);   }
function PlayInAir(optional float tween)
{
	LoopAnim  ('blockhigh',	1.0, tween);
}

function PlayDodgeLeft(optional float tween)  { PlayAnim  ('rollleft',		1.0, tween);   }
function PlayDodgeRight(optional float tween) { PlayAnim  ('rollright',		1.0, tween);   }
function PlayDodgeForward(optional float tween){PlayAnim  ('hopA',			1.0, tween);   }
function PlayDodgeBack(optional float tween)  { PlayAnim  ('dodgeback',		1.0, tween);   }
function PlayDodgeBackflip(optional float tween){PlayAnim ('flip2',			1.0, tween);   }
function PlayDodgeDuck(optional float tween)  { PlayAnim  ('duck',			1.0, tween);   }
function PlayBlockHigh(optional float tween)  { LoopAnim  ('blocklow',		1.0, tween);   }
function PlayBlockLow(optional float tween)   { LoopAnim  ('blocklow',		1.0, tween);   }

function PlayFrontHit(float tween)            { PlayAnim  ('pain',			1.0, tween);   }
function PlayDrowning(optional float tween)   { LoopAnim  ('drown',			1.0, tween);   }

function PlayDeath(name DamageType)
{
	if (FRand()<0.5)
											  PlayAnim('death',			1.0, 0.1);	
	else
											  PlayAnim('deathB',		1.0, 0.1);	
}
function PlayBackDeath(name DamageType)		{ PlayAnim('deathS',		1.0, 0.1);	}
function PlayLeftDeath(name DamageType)		{ PlayAnim('deathR',		1.0, 0.1);	}
function PlayRightDeath(name DamageType)	{ PlayAnim('deathB',		1.0, 0.1);	}
function PlayHeadDeath(name DamageType)		{ PlayAnim('deathF',		1.0, 0.1);	}
function PlaySkewerDeath(name DamageType)	{ PlayAnim('death',			1.0, 0.1);	}
function PlayDrownDeath(name DamageType)	{ PlayAnim('drown_death',	1.0, 0.1);	}

// Tween functions
function TweenToWaiting(float time)
{	if (BodyPartHealth[BODYPART_LARM1] <= 0 ^^
		BodyPartHealth[BODYPART_RARM1] <= 0)
	{	if (BodyPartHealth[BODYPART_LARM1]<=0)	TweenAnim ('idleA_leftpain',	time);
		else									TweenAnim ('idleA_rightpain',	time);
	}
	else if (Weapon==None)						TweenAnim ('idleA',				time);
	else if (Weapon.IsA('Torch'))				TweenAnim ('idleA_torch',		time);
	else										TweenAnim ('w_idleA',			time);
}
function TweenToMoving(float time)
{
	if (bHurrying)
	{
		if (Weapon==None)						TweenAnim ('w_gallopB',			time);
		else if (Weapon.IsA('Torch'))			TweenAnim ('w_gallopB_torch',	time);
		else									TweenAnim ('w_gallopB_weapon',	time);
	}
	else
	{
		if (Weapon==None)						TweenAnim ('walkB',				time);
		else									TweenAnim ('walkB',				time);
	}
}
function TweenToTurning(float time)           {	TweenAnim ('hopA',				time);	}
function TweenToJumping(float time)           {	TweenAnim ('jump',				time);	}
function TweenToHuntStop(float time)          { TweenAnim ('w_idlaA',			time);	}
function TweenToMeleeHigh(float time)
{
	if (Weapon==None)							TweenAnim ('swipe',				time);
	else										TweenAnim ('attackb',			time);
}
function TweenToMeleeLow(float time)
{
	if (Weapon==None)							TweenAnim ('swipe',				time);
	else										TweenAnim ('attackb',			time);
}
function TweenToThrowing(float time)          { TweenAnim ('throwA',			time);	}


//------------------------------------------------
//
// Sound Functions
//
//------------------------------------------------
function Breath()
{
	local int joint;
	local vector l;
	local actor A;

	if (++breathcounter > 2)
	{
		breathcounter = 0;
		OpenMouth(0.5, 0.5);

		if (HeadRegion.Zone.bWaterZone)
		{
			// Spawn Bubbles
			joint = JointNamed('jaw');
			l = GetJointPos(joint);
			if(FRand() < 0.3)
			{
				Spawn(class'BubbleSystemOneShot',,, l,);
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


//===================================================================
//					States
//===================================================================
State MineRocks
{
Begin:
	LoopAnim('attackb', 1.0, 0.3);
	Sleep(3);
	FinishAnim();

	TossWeapon();

	OrderObject = NextPoint;
	GotoState(NextState, NextLabel);
}


//============================================================
//
// MinRocksPartner1
//
//============================================================
state MineRocksPartner1
{
	ignores SeePlayer, HearNoise, EnemyAcquired;

Begin:
Swing:
	PlayAnim('attackb', 1.0, 0.2);
	FinishAnim();
	ReleaseTagged('miner2');
WaitForPartner:
	LoopAnim('w_idleA', 1.0, 0.2);
	WaitForRelease();
	FinishAnim();
	goto('Swing');
}


//============================================================
//
// MineRocksPartner2
//
//============================================================
state MineRocksPartner2
{
	ignores SeePlayer, HearNoise, EnemyAcquired;

Begin:
	Goto('WaitForPartner');
Swing:
	PlayAnim('attackb', 1.0, 0.2);
	FinishAnim();
	ReleaseTagged('miner1');
WaitForPartner:
	LoopAnim('w_idleA', 1.0, 0.2);
	WaitForRelease();
	FinishAnim();
	goto('Swing');
}


//============================================================
//
// ThrowTest
//
//============================================================
state ThrowTest
{
	function Timer()
	{
		if (DesiredMouthRot == 0)
			OpenMouth(0.5, 0.5);
		else
			OpenMouth(0.0, 0.5);
		SetTimer(0.5, false);
	}

	function SpawnRock()
	{
		local RockSmall rock;
		rock = Spawn(class'RockSmall');
		AttachActorToJoint(rock, JointNamed('weapon'));
	}

Begin:
	PlayWaiting(0.2);
	OpenMouth(1, 1.0);
	Sleep(0.2);
	SetTimer(0.2, false);
	SpawnRock();
	Sleep(5);
	NextState = 'ThrowTest';
	NextLabel = 'Begin';
	OrderObject = ActorTagged('throwtarget');
	GotoState('Throwing');
}


//============================================================
//
// AlertSquawk
//
//============================================================
State AlertSquawk
{
Begin:
	LookAt(Enemy);
	SoundChance(AcquireSound, 1.0);
	OpenMouth(1, 1);
	Sleep(0.3);
	OpenMouth(0, 1);
	Sleep(2);
	Goto('InformTeam');
}

State Excited
{
	function EnemyNotVisible()
	{
		GotoState('Startup', 'Restart');
	}

Begin:
	if (Enemy == None)
		Enemy = Pawn(OrderObject);

	LookAt(Enemy);
	PlayTurning();
	TurnToward(Enemy);
	FinishAnim();

Jump:
	if (FRand()<0.5)
	{
		PlayAnim('hopA', 1.0, 0.2);
		AddVelocity(vect(0,0,200));
		WaitForLanding();
		FinishAnim();
	}
	else
	{
		TweenAnim('flip', 0.2);
		FinishAnim();
		PlayAnim('flip', 1.0);
		Sleep(0.2);
		AddVelocity(vect(0,0,500));
		WaitForLanding();
		FinishAnim();
	}
	if (FRand() < 0.8)
		Goto('Jump');

	PlayWaiting();
	Sleep(RandRange(1.5, 4));
	FinishAnim();
	Goto('Jump');
}

//============================================================
//
// ThrowRocks
//
//============================================================
State ThrowRocks
{
ignores SeePlayer, HearNoise, EnemyAcquired;

	function EnemyNotVisible()
	{
		bAlerted = false;
		OrderFinished();
		GotoState('Startup', 'Restart');
	}
	
	function SpawnRock()
	{
		local RockSmall rock;
		rock = Spawn(class'RockSmall');
		AttachActorToJoint(rock, JointNamed('weapon'));
	}

	function bool EnemyInRange(float range)
	{
		return VSize2D(Enemy.Location - Location) < range;
	}
	
Begin:
	PlayWaiting(0.2);

	if (EnemyInRange(300))
		GotoState('Acquisition');

	if (Enemy == None || !EnemyInRange(1000))
	{
		Sleep(2);
		Goto('Begin');
	}
	SpawnRock();
	Sleep(3);
	NextState = 'ThrowRocks';
	NextLabel = 'Begin';
	OrderObject = Enemy;
	GotoState('Throwing');

}


//============================================================
//
// StayOnPaths
//
//============================================================
State StayOnPaths
{
ignores SeePlayer, EnemyNotVisible, HearNoise;

	function BeginState()
	{
		bHurrying = false;
		UpdateMovementSpeed();
	}

	function EndState()
	{
		LookAt(None);
	}

	// Consider all destinations from OrderObject to stay close to enemy
	function PickDestination()
	{
		local int numpaths, numpaths2, i, j;
		local NavigationPoint dest, dest2, closest;
		local float closestdist, dist;

		if (NavigationPoint(CurrentPoint) != None)
		{
			numpaths = NavigationPoint(CurrentPoint).NumPaths();
			closest = NavigationPoint(CurrentPoint);
			closestdist = VSize(Enemy.Location - CurrentPoint.Location);
			for (i=0; i<numpaths; i++)
			{
				// Consider one step down the graph
				dest = NavigationPoint(NavigationPoint(CurrentPoint).PathEndPoint(i));
				if (dest != None)
				{
					dist = VSize(Enemy.Location - dest.Location);
					if (dist < closestdist)
					{
						closestdist = dist;
						closest = dest;
					}

					// Consider two steps down the graph
					numpaths2 = dest.NumPaths();
					for (j=0; j<numpaths2; j++)
					{
						dest2 = NavigationPoint(dest.PathEndPoint(j));
						if (dest2!=None)
						{
							dist = VSize(Enemy.Location - dest2.Location);
							if (dist < closestdist)
							{
								closestdist = dist;
								closest = dest;
							}
						}
					}
				}
			}
			OrderObject = closest;
		}
	}

	function HitWall(vector norm, actor wall)
	{
//		slog("hit wall");
	}
	
	function MayFall()
	{
//		slog("may fall");
	}
	
Begin:
	LookAt(Enemy);
OrderObject = None;
	// Stay on paths, staying as close to enemy as possible
	if (OrderObject == None)
		OrderObject = NearestNavPoint();
	Goto('path');
	
	// OrderObject is my final destination
	// MoveTarget is my next waypoint
	
Move:
Path:
//slog("orderobject="$OrderObject.name);
	if (actorReachable(OrderObject))
	{
//	slog("..reachable - oo="$OrderObject);
		PlayMoving(0.2);
		MoveToward(OrderObject, MovementSpeed);
		FinishAnim();
		CurrentPoint = OrderObject;
		Goto('Turn');
	}
	else if (FindBestPathToward(OrderObject))
	{
//	slog("..not reachable - path="$MoveTarget);
		PlayMoving(0.1);
		MoveToward(MoveTarget, MovementSpeed);
		FinishAnim();
		CurrentPoint = MoveTarget;
		Goto('Path');
	}
	else
	{
//	slog("..not pathable - picking dest");
		PickDestination();
		if (CurrentPoint != OrderObject && OrderObject != None)
		{
			Sleep(0);
			Goto('Move');
		}
		FinishAnim();
		Acceleration = vect(0,0,0);
		Goto('Wait');
	}

Turn:	
	PlayTurning();
	TurnToward(Enemy);
	FinishAnim();
	SoundChance(RoamSound, 1.0);

Wait:
	PlayWaiting();
	Sleep(1);

Check:
	if (VSize(Enemy.Location-Location) < 4000)
	{
		OrderObject = Enemy.NearestNavPoint();
		if (OrderObject != None && OrderObject != CurrentPoint)
		{
			Goto('Move');
		}
	}
	
	Sleep(2);
	Goto('Check');
}


//================================================
//
// Charging
//
//================================================
State Charging
{
ignores EnemyAcquired, SeePlayer, HearNoise;

	// Inherits EndState()

	function BeginState()
	{
		StopLookingToward();
		LookAt(Enemy);
		SetTimer(0.1, true);
		bHurrying = true;
		UpdateMovementSpeed();
	}
	

	function MayFall()
	{	// Only jump if reachable
		bCanJump = ( (Enemy!=None) && actorReachable(Enemy) );
	}

	function Timer()
	{
		if (Enemy!=None && (Enemy.bSwingingHigh || Enemy.bSwingingLow) && InMeleeRange(Enemy))
		{
			GotoState('Fighting', 'CheckDefend');
		}
	}

	function EnemyNotVisible()
	{
		GotoState('Hunting');
	}
	
	function PickPaceDest()
	{
		local vector X,Y,Z;
		local vector PaceVect;
		
		GetAxes(Enemy.Rotation, X, Y, Z);
		PaceVect = Y * PaceRange * 0.3; // 1/3 the distance -- cjr
		if (FRand() < 0.5)
		{
			Destination = Enemy.Location + PaceVect;
		}
		else
		{
			Destination = Enemy.Location - PaceVect;
		}
	}
	
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
			
		//TODO: Test whether climbable, then set falling
		if (bCanGrabEdges && bCanStrafe)
		{
			SetPhysics(PHYS_Falling);
			return;
		}
		
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Charging', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
			GotoState('Charging', 'AdjustFromWall');
		else
			MoveTimer = -1.0;
	}
	
AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Goto('CloseIn');

ResumeCharge:
	PlayMoving();
	Goto('Charge');

Begin:
	if(debugstates) slog(name@"GoblinCharging");

TweenIn:
	TweenToMoving(0.15);
	FinishAnim();
	PlayMoving();

Charge:
	bFromWall = false;
	
CloseIn:
	if ( JumpZ > 0 )		// This may have been set false in Mayfall, so reset
		bCanJump = true;
	if ( !ValidEnemy() )
		GotoState('GoingHome');

	if ( Enemy.Region.Zone.bWaterZone )
	{	// Enemy entered water zone
		if (!bCanSwim)
			GotoState('TacticalDecision');
	}
	else if (!bCanFly && !bCanWalk)
		// Enemy left water zone
		GotoState('GoingHome');

	if (Physics == PHYS_Falling)
	{	// If falling, wait for land
		if (NeedToTurn(Enemy.Location))
		{
			DesiredRotation = Rotator(Enemy.Location - Location);
			Focus = Enemy.Location;
			Destination = Enemy.Location;
		}
		WaitForLanding();
	}

Pace:
	if( actorReachable(Enemy) )
	{
		if (bPaceAttack && FRand() < 0.75 && InPaceRange(Enemy))
		{
			PlayMoving(0.2);
			PickPaceDest();
			MoveTo(Destination, MovementSpeed);
			PlayTurning(0.1);
			TurnToward(Enemy);
			SoundChance(PaceSound, 1.0);
			FinishAnim();
			PlayMoving(0.2);
			if (FRand() < 0.5)
			{	// Wait and continue pacing
				Acceleration = vect(0,0,0);
				SoundChance(ThreatenSound, 0.3);
				Goto('Pace');
			}
		}

		if (bLungeAttack && FRand()<0.3 && InLungeRange(Enemy))
		{
			Goto('GotThere');
		}
		
		SoundChance(ThreatenSound, 0.3);
		MoveToward(Enemy, MovementSpeed);
		if (bFromWall)
		{
			bFromWall = false;
			if (PickWallAdjust())
				StrafeFacing(Destination, Enemy);
			else
				GotoState('TacticalDecision');
		}
	}
	else
	{
NoReach:
		bCanSwing = false;
		bFromWall = false;
		if (!FindBestPathToward(Enemy))
		{	// unreachable and unpathable
			GotoState('Hunting');
		}
Moving:
		if (VSize(MoveTarget.Location - Location) < 2.5 * CollisionRadius)
		{
			bCanSwing = true;
			StrafeFacing(MoveTarget.Location, Enemy);
		}
		else
		{
			if ( !bCanStrafe || !LineOfSightTo(Enemy) ||
				(Skill - 2 * FRand() + (Normal(Enemy.Location - Location - vect(0,0,1) * (Enemy.Location.Z - Location.Z)) 
					Dot Normal(MoveTarget.Location - Location - vect(0,0,1) * (MoveTarget.Location.Z - Location.Z))) < 0) )
			{
				MoveToward(MoveTarget, MovementSpeed);
			}
			else
			{
				bCanSwing = true;
				StrafeFacing(MoveTarget.Location, Enemy);	
			}
			if ( !bFromWall )
				SoundChance(ThreatenSound, 0.8);
		}
	}

CheckDistance:
	if ( (bLungeAttack && !InLungeRange(Enemy)) || !InMeleeRange(Enemy))
	{	// Lunge Attack
		MoveTimer = 0.0;
		bFromWall = false;
		Goto('CloseIn');
	}
	Goto('GotThere');

ResumeFromFighting:
	if ( !ValidEnemy() )
		GotoState('GoingHome');
	if ( (bLungeAttack && !InLungeRange(Enemy)) || !InMeleeRange(Enemy))
	{
		MoveTimer = 0.0;
		Goto('TweenIn');
	}

GotThere:
	Target = Enemy;
	GotoState('Fighting');
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
		SetTimer(0.2, true);
	}

	function EndState()
	{
		bSwingingHigh = false;
		bSwingingLow  = false;
		if (Weapon!=None)
		{
			Weapon.FinishAttack();
			SwipeEffectEnd();
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

	function Timer()
	{
		if (Enemy != None && ShouldDefend())
		{
			GotoState('Fighting', 'Defend');
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

Begin:
	if(debugstates) SLog(name@"GoblinFighting");
	Acceleration = vect(0,0,0);
	GetEnemyProximity();

	// Turn to face enemy
	DesiredRotation.Yaw = rotator(Enemy.Location-Location).Yaw;

Fight:
	// Decide high or low
	if (FRand() < HighOrLow)
	{
		TweenToMeleeHigh(0.1);
		bSwingingHigh = true;
	}
	else
	{
		TweenToMeleeLow(0.1);
		bSwingingLow = true;
	}
	FinishAnim();

	if (bLungeAttack && !InMeleeRange(Enemy))
	{	// Lunge
		AddVelocity( CalcArcVelocity(8000, Location, Enemy.Location) );
	}

	if (bSwingingHigh)
		PlayMeleeHigh(0.1);
	else
		PlayMeleeLow(0.1);
	FinishAnim();
	bSwingingHigh = false;
	bSwingingLow  = false;

	Sleep(TimeBetweenAttacks);
	
	// Good chance of dodge back here (after attacking)
	if (bDodgeAfterAttack)
	{
		if (FRand() < 0.5)
			GotoState('DodgeBack');
		else if (FRand() < 0.5)
			GotoState('DodgeLeft');
		else
			GotoState('DodgeRight');
	}

	GotoState('Charging', 'ResumeFromFighting');

CheckDefend:
	Timer();
	GotoState('Charging', 'ResumeFromFighting');

Defend:
	if (BlockRatherThanDodge())
	{	// Try Block
		Disable('Timer');
		if (FRand() < HighOrLowBlock)
		{	// Block High
			ActivateShield(true);
			PlayBlockHigh(0.1);
			Sleep(RandRange(1, 2));
			FinishAnim();
			ActivateShield(false);
		}
		else
		{	// Block Low
			ActivateShield(true);
			PlayBlockLow(0.1);
			Sleep(RandRange(1, 2));
			FinishAnim();
			ActivateShield(false);
		}
		Enable('Timer');
	}
	else
	{	// Try Dodge
	
		//TODO: handle above/below/level - high/low/vertical
		
		switch(EnemyIncidence)
		{
		case INC_RIGHT:
			GotoState('DodgeLeft');
			break;
		case INC_LEFT:
			if (FRand() < 0.5)
				GotoState('DodgeRight');
			else
				GotoState('DodgeBack');
			break;
		case INC_FRONT:
			if (FRand() < 0.5)
				GotoState('DodgeBackFlip');
			else
				GotoState('DodgeBack');
			break;
		case INC_BACK:
			if (FRand() < 0.5)
				GotoState('DodgeForward');
			else if (FRand() < 0.5)
				GotoState('DodgeLeft');
			else
				GotoState('DodgeRight');
			break;
		}
	}

BackFromSubState:
	GotoState('Charging', 'ResumeFromFighting');
}


//================================================
//
// Fighting Sub-States
//
// Impliment in sub-classes
//
//================================================
State DodgeForward
{
	ignores SeePlayer, HearNoise, EnemyAcquired;

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

Begin:
	if(debugstates) SLog(name@"DodgeForward");
	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);
	PlayDodgeForward();
	AddLocalVelocity(300, 0, 50);
	FinishAnim();
	WaitForLanding();
	PlayLanded(Velocity.Z);

	GotoState('Fighting', 'BackFromSubstate');
}
State DodgeBack
{
	ignores SeePlayer, HearNoise, EnemyAcquired;

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

Begin:
	if(debugstates) SLog(name@"DodgeBack");
	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);
	PlayDodgeBack();
	AddLocalVelocity(-200, 0, 50);
	FinishAnim();
	WaitForLanding();
	PlayLanded(Velocity.Z);

	GotoState('Fighting', 'BackFromSubstate');
}
State DodgeRight
{
	ignores SeePlayer, HearNoise, EnemyAcquired;
	
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

Begin:
	if(debugstates) SLog(name@"DodgeRight");
	Acceleration = vect(0,0,0);
	PlayDodgeRight();
	AddLocalVelocity(0, 300, 100);
	SoundChance(RollSound, 1.0);
	FinishAnim();
	WaitForLanding();
	GotoState('Fighting', 'BackFromSubstate');
}
State DodgeLeft
{
	ignores SeePlayer, HearNoise, EnemyAcquired;
	
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

Begin:
	if(debugstates) SLog(name@"DodgeLeft");
	Acceleration = vect(0,0,0);
	PlayDodgeLeft();
	AddLocalVelocity(0, -300, 100);
	SoundChance(RollSound, 1.0);
	FinishAnim();
	WaitForLanding();
	GotoState('Fighting', 'BackFromSubstate');
}
State DodgeBackflip
{
	ignores SeePlayer, HearNoise, EnemyAcquired;
	
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

Begin:
	if(debugstates) SLog(name@"DodgeBackflip");
	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);
	PlayDodgeBackFlip();
	AddLocalVelocity(-200, 0, 400);
	FinishAnim();
	WaitForLanding();
	PlayLanded(Velocity.Z);
	
	GotoState('Fighting', 'BackFromSubstate');
}


//===================================================================
//					Debug (temp)
//===================================================================

simulated function Debug(canvas Canvas, int mode)
{
	Super.Debug(Canvas, mode);

	Canvas.DrawText("Goblin:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" MoveTimer:"@MoveTimer);
	Canvas.CurY -= 8;
}

defaultproperties
{
     bLungeAttack=True
     FightOrFlight=0.990000
     FightOrDefend=0.500000
     HighOrLow=1.000000
     LatOrVertDodge=0.800000
     HighOrLowBlock=0.500000
     BlockChance=0.500000
     LungeRange=200.000000
     PaceRange=200.000000
     HuntTime=60.000000
     BreathSound=Sound'CreaturesSnd.Goblin.goblinbreath03'
     AcquireSound=Sound'CreaturesSnd.Goblin.goblinamb04'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Goblin.goblinbreath02'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Goblin.goblinamb02'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Goblin.goblinamb01'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Goblin.goblinattack17'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Goblin.goblinattack01'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Goblin.goblinattack18'
     AmbientWaitSoundDelay=7.500000
     AmbientFightSoundDelay=5.000000
     StartWeapon=Class'RuneI.boneclub'
     StartShield=Class'RuneI.GoblinShield'
     ShadowScale=1.000000
     A_PullUp=ClimbB
     A_StepUp=ClimbC
     bCanStrafe=True
     bCanGrabEdges=True
     MeleeRange=30.000000
     GroundSpeed=260.000000
     WaterSpeed=100.000000
     JumpZ=500.000000
     MaxStepHeight=50.000000
     WalkingSpeed=54.000000
     ClassID=5
     Visibility=150
     SightRadius=1500.000000
     PeripheralVision=-0.500000
     Health=50
     BodyPartHealth(1)=35
     BodyPartHealth(3)=35
     BodyPartHealth(5)=40
     UnderWaterTime=2.000000
     Intelligence=BRAINS_HUMAN
     HitSound1=Sound'CreaturesSnd.Goblin.goblinhit08'
     HitSound2=Sound'CreaturesSnd.Goblin.goblinhit16'
     HitSound3=Sound'CreaturesSnd.Goblin.goblinhit28'
     Die=Sound'CreaturesSnd.Goblin.goblindeath06'
     Die2=Sound'CreaturesSnd.Goblin.goblindeath13'
     Die3=Sound'CreaturesSnd.Goblin.goblindeath16'
     LandGrunt=Sound'CreaturesSnd.Goblin.goblinhit32'
     FootStepWood(0)=Sound'FootstepsSnd.Earth.footlandearth08'
     FootStepWood(1)=Sound'FootstepsSnd.Earth.footlandearth08'
     FootStepWood(2)=Sound'FootstepsSnd.Earth.footlandearth08'
     FootStepMetal(0)=Sound'FootstepsSnd.Metal.footmetal07'
     FootStepMetal(1)=Sound'FootstepsSnd.Metal.footmetal07'
     FootStepMetal(2)=Sound'FootstepsSnd.Metal.footmetal07'
     FootStepStone(0)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepStone(1)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepStone(2)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepFlesh(0)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepFlesh(1)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepFlesh(2)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepIce(0)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepIce(1)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepIce(2)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepEarth(0)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepEarth(1)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepEarth(2)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepSnow(0)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepSnow(1)=Sound'FootstepsSnd.Earth.footlandearth09'
     FootStepSnow(2)=Sound'FootstepsSnd.Earth.footlandearth09'
     bCanLook=True
     LookDegPerSec=720.000000
     MaxMouthRot=8192
     MaxMouthRotRate=65535
     DeathRadius=32.000000
     DeathHeight=6.000000
     bLeadEnemy=True
     AnimSequence=idleA
     TransientSoundRadius=1000.000000
     CollisionRadius=16.000000
     CollisionHeight=32.000000
     Mass=50.000000
     Buoyancy=35.000000
     RotationRate=(Pitch=0,Yaw=45000,Roll=0)
     Skeletal=SkelModel'creatures.Goblin'
}
