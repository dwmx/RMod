//=============================================================================
// SnowBeast.
//=============================================================================
class SnowBeast expands ScriptPawn;


/*	DESCRIPTION:
	
		Types:
			Normal
			Chained
			TrialPit

	NEEDED:
		Base animations: Land, Falling,
		Pickup/Bearhug
		Sounds:
			Shorter Breathing sound
			Louder Howling sound
			Bite Sound

*/


var(Sounds) sound	HowlingSound;
var bool bBiting;
var SnowbeastJaws Jaws;
var bool bAngry;
var bool bLunging;
var() float	MaxBashThrust;

//===================================================================
//					Functions
//===================================================================

//------------------------------------------------
//
// AttitudeToCreature
//
//------------------------------------------------
function eAttitude AttitudeToCreature(Pawn Other)
{
	if (Other.IsA('Viking') || Other.IsA('Goblin'))
		return ATTITUDE_Hate;
	else
		return Super.AttitudeToCreature(Other);
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
	W = Spawn(class'snowbeastpaw');
	W.SetOwner(self);
	AttachActorToJoint(W, 21);	// Attach to left wrist
	InvisibleWeapon(Weapon).ChainOnWeapon(W);
	W.GotoState('Active');

	// Spawn Jaws
	Jaws = Spawn(class'snowbeastjaws');
	Jaws.SetOwner(self);
	AttachActorToJoint(Jaws, 9);
	Jaws.GotoState('Active');
}

function Destroyed()
{
	if (Jaws != None)
		Jaws.Destroy();
	Super.Destroyed();
}

//================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//================================================
function bool CanPickup(Inventory item)
{
	return item.IsA('SnowbeastPaw') || item.IsA('SnowbeastJaws');
}

//============================================================
//
// Breath
//
//============================================================
function Breath()
{
	local int joint;
	local vector l;
	local Breath B;

	if (HeadRegion.Zone.bWaterZone)
	{
		// Spawn Bubbles
		joint = JointNamed('llip');
		l = GetJointPos(joint);
		if(FRand() < 0.3)
		{
			Spawn(class'BubbleSystemOneShot',,, l,);
		}
	}
	else// if (Region.Zone.bCold)
	{	// Spawn steam breath
		SoundChance(BreathSound, 1.0, SLOT_Talk);
		joint = JointNamed('llip');
		l = GetJointPos(joint);

		B = Spawn(class'Breath',,, l,);
		B.ScaleMin=0.2;
		B.ScaleMax=1.200000;
	}
}


//============================================================
//
// InAttackRange
//
// When within attack range, state changes from
// charging to fighting
//============================================================
function bool InAttackRange(Actor Other)
{
	local float range;
	range = VSize(Location-Other.Location);
	if (range<CollisionRadius + Other.CollisionRadius + Max(CombatRange, MeleeRange))
		return true;
	if (bLungeAttack && FRand()<0.1 && range < LungeRange)
		return true;
	return false;
}


//===================================================================
//					Localized Damage Functions
//===================================================================

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
// PainSkin
//
// returns the pain skin for a given polygroup
//============================================================
function Texture PainSkin(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_HEAD:
			SkelGroupSkins[2] = Texture'creatures.snowbeastsb_bodypain';
			SkelGroupSkins[9] = Texture'creatures.snowbeastsb_bodypain';
			SkelGroupSkins[5] = Texture'creatures.snowbeastsb_bodypain';//teeth
			SkelGroupSkins[6] = Texture'creatures.snowbeastsb_bodypain';
			break;
		case BODYPART_TORSO:
			SkelGroupSkins[4] = Texture'creatures.snowbeastsb_bodypain';
			SkelGroupSkins[7] = Texture'creatures.snowbeastsb_bodypain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'creatures.snowbeastsb_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[1] = Texture'creatures.snowbeastsb_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[8] = Texture'creatures.snowbeastsb_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[3] = Texture'creatures.snowbeastsb_armlegpain';
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
		case 3: case 5:					return BODYPART_TORSO;
		case 8:							return BODYPART_HEAD;
		case 14:						return BODYPART_RARM1;
		case 15:						return BODYPART_RARM2;
		case 19:						return BODYPART_LARM1;
		case 20:						return BODYPART_LARM2;
		case 27: case 29:				return BODYPART_RLEG1;
		case 31: case 33:				return BODYPART_LLEG1;
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
		case 1: case 4: case 5:
		case 8:						return BODYPART_HEAD;
		case 2:						return BODYPART_RLEG1;
		case 7:						return BODYPART_LLEG1;
		case 9:						return BODYPART_RARM1;
		case 10:					return BODYPART_LARM1;
	}
	return BODYPART_BODY;
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
			case 3: case 5:
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

//------------------------------------------------
//
// JointDamaged
//
//------------------------------------------------
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	bAngry=true;
	return Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
}

//------------------------------------------------
//
// CanGotoPainState
//
// Special functionality added to keep the beast from going into pain while threatening
//------------------------------------------------

function bool CanGotoPainState()
{
	if(AnimSequence == 'howl')
		return(false); // Don't enter pain state, if rearing up and howling
	else
		return(false);
//		return(true);
}


//============================================================
// Animation functions
//============================================================
function PlayWaiting(optional float tween)		{ LoopAnim  ('idl_sbeast_breathe1_an0n',1.0, tween);}
function PlayMoving(optional float tween)
{
	if (bHurrying)
		LoopAnim  ('run',    1.0, tween);
	else
		LoopAnim  ('walk',    1.0, tween);
}
function PlayJumping(optional float tween)		{ PlayAnim  ('jump',			1.0, tween);	}
function PlayTurning(optional float tween)		{ PlayAnim  ('walk',			1.0, tween);	}
function PlayCower(optional float tween)		{ LoopAnim  ('cower',			1.0, tween);	}
function PlayHuntStop(optional float tween)		{ PlayWaiting(tween);							}
function PlayThreatening(optional float tween)	{ PlayAnim  ('howl',			1.0, tween);	}

function PlayFrontHit(float tween)				{ PlayAnim  ('cower',			1.0, tween);	}
function PlayDrowning(optional float tween)		{ LoopAnim  ('drown',			1.0, tween);	}

function PlayDeath(name DamageType)				{ PlayAnim('deathf',			1.0, 0.1);	}
function PlayBackDeath(name DamageType)			{ PlayAnim('deathf',			1.0, 0.1);	}
function PlayLeftDeath(name DamageType)			{ PlayAnim('death',				1.0, 0.1);	}
function PlayRightDeath(name DamageType)		{ PlayAnim('deathl',			1.0, 0.1);	}
function PlayHeadDeath(name DamageType)			{ PlayAnim('deathf',			1.0, 0.1);	}
function PlayDrownDeath(name DamageType)		{ PlayAnim('drown_death',		1.0, 0.1);	}

function TweenToWaiting(float time)				{ TweenAnim ('idl_sbeast_breathe1_an0n',    time);	}
function TweenToMoving(float time)
{
	if (bHurrying)
		TweenAnim ('run',    time);
	else
		TweenAnim ('walk',    time);
}
function TweenToHuntStop(float time)			{ TweenToWaiting(time); }

function PlaySwingLeft()						{ PlayAnim('swipeL',	1.0, 0.1);	}
function PlaySwingRight()						{ PlayAnim('swipeR',	1.0, 0.1);	}
function PlayBite()								{ PlayAnim('bite',		1.0, 0.1);	}
function PlayLunge()							{ PlayAnim('leepR',		1.0, 0.1);	}


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
		bBiting=false;
		if(Jaws != None)
			Jaws.FinishAttack();
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

	function WeaponActivate()
	{
		if (bBiting && Jaws != None)
			Jaws.StartAttack();
		else
			Super.WeaponActivate();
	}

	function WeaponDeactivate()
	{
		if (bBiting && Jaws != None)
			Jaws.FinishAttack();
		else
			Super.WeaponDeactivate();
	}

	function HowlSound()
	{
		PlaySound(HowlingSound, SLOT_None,,,, 1.0 + FRand()*0.2-0.1);
	}

	function Bump(actor Other)
	{
		local vector thrust;

		if (bLunging)
		{
			if (Pawn(Other)!=None)
			{
				Velocity.Z = 5;
				thrust = (Velocity*2*Mass + Other.Velocity*Other.Mass)/(Mass+Other.Mass);
				if (VSize(thrust) > MaxBashThrust)
					thrust = Normal(thrust)*MaxBashThrust;
				Pawn(Other).AddVelocity(thrust);

				// Do bash damage if velocity > some amount
				Other.JointDamaged(20, self, Other.Location, thrust, 'blunt', 0);

				//TODO: If velocity > some amount, knock enemy down
			}

			bLunging = false;	// Don't bash again
		}
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		MoveTimer = -1;
		AttackAction = AA_WAIT;
		Super.HitWall(HitNormal, Wall);
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

	function ComputeLunge()
	{
		local vector dest;
		local vector adjust;

		if (Enemy != None)
		{
			dest = Enemy.Location;
			dest.Z = Location.Z;

			adjust = Enemy.Velocity * 0.15;
			adjust.Z = 0;
					
			AddVelocity(CalcArcVelocity(4000, Location, dest + adjust));
		}
	}

	// Determine AttackAction based upon enemy movement and position
	function Timer()
	{
		GetEnemyProximity();

		LastAction = AttackAction;

		if(Weapon != None && InMeleeRange(Enemy) || (EnemyMovement == MOVE_CLOSER && EnemyDist < MeleeRange * 2.5))
		{
			if (EnemyIncidence == INC_LEFT)
			{	// Swing left
				AttackAction = AA_ATTACKMELEE2;
			}
			else if (EnemyIncidence == INC_RIGHT)
			{	// Swing right
				AttackAction = AA_ATTACKMELEE3;
			}
			else if (FRand() < 0.2)
			{	// Bite
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
		else if(EnemyMovement == MOVE_STANDING && FRand() < 0.9)
		{
/*			if (FRand() < 0.9)
			{	// Pace back and forth
				if (FRand() < 0.1)
				{	// Reverse direction
					bStrafeRight = !bStrafeRight;
				}
				
				if (bStrafeRight)
					AttackAction = AA_STRAFE_RIGHT;
				else
					AttackAction = AA_STRAFE_LEFT;
			}
			else*/
			if (!InRange(Enemy, MeleeRange) && FRand() < 0.8 && EnemyVertical == VERT_LEVEL)
				AttackAction = AA_LUNGE;
			else
				AttackAction = AA_WAIT;
		}
		else
		{
			AttackAction = AA_WAIT;
		}
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
		TurnTo(Enemy.Location);
		bLunging = true;
		PlayLunge();
		Sleep(0.2); // Sleep for a moment before leaping
		TurnTo(Enemy.Location);
		//PlaySound(BashSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
		ComputeLunge();		
		FinishAnim();
		WaitForLanding();
		Sleep(TimeBetweenAttacks);
		bLunging = false;
		bStopMoveIfCombatRange = true;
		break;

	case AA_STRAFE_LEFT:
		bHurrying = false;
		UpdateMovementSpeed();
		PickStrafeDestination();
		//PlayStrafeLeft();
		PlayMoving(0.1);

		if (EnemyMovement==MOVE_CLOSER || InRange(Enemy, MeleeRange * 2))
			StrafeFacing(Destination, Enemy);
		else
			MoveTo(Destination, MovementSpeed);
		bHurrying = true;
		UpdateMovementSpeed();
		break;

	case AA_STRAFE_RIGHT:
		bHurrying = false;
		UpdateMovementSpeed();
		PickStrafeDestination();
		//PlayStrafeRight();
		PlayMoving(0.1);
		if (EnemyMovement==MOVE_CLOSER || InRange(Enemy, MeleeRange * 2))
			StrafeFacing(Destination, Enemy);
		else
			MoveTo(Destination, MovementSpeed);
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
		PlayMoving(0.1);
		PickDestinationBackup();
		StrafeFacing(Destination, Enemy);
		bHurrying = true;
		UpdateMovementSpeed();
		PlayWaiting();
		break;

	case AA_ATTACKMELEE1:
		bBiting=true;
		PlayBite();
		FinishAnim();
		bBiting=false;
		Sleep(TimeBetweenAttacks);
		break;

	case AA_ATTACKMELEE2:
		PlaySwingLeft();
		FinishAnim();
		Sleep(TimeBetweenAttacks);
		break;

	case AA_ATTACKMELEE3:
		PlaySwingRight();
		FinishAnim();
		Sleep(TimeBetweenAttacks);
		break;
	}

	if (InRange(Enemy, CombatRange))
	{
		Sleep(0.05);
		Goto('Begin');
	}

Finished:
	GotoState('Charging', 'ResumeFromFighting');

//	GotoState('ChewOnCorpse');
}


//================================================
//
// Statue
//
//================================================
State() Statue
{
ignores HearNoise, EnemyAcquired, Bump;

	function HowlSound()
	{
		PlaySound(HowlingSound, SLOT_None,,,, 1.0 + FRand()*0.2-0.1);
	}

	function CreatureStatue()
	{
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
	}

Wake:
	PlayThreatening(0.1);
	CreatureNormal();
	InventoryNormal();
	FinishAnim();

	OrderFinished();
	GotoState('Waiting');
}

defaultproperties
{
     HowlingSound=Sound'CreaturesSnd.SnowBeast.beastyell11'
     MaxBashThrust=500.000000
     bLungeAttack=True
     FightOrFlight=1.000000
     FightOrDefend=1.000000
     HighOrLow=1.000000
     LatOrVertDodge=0.500000
     HighOrLowBlock=1.000000
     LungeRange=250.000000
     BreathSound=Sound'CreaturesSnd.SnowBeast.beastbreath05'
     AcquireSound=Sound'CreaturesSnd.SnowBeast.beasthit12'
     AmbientFightSounds(0)=Sound'CreaturesSnd.SnowBeast.beastamb09'
     AmbientFightSounds(1)=Sound'CreaturesSnd.SnowBeast.beastdeath01'
     AmbientFightSounds(2)=Sound'CreaturesSnd.SnowBeast.beasthit08'
     AmbientWaitSoundDelay=10.000000
     AmbientFightSoundDelay=5.000000
     StartWeapon=Class'RuneI.SnowbeastPaw'
     MinStopWait=0.000000
     MaxStopWait=0.000000
     ShadowScale=4.000000
     bCanStrafe=True
     bAlignToFloor=True
     MeleeRange=45.000000
     CombatRange=300.000000
     GroundSpeed=274.000000
     WaterSpeed=100.000000
     AccelRate=400.000000
     MaxStepHeight=30.000000
     WalkingSpeed=107.000000
     ClassID=7
     PeripheralVision=-0.500000
     Health=300
     UnderWaterTime=2.000000
     HitSound1=Sound'CreaturesSnd.SnowBeast.beastbreath02'
     HitSound2=Sound'CreaturesSnd.SnowBeast.beasthit13'
     HitSound3=Sound'CreaturesSnd.SnowBeast.beasthit15'
     Die=Sound'CreaturesSnd.SnowBeast.beastdeath02'
     Die2=Sound'CreaturesSnd.SnowBeast.beastyell14'
     Die3=Sound'CreaturesSnd.SnowBeast.beastdeath03'
     FootStepWood(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepWood(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepWood(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepMetal(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepMetal(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepMetal(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepStone(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepStone(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepStone(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepFlesh(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepFlesh(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepFlesh(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepIce(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepIce(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepIce(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepEarth(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepEarth(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepEarth(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepSnow(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepSnow(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     FootStepSnow(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep07'
     LandSoundWood=Sound'CreaturesSnd.SnowBeast.beastfootstep01'
     LandSoundMetal=Sound'CreaturesSnd.SnowBeast.beastfootstep01'
     LandSoundStone=Sound'CreaturesSnd.SnowBeast.beastfootstep01'
     LandSoundFlesh=Sound'CreaturesSnd.SnowBeast.beastfootstep01'
     LandSoundIce=Sound'CreaturesSnd.SnowBeast.beastfootstep01'
     LandSoundSnow=Sound'CreaturesSnd.SnowBeast.beastfootstep01'
     LandSoundEarth=Sound'CreaturesSnd.SnowBeast.beastfootstep01'
     WeaponJoint=rwrist
     bCanLook=True
     MaxBodyAngle=(Yaw=12743)
     MaxHeadAngle=(Yaw=9102)
     LookDegPerSec=150.000000
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     DeathRadius=55.000000
     DeathHeight=15.000000
     bLeadEnemy=True
     bStasis=False
     AnimSequence=IDL_SBEAST_breathe1_AN0N
     CollisionRadius=40.000000
     CollisionHeight=47.000000
     Mass=400.000000
     Buoyancy=350.000000
     RotationRate=(Pitch=0,Roll=0)
     Skeletal=SkelModel'creatures.SnowBeast'
}
