//=============================================================================
// TubeStriker.
//=============================================================================
class TubeStriker expands ScriptPawn;

/* Description:
	No movement.  When idle, he dangles his tongue around for air/food.  When an
	enemy is detected, he alerts the others around him, and sucks in his tongue.
	When enemies are within his attack range, he brings his worm out and readys
	to attack.
	Has a chance of grabbing enemy and smashing him around on rocks.
	
*/

var bool bAlerted;			// Whether to accept/send alerts to others
var float SleepTime;		// Amount of time to sleep before becoming alert
var bool bThrowOK;
var() bool bCanGrab;		// Can grab enemies
var() float FlingVelocity;	// Magnitude of fling velocity
var(Sounds) Sound	FlailSound;


function Alert(actor threat, float delay)
{	// No effect
}

//================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//================================================
function bool CanPickup(Inventory item)
{
	return item.IsA('TubestrikerTongue');
}

function FlingItem()
{
	local actor A;
	local vector X,Y,Z;
	local rotator r;
	
	A = DetachActorFromJoint(JointNamed('TongueD'));
	if (A != None)
	{
		A.SetPhysics(PHYS_Falling);
		GetAxes(Rotation, X,Y,Z);
		A.Velocity = (X+vect(0,0,1))*FlingVelocity;
		A.DesiredRotation.Yaw = Rotation.Yaw;
		r = A.default.Rotation;
		r.Yaw = Rotation.Yaw;
		A.SetRotation(r);

		if (A.IsA('Weapon'))
		{
			A.SetOwner(self);
			A.GotoState('throw');
		}
	}
}

function CheckForEnemies()
{
}

//============================================================
//
// PainSkin
//
//============================================================
function Texture PainSkin(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_HEAD:
			if (SkelGroupSkins[2] == Texture'creatures.strikerstriker')
				SkelGroupSkins[2] = Texture'creatures.strikerstrikerpain';
			if (SkelGroupSkins[3] == Texture'creatures.strikerstriker')
				SkelGroupSkins[3] = Texture'creatures.strikerstrikerpain';
			break;
	}
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
		case 4: case 5: case 6:
		case 7: case 8: case 9:
		case 10:						return MATTER_FLESH;

		case 0: case 1: case 2: case 3:	return MATTER_EARTH;
		
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
		case 1:										return BODYPART_TORSO;	// Shell
		case 4: case 5: case 6:						return BODYPART_HEAD;	// Head
		case 7: case 8: case 9: case 10: case 11:	return BODYPART_RARM1;	// Tongue
	}
	return BODYPART_BODY;
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
		case 1:		return BODYPART_BODY;
		case 2:		return BODYPART_HEAD;
		case 3:		return BODYPART_RARM1;
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
	return ((BodyPart == BODYPART_HEAD) || (BodyPart == BODYPART_RARM1));
}


//============================================================
//
// BodyPartCritical
//
//============================================================
function bool BodyPartCritical(int BodyPart)
{
	return ((BodyPart == BODYPART_HEAD) || (BodyPart == BODYPART_RARM1));
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
		case BODYPART_HEAD:
		case BODYPART_RARM1:
			return class'TTongue';
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
	local class<actor> partclass;

	Super.LimbSevered(BodyPart, Momentum);
	partclass = SeveredLimbClass(BodyPart);
	
	switch(BodyPart)
	{
		case BODYPART_HEAD:
		case BODYPART_RARM1:
			joint = JointNamed('tonguea');
			pos = GetJointPos(joint);
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.Velocity = -Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			break;
	}
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

	if (BodyPart == BODYPART_TORSO)	// Shell doesn't accept damage
		return 0;

	return Blunt+Sever;
}


//============================================================
//
// DamageBodyPart
//
//============================================================
function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int bodypart)
{
	local bool bContinueSwipe;

	bContinueSwipe = true;
	if ((BodyPart == BODYPART_HEAD) || (BodyPart == BODYPART_RARM1))
	{
		Spawn(class'GreenBloodSpray',,, HitLocation, Rotation);
		GotoState('Pain');
	}
	else if (BodyPart == BODYPART_TORSO)
	{	// Stop the swipe
		bContinueSwipe = false;
	}

	Super.DamageBodyPart(Damage, EventInstigator, HitLocation, Momentum, DamageType, BodyPart);
	return bContinueSwipe;
}


//============================================================
// Animation functions
//============================================================
function PlayWaiting(optional float tween)
{
	LoopAnim('IdleA', RandRange(0.8, 1.2), 0.1);
}

function PlayAttacking()
{
	PlayAnim('Attack', 1.0, 0.1);
}

function PlayDeath(name DamageType)
{
	LoopAnim('Reeling', 1.0, 0.1);
}





//============================================================
// States
//============================================================

//============================================================
//
// Waiting
//
// Hang out and wait for some stimuli
//============================================================
State Waiting
{
	function BeginState()
	{
		BodyPartCollision(BODYPART_HEAD, false);
		BodyPartCollision(BODYPART_RARM1, false);
		bAlerted = false;
	}

	function Bump(actor Other)
	{
		Alert(Other, 0);
	}
	
	function HearNoise(float Loudness, actor NoiseMaker)
	{
		Alert(NoiseMaker, 0.5);
	}
	
	function SeePlayer(actor seen)
	{
		if (VSize(seen.Location - Location) < SightRadius)
		{
			Alert(seen, RandRange(0.1, 0.5));
		}
	}

	function Alert(actor threat, float delay)
	{
		local TubeStriker A;

		if (!bAlerted)
		{
			bAlerted = true;

			// Alert friends
			foreach VisibleActors(class'TubeStriker', A)
			{
				if (!A.bAlerted)
					A.Alert(threat, RandRange(0.5, 2.2));
			}

			LookTarget = threat;
			SleepTime = delay;
			GotoState('Alerted');
		}
	}
	
Begin:
	if(debugstates) slog(name@"Waiting");
//	SetPhysics(PHYS_Falling);
//	WaitForLanding();
//	SetPhysics(PHYS_None);
	PlayWaiting(0.1);
}


//============================================================
//
// Alerted
//
// Poised to strike
//============================================================
State Alerted
{
	ignores Bump, SeePlayer, HearNoise, EnemyAcquired;

	function EnemyNotVisible()
	{
		GotoState('Waiting');
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function Timer()
	{
		local actor A;
		
		foreach RadiusActors(class'actor', A, MeleeRange)
		{
			if ((Pawn(A)!=None && TubeStriker(A)==None && A!=self && Pawn(A).Health>0) ||
				(Inventory(A)!=None && InvisibleWeapon(A)==None && A.Owner!=None))
			{
				if (ActorInSector(A, MaxHeadAngle.Yaw) &&
					Abs(A.Location.Z-Location.Z)<100)
				{	// Attack
					Enemy = Pawn(A);
					LookTarget = A;
					GotoState('Striking');
					break;
				}
			}
		}
	}

Begin:
	if(debugstates) slog(name@"Alerted");
	Sleep(SleepTime);
	PlaySound(AcquireSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
	PlayAnim('Ready', 1.0, 0.1);
	FinishAnim();
Ready:
	LoopAnim('ReadyIdle', 1.0, 0.1);
	SetTimer(0.25 + FRand() * 0.1, true);
}


//============================================================
//
// Striking
//
//============================================================
State Striking
{
	ignores Bump, SeePlayer, HearNoise, EnemyAcquired;

	function BeginState()
	{	// Only collide during this state
	}

	function EndState()
	{
		WeaponDeactivate();
		BodyPartCollision(BODYPART_HEAD, false);
		BodyPartCollision(BODYPART_RARM1, false);
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function WeaponActivate()
	{	// Notification used in attack
		BodyPartCollision(BODYPART_HEAD, true);
		BodyPartCollision(BODYPART_RARM1, true);
		Super.WeaponActivate();
	}
	
	function WeaponDeactivate()
	{	// Notification used in attack
		Super.WeaponDeactivate();
		BodyPartCollision(BODYPART_HEAD, false);
		BodyPartCollision(BODYPART_RARM1, false);
	}

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		if (DamageType == 'thrownweaponblunt' || DamageType == 'thrownweaponsever' || DamageType == 'thrownweaponbluntsever')
		{	// Thrown weapon hit me, disallow damage so I can grab it
			return false;
		}

		return Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
	}

	function bool AllowWeaponToHitActor(Weapon W, Actor A)
	{
		local float chance;

		chance = FRand();

		if (A.IsA('Weapon') && A.AttachParent==None)
		{// Thrown weapon, grab it if has an owner below
			chance = 0;
		}
		if (A.IsA('GiantCrab') || A.IsA('BabyCrab'))
			return true;	// Disallow crabs, their big collision radius hangs up on tubestrikers

		if (bCanGrab && ActorAttachedTo(JointNamed('TongueD'))==None && chance < 0.3)
		{
			if (A.IsA('Weapon') && !A.IsA('GoblinAxePowerup'))
			{	// Grab Weapon
				if (A.Owner!=None && Pawn(A.Owner)!=None && 
					(A==Pawn(A.Owner).Weapon || A.AttachParent==None))
				{
					Pawn(A.Owner).DropWeapon();
					A.Velocity = vect(0,0,0);
					A.GotoState('Active'); // Put the weapon in a non-pickup state
					AttachActorToJoint(A, JointNamed('TongueD'));
					GotoState('Flinging');
				}
				return false;
			}
			else if (A.IsA('Shield'))
			{	// Grab Shield
				if (A.Owner!=None && Pawn(A.Owner)!=None)
				{
					Pawn(A.Owner).DropShield();
					A.Velocity = vect(0,0,0);
					A.GotoState('Idle'); // Put the shield in a non-pickup state
					AttachActorToJoint(A, JointNamed('TongueD'));
					GotoState('Flinging');
				}
				return false;
			}
			else if (Pawn(A)!=None && Tubestriker(A)==None && !A.bCarriedItem)
			{
				// Pickup non-tubestriker Pawns that aren't already attached to something
				A.Velocity = vect(0,0,0);
				AttachActorToJoint(A, JointNamed('TongueD'));
				GotoState('Flinging');
				return false;
			}
		}
		return true;
	}
	
	
Begin:
	if(debugstates) slog(name@"Striking");
	PlayAttacking();
	FinishAnim();
	GotoState('WaitForRefire');
}


//============================================================
//
// Flinging
//
//============================================================
State Flinging
{
	ignores Bump, SeePlayer, HearNoise, EnemyAcquired;
	
	function BeginState()
	{
		BodyPartCollision(BODYPART_HEAD, true);
		BodyPartCollision(BODYPART_RARM1, true);
	}
	
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function EndState()
	{
		BodyPartCollision(BODYPART_HEAD, false);
		BodyPartCollision(BODYPART_RARM1, false);
	}

	function SoundNotify1()
	{
		PlaySound(FlailSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
	}

	// Disallow any damage from flinging actor
	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		if (EventInstigator != None && EventInstigator == ActorAttachedTo(JointNamed('TongueD')))
			return false;

		if (DamageType == 'thrownweaponblunt' || DamageType == 'thrownweaponsever' || DamageType == 'thrownweaponbluntsever')
		{
			if (EventInstigator != None &&
				ActorAttachedTo(JointNamed('TongueD')) != None &&
				EventInstigator == ActorAttachedTo(JointNamed('TongueD')).Owner )
				return false;	// Thrown weapon
		}

		FlingItem();	// Let go if damaged

		// Disallow other tubestrikers damaging me
		if (EventInstigator != None && EventInstigator.IsA('TubeStriker'))
			return false;

		return Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
	}

	// Notify to fling item
	function DoThrow()
	{
		if (bThrowOK)
		{
			FlingItem();
			bThrowOK = false;
			GotoState('Flinging', 'Thrown');
		}
	}

Thrown:
	PlayAnim('Ready', 1.0, 0.2);
	FinishAnim();
	GotoState('WaitForRefire');

Begin:
	if(debugstates) slog(name@"Flinging");
	bThrowOK = false;
	Sleep(0.2);		// Let suck back in a bit
	
	LoopAnim('whip', 1.0, 0.1);
	Sleep(4);
	bThrowOK = true;
}


//============================================================
//
// WaitForRefire
//
//============================================================
State WaitForRefire
{
	ignores SeePlayer, Bump, HearNoise, EnemyAcquired;

Begin:
	if(debugstates) slog(name@"WaitForRefire");
	Sleep(TimeBetweenAttacks);
	GotoState('Alerted', 'Ready');
}


//============================================================
//
// Pain
//
//============================================================
State Pain
{
	ignores Bump, SeePlayer, HearNoise, EnemyAcquired;

	function BeginState()
	{
		BodyPartCollision(BODYPART_HEAD, true);
		BodyPartCollision(BODYPART_RARM1, true);
	}
	
	function EndState()
	{
		BodyPartCollision(BODYPART_HEAD, false);
		BodyPartCollision(BODYPART_RARM1, false);
	}

	function bool CanGotoPainState()
	{ // Do not allow the actor to enter the painstate when already in pain
		return(false);
	}
	
Begin:
	if(debugstates) slog(name@"Pain");
	PlayAnim('pain', 1.0, 0.1);
	FinishAnim();

	GotoState('WaitForRefire');
}


//============================================================
//
// Dying (overridden from pawn)
//
//============================================================
State Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, JointDamaged, Timer;

	function BeginState()
	{
		LookAt(None);
		StopLookingToward();
		BodyPartCollision(BODYPART_HEAD, false);
		BodyPartCollision(BODYPART_RARM1, false);
		BodyPartVisibility(BODYPART_RARM1, false);
	}

Begin:
	if(debugstates) slog(name@"Dying");
	FlingItem();

	PlayAnim('Death', 1.0, 0.3);
}



simulated function Debug(canvas Canvas, int mode)
{
	Super.Debug(Canvas, mode);
	Canvas.DrawText("Tube:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  LookAngle.Yaw: " @ LookAngle.Yaw);
	Canvas.CurY -= 8;
	Canvas.DrawText("  Cos(LookAngle):" @ cos(LookAngle.Yaw*2.0*Pi/65535.0));
	Canvas.CurY -= 8;
	Canvas.DrawText("  PeriphVision:  " @ PeripheralVision);
	Canvas.CurY -= 8;
}

defaultproperties
{
     FlingVelocity=300.000000
     FlailSound=Sound'CreaturesSnd.TubeStriker.tubeflail02'
     FightOrFlight=1.000000
     AcquireSound=Sound'CreaturesSnd.TubeStriker.tubebite05'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.TubeStriker.tubeamb01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.TubeStriker.tubeamb05'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.TubeStriker.tubeamb03'
     AmbientFightSounds(0)=Sound'CreaturesSnd.TubeStriker.tubeamb04'
     AmbientFightSounds(1)=Sound'CreaturesSnd.TubeStriker.tubeattack02'
     AmbientFightSounds(2)=Sound'CreaturesSnd.TubeStriker.tubeattack03'
     StartWeapon=Class'RuneI.TubeStrikerTongue'
     CarcassType=None
     bAlignToFloor=True
     MeleeRange=200.000000
     GroundSpeed=0.000000
     WaterSpeed=0.000000
     AccelRate=0.000000
     JumpZ=0.000000
     MaxStepHeight=0.000000
     AirControl=0.000000
     ClassID=9
     SightRadius=400.000000
     PeripheralVision=-1.000000
     Health=5
     BodyPartHealth(0)=5
     BodyPartHealth(3)=5
     BodyPartHealth(5)=5
     bGibbable=False
     HitSound1=Sound'CreaturesSnd.TubeStriker.tubebite06'
     HitSound2=Sound'CreaturesSnd.TubeStriker.tubebite06'
     HitSound3=Sound'CreaturesSnd.TubeStriker.tubebite06'
     Die=Sound'CreaturesSnd.TubeStriker.tubedeath01'
     Die2=Sound'CreaturesSnd.TubeStriker.tubedeath01'
     Die3=Sound'CreaturesSnd.TubeStriker.tubedeath01'
     WeaponJoint=tonguee
     bCanLook=True
     MaxBodyAngle=(Yaw=0)
     MaxHeadAngle=(Pitch=0,Yaw=32768)
     bRotateTorso=False
     bLookFocusCreature=True
     AnimSequence=idleA
     bMovable=False
     TransientSoundRadius=1200.000000
     CollisionRadius=23.000000
     CollisionHeight=47.000000
     bRotateToDesired=False
     RotationRate=(Pitch=0,Yaw=0,Roll=0)
     Skeletal=SkelModel'creatures.Striker'
}
