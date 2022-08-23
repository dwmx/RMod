//=============================================================================
// Polyobj.
//=============================================================================
class Polyobj expands Brush
	native;
//	nativereplication;

//-----------------------------------------------------------------------------
// Mover Stuff
//-----------------------------------------------------------------------------

// How to react when it encroaches an actor.
var() enum EPolyObjEncroachType
{
	PET_StopWhenEncroach,	// Stop when we hit an actor.
	PET_ReturnWhenEncroach,	// Return to previous position when we hit an actor.
   	PET_CrushWhenEncroach,   // Crush the poor helpless actor.
   	PET_IgnoreWhenEncroach,  // Ignore encroached actors.
} PolyObjEncroachType;

// How to move from one position to another.
var() enum EPolyObjGlideType
{
	PGT_MoveByTime,			// Move linearly.
	PGT_GlideByTime,			// Move with smooth acceleration.
} PolyObjGlideType;

// What classes can bump trigger me
var() enum EPolyObjBumpType
{
	PBT_PlayerBump,		// Can only be bumped by player.
	PBT_PawnBump,		// Can be bumped by any pawn
	PBT_CreatureBump,	// Can be bumped by any NON-player pawn
	PBT_AnyBump,			// Cany be bumped by any solid actor
} PolyObjBumpType;

// Keyframe numbers.
var() byte       KeyNum;           // Current or destination keyframe.
var byte         PrevKeyNum;       // Previous keyframe.
var() const byte NumKeys;          // Number of keyframes in total (0-3).
var() const byte WorldRaytraceKey; // Raytrace the world with the brush here.
var() const byte BrushRaytraceKey; // Raytrace the brush here.

// Movement parameters.
var() float      MoveTime[16];         // Time to spend moving between keyframes.
var() float      StayOpenTime;     // How long to remain open before closing.
var() float      OtherTime;        // TriggerPound stay-open time.
var() int        EncroachDamage;   // How much to damage encroached actors.
var() name		 InterpolateEvent[16];	// RUNE:  Events to call at each interpolation point
var() int		 BumpDamage;		// Damage to do to an actor when bumped (one-time per bump)

// Mover state.
var() bool       bTriggerOnceOnly; // Go dormant after first trigger.
var() bool       bSlave;           // This brush is a slave.
var() bool		 bUseTriggered;		// Triggered by player grab
var() bool		 bDamageTriggered;	// Triggered by taking damage
var() bool       bDynamicLightMover; // Apply dynamic lighting to mover.
var() name       PlayerBumpEvent;  // Optional event to cause when the player bumps the mover.
var() name       BumpEvent;			// Optional event to cause when any valid bumper bumps the mover.
var   actor      SavedTrigger;      // Who we were triggered by.
var() float		 DamageThreshold;	// minimum damage to trigger
var	  int		 numTriggerEvents;	// number of times triggered ( count down to untrigger )
var	  Polyobj	 Leader;			// for having multiple movers return together
var	  Polyobj	 Follower;
var() name		 ReturnGroup;		// if none, same as tag
var() float		 DelayTime;			// delay before starting to open

// Audio.
var(Sounds) sound      OpeningSound;     // When start opening.
var(Sounds) sound      OpenedSound;      // When finished opening.
var(Sounds) sound      ClosingSound;     // When start closing.
var(Sounds) sound      ClosedSound;      // When finish closing.
var(Sounds) sound      MoveAmbientSound; // Optional ambient sound when moving.

// Internal.
var vector       KeyPos[16];
var rotator      KeyRot[16];
var vector       BasePos, OldPos, OldPrePivot, SavedPos;
var rotator      BaseRot, OldRot, SavedRot;

// AI related
var       NavigationPoint  myMarker;
var		  Actor			TriggerActor;
var		  Actor         TriggerActor2;
var		  Pawn			WaitingPawn;
var		  bool			bOpening, bDelaying, bClientPause;
var		  bool			bPlayerOnly;
var		  Trigger		RecommendedTrigger;

// for client side replication
var		vector			SimOldPos;
var		int				SimOldRotPitch, SimOldRotYaw, SimOldRotRoll;
var		vector			SimInterpolate;
var		vector			RealPosition;
var     rotator			RealRotation;
var		int				ClientUpdate;

//-----------------------------------------------------------------------------
// PolyObj stuff
//-----------------------------------------------------------------------------
var const bool bCanRender;			// Set to true after the poly has been lit and is renderable
var() bool bDynamicLightPolyobj;	// The polyobj should be dynamically lit

var vector	CStartLocation;
var vector	CHeightVect;
var rotator	CRotator;
var float	CTimeCounter;
var float	CPrevV;
var float	CPulse;
var float	CDelay;
var actor	CBase;

var(PolyObjSpecial) float CCycleTime;
var(PolyObjSpecial) float CPhase;
var(PolyObjSpecial) float CHeight;
var(PolyObjSpecial) float CSize;
var(PolyObjSpecial) float CSpeed;
var(PolyObjSpecial) sound CSound;
var(PolyObjSpecial) bool flag1;
var(PolyObjSpecial) bool flag2;
var(PolyObjSpecial) name CBaseName;

const CCUTOFF = 0.3;

var int OnMeCount;							// For Sinkers
var Pawn OnMeList[4];						// For Sinkers
var bool SinkResting;						// For Sinkers

var() bool bInitiallyOn;		// used for rotators, smashing, 

var() vector ThrustVector;	// For PET_ThrustWhenEncroach

var(PolyObjDestroyable) EMatterType matter;			// Used to tell if damaged in lieu of being texture based
var(PolyObjDestroyable) class<Debris> DebrisType;
var(PolyObjDestroyable) bool bDestroyable;			// An alternate way of marking as destroyable (to combine with other states)
var(PolyObjDestroyable) int NumDebrisChunks;
var(PolyObjDestroyable) float DebrisSpawnRadius;	// Used for debris spawn locations and to calculate size of chunks
var(PolyObjDestroyable) Texture DebrisTexture;


native(668) final function float GetCollisionRadius();		// Get approximate collision sphere
native(669) final function Texture GetTexture();			// Get one of the textures


replication
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority )
		SimOldPos, SimOldRotPitch, SimOldRotYaw, SimOldRotRoll, SimInterpolate, RealPosition, RealRotation;
}



//-----------------------------------------------------------------------------
// Functions
//-----------------------------------------------------------------------------

// Override in destructible child classes to determine matter
function Explode(vector Momentum)
{
	local Debris D;
	local Actor A;
	local int i,numchunks;
	local float scale;
	local vector loc;

	// Trigger any events.
	FireEvent(Event);

	// DebrisType is specified by LD, for automatic use RunePolyobj

	// Spawn debris
	if (DebrisType != None)
	{
		if (DebrisSpawnRadius == 0)
			DebrisSpawnRadius = GetCollisionRadius();

		// Find appropriate size of chunks
//		scale = (CollisionRadius*CollisionRadius*CollisionHeight) / (NumDebrisChunks*500);
		scale = (DebrisSpawnRadius*DebrisSpawnRadius*DebrisSpawnRadius) / (NumDebrisChunks*500);
		scale = scale ** 0.3333333;
		scale = FClamp(scale, 0.2, 5);

		numchunks = NumDebrisChunks*Level.Game.DebrisPercentage;
		for (i=0; i<numchunks; i++)
		{
			loc = Location;
			loc.X += (FRand()*2-1)*DebrisSpawnRadius;
			loc.Y += (FRand()*2-1)*DebrisSpawnRadius;
			loc.Z += (FRand()*2-1)*DebrisSpawnRadius;
			D = Spawn(DebrisType,,,loc);
			if (D != None)
			{
				D.SetSize(scale);
				if (DebrisTexture==None)
					D.SetTexture(GetTexture());
				else
					D.SetTexture(DebrisTexture);
				D.SetMomentum(Momentum);
			}
		}
	}
}


function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	ForEach AllActors(class 'Actor', A)
		if ( (A.Event == Tag) && (A.IsA('Trigger') || A.IsA('Polyobj')) )
		{
			if ( A.IsA('Counter') || A.IsA('Pawn') )
			{
				bPlayerOnly = true;
				return; //FIXME - handle counters
			}
			if (TriggerActor == None)
				TriggerActor = A;
			else if ( TriggerActor2 == None )
				TriggerActor2 = A;
		}

	if ( TriggerActor == None )
	{
		bPlayerOnly = (PolyObjBumpType == PBT_PlayerBump);
		return;
	}

	bPlayerOnly = ( TriggerActor.IsA('Trigger') && (Trigger(TriggerActor).TriggerType == TT_PlayerProximity) );
	if ( bPlayerOnly && ( TriggerActor2 != None) )
	{
		bPlayerOnly = ( TriggerActor2.IsA('Trigger') && (Trigger(TriggerActor).TriggerType == TT_PlayerProximity) );
		if ( !bPlayerOnly )
		{
			A = TriggerActor;
			TriggerActor = TriggerActor2;
			TriggerActor2 = A;
		}
	}
}

// set specialgoal/movetarget or special pause if necessary
// if mover can't be affected by this pawn, return false
// Each mover state should implement the appropriate version
function bool HandleDoor(pawn Other)
{
	return false;
}

function bool HandleTriggerDoor(pawn Other)
{
	local bool bOne, bTwo;
	local float DP1, DP2, Dist1, Dist2;

	if ( bOpening || bDelaying )
	{
		WaitingPawn = Other;
		Other.SpecialPause = 2.5;
		return true;
	}
	if ( bPlayerOnly && !Other.bIsPlayer )
		return false;
	if ( bUseTriggered )
	{
		WaitingPawn = Other;
		Other.SpecialPause = 2.5;
		Trigger(Other, Other);
		return true;
	}
	if ( (BumpEvent == tag) || (Other.bIsPlayer && (PlayerBumpEvent == tag)) )
	{
		WaitingPawn = Other;
		Other.SpecialPause = 2.5;
		if ( Other.Base == Self )
			Trigger(Other, Other);
		return true;
	}
	if ( bDamageTriggered )
	{
		WaitingPawn = Other;
		Other.SpecialGoal = self;
		if ( !Other.bCanDoSpecial || (Other.Weapon == None) )
			return false;

		Other.Target = self;
		Other.bShootSpecial = true;
		Trigger(Self, Other);
		Other.bFire = 0;
		Other.bAltFire = 0;
		return true;
	}

	if ( RecommendedTrigger != None )
	{
		Other.SpecialGoal = RecommendedTrigger;
		Other.MoveTarget = RecommendedTrigger;
		return True;
	}

	bOne = ( (TriggerActor != None) 
			&& (!TriggerActor.IsA('Trigger') || Trigger(TriggerActor).IsRelevant(Other)) );
	bTwo = ( (TriggerActor2 != None) 
			&& (!TriggerActor2.IsA('Trigger') || Trigger(TriggerActor2).IsRelevant(Other)) );
	
	if ( bOne && bTwo )
	{
		// Dotp, dist
		Dist1 = VSize(TriggerActor.Location - Other.Location);
		Dist2 = VSize(TriggerActor2.Location - Other.Location);
		if ( Dist1 < Dist2 )
		{
			if ( (Dist1 < 500) && Other.ActorReachable(TriggerActor) )
				bTwo = false;
		}
		else if ( (Dist2 < 500) && Other.ActorReachable(TriggerActor2) )
			bOne = false;
		
		if ( bOne && bTwo )
		{
			DP1 = Normal(Location - Other.Location) Dot (TriggerActor.Location - Other.Location)/Dist1;
			DP2 = Normal(Location - Other.Location) Dot (TriggerActor2.Location - Other.Location)/Dist2;
			if ( (DP1 > 0) && (DP2 < 0) )
				bOne = false;
			else if ( (DP1 < 0) && (DP2 > 0) )
				bTwo = false;
			else if ( Dist1 < Dist2 )
				bTwo = false;
			else 
				bOne = false;
		}
	}

	if ( bOne )
	{
		Other.SpecialGoal = TriggerActor;
		Other.MoveTarget = TriggerActor;
		return True;
	}
	else if ( bTwo )
	{
		Other.SpecialGoal = TriggerActor2;
		Other.MoveTarget = TriggerActor2;
		return True;
	}
	return false;
}

function Actor SpecialHandling(Pawn Other)
{
	if ( bDamageTriggered )	
	{
		if ( !Other.bCanDoSpecial || (Other.Weapon == None) )
			return None;

		Other.Target = self;
		Other.bShootSpecial = true;
//		Other.FireWeapon();
		Other.bFire = 0;
		Other.bAltFire = 0;
		return self;
	}

	if ( PolyObjBumpType == PBT_PlayerBump && !Other.bIsPlayer )
		return None;

	return self;
}

//-----------------------------------------------------------------------------
// Movement functions.
//-----------------------------------------------------------------------------

// Interpolate to keyframe KeyNum in Seconds time.
final function InterpolateTo( byte NewKeyNum, float Seconds )
{
	local Actor A;

	NewKeyNum = Clamp( NewKeyNum, 0, ArrayCount(KeyPos)-1 );
	if( NewKeyNum==PrevKeyNum && KeyNum!=PrevKeyNum )
	{
		// Reverse the movement smoothly.
		PhysAlpha = 1.0 - PhysAlpha;
		OldPos    = BasePos + KeyPos[KeyNum];
		OldRot    = BaseRot + KeyRot[KeyNum];
	}
	else
	{
		// Start a new movement.
		OldPos    = Location;
		OldRot    = Rotation;
		PhysAlpha = 0.0;
	}

	// Setup physics.
	SetPhysics(PHYS_MovingBrush);
	bInterpolating   = true;
	PrevKeyNum       = KeyNum;
	KeyNum			 = NewKeyNum;
	PhysRate         = 1.0 / FMax(Seconds, 0.005);

	ClientUpdate++;
	SimOldPos = OldPos;
	SimOldRotYaw = OldRot.Yaw;
	SimOldRotPitch = OldRot.Pitch;
	SimOldRotRoll = OldRot.Roll;
	SimInterpolate.X = 100 * PhysAlpha;
	SimInterpolate.Y = 100 * FMax(0.01, PhysRate);
	SimInterpolate.Z = 256 * PrevKeyNum + KeyNum;
	
	// Call events at each interpolation point	
	if(InterpolateEvent[PrevKeyNum] != 'None')
	{ // Call the event on this interpolation point
		foreach AllActors(class 'Actor', A, InterpolateEvent[PrevKeyNum])
		{
			A.Trigger(self, None);
		}
	}
}

// Set the specified keyframe.
final function SetKeyframe( byte NewKeyNum, vector NewLocation, rotator NewRotation )
{
	KeyNum         = Clamp( NewKeyNum, 0, ArrayCount(KeyPos)-1 );
	KeyPos[KeyNum] = NewLocation;
	KeyRot[KeyNum] = NewRotation;
}

// Interpolation ended.
function InterpolateEnd( actor Other )
{
	local byte OldKeyNum;
	local Actor A;

	OldKeyNum  = PrevKeyNum;
	PrevKeyNum = KeyNum;
	PhysAlpha  = 0;
	ClientUpdate--;

	// If more than two keyframes, chain them.
	if( KeyNum>0 && KeyNum<OldKeyNum )
	{
		// Chain to previous.
		InterpolateTo(KeyNum-1,MoveTime[KeyNum-1]);
	}
	else if( KeyNum<NumKeys-1 && KeyNum>OldKeyNum )
	{
		// Chain to next.
		InterpolateTo(KeyNum+1,MoveTime[KeyNum]);
	}
	else
	{
		// Call events at each interpolation point (end point)
		if(InterpolateEvent[PrevKeyNum] != 'None')
		{ // Call the event on this interpolation point
			foreach AllActors(class 'Actor', A, InterpolateEvent[PrevKeyNum])
			{
				A.Trigger(self, None);
			}
		}

		// Finished interpolating.
		AmbientSound = None;
		if ( (ClientUpdate == 0) && (Level.NetMode != NM_Client) )
		{
			RealPosition = Location;
			RealRotation = Rotation;
		}
	}
}

//-----------------------------------------------------------------------------
// Mover functions.
//-----------------------------------------------------------------------------

// Notify AI that mover finished movement
function FinishNotify()
{
	local Pawn P;

	if ( StandingCount > 0 )
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
			if ( P.Base == self )
			{
				P.StopWaiting();
				if ( (P.SpecialGoal == self) || (P.SpecialGoal == myMarker) )
					P.SpecialGoal = None; 
				if ( P == WaitingPawn )
					WaitingPawn = None;
			}

	if ( WaitingPawn != None )
	{
		WaitingPawn.StopWaiting();
		if ( (WaitingPawn.SpecialGoal == self) || (WaitingPawn.SpecialGoal == myMarker) )
			WaitingPawn.SpecialGoal = None; 
		WaitingPawn = None;
	}
}

// Handle when the mover finishes closing.
function FinishedClosing()
{
	// Update sound effects.
	PlaySound( ClosedSound, SLOT_None );

	// Notify our triggering actor that we have completed.
	if( SavedTrigger != None )
		SavedTrigger.EndEvent();
	SavedTrigger = None;
	Instigator = None;
	FinishNotify(); 
}

// Handle when the mover finishes opening.
function FinishedOpening()
{
	local actor A;

	// Update sound effects.
	PlaySound( OpenedSound, SLOT_None );
	
	// Trigger any chained movers.
//	FireEvent(Event);

	if(ThrustVector != vect(0, 0, 0))
	{
		foreach AllActors(class'Actor', A)
			if(A.Base == self)
				A.AddVelocity(ThrustVector);
	}

	FinishNotify();

}

// Open the mover.
function DoOpen()
{
	bOpening = true;
	bDelaying = false;
	
	InterpolateTo( 1, MoveTime[0] );	
	PlaySound( OpeningSound, SLOT_None );
	AmbientSound = MoveAmbientSound;
}

// Close the mover.
function DoClose()
{
	local actor A;

	bOpening = false;
	bDelaying = false;
	InterpolateTo( Max(0,KeyNum-1), MoveTime[Max(0, KeyNum-1)]);
	PlaySound( ClosingSound, SLOT_None );
//	FireEvent(Event);
	AmbientSound = MoveAmbientSound;
}

//===================================================================
//
// PolyobjDestroy
//
// Polyobjs aren't actually destroyed: they hidden, made non-blocking 
// and non-thinking.
//
// This function should be called instead of the Destroy();
//===================================================================

function PolyobjDestroy()
{
	local actor A;

	bHidden = true;
	bSweepable = false;
	SetCollision(false, false, false);
	Disable('Tick');
	SetTimer(0.0, false);

	if(StandingCount > 0)
	{
		foreach AllActors(class'Actor', A)
			if(A.Base == self)
			{
				A.SetBase(None);
			}
	}

	GotoState('');
}

//-----------------------------------------------------------------------------
// Engine notifications
//-----------------------------------------------------------------------------
// When mover enters gameplay.
simulated function BeginPlay()
{
	local rotator R;

	Enable('Tick');

	// timer updates real position every second in network play
	if ( Level.NetMode != NM_Standalone )
	{
		if ( Level.NetMode == NM_Client )
			settimer(4.0, true);
		else
			settimer(1.0, true);
		if ( Role < ROLE_Authority )
			return;
	}

	if ( Level.NetMode != NM_Client )
	{
		RealPosition = Location;
		RealRotation = Rotation;
	}

	// Init key info.
	Super.BeginPlay();
	KeyNum         = Clamp( KeyNum, 0, ArrayCount(KeyPos)-1 );
	PhysAlpha      = 0.0;

	// Set initial location.
	Move( BasePos + KeyPos[KeyNum] - Location );

	// Initial rotation.
	SetRotation( BaseRot + KeyRot[KeyNum] );

	// find movers in same group
	if ( ReturnGroup == '' )
		ReturnGroup = tag;
}

// Immediately after entering gameplay.
function PostBeginPlay()
{
	local polyobj M;

	//brushes can't be deleted, so if not relevant, make it invisible and non-colliding
	if ( !Level.Game.IsRelevant(self) )
	{
		SetCollision(false, false, false);
		SetLocation(Location + vect(0,0,20000)); // temp since still in bsp
		bHidden = true;
	}
	else
	{
		FindTriggerActor();
		// Initialize all slaves.
		if( !bSlave )
		{
			foreach AllActors( class 'Polyobj', M, Tag )
			{
				if( M.bSlave )
				{
					M.GotoState('');
					M.SetBase( Self );
				}
			}
		}
		if ( Leader == None )
		{	
			Leader = self;
			ForEach AllActors( class'Polyobj', M )
				if ( (M != self) && (M.ReturnGroup == ReturnGroup) )
				{
					M.Leader = self;
					M.Follower = Follower;
					Follower = M;
				}
		}
	}
}

simulated function Timer()
{
	if ( Velocity != vect(0,0,0) )
	{
		bClientPause = false;
		return;		
	}
	if ( Level.NetMode == NM_Client )
	{
		if ( ClientUpdate == 0 ) // not doing a move
		{
			if ( bClientPause )
			{
				if ( VSize(RealPosition - Location) > 3 )
					SetLocation(RealPosition);
				else
					RealPosition = Location;
				SetRotation(RealRotation);
				bClientPause = false;
			}
			else if ( RealPosition != Location )
				bClientPause = true;
		}
		else
			bClientPause = false;
	}
	else
	{
		RealPosition = Location;
		RealRotation = Rotation;
	}
}

function MakeGroupStop()
{
	// Stop moving immediately.
	bInterpolating = false;
	AmbientSound = None;
	GotoState( , '' );

	if ( Follower != None )
		Follower.MakeGroupStop();
}

function MakeGroupReturn()
{
	// Abort move and reverse course.
	bInterpolating = false;
	AmbientSound = None;
	if( KeyNum<PrevKeyNum )
		GotoState( , 'Open' );
	else
		GotoState( , 'Close' );

	if ( Follower != None )
		Follower.MakeGroupReturn();
}
		
// Return true to abort, false to continue.
function bool EncroachingOn( actor Other )
{
	local Pawn P;
	if ( Other.IsA('Carcass') || Other.IsA('Decoration') )
	{
		Other.JointDamaged(10000, Instigator, Other.Location, vect(0,0,0), 'Crushed', 0);
		return false;
	}
	if ( Other.IsA('Fragment') || (Other.IsA('Inventory') && (Other.Owner == None)) )
	{
		Other.Destroy();
		return false;
	}

	// Damage the encroached actor.
	if( EncroachDamage != 0 )
	{
		Other.JointDamaged( EncroachDamage, Instigator, Other.Location, vect(0,0,0), 'Crushed', 0);
	}

	// If we have a bump-player event, and Other is a pawn, do the bump thing.
	P = Pawn(Other);
	if( P!=None && P.bIsPlayer)
	{
		if ( PlayerBumpEvent!='' )
			Bump( Other );
		/*
		if ( (MyMarker != None) && (P.Base != self) 
			&& (P.Location.Z < MyMarker.Location.Z - P.CollisionHeight - 0.7 * MyMarker.CollisionHeight) )
			// pawn is under lift - tell him to move
		{
			P.UnderLift(self);
		}
		*/
	}

	// Stop, return, or whatever.
	if( PolyObjEncroachType == PET_StopWhenEncroach )
	{
		Leader.MakeGroupStop();
		return true;
	}
	else if( PolyObjEncroachType == PET_ReturnWhenEncroach )
	{
		Leader.MakeGroupReturn();
		return true;
	}
	else if( PolyObjEncroachType == PET_CrushWhenEncroach )
	{
		// Kill it.
		Other.KilledBy( Instigator );
		return false;
	}
	else if( PolyObjEncroachType == PET_IgnoreWhenEncroach )
	{
		// Ignore it.
		return false;
	}
}

// When bumped by player.
function Bump( actor Other )
{
	local actor A;
	local pawn  P;

	// Apply bump damage (if applicable)
	if(BumpDamage > 0)
	{
		Other.JointDamaged(BumpDamage, Other.Instigator, Other.Location, vect(0, 0, 0), 'blunt', 0);
	}

	P = Pawn(Other);
	if ( (PolyObjBumpType != PBT_AnyBump) && (P == None) )
		return;
	if ( (PolyObjBumpType == PBT_PlayerBump) && !P.bIsPlayer )
		return;
	if ( (PolyObjBumpType == PBT_PawnBump) && (Other.Mass < 10) )
		return;
	if((PolyObjBumpType == PBT_CreatureBump) && (Other.Mass < 10 || P.bIsPlayer))
		return; // RUNE:  Non-player pawn bump

	if( BumpEvent!='' )
		foreach AllActors( class 'Actor', A, BumpEvent )
			A.Trigger( Self, P );

	if ( P != None )
	{
		if( P.bIsPlayer && (PlayerBumpEvent!='') )
				foreach AllActors( class 'Actor', A, PlayerBumpEvent )
						A.Trigger( Self, P );

		if ( P.SpecialGoal == self )
			P.SpecialGoal = None;
	}
}

function bool UseTrigger(Actor Other)
{
	if ( bUseTriggered )
	{
		self.Trigger(self, Pawn(Other));
		return true;
	}
	return false;
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local bool bDamage;

	if ( bDamageTriggered && (Damage >= DamageThreshold) )
		self.Trigger(self, EventInstigator);

	if ( bDestroyable )
	{
		DamageThreshold -= Damage;
		if (DamageThreshold <= 0)
		{
			Explode(Momentum);
			PolyobjDestroy();
		}

/* Commented out so that all weapons will cause damage to all breakable objects -- cjr
		switch(DamageType)
		{
			case 'sever':		// Sword
				bDamage = (matter==MATTER_FLESH);
				break;
			case 'bluntsever':	// Axe
				bDamage = (matter==MATTER_FLESH || matter==MATTER_WOOD);
				break;
			case 'blunt':		// Hammer
				bDamage = (matter==MATTER_FLESH || matter==MATTER_WOOD || matter==MATTER_STONE);
				break;
			default:
				bDamage = false;
				break;
		}

		if (bDamage)
		{
			DamageThreshold -= Damage;
			if (DamageThreshold <= 0)
			{
				Explode(Momentum);
				PolyobjDestroy();
			}
		}
*/
	}

	return false;
}



//-----------------------------------------------------------------------------
// States
//-----------------------------------------------------------------------------
state() Rotating
{
	function BeginState()
	{
		if (!bInitiallyOn)
			bFixedRotationDir=False;
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		if (bInitiallyOn)
		{
			PlaySound( OpenedSound, SLOT_None );
			bFixedRotationDir=False;
			bInitiallyOn = false;
		}
		else
		{
			PlaySound( OpeningSound, SLOT_None );
			AmbientSound = MoveAmbientSound;
			bFixedRotationDir=True;
			bInitiallyOn = true;
		}
	}
Open:
Close:
}


state() Prop
{
	function BeginState()
	{
		if (!bInitiallyOn)
			Disable('Tick');

		foreach AllActors( class 'Actor', Target, CBaseName )
			CBase = Target;
		CRotator = Rotation;
		if(CSpeed < 0.01)
			CSpeed = 1.0;
	}

	function Tick(float deltaTime)
	{
		CRotator.roll += DeltaTime * 20000 * CSpeed;
		SetLocation(CBase.Location);
		SetRotation(CRotator + CBase.Rotation);
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		if (bInitiallyOn)
		{
			Disable('Tick');
			bInitiallyOn = false;
		}
		else
		{
			Enable('Tick');
			bInitiallyOn = true;
		}
	}
}

state() Smashing
{
	function BeginState()
	{
		if (!bInitiallyOn)
			Disable('Tick');

		CStartLocation = Location;
		CStartLocation.z -= CCUTOFF * CHeight;
		CTimeCounter = CPhase;
		CCycleTime = 2 * Pi / CCycleTime;
		CHeightVect = Vect( 0, 0, 0 );
		CHeightVect.z = CHeight;
		CPrevV = 0;
		if(CSpeed < 0.01)
			CSpeed = 1.0;
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		if (bInitiallyOn)
		{
			Disable('Tick');
			bInitiallyOn = false;
		}
		else
		{
			Enable('Tick');
			bInitiallyOn = true;
		}
	}

	function Tick( float DeltaTime )
	{
		local float v, v2;
		local vector PosVect;

		if(CDelay > 0.01)
		{
			CDelay -= DeltaTime;
			return;
		}
		CTimeCounter += DeltaTime;
		v = ( 1.0 + sin( CTimeCounter * CCycleTime ) ) / 2.0;
		v2 = v;
		if( v < CCUTOFF )
		{
			if( CPrevV >= CCUTOFF )
			{
				if( Event != '' )
				{
					foreach AllActors( class 'Actor', Target, Event )
						Target.Trigger( Self, None );
				}
				if( CSound != None )
				{
					PlaySound( CSound );
				}
			}
			v2 = CCUTOFF + ( CCUTOFF - v ) * 0.04;
		}
		else if ( CPrevV < CCUTOFF )
		{
			CDelay = CSpeed;
			CPrevV = CCUTOFF;
			return;
		}
		PosVect = CHeightVect * v2;
		CPrevV = v;
		SetLocation( CStartLocation + PosVect );
	}
}

state() Shaking
{
	function BeginState()
	{
		if (!bInitiallyOn)
			Disable('Tick');

		CRotator = Rotation;
		CTimeCounter = CPhase;
		CPulse = 0.0;
		if(CCycleTime < 0.01)
			CCycleTime = 1.0;
		if(CSpeed < 0.01)
			CSpeed = 1.0;
		if(CSize < 0.01)
			CSize = 1.0;
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		if (bInitiallyOn)
		{
			Disable('Tick');
			bInitiallyOn = false;
		}
		else
		{
			Enable('Tick');
			bInitiallyOn = true;
		}
		CPulse = CCycleTime;
	}

	function Tick(float deltaTime)
	{
		local float wScale;
		local rotator tRot;

		CPulse -= deltaTime;
		if(CPulse < 0.001)
		{
			SetRotation(CRotator);
			return;
		}

		wScale = CPulse/CCycleTime;

		CTimeCounter += deltaTime * (1.5-wScale);

		tRot.pitch = sin(CTimeCounter*19*CSpeed) * 900 * wScale *CSize;
		tRot.roll = sin(CTimeCounter*17*CSpeed) * 900 * wScale *CSize;
		tRot.yaw = 0.0;
		SetRotation(CRotator + tRot);
	}
}

state() Wobbling
{
	function BeginState()
	{
		if (!bInitiallyOn)
			Disable('Tick');
		if(CSize < 0.01)
			CSize = 1.0;
		CTimeCounter = CPhase;
		CStartLocation = Location;
		CRotator = Rotation;
		CRotator.pitch = CPhase;
		CRotator.yaw = CPhase;
		CRotator.roll = CPhase;
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		if (bInitiallyOn)
		{
			Disable('Tick');
			bInitiallyOn = false;
		}
		else
		{
			Enable('Tick');
			bInitiallyOn = true;
		}
	}

	function Tick(float deltaTime)
	{
		local vector wob;
		local float wScale;

		CTimeCounter += deltaTime;

		wob.x = sin( CTimeCounter * 2.0 );
		wob.y = sin( CTimeCounter * 3.0 );
		wob.z = sin( CTimeCounter * 4.0 );
		SetLocation( CStartLocation + (wob*70*CSize) );

		if(flag1)
			wScale = 1.6 + sin(CTimeCounter*2.5)*0.7;
		else
			wScale = 0.6;
		CRotator.pitch += deltaTime * 15000 * wScale;
		CRotator.yaw += deltaTime * 10000 * wScale;
		CRotator.roll += deltaTime * 18000 * wScale;
		SetRotation(CRotator);
	}
}

state() Splining
{
	function BeginState()
	{
		Disable('Tick');
		CTimeCounter = 0;
		if(CSize < 0.1)
			CSize = 1.0;
	}

	function Trigger(actor other, pawn eventInstigator)
	{
		local InterpolationPoint i;

		foreach AllActors(class 'InterpolationPoint', i, Event)
		{
			if(i.Position == 0)
			{ // Found a matching path
				//SetCollision(true, false, false);
				//bCollideWorld = False;
				Target = i;
				SetPhysics(PHYS_Interpolating);
				PhysRate = 1.0;
				PhysAlpha = 0.0;
				bInterpolating = true;
				//Enable('Tick');
				return;
			}
		}
	}

	function Tick(float deltaTime)
	{
	}
}

state() Sinker
{
	function BeginState()
	{
		OnMeCount = 0;
		CStartLocation = Location;
		CTimeCounter = FRand()*100;
		SinkResting = true;
	}

	function MakeOnMeList()
	{
		local int i, j;
		local Pawn p;

		OnMeCount = 0;
		for(i = 0; i < StandingCount; i++)
		{
			foreach RadiusActors(class'Pawn', p, 150)
			{
				if(p.Base == self)
				{
					//for(j = 0; j < OnMeCount; j++)
					//	if(p.Name == OnMeList[j].Name)
					//		continue;
					OnMeList[OnMeCount] = p;
					OnMeCount++;
				}
			}
			if(OnMeCount == 4)
				break;
		}

		//slog("OnMe Actors: " $ OnMeCount);
		//for(i = 0; i < OnMeCount; i++)
		//{
		//	slog("  name: " $ OnMeList[i].Name);
		//}

		if(OnMeCount == 0)
		{
			DesiredRotation = Rot(0,0,0);
			RotationRate = Rot(1000,1000,1000);
		}
	}

	event Attach(actor other)
	{
		MakeOnMeList();
	}

	event Detach(actor other)
	{
		MakeOnMeList();
	}

	event Tick(float deltaTime)
	{
		local vector pos;
		local vector onMe;
		local float xdiff, ydiff;
		local rotator dRot, tRot;
		local float wScale;

		CTimeCounter += deltaTime;
		if(OnMeCount > 0)
		{
			pos = vect(0,0,0);
			pos.z = -6*deltaTime;
			Move(pos);

			pos = Location;
			onMe = OnMeList[0].Location;
			drot.yaw = 0;
			xdiff = onMe.x - pos.x;
			ydiff = onMe.y - pos.y;
			drot.pitch = -xdiff*40;
			drot.roll = ydiff*40;
			DesiredRotation = dRot;
			RotationRate = Rot(4000,4000,4000);
			bRotateToDesired = true;
			SinkResting = false;
		}
		else if(SinkResting == true)
		{
			wScale = 0.5 + cos(CTimeCounter*2.5)*0.5;
			tRot.pitch = wScale*(sin(CTimeCounter*1.3)*275);
			wScale = 0.5 + sin(CTimeCounter*2.0)*0.5;
			tRot.roll = wScale*(cos(CTimeCounter*0.9)*290);
			tRot.yaw = 0.0;
			SetRotation(tRot);
			UpdateSinkerZ(deltaTime);
		}
		else
		{
			DesiredRotation = Rot(0, 0, 0);
			RotationRate = Rot(3000, 3000, 3000);
			if(Rotation == Rot(0, 0, 0))
			{
				SinkResting = true;
				bRotateToDesired = false;
			}
			UpdateSinkerZ(deltaTime);
		}
	}

	function UpdateSinkerZ(float deltaTime)
	{
		local vector pos;
		local float zDiff;

		pos = Location;
		zDiff = CStartLocation.z - pos.z;
		if(zDiff > 0)
		{
			pos.z += (1+FClamp(zDiff, 0, 30)*0.5)*deltaTime;
			SetLocation(pos);
		}
	}
}


// Triggering or doing damage to it destroys it based on DamageThreshold
State() Destructible
{
	function Trigger(actor other, pawn eventInstigator)
	{
		DamageThreshold = 0;
		Explode(vect(0,0,0));
		PolyobjDestroy();
	}

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{

		DamageThreshold -= Damage;
		if (DamageThreshold <= 0)
		{
			Explode(vect(0,0,0));
			PolyobjDestroy();
		}

/* Commented out so that all weapons will cause damage to all breakable objects -- cjr
		local bool bDamage;

		switch(DamageType)
		{
			case 'sever':		// Sword
				bDamage = (matter==MATTER_FLESH);
				break;
			case 'bluntsever':	// Axe
				bDamage = (matter==MATTER_FLESH || matter==MATTER_WOOD);
				break;
			case 'blunt':		// Hammer
				bDamage = (matter==MATTER_FLESH || matter==MATTER_WOOD || matter==MATTER_STONE);
				break;
			default:
				bDamage = false;
				break;
		}
		if (bDamage)
		{
			DamageThreshold -= Damage;
			if (DamageThreshold <= 0)
			{
				Explode(vect(0,0,0));
				PolyobjDestroy();
			}
		}
*/
	}
Open:
Close:
}



//-----------------------------------------------------------------------------
// Mover States
//-----------------------------------------------------------------------------


// When triggered, open, wait, then close.
state() TriggerOpenTimed
{
	function bool HandleDoor(pawn Other)
	{
		return HandleTriggerDoor(Other);
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		GotoState( 'TriggerOpenTimed', 'Open' );
	}

	function BeginState()
	{
		bOpening = false;
	}

Open:
	Disable( 'Trigger' );
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Sleep( StayOpenTime );
	if( bTriggerOnceOnly )
		GotoState('');
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Trigger' );
}

// Toggle when triggered.
state() TriggerToggle
{
	function bool HandleDoor(pawn Other)
	{
		return HandleTriggerDoor(Other);
	}
	
	function Trigger( actor Other, pawn EventInstigator )
	{
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		if( KeyNum==0 || KeyNum<PrevKeyNum )
			GotoState( 'TriggerToggle', 'Open' );
		else
			GotoState( 'TriggerToggle', 'Close' );
	}
Open:
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	if ( SavedTrigger != None )
		SavedTrigger.EndEvent();
	if( bTriggerOnceOnly )
		GotoState('');
	Stop;
Close:		
	DoClose();
	FinishInterpolation();
	FinishedClosing();
}

// Open when triggered, close when get untriggered.
state() TriggerControl
{
	function bool HandleDoor(pawn Other)
	{
		return HandleTriggerDoor(Other);
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		numTriggerEvents++;
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		GotoState( 'TriggerControl', 'Open' );
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		numTriggerEvents--;
		if ( numTriggerEvents <=0 )
		{
			numTriggerEvents = 0;
			SavedTrigger = Other;
			Instigator = EventInstigator;
			SavedTrigger.BeginEvent();
			GotoState( 'TriggerControl', 'Close' );
		}
	}

	function BeginState()
	{
		numTriggerEvents = 0;
	}

Open:
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	SavedTrigger.EndEvent();
	if( bTriggerOnceOnly )
		GotoState('');
	Stop;
Close:		
	DoClose();
	FinishInterpolation();
	FinishedClosing();
}

// Start pounding when triggered.
state() TriggerPound
{
	function bool HandleDoor(pawn Other)
	{
		return HandleTriggerDoor(Other);
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		numTriggerEvents++;
		SavedTrigger = Other;
		Instigator = EventInstigator;
		GotoState( 'TriggerPound', 'Open' );
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		numTriggerEvents--;
		if ( numTriggerEvents <= 0 )
		{
			numTriggerEvents = 0;
			SavedTrigger = None;
			Instigator = None;
			GotoState( 'TriggerPound', 'Close' );
		}
	}
	function BeginState()
	{
		numTriggerEvents = 0;
	}

Open:
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	Sleep(OtherTime);
Close:
	DoClose();
	FinishInterpolation();
	Sleep(StayOpenTime);
	if( bTriggerOnceOnly )
		GotoState('');
	if( SavedTrigger != None )
		goto 'Open';
}


// Open when bumped, wait, then close.
state() BumpOpenTimed
{
	function bool HandleDoor(pawn Other)
	{
		if ( (PolyObjBumpType == PBT_PlayerBump) && !Other.bIsPlayer )
			return false;

		Bump(Other);
		WaitingPawn = Other;
		Other.SpecialPause = 2.5;
		return true;
	}

	function Bump( actor Other )
	{
		// Apply bump damage (if applicable)
		if(BumpDamage > 0)
		{
			Other.JointDamaged(BumpDamage, Other.Instigator, Other.Location, vect(0, 0, 0), 'blunt', 0);
		}

		if ( (PolyObjBumpType != PBT_AnyBump) && (Pawn(Other) == None) )
			return;
		if ( (PolyObjBumpType == PBT_PlayerBump) && !Pawn(Other).bIsPlayer )
			return;
		if ( (PolyObjBumpType == PBT_PawnBump) && (Other.Mass < 10) )
			return;
		if((PolyObjBumpType == PBT_CreatureBump) && (Other.Mass < 10 || Pawn(Other).bIsPlayer))
			return; // RUNE:  Non-player pawn bump

		Global.Bump( Other );
		SavedTrigger = None;
		Instigator = Pawn(Other);
		GotoState( 'BumpOpenTimed', 'Open' );
	}
Open:
	Disable( 'Bump' );
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Sleep( StayOpenTime );
	if( bTriggerOnceOnly )
		GotoState('');
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Bump' );
}

// Open when bumped, close when reset.
state() BumpButton
{
	function bool HandleDoor(pawn Other)
	{
		if ( (PolyObjBumpType == PBT_PlayerBump) && !Other.bIsPlayer )
			return false;

		Bump(Other);
		return false; //let pawn try to move around this button
	}

	function Bump( actor Other )
	{
		// Apply bump damage (if applicable)
		if(BumpDamage > 0)
		{
			Other.JointDamaged(BumpDamage, None, Other.Location, vect(0, 0, 0), 'blunt', 0);
		}

		if ( (PolyObjBumpType != PBT_AnyBump) && (Pawn(Other) == None) )
			return;
		if ( (PolyObjBumpType == PBT_PlayerBump) && !Pawn(Other).bIsPlayer )
			return;
		if ( (PolyObjBumpType == PBT_PawnBump) && (Other.Mass < 10) )
			return;
		if((PolyObjBumpType == PBT_CreatureBump) && (Other.Mass < 10 || Pawn(Other).bIsPlayer))
			return; // RUNE:  Non-player pawn bump

		Global.Bump( Other );
		SavedTrigger = Other;
		Instigator = Pawn( Other );
		GotoState( 'BumpButton', 'Open' );
	}
	function BeginEvent()
	{
		bSlave=true;
	}
	function EndEvent()
	{
		bSlave     = false;
		Instigator = None;
		GotoState( 'BumpButton', 'Close' );
	}
Open:
	Disable( 'Bump' );
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	if( bTriggerOnceOnly )
		GotoState('');
	if( bSlave )
		Stop;
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Bump' );
}


// Open when stood on, wait, then close.
state() StandOpenTimed
{
	function bool HandleDoor(pawn Other)
	{
		if ( bPlayerOnly && !Other.bIsPlayer )
			return false;
		Other.SpecialPause = 2.5;
		WaitingPawn = Other;
		if ( Other.Base == self )
			Attach(Other);
		return true;
	}

	function Attach( actor Other )
	{
		local pawn  P;

		P = Pawn(Other);
		if ( (PolyObjBumpType != PBT_AnyBump) && (P == None) )
			return;
		if ( (PolyObjBumpType == PBT_PlayerBump) && !P.bIsPlayer )
			return;
		if ( (PolyObjBumpType == PBT_PawnBump) && (Other.Mass < 10) )
			return;
		if((PolyObjBumpType == PBT_CreatureBump) && (Other.Mass < 10 || P.bIsPlayer))
			return; // RUNE:  Non-player pawn bump

		SavedTrigger = None;
		GotoState( 'StandOpenTimed', 'Open' );
	}
Open:
	Disable( 'Attach' );
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Sleep( StayOpenTime );
	if( bTriggerOnceOnly )
		GotoState('');
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Attach' );
}

defaultproperties
{
     PolyObjEncroachType=PET_ReturnWhenEncroach
     PolyObjGlideType=PGT_GlideByTime
     NumKeys=2
     MoveTime(0)=1.000000
     MoveTime(1)=1.000000
     MoveTime(2)=1.000000
     MoveTime(3)=1.000000
     MoveTime(4)=1.000000
     MoveTime(5)=1.000000
     MoveTime(6)=1.000000
     MoveTime(7)=1.000000
     MoveTime(8)=1.000000
     MoveTime(9)=1.000000
     MoveTime(10)=1.000000
     MoveTime(11)=1.000000
     MoveTime(12)=1.000000
     MoveTime(13)=1.000000
     MoveTime(14)=1.000000
     MoveTime(15)=1.000000
     StayOpenTime=4.000000
     matter=MATTER_STONE
     NumDebrisChunks=10
     bStatic=False
     bIsMover=True
     bAlwaysRelevant=True
     Physics=PHYS_MovingBrush
     RemoteRole=ROLE_SimulatedProxy
     InitialState=BumpOpenTimed
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bSweepable=True
     NetPriority=2.700000
}
