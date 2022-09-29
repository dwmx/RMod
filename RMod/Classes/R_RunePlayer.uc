//==============================================================================
//  R_RunePlayer
//  Base player class for all players in RMod.
//  For custom player classes in custom game modes, modify
//  R_GameInfo.RunePlayerClass.
//==============================================================================
class R_RunePlayer extends RunePlayer config(RMod);

var Class<R_AUtilities> UtilitiesClass;

var Class<RunePlayer> RunePlayerSubClass;
var Class<RunePlayerProxy> RunePlayerProxyClass;
var Class<Actor> RunePlayerSeveredHeadClass;
var Class<Actor> RunePlayerSeveredLimbClass;
var byte PolyGroupBodyParts[16];

var Class<HUD> HUDTypeSpectator;

var Class<R_ACamera> SpectatorCameraClass;
var R_ACamera Camera;

var R_LoadoutReplicationInfo LoadoutReplicationInfo;

// Replicated POV view rotation
var private float ViewRotPovPitch;
var private float ViewRotPovYaw;

// When bForceClientAdjustPosition is true, ServerMove will force a client
// adjust on the owning player
var bool bForceClientAdjustPosition;

// PainSkin arrays
const MAX_SKEL_GROUP_SKINS = 16;
struct FSkelGroupSkinArray
{
	var Texture Textures[16];
};
// Indexed by BODYPART consts
var FSkelGroupSkinArray PainSkinArrays[16];
var FSkelGroupSkinArray GoreCapArrays[16];

var float SuicideTimeStamp;
var float SuicideCooldown;

replication
{	
	reliable if(Role == ROLE_Authority && bNetInitial)
		RunePlayerSubClass;
	
	reliable if(Role == ROLE_Authority)
		HUDTypeSpectator,
		Camera;

	reliable if(Role == ROLE_Authority && RemoteRole == ROLE_AutonomousProxy)
        LoadoutReplicationInfo,
		ClientReceiveUpdatedGamePassword,
		ClientPreTeleport;

	reliable if(Role < ROLE_Authority)
		ServerResetLevel,
		ServerSwitchGame,
		ServerSpectate,
		ServerTimeLimit;
		
	unreliable if(Role == ROLE_Authority && RemoteRole != ROLE_AutonomousProxy)
		ViewRotPovPitch,
		ViewRotPovYaw;
}

/**
*   PreBeginPlay (override)
*   Overridden to allow player replication info and anim proxy to be spawned
*   based on classes.
*/
event PreBeginPlay()
{
	Enable('Tick');

	if(R_GameInfo(Level.Game) != None)
	{
		PlayerReplicationInfoClass = R_GameInfo(Level.Game).PlayerReplicationInfoClass;
	}

    // Bypass RunePlayer's PreBeginPlay, because it will respawn anim proxy
	Super(PlayerPawn).PreBeginPlay();

	// Spawn Torso Animation proxy
	AnimProxy = Spawn(Self.RunePlayerProxyClass, Self);

	OldCameraStart = Location;
	OldCameraStart.Z += CameraHeight;

	CurrentDist = CameraDist;
	LastTime = 0;
	CurrentTime = 0;
	CurrentRotation = Rotation;

	// Adjust CrouchHeight to new DrawScale
	CrouchHeight = CrouchHeight * DrawScale;		
}

/**
*   PostBeginPlay (override)
*   Grab additional data from R_GameInfo at startup
*/
event PostBeginPlay()
{
	local R_GameInfo RGI;
    local R_GameOptions RGO;

	Super.PostBeginPlay();

	RGI = R_GameInfo(Level.Game);
	if(RGI != None)
	{
		HUDTypeSpectator = RGI.HUDTypeSpectator;

        RGO = RGI.GameOptions;
        if(RGO != None)
        {
            if(RGO.bOptionLoadoutEnabled)
            {
                SpawnLoadoutReplicationInfo();
            }
        }
	}
}

function SpawnLoadoutReplicationInfo()
{
    if(Role == ROLE_Authority)
    {
        LoadoutReplicationInfo = Spawn(Class'RMod.R_LoadoutReplicationInfo', Self);
    }
}

event Destroyed()
{
    Super.Destroyed();

    if(LoadoutReplicationInfo != None)
    {
        LoadoutReplicationInfo.Destroy();
    }
}

/**
*   PreTeleport (override)
*   Overridden to bypass camera interpolation and make teleporting feel
*   seamless (still needs work).
*/
event bool PreTeleport(Teleporter InTeleporter)
{
	if(!Super.PreTeleport(InTeleporter))
	{
		return false;
	}

	if(Role == ROLE_Authority)
	{
		ClientPreTeleport(InTeleporter);
	}
	DoPreTeleport(InTeleporter);
	return true;
}

function ClientPreTeleport(Teleporter InTeleporter)
{
	DoPreTeleport(InTeleporter);
}

/**
*   DoPreTeleport
*   Runs on both server and client. Updates all variables involved
*   in camera interpolation to make teleporting feel seamless.
*/
function DoPreTeleport(Teleporter InTeleporter)
{
	local Rotator NewRotation;
	local Vector NewLocation;
	local Rotator NewViewRotation;

	// Client-side prediction
	if(Role < ROLE_Authority)
	{
		NewRotation = InTeleporter.Rotation;
		NewRotation.Pitch = 0;
		NewRotation.Roll = 0;

		NewLocation = InTeleporter.Location;

		OldCameraStart = (OldCameraStart - Location) + NewLocation;
		SavedCameraLoc = (SavedCameraLoc - Location) + NewLocation;
		
		NewViewRotation = NewRotation;
		NewViewRotation.Pitch = ViewRotation.Pitch;

		ViewLocation = SavedCameraLoc;
		ViewRotation = NewViewRotation;

		SetLocation(NewLocation);
		SetRotation(NewRotation);
	}
}

/**
*   PreRender (override)
*   Overridden to ensure that when the player is not in spectator state,
*   they will use the normal HUD. Spectator state applies a different HUD.
*/
event PreRender( canvas Canvas )
{
	if (bDebug==1)
	{
		if (myDebugHUD   != None)
			myDebugHUD.PreRender(Canvas);
		else if ( Viewport(Player) != None )
			myDebugHUD = spawn(Class'Engine.DebugHUD', self);
	}

	// Ensure normal hud is in use
	if(myHUD != None && R_RunePlayerHUDSpectator(myHUD) != None)
	{
		myHUD.Destroy();
	}

	if(myHUD == None || (myHUD != None && HUDType != None && myHUD.Class != HUDType))
	{
		if(myHUD == None)
		{
			myHUD.Destroy();
		}
		myHUD = Spawn(HUDType, Self);
	}

	if(myHUD != None)
	{
		myHUD.PreRender(Canvas);
	}

	if (bClientSideAlpha)
	{
		OldStyle = Style;
		OldScale = AlphaScale;
		Style = STY_AlphaBlend;
		AlphaScale = ClientSideAlphaScale;
	}
}

/**
*   AdminLogin (override)
*   Overridden to log AdminLogin attempts.
*/
exec function AdminLogin(String Password)
{
    local String PlayerName;

    PlayerName = "";
    if(PlayerReplicationInfo != None)
    {
        PlayerName = PlayerReplicationInfo.PlayerName;
    }

    UtilitiesClass.Static.RModLog
    (
        "AdminLogin attempt from player" @ PlayerName @ "(" $ Self $ "):" @ Password
    );

    Level.Game.AdminLogin(Self, Password);
}

/**
*   AdminLogout (override)
*   Overridden to log AdminLogout attempts.
*/
exec function AdminLogout()
{
    local String PlayerName;

    PlayerName = "";
    if(PlayerReplicationInfo != None)
    {
        PlayerName = PlayerReplicationInfo.PlayerName;
    }

    UtilitiesClass.Static.RModLog
    (
        "AdminLogout attempt from player" @ PlayerName @ "(" $ Self $ "):" @ Password
    );

    Level.Game.AdminLogout( Self );
}

/**
*   VerifyAdminWithErrorMessage
*   Check if this player has admin rights and send a client message if not.
*/
function bool VerifyAdminWithErrorMessage()
{
	if(bAdmin)
	{
		return true;
	}
	else
	{
		ClientMessage("You need administrator rights");
		return false;
	}
	return false;
}

/**
*   Admin (override)
*   Overridden to route all admin commands through verification function.
*/
exec function Admin(String CommandLine)
{
    local String Result;

    if(!VerifyAdminWithErrorMessage())
    {
        return;
    }

    Result = ConsoleCommand(CommandLine);
    if(Result != "")
    {
        ClientMessage(Result);
    }
}

/**
*   ClientReceiveUpdatedGamePassword
*   Called from R_GameInfo when game password is updated. This allows
*   administrators to password the server without losing everyone on
*   map change. Useful for competitive games.
*/
function ClientReceiveUpdatedGamePassword(String NewGamePassword)
{
	UpdateURL("Password", NewGamePassword, false);
	ClientMessage("Local password has been updated:" @ NewGamePassword);
}

/**
*   LogPlayerIDs
*   Print all player IDs to the client's log.
*/
exec function LogPlayerIDs()
{
	local PlayerReplicationInfo PRI;
	
	UtilitiesClass.Static.RModLog("LogPlayerIDs output:");
	foreach AllActors(Class'Engine.PlayerReplicationInfo', PRI)
	{
		UtilitiesClass.Static.RModLog(
			"ID: " $ PRI.PlayerID $ ", " $
			"Name: " $ PRI.PlayerName);
	}
}

/**
*   DiscardInventory
*   Clear this player's entire inventory. GameInfo has a DiscardInventory
*   function of its own and I don't fully remember why this is here.
*/
function DiscardInventory()
{
	local Inventory Curr;
	local Inventory Next;
	
	for(Curr = Self.Inventory; Curr != None; Curr = Next)
	{
		Next = Curr.Inventory;
		DeleteInventory(Curr);
		Curr.Destroy();
	}
	
	Self.Weapon = None;
	Self.SelectedItem = None;
	Self.Shield = None;
	
	Self.StowSpot[0] = None;
	Self.StowSpot[1] = None;
	Self.StowSpot[2] = None;
}

/**
*   ChangeName (override)
*   Overridden to cause GameInfo to broadcast a message
*   when players change their names.
*/
function ChangeName(coerce String S)
{
    // Last arg = true causes GameInfo to broadcast a message
	Level.Game.ChangeName(Self, S, true);
}

/**
*   ApplySubClass
*   The following functions are responsible for extracting all custom skin-based
*   data from the provided RunePlayer class, and applying it to this instance.
*   This is called during the login sequence from R_GameInfo.
*/
function ApplySubClass(Class<RunePlayer> SubClass)
{
	local RunePlayer Dummy;
    local int i, j;
	
	Self.RunePlayerSubClass = SubClass;
	ApplySubClass_ExtractDefaults(SubClass);
	
	// Spawn a Dummy instance to get info from functions
	if(Role == ROLE_Authority
	&& R_GameInfo(Level.Game) != None
	&& SubClass != R_GameInfo(Level.Game).SpectatorMarkerClass)
	{
		// Disable collision so Dummy pawn doesn't explode
		Self.SetCollision(false, false, false);
		Dummy = Spawn(SubClass, self);
		if(Dummy != None)
		{
			Dummy.SetCollision(false, false, false);
			Dummy.bHidden = true;
			Dummy.RemoteRole = ROLE_None;

			ApplySubClass_ExtractBodyPartData(SubClass, Dummy);
			ApplySubClass_ExtractPainSkinData(SubClass, Dummy);
			ApplySubClass_ExtractGoreCapData(SubClass, Dummy);
			
			// Destroy Dummy and turn collision back on
			//		When you spawn a PlayerPawn, GameInfo.Login does not get called,
			//		but GameInfo.Logout DOES get called when the pawn is destroyed.
			//		This is the cause of the negative player count bug.
			//		R_GameInfo looks for the dummy tag and ignores the destroyed
			//		pawn at GameInfo.Logout to bypass the issue
			ApplyDummyTag(Dummy);
			Dummy.Destroy();
		}
		Self.SetCollision(true, true, true);
	}

	// Extract the menu name so this looks correct in server browser
	ApplySubClass_ExtractMenuName(SubClass);
}

/**
*   ApplyDummyTag
*   Apply the tag that R_GameInfo.Logout will look for when ignoring dummies.
*/
static function ApplyDummyTag(Actor A)
{
	A.Tag = 'RMODDUMMY';
}

/**
*   CheckForDummyTag
*   Check if the provided actor has the dummy tag applied.
*/
static function bool CheckForDummyTag(Actor A)
{
	if(A.Tag == 'RMODDUMMY')
	{
		return true;
	}
	return false;
}

/**
*   ApplySubClass_ExtractDefaults
*   Extract all relevant default properties from the RunePlayer class.
*/
function ApplySubClass_ExtractDefaults(Class<RunePlayer> SubClass)
{
	local int i;

	Self.WeaponPickupSound          = SubClass.Default.WeaponPickupSound;
    Self.WeaponThrowSound           = SubClass.Default.WeaponThrowSound;
    Self.WeaponDropSound            = SubClass.Default.WeaponDropSound;
    for(i = 0; i < 3; ++i)
        Self.JumpGruntSound[i]      = SubClass.Default.JumpGruntSound[i];
    Self.JumpSound                  = SubClass.Default.JumpSound;
    Self.LandGrunt                  = SubClass.Default.LandGrunt;
    Self.FallingDeathSound          = SubClass.Default.FallingDeathSound;
    Self.FallingScreamSound         = SubClass.Default.FallingScreamSound;
    Self.UnderWaterDeathSound       = SubClass.Default.UnderWaterDeathSound;
    Self.EdgeGrabSound              = SubClass.Default.EdgeGrabSound;
    Self.StepUpSound                = SubClass.Default.StepUpSound;
    Self.KickSound                  = SubClass.Default.KickSound;
    for(i = 0; i < 3; ++i)
        Self.HitSoundLow[i]         = SubClass.Default.HitSoundLow[i];
    for(i = 0; i < 3; ++i)
        Self.HitSoundMed[i]         = SubClass.Default.HitSoundMed[i];
    for(i = 0; i < 3; ++i)
        Self.HitSoundHigh[i]        = SubClass.Default.HitSoundHigh[i];
    for(i = 0; i < 6; ++i)
        Self.UnderWaterAmbient[i]   = SubClass.Default.UnderWaterAmbient[i];
    Self.BerserkSoundStart          = SubClass.Default.BerserkSoundStart;
    Self.BerserkSoundEnd            = SubClass.Default.BerserkSoundEnd;
    Self.BerserkSoundLoop           = SubClass.Default.BerserkSoundLoop;
    for(i = 0; i < 6; ++i)
        Self.BerserkYellSound[i]    = SubClass.Default.BerserkYellSound[i];
    Self.CrouchSound                = SubClass.Default.CrouchSound;
    for(i = 0; i < 3; ++i)
        Self.RopeClimbSound[i]      = SubClass.Default.RopeClimbSound[i];
    Self.Die                        = SubClass.Default.Die;
    Self.Die2                       = SubClass.Default.Die2;
    Self.Die3                       = SubClass.Default.Die3;
    Self.MaxMouthRot                = SubClass.Default.MaxMouthRot;
    Self.MaxMouthRotRate            = SubClass.Default.MaxMouthRotRate;
    Self.SkelMesh                   = SubClass.Default.SkelMesh;
    for(i = 0; i < 16; ++i)
        Self.SkelGroupSkins[i]      = SubClass.Default.SkelGroupSkins[i];
    for(i = 0; i < 16; ++i)
        Self.SkelGroupFlags[i]      = SubClass.Default.SkelGroupFlags[i];
    for(i = 0; i < 50; ++i)
        Self.JointFlags[i]          = SubClass.Default.JointFlags[i];
    for(i = 0; i < 50; ++i)
        Self.JointChild[i]          = SubClass.Default.JointChild[i];
	Self.SubstituteMesh				= SubClass.Default.SubstituteMesh;
}

/**
*   ApplySubClass_ExtractBodyPartData
*   Extracts the classes used for severed limb body parts on the provided class.
*   This data cannot be extracted (that I'm aware of) from the class, so
*   it requires an instance of the RunePlayer.
*/
function ApplySubClass_ExtractBodyPartData(Class<RunePlayer> SubClass, RunePlayer SubClassInstance)
{
	local int i;

	for(i = 0; i < 16; ++i)
	{
		PolyGroupBodyParts[i] = SubClassInstance.BodyPartForPolyGroup(i);
	}

	RunePlayerSeveredHeadClass = SubClassInstance.SeveredLimbClass(BODYPART_HEAD);
	RunePlayerSeveredLimbClass = SubClassInstance.SeveredLimbClass(BODYPART_LARM1);
}

/**
*   ApplySubClass_ExtractPainSkinData
*   Extract the pain skin textures from the provided RunePlayer class.
*/
function ApplySubClass_ExtractPainSkinData(Class<RunePlayer> SubClass, RunePlayer SubClassInstance)
{
	local int i, j;

	// Initialize pain skins
	for(i = 0; i < NUM_BODYPARTS; ++i)
	{
		for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
		{
			PainSkinArrays[i].Textures[j] = None;
		}
	}

	// Extract from subclass
	for(i = 0; i < NUM_BODYPARTS; ++i)
	{
		for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
		{
			SubClassInstance.SkelGroupSkins[i] = None;
		}

		SubClassInstance.PainSkin(i);

		for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
		{
			PainSkinArrays[i].Textures[j] = SubClassInstance.SkelGroupSkins[j];
		}
	}
}

/**
*   ApplySubClass_ExtractGoreCapData
*   Extract gore cap textures from the provided RunePlayer class.
*/
function ApplySubClass_ExtractGoreCapData(Class<RunePlayer> SubClass, RunePlayer SubClassInstance)
{
	local int i, j;

	// Initialize gore cap skins
	for(i = 0; i < NUM_BODYPARTS; ++i)
	{
		for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
		{
			GoreCapArrays[i].Textures[j] = None;
		}
	}

	// Extract from subclass
	for(i = 0; i < NUM_BODYPARTS; ++i)
	{
		for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
		{
			SubClassInstance.SkelGroupSkins[i] = None;
		}

		SubClassInstance.ApplyGoreCap(i);

		for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
		{
			GoreCapArrays[i].Textures[j] = SubClassInstance.SkelGroupSkins[j];
		}
	}
}

/**
*   ApplySubClass_ExtractMenuName
*   Attempts to extract the menu name for the provided RunePlayer class,
*   so that when viewed from the server browser, players still see the original
*   name of the skin being used instead of R_RunePlayer.
*/
function ApplySubClass_ExtractMenuName(Class<RunePlayer> SubClass)
{
	local String ClassString;
	local String EntryString, DescriptionString;
	local int i;

	ClassString = Level.GetNextInt("RuneI.RunePlayer", 0);
	for(i = 0; ClassString != ""; ClassString = Level.GetNextInt("RuneI.RunePlayer", ++i))
	{
		if(ClassString == String(SubClass))
		{
			Level.GetNextIntDesc("RuneI.RunePlayer", i, EntryString, DescriptionString);
			MenuName = DescriptionString;
			return;
		}
	}

	MenuName = "RMod Rune Player";
}

/**
*   ServerMove (override)
*	Overridden for the following reasons:
*   -   Clients who have a high net speed variable will have a ClientAdjust
*       called every single tick. Override implements a fix.
*   -   bForceClientAdjustPosition, when true, forces a call to ClientAdjust.
*   -   Client view pitch and view yaw are replicated so that spectators can
*       view in point-of-view mode.
*/
function ServerMove(
	float TimeStamp, 
	vector InAccel, 
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
	optional int OldAccel)
{
	local float DeltaTime, clientErr, OldTimeStamp;
	local rotator DeltaRot, Rot;
	local vector Accel, LocDiff;
	local int maxPitch, ViewPitch, ViewYaw;
	local actor OldBase;

	local bool NewbPressedJump, OldbRun, OldbDuck;
	local eDodgeDir OldDodgeMove;

	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
	{
		return;
	}

	// Update bReadyToPlay for clients
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.bReadyToPlay = bReadyToPlay;

	// if OldTimeDelta corresponds to a lost packet, process it first
	if (  OldTimeDelta != 0 )
	{
		OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
		if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
		{
			// split out components of lost move (approx)
			Accel.X = OldAccel >>> 23;
			if ( Accel.X > 127 )
				Accel.X = -1 * (Accel.X - 128);
			Accel.Y = (OldAccel >>> 15) & 255;
			if ( Accel.Y > 127 )
				Accel.Y = -1 * (Accel.Y - 128);
			Accel.Z = (OldAccel >>> 7) & 255;
			if ( Accel.Z > 127 )
				Accel.Z = -1 * (Accel.Z - 128);
			Accel *= 20;
			
			OldbRun = ( (OldAccel & 64) != 0 );
			OldbDuck = ( (OldAccel & 32) != 0 );
			NewbPressedJump = ( (OldAccel & 16) != 0 );
			if ( NewbPressedJump )
				bJumpStatus = NewbJumpStatus;

			switch (OldAccel & 7)
			{
				case 0:
					OldDodgeMove = DODGE_None;
					break;
				case 1:
					OldDodgeMove = DODGE_Left;
					break;
				case 2:
					OldDodgeMove = DODGE_Right;
					break;
				case 3:
					OldDodgeMove = DODGE_Forward;
					break;
				case 4:
					OldDodgeMove = DODGE_Back;
					break;
			}
			//log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
			MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, OldbDuck, NewbPressedJump, OldDodgeMove, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}		

	// View components
	ViewPitch = View/32768;
	ViewYaw = 2 * (View - 32768 * ViewPitch);
	ViewPitch *= 2;
	// Make acceleration.
	Accel = InAccel/10;

	NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	bJumpStatus = NewbJumpStatus;

	// handle firing and alt-firing
	if(bFired)
	{
		if(bForceFire && (Weapon != None) )
		{
//RUNE			Weapon.ForceFire();
			Fire(0);
		}
		else if(bFire == 0)
		{
			Fire(0);
		}
		bFire = 1;
	}
	else
		bFire = 0;


	if(bAltFired)
	{
		if(bForceAltFire && (Shield != None))
			AltFire(0);
//RUNE			Weapon.ForceAltFire();
		else if(bAltFire == 0)
			AltFire(0);
		bAltFire = 1;
	}
	else
		bAltFire = 0;

	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if ( ServerTimeStamp > 0 )
	{
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	Rot.Roll = 256 * ClientRoll;
	Rot.Yaw = ViewYaw;
	if ( (Physics == PHYS_Swimming) || (Physics == PHYS_Flying) )
		maxPitch = 2;
	else
		maxPitch = 1;
	If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
	{
		If (ViewPitch < 32768) 
			Rot.Pitch = maxPitch * RotationRate.Pitch;
		else
			Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	else
		Rot.Pitch = ViewPitch;
	DeltaRot = (Rotation - Rot);
	ViewRotation.Pitch = ViewPitch;
	ViewRotation.Yaw = ViewYaw;
	ViewRotation.Roll = 0;
	SetRotation(Rot);

	OldBase = Base;

	// Perform actual movement.
	if ( (Level.Pauser == "") && (DeltaTime > 0) )
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DodgeMove, Accel, DeltaRot);

	// Accumulate movement error.
	//if ( Level.TimeSeconds - LastUpdateTime > 0.125)
	//	ClientErr = 10000;
	//else if ( Level.TimeSeconds - LastUpdateTime > 0.045 )
	//if ( Level.TimeSeconds - LastUpdateTime > 0.045 )
	if(Level.TimeSeconds - LastUpdateTime > 0.25)
	{
		bForceClientAdjustPosition = true;
	}
	else if(Level.TimeSeconds - LastUpdateTime > 0.045)
	{
		LocDiff = Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}
	else
	{
		ClientErr = 0.0;
	}
	//Log(ClientErr);

	// If client has accumulated a noticeable positional error, correct him.
	if ( bForceClientAdjustPosition || ClientErr > 3 )
	{
		bForceClientAdjustPosition = false;
		
		if ( Mover(Base) != None )
			ClientLoc = Location - Base.Location;
		else
			ClientLoc = Location;
		//log("Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Physics);
		LastUpdateTime = Level.TimeSeconds;
		ClientAdjustPosition
		(
			TimeStamp, 
			GetStateName(), 
			Physics, 
			ClientLoc.X, 
			ClientLoc.Y, 
			ClientLoc.Z, 
			Velocity.X, 
			Velocity.Y, 
			Velocity.Z,
			Base
		);
	}
	//log("Server "$Role$" moved "$self$" stamp "$TimeStamp$" location "$Location$" Acceleration "$Acceleration$" Velocity "$Velocity);
		
	ViewRotPovPitch = ViewRotation.Pitch;
	ViewRotPovYaw = ViewRotation.Yaw;
}

/**
*   JointDamaged (override)
*   Overridden to keep track of Damage dealt statistics.
*/
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local int PreviousHealth;
	local int DamageDealt;
	local R_PlayerReplicationInfo RPRI;
	local bool bResult;

	PreviousHealth = Health;
	bResult = Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);

	if(Health < 0)
	{
		DamageDealt = PreviousHealth;
	}
	else
	{
		DamageDealt = PreviousHealth - Health;
	}

	if(EventInstigator != None && EventInstigator.PlayerReplicationInfo != None)
	{
		RPRI = R_PlayerReplicationInfo(EventInstigator.PlayerReplicationInfo);
		if(RPRI != None)
		{
			RPRI.DamageDealt += DamageDealt;
		}
	}
}

/**
*   PlayTakeHit (override)
*   Overridden to avoid playing client flashes in response to shield hit stun
*/
function PlayTakeHit(float TweenTime, int Damage, Vector HitLoc, Name DamageType, Vector Momentum, int BodyPart)
{
    local float rnd;
    local float time;

    if(DamageType != 'ShieldHit')
    {
        rnd = FClamp(Damage, 10, 40);
        if (DamageType == 'burned')
        {
            ClientFlash(-0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
        }
        else if (DamageType == 'corroded')
        {
            ClientFlash(-0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
        }
        else if (DamageType == 'drowned')
        {
            ClientFlash(-0.390, vect(312.5,468.75,468.75));
        }
        else
        {
            ClientFlash(-0.017 * rnd, rnd * vect(24, 4, 4));
        }
    }

    time = 0.15 + 0.005 * Damage;
    ShakeView(time, Damage * 10, time * 0.5);

    // Bypass RunePlayer.PlayTakeHit to avoid client flash
    Super(PlayerPawn).PlayTakeHit(TweenTime, Damage, HitLoc, DamageType, Momentum, BodyPart);
}

/**
*   SetSkinActor (override)
*   Overridden to apply skin actor in the context of the sub class that would
*   have been saved during the call to ApplySubClass.
*/
static function SetSkinActor(Actor SkinActor, int NewSkin)
{
	local R_RunePlayer RP;
	local Class<RunePlayer> RPSubClass;
	local int i;
	
	RP = R_RunePlayer(SkinActor);
	if(RP == None)
	{
		Class'RuneI.RunePlayer'.Static.SetSkinActor(SkinActor, NewSkin);
		return;
	}
	
	RPSubClass = RP.RunePlayerSubClass;
	if(RPSubClass == None)
	{
		RPSubClass = Class'RMod.R_RunePlayer';
	}
	
	for(i = 0; i < 16; ++i)
	{
		RP.SkelGroupSkins[i] = RPSubClass.Default.SkelGroupSkins[i];
	}
}

/**
*   PainSkin (override)
*   Overridden to apply the pain skin that was extracted in ApplySubClass.
*/
function Texture PainSkin(int BodyPart)
{
	local Texture PainTexture;
	local int i;

	if(BodyPart < 0 || BodyPart >= NUM_BODYPARTS)
	{
		return None;
	}

	for(i = 0; i < MAX_SKEL_GROUP_SKINS; ++i)
	{
		PainTexture = PainSkinArrays[BodyPart].Textures[i];
		if(PainTexture != None)
		{
			SkelGroupSkins[i] = PainTexture;
		}
	}
	
	return None;
}

/**
*   ApplyGoreCap (override)
*   Overridden to apply the gore cap that was extracted in ApplySubClass.
*/
function ApplyGoreCap(int BodyPart)
{
	local Texture GoreTexture;
	local int i;

	if(BodyPart < 0 || BodyPart >= NUM_BODYPARTS)
	{
		return;
	}

	for(i = 0; i < MAX_SKEL_GROUP_SKINS; ++i)
	{
		GoreTexture = GoreCapArrays[BodyPart].Textures[i];
		if(GoreTexture != None)
		{
			SkelGroupSkins[i] = GoreTexture;
			SkelGroupFlags[i] = SkelGroupFlags[i] & ~POLYFLAG_INVISIBLE;
		}
	}
}

/**
*   BodyPartForPolyGroup (override)
*   Overridden to return the body part that was extracted in ApplySubClass.
*/
function int BodyPartForPolyGroup(int PolyGroup)
{
	if(PolyGroup < 0 || PolyGroup >= 16)
	{
		return BODYPART_BODY;
	}

	return PolyGroupBodyParts[PolyGroup];
}

/**
*   SeveredLimbClass (override)
*   Overridden to return the severed limb class that was
*   extracted in ApplySubClass.
*/
function Class<Actor> SeveredLimbClass(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LARM1:
		case BODYPART_RARM1:
			return Self.RunePlayerSeveredLimbClass;
		case BODYPART_HEAD:
			return Self.RunePlayerSeveredHeadClass;
	}

	return None;
}

/**
*   GetViewRotPov
*   Get the point-of-view view rotation for this player. Called by other
*   players who are in spectator state.
*   Note that this needs to be simulated because it's going to be called
*   client-side by non-owning clients.
*/
simulated function Rotator GetViewRotPov()
{
	local Rotator ViewRotPov;
	
	ViewRotPov.Pitch = ViewRotPovPitch;
	ViewRotPov.Yaw = ViewRotPovYaw;
	ViewRotPov.Roll = 0;
	return ViewRotPov;
}

/**
*   SwitchGame
*   Custom command for server travel using specific game presets specified
*   in R_GameInfo.
*/
exec function SwitchGame(String S)
{
	ServerSwitchGame(S);
}

/**
*   ServerSwitchGame
*   SwitchGame command repliated to server.
*/
function ServerSwitchGame(String S)
{
	local R_GameInfo GI;
	
	if(!VerifyAdminWithErrorMessage())
	{
		return;
	}
	
	GI = R_GameInfo(Level.Game);
	if(GI == None)
	{
		return;
	}
	
	GI.SwitchGame(Self, S);
}

/**
*   Throw (override)
*   Overridden to allow player to drop shield with Throw input when they
*   have to currently equipped weapon.
*/
exec function Throw()
{
    if(Weapon == None)
    {
        if(Shield != None)
        {
            DropShield();
        }

        return;
    }
    else
    {
        if( bShowMenu || (Level.Pauser!=""))
        {
            return;
        }
        
        if(AnimProxy != None && AnimProxy.Throw())
        {
            PlayAnim('ATK_ALL_throw1_AA0S', 1.0, 0.1);
        }
    }
}

/**
*   ResetLevel
*   Performs a soft level reset. Resets the map state without reloading the map.
*   Useful for restarting maps only after all players have loaded in.
*/
exec function ResetLevel(optional int DurationSeconds)
{
	ServerResetLevel(DurationSeconds);
}

/**
*   ServerResetLevel
*   ResetLevel command replicated to server.
*/
function ServerResetLevel(optional int DurationSeconds)
{
	local R_GameInfo GI;
	
	if(!VerifyAdminWithErrorMessage())
	{
		return;
	}
	
	GI = R_GameInfo(Level.Game);
	if(GI == None)
	{
		return;
	}
	
	GI.ResetLevel(DurationSeconds);
}

/**
*   TimeLimit
*   Update the game's time limit on the fly.
*/
exec function TimeLimit(int DurationMinutes)
{
	ServerTimeLimit(DurationMinutes);
}

/**
*   ServerTimeLimit
*   TimeLimit command replicated to server
*/
function ServerTimeLimit(int DurationMinutes)
{
	local R_GameInfo GI;
	
	if(!VerifyAdminWithErrorMessage())
	{
		return;
	}
	
	GI = R_GameInfo(Level.Game);
	if(GI == None)
	{
		return;
	}
	
	GI.PlayerSetTimeLimit(self, DurationMinutes);
}

/**
*   Spectate
*   Allows clients to switch to spectator mode while in-game.
*/
exec function Spectate()
{
	ServerSpectate();
}

/**
*   ServerSpectate
*   Spectate command replicated to server.
*/
function ServerSpectate()
{
	local R_GameInfo GI;
	GI = R_GameInfo(Level.Game);
	if(GI != None)
	{
		GI.RequestSpectate(Self);
	}
}

/**
*   Say (override)
*   Overridden to filter out spectator messages for non-spectator players.
*/
exec function Say( string Msg )
{
    local Pawn P;
	local R_GameInfo RGI;

    if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
	{
		RGI = R_GameInfo(Level.Game);
        for( P=Level.PawnList; P!=None; P=P.nextPawn )
		{
			// Filter spectator messages as necessary
			if(RGI != None
			&& !RGI.bAllowSpectatorBroadcastMessage
			&& P.PlayerReplicationInfo != None
			&& PlayerReplicationInfo.bIsSpectator
			&& !P.PlayerReplicationInfo.bIsSpectator)
			{
				continue;
			}

            if( P.bIsPlayer || P.IsA('MessagingSpectator') )
			{
                P.TeamMessage( PlayerReplicationInfo, Msg, 'Say', true );
			}
		}
	}
    return;
}

/**
*   TeamSay (override)
*   Overridden to filter out spectator messages for non-spectator players.
*/
exec function TeamSay( string Msg )
{
    local Pawn P;
	local R_GameInfo RGI;

    if ( !Level.Game.bTeamGame )
    {
        Say(Msg);
        return;
    }

    if ( Msg ~= "Help" )
    {
        CallForHelp();
        return;
    }
            
    if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
	{
		RGI = R_GameInfo(Level.Game);
        for( P=Level.PawnList; P!=None; P=P.nextPawn )
		{
			// Filter spectator messages as necessary
			if(RGI != None
			&& !RGI.bAllowSpectatorBroadcastMessage
			&& P.PlayerReplicationInfo != None
			&& PlayerReplicationInfo.bIsSpectator
			&& !P.PlayerReplicationInfo.bIsSpectator)
			{
				continue;
			}

            if( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
            {
                if ( P.IsA('PlayerPawn') )
				{
                    P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
				}
            }
		}
	}
}

/**
*   DoTryPlayTorsoAnim (override)
*   This function's name is confusing, but what it actually means is:
*   "Try to play the AnimProxy's current on animation on the RunePlayer",
*   which effectively means:
*   "Whatever animation is playing on the torso, try to play that
*   animation on the legs as well".
*   This fixes the client-side leg animations by force-playing the specified
*   animation. Note that 'simulated' serves no purpose here, and it's only
*   marked simulated because the original function is marked simulated
*/
simulated function DoTryPlayTorsoAnim(Name TorsoAnim, float speed, float tween)
{
	if(Role == ROLE_AutonomousProxy || Level.NetMode == NM_Standalone)
	{
		if(TorsoAnim == 'neutral_kick'
		|| TorsoAnim == 'PumpTrigger'
		|| TorsoAnim == 'LevelTrigger'
		|| TorsoAnim == 'S3_Taunt')
		{
			PlayAnim(TorsoAnim, speed, tween);
			return;
		}

		if(Weapon != None)
		{
			if(TorsoAnim == Weapon.A_JumpAttack
			|| TorsoAnim == Weapon.A_Taunt
			|| TorsoAnim == Weapon.A_PumpTrigger
			|| TorsoAnim == Weapon.A_LeverTrigger)
			{
				PlayAnim(TorsoAnim, speed, tween);
				return;
			}

			if(Physics == PHYS_Walking && VSize2D(Acceleration) < 1000.0f)
			{
				PlayAnim(TorsoAnim, speed, tween);
				return;
			}
		}
	}

	Super.DoTryPlayTorsoAnim(TorsoAnim, speed, tween);
}

/**
*   Suicide (override)
*   Overridden to prevent suicide-spam server attacks.
*   TODO:
*   It would be a good idea to implement auto-disconnect functionality here
*   when the server detects players spamming suicide.
*/
exec function Suicide()
{
	// Anti spam
	if(Level.TimeSeconds - SuicideTimeStamp <= SuicideCooldown)
	{
		return;
	}

	SuicideTimeStamp = Level.TimeSeconds;
    KilledBy( None );
}

/**
*   CheckShouldSpectateAfterDying
*   Dying state calls this function to see whether the player should enter
*   into spectator state after dying. This is useful for game types like Arena,
*   to allow players to spectate other players while dead.
*/
function bool CheckShouldSpectateAfterDying()
{
	// If unable to restart, then go into spectator mode
	return !bCanRestart;
}

/**
*   PlayerSpectating State
*   Allows players to view in spectator mode without reconnecting as spectators.
*   Spawns a spectator camera actor and routes most view-related functions to
*   the camera.
*   For custom spectator functionality, extend R_ACamera and set the
*   SpectatorCameraClass variable in this class.
*/
state PlayerSpectating
{
	event BeginState()
    {
        Self.SetCollision(false, false, false);
        Self.bCollideWorld = false;
        Self.DrawType = DT_None;
		//Self.bHidden = true;
        Self.bAlwaysRelevant = false;
        Self.SetPhysics(PHYS_None);
		//Self.PlayerReplicationInfo.bIsSpectator = true;
		
		if(Role == ROLE_Authority)
		{
			Level.Game.DiscardInventory(Self);
			
			if(Camera != None)
			{
				Camera.Destroy();
			}
			Camera = Spawn(Self.SpectatorCameraClass, Self);
		}
    }

    event EndState()
    {
        Self.SetCollision(true, true, true);
        Self.bCollideWorld = Self.Default.bCollideWorld;
        Self.DrawType = Self.Default.DrawType;
		//Self.bHidden = Self.Default.bHidden;
        Self.bAlwaysRelevant = Self.Default.bAlwaysRelevant;
		//Self.PlayerReplicationInfo.bIsSpectator = false;

		if(Role == ROLE_Authority)
		{
			if(Camera != None)
			{
				Camera.Destroy();
			}
		}
    }
	
	event PlayerCalcView(
        out Actor ViewActor,
        out vector CameraLocation,
        out rotator CameraRotation)
    {
		if(Self.Camera != None)
		{
			Self.Camera.PlayerCalcView(
				ViewActor,
				CameraLocation,
				CameraRotation);
			Self.SavedCameraRot = CameraRotation;
			Self.SavedCameraLoc = CameraLocation;
			Self.ViewLocation = CameraLocation;
		}
    }
	
	event PreRender( canvas Canvas )
	{
		if (bDebug==1)
		{
			if (myDebugHUD   != None)
				myDebugHUD.PreRender(Canvas);
			else if ( Viewport(Player) != None )
				myDebugHUD = spawn(Class'Engine.DebugHUD', self);
		}
	
		// Ensure spectator hud is in use
		if(myHUD == None || (myHUD != None && HUDTypeSpectator != None && myHUD.Class != HUDTypeSpectator))
		{
			if(myHUD == None)
			{
				myHUD.Destroy();
			}
			myHUD = Spawn(HUDTypeSpectator, Self);
		}

		if(myHUD != None)
		{
			myHUD.PreRender(Canvas);
		}
	
		if (bClientSideAlpha)
		{
			OldStyle = Style;
			OldScale = AlphaScale;
			Style = STY_AlphaBlend;
			AlphaScale = ClientSideAlphaScale;
		}
	}

	event PostRender(Canvas C)
	{
		Global.PostRender(C);
		if(Self.Camera != None)
		{
			Self.Camera.PostRender(C);
		}
	}
	
	event PlayerInput(float DeltaSeconds)
    {
        Super.PlayerInput(DeltaSeconds);
		if(Self.Camera != None)
		{
			Self.Camera.Input_MouseAxis(aMouseX, aMouseY);
		}
    }
	
	// Use cycles camera modes
	exec function Use()
	{
		if(Self.Camera != None)
		{
			Self.Camera.Input_Use();
		}
	}
	
	// Fire cycles view targets
	exec function Fire(optional float F)
	{
		if(Self.Camera != None)
		{
			Self.Camera.Input_Fire();
		}
	}
	
	exec function CameraIn()
	{
		if(Self.Camera != None)
		{
			Self.Camera.Input_CameraIn();
		}
	}
	
	exec function CameraOut()
	{
		if(Self.Camera != None)
		{
			Self.Camera.Input_CameraOut();
		}
	}
}

//==============================================================================
//  The following states are only overridden to force a client adjust when
//  transitioning from one state to another. The client-side jitter fix in
//  ServerMove has some strange behavior in certain cases, but this solution
//  appears to fix nearly all of the issues.
//==============================================================================

state Pain
{
	event BeginState()
	{
		Super.BeginState();
		bForceClientAdjustPosition = true;
	}
	
	event EndState()
	{
		Super.EndState();
		bForceClientAdjustPosition = true;
	}
}

state Dying
{
	event BeginState()
	{
		Super.BeginState();
		bForceClientAdjustPosition = true;
	}
	
	event EndState()
	{
		Super.EndState();
		bForceClientAdjustPosition = true;
	}

	function AnimEnd()
	{
		Super.AnimEnd();
		if(CheckShouldSpectateAfterDying())
		{
			GotoState('PlayerSpectating');
		}
	}
}

state PlayerWalking
{
	event BeginState()
	{
		Super.BeginState();
		bForceClientAdjustPosition = true;
	}
	
	event EndState()
	{
		Super.EndState();
		bForceClientAdjustPosition = true;
	}
}

state PlayerWaiting
{
	event BeginState()
	{
		Super.BeginState();
		bForceClientAdjustPosition = true;
	}
	
	event EndState()
	{
		Super.EndState();
		bForceClientAdjustPosition = true;
	}
}

state Uninterrupted
{
	event BeginState()
	{
		Super.BeginState();
		bForceClientAdjustPosition = true;
	}
	
	event EndState()
	{
		Super.EndState();
		bForceClientAdjustPosition = true;
	}
}

state Unresponsive
{
	event BeginState()
	{
		Super.BeginState();
		bForceClientAdjustPosition = true;
	}
	
	event EndState()
	{
		Super.EndState();
		bForceClientAdjustPosition = true;
	}
}

state GameEnded
{
	ignores Throw;
}

// Loadouts
exec function Loadout()
{
    local WindowConsole WC;
    local UWindowWindow Window;

    WC = WindowConsole(Player.Console);
    if(WC == None)
    {
        UtilitiesClass.Static.RModLog("Failed to open loadout menu -- Invalid console");
        return;
    }

    if(WC.IsInState('UWINDOW') && !WC.bShowConsole)
    {
        // Player is in main menu
        return;
    }

    if(!WC.bCreatedRoot || WC.Root == None)
    {
        WC.CreateRootWindow(None);
    }

    WC.bQuickKeyEnable = true;
    WC.LaunchUWindow();

    // SETUP
    Window = WC.Root.CreateWindow(Class'RMod.R_LoadoutWindow', 128, 256, 400, 128);
    if(WC.bShowConsole)
    {
        WC.HideConsole();
    }

    Window.bLeaveOnScreen = true;
    Window.ShowWindow();
}


defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
    RunePlayerProxyClass=Class'RMod.R_RunePlayerProxy'
    SpectatorCameraClass=Class'RMod.R_Camera_Spectator'
    bMessageBeep=True
    SuicideCooldown=5.0
    bAlwaysRelevant=True
    bRotateTorso=False
}
