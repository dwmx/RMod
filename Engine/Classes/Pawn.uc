//=============================================================================
// Pawn.
//=============================================================================

class Pawn extends Actor
	abstract
	native;
//	nativereplication;

#exec Texture Import File=Textures\Pawn.pcx Name=S_Pawn Mips=Off Flags=2

// Pawn Variables -------------------------------------------------------------

enum ESpeedScale
{
	SS_Circular,
	SS_Elliptical,
	SS_Other,
};

var() class<carcass> CarcassType;

// General flags.
var bool		bBehindView;    // Outside-the-player view.
var bool        bIsPlayer;      // Pawn is a player or a player-bot.
var bool		bJustLanded;	// used by eyeheight adjustment
var bool		bUpAndOut;		// used by swimming
var bool		bIsWalking;
var const bool	bHitSlopedWall;	// used by Physics
var globalconfig bool	bNeverSwitchOnPickup;	// if true, don't automatically switch to picked up weapon
var bool		bWarping;		// Set when travelling through warpzone (so shouldn't telefrag)
var bool		bUpdatingDisplay; // to avoid infinite recursion through inventory setdisplay

// AI flags
var(Combat) bool	bCanStrafe;			//can move in different directions than current rotation
var(Orders) bool	bFixedStart;
var const bool		bReducedSpeed;		//used by movement natives
var		bool		bCanJump;
var		bool 		bCanWalk;
var		bool		bCanSwim;
var		bool		bCanFly;
var		bool		bCanOpenDoors;
var		bool		bCanDoSpecial;
var		bool		bDrowning;
var const bool		bLOSflag;			// used for alternating LineOfSight traces
var 	bool 		bFromWall;
var		bool		bHunting;			// tells navigation code that pawn is hunting another pawn,
										//	so fall back to finding a path to a visible pathnode if none
										//	are reachable
var		bool		bAvoidLedges;		// don't get too close to ledges
var		bool		bStopAtLedges;		// if bAvoidLedges and bStopAtLedges, Pawn doesn't try to walk along the edge at all
var		bool		bJumpOffPawn;
var		bool		bShootSpecial;
var		bool		bAutoActivate;
var		bool		bIsHuman;			// for games which care about whether a pawn is a human
var		bool		bIsFemale;
var		bool		bIsMultiSkinned;
var		bool		bCountJumps;
var		bool		bAdvancedTactics;	// used during movement between pathnodes
var		bool		bViewTarget;

var()	bool		bCanGrabEdges;		// Can grab edges: bCanStrafe must also be set to true
var()	bool		bAlignToFloor;		// RUNE:  Align this pawn to the floor below it (only when in PHYS_Walking)

// Ticked pawn timers
var		float		SightCounter;	//Used to keep track of when to check player visibility
var		float       PainTime;		//used for getting PainTimer() messages (for Lava, no air, etc.)
var		float		SpeechTime;	
var		float		AmbientSoundTime;	// Used to generate ambient sound events

// Physics updating time monitoring (for AI monitoring reaching destinations)
var const	float		AvgPhysicsTime;

// Additional pawn region information.
var PointRegion FootRegion;
var PointRegion HeadRegion;

// Navigation AI
var 	float		MoveTimer;
var 	Actor		MoveTarget;		// set by movement natives
var		Actor		FaceTarget;		// set by strafefacing native
var		vector	 	Destination;	// set by Movement natives
var	 	vector		Focus;			// set by Movement natives
var		float		DesiredSpeed;
var		float		MaxDesiredSpeed;
var(Combat) float	MeleeRange; // Max range for melee attack (not including collision radii)

var(Combat) float	CombatRange; // RUNE:  Range the creature tries to stay within during his fighting state
								 // CombatRange is usually further than meleerange (which is the range in which he actually can attack)
var bool bStopMoveIfCombatRange; // RUNE:  a moveToward latent function will exit if the enemy is within CombatRange

// Player and enemy movement.
var(Movement) float		GroundSpeed;	// The maximum ground speed.
var(Movement) float		WaterSpeed;		// The maximum swimming speed.
var(Movement) float		AirSpeed;		// The maximum flying speed.
var(Movement) float		AccelRate;		// max acceleration rate
var(Movement) float		JumpZ;      	// vertical acceleration w/ jump
var(Movement) float		MaxStepHeight;	// Maximum size of upward/downward step.
var(Movement) float		AirControl;		// amount of AirControl available to the pawn
var(Movement) float		WalkingSpeed;	// RUNE:  Speed creature walks
var float				MovementSpeed;	// RUNE:  Current speed modifier 0..1 (Set by UpdateMovementSpeed())
var bool				bHurrying;		// RUNE:  Whether running or walking

var ESpeedScale SpeedScale;				// RUNE:  Handles the movement type (circular, elliptical, etc)
var int					ClassID;			// ID determining same family of creatures

// AI basics.
var	 	float		MinHitWall;		// Minimum HitNormal dot Velocity.Normal to get a HitWall from the
									// physics
var() 	byte       	Visibility;      //How visible is the pawn? 0 = invisible. 
									// 128 = normal.  255 = highly visible.
var		float		Alertness; // -1 to 1 ->Used within specific states for varying reaction to stimuli 
var		float 		Stimulus; // Strength of stimulus - Set when stimulus happens, used in Acquisition state 
var(AI) float		SightRadius;     //Maximum seeing distance.
var(AI) float		PeripheralVision;	//Cosine of limits of peripheral vision. (-1..1)
var(AI) float		HearingThreshold;  //Minimum noise loudness for hearing
var		vector		LastSeenPos; 		// enemy position when I last saw enemy (auto updated if EnemyNotVisible() enabled)
var		vector		LastSeeingPos;		// position where I last saw enemy (auto updated if EnemyNotVisible enabled)
var		float		LastSeenTime;
var	 	Pawn    	Enemy;

// Player info.
var travel Weapon       Weapon;			// The pawn's current weapon.
var travel Shield		Shield;			// The pawn's current shield
var Weapon				PendingWeapon;	// Will become weapon once current weapon is put down
var travel Inventory	SelectedItem;	// currently selected inventory item
var name				StartEvent;		// Event of PlayerStart (temp storage)
var int					CurrentSkin;	// Index of skin currently being used

// Movement.
var rotator     	ViewRotation;  	// View rotation.
var vector			ViewLocation;	// RUNE: To cache camera location for PlayerCanSeeMe()
var vector			WalkBob;
var() float      	BaseEyeHeight; 	// Base eye height above collision center.
var float        	EyeHeight;     	// Current eye height, adjusted for bobbing and stairs.
var	const	vector	Floor;			// Normal of floor pawn is standing on (only used
									//	by PHYS_Spider)
var float			SplashTime;		// time of last splash

var vector GrabLocationUp; // RUNE:  Pull-up location of grab
var vector GrabLocationIn; // RUNE:  Push-in location of grab

// View
var float        OrthoZoom;     // Orthogonal/map view zoom factor.
var() float      FovAngle;      // X field of view angle in degrees, usually 90.

// Player game statistics.
var int			DieCount, ItemCount, KillCount, SecretCount, Spree;

// Pawn Attributes
var() travel int	Health;				// Health:
var() travel int	Strength;			// RUNE:  Strength damage modifier
var() travel int	RunePower;			// RUNE:  Current amount of RunePower
var() travel int	MaxHealth;			// RUNE:  Maximum health: 100 = normal
var() travel int	MaxStrength;		// RUNE:  Maximum strength, 100 = normal
var() travel int	MaxPower;			// RUNE:  Maximum power.  100 = normal

var() int BodyPartHealth[15];			// RUNE:  Health of bodyparts
var() int GibCount;						// RUNE:  Number of normal gibs to spew out
var() class<Debris> GibClass;			// RUNE:  Gib to spew out
var() float	PainDelay;					// RUNE:  Time to delay when in the pain state (if negative, does a FinishAnim())
var() bool bGibbable;					// RUNE:  Can be gibbed
var bool bInvisible;					// RUNE:  Pawn is invisible to others

// Selection Mesh
var() string			SelectionMesh;
var() string			SpecialMesh;

// Inherent Armor (for creatures).
var() name	ReducedDamageType; //Either a damagetype name or 'All', 'AllEnvironment' (Burned, Corroded, Frozen)
var() float ReducedDamagePct;

// Inventory to drop when killed (for creatures)
var() class<inventory> DropWhenKilled;

// Zone pain
var(Movement) float		UnderWaterTime;  	//how much time pawn can go without air (in seconds)

var(AI) enum EAttitude  //important - order in decreasing importance
{
	ATTITUDE_Fear,		//will try to run away
	ATTITUDE_Hate,		// will attack enemy
	ATTITUDE_Frenzy,	//will attack anything, indiscriminately
	ATTITUDE_Threaten,	// animations, but no attack
	ATTITUDE_Ignore,
	ATTITUDE_Friendly,
	ATTITUDE_Follow 	//accepts player as leader
} AttitudeToPlayer;	//determines how creature will react on seeing player (if in human form)

var(AI) enum EIntelligence //important - order in increasing intelligence
{
	BRAINS_NONE, //only reacts to immediate stimulus
	BRAINS_REPTILE, //follows to last seen position
	BRAINS_MAMMAL, //simple navigation (limited path length)
	BRAINS_HUMAN   //complex navigation, team coordination, use environment stuff (triggers, etc.)
}	Intelligence;

var(AI) float		Skill;			// skill, scaled by game difficulty (add difficulty to this value)	
var		actor		SpecialGoal;	// used by navigation AI
var		float		SpecialPause;

// Sound and noise management
var const 	vector 		noise1spot;
var const 	float 		noise1time;
var const	pawn		noise1other;
var const	float		noise1loudness;
var const 	vector 		noise2spot;
var const 	float 		noise2time;
var const	pawn		noise2other;
var const	float		noise2loudness;
var			float		LastPainSound;

// chained pawn list
var const	pawn		nextPawn;

// Common sounds
var(Sounds)	sound	HitSound1;
var(Sounds)	sound	HitSound2;
var(Sounds) sound	HitSound3;
var(Sounds)	sound	Die;
var(Sounds) sound	Die2;
var(Sounds) sound	Die3;
var(Sounds) sound	WaterStep;
var(Sounds) sound	GibSound;
//var(Sounds)	sound	Land;
var(Sounds) float	FootstepVolume;

var(Sounds) sound	LandGrunt;
var(Sounds) sound	FootStepWood[3];
var(Sounds) sound	FootStepMetal[3];
var(Sounds) sound	FootStepStone[3];
var(Sounds) sound	FootStepFlesh[3];
var(Sounds) sound	FootStepIce[3];
var(Sounds) sound	FootStepEarth[3];
var(Sounds) sound	FootStepSnow[3];
var(Sounds) sound	FootStepBreakableWood[3];
var(Sounds) sound	FootStepBreakableStone[3];
var(Sounds) sound	FootStepWater[3];
var(Sounds) sound	FootStepMud[3];
var(Sounds) sound	FootStepLava[3];
var(Sounds) sound	LandSoundWood;
var(Sounds) sound	LandSoundMetal;
var(Sounds) sound	LandSoundStone;
var(Sounds) sound	LandSoundFlesh;
var(Sounds) sound	LandSoundIce;
var(Sounds) sound	LandSoundSnow;
var(Sounds) sound	LandSoundEarth;
var(Sounds) sound	LandSoundBreakableWood;
var(Sounds) sound	LandSoundBreakableStone;
var(Sounds) sound	LandSoundWater;
var(Sounds) sound	LandSoundMud;
var(Sounds) sound	LandSoundLava;

// Input buttons.
var input byte
	bZoom, bRun, bLook, bDuck, bSnapLevel,
	bStrafe, bFire, bAltFire, bFreeLook,
	bExtra0, bExtra1, bExtra2, bExtra3;

var(Combat) float CombatStyle; // -1 to 1 = low means tends to stay off and snipe, high means tends to charge and melee
//var NavigationPoint home; //set when begin play, used for retreating and attitude checks

var name NextState; //for queueing states
var name NextLabel; //for queueing states
var name NextStateAfterPain;

var float SoundDampening;
var float DamageScaling;

var Name PlayerReStartState;

var() localized  string MenuName; //Name used for this pawn type in menus (e.g. player selection) 
var() localized  string NameArticle; //article used in conjunction with this class (e.g. "a", "an")

var() byte VoicePitch; //for speech
var() string VoiceType; //for speech
var float OldMessageTime; //to limit frequency of voice messages

var(Skeleton) name		WeaponJoint;		// Name of weapon attachment joint
var(Skeleton) name		ShieldJoint;		// Name of weapon attachment joint

var(Skeleton) name		StabJoint;			// RUNE:  Name of joint a weapon can be stuck into the actor
 
// Route Cache for Navigation
var NavigationPoint RouteCache[16];

// Replication Info
var() class<PlayerReplicationInfo> PlayerReplicationInfoClass;
var PlayerReplicationInfo PlayerReplicationInfo;

// shadow decal
var Decal Shadow;


// ** Stuff added for RUNE (don't cull) **

var(Look) bool bCanLook;		// Pawn has base_ joints..  can look around
var(Look) rotator MaxBodyAngle;	// Max angles on each axis for body turning
var(Look) rotator MaxHeadAngle;	// Max angles on each axis for head turning
var(Look) bool bRotateHead;
var(Look) bool bRotateTorso;	// Torso turns during look
var(Look) bool bHeadLookUpDouble; // RUNE:  Allow the head to look up double the MaxHeadAngle Pitch
var(Look) float LookDegPerSec;	// Degrees/Second velocity for turning to look
var actor LookTarget;			// Actor pawn is interested in
var vector LookSpot;			// Position pawn is interested in
var rotator LookAngle;			// Angle currently looking
var rotator targetangle;		// Only used when bOverrideLookTarget
var bool bOverrideLookTarget;	// Use existing targetangle for looking

var int MouthRot;
var int DesiredMouthRot;
var int MouthRotRate;
var(Look) int MaxMouthRot;			// 16000 for goblin
var(Look) int MaxMouthRotRate;		// 65535 for goblin

// Footsteps
var(Footsteps) class<Decal>	FootprintClass;
var(Footsteps) class<Decal>	WetFootprintClass;
var(Footsteps) class<Decal>	BloodyFootprintClass;
var(Footsteps) int			LFootJoint;
var(Footsteps) int			RFootJoint;
var(Footsteps) bool			bFootsteps;
var int						WaterSteps;
var int						BloodSteps;

var bool bSwingingHigh;				// Currently swinging high (used to warn targets)
var bool bSwingingLow;				// Currently swinging low

var(Collision) float DeathRadius;	// Collision Radius upon death
var(Collision) float DeathHeight;	// Collision Height upon death
var(Collision) bool bAllowStandOn;	// Allow actors to stand on top of instead of throwing off

var(Combat) bool bLeadEnemy;		// Actor will lead the enemy when charging, instead of charging straight at them

var name UninterruptedAnim;			// RUNE: Used specifically in the Uninterrupted state
var Actor UseActor;					// RUNE: Used by Use functionality
var() localized  string SkinDefaultText;	//Text describing Default Skin

event ShadowUpdate(int ShadowType); // RUNE:  Update shadow



//------------------------------------------------------------
//
// PreBeginPlay
//
// Called immediately before gameplay begins.
//------------------------------------------------------------
event PreBeginPlay()
{
	AddPawn();
	Super.PreBeginPlay();
	if ( bDeleteMe )
		return;

	// Set instigator to self.
	Instigator = Self;
	DesiredRotation = Rotation;
	SightCounter = 0.2 * FRand();  //offset randomly 
	if ( Level.Game != None )
		Skill += Level.Game.Difficulty; 
	Skill = FClamp(Skill, 0, 3);
	PreSetMovement();
	
	if ( DrawScale != Default.Drawscale )
	{
		// Collision moved to actor
		//SetCollisionSize(CollisionRadius*DrawScale/Default.DrawScale, CollisionHeight*DrawScale/Default.DrawScale);
		Health = Health * DrawScale/Default.DrawScale;
		GroundSpeed = GroundSpeed * DrawScale/Default.DrawScale;
	}
	
	if (bIsPlayer)
	{
		if (PlayerReplicationInfoClass != None)
			PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
		else
			PlayerReplicationInfo = Spawn(class'PlayerReplicationInfo', Self,,vect(0,0,0),rot(0,0,0));
		InitPlayerReplicationInfo();

		switch(Level.Game.Difficulty)
		{
			case 0:
				UnderWaterTime *= 3;
				break;
			case 1:
				UnderWaterTime *= 2;
				break;
			case 2:
			default:
				break;
		}
	}

	if (!bIsPlayer) 
	{
		if ( BaseEyeHeight == 0 )
			BaseEyeHeight = 0.8 * CollisionHeight;
		EyeHeight = BaseEyeHeight;
		if (Fatness == 0) //vary monster fatness slightly if at default
			Fatness = 120 + Rand(8) + Rand(8);
	}

	if ( menuname == "" )
		menuname = GetItemName(string(class));

	if (SelectionMesh == "")
		SelectionMesh = string(Skeletal);
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	SplashTime = 0;
}

// called after PostBeginPlay on net client
event PostNetBeginPlay()
{
	if ( Role != ROLE_SimulatedProxy )
		return;
/*	if ( bIsMultiSkinned && bIsPlayer )
	{
		if ( MultiSkins[0] == None )
		{
			if ( bIsPlayer )
				SetMultiSkin(self, "","", PlayerReplicationInfo.team);
			else
				SetMultiSkin(self, "","", 0);
		}
	}
	else if ( Skin == None )
		Skin = Default.Skin;
*/

	if ( (PlayerReplicationInfo != None) 
		&& (PlayerReplicationInfo.Owner == None) )
		PlayerReplicationInfo.SetOwner(self);
}


//=============================================================================
// Network related
//=============================================================================

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		Weapon, PlayerReplicationInfo, Health, bCanFly,
		MaxHealth, MaxStrength, MaxPower, Strength, RunePower;
	reliable if( bNetOwner && Role==ROLE_Authority )
		bIsPlayer, SelectedItem,
		GroundSpeed, WaterSpeed, AirSpeed, AccelRate, JumpZ, AirControl,
		PlayerRestartState,
		CurrentSkin,
		SpeedScale;
	unreliable if( (bNetOwner && bIsPlayer && bNetInitial && Role==ROLE_Authority) || bDemoRecording )
		ViewRotation;
	unreliable if( bNetOwner && Role==ROLE_Authority )
        MoveTarget;

	reliable if( bDemoRecording )
		EyeHeight;

	// Functions the server calls on the client side.
	reliable if( RemoteRole==ROLE_AutonomousProxy ) 
		ClientDying, ClientReStart, ClientGameEnded, ClientSetRotation, ClientSetLocation, ClientPutDown;
	unreliable if( (!bDemoRecording || bClientDemoRecording && bClientDemoNetFunc) && Role==ROLE_Authority )
		ClientHearSound;
	reliable if ( (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc)) && Role == ROLE_Authority )
		ClientVoiceMessage;
	reliable if ( (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc) || (Level.NetMode==NM_Standalone && IsA('PlayerPawn'))) && Role == ROLE_Authority )
		ClientMessage, TeamMessage, ReceiveLocalizedMessage;

	// Functions the client calls on the server.
	unreliable if( Role<ROLE_Authority )
		SendVoiceMessage, NextItem, SwitchToBestWeapon, TeamBroadcast;

	// RUNE:
	unreliable if ( Role==ROLE_Authority )
		bCanLook, bRotateHead, bRotateTorso, bAlignToFloor, Shield;
}

function InitPlayerReplicationInfo()
{
	if (PlayerReplicationInfo.PlayerName == "")
		PlayerReplicationInfo.PlayerName = class'GameInfo'.Default.DefaultPlayerName;
}

simulated event Destroyed()
{
	local Inventory Inv, nextInv;
	local Pawn OtherPawn;

	if ( Shadow != None )
		Shadow.Destroy();
	if ( Role < ROLE_Authority )
		return;

	RemovePawn();

	for(Inv = Inventory; Inv != None; Inv = nextInv)
	{
		nextInv = Inv.Inventory;
		Inv.Destroy();
	}

	Weapon = None;
	Shield = None;
	Inventory = None;
	if ( bIsPlayer && (Level.Game != None) )
		Level.Game.logout(self);
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.Destroy();

	for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
		OtherPawn.Killed(None, self, '');

	Super.Destroyed();
}

event PlayerTimeOut()
{
	if (Health > 0)
		Died(None, 'suicided', Location);
}


//=============================================================================
// Messaging functions
//=============================================================================

event ClientMessage( coerce string S, optional name Type, optional bool bBeep );
event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep );
event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject );

function BecomeViewTarget()
{
	bViewTarget = true;
}

function HandleHelpMessageFrom(Pawn Other);

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID);
function BotVoiceMessage(name messagetype, byte MessageID, Pawn Sender);

function string KillMessage( name damageType, pawn Other )
{
	local string message;

	message = Level.Game.CreatureKillMessage(damageType, Other);
	return (Other.PlayerReplicationInfo.PlayerName$message$namearticle$menuname);
}

//------------------------------------------------------------------------------
// Speech related

function SendGlobalMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'GLOBAL');
}


function SendTeamMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'TEAM');
}

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
	local Pawn P;
	local bool bNoSpeak;

	if ( Level.TimeSeconds - OldMessageTime < 2.5 )
		bNoSpeak = true;
	else
		OldMessageTime = Level.TimeSeconds;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if ( P.IsA('PlayerPawn') )
		{  
			if ( !bNoSpeak )
			{
				if ( (broadcasttype == 'GLOBAL') || !Level.Game.bTeamGame )
					P.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
				else if ( Sender.Team == P.PlayerReplicationInfo.Team )
					P.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
			}
		}
		else if ( (P.PlayerReplicationInfo == Recipient) || ((messagetype == 'ORDER') && (Recipient == None)) )
			P.BotVoiceMessage(messagetype, messageID, self);
	}
}



// Broadcast a text message to all players, or all on the same team.
function TeamBroadcast( coerce string Msg)
{
	local Pawn P;
	local bool bGlobal;

	if ( Left(Msg, 1) ~= "@" )
	{
		Msg = Right(Msg, Len(Msg)-1);
		bGlobal = true;
	}

	if ( Left(Msg, 1) ~= "." )
		Msg = "."$VoicePitch$Msg;

	if ( bGlobal || !Level.Game.bTeamGame )
	{
		if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
			for( P=Level.PawnList; P!=None; P=P.nextPawn )
				if( P.bIsPlayer  || P.IsA('MessagingSpectator') )
					P.TeamMessage( PlayerReplicationInfo, Msg, 'Say' );
		return;
	}
		
	if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
			if( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
			{
				if ( P.IsA('PlayerPawn') )
					P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay' );
			}
}


//=============================================================================
// Client-side functions
//=============================================================================

function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	local Pawn P;

	ViewRotation      = NewRotation;
	If ( (ViewRotation.Pitch > RotationRate.Pitch) && (ViewRotation.Pitch < 65536 - RotationRate.Pitch) )
	{
		If (ViewRotation.Pitch < 32768) 
			NewRotation.Pitch = RotationRate.Pitch;
		else
			NewRotation.Pitch = 65536 - RotationRate.Pitch;
	}
	NewRotation.Roll  = 0;
	SetRotation( NewRotation );
	SetLocation( NewLocation );
}

function ClientSetRotation( rotator NewRotation )
{
	local Pawn P;

	ViewRotation      = NewRotation;
	NewRotation.Pitch = 0;
	NewRotation.Roll  = 0;
	SetRotation( NewRotation );
}

native simulated event ClientHearSound ( 
	actor Actor, 
	int Id, 
	sound S, 
	vector SoundLocation, 
	vector Parameters 
);

function ClientDying(name DamageType, vector HitLocation)
{
	PlayDying(DamageType, HitLocation);
	GotoState('Dying');
}

function ClientReStart()
{
//	local rotator r;

	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	BaseEyeHeight = Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;

//	r = Rotation;
//	r.Pitch = 0;
//	r.Roll = 0;
//	SetRotation(r);

	// Reset cache to idle pose, then actually play it since, reset sets it back for next frame
	ResetAnimationCache('neutral_idle');
	LoopAnim('neutral_idle', 1.0, 0.0);
	if (AnimProxy != None)
		AnimProxy.LoopAnim('neutral_idle', 1.0, 0.0);

	if ( Region.Zone.bWaterZone && (PlayerRestartState == 'PlayerWalking') )
	{
		if (HeadRegion.Zone.bWaterZone)
			PainTime = UnderWaterTime;
		setPhysics(PHYS_Swimming);
		GotoState('PlayerSwimming');
	}
	else
		GotoState(PlayerReStartState);
}

function ClientGameEnded()
{
	GotoState('GameEnded');
}




//=============================================================================
// Latent Movement.
//=============================================================================

//Note that MoveTo sets the actor's Destination, and MoveToward sets the
//actor's MoveTarget.  Actor will rotate towards destination

native(500) final latent function MoveTo( vector NewDestination, optional float speed);
native(502) final latent function MoveToward(actor NewTarget, optional float speed);
native(504) final latent function StrafeTo(vector NewDestination, vector NewFocus);
native(506) final latent function StrafeFacing(vector NewDestination, actor NewTarget);
native(508) final latent function TurnTo(vector NewFocus);
native(510) final latent function TurnToward(actor NewTarget);


//=============================================================================
// AI functions
//=============================================================================

// LineOfSightTo() returns true if any of several points of Other is visible (origin, top, bottom)
native(514) final function bool LineOfSightTo(actor Other); 

// CanSee() similar to line of sight, but also takes into account Pawn's peripheral vision
native(533) final function bool CanSee(actor Other); 
native(518) final function Actor FindPathTo(vector aPoint, optional bool bSinglePath, 
												optional bool bClearPaths);
native(517) final function Actor FindPathToward(actor anActor, optional bool bSinglePath, 
												optional bool bClearPaths);

// returns a random pathnode which is reachable from the creature's location
native(525) final function NavigationPoint FindRandomDest(optional bool bClearPaths);

// clear all temporary path variables used in routing
native(522) final function ClearPaths();

native(523) final function vector EAdjustJump();

//Reachable returns what part of direct path from Actor to aPoint is traversable
//using the current locomotion method
native(521) final function bool pointReachable(vector aPoint);
native(520) final function bool actorReachable(actor anActor);

native(664) final function NavigationPoint NearestNavPoint();
native(665) final function NavigationPoint CloserNavPointTo(actor Other);

final function Actor FindPathAwayFrom(actor anActor, optional actor justvisited)
{
	local float distsquared, furthestdistsquared;
	local NavigationPoint N;
	local actor A, furthestpoint;
	local vector topoint;
	local int i, numpaths;

	N = NearestNavPoint();
	if (N == None)
		return N;

	numpaths = N.NumPaths();
	for (i=0; i<numpaths; i++)
	{
		A = N.PathEndPoint(i);
		if (A == justvisited)
			continue;
		topoint = A.Location - anActor.Location;
		distsquared = topoint dot topoint;
		if (distsquared > furthestdistsquared)
		{
			furthestdistsquared = distsquared;
			furthestpoint = A;
		}
	}
	return furthestpoint;
}

//------------------------------------------------
//
// FindBestPathToward
//
// Assumes the desired destination is not directly reachable, 
// it tries to set Destination to the location of the best
// waypoint, and returns true if successful
//------------------------------------------------
function bool FindBestPathToward(actor desired)
{
	local Actor path;
	local bool success;
	
	path = None;
	if (Intelligence <= BRAINS_Reptile)
		path = FindPathToward(desired, true);
	else 
		path = FindPathToward(desired); 
		
	success = (path != None);
	if (success)
	{
		MoveTarget = path; 
		Destination = path.Location;
	}
//slog("findbestpathtoward"@desired.name@"="$success);
	return success;
}


//------------------------------------------------------------
//
// PickWallAdjust()
//
// Check if could jump up over obstruction (only if there is a knee height obstruction)
// If so, start jump, and return current destination
// Else, try to step around - return a destination 90 degrees right or left depending on traces
// out and floor checks
//------------------------------------------------------------
native(526) final function bool PickWallAdjust();
native(524) final function int FindStairRotation(float DeltaTime);

// Wait until physics is not PHYS_Falling
native(527) final latent function WaitForLanding();

native(540) final function actor FindBestInventoryPath(out float MinWeight, bool bPredictRespawns);

native(529) final function AddPawn();
native(530) final function RemovePawn();

// Pick best pawn target
native(531) final function pawn PickTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart);
native(534) final function actor PickAnyTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart);

native(535) final function vector FindWaterLine(vector Start, vector End); // RUNE

// Force end to sleep
native function StopWaiting();


//=============================================================================
// Display
//=============================================================================

simulated event RenderOverlays( canvas Canvas )
{
	if ( Weapon != None )
		Weapon.RenderOverlays(Canvas);
}

/*
static function SetMultiSkin( actor SkinActor, string SkinName, string FaceName, byte TeamNum )
{
	local Texture NewSkin;

	if(SkinName != "")
	{
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));
		if ( NewSkin != None )
			SkinActor.Skin = NewSkin;
	}
}

static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName )
{
	SkinName = String(SkinActor.Skin);
	FaceName = "";
}
*/

static function bool SetSkinElement(Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
	local Texture NewSkin;

	NewSkin = Texture(DynamicLoadObject(SkinName, class'Texture'));
	if ( NewSkin != None )
	{
		SkinActor.Multiskins[SkinNo] = NewSkin;
		return True;
	}
	else
	{
		log("Failed to load "$SkinName);
		if(DefaultSkinName != "")
		{
			NewSkin = Texture(DynamicLoadObject(DefaultSkinName, class'Texture'));
			SkinActor.Multiskins[SkinNo] = NewSkin;
		}
		return False;
	}
}

function SetDisplayProperties(ERenderStyle NewStyle, texture NewTexture, bool bLighting, bool bEnviroMap )
{
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
	bMeshEnviromap = bEnviromap;
	if ( Weapon != None )
		Weapon.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
	bUpdatingDisplay = false;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
	bMeshEnviromap = Default.bMeshEnviromap;
	if ( Weapon != None )
		Weapon.SetDisplayProperties(Weapon.Default.Style, Weapon.Default.Texture, Weapon.Default.bUnlit, Weapon.Default.bMeshEnviromap);

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
	bUpdatingDisplay = false;
}



//=============================================================================
// Game Events
//=============================================================================
function RestartPlayer();


//=============================================================================
// Stimulus events
//=============================================================================
event MayFall(); //return true if allowed to fall - called by engine when pawn is about to fall
event AlterDestination(); // called when using movetoward with bAdvancedTactics true to temporarily modify destination
event HearNoise( float Loudness, Actor NoiseMaker);
event SeePlayer( actor Seen );
event UpdateEyeHeight( float DeltaTime );
event UpdateTactics(float DeltaTime); // for advanced tactics
event EnemyNotVisible();
event LongFall();
event bool GrabEdge(float grabDistance, vector grabNormal);	// Pawn just grabbed an edge

function Killed(pawn Killer, pawn Other, name damageType)
{
	if ( Enemy == Other )
		Enemy = None;

}

function Falling()
{
	local vector end;

	end = Location;
	end.Z -= CollisionHeight * 2.5;

	if(FastTrace(end, Location))
		PlayInAir(0.1);

//	if (Velocity.Z < -JumpZ)
//		PlayInAir(0.1);
}

event FellOutOfWorld()
{
	if ( Role < ROLE_Authority )
		return;
	Health = -1;
	SetPhysics(PHYS_None);
	Weapon = None;
	Died(None, 'Fell', Location);
}

// Pawn interface called while PHYS_Walking and PHYS_Swimming to update the pawn with 
// the latest information about the walk surface
event WalkTexture( texture Texture, vector StepLocation, vector StepNormal )
{
}

event Landed(vector HitNormal, actor HitActor)
{
	local int damage;

	//Note - physics changes type to PHYS_Walking by default for landed pawns
//	SetMovementPhysics();
	PlayLanded(Velocity.Z);
	if (Velocity.Z < -1.4 * JumpZ)
	{
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));

		// Damage whatever the pawn landed on (if the pawn fell far enough)
		if(Velocity.Z <= -400 && HitActor != None)
		{
			// Don't hurt players in neutral zones
			if(Region.Zone.bNeutralZone || HitActor.Region.Zone.bNeutralZone)
				damage = 0;
			else if(Level.Game.bTeamGame && Pawn(HitActor) != None && self != None 
				&& Pawn(HitActor).PlayerReplicationInfo.Team != 255 
				&& Pawn(HitActor).PlayerReplicationInfo.Team == self.PlayerReplicationInfo.Team)
				damage = 0; // Don't hurt the victim if on the same team
			else if(!HitActor.IsA('LevelInfo'))
			{ // RUNE:  Damage anything the actor fell on
				if(HitActor.Mass > 0)	
					damage = -0.1 * (Velocity.Z) * Mass / HitActor.Mass;
				else
					damage = -0.1 * (Velocity.Z) * Mass / 100;
				HitActor.JointDamaged(damage, None, HitActor.Location, vect(0, 0, 0), 'blunt', 0);
			}
		}

		// Falling damage
		if (Velocity.Z <= -1100 && !HitActor.bJointsBlock)
		{
			if((Velocity.Z < -2000) && (ReducedDamageType != 'All'))
			{
				JointDamaged(1000, None, Location, vect(0,0,0), 'fell', 0);
			}
			else if ( Role == ROLE_Authority )
			{
				JointDamaged(-0.15 * (Velocity.Z + 1050), None, Location, vect(0,0,0), 'fell', 0);
			}
		}
	}
	bJustLanded = true;
}

//=============================================================================
//
// FootSteps/Notifies
// 
//=============================================================================

simulated function FootStepRight()
{
	if(!bFootsteps || RFootJoint==0)
		return;

	FootStepPrint(RFootJoint);
}

simulated function FootStepLeft()
{
	if(!bFootsteps || LFootJoint==0)
		return;

	FootStepPrint(LFootJoint);
}

simulated function FootStepPrint(int footjoint)
{
	local EMatterType matter;
	local sound snd;
	local vector footpos;
	local Decal d;
	local float sndVol;
	local bool bStealth;
	local int slot;
	
	footpos = GetJointPos(footjoint);

	if(FootRegion.Zone.bPainZone)
		matter = MATTER_LAVA;
	else if(FootRegion.Zone.bWaterZone)
		matter = MATTER_WATER;
	else
		matter = MatterTrace(footpos-vect(0,0,20), footpos+vect(0,0,20), 10);

	if (Physics == PHYS_Walking)
	{
		if(self.IsA('PlayerPawn') && PlayerPawn(self).bIsCrouching)
			bStealth = true; // Player is crouching, and hence being stealthy
		else
			bStealth = false;

		snd = GetFootstepSound(matter);
		if(snd != None)
		{
			if(bStealth)
				sndVol = 0.2;
			else
				sndVol = 0.33;

			// RUNE:  Allow player footstep sounds to overlap
			if(self.IsA('PlayerPawn'))
				PlaySound(snd, SLOT_None, sndVol, false,, 0.95 + (FRand() * 0.1));
			else
				PlaySound(snd, SLOT_Interact, sndVol, false,, 0.95 + (FRand() * 0.1));
		}		
		if(!bStealth && matter == MATTER_METAL || matter == MATTER_WATER || matter == MATTER_LAVA)
			MakeNoise(1.0);
	}

	// See if we're stepping in blood
	foreach RadiusActors(class'Decal', d, CollisionRadius, footpos)
	{
		if (d.bBloodyDecal)
			BloodSteps += 5;
	}

	if (matter==MATTER_WATER || matter==MATTER_LAVA)
		return;

	footpos.Z = Location.Z - CollisionHeight + 10;
	if (WaterSteps > 0)
	{	// Make water footprint
		WaterSteps--;
		d = Spawn(WetFootprintClass,self,,footpos);
		if (d!=None)
			d.DirectionalAttach(Velocity, Floor);
	}
	else if (BloodSteps > 0)
	{	// Make blood footprint
		BloodSteps--;
		d = Spawn(BloodyFootprintClass,self,,footpos);
		if (d!=None)
			d.DirectionalAttach(Velocity, Floor);
	}
	else if ((matter==MATTER_SNOW || matter==MATTER_EARTH) && FootprintClass!=None)
	{	// Make normal footprint
		d = Spawn(FootprintClass,self,,footpos);
		if (d!=None)
			d.DirectionalAttach(Velocity, Floor);
	}
}

simulated function Sound GetFootstepSound(EMatterType matter)
{
	local int i;
	local sound snd;

	i = Rand(3);
	switch(matter)
	{
	case MATTER_FLESH:
		snd = FootStepFlesh[i];
		break;
	case MATTER_WOOD:
		snd = FootStepWood[i];
		break;
	case MATTER_STONE:
		snd = FootStepStone[i];
		break;
	case MATTER_METAL:
		snd = FootStepMetal[i];
		break;
	case MATTER_EARTH:
		snd = FootStepEarth[i];
		break;
	case MATTER_BREAKABLEWOOD:
		snd = FootStepBreakableWood[i];
		break;
	case MATTER_BREAKABLESTONE:
		snd = FootStepBreakableStone[i];
		break;
	case MATTER_ICE:
		snd = FootStepIce[i];
		break;
	case MATTER_SNOW:
		snd = FootStepSnow[i];
		break;
	case MATTER_WATER:
		snd = FootStepWater[i];
		break;
	case MATTER_MUD:
		snd = FootStepMud[i];
		break;
	case MATTER_LAVA:
		snd = FootStepLava[i];
		break;
	default:
		snd = None;
	}

	return snd;
}

simulated function FootStep()
{
	local EMatterType matter;
	local vector end;
	local sound snd;

	if(bFootsteps && Physics == PHYS_Walking)
	{
		if(FootRegion.Zone.bPainZone)
			matter = MATTER_LAVA;
		else if(FootRegion.Zone.bWaterZone)
			matter = MATTER_WATER;
		else
		{
			end = Location;
			end.Z -= CollisionHeight + 8;
			matter = MatterTrace(end, Location, 10);
		}

		snd = GetFootstepSound(matter);
		if(snd != None)
		{
			PlaySound(snd, SLOT_Interact, FootstepVolume, false,, 0.95 + (FRand() * 0.1));
		}
	}
}

//------------------------------------------------------------
//
// FootZoneChange
//
//------------------------------------------------------------
event FootZoneChange(ZoneInfo newFootZone)
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local float splashSize;
	local actor splash;

	// Handle footprints
	if ( FootRegion.Zone.bWaterZone )
	{
		WaterSteps = 15;
		BloodSteps = 0;
	}

	if ( Level.NetMode == NM_Client )
		return;
	if ( Level.TimeSeconds - SplashTime > 0.25 ) 
	{
		SplashTime = Level.TimeSeconds;
		if (Physics == PHYS_Falling)
			MakeNoise(1.0);
		else
			MakeNoise(0.3);
		if ( FootRegion.Zone.bWaterZone )
		{
			if ( !newFootZone.bWaterZone && (Role==ROLE_Authority) )
			{
				if ( FootRegion.Zone.ExitSound != None )
					PlaySound(FootRegion.Zone.ExitSound, SLOT_Misc, 1); 
				if ( FootRegion.Zone.ExitActor != None )
					Spawn(FootRegion.Zone.ExitActor,,,Location - CollisionHeight * vect(0,0,1));
			}
		}
		else if ( newFootZone.bWaterZone && (Role==ROLE_Authority) )
		{
			splashSize = FClamp(0.000025 * Mass * (300 - 0.5 * FMax(-500, Velocity.Z)), 1.0, 4.0 );
			if ( newFootZone.EntrySoundBig != None && Velocity.Z < -600)
			{
				HitActor = Trace(HitLocation, HitNormal, 
						Location - (CollisionHeight + 40) * vect(0,0,0.8),
						Location - CollisionHeight * vect(0,0,0.8), false);
				if ( HitActor == None )
					PlaySound(newFootZone.EntrySoundBig, SLOT_Misc, 2 * splashSize);
				else 
					PlaySound(WaterStep, SLOT_Misc, 1.5 + 0.5 * splashSize);
			}
			else if ( newFootZone.EntrySound != None )
			{
				HitActor = Trace(HitLocation, HitNormal, 
						Location - (CollisionHeight + 40) * vect(0,0,0.8),
						Location - CollisionHeight * vect(0,0,0.8), false);
				if ( HitActor == None )
					PlaySound(newFootZone.EntrySound, SLOT_Misc, 2 * splashSize);
				else 
					PlaySound(WaterStep, SLOT_Misc, 1.5 + 0.5 * splashSize);
			}
			if( newFootZone.EntryActor != None )
			{
				splash = Spawn(newFootZone.EntryActor,,,Location - CollisionHeight * vect(0,0,1));
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
		}
	}
	
	if (FootRegion.Zone.bPainZone)
	{
		if ( !newFootZone.bPainZone && !HeadRegion.Zone.bWaterZone )
			PainTime = -1.0;
	}
	else if (newFootZone.bPainZone)
		PainTime = 0.01;
}

//------------------------------------------------------------
//
// HeadZoneChange
//
//------------------------------------------------------------
event HeadZoneChange(ZoneInfo newHeadZone)
{
	local int dummy1, dummy2;

	if ( Level.NetMode == NM_Client )
		return;
	if (HeadRegion.Zone.bWaterZone)
	{
		if (!newHeadZone.bWaterZone)
		{
			if ( bIsPlayer && (PainTime > 0) && (PainTime < 8) )
				Gasp();
			if ( Inventory != None )
				Inventory.ReduceDamage(dummy1, dummy2, 'Breathe', Location); //inform inventory of zone change
			bDrowning = false;
			if ( !FootRegion.Zone.bPainZone )
				PainTime = -1.0;
		}
	}
	else
	{
		if (newHeadZone.bWaterZone)
		{
			if ( !FootRegion.Zone.bPainZone )
				PainTime = UnderWaterTime;
			if ( Inventory != None )
				Inventory.ReduceDamage(dummy1, dummy2, 'Drowned', Location); //inform inventory of zone change
		}
	}
}



//=============================================================================
// Timers
//=============================================================================
event SpeechTimer();
event AmbientSoundTimer();
event PainTimer()
{
	local float depth;

	// Pain timer just expired:
	//  Check what zone I'm in (and which parts are)
	//  based on that cause damage, and reset PainTime

	if ( (Health < 0) || (Level.NetMode == NM_Client) )
		return;
		
	if ( FootRegion.Zone.bPainZone )
	{
		depth = 0.4;
		if (Region.Zone.bPainZone)
			depth += 0.4;
		if (HeadRegion.Zone.bPainZone)
			depth += 0.2;

		if (FootRegion.Zone.DamagePerSec > 0)
		{
			if ( IsA('PlayerPawn') )
				Level.Game.SpecialDamageString = FootRegion.Zone.DamageString;
			JointDamaged(int(float(FootRegion.Zone.DamagePerSec) * depth), None, Location, vect(0,0,0), FootRegion.Zone.DamageType, 0);
		}
		else if ( Health < Default.Health )
			Health = Min(Default.Health, Health - depth * FootRegion.Zone.DamagePerSec);

		if (Health > 0)
			PainTime = 1.0;
	}
	else if ( HeadRegion.Zone.bWaterZone )
	{
		bDrowning = true;
		JointDamaged(0.2*Default.Health, None, Location, vect(0,0,0), 'drowned', 0);
		if ( Health > 0 )
			PainTime = 2.0;
	}
}



//=============================================================================
// Encroachment
//=============================================================================

event bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;
		
	if ( (!bIsPlayer || bWarping) && (Pawn(Other) != None))
		return true;
		
	return false;
}

event EncroachedBy( actor Other )
{
	if ( Pawn(Other) != None )
	{
		health = -1000; //make sure gibs
		Died(pawn(Other), 'gibbed', Location);
	}
}

//Base change - if new base is pawn or decoration,
// damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn()
{
	Velocity += 60 * VRand();
	Velocity.Z = 180;
	SetPhysics(PHYS_Falling);
}

function UnderLift(Mover M);

singular event BaseChange()
{
	local float decorMass;
	local EMatterType matter;
	local int damage;

	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if (Pawn(Base) != None)
	{
/* This functionality moved to Landed()
		damage = (1-Velocity.Z/400)* Mass/Base.Mass;
		if (damage > 0)
			Base.JointDamaged(damage, Self, Location, 0.5*Velocity, 'stomped', 0);
*/
		if (Pawn(Base).bAllowStandOn)
			SetPhysics(PHYS_Walking);
		else
			JumpOffPawn();
	}
	else if ( (Decoration(Base) != None) )
	{
		if (Velocity.Z < -1.4*JumpZ)
		{
			matter=Base.MatterForJoint(0);
			PlayLandSound(matter, Velocity.Z);
		}
		if (Velocity.Z < -400)
		{
			decorMass = FMax(Decoration(Base).Mass, 1);
			Base.JointDamaged(-2* Mass/decorMass * Velocity.Z/400, Self, Location, 0.5*Velocity, 'stomped', 0);
		}
	}
}


//=============================================================================
// Animation functions - should be implemented in subclass, 
//=============================================================================
function PlayWaiting		(optional float tween){}	// These are required
function PlayMoving			(optional float tween){}
function PlayJumping		(optional float tween){}
function PlayTurning		(optional float tween){}
function PlayMovingAttack	(optional float tween){}
function PlayInAir			(optional float tween){}
function PlayDuck			(optional float tween){}
function PlayCrawling		(optional float tween){}

function PlayThreatening	(optional float tween)		{	PlayWaiting(tween);	}
function PlayOutOfWater		(optional float tween)		{	PlayJumping(tween);	}
function PlayDive			(optional float tween)		{	PlayInAir(tween);	}
function PlayPullUp			(optional float tween)		{	PlayJumping(tween);	}
function PlayStepUp			(optional float tween)		{	PlayPullUp(tween);	}
function PlayLanding		(optional float tween)		{}
function PlayLanded(float impactVel)
{
	local EMatterType matter;
	local vector end;

	if (impactVel < -JumpZ)
		PlayLanding(0.1);

	impactVel = impactVel/JumpZ;
	impactVel = 0.005 * Mass * impactVel * impactVel;

	if ( Role == ROLE_Authority )
	{
		if ( impactVel > 0.17 )
			PlaySound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);

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
}


function TweenToWaiting		(float tweentime){}
function TweenToMoving		(float tweentime){}

// Deaths
function PlayDeath(name DamageType);										// hit from front
function PlayBackDeath(name DamageType)		{ PlayDeath(DamageType);	}	// hit from behind
function PlayLeftDeath(name DamageType)		{ PlayDeath(DamageType);	}	// fall to his left
function PlayRightDeath(name DamageType)	{ PlayDeath(DamageType);	}	// fall to his right
function PlayHeadDeath(name DamageType)		{ PlayDeath(DamageType);	}	// decapitated
function PlayDrownDeath(name DamageType)	{ PlayDeath(DamageType);	}	// drown
function PlaySkewerDeath(name DamageType)	{ PlayDeath(DamageType);	}	// hit by thrown sword
function PlayGibDeath(name DamageType)
{
//	PlayDeath(DamageType);
	if (bIsPlayer)
		bHidden=true;
	else
		Destroy();
	SpawnBodyGibs(Velocity);
}
function PlayDying(name DamageType, vector HitLoc)
{
	local vector X,Y,Z,HitVec,HitVec2D;
	local float dotp;

	// Handle special damage types here
	if ( DamageType == 'drowned' )
	{
		PlayDrownDeath(DamageType);
		return;
	}
	else if ( DamageType == 'decapitated' )
	{
		PlayHeadDeath(DamageType);
		return;
	}
	else if ( DamageType == 'gibbed')
	{
		PlayGibDeath(DamageType);
		return;
	}
	else if( DamageType == 'thrownweaponsever')
	{
		PlaySkewerDeath(DamageType);
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	//first check for head hit
	if ( HitLoc.Z - Location.Z > 0.5 * CollisionHeight && (dotp > 0) )
	{
		PlayHeadDeath(DamageType);
		return;
	}
	
	if (dotp > 0.71) //then hit in front
		PlayDeath(DamageType);
	else if (dotp < -0.71)
		PlayBackDeath(DamageType);
	else
	{
		dotp = HitVec dot Y;
		if (dotp > 0.0)
		{
			if (!bMirrored)
				PlayLeftDeath(DamageType);
			else
				PlayRightDeath(DamageType);
		}
		else
		{
			if (!bMirrored)
				PlayRightDeath(DamageType);
			else
				PlayLeftDeath(DamageType);
		}
	}
}

// Pain
function PlayFrontHit	(optional float tweentime)	{}
function PlayBackHit	(optional float tweentime)	{ PlayFrontHit(tweentime);	}
function PlayLeftHit	(optional float tweentime)	{ PlayFrontHit(tweentime);	}
function PlayRightHit	(optional float tweentime)	{ PlayFrontHit(tweentime);	}
function PlayHeadHit	(optional float tweentime)	{ PlayFrontHit(tweentime);	}
function PlayDrowning	(optional float tweentime)	{ PlayFrontHit(tweentime);	}
function PlayTakeHit	(float tweentime, int damage, vector HitLoc, name damageType, vector Momentum, int BodyPart)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;

	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	if(damageType == 'Drowned')
	{
		PlayDrowning(tweentime);
		return;
	}

	//first check for head hit
	if ( HitLoc.Z - Location.Z > 0.5 * CollisionHeight )
	{
		if (dotp > 0)
		{
			PlayHeadHit(tweentime);
			return;
		}
	}
	
	if (dotp > 0.71) //then hit in front
		PlayFrontHit( tweentime);
	else if (dotp < -0.71) // then hit in back
		PlayBackHit(tweentime);
	else
	{
		dotp = HitVec dot Y;
		if (dotp > 0.0)
		{
			if (!bMirrored)
				PlayLeftHit(tweentime);
			else
				PlayRightHit(tweentime);
		}
		else
		{
			if (!bMirrored)
				PlayRightHit(tweentime);
			else
				PlayLeftHit(tweentime);
		}
	}
}

function PlayWeaponSwitch(Weapon NewWeapon);


//=============================================================================
// Sound functions
//=============================================================================
function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	if ( Level.TimeSeconds - LastPainSound < 0.25 )
		return;

	if (HitSound1 == None)
		return;
	LastPainSound = Level.TimeSeconds;
	if (Damage < 10)
		PlaySound(HitSound1, SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0));
	else if (Damage < 25)
		PlaySound(HitSound2, SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0));
	else
		PlaySound(HitSound3, SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0));
}

function PlayDyingSound(name damageType)
{
	local float rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
/*		if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,,,,Frand()*0.2+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,,,,Frand()*0.2+0.9);
		return;*/
	}

	if (damageType == 'gibbed')
	{
		PlaySound(GibSound, SLOT_Talk);
	}
	else
	{
		rnd = FRand();
		if (rnd < 0.33)
			PlaySound(Die, SLOT_Talk);
		else if (rnd < 0.66)
			PlaySound(Die2, SLOT_Talk);
		else 
			PlaySound(Die3, SLOT_Talk);
	}
}

function PlayLandSound(EMatterType matter, float impactVel)
{
	local sound snd;

	switch(matter)
	{
	case MATTER_FLESH:
		snd = LandSoundFlesh;
		break;
	case MATTER_WOOD:
		snd = LandSoundWood;
		break;
	case MATTER_STONE:
		snd = LandSoundStone;
		break;
	case MATTER_METAL:
		snd = LandSoundMetal;
		break;
	case MATTER_EARTH:
		snd = LandSoundEarth;
		break;
	case MATTER_BREAKABLEWOOD:
		snd = LandSoundBreakableWood;
		break;
	case MATTER_BREAKABLESTONE:
		snd = LandSoundBreakableStone;
		break;
	case MATTER_ICE:
		snd = LandSoundIce;
		break;
	case MATTER_SNOW:
		snd = LandSoundSnow;
		break;
	case MATTER_WATER:
		snd = LandSoundWater;
		break;
	case MATTER_MUD:
		snd = LandSoundMud;
		break;
	case MATTER_LAVA:
		snd = LandSoundLava;
		break;
	default:
		snd = None;
	}

	if(snd != None)
	{
		PlaySound(snd, SLOT_Interact, FClamp(4 * impactVel, 0.5, 2), false, 1000, 0.95 + (FRand() * 0.1));
	}
}

function Gasp();
function StopFiring();


//=============================================================================
// Utility functions
//=============================================================================

function UpdateMovementSpeed()
{
	if (Region.Zone.bWaterZone)
	{
		if (bHurrying || WaterSpeed==0)
			MovementSpeed = 1;
		else
			MovementSpeed = WalkingSpeed/WaterSpeed;
	}
	else if (Physics == PHYS_Flying)
	{
		if (bHurrying || AirSpeed==0)
			MovementSpeed = 1;
		else
			MovementSpeed = WalkingSpeed/AirSpeed;
	}
	else
	{
		if (bHurrying || GroundSpeed==0)
			MovementSpeed = 1;
		else
			MovementSpeed = WalkingSpeed/GroundSpeed;
	}
}

function AddVelocity( vector NewVelocity)
{
	if (Physics == PHYS_Walking)
		SetPhysics(PHYS_Falling);
//	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
//		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

function actor ActorTagged(name tag)
{
	local actor A;
	foreach AllActors(class'actor', A, tag)
	{
		return A;
	}
}

function String GetHumanName()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.PlayerName;
	return NameArticle$MenuName;
}

function ClientPutDown(Weapon Current, Weapon Next)
{
//	Current.ClientPutDown(Next);
}

function BoostStrength(int amount)
{
	Strength += amount;
	if (Strength > MaxStrength)
		Strength = MaxStrength;
}

function bool CanBeStatued()
{	// Pawn can be turned into a statue
	return true;
}

//------------------------------------------------------------
//
// AdjustAim()
//
// ScriptedPawn version does adjustment for non-controlled pawns. 
// PlayerPawn version does the adjustment for player aiming help.
// Only adjusts aiming at pawns
// allows more error in Z direction (full as defined by AutoAim - only half that difference for XY)
//------------------------------------------------------------
function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
	return ViewRotation;
}

function rotator AdjustToss(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
	return ViewRotation;
}

function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
{
	// AI controlled creatures may duck
	// if not falling, and projectile time is long enough
	// often pick opposite to current direction (relative to shooter axis)
}

function SetMovementPhysics()
{
	//implemented in sub-class
}

function PreSetMovement()
{
	if(JumpZ > 0)
		bCanJump = true;
	bCanWalk = GroundSpeed > 0;
	bCanSwim = false;
	bCanFly = false;
//	MinHitWall = -0.6;
	MinHitWall = -0.835;	//RUNE
	if(Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if(Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

simulated function SetMesh()
{
	mesh = default.mesh;
}

function HidePlayer()
{
	SetCollision(false, false, false);
	TweenToWaiting(0.01);
	bHidden = true;
}

function damageAttitudeTo(pawn Other);
function bool FollowOrders(name order, name tag)	{	return false;	}
function FearThisSpot(Actor aSpot);

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

//------------------------------------------------------------
//
// NearWall
//
// Returns true if there is a nearby barrier at eyeheight and
// changes focus to a suggested value
//------------------------------------------------------------
function bool NearWall(float walldist)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

	LookDir = vector(Rotation);
	ViewSpot = Location + BaseEyeHeight * vect(0,0,1);
	ViewDist = LookDir * walldist; 
	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
		return false;

	ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
	if (FRand() < 0.5)
		ViewDist *= -1;

	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
	{
		Focus = Location + ViewDist;
		return true;
	}

	ViewDist *= -1;

	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
	{
		Focus = Location + ViewDist;
		return true;
	}

	Focus = Location - LookDir * 300;
	return true;
}


//=============================================================================
// Inventory related functions.
//=============================================================================

//------------------------------------------------------------
//
// WantsToPickup
//
// Returns whether the item is desired
//------------------------------------------------------------
function bool WantsToPickUp(Inventory item)
{
	return false;
}


//------------------------------------------------------------
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//------------------------------------------------------------
function bool CanPickup(Inventory item)
{
	return false;
}


//------------------------------------------------------------
//
// AcquireInventory
//
// Called when inventory item is acquired
//------------------------------------------------------------
function AcquireInventory(Inventory item)
{
	if (item.IsA('Weapon'))
	{
		DropWeapon();
		AttachActorToJoint(item, JointNamed(WeaponJoint));
		Weapon = Weapon(item);
		Weapon.GotoState('Active');
	}
	else if (item.IsA('Shield'))
	{
		DropShield();
		AttachActorToJoint(item, JointNamed(ShieldJoint));
		Shield = Shield(item);
		Shield.GotoState('Active');
	}
}


//------------------------------------------------------------
//
// DropWeapon
//
//------------------------------------------------------------
function DropWeapon()
{
	local vector X,Y,Z;
	local int joint;
	
	if(Weapon == None)
		return;

	if(Weapon.bPoweredUp)
		Weapon.PowerupEnd();

	joint = JointNamed(WeaponJoint);
	if (joint != 0)
	{
		DetachActorFromJoint(joint);
		
		GetAxes(Rotation, X, Y, Z);
		Weapon.DropFrom(GetJointPos(joint));

		if (Weapon != None)	// Invisible weapons get destroyed at DropFrom()
		{
			Weapon.SetPhysics(PHYS_Falling);
			Weapon.Velocity = Y * 100 + X * 75;
			Weapon.Velocity.Z = 50;
			Weapon.GotoState('Drop');
			Weapon.DisableSwipeTrail();

			DeleteInventory( Weapon );
		}
	}
}	


//------------------------------------------------------------
//
// DropShield
//
//------------------------------------------------------------
function DropShield()
{
	local vector X,Y,Z;
	local int joint;
	
	if(Shield == None)
		return;
	
	joint = JointNamed(ShieldJoint);
	if (joint != 0)
	{
		DetachActorFromJoint(joint);
		
		GetAxes(Rotation, X, Y, Z);
		Shield.DropFrom(GetJointPos(joint));
	
		Shield.SetPhysics(PHYS_Falling);
		Shield.Velocity = Y * 100 + X * 75;
		Shield.Velocity.Z = 50;
		Shield.GotoState('Drop');

		DeleteInventory( Shield );
	}
}

//=============================================================================
//
// ThrowWeapon
//
// RUNE:  Throw the current weapon
//=============================================================================

function ThrowWeapon()
{
	local vector X,Y,Z;
	local float xMag, zMag;
	local int joint;
	local Weapon theWeapon;
	local vector extent;
	local vector weaponLoc;
	local vector HitLocation, HitNormal;
	
	if(Weapon == None)
	{
		return;
	}
	
	joint = JointNamed(WeaponJoint);
	DetachActorFromJoint(joint);
	
	if(self.IsA('PlayerPawn'))
		GetAxes(ViewRotation, X, Y, Z); // Players throw in the direction they are looking
	else
		GetAxes(Rotation, X, Y, Z); // Creatures throw in the direction they are facing

	// Check if weapon will fit in intended location (trace from center to weapon location)
	extent.X = Weapon.CollisionRadius;
	extent.Y = Weapon.CollisionRadius;
	extent.Z = Weapon.CollisionHeight;
	weaponLoc = GetJointPos(joint);

	if(Trace(HitLocation, HitNormal, weaponLoc, Location, true, Extent) != None)
	{ // Struck something along the way, spawn the weapon at the player location
		weaponLoc = Location;
	}
	
	Weapon.SetLocation(weaponLoc);
	theWeapon = Weapon;
	DeleteInventory( theWeapon );
	theWeapon.SetOwner(self); // Guarantee that the owner is set for the throwing weapon (not needed anymore)

	xMag = 7500 / theWeapon.Mass;
	if(xMag > 750)
		xmag = 750;

	zMag = 2000 / theWeapon.Mass;
	if(zMag > 200)
		zMag = 200;

	theWeapon.Velocity = X * xMag + Z * zMag;
	theWeapon.GotoState('Throw');
}	


// toss out the weapon currently held
function TossWeapon()
{
	local vector X,Y,Z;
	if ( Weapon == None )
		return;
	GetAxes(Rotation,X,Y,Z);
//	Weapon.DropFrom(Location + 0.8 * CollisionRadius * X + - 0.5 * CollisionRadius * Y);
	DetachActorFromJoint(JointNamed(WeaponJoint));
	Weapon.Velocity = Y * 100 - X * 50;
	Weapon.DropFrom(Weapon.Location); 
}	

exec function bool SwitchToBestWeapon()
{
	local float rating;
	local int usealt;

	if ( Inventory == None )
		return false;

	PendingWeapon = Inventory.RecommendWeapon(rating, usealt);
	if ( PendingWeapon == Weapon )
		PendingWeapon = None;

	if ( PendingWeapon == None )
		return false;

	if ( Weapon == None )
		ChangedWeapon();

	return (usealt > 0);
}

function float AdjustDesireFor(Inventory Inv)
{
	return 0;
}

// The player/bot wants to select next item
exec function NextItem()
{
	local Inventory Inv;

	if (SelectedItem==None) {
		SelectedItem = Inventory.SelectNext();
		Return;
	}
	if (SelectedItem.Inventory!=None)
		SelectedItem = SelectedItem.Inventory.SelectNext(); 
	else
		SelectedItem = Inventory.SelectNext();

	if ( SelectedItem == None )
		SelectedItem = Inventory.SelectNext();
}

// FindInventoryType()
// returns the inventory item of the requested class
// if it exists in this pawn's inventory 

function Inventory FindInventoryType( class DesiredClass )
{
	local Inventory Inv;

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )   
		if ( Inv.class == DesiredClass )
			return Inv;
	return None;
} 

// Add Item to this pawn's inventory. 
// Returns true if successfully added, false if not.
function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;
	
	// The item should not have been destroyed if we get here.
	if (NewItem ==None )
		log("tried to add none inventory to "$self);

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if( Inv == NewItem )
			return false;


	// Add to front of inventory chain.
	NewItem.SetOwner(Self);
	NewItem.Inventory = Inventory;
	Inventory = NewItem;
	return true;
}

// Remove Item from this pawn's inventory, if it exists.
// Returns true if it existed and was deleted, false if it did not exist.
function bool DeleteInventory( inventory Item )
{
	// If this item is in our inventory chain, unlink it.
	local actor Link;
	if ( Item == Weapon )
		Weapon = None;
	if ( Item == Shield )
		Shield = None;
	if ( Item == SelectedItem )
		SelectedItem = None;
	for( Link = Self; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory == Item )
		{
			Link.Inventory = Item.Inventory;
			Item.Inventory = None;
			break;
		}
	}
	Item.SetOwner(None);
}

// Just changed to pendingWeapon
function ChangedWeapon()
{
	local Weapon OldWeapon;

	OldWeapon = Weapon;

	if (Weapon == PendingWeapon)
	{
		if ( Weapon == None )
			SwitchToBestWeapon();
		if ( Weapon != None )
			Weapon.SetDefaultDisplayProperties();
		Inventory.ChangedWeapon(); // tell inventory that weapon changed (in case any effect was being applied)
		PendingWeapon = None;
		return;
	}
	if ( PendingWeapon == None )
		PendingWeapon = Weapon;
	PlayWeaponSwitch(PendingWeapon);
	if ( Weapon != None )
		Weapon.SetDefaultDisplayProperties();
	Weapon = PendingWeapon;
	Inventory.ChangedWeapon(); // tell inventory that weapon changed (in case any effect was being applied)

	PendingWeapon = None;
}

function PowerUpWeapon()
{
	if(Weapon == None)
		return;

	if (RunePower >= Weapon.RunePowerRequired && !Weapon.bPoweredUp)
	{
		RunePower -= Weapon.RunePowerRequired;
		Weapon.PowerUp();
	}
}



//=============================================================================
// Localized Damage Support functions
//=============================================================================

function int BodyPartForJoint(int joint)			{ return BODYPART_BODY; }
function int BodyPartForPolyGroup(int polygroup)	{ return BODYPART_BODY; }
function bool BodyPartSeverable(int BodyPart)		{ return false; }
function bool BodyPartCritical(int BodyPart)		{ return false; }
function LimbSevered(int bodypart, vector Momentum) { }

//------------------------------------------------------------
//
// RestoreBodyPart
//
// Restore a bodypart to full health, visibility, collision
//------------------------------------------------------------
function RestoreBodyPart(int BodyPart)
{
	BodyPartHealth[BodyPart] = Default.BodyPartHealth[BodyPart];
	BodyPartCollision(BodyPart, true);
	BodyPartVisibility(BodyPart, true);
}

//------------------------------------------------------------
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//------------------------------------------------------------
function EMatterType MatterForJoint(int joint)
{
	return MATTER_FLESH;
}

//------------------------------------------------------------
//
// BodyPartMissing
//
//------------------------------------------------------------
function bool BodyPartMissing(int BodyPart)
{
	return BodyPartHealth[BodyPart] <= 0;
}

//------------------------------------------------------------
//
// BodyPartCollision
//
// Turn collision on or off on a body part
//------------------------------------------------------------
function BodyPartCollision(int BodyPart, bool on)
{
	local int i,num;

	num = NumJoints();
	for (i=0; i<num; i++)
	{
		if (BodyPartForJoint(i) == BodyPart)
		{
			if (on)
				JointFlags[i] = JointFlags[i] | JOINT_FLAG_COLLISION;
			else
				JointFlags[i] = JointFlags[i] & ~JOINT_FLAG_COLLISION;
		}
	}
}

//------------------------------------------------------------
//
// BodyPartVisibility
//
// Turn visibility on or off on a body part
//------------------------------------------------------------
function BodyPartVisibility(int BodyPart, bool on)
{
	local int i,num;

	for (i=0; i<16; i++)
	{
		if (BodyPartForPolygroup(i) == BodyPart)
		{
			if (on)
				SkelGroupFlags[i] = SkelGroupFlags[i] & ~POLYFLAG_INVISIBLE;
			else
				SkelGroupFlags[i] = SkelGroupFlags[i] | POLYFLAG_INVISIBLE;
		}
	}
}


//------------------------------------------------------------
//
// LimbPassThrough
//
// Determines what damage is passed through to body
//------------------------------------------------------------
function int LimbPassThrough(int BodyPart, out int Blunt, out int Sever)
{
	return Blunt+Sever;
}

//------------------------------------------------------------
//
// ApplyPainToJoint
//
//------------------------------------------------------------
function ApplyPainToJoint(int joint, vector Momentum)
{
}

//------------------------------------------------------------
//
// JointDamaged
//
//------------------------------------------------------------
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	ApplyPainToJoint(joint, Momentum);

	// Allow mutators to change stuff around
	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorJointDamaged( Damage, Self, EventInstigator, HitLoc, Momentum, DamageType, joint);

	return Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
}

//------------------------------------------------------------
//
// CanGotoPainState
//
// True if the actor is allowed to enter it's painstate
// This is overriden in some substates
//------------------------------------------------------------

function bool CanGotoPainState()
{
	return(true);
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

//------------------------------------------------------------
//
// DamageBodyPart
//
//------------------------------------------------------------
function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int bodypart)
{
	local int PassThrough;
	local int SeverDamage;
	local int BluntDamage;
	local bool bAlreadyDead;
	local int AppliedDamage;
	local Debris Gib;
	local float scale;
	local int i, NumChunks;

	local vector AdjMomentum;

	if(!class'GameInfo'.Default.bVeryLowGore)
	{
		if (CurrentSkin != 0)
			SpecialPainSkin(BodyPart);
		else
			PainSkin(BodyPart);
	}

	GetDamageValues(Damage, DamageType, BluntDamage, SeverDamage);
	Level.Game.ReduceDamage(BluntDamage, SeverDamage, DamageType, self, EventInstigator);
	PassThrough = LimbPassThrough(BodyPart, BluntDamage, SeverDamage);

	// Give instigator strength boost if deserving
	if(EventInstigator!=None && EventInstigator.IsA('PlayerPawn') && Health>0 &&
		(DamageType=='blunt' || DamageType=='sever' || DamageType=='bluntsever') &&
		EventInstigator.Weapon!=None && !EventInstigator.Weapon.bPoweredUp &&
		(PassThrough>0) )
	{ // Boost the player's strength/bloodlust for successful conventional attacks
		EventInstigator.BoostStrength(0.2 * Damage);
	}

	if (BodyPart != BODYPART_BODY)
	{
		if (BodyPartSeverable(BodyPart) && (BodyPartHealth[BodyPart] > 0))
		{
			BodyPartHealth[BodyPart] -= SeverDamage;
	
			if(BodyPartHealth[BodyPart] <= 0)
			{	// Body Part was killed
				if (BodyPartCritical(BodyPart))
				{
					PassThrough = Max(Health, Damage);
					DamageType = 'decapitated';
				}

				// Sever the limb
				if(!class'GameInfo'.Default.bLowGore)
				{
					BodyPartVisibility(BodyPart, false);
					BodyPartCollision(BodyPart, false);
					LimbSevered(BodyPart, Momentum);
				}
			}
		}
	}

	if (DamageType=='sever' || DamageType=='bluntsever')
	{	// spawn chunks
		NumChunks = (Damage / 15) + 1;
		NumChunks = NumChunks * Level.Game.DebrisPercentage;
		for(i = 0; i < NumChunks; i++)
		{
			Gib = spawn(GibClass,,, HitLocation + VRand() * 2,);
			if (Gib != None)
			{
				Gib.SetSize(RandRange(0.1, 0.4));
				Gib.SetMomentum((-0.08 * Momentum));
			}
		}
	}
	else if (DamageType == 'crushed')
	{	// Force the gib when crushed
		PassThrough = Default.Health*3;
		bGibbable = true;
	}

	// Apply damage to body
	if (PassThrough != 0)
	{
		bAlreadyDead = (Health <= 0);

//		AppliedDamage = Level.Game.ReduceDamage(PassThrough, DamageType, self, EventInstigator);
		AppliedDamage = PassThrough;

		Health -= AppliedDamage;

		if (Health > 0)
		{
			// Apply momentum
			// NOTE:  This code is duplicated in Shield.Active and Shield.Idle states
			AdjMomentum = momentum / Mass;
			if(Mass < VSize(AdjMomentum) && Velocity.Z <= 0)
			{			
				AdjMomentum.Z += (VSize(AdjMomentum) - Mass) * 0.5;
			}
			AddVelocity(AdjMomentum);
//			if (Velocity.Z == 0)
//				AddVelocity(momentum / Mass);

			if(CanGotoPainState())
			{ // Only goto the painstate if the pawn allows it 
				PlayTakeHitSound(AppliedDamage, DamageType, 1);

				if(PassThrough > 5) // DAMAGE_EPSILON = 5
				{ // Only go to the painstate if the damage is over a given level
					if (GetStateName() != 'Pain' && GetStateName() != 'pain')
					{
						NextStateAfterPain = GetStateName();

						// Play pain anim
						PlayTakeHit(0.1, AppliedDamage, HitLocation, DamageType, Momentum, BodyPart);
						GotoState('Pain');
					}
					return(false);
				}
			}
		}
		else if (bAlreadyDead)
		{	// Twitch corpse or Gib
			if(Health < -Default.Health && bGibbable && !bHidden)
			{ // Gib if beaten down far enough
				SpawnBodyGibs(Momentum);
				PlayDyingSound('gibbed');
				if (bIsPlayer)
					bHidden=true;
				else
					Destroy();
			}
		}
		else
		{ // Kill the creature
			AddVelocity(momentum * 2 / Mass);
			if(Health < -Default.Health && bGibbable)
			{ // Gib if beaten down far enough
				Died(EventInstigator, 'gibbed', HitLocation);
//				if (bIsPlayer)	// moved to died
//					bHidden=true;
//				else
//					Destroy();
			}
			else
			{
				// Apply momentum
				Died(EventInstigator, DamageType, HitLocation);
			}
		}
		MakeNoise(1.0);
	}

	return(false);
}


//------------------------------------------------------------
//
// SpawnCarcass
// 
//------------------------------------------------------------
function Carcass SpawnCarcass()
{
	local carcass carc;

	carc = Spawn(CarcassType,,,Location,Rotation);
	if (carc != None)
	{
		carc.Initfor(self);
	}

	return carc;
}


//------------------------------------------------------------
//
// SpawnBodyGibs
// 
// Subclass this to spawn specific gibs for a given creature
//------------------------------------------------------------

function SpawnBodyGibs(vector momentum)
{
	local int i, NumSourceGroups, numgibs;
	local Debris Gib;
	local vector loc;
	local float scale;
	local class<actor> partclass;
	local actor part;

	if (class'GameInfo'.Default.bLowGore )
		return;

	for (NumSourceGroups=1; NumSourceGroups<16; NumSourceGroups++)
	{
		if (SkelGroupSkins[NumSourceGroups] == None)
			break;
	}

	numgibs = GibCount;
	if (Level.Game != None)	//fixme: should be class'GameInfo'.default.DebrisPercentage
		numgibs = numgibs*Level.Game.DebrisPercentage;

	// Spawn some real body parts
	for (i=0; i<NUM_BODYPARTS; i++)
	{
		if (BodyPartMissing(i))
			continue;

		partclass = SeveredLimbClass(i);
		if (partclass != None)
		{
			numgibs--;
			BodyPartHealth[i] = 0;

			loc = VRand();
			loc.X *= CollisionRadius;
			loc.Y *= CollisionRadius;
			loc.Z *= CollisionHeight;
			loc += Location;
			part = Spawn(partclass, self,, loc, Rotation);
			if(part != None)
			{
				if (Momentum != vect(0,0,0))
					Velocity = (Normal(Momentum)*2 + VRand() + vect(0,0,1)) * RandRange(50,300);
				else
					Velocity = (VRand()*2+vect(0,0,2)) * RandRange(50,400);
				if (part.IsA('Weapon'))
					part.GotoState('Drop');
			}
		}
	}

	if (GibClass != None)
	{
		// Find appropriate size of chunks
		scale = (CollisionRadius*CollisionRadius*CollisionHeight) / (numgibs*600);
		scale = 0.8 * (scale ** 0.3333333);

		for (i = 0; i < numgibs; i++)
		{
			loc = VRand();
			loc.X *= CollisionRadius;
			loc.Y *= CollisionRadius;
			loc.Z *= CollisionHeight;
			loc += Location;

			Gib = spawn(GibClass,,, loc,);
			if (Gib != None)
			{
				Gib.SetSize(scale);
				Gib.SetMomentum(Momentum);
				if (FRand()<0.3)
					Gib.SetTexture(SkelGroupSkins[i%NumSourceGroups]);
			}
		}
	}
}


//------------------------------------------------------------
//
// MakeTwitchable
//
// TODO: Move this logic to carcass
//------------------------------------------------------------
function MakeTwitchable()
{
/*	local int j;

	// Turn all collision joints accelerative
	for (j=0; j<NumJoints(); j++)
	{
		if ((JointFlags[j] & JOINT_FLAG_COLLISION)==0)
			continue;

		JointFlags[j] = JointFlags[j] | JOINT_FLAG_ACCELERATIVE;
//		SetJointRotThreshold(j, 16000);
//		SetJointDampFactor(j, 0.025);
//		SetAccelMagnitude(j, 8000);
	}
*/
}


//------------------------------------------------------------
//
// Died
//
// Pawn has run out of health, kill him properly
//------------------------------------------------------------
function Died(pawn Killer, name damageType, vector HitLocation)
{
	local actor A;

	if ( bDeleteMe ) return; //already destroyed
	Health = Min(0, Health);
	Strength = 0; // Remove any bloodlust that has accumulated

	if(IsA('PlayerPawn') && PlayerPawn(self).bBloodlust)
	{ // Player is bloodlusting and was killed by the world, or suicided, remove bloodlust
		Strength = 1;
		PlayerPawn(self).StrengthDecay(1); // Force bloodlust off
	}
	
	if (Killer != None)
		Killer.Killed(Killer, self, damageType);
	Level.Game.Killed(Killer, self, damageType);

	// RUNE:  Guarantee that the powerup turns off when a player dies
	if(Weapon != None && Weapon.bPoweredUp)
		Weapon.PowerupEnd();

	if (Weapon!=None && Weapon.Class!=Level.Game.DefaultWeapon && Level.Game.AllowWeaponDrop())
		DropWeapon();
	if (Shield!=None && Shield.Class!=Level.Game.DefaultShield && Level.Game.AllowShieldDrop())
		DropShield();
	Level.Game.DiscardInventory(self);	// Delete the rest of the inventory

	// No longer make this a player look target
	bLookFocusPlayer = false;
	
	// Trigger any events
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Killer );

	// Play death animation for this type of death (head hit, gut hit, etc.)
	PlayDying(DamageType, HitLocation);
	PlayDyingSound(damageType);

	if (!bIsPlayer)
		bAlignToFloor = true;

	MakeTwitchable();

	if ( RemoteRole == ROLE_AutonomousProxy )
		ClientDying(DamageType, HitLocation);

	if(AnimProxy != None)
		AnimProxy.GotoState('Dying'); // RUNE:  Make sure the animproxy is in death state as well
	GotoState('Dying');
}


//------------------------------------------------------------
//
// WeaponActivate
//
//------------------------------------------------------------
function WeaponActivate()
{
	if(Weapon != None)
	{
		Weapon.StartAttack();
	}
}

//------------------------------------------------------------
//
// WeaponDeactivate
//
//------------------------------------------------------------
function WeaponDeactivate()
{
	if(Weapon != None)
	{
		Weapon.FinishAttack();
	}
}

//=============================================================================
//
// SwipeEffectStart
//
// Swipe Effect Notify
//=============================================================================

function SwipeEffectStart()
{
	if(Weapon != None)
	{
		Weapon.EnableSwipeTrail();
	}
}

//=============================================================================
//
// SwipeEffectEnd
//
// Swipe Effect Notify
//=============================================================================

function SwipeEffectEnd()
{
	if(Weapon != None)
	{
		Weapon.DisableSwipeTrail();
	}
}


//------------------------------------------------------------
//
// StopAttack
//
//------------------------------------------------------------
function StopAttack()
{
	WeaponDeactivate();
}

//------------------------------------------------------------
//
// ClearSwipeArray
//
//------------------------------------------------------------

function ClearSwipeArray()
{
	if(Weapon != None)
	{
		Weapon.ClearSwipeArray();
		Weapon.PlaySwipeSound();
	}
}

//=========================================================================
//
// DoThrow
// 
// Throw weapon notify
//=========================================================================
	
function DoThrow()
{
	if(Weapon != None)
		ThrowWeapon();
}

//------------------------------------------------------------
//
// ActivateShield
//
// Changes the state of current shield (in case needed later)
//------------------------------------------------------------
function ActivateShield(bool bOn)
{
	if (Shield == None)
		return;

	if (bOn)
	{
		Shield.GotoState('Active');
	}
	else
	{
		Shield.GotoState('Idle');
	}
}


//------------------------------------------------------------
//
// AllowWeaponToHitActor
//
// Event to notify pawn when weapon hits something
//------------------------------------------------------------
function bool AllowWeaponToHitActor(Weapon W, Actor A)
{
	return true;
}


//------------------------------------------------------------
//
// CanStabActor
//
// If the actor can be stabbed by a weapon
//------------------------------------------------------------

function bool CanStabActor()
{
	if(StabJoint == '')
		return(false);

	if(ActorAttachedTo(JointNamed(StabJoint)) != None)
		return(false);

	return(true);
}

//------------------------------------------------------------
//
// CheckDefending
//
// Checks if the Pawn is defending 
//------------------------------------------------------------

function bool CheckDefending()
{
	if(Shield != None)
	{ // Creature has a shield
		if(Shield.GetStateName() == 'Active')
		{ // The creature is defending
			return(true);
		}
	}

	return(false);
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
	return(1.0);
}

//=============================================================================
// Dynamic joint turning (head, jaw)
//=============================================================================

//------------------------------------------------------------
//
// AngleTo
//
// Returns absolute value of yaw angle to a location
//------------------------------------------------------------
function int AngleTo(vector pos)
{
	local int YawErr;
	local rotator targetangle;

	targetangle = rotator(pos - location);
	YawErr = targetangle.Yaw - Rotation.Yaw;
	
	// Fix angles (0..180,0..-180)
	while (YawErr > 32768)
		YawErr -= 65535;
	while (YawErr < -32768)
		YawErr += 65535;

	return( Abs(YawErr) );
}


//------------------------------------------------------------
//
// NeedToTurn
//
// Returns whether I need to turn to see a location
//------------------------------------------------------------
function bool NeedToTurn(vector targ)
{
	local int MaxYaw;

	MaxYaw = 1000;	// Tolerance for looking
	if (bRotateHead)
		MaxYaw += MaxHeadAngle.Yaw;
	if (bRotateTorso)
		MaxYaw += MaxBodyAngle.Yaw;

	return (AngleTo(targ) > MaxYaw);
}


//------------------------------------------------------------
//
// Tick
//
//------------------------------------------------------------
simulated function Tick(float DeltaTime)
{
	SkeletonLook(DeltaTime);
//	Look(DeltaTime);
	Jaw (DeltaTime);
}

//------------------------------------------------------------
//
// OpenMouth
//
// Changes pawn's jaw openness if capable
//  amount[0..1] 0 is completely closed, 1 is completely open
//  rate[0..1]   0 is not moving, 1 is move at max rate
//------------------------------------------------------------
function OpenMouth(float amount, float rate)
{
	DesiredMouthRot = MaxMouthRot * amount;
	MouthRotRate    = MaxMouthRotRate * rate;
}


//------------------------------------------------------------
//
// Jaw
//
// Takes care of moving the jaw smoothly
//------------------------------------------------------------
simulated function Jaw(float DeltaSeconds)
{
	local rotator r;

	if (MaxMouthRotRate > 0)
	{
		if (MouthRot < DesiredMouthRot)
		{
			MouthRot += MouthRotRate * DeltaSeconds;
			if (MouthRot > DesiredMouthRot)
				MouthRot = DesiredMouthRot;
		}
		else if (MouthRot > DesiredMouthRot)
		{
			MouthRot -= MouthRotRate * DeltaSeconds;
			if (MouthRot < DesiredMouthRot)
				MouthRot = DesiredMouthRot;
		}
		r.Yaw = 0;
		r.Roll = 0;
		r.Pitch = MouthRot;
		SetJointRot(JointNamed('jaw'), r);
	}
}


//------------------------------------------------------------
//
// LookAt
//
// Look at an actor if not looking at a location
//------------------------------------------------------------
function LookAt(actor A, optional bool force)
{
	if (bCanLook)
	{
		if (force || LookSpot == vect(0,0,0))
			LookTarget = A;
	}
}

//------------------------------------------------------------
//
// LookToward
//
// Set a spot to be looked at when not looking at an actor
//------------------------------------------------------------
function LookToward(vector pos, optional bool force)
{
	if (bCanLook)
	{
		if (force)
			LookTarget = None;
		LookSpot = pos;
	}
}

//------------------------------------------------------------
//
// StopLookingToward
//
//------------------------------------------------------------
function StopLookingToward()
{
	lookspot = vect(0,0,0);
}

function CalcLookAngle()
{
}


native(670) final function SkeletonLook(float DeltaTime);
/*
//------------------------------------------------------------
//
// Look
//
// Make pawn look around
//------------------------------------------------------------
simulated function Look(float DeltaTime)
{
	local int head,body;
	local float headdeg,bodydeg,rotvel;
	local rotator headangle, bodyangle;
	local rotator ragnarRot;
	local float headPitchUp;
	local int joint;
	
	if (!bCanLook)
		return;

	if(Health <= 0)
		return;

	ragnarRot = Rotation;
	ragnarRot.Pitch = 0;
	
	if (bOverrideLookTarget)
	{
		// Use existing targetangle
	}
	else if (LookTarget != None)
	{	// Look at LookTarget
		targetangle = rotator(LookTarget.Location - Location);
		targetangle -= ragnarRot;
	}
	else if (LookSpot.X!=0 || LookSpot.Y!=0 || LookSpot.Z!=0)
	{	// Look at LookSpot
		targetangle = rotator(LookSpot - Location);
		targetangle -= ragnarRot;
	}
	else
	{	// Look straight ahead
		targetangle = rot(0,0,0);
	}

	// Fix angles (0..180,0..-180)
	while (targetangle.Yaw > 32768)
		targetangle.Yaw = targetangle.Yaw - 65535;
	while (targetangle.Yaw < -32768)
		targetangle.Yaw = targetangle.Yaw + 65535;
	while (targetangle.Pitch > 32768)
		targetangle.Pitch = targetangle.Pitch - 65535;
	while (targetangle.Pitch < -32768)
		targetangle.Pitch = targetangle.Pitch + 65535;

	rotvel = LookDegPerSec * 65535.0 / 360.0;
		
	// If target is in dead zone, return to looking forward
	if (cos(targetangle.Yaw*2.0*Pi/65535.0) < PeripheralVision)
	{
		targetangle = rot(0,0,0);
		rotvel *= 0.5;				// slower rate when returning to straight
	}

	// Yaw towards target angle
	if (targetangle.Yaw < LookAngle.Yaw)
	{	// Turning left
		LookAngle.Yaw -= rotvel * DeltaTime;
		if (LookAngle.Yaw < targetangle.Yaw)	// Disallow overshoot
			LookAngle.Yaw = targetangle.Yaw;
	}
	else
	{	// Turning right
		LookAngle.Yaw += rotvel * DeltaTime;
		if (LookAngle.Yaw > targetangle.Yaw)	// Disallow overshoot
			LookAngle.Yaw = targetangle.Yaw;
	}

	// Pitch towards target angle
	rotvel = 0.5 * LookDegPerSec * 65535.0 / 360.0;
	if (targetangle.Pitch < LookAngle.Pitch)
	{	// Pitching Up
		LookAngle.Pitch -= rotvel * DeltaTime;
		if (LookAngle.Pitch < targetangle.Pitch)
			LookAngle.Pitch = targetangle.Pitch;
	}
	else
	{	// Pitching Down
		LookAngle.Pitch += rotvel * DeltaTime;
		if (LookAngle.Pitch > targetangle.Pitch)
			LookAngle.Pitch = targetangle.Pitch;
	}

	if(bHeadLookUpDouble)
	{
		headPitchUp = MaxHeadAngle.Pitch * 2;
	}
	else
	{
		headPitchUp = MaxHeadAngle.Pitch;
	}

	// Now translate LookAngle.Yaw into head and body angles
	if (bRotateHead)
	{
		headangle = LookAngle;


		// Overflow any extra angle beyond head maximums into body
		if (headangle.Yaw > MaxHeadAngle.Yaw)
		{
			bodyangle.Yaw = headangle.Yaw - MaxHeadAngle.Yaw;
			headangle.Yaw = MaxHeadAngle.Yaw;
		}
		else if (headangle.Yaw < -MaxHeadAngle.Yaw)
		{
			bodyangle.Yaw = headangle.Yaw + MaxHeadAngle.Yaw;
			headangle.Yaw = -MaxHeadAngle.Yaw;
		}

		if (headangle.Pitch > headPitchUp)
		{
			bodyangle.Pitch = headangle.Pitch - headPitchUp;
			headangle.Pitch = headPitchUp;
		}
		else if (headangle.Pitch < -MaxHeadAngle.Pitch)
		{
			bodyangle.Pitch = headangle.Pitch + MaxHeadAngle.Pitch;
			headangle.Pitch = -MaxHeadAngle.Pitch;
		}
	}
	else if (bRotateTorso)
	{
		bodyangle = LookAngle;
	}
	
	// Do head roll
	if (MaxHeadAngle.Roll > 0)	// TODO: Make proportional
		headangle.Roll = headangle.Yaw / 2;
	if (MaxBodyAngle.Roll > 0)  // TODO: Make proportional
		bodyangle.Roll = bodyangle.Yaw / 2;

	// Clamp to max angles
	bodyangle.Yaw   = Clamp(bodyangle.Yaw,   -MaxBodyAngle.Yaw,   MaxBodyAngle.Yaw);
	bodyangle.Pitch = Clamp(bodyangle.Pitch, -MaxBodyAngle.Pitch, MaxBodyAngle.Pitch);
	bodyangle.Roll  = Clamp(bodyangle.Roll,  -MaxBodyAngle.Roll,  MaxBodyAngle.Roll);
	headangle.Yaw   = Clamp(headangle.Yaw,   -MaxHeadAngle.Yaw,   MaxHeadAngle.Yaw);
	headangle.Pitch = Clamp(headangle.Pitch, -MaxHeadAngle.Pitch, headPitchUp);
	headangle.Roll  = Clamp(headangle.Roll,  -MaxHeadAngle.Roll,  MaxHeadAngle.Roll);

//headdeg = headangle.Yaw * 360.0 / 65536.0;
//bodydeg = bodyangle.Yaw * 360.0 / 65536.0;
//SLog("Head="$headdeg$" Body="$bodydeg);

	headangle += Rotation;
	bodyangle += Rotation;

	joint = JointNamed('torso');
	if (joint != 0)
	{
		if (bRotateTorso)
			TurnJointTo(joint, bodyangle);
		else
			TurnJointTo(joint, Rotation); // No extra rotation
	}

	joint = JointNamed('head');
	if (joint != 0)
	{
		if (bRotateHead)
			TurnJointTo(joint, headangle);
		else
			TurnJointTo(joint, Rotation); // No extra rotation
	}
}
*/

//=============================================================================
//
// UseNotify
//
// Notify used by animations to specify when the use should occur
//=============================================================================

function UseNotify()
{
	if(UseActor != None)
		UseActor.UseTrigger(self);

	UseActor = None;
}

//------------------------------------------------------------
//
// Uninterrupted
//
// This state does not allow the pawn to be interrupted while
// the pawn is performing a specific action.  Note that the pawn
// will still take pain (but not enter the painstate) and die (and WILL
// go into the death state) while in this state.
//------------------------------------------------------------

function PlayUninterruptedAnim(name Anim)
{
	if(GetStateName() != 'Uninterrupted')
	{
		Velocity.X = 0;
		Velocity.Y = 0;
		Acceleration = vect(0, 0, 0);
		
		UninterruptedAnim = Anim;
		NextState = GetStateName();
		GotoState('Uninterrupted');
		
		if(AnimProxy != None)
			AnimProxy.GotoState('Uninterrupted');
	}
}

state Uninterrupted
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, Landed;

	function bool CanGotoPainState()
	{ // Do not allow the actor to enter the painstate when in uninterrupted mode
		return(false);
	}

	function BeginState()
	{
		if(UninterruptedAnim != 'None')
		{
			PlayAnim(UninterruptedAnim, 1.0, 0.1);
			if(AnimProxy != None)
				AnimProxy.PlayAnim(UninterruptedAnim, 1.0, 0.1);
		}
	}

	function EndState()
	{
		UninterruptedAnim = 'None';
	}

	function AnimEnd()
	{
		// Clear out any blending information (if it exists)
		BlendAnimSequence = 'None';
		if(AnimProxy != None)
		{
			AnimProxy.BlendAnimSequence = 'None';			
			AnimProxy.GotoState('Idle');
		}

		if(Weapon != None)
		{ // If there is a weapon, make the weapon go cold if it was hot during this animation
			Weapon.FinishAttack();
			Weapon.DisableSwipeTrail();
		}

		GotoState(NextState);
	}

	function Tick(float DeltaSeconds)
	{
		Global.Tick(DeltaSeconds);
	}
}


//------------------------------------------------------------
//
// Pain
//
//------------------------------------------------------------
state Pain
{
	function bool CanGotoPainState()
	{ // Do not allow the actor to enter the painstate when already in pain
		return(false);
	}

	function EndState()
	{
		NextStateAfterPain = '';
	}

Begin:

	if(PainDelay < 0)
	{ // If PainDelay is negative, the painstate waits until the anim has completed
		FinishAnim();
	}
	else
	{ // Otherwise, just use the PainDelay
		Sleep(PainDelay);
	}
//slog(name@"in painstate: going to"@NextStateAfterPain);
	if (NextStateAfterPain == '' && !bIsPlayer)	// hack for dwarf stuck in pain bug
		GotoState('Charging');
	else
		GotoState(NextStateAfterPain);
}


//------------------------------------------------------------
//
// STATE Dying
//
//------------------------------------------------------------
state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, Landed;

	function bool CanBeStatued()						{	return false;	}
	function PowerupStone(Pawn EventInstigator)			{}
	function PowerupIce(Pawn EventInstigator)			{}
	function PowerupFire(Pawn EventInstigator)			{}
	function PowerupBlaze(Pawn EventInstigator)			{}
	function PowerupFriend(Pawn EventInstigator)		{}
	function PowerupElectricity(Pawn EventInstigator)	{}

	function ReplaceWithCarcass()
	{
		local Carcass C;

		// Replace with a carcass if there is one
		if (!bHidden && CarcassType != None)
		{
			C = SpawnCarcass();
			if (C!=None)
			{
				C.RemovedStabbedWeapon(); // Remove a stabbed weapon if one exists
				C.SetBase(Base);
			}

			if (bIsPlayer)
			{
				HidePlayer();
			}
			else
			{
				bHidden=true;
				Destroy();
			}
		}
	}

	function ExpandCollisionRadius()
	{
		SetCollision(false, false, false);
		bCollideWorld = false;

		SetCollisionSize(DeathRadius, CollisionHeight);

		SetCollision(true, false, false);	// Allow to clip through other corpses
		bCollideWorld = true;
	}

	function ShrinkCollisionHeight()
	{
		local vector newloc;
		local float offset;

		SetCollision(false, false, false);
		bCollideWorld = false;

		SetCollisionSize(CollisionRadius, DeathHeight);

		// Adjust so corpse is lying on ground
		offset = default.CollisionHeight - default.DeathHeight;
		newloc = Location;
		newloc.Z -= offset;
		SetLocation(newloc);
		PrePivot.Z += offset;

		SetCollision(true, false, false);	// Allow to clip through other corpses
		bCollideWorld = true;
		bAllowStandOn=true;
	}

	function ApplyPainToJoint(int joint, vector momentum)
	{
		if ((JointFlags[joint] & JOINT_FLAG_ACCELERATIVE) != 0)
		{
			//slog("moving"@GetJointName(joint));
			ApplyJointForce(joint, Momentum);
		}
	}

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{	// Do spasm
		ApplyPainToJoint(joint, Momentum);
		Super(Actor).JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
	}

	function Done()
	{
		SetPhysics(PHYS_None);
		bCollideWorld = false;
		ReplaceWithCarcass();
	}

Begin:
	LookTarget=None;
	LookSpot=vect(0,0,0);
	Goto('PreDeath');

PreDeath:
	Goto('Death');

Death:
	ExpandCollisionRadius();
	SetPhysics(PHYS_Falling);

	WaitForLanding();
	FinishAnim();

	ShrinkCollisionHeight();
	Done();
	Goto('PostDeath');

PostDeath:
}

/*
state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, Landed;

	function ReplaceWithCarcass()
	{
		local Carcass C;

		ShrinkCollisionHeight();

		// Replace with a carcass if there is one
		if (!bHidden && CarcassType != None)
		{
			C = SpawnCarcass();
			C.RemovedStabbedWeapon(); // Remove a stabbed weapon if one exists

			if (bIsPlayer)
			{
				HidePlayer();
			}
			else
			{
				bHidden=true;
				Destroy();
			}
		}
	}

	function ExpandCollisionRadius()
	{
		SetCollision(false, false, false);
		bCollideWorld = false;

		SetCollisionSize(DeathRadius, CollisionHeight);

		SetCollision(true, false, true);	// Allow to clip through other corpses
		bCollideWorld = true;
	}

	function ShrinkCollisionHeight()
	{
		local vector newloc;
		local float offset;

		SetCollision(false, false, false);
		bCollideWorld = false;

		SetCollisionSize(CollisionRadius, DeathHeight);

		// Adjust so corpse is lying on ground
		offset = default.CollisionHeight - default.DeathHeight;
		newloc = Location;
		newloc.Z -= offset;
		SetLocation(newloc);
		PrePivot.Z += offset;

		SetCollision(true, false, true);	// Allow to clip through other corpses
		bCollideWorld = true;
		bAllowStandOn=true;
	}

	function ApplyPainToJoint(int joint, vector momentum)
	{
		if ((JointFlags[joint] & JOINT_FLAG_ACCELERATIVE) != 0)
		{
			//slog("moving"@GetJointName(joint));
			ApplyJointForce(joint, Momentum);
		}
	}

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{	// Do spasm
		ApplyPainToJoint(joint, Momentum);
		Super(Actor).JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
	}

	function BeginState()
	{
		LookTarget=None;
		LookSpot=vect(0,0,0);
		SetTimer(0.3, false);
	}

	event Landed(vector HitNormal, actor HitActor)
	{
		SetPhysics(PHYS_None);
	}

	function Timer()
	{
		ReplaceWithCarcass();
	}

Begin:
	Goto('PreDeath');

PreDeath:
	Goto('Death');

Death:
	Goto('PostDeath');

PostDeath:
}
*/



//------------------------------------------------------------
//
// STATE GameEnded
//
//------------------------------------------------------------
state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, JointDamaged, WarnTarget, Died;

	function BeginState()
	{
		SetPhysics(PHYS_None);
		HidePlayer();
	}
}


//=============================================================================
// Skin support
//=============================================================================
static function int GetNumSkins()
{
	return 1;
}

static function string GetSkinName(int Skin)
{
	switch(Skin)
	{
		case 0:		return default.SkinDefaultText;
	}
	return "";
}

static function SetSkinActor(actor SkinActor, int NewSkin)
{
	local int i;

	switch(NewSkin)
	{
		case 0:
		default:
			for (i=0; i<16; i++)
			{
				SkinActor.SkelGroupSkins[i] = Default.SkelGroupSkins[i];
			}
			break;
	}
}

function SpecialPainSkin(int BodyPart)
{
}


// Powerup support
function PowerupStone(Pawn EventInstigator);
function PowerupIce(Pawn EventInstigator);
function PowerupFire(Pawn EventInstigator);
function PowerupBlaze(Pawn EventInstigator);
function PowerupFriend(Pawn EventInstigator);
function PowerupElectricity(Pawn EventInstigator);


simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);
	
	Canvas.DrawText("Pawn:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  Health:     " $ Health);
	Canvas.CurY -= 8;
	Canvas.DrawText("  Weapon:     " $ Weapon);
	Canvas.CurY -= 8;
	Canvas.DrawText("  Shield:     " $ Shield);
	Canvas.CurY -= 8;
	Canvas.DrawText("  Enemy:      " $ Enemy);
	Canvas.CurY -= 8;
	Canvas.DrawText("  LookTarget: " $ LookTarget);
	Canvas.CurY -= 8;
	Canvas.DrawText("  LookSpot:   " $ LookSpot);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bOverrideLookTarget: " $ bOverrideLookTarget);
	Canvas.CurY -= 8;
	Canvas.DrawText("  HighSwing:  " $ bSwingingHigh);
	Canvas.CurY -= 8;
	Canvas.DrawText("  LowSwing:   " $ bSwingingLow);
	Canvas.CurY -= 8;
	Canvas.DrawText("  NextState:  " $ NextState);
	Canvas.CurY -= 8;
	Canvas.DrawText("  NextStateAfterPain: " $ NextStateAfterPain);
	Canvas.CurY -= 8;
	Canvas.DrawText("  intelligence: "$ intelligence);
	Canvas.CurY -= 8;

/*
	Canvas.DrawText("  Cos(LookAngle): " $ cos(LookAngle.Yaw*2.0*Pi/65535.0));
	Canvas.CurY -= 8;
	Canvas.DrawText("  PeriphVision:   " $ PeripheralVision);
	Canvas.CurY -= 8;
	Canvas.DrawText("  LookYaw:    " $ LookAngle.Yaw);
	Canvas.CurY -= 8;
	Canvas.DrawText("  LookPitch:  " $ LookAngle.Pitch);
	Canvas.CurY -= 8;
*/
}

defaultproperties
{
     AvgPhysicsTime=0.100000
     MaxDesiredSpeed=1.000000
     GroundSpeed=320.000000
     WaterSpeed=200.000000
     AccelRate=500.000000
     JumpZ=325.000000
     MaxStepHeight=25.000000
     AirControl=0.050000
     Visibility=128
     SightRadius=2500.000000
     HearingThreshold=1.000000
     OrthoZoom=40000.000000
     FovAngle=75.000000
     Health=100
     MaxHealth=100
     MaxStrength=100
     MaxPower=100
     PainDelay=0.300000
     bGibbable=True
     AttitudeToPlayer=ATTITUDE_Hate
     Intelligence=BRAINS_MAMMAL
     noise1time=-10.000000
     noise2time=-10.000000
     FootstepVolume=0.330000
     SoundDampening=1.000000
     DamageScaling=1.000000
     PlayerReStartState=PlayerWalking
     NameArticle=" a "
     PlayerReplicationInfoClass=Class'Engine.PlayerReplicationInfo'
     MaxBodyAngle=(Yaw=8192)
     MaxHeadAngle=(Pitch=4096,Yaw=8192)
     bRotateHead=True
     bRotateTorso=True
     LookDegPerSec=360.000000
     DeathRadius=22.000000
     DeathHeight=22.000000
     SkinDefaultText="Default"
     bCanTeleport=True
     bStasis=True
     bIsPawn=True
     bLookFocusPlayer=True
     RemoteRole=ROLE_SimulatedProxy
     AnimSequence=Fighter
     bDirectional=True
     Texture=Texture'Engine.S_Pawn'
     bIsKillGoal=True
     SoundRadius=9
     SoundVolume=240
     TransientSoundVolume=2.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bSweepable=True
     bRotateToDesired=True
     RotationRate=(Pitch=4096,Yaw=50000,Roll=3072)
     NetPriority=2.000000
}
