//=============================================================================
// ScriptPawn.
//=============================================================================
class ScriptPawn expands Pawn;


/* Description:
	Base class for intelligent creatures.  Contains functionality for their major systems.
	
	Goals:
		Supports common pathfinding behaviors between creatures
		Locomotion manerisms can be overridden (for crab, fish, etc.)

	Startup:
	Set initial parameters, and decide what to do based on orders
	EXIT STATES: Waiting, 
	
	Waiting:
	Doing ambient behavior.  Either timed or until some stimulus

	Roaming:
	Roaming around level using the patrol points.
	EXIT STATES: Wandering, 

	Wandering:
	Wandering around without the use of navigation points.

	Acquisition:
	Just acquired an enemy, notice it (look/turn to it)
	EXIT STATES: TacticalDecision
	
	TacticalDecision:
	Deciding an attack strategy, choosing a leader.
	EXIT STATES: Charging, Hunting, Fleeing,

	Charging:
	Trying to get near the enemy for an Attack.
	EXIT STATES: Tactical, Fighting
	
	Hunting:
	Lost sight of enemy, trying to find him again
	EXIT STATES: Charging, GoingHome

	Fleeing:
	Outmatched or panicing, trying to get away and survive.
	EXIT STATES: Waiting, Cower

	Cower:
	Cowering because can't get away when fleeing.
	EXIT STATES: None

	GoingHome:
	EXIT STATES: Startup, Acquisition

	Commonly overridden states
	Fighting:
	Doing attack behavior.
	EXIT STATES: Charging
	
	Falling:
	EXIT STATES: NextState
	
	Scripting:
	Scripted behavior defined by series of ScriptPoint

   Valid Orders:
   	Scripting, Roaming, None, Creature defined

   SOUND slot usage:
	SLOT_None				
	SLOT_Misc				Water Splashes, Acquire
	SLOT_Pain				Hit sounds
	SLOT_Interact			Footsteps, Land
	SLOT_Ambient			AmbientSound
	SLOT_Talk				LandGrunt, Death, AmbientWait, AmbientFight
	SLOT_Interface			Breath
	
 	
   TODO:
	Phase out meleeRange,lungeRange,paceRange for AttackRange()
	HitWall handling in all states
	   	add climbing ability (set phys_falling) in all hitwalls
		do a global hitwall() function that goes to current
		state with label of hitwall: and have a hitwall
		handler in each
	Handle jumping out of water in ZoneChange()
*/

enum Facing_e
{
	FACE_FRONT,
	FACE_BACK,
	FACE_SIDE
};

enum Incidence_e
{
	INC_FRONT,
	INC_BACK,
	INC_LEFT,
	INC_RIGHT
};

enum Vertical_e
{
	VERT_ABOVE,
	VERT_BELOW,
	VERT_LEVEL
};

enum Movement_e
{
	MOVE_STANDING,
	MOVE_CLOSER,
	MOVE_FARTHER,
	MOVE_STRAFE_LEFT,
	MOVE_STRAFE_RIGHT
};

enum AttackAction_e
{
	AA_WAIT,
	AA_LUNGE,
	AA_STRAFE_RIGHT,
	AA_STRAFE_LEFT,
	AA_JUMP,
	AA_CHARGE,
	AA_BACKUP,
	AA_ATTACKMELEE1,
	AA_ATTACKMELEE2,
	AA_ATTACKMELEE3,
	AA_ATTACKMISSILE1,
	AA_ATTACKMISSILE2,
	AA_THROW,
	AA_BLOCK,
	AA_RETRIEVE_WEAPON
};

// Enemy Proximity information
var float EnemyDist;
var vector VecToEnemy; // Normalized vector
var vector VecFromEnemy; // Normalized vector
var Facing_e EnemyFacing;
var Incidence_e EnemyIncidence;
var Vertical_e EnemyVertical;
var Movement_e EnemyMovement;
var AttackAction_e AttackAction;
var AttackAction_e LastAction;

// Orders related
var(Orders) name		Orders;				// Ambient Orders, will also try to return to this state
var(Orders) name		OrdersTag;			// Object of Ambient Orders
var(Orders) name 		AlertOrders;		// Orders upon alert
var(Orders) name 		AlertOrdersTag;		// Associated object
var(Orders) name		TriggerOrders;		// Orders upon trigger
var(Orders) name		TriggerOrdersTag;	// Associated object
var name				AttackOrders;		// Tactical orders for attack
var actor				OrderObject;		// Object referred to by orders (if applicable).
var bool				bTeamLeader;		// Whether I am the leader of a group
var(AI) name			TeamTag;			// Tag of team if I belong to one
var bool				bAlerted;			// Whether pawn has been alerted already
var bool				bTaskLocked;		// Don't apply stimulus while bTaskLocked

// Movement related
var NavigationPoint		LastNodeVisited;	// Last Nav point visited (to avoid looking back)
var vector				HomeBase;			// Startup location, returns to when GoingHome
var rotator				HomeRot;			// Startup rotation, returns to when GoingHome
var() bool				bFallAtStartup;		// Whether to fall to ground at startup (used on crusified guys)
var() bool				bMoveWhenUnreachable;	// For trialpit beast

// Attack related
var bool				bCanSwing;			// Can swing attack (has right arm)
var bool 				bCanDefend;			// Can defend (has left arm)
var(Combat) bool		bLungeAttack;		// Lunges at enemy during attack
var(Combat) bool		bPaceAttack;		// Paces during attack
var(Combat) float		FightOrFlight;		// Bravery Disposition for fleeing
var(Combat) float		FightOrDefend;		// Aggressiveness towards fighting
var(Combat) float		HighOrLow;			// Vertical Attack Disposition
var(Combat) float		LatOrVertDodge;		// Chances of dodge laterally or vertically
var(Combat) float		HighOrLowBlock;		// Vertical blocking disposition
var(Combat) float		BlockChance;		// Blocking chances (of success)
var(Combat) float		LungeRange;			// Distance fighting takes place within
var(Combat) float		PaceRange;			// Distance to stay from enemy while pacing
var(Combat) bool		bDodgeAfterAttack;	// Dodge back after attacking
var(Combat) float		TimeBetweenAttacks;	// Time to wait before attacking again
var(Combat) int			ThrowTrajectory;	// Trajectory creatures uses to throw

// Hunting related
var float				HuntStartTime;		// Amount of time spent hunting
var int					numHuntPaths;		// number of paths taken hunting
var bool				bFrustrated;		// Desperate to find player
var(AI) float			HuntTime;			// Time to hunt before becoming frustrated
var(AI) float			HuntDistance;		// Distance from home allowed when hunting
var float				LastPathTime;		// Timer to reduce path searching overhead

// Animation related
var name				NextAnim;			// Used for queueing anims along with NextState,NextLabel

// Statue related
var(Statue) name		StatueAnimSeq;		// Anim sequence used for statue
var(Statue) float		StatueAnimFrame;	// Anim frame used for statue
var(Statue) bool		bStatueCanWake;		// Can come out of statue mode
var(Statue) bool		bStatueDestructible;// Can't be smashed

// Scripting related
var actor				NextPoint;			// For queueing OrderObject (NextState, NextLabel)
var int					SpeechPos;			// Position within controls for speech
var int					DispatchAction;		// Index of current action of ScriptDispatcher

// Sound related
var bool				bQuiet;				// Don't play sounds (TODO: need to support this again)
var(Sounds) sound		BreathSound;
var(Sounds) sound		AcquireSound;
var(Sounds) sound		AmbientWaitSounds[3];
var(Sounds) sound		AmbientFightSounds[3];
var(Sounds) sound		HuntSound;

var(Sounds) float		AmbientWaitSoundDelay;	// [0..x] amount of time between ambient wait sounds
var(Sounds) float		AmbientFightSoundDelay;	// [0..x] amount of time between ambient fight sounds
var int					NumAmbientWaitSounds;
var int					NumAmbientFightSounds;

var(Sounds) sound		RoamSound;		//OBS (ambient replaces)
var(Sounds) sound		FearSound;		//OBS
var(Sounds) sound		ThreatenSound;	//OBS

// Personality
var(AI) bool			bIsBoss;			// Whether creature is boss
var(AI) class<Weapon>	StartWeapon;		// Startup weapon
var(AI) class<Shield>	StartShield;		// Startup shield
var(AI) bool			bWillJoin;			// Will join a team if asked
var(AI) bool			bRoamHome;			// Creature roams instead of goinghome
var(AI) float			MinStopWait;		// Minimum time to wait between roams
var(AI) float			MaxStopWait;		// Maximum time to wait between roams
var(AI) bool			bGlider;			// For fish/birds that always move forward
var(AI) bool			bWaitLook;			// Whether looks around while waiting

// Internal variables
var int					lookIndex;			// Index of reachspec looking down during movement
var float				testfloat;			// used for debugging
var string				teststring;
var string				teststring2;
var int					i;
var Pawn				Hated;				// This creature is hated
var Pawn				Ally;				// This creature is followed
var float				ProtectionTimer;	// Timer for optimizing protection
var(Advanced) bool		bBurnable;			// RUNE: Can be set on fire
var() float				ShadowScale;		// RUNE:  Scale of the blob shadow

// Powerup related
var float				AllyTime;			// Internal timer
var float				AllyMaxTime;		// Amount of time to stay allied

// Fleeing
var actor				LastPointVisited;	// Last navigation point visited
var actor				CurrentPoint;
var float				WanderDistance;		// Distance used to determine open space when wandering

// Charging
var actor				IgnoreEnemy;		// Actor to ignore from acquisition

// PullUp Anims
var name A_PullUp, A_StepUp;

var bool debugstates;
var bool bDisableCheckForEnemies;			// Speedup: don't check for enemies


//===================================================================
//					Stimulus Functions
//===================================================================
function AfterSpawningInventory()	{}		// Used to spawn additional chained weapons

//------------------------------------------------
//
// PreBeginPlay
//
//------------------------------------------------
function PreBeginPlay()
{
	Super.PreBeginPlay();
	if ( bDeleteMe )
		return;
	if (DrawScale != Default.DrawScale)
	{
		WalkingSpeed = WalkingSpeed * DrawScale/Default.DrawScale;
	}

	// Grab statue animation from animseq if it's been set
	if (StatueAnimSeq == '' && AnimSequence != Default.AnimSequence)
	{
		StatueAnimSeq = AnimSequence;
		StatueAnimFrame = AnimFrame;
	}

	// Randomize phase of protection timer
	ProtectionTimer = -2.5*FRand();

	NumAmbientWaitSounds = 0;
	NumAmbientFightSounds = 0;
	for(i = 0; i < 3; i++)
	{
		if(AmbientWaitSounds[i] != None)
			NumAmbientWaitSounds++;
		if(AmbientFightSounds[i] != None)
			NumAmbientFightSounds++;
	}

	// Adjust health based upon level difficulty
	switch(Level.Game.Difficulty)
	{
	case 0: // Easy
		Health = Default.Health * 0.75;
		break;
	case 2: // Hard
		Health = Default.Health * 1.25;
		break;
	}
}

// Pass frame notifies to weapon
simulated event FrameNotify(int framepassed)
{
	if (Weapon != None)
	{
		Weapon.FrameNotify(framepassed);
		if (InvisibleWeapon(Weapon)!=None && InvisibleWeapon(Weapon).ChainedWeapon!=None)
			InvisibleWeapon(Weapon).ChainedWeapon.FrameNotify(framepassed);
	}
}

//------------------------------------------------------------
//
// ShadowUpdate
//
// RUNE:  Updates the shadow on the Pawn
// Set ShadowScale to zero to not draw a shadow on this pawn
//------------------------------------------------------------

event ShadowUpdate(int ShadowType)
{
	if(ShadowType == 1 && ShadowScale > 0)
	{ // Blob
		if(shadow == None)
			shadow = Spawn(class'PlayerShadow', self,, Location, Rotation);

		shadow.DrawScale = ShadowScale * DrawScale;
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

//------------------------------------------------
//
// Trigger
//
//------------------------------------------------
function Trigger( Actor Other, Pawn EventInstigator )
{
	//slog("triggered - doing orders:"@TriggerOrders@TriggerOrdersTag);
	FollowOrders(TriggerOrders, TriggerOrdersTag);
}


//------------------------------------------------
//
// WantsToPickup
//
// Returns whether the item is desired
//------------------------------------------------
function bool WantsToPickUp(Inventory item)
{
	if (item.IsA('Weapon'))
		return (Weapon == None || Weapon(item).Rating > Weapon.Rating);
	else if (item.IsA('Shield'))
		return (Shield == None || Shield(item).Rating > Shield.Rating);
}


//------------------------------------------------
//
// EnemyAcquired
//
// Called when Enemy has been set
//------------------------------------------------
function EnemyAcquired()
{
	if ( !bAlerted )
	{
		bAlerted = true;
		if ( FollowOrders(AlertOrders, AlertOrdersTag) )
			return;
	}
	GotoState('Acquisition');
}

//------------------------------------------------
//
// SeePlayer
//
//------------------------------------------------
function SeePlayer(actor seen)
{
	if (SetEnemy(seen))
	{
	}
}


//------------------------------------------------
//
// HearNoise
//
//------------------------------------------------
function HearNoise(float Loudness, Actor NoiseMaker)
{
	if (Pawn(NoiseMaker)==None && NoiseMaker.Instigator!=None)
	{
		if (SetEnemy(NoiseMaker.Instigator))
		{
		}
	}
	else
	{
		if (SetEnemy(NoiseMaker))
		{
		}
	}
}


//------------------------------------------------
//
// HitWall
//
//------------------------------------------------
function HitWall(vector HitNormal, actor Wall)
{
//	slog("hit wall in"@GetStateName()@"phys="$Physics);
}


//------------------------------------------------
//
// WeaponActivate (notify)
//
//------------------------------------------------
function WeaponActivate()
{
	if (Weapon != None)
		Weapon.StartAttack();
}


//------------------------------------------------
//
// WeaponDeactivate (notify)
//
//------------------------------------------------
function WeaponDeactivate()
{
	if (Weapon != None)
		Weapon.FinishAttack();
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

	if(Enemy != None)
	{ // If this Pawn has an enemy, throw the weapon at it
		OrderObject = Enemy;
	}
	else
	{ // ...Otherwise, just toss the weapon
		ThrowWeapon();
		return;
	}
	
	throwloc = GetJointPos(JointNamed(WeaponJoint));
	throwitem = DetachActorFromJoint(JointNamed(WeaponJoint));
	if (throwitem != None && OrderObject != None)
	{
		//TODO: Calculate Trajectory
		traj = ThrowTrajectory;

		// Throw the item
		throwitem.SetPhysics(PHYS_Falling);
//			throwitem.SetLocation(throwloc);	// More accurate this way for some reason
		throwitem.Acceleration = vect(0,0,0);
		throwitem.Velocity = CalcArcVelocity(traj, throwloc, OrderObject.Location);
		throwitem.GotoState('Throw');

		if(throwItem.IsA('inventory'))
			DeleteInventory(Inventory(throwItem));

		if (Weapon==throwitem)
			Weapon=None;
	}
}


//------------------------------------------------
//
// Breath (notify)
//
// Notification called when pawn takes a breath
//------------------------------------------------
function Breath()
{
	if (!HeadRegion.Zone.bWaterZone)
	{
		PlaySound(BreathSound, SLOT_Interface,,,, 1.0 + FRand()*0.2-0.1);
	}
}


//------------------------------------------------
//
// ZoneChange
//
//------------------------------------------------
function ZoneChange(ZoneInfo newZone)
{
	local vector jumpDir;

	if ( newZone.bWaterZone )
	{
		if (!bCanSwim)
			MoveTimer = -1.0;
		else if (Physics != PHYS_Swimming)
			setPhysics(PHYS_Swimming);
	}
	else if (Physics == PHYS_Swimming)
	{
		if ( bCanFly )
			 SetPhysics(PHYS_Flying); 
		else
		{ 
			SetPhysics(PHYS_Falling);
			if ( bCanWalk && CheckWaterJump(jumpDir) )
			{
//				JumpOutOfWater(jumpDir);
			}
		}
	}
	UpdateMovementSpeed();
}


//------------------------------------------------------------
//
// HeadZoneChange
//
//------------------------------------------------------------
function HeadZoneChange(ZoneInfo newHeadZone)
{
	Super.HeadZoneChange(newHeadZone);
	if (newHeadZone.bWaterZone)
	{
		if (!bCanSwim)
			GotoState('Drowning');
	}
}


function PainTimer()
{
	Super.PainTimer();
	if ( HeadRegion.Zone.bWaterZone )
	{
		if (!bCanSwim)
			GotoState('Drowning');
	}
}

//------------------------------------------------
//
// FearThisSpot
//
//------------------------------------------------
function FearThisSpot(Actor aSpot)
{
	Acceleration = vect(0,0,0);
	MoveTimer=-1.0;
}

//------------------------------------------------
//
// JointDamaged
//
//------------------------------------------------
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	if (EventInstigator != None)
		DamageAttitudeTo(EventInstigator);
	return Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
}

//------------------------------------------------
//
// LimbSevered
//
//------------------------------------------------
function LimbSevered(int BodyPart, vector Momentum)
{
	Super.LimbSevered(BodyPart, Momentum);
	SoundChance(FearSound, 0.5);
	switch(BodyPart)
	{
		case BODYPART_RARM1:
		case BODYPART_RARM2:
			bCanSwing = false;
			DropWeapon();
			if (Health > 0)
				GotoState('Fleeing');
			break;
		case BODYPART_LARM1:
		case BODYPART_LARM2:
			bCanDefend = false;
			DropShield();
			break;
	}
}


//------------------------------------------------
// MayFall
//
// called by engine physics if walking and bCanJump, and
// is about to go off a ledge.  Pawn has opportunity
// to avoid fall (by setting bCanJump to false)
//------------------------------------------------
function MayFall()
{	// Only jump if reachable
	if (intelligence==BRAINS_None)
	{
		bCanJump = true;
	}
	else if (MoveTarget!=None)
	{
		bCanJump = actorReachable(MoveTarget);
	}
	else if (Enemy!=None)
	{
		bCanJump = actorReachable(Enemy);
	}
}


//------------------------------------------------
//
// GrabEdge
//
//------------------------------------------------
function bool GrabEdge(float grabDistance, vector grabNormal)
{
//	slog("!!grab edge event while in state:"@GetStateName());
	SetPhysics(PHYS_Walking);

	return(false);
}


//------------------------------------------------
//
// Falling
//
// Called by physics
//------------------------------------------------
singular function Falling()
{
 	if (health <= 0)
		return;

	Super.Falling();
	if (bCanFly)
	{
		SetPhysics(PHYS_Flying);
		return;
	}
	SetFall();
}


//------------------------------------------------
//
// Landed
//
//------------------------------------------------
function Landed(vector HitNormal, actor HitActor)
{
	Super.Landed(HitNormal, HitActor);
	Acceleration = vect(0,0,0);
}


//------------------------------------------------
//
// SetFall
//
// default SetFall handler
//------------------------------------------------
function SetFall()
{
	if (Enemy != None)
	{
		if (GetStateName() != 'FallingState')
		{
			NextState = GetStateName();
			NextLabel = 'Begin';
			GotoState('FallingState');
		}
	}
}

function SetOnFire(Pawn EventInstigator, int joint)
{
	local PawnFire F;

	if (bBurnable)
	{
		if (ActorAttachedTo(joint) == None)
		{
			F = Spawn(class'PawnFire',EventInstigator);
			AttachActorToJoint(F, joint);
		}
	}
}

//===================================================================
//					Powerup Support
//===================================================================
function PowerupFire(Pawn EventInstigator)
{
	local int i;

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

	// Set all collision joints on fire
	for (i=0; i<NumJoints(); i++)
	{
		if ((JointFlags[i] & JOINT_FLAG_COLLISION)!=0)
			SetOnFire(EventInstigator, i);
	}
}
function PowerupStone(Pawn EventInstigator)
{
	if (!bIsBoss)
	{
		FireEvent(Event);
		PlaySound(Sound'WeaponsSnd.Powerups.atfreezestone01', SLOT_Interface);
		GotoState('Statue');
	}
}
function PowerupIce(Pawn EventInstigator)
{
	if (!bIsBoss)
	{
		PlaySound(Sound'WeaponsSnd.Powerups.atfreezeice01', SLOT_Interface);
		GotoState('IceStatue');
		SetTimer(5, false);
	}
}
function PowerupFriend(Pawn EventInstigator)
{
	if (!bIsBoss)
	{
		PlaySound(Sound'WeaponsSnd.Powerups.aalli01', SLOT_Interface);
		AttitudeToPlayer = ATTITUDE_Follow;
		Ally = EventInstigator;
		AllyTime = 0;
		DesiredColorAdjust = vect(0,0,102);
		Enemy = None;
		FireEvent(Event);
		Event='';
	}
}
function UnPowerupFriend()
{
	AttitudeToPlayer = Default.AttitudeToPlayer;
	Ally = None;
	DesiredColorAdjust = vect(0,0,0);
	Enemy = None;
	GotoState('GoingHome');
}
function PowerupElectricity(Pawn EventInstigator)
{
}


//===================================================================
//					Internal Work Functions
//===================================================================


//------------------------------------------------
//
// FollowOrders
//
//------------------------------------------------
function bool FollowOrders(name order, name tag)
{
	if (Order != '' && Health > 0)
	{
		bTaskLocked = true;
		OrderObject = ActorTagged(Tag);
		GotoState(Order);
		return true;
	}
	
	return false;
}


//------------------------------------------------
//
// OrderFinished
//
//------------------------------------------------
function OrderFinished()
{
	bTaskLocked = false;
	MoveTimer = -1.0;	// Stop any latent movement
}


//------------------------------------------------
//
// SetMovementPhysics
//
// Decide what locomotion method to use based on
// the zone we are in
//------------------------------------------------
function SetMovementPhysics()
{
	if (Region.Zone.bWaterZone)
		SetPhysics(PHYS_Swimming);
	else if (bCanFly)
		SetPhysics(PHYS_Flying);
	else if (bCanWalk)
		SetPhysics(PHYS_Walking);
	UpdateMovementSpeed();
}


//------------------------------------------------
//
// SetEnemy
//
// Decide whether to set this pawn as new enemy
//------------------------------------------------
function bool SetEnemy( Actor NewEnemy )
{
	local EAttitude attitude;

	if (bTaskLocked)
		return false;
	if (NewEnemy == IgnoreEnemy)
		return false;
	if (Pawn(NewEnemy)!=None && Pawn(NewEnemy).Health<=0)
		return false;

	// Attitude logic for choosing enemy
	if (Pawn(NewEnemy) != None)
		attitude = AttitudeTo(Pawn(NewEnemy));
	else
		attitude = ATTITUDE_IGNORE;	// ATTITUDE_CURIOUS
	if (attitude >= ATTITUDE_IGNORE)
		return false;

	if (Enemy==None || attitude < AttitudeTo(Enemy))
	{
		Enemy = Pawn(NewEnemy);
		EnemyAcquired();
	}
	return true;
}

//------------------------------------------------
//
// AttitudeTo
//
//------------------------------------------------
function eAttitude AttitudeTo(Pawn Other)
{
	local EAttitude att;

	if (Other.bInvisible)
		att = ATTITUDE_Ignore;
	else if (Other.GetStateName()=='Statue' || Other.GetStateName()=='IceStatue' || Other.GetStateName()=='Crucified')
		att = ATTITUDE_Ignore;
	else if (Other.bIsPlayer)
		att = AttitudeToPlayer;
	else
		att = AttitudeToCreature(Other);

	return att;
}

//------------------------------------------------
//
// AttitudeToCreature
//
//------------------------------------------------
function eAttitude AttitudeToCreature(Pawn Other)
{
	if( Other != None && Other==Hated)
		return ATTITUDE_Hate;
	else if ( (TeamTag != '') && (ScriptPawn(Other) != None) && (TeamTag == ScriptPawn(Other).TeamTag) )
		return ATTITUDE_Friendly;
	else if( Other.Class == Class || Other.ClassID == ClassID)
		return ATTITUDE_Friendly;
	else
		return ATTITUDE_Ignore;
}


//------------------------------------------------
//
// DamageAttitudeTo
//
//------------------------------------------------
function DamageAttitudeTo(Pawn Other)
{
	if ( (Other == Self) || (Other == None) || (FlockPawn(Other) != None) )
		return;
	if (Other.bIsPlayer)
	{
		switch(AttitudeToPlayer)
		{
			case ATTITUDE_Fear:
			case ATTITUDE_Hate:
			case ATTITUDE_Frenzy:
			case ATTITUDE_Follow:
				break;
			case ATTITUDE_Threaten:
			case ATTITUDE_Ignore:
			case ATTITUDE_Friendly:
				AttitudeToPlayer = ATTITUDE_Hate;
				break;
		}
	}
	else
	{
		if (Other.ClassID != ClassID ||
			(ScriptPawn(Other)!=None && ScriptPawn(Other).Hated==self) ||
			(Other.Enemy==Ally)	)
		{
			Enemy = None;
			Hated = Other;
		}
	}
	SetEnemy(Other);
}


// CheckForEnemies
//
// Allows scriptpawns to target other scriptpawns, as well as
// Could be changed to a radius actors check
function CheckForEnemies()
{
	local Pawn P, ClosestEnemy;
	local eAttitude att;
	local float Dist,LeastDist;
	local float radius;

	ClosestEnemy=None;
	LeastDist=9999999.0;

	if (HuntDistance>0)
		radius = Min(HuntDistance, SightRadius);
	else
		radius = SightRadius;

	foreach RadiusActors(class'Pawn', P, radius)
	{
		if (P==self || P.Class == Class || P.ClassID == ClassID)
			continue;
		if (P.IsA('FlockPawn'))
			continue;

		att = AttitudeTo(P);
		if (att != ATTITUDE_Hate && att != ATTITUDE_Fear)
			continue;

		dist = VSize(P.Location-Location);

		if (HuntDistance>0 && (dist > 2*HuntDistance || VSize(HomeBase-P.Location)>2*HuntDistance))
			continue;

		if (P.bIsPlayer)
			dist *= 0.5;

		if (dist<LeastDist)
		{
			if (actorReachable(P) || FindBestPathToward(P))
			{
				LeastDist=Dist;
				ClosestEnemy=P;
			}
		}
	}

	if (ClosestEnemy != None)
	{
		SetEnemy(ClosestEnemy);
		att = AttitudeTo(ClosestEnemy);
		if (att == ATTITUDE_Fear)
			GotoState('Fleeing');
	}

/*
	foreach RadiusActors(class'Pawn', P, radius)
	{
		if (P==self)
			continue;
		if (P.IsA('FlockPawn'))
			continue;

		dist = VSize(P.Location-Location);

		if (HuntDistance>0 && (dist > 2*HuntDistance || VSize(HomeBase-P.Location)>2*HuntDistance))
			continue;

		if (dist.Z > 300)
			continue;

		// fixme: make sure pawn is reachable

		if (P.bIsPlayer)
			dist *= 0.5;

		if (dist<LeastDist)
		{
			LeastDist=Dist;
			ClosestEnemy=P;
		}
	}

	if (ClosestEnemy != None)
	{
		att = AttitudeTo(ClosestEnemy);
		if (att == ATTITUDE_Hate)
		{
			SetEnemy(ClosestEnemy);
		}
		else if (att == ATTITUDE_Fear)
		{
			SetEnemy(ClosestEnemy);
			GotoState('Fleeing');
		}
	}
*/
}


function Tick(float DeltaTime)
{
	ProtectionTimer += DeltaTime;
	if (ProtectionTimer > 2.5)
	{
		ProtectionTimer = 0;

		if (AttitudeToPlayer==ATTITUDE_Follow)
		{
			ProtectAlly();
		}
		else if (!ValidEnemy() && !bDisableCheckForEnemies)
		{	// otherwise, attack enemies
			CheckForEnemies();
		}
	}

	Super.Tick(DeltaTime);
}


function ProtectAlly()
{	// Follow and protect ally
	local Pawn P;

	AllyTime += 1;
	if (AllyTime > AllyMaxTime)
	{
		UnPowerupFriend();
		return;
	}

	if (AttitudeToPlayer!=ATTITUDE_Follow || Ally == None)
		return;

	if (Enemy != None)
	{	// Already has an enemy
		if (ScriptPawn(Enemy)!=None && ScriptPawn(Enemy).Ally==Ally)
		{
			Enemy = None;
		}
		else if (Enemy.Health > 0)	// living enemy, keep attacking
			return;
	}

	// otherwise, attack enemies
	foreach VisibleActors(class'Pawn', P)
	{
		if (P==Ally || P==self)
			continue;

		if (ScriptPawn(P)!=None && ScriptPawn(P).Ally==Ally)
			continue;

		// Look around for enemies of the player and make them my enemy
		if (P.Enemy == Ally)
		{
			DamageAttitudeTo(P);
			return;
		}
		else if (ScriptPawn(P.Enemy)!=None && ScriptPawn(P.Enemy).Ally == Ally)
		{
			DamageAttitudeTo(P);
			return;
		}
	}
}


// Used to stop attacking when conditions are met
function bool ValidEnemy()
{
	if (AttitudeToPlayer==ATTITUDE_Follow && ScriptPawn(Enemy)!=None && ScriptPawn(Enemy).Ally==Ally)
		return false;

	return (Enemy!=None && Enemy.Health>0 && !Enemy.bInvisible);
}

//------------------------------------------------
//
// AllowWeaponToHitActor
//
// Disallow hitting others of the same class
//------------------------------------------------
function bool AllowWeaponToHitActor(Weapon W, Actor A)
{
	if (A!=Enemy)
	{
		if (A.Class == Class)
			return false;

		if (A.Owner != None && A.Owner.Class == Class)
			return false;
	}

	return true;
}


//------------------------------------------------
//
// CanDirectlyThreaten
//
//------------------------------------------------
function bool CanDirectlyThreaten()
{
	if ( Enemy==None || (Enemy.Region.Zone.bWaterZone && !bCanSwim && !bCanFly))
		return false;
	if ( !Enemy.Region.Zone.bWaterZone && !bCanWalk && !bCanFly)
		return false;
	return ( ActorReachable(Enemy) );
}


//================================================
//
// InRange
//
//================================================
function bool InRange(actor Other, float range)
{
	if (Other == None)
		return false;
	return (VSize(Location-Other.Location) < CollisionRadius + Other.CollisionRadius + range);
}


//------------------------------------------------
//
// InMeleeRange
//
//------------------------------------------------
function bool InMeleeRange(Actor Other)
{
	if (Other == None)
		return false;
	return (VSize(Location - Other.Location) < CollisionRadius + Other.CollisionRadius + MeleeRange);
}

//------------------------------------------------
//
// InLungeRange
//
//------------------------------------------------
function bool InLungeRange(Actor Other)
{
	if (Other == None)
		return false;
	return (VSize(Location - Other.Location) < CollisionRadius + Other.CollisionRadius + LungeRange);
}

//------------------------------------------------
//
// InPaceRange
//
//------------------------------------------------
function bool InPaceRange(Actor Other)
{
	if (Other == None)
		return false;
	return (VSize(Location - Other.Location) < CollisionRadius + Other.CollisionRadius + PaceRange);
}


//------------------------------------------------
//
// InAttackRange
//
// When within attack range, state changes from
// charging to fighting
//------------------------------------------------
function bool InAttackRange(Actor Other)
{
	local float range;

	range = VSize(Location-Other.Location);

	// Handle Melee Range
	if(range <= CollisionRadius + Other.CollisionRadius + MeleeRange)
		return(true);

	// Handle Combat Range
	if(bStopMoveIfCombatRange && (range < CollisionRadius + Other.CollisionRadius + CombatRange))
		return(true);
	
	return(false);
}


//------------------------------------------------
//
// AddLocalVelocity
//
// Add local coordinate system velocities
//------------------------------------------------
function AddLocalVelocity(float vx, float vy, float vz)
{
	local vector X, Y, Z;
	GetAxes(Rotation, X, Y, Z);
	
	AddVelocity(X*vx + Y*vy + Z*vz);
}



//------------------------------------------------
//
// GetEnemyProximity
//
// Determine attack proximity information
//------------------------------------------------
function GetEnemyProximity()
{
	local vector X, Y, Z;
	local vector EX, EY, EZ;
	local float dp;

	if(Enemy == None)
		return;

	GetAxes(Rotation,  X, Y, Z);
	GetAxes(Enemy.Rotation,  EX, EY, EZ);
	
	VecToEnemy = Enemy.Location - Location;
	EnemyDist = VSize(VecToEnemy);

	VecToEnemy = Normal(VecToEnemy);
	VecFromEnemy = VecToEnemy * -1;
	
	// Calculate enemy facing
	dp = VecFromEnemy dot vector(Enemy.Rotation);
	if(dp >= 0.7)
	{
		EnemyFacing = FACE_FRONT;
	}
	else if(dp <= -0.7)
	{
		EnemyFacing = FACE_BACK;
	}
	else
	{
		EnemyFacing = FACE_SIDE;
	}
	
	// Calculate enemy incidence
	dp = VecToEnemy dot X;
	if(dp >= 0.8)
	{
		EnemyIncidence = INC_FRONT;
	}
	else if(dp <= -0.7)
	{
		EnemyIncidence = INC_BACK;
	}
	else
	{ // Compute left or right
		if(VecToEnemy dot Y >= 0)
		{
			EnemyIncidence = INC_RIGHT;
		}
		else
		{
			EnemyIncidence = INC_LEFT;
		}
	}

	// Calculate Enemy Verticality (above/below)
	if(Enemy.Location.Z > Location.Z + CollisionHeight * 0.75)
	{
		EnemyVertical = VERT_ABOVE;
	}
	else if(Enemy.Location.Z < Location.Z - CollisionHeight * 0.75)
	{
		EnemyVertical = VERT_BELOW;
	}
	else
	{
		EnemyVertical = VERT_LEVEL;
	}

	// Calculate Enemy Movement
	if(VSize(Enemy.Velocity) >= Enemy.GroundSpeed * 0.5)
	{
		dp = VecFromEnemy dot Normal(Enemy.Velocity);
		if(dp >= 0.7)
		{
			EnemyMovement = MOVE_CLOSER;
		}
		else if(dp <= -0.7)
		{
			EnemyMovement = MOVE_FARTHER;
		}
		else
		{ // Determine strafe left of right
			if(EY dot Normal(Enemy.Velocity) >= 0)
			{
				EnemyMovement = MOVE_STRAFE_RIGHT;
			}
			else
			{
				EnemyMovement = MOVE_STRAFE_LEFT;
			}				
		}
	}
	else
	{
		EnemyMovement = MOVE_STANDING;
	}
}




//------------------------------------------------
//
// Animation Functions
//
// Override in children
//------------------------------------------------

// Required
function PlayWaiting(optional float tween)			{}	// Played when not doing anything else
function PlayMoving(optional float tween)			{}	// Played during all locomotion (swim,walk,run,fly)
function PlayJumping(optional float tween)			{}	// Played while jumping
function PlayInAir(optional float tween)			{}	// Played while falling
function PlayStrafeLeft(optional float tween)		{ PlayMoving(tween); }
function PlayStrafeRight(optional float tween)		{ PlayMoving(tween); }
function PlayBackup(optional float tween)			{ PlayMoving(tween); }

// Optional
function PlayTurning(optional float tween)			{ PlayWaiting(tween);	}	// Played while turning
function PlayCower(optional float tween)			{ PlayWaiting(tween);	}	// Fleeing -> HitWall -> Cower
function PlayHuntStop(optional float tween)			{ PlayWaiting(tween);	}	// Played when choosing next Hunting dest
function PlayTaunting(optional float tween)			{ PlayWaiting(tween);	}	// 
function PlayThreatening(optional float tween)		{ PlayWaiting(tween);	}	// 
function LongFall()									{ PlayInAir(0.1);		}
function PlayPickupWeapon(optional float tween)		{}
function PlayDropWeapon(optional float tween)		{}
function PlayPickupShield(optional float tween)		{}
function PlayLanding(optional float tween)			{}

// PullUp
function PlayPullUp(optional float tween)			{ PlayAnim(A_PullUp, 1.0, tween); }
function PlayStepUp(optional float tween)			{ PlayAnim(A_StepUp, 1.0, tween); }

// Damage
function PlayFrontHit(optional float tween)			{}

// Deaths (from Pawn)
function PlayDeath(name DamageType)					{}

// Obsolete
function PlayMeleeLow(optional float tween)			{}	// These can go ?
function PlayMeleeHigh(optional float tween)		{}
function PlayMeleeVertical(optional float tween)	{}
function PlayBlockLow(optional float tween)			{}
function PlayBlockHigh(optional float tween)		{}
function PlayThrowing(optional float tween)			{}
function PlayMovingAttack(optional float tween)		{}

// Tweens
function TweenToWaiting(float time)					{}
function TweenToMoving(float time)					{}
function TweenToJumping(float time)					{}
function TweenToTurning(float time)					{}
function TweenToHuntStop(float time)				{}

function TweenToMeleeHigh(float time)				{}	// These can go
function TweenToMeleeLow(float time)				{}
function TweenToThrowing(float time)				{}



//------------------------------------------------
//
// Sound Functions
//
//------------------------------------------------
function bool SoundChance(sound Sound, float chance, optional ESoundSlot slot)
{
	if ((Sound != None) && (FRand() < chance) && !bQuiet)
	{
		PlaySound(Sound, slot,, true,, 1.0 + FRand()*0.2-0.1);
		return true;
	}
	return false;
}

function PlayAmbientWaitSound()
{
	if (!Region.Zone.bWaterZone)
	{
		i = Rand(NumAmbientWaitSounds);
		PlaySound(AmbientWaitSounds[i], SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
		AmbientSoundTime = (0.5 + FRand()*0.5) * AmbientWaitSoundDelay;
	}
}

function PlayAmbientFightSound()
{
	if (!Region.Zone.bWaterZone)
	{
		i = Rand(NumAmbientFightSounds);
		PlaySound(AmbientFightSounds[i], SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
		AmbientSoundTime = (0.5 + FRand()*0.5) * AmbientFightSoundDelay;
	}
}

function AmbientSoundTimer()
{
	PlayAmbientWaitSound();
}


//===================================================================
//					States
//===================================================================
			

//================================================
//
// Startup
//
//================================================
auto State Startup
{
ignores EnemyAcquired, SeePlayer, HearNoise;
	
	function BeginState()
	{
		Enemy = None;
		AmbientSoundTime=RandRange(2.0, 5.0);	// Start ambient sounds
	}
	
	function EndState()
	{
		SetMovementPhysics();
		bHurrying = false;
		UpdateMovementSpeed();
	}
	
	function SpawnStartInventory()
	{	// Spawn a start weapon if applicable
		local Weapon W;
		local Shield S;

		if (StartWeapon != None)
		{
			W = Spawn(StartWeapon);
			W.RespawnTime=0;
		}
		
		if (StartShield != None)
		{
			S = Spawn(StartShield);
			S.RespawnTime=0;
		}
	}

	function TouchSurroundingObjects()
	{	// Since things spawned touching don't get touch messages
		local Inventory Inv;
		foreach RadiusActors(class'Inventory', Inv, 10)
		{
			Inv.Touch(self);
		}
	}

	function Timer()
	{
		if (PlayerCanSeeMe())
		{
			SetTimer(0, false);
			GotoState('Startup', 'Wake');
		}
	}
	
	function SetHome()
	{
		local NavigationPoint aNode;

		aNode = Level.NavigationPointList;

		while ( aNode != None )
		{
			if ( aNode.IsA('HomeBase') && (aNode.tag == tag) )
			{
				HomeBase = aNode.Location;
				HomeRot = aNode.Rotation;
				return;
			}
			aNode = aNode.nextNavigationPoint;
		}

		// Didn't find a homebase, use spawnpoint
		HomeBase = Location;
		HomeRot = Rotation;
	}

Wake:
	FollowOrders(Orders, OrdersTag);
	GotoState('Waiting');
	
Begin:
	if(debugstates) slog(name@"Starting");
	if (!bCanFly && bFallAtStartup)
		SetPhysics(PHYS_Falling);
	SetHome();
	SpawnStartInventory();
	TouchSurroundingObjects();
	AfterSpawningInventory();

Restart:
	if (bMovable && bFallAtStartup && !Region.Zone.bWaterZone)
		WaitForLanding();
	SetPhysics(PHYS_None);
//	SetTimer(0.2, true);
	Goto('Wake');
}


//================================================
//
// Waiting
//
//================================================
State Waiting
{
	function BeginState()
	{
		Enemy = None;
		SetPhysics(PHYS_None);
	}
	
	function EndState()
	{
		// Make sure we start up physics before leaving this state
		SetMovementPhysics();
		SetTimer(0, false);
	}

	function SeePlayer(actor seen)
	{
		if (HuntDistance > 0)
		{
			// Disallow if seen is outside hunt radius
			if (VSize(HomeBase-seen.Location)>2*HuntDistance)
				return;

			// Disallow if path to seen is outside hunt radius
		}

		global.SeePlayer(seen);
	}

	function Bump(actor Other)
	{
		SetEnemy(Other);
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		SetPhysics(PHYS_None);
	}

	function Timer()
	{
		if (bCanLook && bWaitLook)
		{	// Change look spot
			LookToward(Location + VRand() * 100);
			SetTimer(RandRange(1.5, 3.5), false);
		}
	}

Begin:
	if(debugstates) slog(name@"Waiting");
Wait:
	PlayWaiting();
	SetTimer(1, false);
}


//================================================
//
// Roaming
//
// Following random paths
//================================================
State() Roaming
{
	function BeginState()
	{
		bTaskLocked = false;	// Never task locked when roaming so will fight
		Enemy = None;
		LookAt(None);
		bHurrying = false;
		UpdateMovementSpeed();
	}
	
	function HitWall(vector HitNormal, actor Wall)
	{
		global.HitWall(HitNormal, Wall);
		if (Physics == PHYS_Falling)
			return;
		Focus = Destination;
		if (PickWallAdjust())
			GotoState('Roaming', 'AdjustFromWall');
		else
			MoveTimer = -1.0;
	}

	function PickDestination()
	{
		OrderObject = FindRandomDest();
		if (OrderObject == None)
			GotoState('Wandering');
	}

	function PickWaypoint()
	{
		MoveTarget = FindPathToward(OrderObject);
		if (MoveTarget != None)
		{
			Destination = MoveTarget.Location;
			if (actorReachable(MoveTarget))
			{
				return;
			}
		}
		GotoState('Roaming', 'Roam');
	}

Begin:
	if(debugstates) slog(name@"Roaming");
Roam:
	PickDestination();

Path:
	PickWaypoint();
	
	LookToward(MoveTarget.Location);

	// Turn to Destination
	if (AngleTo(MoveTarget.Location) > ANGLE_45)
	{
		DesiredRotation.Yaw = Rotator(MoveTarget.Location - Location).Yaw;
		PlayTurning();
		FinishAnim();
	}
	
	TweenToMoving(0.15);
	WaitForLanding();
	FinishAnim();
	PlayMoving();
	StopLookingToward();
	
Moving:
	MoveToward(MoveTarget, MovementSpeed);

	// Look down some paths if not a straight shot
	if ((!bGlider) &&
		MaxStopWait > 0 &&
		NavigationPoint(MoveTarget) != None &&
		NavigationPoint(MoveTarget).NumPaths() > 2 &&
		NavigationPoint(MoveTarget) != LastNodeVisited)
	{
		Acceleration = vect(0,0,0);
		TweenToWaiting(0.3);
		FinishAnim();
	
		lookindex = 0;
		while (lookIndex < NavigationPoint(MoveTarget).NumPaths())
		{
			PlayWaiting();
			LookToward(NavigationPoint(MoveTarget).PathEndPoint(lookIndex).Location);
			lookIndex++;
			Sleep(RandRange(MinStopWait, MaxStopWait));
			FinishAnim();
		}
	}
	
	LastNodeVisited	= NavigationPoint(MoveTarget);
	
	if (MoveTarget != OrderObject)
		Goto('Path');
	else
	{
		SoundChance(RoamSound, 1.0);
		Goto('Roam');
	}

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('Moving');
}


//================================================
//
// Wandering
//
//================================================
State Wandering
{
	function BeginState()
	{
		Enemy = None;
		LookAt(None);
		bHurrying = false;
		UpdateMovementSpeed();
	}
	
	function SetFall()
	{
		NextState = 'Wandering'; 
		NextLabel = 'ContinueWander';
		NextAnim  = AnimSequence;
//		GotoState('FallingState'); 
	}
	
	function HitWall(vector HitNormal, actor Wall)
	{
		global.HitWall(HitNormal, Wall);
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Wandering', 'Pausing');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
			GotoState('Wandering', 'AdjustFromWall');
		else
			MoveTimer = -1.0;
	}

	function bool TestDirection(vector dir, out vector pick)
	{	
		local vector HitLocation, HitNormal, dist;
		local float minDist;
		local actor HitActor;

		minDist = FMin(150.0, 4*CollisionRadius);
		pick = dir * (minDist + (450 + WanderDistance * CollisionRadius) * FRand());

		HitActor = Trace(HitLocation, HitNormal, Location + pick + 1.5 * CollisionRadius * dir , Location, false);
		if (HitActor != None)
		{
			pick = HitLocation + (HitNormal - dir) * 2 * CollisionRadius;
			HitActor = Trace(HitLocation, HitNormal, pick , Location, false);
			if (HitActor != None)
				return false;
		}
		else
		{	// Trace hit nothing
			if (Physics == PHYS_Swimming)
			{
				if (!pointReachable(Location+pick))
				{
					return false;
				}
			}
			pick = Location + pick;
		}

 
		dist = pick - Location;
		if (Physics == PHYS_Walking)
			dist.Z = 0;
		
		return (VSize(dist) > minDist); 
	}
	
	function PickDestination()
	{
		local vector pick, pickdir;
		local bool success;
		local float XY;

		// Try to get back to Roaming
		OrderObject = FindRandomDest();
		if (OrderObject != None)
		{
			GotoState('Roaming');
			return;
		}
		
		//Favor XY alignment
		XY = FRand();
		if (XY < 0.3)
		{
			pickdir.X = 1;
			pickdir.Y = 0;
		}
		else if (XY < 0.6)
		{
			pickdir.X = 0;
			pickdir.Y = 1;
		}
		else
		{
			pickdir.X = 2 * FRand() - 1;
			pickdir.Y = 2 * FRand() - 1;
		}

		if (Physics == PHYS_Swimming)
		{
			pickdir.Z = 2 * FRand() - 1;
			pickdir = Normal(pickdir);
		}
		else if (Physics == PHYS_Flying)
		{
			pickdir.Z = 2 * FRand() - 1;
			pickdir = Normal(pickdir);
		}
		else
		{
			pickdir.Z = 0;
			if (XY >= 0.6)
				pickdir = Normal(pickdir);
		}	

		success = TestDirection(pickdir, pick);
		if (!success)
			success = TestDirection(-1 * pickdir, pick);

		if (success)
			Destination = pick;
		else
			GotoState('Wandering', 'Turn');
	}
	
Begin:
	if(debugstates) slog(name@"Wandering");
Wander: 
	TweenToMoving(0.15);
	WaitForLanding();
	PickDestination();
	FinishAnim();
	PlayMoving();

Moving:
	Enable('HitWall');
	MoveTo(Destination, MovementSpeed);

Pausing:
	SoundChance(RoamSound, 0.3);
	if ((!bGlider) &&
		MaxStopWait > 0)
	{
		Acceleration = vect(0,0,0);

		if ( NearWall(2 * CollisionRadius + 50) )
		{
			PlayTurning();
			TurnTo(Focus);
		}

		TweenToWaiting(0.2);
		FinishAnim();
		PlayWaiting();
		Sleep(RandRange(MinStopWait, MaxStopWait));
	}
	Goto('Wander');


ContinueWander:
	FinishAnim();
	PlayMoving();
	SoundChance(RoamSound, 0.3);
	if (FRand() < 0.2)
		Goto('Turn');
	Goto('Wander');

Turn:
	Acceleration = vect(0,0,0);
	PlayTurning();
	TurnTo(Location + 20 * VRand());
	Goto('Pausing');

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('Moving');
}


//================================================
//
// Scripting
//
// Requires a ScriptPoint OrderObject
//================================================
State() Scripting
{
ignores PowerupFire, PowerupBlaze, PowerupStone, PowerupIce, PowerupFriend, CheckForEnemies, ProtectAlly;//, SetOnFire;

	function Breath()	{}

	// Override some animations so these events don't takeover animations between scriptpoints
	function PlayLanding(optional float tween)		{	PlayMoving(tween);	}
	function PlayJumping(optional float tween)		{	PlayMoving(tween);	}
	function PlayInAir(optional float tween)		{	PlayMoving(tween);	}

	function BeginState()
	{
		Acceleration=vect(0,0,0);
	}

	function EndState()
	{
		bOverrideLookTarget=false;
	}

	function bool CanGotoPainState()
	{
		return(false);
	}

	function AmbientSoundTimer()
	{	// Don't play it, just reset timer for next one
		AmbientSoundTime = (0.5 + FRand()*0.5) * AmbientWaitSoundDelay;
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
			SoundChance(Dest.ArriveSound, 1.0);
			
			FireEvent(Dest.ArriveEvent);

			NextState = Dest.NextOrder;
			NextLabel = '';//Dest.NextOrderLabel;
			NextPoint = ActorTagged( Dest.NextOrderTag );
			
			bTaskLocked = !Dest.bReleaseUponArrival;

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
			else
			{	// Release to normal AI
				bTaskLocked = false;
				OrderObject = None;
				GotoState('Waiting');
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
			
			bTaskLocked = !Action.bReleaseUponCompletion;

			if (NextState != '')
			{
				OrderObject = NextPoint;
				GotoState(NextState, NextLabel);
			}
			else
			{	// Release to normal AI
				bTaskLocked = false;
				OrderObject = None;
				GotoState('Waiting');
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
			PlaySound(ScriptAction(OrderObject).SoundToPlay, SLOT_None,,true);
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
				bTaskLocked = false;
				OrderObject = None;
				GotoState('Waiting');
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
			bTaskLocked = SD.Actions[i].bTaskLocked;
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
			PlaySound(SD.Actions[i].SoundToPlay,SLOT_None,,true);

		if (SD.Actions[i].AnimToPlay != '')
		{
			LoopAnim(SD.Actions[i].AnimToPlay, 1.0, 0.1);
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
		Acceleration=vect(0,0,0);	// jim said they were moving while turning
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
				Sleep(ScriptAction(OrderObject).AnimTimeToLoop);
			}
			else
			{
				PlayAnim(ScriptAction(OrderObject).AnimToPlay, 1.0, 0.1);
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
	PlayMoving(0.2);
	if (ScriptPoint(OrderObject) != None && ScriptPoint(OrderObject).LookTarget != '')
	{	// Look at looktarget
		bOverrideLookTarget=false;
		LookAt(ActorTagged(ScriptPoint(OrderObject).LookTarget));
	}
	
ContinueScripting:
	if (actorReachable(OrderObject))
	{
	teststring = "reachable";
		MoveToward(OrderObject, MovementSpeed);

		if (ScriptPoint(OrderObject)!=None)
		{
			if (ScriptPoint(OrderObject).bTurnToRotation)
			{	// Turn to ScriptPoint rotation
				TweenToTurning(0.2);
				FinishAnim();

				DesiredRotation = OrderObject.Rotation;
				PlayTurning(0.2);
				FinishAnim();
			}

			if (ScriptPoint(OrderObject).ArriveAnim != '')
			{	// Play anim
				if (ScriptPoint(OrderObject).ArrivePause > 0)
				{
					LoopAnim(ScriptPoint(OrderObject).ArriveAnim, 1.0, 0.1);
					Sleep(ScriptPoint(OrderObject).ArrivePause);
				}
				else
				{
					PlayAnim(ScriptPoint(OrderObject).ArriveAnim, 1.0, 0.1);
					FinishAnim();
				}
			}
		}
		ExecuteScriptPoint();
	}
	else if (FindBestPathToward(OrderObject))
	{
	teststring = "pathable";
		MoveToward(MoveTarget, MovementSpeed);
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

Begin:
	if (debugstates) slog(name@"Scripting to"@OrderObject.Name);

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


//================================================
//
// Fleeing
//
//================================================
State Fleeing
{
ignores SeePlayer, HearNoise, EnemyAcquired;

	function BeginState()
	{
		bHurrying = true;
		UpdateMovementSpeed();
		FireEvent(Event);
		Event = '';
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		global.HitWall(HitNormal, Wall);
		GotoState('Cower');
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		global.Landed(HitNormal, HitActor);
		GotoState('Fleeing', 'HandleLanded');
	}

	function PickDestination()
	{
		if (Enemy != None)
		{
			if (VSize(Enemy.Location - Location) > 1000 && !PlayerCanSeeMe())
			{
				FightOrFlight = 0.0;
				GotoState('Waiting');
			}
			else
			{
				OrderObject = FindPathAwayFrom(Enemy, LastPointVisited);
			}
		}
		else
		{
			OrderObject = FindPathAwayFrom(self, LastPointVisited);
		}
	}

HandleLanded:
	FinishAnim();
	Goto('Flee');

Begin:
	if(debugstates) SLog(name@"Fleeing");

Flee:
	TweenToMoving(0.2);
	FinishAnim();
	PlayMoving();
	Goto('Move');

Move:
	PickDestination();

	if (actorReachable(OrderObject))
	{
		MoveToward(OrderObject, MovementSpeed);
		SoundChance(HitSound1, 0.8);
		LastPointVisited = CurrentPoint;
		CurrentPoint = OrderObject;
	}
	else if (FindBestPathToward(OrderObject))
	{
		MoveToward(MoveTarget, MovementSpeed);
		SoundChance(HitSound1, 0.6);
		LastPointVisited = CurrentPoint;
		CurrentPoint = MoveTarget;
	}
	else if (Enemy != None)
	{	// no paths, pick random spot
		Destination = Location + Normal(Location-Enemy.Location)*50;
		MoveTo(Destination, MovementSpeed);
		Goto('Move');
	}
	
	if (FRand() < 0.1)
	{
		TweenToWaiting(0.2);
		FinishAnim();
		PlayWaiting();
		FinishAnim();
		PlayMoving(0.2);
	}

	Goto('Move');
}


//================================================
//
// Cower
//
//================================================
State Cower
{
Begin:
	Acceleration = vect(0,0,0);
	PlayCower();
}

//================================================
//
// GoingHome
//
//================================================
State GoingHome
{
	function BeginState()
	{
		if (bRoamHome)
		{
			GotoState('Roaming');
			return;
		}

		bHurrying = false;
		UpdateMovementSpeed();
	}

Begin:
	if(debugstates) SLog(name@"GoingHome");
	
Home:
	if (pointReachable(HomeBase))
	{	// Directly reachable
		PlayMoving();
		MoveTo(HomeBase, MovementSpeed);
		FinishAnim();

		PlayTurning();
		DesiredRotation = HomeRot;
		FinishAnim();

		GotoState('Startup', 'Wake');
	}
	else
	{
		MoveTarget = FindPathTo(HomeBase);
		if (MoveTarget != None)
		{	// Pathable
			PlayMoving();
			MoveToward(MoveTarget, MovementSpeed);
			FinishAnim();
		}
		else
		{	// Unreachable
			GotoState('Waiting');
		}
	}
	Goto('Home');
}


//================================================
//
// Acquisition
//
//================================================
State Acquisition
{
ignores EnemyAcquired, SeePlayer, HearNoise;

	function BeginState()
	{
		LookAt(Enemy);
	}

	function InformTeammates()
	{
		local ScriptPawn A;
		foreach AllActors(class'ScriptPawn', A, TeamTag)
		{
			if (A.Enemy != Enemy)
			{
				A.SetEnemy(Enemy);
			}
		}
	}
	
Begin:
	if(debugstates) slog(name@"Acquiring"@Enemy.Name);

Acquire:
//	Sleep(RandRange(0.5, 1.0));
	SetMovementPhysics();
	if (Enemy != None)
		LastSeenPos = Enemy.Location;
	if ((!bGlider) &&
		MaxStopWait > 0)
	{
		Acceleration = vect(0,0,0);

		// Turn to see your new enemy
		if (NeedToTurn(LastSeenPos))
		{	
			PlayTurning();
			TurnTo(LastSeenPos);
		}
		DesiredRotation = Rotator(LastSeenPos - Location);
	}
	Goto('SpecialAcquire');

SpecialAcquire:		// To be overridden
	Goto('InformTeam');

InformTeam:
	PlaySound(AcquireSound, SLOT_Misc,,,, 1.0 + FRand()*0.2-0.1);

	if (Enemy != None)
		Enemy.MakeNoise(1);
/*	if (bTeamLeader)
	{
		InformTeammates();
	}*/
	
	GotoState('TacticalDecision');
}


//================================================
//
// TacticalDecision
//
// All attack behaviors stem from here
//================================================
State TacticalDecision
{
ignores EnemyAcquired, SeePlayer, HearNoise;

	function BeginState()
	{
		if (TeamTag == '')
		{
			TeamTag = name;
			bTeamLeader = true;
		}
	}

	function AssimilateVagrants()
	{
		local ScriptPawn A, TeamMember;
		foreach VisibleActors(class'ScriptPawn', A)
		{
			if (bWillJoin && A.TeamTag == '')
			{
				A.TeamTag = TeamTag;
				A.bTeamLeader = false;
			}
		}
	}

	function CheckElectLeader()
	{
		local ScriptPawn A, TeamMember;
		foreach AllActors(class'ScriptPawn', A)
		{
			if (A.TeamTag == TeamTag)
			{
				TeamMember = A;
				if (A.bTeamLeader)
				{
					return;
				}
			}
		}
		TeamMember.bTeamLeader = true;
	}

	function bool IAmLeader()
	{
		return bTeamLeader;
	}

	function float Evaluate(Pawn A)
	{
		local float strength;

		if (A.Health <= 0)
			return 0;
		strength = 1;
		strength += A.Health  * 0.5;
		strength += A.Mass    * 0.01;
		return strength;
	}

	function DecideOrders()
	{
		local float TeamStrength, EnemyStrength, Advantage;
		local float TeamNumbers, EnemyNumbers;
		local pawn A;
		local ScriptPawn S;

		// Evaluate Team Strength
		TeamStrength = 0;
		foreach AllActors(class'ScriptPawn', S)
		{
			if (S.TeamTag != TeamTag)
				continue;

			TeamStrength += Evaluate(S);
			TeamNumbers += 1;
		}

		// Evaluate Enemy Strength
		EnemyStrength = 0;
		foreach VisibleActors(class'Pawn', A)
		{
			if (ScriptPawn(A) != None && ScriptPawn(A).TeamTag == TeamTag)
				continue;

			EnemyStrength += Evaluate(A);
			EnemyNumbers += 1;
		}

		// Null out orders of troops
		GiveNullOrders();

		Advantage = TeamStrength / EnemyStrength;
		if(debugstates) SLog(TeamStrength$"/"$EnemyStrength$":"@Advantage@TeamNumbers);

		if (Advantage < -1 || AttitudeTo(Enemy) == ATTITUDE_Fear)
			GiveFleeOrders(TeamNumbers);		// Outmatched, Flee
		else
			GiveAttackOrders(TeamNumbers);		// Equally matched, offer battle
	}

	function GiveNullOrders()
	{
		local ScriptPawn TeamMember;
		
		foreach AllActors(class'ScriptPawn', TeamMember)
		{
			if (TeamMember.TeamTag != TeamTag)
				continue;
				
			TeamMember.AttackOrders = '';
		}
	}
	function GiveAttackOrders(int TeamNumbers)
	{
		local ScriptPawn TeamMember;

		foreach AllActors(class'ScriptPawn', TeamMember)
		{
			if (TeamMember.TeamTag != TeamTag)
				continue;
			if (TeamMember.AttackOrders != '')
				continue;

			if ( TeamMember.CanDirectlyThreaten() )
				TeamMember.AttackOrders = 'Charging';
			else
				TeamMember.AttackOrders = 'Hunting';
		}
	}
	function GiveFleeOrders(int TeamNumbers)
	{
		local ScriptPawn TeamMember;
		foreach AllActors(class'ScriptPawn', TeamMember)
		{
			if (TeamMember.TeamTag != TeamTag)
				continue;
			TeamMember.AttackOrders = 'Fleeing';
		}
	}

Begin:
if(debugstates) slog(name@"Tactical");

Think:
/*	if ( IAmLeader())
	{
		if (Intelligence > BRAINS_REPTILE)
		{
			// If any non-team members of my class around, comandeer them for my team
			AssimilateVagrants();
			
			DecideOrders();
		}
		else
		{	// Stupid creatures blindly attack
			GiveAttackOrders(1);
		}
	}
	else	// I am a follower
	{
		// If there is no leader elect one
		CheckElectLeader();
	}*/
	//Paul: Test attempt at speedup
	if ( CanDirectlyThreaten() )
		AttackOrders = 'Charging';
	else
		AttackOrders = 'Hunting';

	if (FRand() > FightOrFlight)
		GotoState('Fleeing');

Wait:
	if (AttackOrders == '')
	{
		Sleep(1);
		Goto('Think');
	}
	GotoState(AttackOrders);
}


//================================================
//
// Threatening
//
// Stay within hunt radius and threaten
//================================================
State Threatening
{
	ignores SeePlayer, HearNoise, EnemyAcquired;

	function BeginState()
	{
		bHurrying = true;
		UpdateMovementSpeed();
		SetTimer(1, true);
	}

	function EndState()
	{
		SetTimer(0, false);
	}

	function Timer()
	{
		if (FRand() < 0.1)
			PlayThreatening(0.1);
	}

	function EnemyNotVisible()
	{
		GotoState('GoingHome');
	}

	function bool PickDestination()
	{
		if (HuntDistance == 0)
			return false;

		if (VSize(Enemy.Location-HomeBase) < HuntDistance &&
			(VSize(Location-HomeBase) < HuntDistance))
		{
			GotoState('Charging');
		}
		else
		{
			Destination = HomeBase + Normal(Enemy.Location - HomeBase) * (HuntDistance);

			if (VSize(Destination - Location) < 50)
			{	// Don't do small moves
				return false;
			}
		}
		return true;
	}

Begin:
	if(debugstates) SLog(name@"Threatening");
	Acceleration = vect(0,0,0);

	if ( !ValidEnemy() )
		GotoState('GoingHome');

StayInRadius:
	if (PickDestination())
	{
		PlayMoving(0.1);
		MoveTo(Destination, MovementSpeed);
		PlayWaiting(0.1);

		// turn to face
		if (NeedToTurn(Enemy.Location))
		{	
			PlayTurning();
			TurnTo(Enemy.Location);
		}
	}
	else
	{
		PlayWaiting(0.1);
	}

	Sleep(1);
	Goto('StayInRadius');
}


//================================================
//
// StakeOut
//
//================================================
state StakeOut
{
	ignores SeePlayer, HearNoise, EnemyAcquired;

	function BeginState()
	{
		bHurrying = true;
		UpdateMovementSpeed();
		SetTimer(1.0+FRand(), true);
		LastPathTime = Level.TimeSeconds;
	}

	function EndState()
	{
		SetTimer(0, false);
	}

	function Timer()
	{
		CheckReachable();
	}

	function CheckReachable()
	{
		if (Level.TimeSeconds - LastPathTime < 1)
			return;
		if (Enemy == None)
			return;

		if (HuntDistance > 0 && VSize(HomeBase-Enemy.Location)>HuntDistance)
		{	// Disallow if seen is outside hunt radius
			teststring2 = Enemy.name @"is outside huntdistance";
			return;
		}

		if (actorReachable(Enemy))
		{
			teststring2 = Enemy.name @"is actorreachable";
			GotoState('Charging');
			return;
		}

		LastPathTime = Level.TimeSeconds;

		if ( FindBestPathToward(Enemy) )
		{
			if (HuntDistance > 0 && VSize(HomeBase-Destination)>HuntDistance)
			{	// Disallow if path to seen is outside hunt radius
				teststring2 = "path is outside huntdistance";
				return;
			}

			teststring2 = Enemy.name @"is pathable - hunting";
			GotoState('Charging');
			return;
		}

		teststring2 = Enemy.name @"unpathable";
	}

Begin:
	if(debugstates) SLog(name@"Stakeout");
	Acceleration = vect(0,0,0);
	SetPhysics(PHYS_Falling);	// So they don't just sit in the air

Stay:
	if ( !ValidEnemy() )
		GotoState('GoingHome');

	PlayWaiting(0.1);
	Sleep(2);
	Goto('Stay');
}


//================================================
//
// Hunting
//
//================================================
State Hunting
{
	function BeginState()
	{
		bHurrying = true;
		UpdateMovementSpeed();
		bAvoidLedges = true;
	}

	function EndState()
	{
		bHunting = false;
		bAvoidLedges = false;
		if ( JumpZ > 0 )
			bCanJump = true;
	}

	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( SetEnemy(NoiseMaker.instigator) )
			LastSeenPos = Enemy.Location; 
	}

	function TryChargeEnemy()
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		if (actorReachable(Enemy))
			GotoState('Charging');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		global.HitWall(HitNormal, Wall);
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			GotoState('Hunting', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
			GotoState('Hunting', 'AdjustFromWall');
		else
			MoveTimer = -1.0;
	}

	function MayFall()
	{	// Only jump if reachable
		if (intelligence==BRAINS_None)
			bCanJump = true;
		else if (MoveTarget!=None)
			bCanJump = actorReachable(MoveTarget);
		else if (Enemy!=None)
			bCanJump = actorReachable(Enemy);
//		if (bFrustrated)
//			bCanJump = true;
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		Super.Landed(HitNormal, HitActor);
	}

	function PickDestination()
	{
		local NavigationPoint path;
		local actor HitActor;
		local vector HitNormal, HitLocation, nextSpot, ViewSpot;
		local float posZ, elapsed;
		local bool bCanSeeLastSeen;

		//TEMP: Everything hunts forever
		HuntTime = 9999;

		// If no enemy, or I should see him but don't, then give up		
		if ( !ValidEnemy() )
		{
			GotoState('GoingHome');
			return;
		}

		bAvoidLedges = false;
		elapsed = Level.TimeSeconds - HuntStartTime;
		if ( elapsed > HuntTime )
		{	// Don't hunt too long
			GotoState('GoingHome');
			return;
		}

		// Don't stray too far from home
		if ( HuntDistance > 0 && VSize(HomeBase-Location)>HuntDistance)
		{	// If outside of hunt radius, return home
			GotoState('GoingHome');
			return;
		}

//		if ( HuntDistance > 0 && VSize(HomeBase-Enemy.Location) > HuntDistance)
//		{	// If enemy is outside of hunt radius
//			GotoState('Stakeout');
//			return;
//		}

		numHuntPaths++;
		if ( JumpZ > 0 )
			bCanJump = true;

		// Enemy is directly reachable
		if ( ActorReachable(Enemy) )
		{
			teststring = "enemy is directly reachable";
			Destination = Enemy.Location;
			MoveTarget = None;
			return;
		}

		// Try to find a path toward enemy
		ViewSpot = Location + EyeHeight * vect(0,0,1);
		bCanSeeLastSeen = false;
		if ( intelligence > BRAINS_Reptile )
		{
			HitActor = Trace(HitLocation, HitNormal, LastSeenPos, ViewSpot, false);
			bCanSeeLastSeen = (HitActor == None);
			if ( bCanSeeLastSeen )
			{
				HitActor = Trace(HitLocation, HitNormal, LastSeenPos, Enemy.Location, false);
				bHunting = (HitActor != None);
			}
			else
				bHunting = true;
			if ( FindBestPathToward(Enemy) )
			{
				teststring = "found a path toward";
				return;
			}
		}

		// If hit a wall, adjust
		MoveTarget = None;
		if ( bFromWall )
		{
			teststring = "From Wall";
			bFromWall = false;
			if ( !PickWallAdjust() )
			{	// Stuck on wall?
				teststring = "Couldnt wall adjust";
				MoveTarget = FindRandomDest();
				if (MoveTarget != None)
					Destination = MoveTarget.Location;
			}
			return;
		}

		// Resort to Last Seen Position
		bFrustrated = true;
		teststring = "resorting to last seen";
		bAvoidLedges = ( (CollisionRadius > 42) && (Intelligence < BRAINS_Human) );
		posZ = LastSeenPos.Z + CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Location - Enemy.OldLocation) * CollisionRadius;
		nextSpot.Z = posZ;
		HitActor = Trace(HitLocation, HitNormal, nextSpot , ViewSpot, false);
		if ( HitActor == None )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
			Destination = LastSeenPos;
		else
		{
			Destination = LastSeenPos;
			HitActor = Trace(HitLocation, HitNormal, LastSeenPos , ViewSpot, false);
			if ( HitActor != None )
			{
				// check if could adjust and see it
				if ( PickWallAdjust() || FindViewSpot() )
					GotoState('Hunting', 'AdjustFromWall');
				else
				{	// Stuck on wall?
					teststring = "Could not wall adjust";
					MoveTarget = FindRandomDest();
					if (MoveTarget != None)
						Destination = MoveTarget.Location;
					return;
				}
			}
		}
		LastSeenPos = Enemy.Location;
	}	

	function bool FindViewSpot()
	{
		local vector X,Y,Z, HitLocation, HitNormal;
		local actor HitActor;
		local bool bAlwaysTry;
		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;
		
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location + 2 * Y * CollisionRadius, false);
		if ( HitActor == None )
		{
			Destination = Location + 2.5 * Y * CollisionRadius;
			return true;
		}

		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location - 2 * Y * CollisionRadius, false);
		if ( HitActor == None )
		{
			Destination = Location - 2.5 * Y * CollisionRadius;
			return true;
		}
		if ( bAlwaysTry )
		{
			if ( FRand() < 0.5 )
				Destination = Location - 2.5 * Y * CollisionRadius;
			else
				Destination = Location - 2.5 * Y * CollisionRadius;
			return true;
		}

		return false;
	}

	function LookAtEndPoint(int index)
	{
		local actor endpoint;
		endpoint = NavigationPoint(MoveTarget).PathEndPoint(index);
		LookToward(endpoint.Location);
	}

AdjustFromWall:
	PlayMoving();	//todo: determine direction and play strafing
	StrafeTo(Destination, Focus);
	Destination = Focus;
	if ( MoveTarget != None )
		Goto('SpecialNavig');
	else
		Goto('Follow');

Begin:
	if(debugstates) SLog(name@"Hunting");
	Acceleration=vect(0,0,0);

Hunt:

	numHuntPaths = 0;
	HuntStartTime = Level.TimeSeconds;

AfterFall:
	TweenToMoving(0.15);
	bFromWall = false;
	FinishAnim();

Follow:
	WaitForLanding();
	if ( CanSee(Enemy) )
		TryChargeEnemy();	// Exit to charge
	PickDestination();

	if (!bMoveWhenUnreachable)
	{
		if (MoveTarget == None)
		{
			if (!pointReachable(Destination))
			{
				teststring2 = string(destination)@"failed pointReachable";
				GotoState('StakeOut');
			}
		}
		else
		{
			if (!actorReachable(MoveTarget))
			{
				teststring2 = MoveTarget.Name@"failed actorReachable";
				GotoState('StakeOut');
			}
		}
	}

	LookToward(Destination);

	// Turn to Destination
	if (AngleTo(Destination) > ANGLE_45)
	{
		DesiredRotation.Yaw = Rotator(Destination - Location).Yaw;
		PlayTurning();
		FinishAnim();
	}

	if (HuntDistance>0 && VSize(HomeBase-Destination)>HuntDistance)
	{	// Destination outside hunt radius
		GotoState('Stakeout');
	}

	TweenToMoving(0.15);
	WaitForLanding();
	FinishAnim();
	PlayMoving();
	StopLookingToward();

SpecialNavig:
	if (MoveTarget == None)
	{
		MoveTo(Destination, MovementSpeed);
//		SoundChance(HuntSound, 1.0);
	}
	else
	{
		MoveToward(MoveTarget, MovementSpeed);
		
		// Look down some paths if not a straight shot
		if ((!bGlider) &&
			MaxStopWait > 0 &&
			NavigationPoint(MoveTarget) != None &&
			NavigationPoint(MoveTarget).NumPaths() > 2 &&
			NavigationPoint(MoveTarget) != LastNodeVisited &&
			FRand() > 0.8)
		{
			TweenToHuntStop(0.3);
			Acceleration = vect(0,0,0);
			FinishAnim();
		
			lookindex = 0;
			while (lookIndex < NavigationPoint(MoveTarget).NumPaths())
			{
				PlayHuntStop();
				SoundChance(RoamSound, 0.3);
				LookAtEndPoint(lookIndex);
				lookIndex++;
				Sleep(RandRange(MinStopWait, MaxStopWait));
				FinishAnim();
			}
		}
		
		LastNodeVisited	= NavigationPoint(MoveTarget);
	}
	
/*	if ( Intelligence < BRAINS_Human )
	{
		if (!SoundChance(RoamSound, 0.3))
			SoundChance(ThreatenSound, 0.7);
	}*/
	Goto('Follow');
}


//================================================
//
// Charging
//
//================================================
State Charging
{
ignores EnemyAcquired, SeePlayer, HearNoise;

	function BeginState()
	{
		StopLookingToward();
		LookAt(Enemy);
		SetTimer(0.1, true);
		bHurrying = true;
		UpdateMovementSpeed();
	}
	
	function EndState()
	{
		LookAt(None);
		SetTimer(0, false);
		if ( JumpZ > 0 )		// This may have been set false in Mayfall, so reset
			bCanJump = true;
	}

	function Timer()
	{
		if ( !ValidEnemy() )
			GotoState('GoingHome');
		else if ( Enemy.Region.Zone.bWaterZone && !bCanSwim)
		{	// Enemy entered water zone and I can't
			GotoState('TacticalDecision');
		}
		else if (!Enemy.Region.Zone.bWaterZone && !bCanFly && !bCanWalk)
		{	// Enemy left water zone and I can't
			GotoState('GoingHome');
		}
		else
		{
			if ((Enemy.bSwingingHigh || Enemy.bSwingingLow) && InMeleeRange(Enemy))
				GotoState('Fighting', 'CheckDefend');
			else if (InAttackRange(Enemy))
				GotoState('Fighting');
		}
	}

	function EnemyNotVisible()
	{
		GotoState('Hunting');
	}
	
	function HitWall(vector HitNormal, actor Wall)
	{
		global.HitWall(HitNormal, Wall);

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

	function vector CheckDestination(vector loc)
	{
		if (VSize(loc - HomeBase) > HuntDistance)
		{	// Destination is outside radius
			return (Normal(loc-HomeBase)*(HuntDistance*0.95));
		}
		// Don't stray too far from home when charging
		if ( HuntDistance > 0 && VSize(HomeBase-Location)>HuntDistance)
		{	// Outside hunt radius
			GotoState('Threatening');
		}
		return loc;
	}


AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Goto('CheckEnemy');

ResumeFromFighting:
	Timer();
Begin:
	if(debugstates) slog(name@"Charging");
	Goto('Threaten');

Threaten:	// Override in classes that threaten
	Enemy=Enemy;
	Goto('TweenIn');

TweenIn:
	TweenToMoving(0.15);
	FinishAnim();
	PlayMoving();

Charge:
	MoveTimer = 0.0;
	bFromWall = false;
	if ( JumpZ > 0 )		// This may have been set false in Mayfall, so reset
		bCanJump = true;

CheckEnemy:
	// Check enemy for exit conditions
	Timer();
	
CloseIn:
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

	if( actorReachable(Enemy) )
	{
		// Handle HuntDistance
		if (HuntDistance > 0 && VSize(Enemy.Location - HomeBase) > HuntDistance)
		{	// Destination is outside radius
			Destination = HomeBase + (Normal(Enemy.Location-HomeBase)*(HuntDistance*0.95));
			if (VSize(Destination-Location) > 50)
			{	// Get as close as possible while still within radius
				PlayMoving(0.1);
				if (bCanStrafe)
					StrafeFacing(Destination, Enemy);
				else
					MoveTo(Destination, MovementSpeed);

				if (NeedToTurn(Enemy.Location))
				{
					PlayTurning(0.1);
					TurnTo(Enemy.Location);
				}
				PlayWaiting(0.1);
				Sleep(0.5);
				Acceleration=vect(0,0,0);
			}
			else
			{	// Small move, just wait
				Acceleration=vect(0,0,0);
				PlayWaiting(0.1);
				Sleep(0.5);
			}
		}
		else if ( HuntDistance > 0 && VSize(HomeBase-Location)>HuntDistance)
		{	// Already Outside hunt radius
			Destination = HomeBase + (Normal(Enemy.Location-HomeBase)*(HuntDistance*0.95));
			if (VSize(Destination-Location) > 50)
			{	// Get as close as possible while still within radius
				PlayMoving(0.1);
				if (bCanStrafe)
					StrafeFacing(Destination, Enemy);
				else
					MoveTo(Destination, MovementSpeed);
				if (NeedToTurn(Enemy.Location))
				{
					PlayTurning(0.1);
					TurnTo(Enemy.Location);
				}
				PlayWaiting(0.1);
				Sleep(0.5);
				Acceleration=vect(0,0,0);
			}
			else
			{	// Small move, just wait
				Acceleration=vect(0,0,0);
				PlayWaiting(0.1);
				Sleep(0.5);
			}
		}
		else
		{	// Normal Charge
			if (HuntDistance > 0)	// could have been reset to waiting
				PlayMoving(0.1);

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
	}
	else
	{
		bCanSwing = false;
		bFromWall = false;
		if (!FindBestPathToward(Enemy))
		{	// unreachable and unpathable
			GotoState('Hunting');
		}

		if ( HuntDistance > 0)
		{
			if (VSize(HomeBase-Location)>HuntDistance)
			{	// Outside hunt radius
				GotoState('StakeOut');
			}
			else if (VSize(HomeBase-MoveTarget.Location)>HuntDistance)
			{	// Destination outside hunt radius
				GotoState('StakeOut');
			}
		}

		PlayMoving(0.1);
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
//			if ( !bFromWall )
//				SoundChance(ThreatenSound, 0.8);
		}
	}
	Goto('Charge');
}


//================================================
//
// Fighting
//
// Override in children
//================================================
State Fighting
{
ignores EnemyAcquired;

	function BeginState()
	{
		LookAt(Enemy);
		bHurrying = true;
		UpdateMovementSpeed();
	}

	function EndState()
	{
		bSwingingHigh = false;
		if (Weapon!=None)
			Weapon.FinishAttack();
		LookAt(None);
	}

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

Begin:
	if(debugstates) SLog(name@"Fighting");
	Acceleration = vect(0,0,0);
	GetEnemyProximity();

	// Turn to face enemy
	DesiredRotation.Yaw = rotator(Enemy.Location-Location).Yaw;

Fight:
	bSwingingHigh = true;
	PlayMeleeHigh(0.1);
	FinishAnim();
	bSwingingHigh = false;
	Sleep(TimeBetweenAttacks);

	GotoState('Charging', 'ResumeFromFighting');

CheckDefend:
	GotoState('Charging', 'ResumeFromFighting');
}




//==================================================================
//
// Sub-states and Misc states
//
// require NextState to be set
//==================================================================


//============================================================
//
// Drowning
//
//============================================================
state Drowning
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, Landed, EnemyAcquired, PlayTakeHit;

	function BeginState()
	{
		Buoyancy = 0.98 * Mass;
		DropWeapon();
		DropShield();
	}

	function EndState()
	{
		Buoyancy = 0.75 * Mass;
		SetPhysics(PHYS_Falling);
		if (Health <= 0)
		{
			Breath();
			Breath();
			Breath();
		}
	}

	function PainTimer()
	{
		Super.PainTimer();
		Breath();
	}

	function HeadZoneChange(ZoneInfo newHeadZone)
	{
		if (!newHeadZone.bWaterZone)
		{
			GotoState('Waiting');
		}
	}

Begin:
	Acceleration = vect(0,0,0);
	PlayDrowning(0.1);
}


//============================================================
//
// Dying
//
//============================================================
state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, Landed, EnemyAcquired, CheckForEnemies;

	function SpawnBloodSplot()
	{
		local vector headLoc;
		local vector start, end;
		local vector loc, norm;
		
		//	if (BodyPartMissing(BODYPART_HEAD))
		if (!HeadRegion.Zone.bWaterZone)
		{
			headLoc = GetJointPos(JointNamed('head'));
			start = headLoc;
			end = headLoc - vect(0, 0, 50);
			if(Trace(loc, norm, end, start) != None)
			{
	    		loc = loc + norm * FRand(); // Pull the decal a bit out from the surface
				Spawn(class'DecalBlood4',,,loc, rotator(-norm));
			}
		}
	}

	function AmbientSoundTimer()
	{
		// Don't reset timer
	}

	function Timer()
	{
		Super.Timer();
		SpawnBloodSplot();
	}
}



//================================================
//
// FallingState
//
//================================================
State FallingState
{
//	ignores Landed, SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, PainTimer, SetFall;
	ignores Landed, SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, Falling, WarnTarget, SetFall;

	function BeginState()
	{
		MoveTarget = None;
	}

	function bool CanGotoPainState()
	{ // Do not allow the creature to enter the painstate when falling
		return(false);
	}

	event PainTimer()
	{
		// Pain timer just expired:
		//  Check what zone I'm in (and which parts are)
		//  based on that cause damage, and reset PainTime

		if((Health < 0) || (Level.NetMode == NM_Client))
			return;
			
		if(FootRegion.Zone.bPainZone)
		{
			PainTime = 1.0;
		}
		else if ( HeadRegion.Zone.bWaterZone )
		{
			PainTime = 2.0;
		}
	}

	function AnimEnd()
	{
		if(AnimSequence == A_PullUp)
		{
			PlayStepUp();
		}
		else if(AnimSequence == A_StepUp)
		{		
			PlayWaiting();
			SetPhysics(PHYS_Falling);
			GotoState(NextState);
		}
	}

	function bool GrabEdge(float grabDistance, vector grabNormal)
	{
		local float dist;

		Velocity = vect(0, 0, 0);
		Acceleration = vect(0, 0, 0);

		GrabLocationUp.X = Location.X;
		GrabLocationUp.Y = Location.Y;
		GrabLocationUp.Z = Location.Z + grabDistance + 2;
	
		GrabLocationIn.X = Location.X + grabNormal.X * (CollisionRadius + 5);
		GrabLocationIn.Y = Location.Y + grabNormal.Y * (CollisionRadius + 5);
		GrabLocationIn.Z = GrabLocationUp.Z + CollisionHeight + 4;


		dist = GrabLocationUp.Z - Location.Z;
		SetLocation(GrabLocationIn);

		if(dist > 20 && A_PullUp != 'None') 
		{
			PlayPullup(0.0); // No tween
		}
		else if(A_StepUp != 'None')
		{
			PlayStepup(0.0); // No tween
		}
		
//		GotoState('FallingState', 'EdgeHanging');

		return(true);
	}

	//choose a jump velocity
	function adjustJump()
	{
		local float velZ;
		local vector FullVel;
		local vector LedgeDown, HitLoc, HitNorm;
		local actor A;

		velZ = Velocity.Z;
		FullVel = Normal(Velocity) * GroundSpeed;

		// Trace down to see if we can jump step down to floor
		LedgeDown = vect(0,0,0);
		LedgeDown.Z = -(CollisionHeight + 100);
		A = Trace(HitLoc, HitNorm, Location+LedgeDown, Location, true);
		if (A != None)
		{	// There's something to land on, don't jump
			Destination = Location + vector(rotation)*CollisionRadius;
			GotoState('FallingState', 'WalkOverEdge');
			return;
		}

		// If far above destination
		If (Location.Z > Destination.Z + CollisionHeight + 2 * MaxStepHeight)
		{
			Velocity = FullVel;
			Velocity.Z = velZ;
			Velocity = EAdjustJump();
			Velocity.Z = 0;
			if ( VSize(Velocity) < 0.9 * GroundSpeed )
			{
				Velocity.Z = velZ;
				return;
			}
		}

		Velocity = FullVel;
		Velocity.Z = JumpZ + velZ;
		Velocity = EAdjustJump();
	}

	function DoLanded(vector HitNormal)
	{
		bJustLanded = true;
		PlayLanded(Velocity.Z);
		if (Velocity.Z < -1.4 * JumpZ || bUpAndOut)
		{
			MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));

			// Falling damage
			if (Velocity.Z <= -1100)
			{
				if ( (Velocity.Z < -2000) && (ReducedDamageType != 'All') )
					JointDamaged(1000, None, Location, vect(0,0,0), 'fell', 0);
				else if ( Role == ROLE_Authority )
					JointDamaged(-0.15 * (Velocity.Z + 1050), None, Location, vect(0,0,0), 'fell', 0);
			}
		}
		else if ( Velocity.Z < -0.8 * JumpZ )
		{
			PlayLanded(Velocity.Z);
			GotoState('FallingState', 'FastLanded');
		}
	}
	
	function EnemyAcquired()
	{
		NextState = 'Acquisition';
		NextLabel = 'Begin';
	}

/* Obsolete, as pulling up is now handed with two animations, and using AnimEnd -- cjr
EdgeHanging:
	teststring = "Edge Hanging";

	if(GrabLocationUp.Z - Location.Z > 20)
	{
//		PlaySound(EdgeGrabSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.4 + 0.8);
		SetLocation(GrabLocationIn);
		PlayPullup(0.0); // No tween
		FinishAnim();

//		PlaySound(StepupSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.4 + 0.8);

		PlayStepup(0.1);
		FinishAnim();
	}
	else
	{
		SetLocation(GrabLocationIn);

//		PlaySound(StepupSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.4 + 0.8);

		PlayStepup(0.0); // No tween
		FinishAnim();	
	}

	PlayWaiting(); // Necessary?
	AirSpeed = Default.AirSpeed;

	SetPhysics(PHYS_Falling);
	WaitForLanding();
	GotoState(NextState);
*/

WalkOverEdge:
	teststring = "WalkOverEdge";
	AirSpeed = 225;
	SetPhysics(PHYS_Flying);
	MoveTo(Destination);
	AirSpeed = Default.AirSpeed;
	SetPhysics(PHYS_Falling);
	Goto('Falling');
	
FastLanded:
	teststring = "FastLanded";
	Velocity=vect(0,0,0);
//	FinishAnim();
	Goto('Done');

Done:
	GotoState(NextState, NextLabel);

Begin:
	if(debugstates) SLog(name@"Falling"@"NextState="$NextState);
	teststring = "Begin";
	if (Region.Zone.bWaterZone)
	{
		if (bCanSwim)
			SetPhysics(PHYS_Swimming);
		Goto('Done');
	}
	AdjustJump();

Falling:
	teststring = "Falling";
	if (Physics != PHYS_Falling)
		Goto('Done');
	WaitForLanding();
	DoLanded(vect(0,0,1));

Landed:
	teststring = "Landed";
	if ( !bIsPlayer ) //bots act like players
		Acceleration = vect(0,0,0);
	FinishAnim();
	Goto('Done');
}


//===============================================================================
// Scriptable States
//===============================================================================

//================================================
//
// Statue
//
//================================================
State() Statue
{
ignores HearNoise, EnemyAcquired, Bump, PowerupFire, PowerupBlaze, PowerupStone, PowerupIce, PowerupFriend, SetOnFire, CheckForEnemies, ProtectAlly, WeaponActivate, SwipeEffectStart;

	function AmbientSoundTimer()
	{
		// Don't play it, just reset timer for next one
		AmbientSoundTime = (0.5 + FRand()*0.5) * AmbientWaitSoundDelay;
	}

	function EMatterType MatterForJoint(int joint)
	{
		return MATTER_STONE;
	}

	function bool CanBeStatued()
	{
		return false;
	}

	function SpawnDebris(vector Momentum)
	{
		local int numchunks;
		local debris d;
		local vector loc;
		local float scale;

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

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		local actor A;

		if (DamageType=='sever' || DamageType=='bluntsever' ||
			DamageType=='thrownweaponsever' || DamageType=='thrownweaponbluntsever' ||
			DamageType=='fire' || DamageType=='electricity' ||
			DamageType=='stomped')
			return false;

		if (bStatueDestructible)
		{
			if( Event != '' )
				foreach AllActors( class 'Actor', A, Event )
					A.Trigger( Self, EventInstigator );
			Health = 0;
			PlaySound(Sound'WeaponsSnd.impcrashes.crashxstone01', SLOT_Pain);
			SpawnDebris(Momentum);
			Destroy();
		}

		return false;
	}

	function Trigger(actor Other, pawn EventInstigator)
	{
		if (bStatueCanWake)
			GotoState('Statue', 'Wake');
	}

	function CreatureStatue()
	{
		local int ix;

		for (ix=0; ix<16; ix++)
		{
			if (SkelGroupSkins[ix] != None)
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
			SkelGroupSkins[ix] = None;
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
				inv.bSweepable=false;
				for (ix=0; ix<16; ix++)
				{
					if (inv.SkelGroupSkins[ix] != None)
					{
						inv.SkelGroupSkins[ix] = texture'statues.sb_body_stone';
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

	function Tick(float DeltaTime)
	{
		if (bCanLook)
		{
			Super.Tick(DeltaTime);
		}
	}

	function Timer()
	{
		// Once in a while, check if player can see me
		if (PlayerCanSeeMe())
		{
			bCanLook = false;
		}
		else
		{
			bCanLook = true;
			LookAt(Target);
		}
	}

	function SeePlayer(Actor Seen)
	{
		if (bStatueCanWake && Target == None)
		{
			Target = Seen;
			SetTimer(0.5, true);
		}
	}

	function BeginState()
	{
		bCanLook = false;
		Target = None;
		bProjTarget = false;
		if (Weapon!=None)
			Weapon.FinishAttack();
	}

	function EndState()
	{
		bCanLook = Default.bCanLook;
		SetTimer(0, false);
		bMovable = Default.bMovable;
		bProjTarget = Default.bProjTarget;
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		bMovable = false;
		global.Landed(HitNormal, HitActor);
	}

Wake:
	DebrisCloud();
	SetTimer(0, false);
//	PlayThreatening(0.1);
	CreatureNormal();
	InventoryNormal();
//	FinishAnim();
	OrderFinished();
	GotoState('Waiting');

Begin:
	Acceleration=vect(0,0,0);
	SetPhysics(PHYS_Falling);

	CreatureStatue();
	InventoryStatue();

	if (StatueAnimSeq != '')
	{
		TweenAnim(StatueAnimSeq, 0.2);
		FinishAnim();

		for(i=0; i<20; i++)
		{
			AnimFrame = (AnimFrame + 3*StatueAnimFrame)*0.25;
			Sleep(0.1);
		}
	}
	else
	{
		// Slow to end of sequence
		for(i=0; i<20; i++)
		{
			AnimRate *= 0.75;
			Sleep(0.1);
		}
	}
	AnimRate=0;
	bMovable = false;
}


//================================================
//
// IceStatue
//
// Used only for Ice Powerup
//================================================
State() IceStatue
{
ignores HearNoise, EnemyAcquired, Bump, PowerupFire, PowerupBlaze, PowerupStone, PowerupIce, PowerupFriend, SetOnFire, CheckForEnemies, ProtectAlly, WeaponActivate, SwipeEffectStart;

	function AmbientSoundTimer()
	{
		// Don't play it, just reset timer for next one
		AmbientSoundTime = (0.5 + FRand()*0.5) * AmbientWaitSoundDelay;
	}

	function EMatterType MatterForJoint(int joint)
	{
		return MATTER_ICE;
	}

	function bool CanBeStatued()
	{
		return false;
	}

	function SpawnDebris(vector Momentum)
	{
		local int numchunks;
		local debris d;
		local vector loc;
		local float scale;

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

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		local actor A;

		if (DamageType=='sever' || DamageType=='bluntsever' ||
			DamageType=='thrownweaponsever' || DamageType=='thrownweaponbluntsever' ||
			DamageType=='fire' || DamageType=='electricity')
			return false;

		if (bStatueDestructible)
		{
			if( Event != '' )
				foreach AllActors( class 'Actor', A, Event )
					A.Trigger( Self, EventInstigator );
			Health = 0;
			PlaySound(Sound'WeaponsSnd.impcrashes.crashglass02', SLOT_Pain);
			SpawnDebris(Momentum);
			Destroy();
		}

		return false;
	}

	function Trigger(actor Other, pawn EventInstigator)
	{
		if (bStatueCanWake)
			GotoState('IceStatue', 'Wake');
	}

	function CreatureStatue()
	{
		local int ix;

		for (ix=0; ix<16; ix++)
		{
			if (SkelGroupSkins[ix] != None)
				SkelGroupSkins[ix] = texture'statues.ice1';
		}
	}

	function CreatureNormal()
	{
		local int ix;

		// Transform creature to default skin
		for (ix=0; ix<16; ix++)
			SkelGroupSkins[ix] = None;
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
;
			}
			inv = inv.Inventory;
		}
	}

	function Timer()
	{	// After time expires, come back to life (timer set by powerup)
		GotoState('IceStatue', 'Wake');
	}

	function BeginState()
	{
		bCanLook = false;
		bProjTarget = false;
		if (Weapon!=None)
			Weapon.FinishAttack();
	}

	function EndState()
	{
		bCanLook = Default.bCanLook;
		SetTimer(0, false);
		bMovable = Default.bMovable;
		bProjTarget = Default.bProjTarget;
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		bMovable = false;
		global.Landed(HitNormal, HitActor);
	}

Wake:
	SpawnDebris(vect(0,0,0));
	PlaySound(Sound'WeaponsSnd.impcrashes.crashglass02', SLOT_Pain);
	SetTimer(0, false);
	CreatureNormal();
	InventoryNormal();
	OrderFinished();
	GotoState('Waiting');

Begin:
	Acceleration=vect(0,0,0);
	SetPhysics(PHYS_Falling);

	CreatureStatue();
	InventoryStatue();

	if (StatueAnimSeq != '')
	{
		TweenAnim(StatueAnimSeq, 0.2);
		FinishAnim();

		for(i=0; i<20; i++)
		{
			AnimFrame = (AnimFrame + 3*StatueAnimFrame)*0.25;
			Sleep(0.1);
		}
	}
	else
	{
		// Slow to end of sequence
		bAnimLoop=false;
		for(i=0; i<7; i++)
		{
			AnimRate *= 0.75;
			Sleep(0.1);
		}

		while (AnimFrame < AnimLast)
			Sleep(0.1);
	}
	AnimRate=0;
	bMovable = false;
}


//================================================
// Frozen
// Used to make a quiet creature in scripting, trigger to get out
//================================================
State() Frozen
{
	function BeginState()
	{
		bQuiet=true;
		SetPhysics(PHYS_None);
	}

	function EndState()
	{
		bQuiet=false;
		SetMovementPhysics();
	}

Begin:
}


//================================================
//
// Attack (not finished)
//
// Attack OrderObject
// That order object should have an event to trigger this guy, which in
// turn will fire the next state
//================================================
State() Attack
{
Begin:
	Enemy = Pawn(OrderObject);
	if (Enemy != None)
		GotoState('Acquisition');

	// put next queued state in Trigger orders to be fired when enemy dies
	TriggerOrders = NextState;
	if (NextPoint != None)
		TriggerOrdersTag = NextPoint.Tag;

}


//================================================
// Debug
//================================================
simulated function Debug(canvas Canvas, int mode)
{
	local int sx,sy;
	local vector offset;
	local string text;
	
	Super.Debug(Canvas, mode);
	
	Canvas.DrawText("ScriptPawn:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  NavList:      "$Level.NavigationPointList);
	Canvas.CurY -= 8;

	text = "  ";
	if (bCanWalk)
		text = text@"bCanWalk";
	if (bCanJump)
		text = text@"bCanJump";
	if (bCanSwim)
		text = text@"bCanSwim";
	if (bCanFly)
		text = text@"bCanFly";
	Canvas.DrawText(text);
	Canvas.CurY -= 8;

	Canvas.DrawText("  bHurrying:    "$bHurrying);
	Canvas.CurY -= 8;
	Canvas.DrawText("  MovementSpeed:"$MovementSpeed);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bTaskLocked:  "$bTaskLocked);
	Canvas.CurY -= 8;
	Canvas.DrawText("  Orders:       "$Orders);
	Canvas.CurY -= 8;
	Canvas.DrawText("  OrdersTag:    "$OrdersTag);
	Canvas.CurY -= 8;
	Canvas.SetColor(255, 255, 255);
	if (HuntDistance>0)
	{
		Canvas.DrawText("  HuntDistance: "$HuntDistance);
		Canvas.CurY -= 8;
	}
	Canvas.DrawText("  TestStr: "$teststring);
	Canvas.CurY -= 8;
	Canvas.DrawText("  TestStr2:"$teststring2);
	Canvas.CurY -= 8;
	Canvas.SetColor(255, 0, 0);

	Canvas.DrawText("	bStopMoveIfCombatRange:"$bStopMoveIfCombatRange);
	Canvas.CurY -= 8;

	switch(EnemyFacing)
	{
	case FACE_FRONT:	Canvas.DrawText("	Enemy Facing:    FRONT");	break;
	case FACE_BACK:		Canvas.DrawText("	Enemy Facing:    BACK");	break;
	case FACE_SIDE:		Canvas.DrawText("	Enemy Facing:    SIDE");	break;
	}
	Canvas.CurY -= 8;

	switch(EnemyVertical)
	{
	case VERT_ABOVE:	Canvas.DrawText("	Enemy Vertical:  ABOVE");	break;
	case VERT_BELOW:	Canvas.DrawText("	Enemy Vertical:  BELOW");	break;
	case VERT_LEVEL:	Canvas.DrawText("	Enemy Vertical:  LEVEL");	break;
	}
	Canvas.CurY -= 8;

	switch(EnemyMovement)
	{
	case MOVE_CLOSER:		Canvas.DrawText("	Enemy Movement:  CLOSER");			break;
	case MOVE_FARTHER:		Canvas.DrawText("	Enemy Movement:  FARTHER");			break;
	case MOVE_STRAFE_LEFT:	Canvas.DrawText("	Enemy Movement:  STRAFE_LEFT");		break;
	case MOVE_STRAFE_RIGHT:	Canvas.DrawText("	Enemy Movement:  STRAFE_RIGHT");	break;
	case MOVE_STANDING:		Canvas.DrawText("	Enemy Movement:  STANDING");		break;
	}
	Canvas.CurY -= 8;

	switch(EnemyIncidence)
	{
	case INC_FRONT:		Text="INC_FRONT";	break;
	case INC_BACK:		Text="INC_BACK";	break;
	case INC_LEFT:		Text="INC_LEFT";	break;
	case INC_RIGHT:		Text="INC_RIGHT";	break;
	}
	Canvas.DrawText("	Enemy Incidence: "$Text);
	Canvas.CurY -= 8;

	switch(LastAction)
	{
	case AA_WAIT:			Text="AA_WAIT";				break;
	case AA_CHARGE:			Text="AA_CHARGE";			break;
	case AA_STRAFE_LEFT:	Text="AA_STRAFE_LEFT";		break;
	case AA_STRAFE_RIGHT:	Text="AA_STRAFE_RIGHT";		break;
	case AA_LUNGE:			Text="AA_LUNGE";			break;
	case AA_JUMP:			Text="AA_JUMP";				break;
	case AA_BACKUP:			Text="AA_BACKUP";			break;
	case AA_ATTACKMELEE1:	Text="AA_ATTACKMELEE1";		break;
	case AA_ATTACKMELEE2:	Text="AA_ATTACKMELEE2";		break;
	case AA_ATTACKMELEE3:	Text="AA_ATTACKMELEE3";		break;
	case AA_ATTACKMISSILE1:	Text="AA_ATTACKMISSILE1";	break;
	case AA_ATTACKMISSILE2:	Text="AA_ATTACKMISSILE2";	break;
	}
	Canvas.DrawText("   LastAction:      " $ Text);
	Canvas.CurY -= 8;

	switch(AttackAction)
	{
	case AA_WAIT:			Text="AA_WAIT";				break;
	case AA_CHARGE:			Text="AA_CHARGE";			break;
	case AA_STRAFE_LEFT:	Text="AA_STRAFE_LEFT";		break;
	case AA_STRAFE_RIGHT:	Text="AA_STRAFE_RIGHT";		break;
	case AA_LUNGE:			Text="AA_LUNGE";			break;
	case AA_JUMP:			Text="AA_JUMP";				break;
	case AA_BACKUP:			Text="AA_BACKUP";			break;
	case AA_ATTACKMELEE1:	Text="AA_ATTACKMELEE1";		break;
	case AA_ATTACKMELEE2:	Text="AA_ATTACKMELEE2";		break;
	case AA_ATTACKMELEE3:	Text="AA_ATTACKMELEE3";		break;
	case AA_ATTACKMISSILE1:	Text="AA_ATTACKMISSILE1";	break;
	case AA_ATTACKMISSILE2:	Text="AA_ATTACKMISSILE2";	break;
	}
	Canvas.DrawText("   AttackAction:    " $ Text);
	Canvas.CurY -= 8;
	
	// Destination is red
	offset = Destination;
	Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 255, 0, 0);
	Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 255, 0, 0);
	Canvas.DrawLine3D(offset + vect(0, 0, 10), offset+ vect(0, 0, -10), 255, 0, 0);
	Canvas.DrawLine3D(Location, Destination, 255, 0, 0);

	// MoveTarget is Green
	if (MoveTarget != None)
		Canvas.DrawLine3D(Location, MoveTarget.Location, 0, 0, 255);
		
	// OrderObject is Blue
	if (OrderObject != None)
		Canvas.DrawLine3D(Location, OrderObject.Location, 0, 0, 255);
}

defaultproperties
{
     bFallAtStartup=True
     ThrowTrajectory=8192
     HuntTime=30.000000
     bStatueCanWake=True
     bStatueDestructible=True
     AmbientWaitSoundDelay=15.000000
     AmbientFightSoundDelay=10.000000
     MinStopWait=0.500000
     MaxStopWait=1.500000
     bWaitLook=True
     bBurnable=True
     AllyMaxTime=30.000000
     WanderDistance=12.000000
     CarcassType=Class'RuneI.RuneCarcass'
     WalkingSpeed=50.000000
     GibCount=8
     GibClass=Class'RuneI.DebrisFlesh'
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
     WeaponJoint=Weapon
     ShieldJoint=Shield
     bFootsteps=True
     bFrameNotifies=True
     DrawType=DT_SkeletalMesh
}
