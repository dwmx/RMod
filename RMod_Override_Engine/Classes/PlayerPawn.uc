//=============================================================================
// PlayerPawn.
// player controlled pawns
// Note that Pawns which implement functions for the PlayerTick messages
// must handle player control in these functions
//=============================================================================
class PlayerPawn expands Pawn
	config(user)
	native;
//	nativereplication;

// Player info.
var const player Player;
var	globalconfig string Password;	// for restarting coop savegames

var	travel	  float DodgeClickTimer; // max double click interval for dodge move
var(Movement) globalconfig float	DodgeClickTime;
var(Movement) globalconfig float Bob;
var			  float				LandBob, AppliedBob;
var float bobtime;

// Camera info.
var int ShowFlags;
var int RendMap;
var int Misc1;
var int Misc2;

var actor ViewTarget;
var vector FlashScale, FlashFog;
var HUD	myHUD;
var DebugHUD myDebugHUD;
var ScoreBoard Scoring;
var class<hud> HUDType;
var class<scoreboard> ScoringType;

var float DesiredFlashScale, ConstantGlowScale, InstantFlash;
var vector DesiredFlashFog, ConstantGlowFog, InstantFog;
var globalconfig float DesiredFOV;
var globalconfig float DefaultFOV;
var globalconfig float HudTranslucency;

// Music info.
var music Song;
var byte  SongSection;
var byte  CdTrack;
var EMusicTransition Transition;

var float shaketimer; // player uses this for shaking view
var int shakemag;	// max magnitude in degrees of shaking
var float shakevert; // max vertical shake magnitude
var float maxshake;
var float verttimer;
var travel globalconfig float MyAutoAim;
var(Sounds) sound JumpSound;

var float AtrophyTimer;				 // RUNE:  Timer for strength atrophy
var bool bBloodLust;				 // RUNE:  True if the character is bloodlusting

var vector PolyColorAdjust;			 // RUNE:  Color adjust on the screen polygons
var vector DesiredPolyColorAdjust;	 // RUNE:  Desired adjust (smoothly fades to this color)
var bool bClientSideAlpha;			 // RUNE:  client side var for camera alpha
var float ClientSideAlphaScale;		 // RUNE:  client side var for camera alpha
var ERenderStyle OldStyle;			 // RUNE:  storage of style while client alpha rendering
var float OldScale;					 // RUNE:  storage of alphascale while client alpha rendering

var travel Weapon StowSpot[3]; // RUNE:  Stow Spots

// Player control flags
var bool		bAdmin;
var() globalconfig bool 		bLookUpStairs;	// look up/down stairs (player)
var() globalconfig bool		bSnapToLevel;	// Snap to level eyeheight when not mouselooking
var() globalconfig bool		bAlwaysMouseLook;
var globalconfig bool 		bKeyboardLook;	// no snapping when true
var bool		bWasForward;	// used for dodge move 
var bool		bWasBack;
var bool		bWasLeft;
var bool		bWasRight;
var bool		bEdgeForward;
var bool		bEdgeBack;
var bool		bEdgeLeft;
var bool 		bEdgeRight;
var bool		bIsCrouching;
var	bool		bShakeDir;			
var bool		bAnimTransition;
var bool		bIsTurning;
var bool		bFrozen;
var bool        bBadConnectionAlert;
var globalconfig bool	bInvertMouse;
var bool		bShowScores;
var bool		bShowMenu;
var bool		bSpecialMenu;
var bool		bWokeUp;
var bool		bPressedJump;
var bool		bUpdatePosition;
var bool		bDelayedCommand;
var bool		bRising;
var bool		bReducedVis;
var bool		bCenterView;
var() globalconfig bool bMaxMouseSmoothing;
var bool		bMouseZeroed;
var bool		bReadyToPlay;
var globalconfig bool bNoFlash;
var globalconfig bool bNoVoices;
var globalconfig bool bMessageBeep;
var bool		bZooming;
var() bool		bSinglePlayer;		// this class allowed in single player
var bool		bJustFired;
var bool		bJustAltFired;
var bool		bIsTyping;
var bool		bFixedCamera;
var globalconfig bool	bNeverAutoSwitch;	// if true, don't automatically switch to picked up weapon
var bool		bJumpStatus;	// used in net games
var	bool		bUpdating;
var bool		bCheatsEnabled;
var bool		bJustSpawned;		// just spawned into a level (not from a loadgame)

var float		ZoomLevel;
var float		LevelFadeAlpha;

var class<menu> SpecialMenu;
var string DelayedCommand;
var globalconfig float	MouseSensitivity;

var globalconfig name	WeaponPriority[20]; //weapon class priorities (9 is highest)

var float SmoothMouseX, SmoothMouseY, BorrowedMouseX, BorrowedMouseY;
var() globalconfig float MouseSmoothThreshold;
var float MouseZeroTime;

// Input axes.
var input float 
	aBaseX, aBaseY, aBaseZ,
	aMouseX, aMouseY,
	aForward, aTurn, aStrafe, aUp, 
	aLookUp, aExtra4, aExtra3, aExtra2,
	aExtra1, aExtra0;

// Move Buffering.
var SavedMove SavedMoves;
var SavedMove FreeMoves;
var SavedMove PendingMove;
var float CurrentTimeStamp,LastUpdateTime,ServerTimeStamp,TimeMargin, ClientUpdateTime;
var globalconfig float MaxTimeMargin;

// Progess Indicator.
var string ProgressMessage[8];
var color ProgressColor[8];
var float ProgressTimeOut;

// Localized strings
var localized string QuickSaveString;
var localized string NoPauseMessage;
var localized string ViewingFrom;
var localized string OwnCamera;
var localized string FailedView;

// ReplicationInfo
var GameReplicationInfo GameReplicationInfo;

// ngWorldStats Logging
var() globalconfig string ngWorldSecret;

// Remote Pawn ViewTargets
var rotator TargetViewRotation; 
var float TargetEyeHeight;
var vector TargetWeaponViewOffset;

// Demo recording view rotation
var int DemoViewPitch;
var int DemoViewYaw;

var float LastPlaySound;

replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && Role==ROLE_Authority )
		ViewTarget, ScoringType, HUDType, GameReplicationInfo, bFixedCamera, bCheatsEnabled,
		DesiredPolyColorAdjust, bBloodlust;
	unreliable if ( bNetOwner && Role==ROLE_Authority )
		TargetViewRotation, TargetEyeHeight, TargetWeaponViewOffset;
	reliable if( bDemoRecording && Role==ROLE_Authority )
		DemoViewPitch, DemoViewYaw;
	unreliable if ( ROLE==ROLE_Authority )
		bIsTyping;

	// Things the client should send to the server
	reliable if ( Role<ROLE_Authority )
		Password, bReadyToPlay;

	// Functions client can call.
	unreliable if( Role<ROLE_Authority )
		CallForHelp;
	reliable if( Role<ROLE_Authority )
		ShowPath, RememberSpot, Speech, Say, TeamSay, RestartLevel, SwitchWeapon, Pause, SetPause, 
		PrevItem, ActivateItem, ShowInventory, Grab, ServerFeignDeath, ServerSetWeaponPriority,
		ChangeName, ChangeTeam, God, Suicide, ViewClass, ViewPlayerNum, ViewSelf, ViewPlayer, ServerSetSloMo, ServerAddBots,
		PlayersOnly, ServerRestartPlayer, NeverSwitchOnPickup, BehindView, ServerNeverSwitchOnPickup, 
		PrevWeapon, NextWeapon, GetWeapon, ServerReStartGame, ServerUpdateWeapons, ServerTaunt, ServerChangeSkin,
		SwitchLevel, SwitchCoopLevel, Kick, KickBan, KillAll, Summon, Admin, AdminLogin, AdminLogout, Typing, Mutate,
		Use, Throw, PowerUp, CheatPlease;
	unreliable if( Role<ROLE_Authority )
		ServerMove, Fly, Walk, Ghost;

	// Functions server can call.
	reliable if( Role==ROLE_Authority && !bDemoRecording )
		ClientTravel;
	reliable if( Role==ROLE_Authority )
		ClientReliablePlaySound, ClientReplicateSkins, ClientAdjustGlow, ClientChangeTeam, ClientSetMusic, StartZoom, ToggleZoom, StopZoom, EndZoom, SetDesiredFOV, ClearProgressMessages, SetProgressColor, SetProgressMessage, SetProgressTime, ClientWeaponEvent;
	unreliable if( Role==ROLE_Authority )
		SetFOVAngle, ClientShake, ClientFlash, ClientInstantFlash;
	unreliable if( Role==ROLE_Authority && !bDemoRecording )
		ClientPlaySound;
	unreliable if( RemoteRole==ROLE_AutonomousProxy )//***
		ClientAdjustPosition;
}

//
// native client-side functions.
//
native event ClientTravel( string URL, ETravelType TravelType, bool bItems );
native(544) final function ResetKeyboard();
native(546) final function UpdateURL(string NewOption, string NewValue, bool bSaveDefault);
native final function string GetDefaultURL(string Option);
native final function LevelInfo GetEntryLevel();
native final function string GetPlayerNetworkAddress();

// Execute a console command in the context of this player, then forward to Actor.ConsoleCommand.
native function string ConsoleCommand( string Command );
native function CopyToClipboard( string Text );
native function string PasteFromClipboard();

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();

	PlayerReplicationInfo.bAdmin = bAdmin;
}

event PreClientTravel()
{
}

exec function Ping()
{
	ClientMessage("Current ping is"@PlayerReplicationInfo.Ping);
}

function ClientWeaponEvent(name EventType)
{
	if ( Weapon != None )
		Weapon.ClientWeaponEvent(EventType);
}

simulated event RenderOverlays( canvas Canvas )
{
	if ( Weapon != None )
		Weapon.RenderOverlays(Canvas);

	if ( myHUD != None )
		myHUD.RenderOverlays(Canvas);
}

function SetClientAlpha(float alpha)
{
	ClientSideAlphaScale = FClamp(alpha, 0.0, 1.0);
	bClientSideAlpha = (ClientSideAlphaScale < 1.0);
}

function ClientReplicateSkins(texture Skin1, optional texture Skin2, optional texture Skin3, optional texture Skin4)
{
	// do nothing (just loading other player skins onto client)
	log("Getting "$Skin1$", "$Skin2$", "$Skin3$", "$Skin4);
	return;
}

function CheckBob(float DeltaTime, float Speed2D, vector Y)
{
	local float OldBobTime;

	OldBobTime = BobTime;
	if ( Speed2D < 10 )
		BobTime += 0.2 * DeltaTime;
	else
		BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
	WalkBob = Y * 0.65 * Bob * Speed2D * sin(6 * BobTime);
	AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
	if ( LandBob > 0.01 )
	{
		AppliedBob += FMin(1, 16 * deltatime) * LandBob;
		LandBob *= (1 - 8*Deltatime);
	}
	if ( Speed2D < 10 )
		WalkBob.Z = AppliedBob + Bob * 30 * sin(12 * BobTime);
	else
		WalkBob.Z = AppliedBob + Bob * Speed2D * sin(12 * BobTime);
}

exec function ViewPlayerNum(optional int num)
{
	local Pawn P;

	if ( !PlayerReplicationInfo.bIsSpectator && !Level.Game.bTeamGame )
		return;

	if ( num >= 0 )
	{
		P = Pawn(ViewTarget);
		if ( (P != None) && P.bIsPlayer && (P.PlayerReplicationInfo.TeamID == num) )
		{
			ViewTarget = None;
			bBehindView = false;
			return;
		}
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
				&& !P.PlayerReplicationInfo.bIsSpectator
				&& (P.PlayerReplicationInfo.TeamID == num) )
			{
				if ( P != self )
				{
					ViewTarget = P;
					bBehindView = true;
				}
				return;
			}
		return;
	}
	if ( Role == ROLE_Authority )
	{
		ViewClass(class'Pawn', true);
		While ( (ViewTarget != None) 
				&& (!Pawn(ViewTarget).bIsPlayer || Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator) )
		{
			ViewClass(class'Pawn', true);
		}

		if ( ViewTarget != None )
			ClientMessage(ViewingFrom@Pawn(ViewTarget).PlayerReplicationInfo.PlayerName, 'Event', true);
		else
			ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
	}
}

exec function Profile()
{
	//TEMP for performance measurement

	slog("Average AI Time"@Level.AvgAITime);
	slog(" < 5% "$Level.AIProfile[0]);
	slog(" < 10% "$Level.AIProfile[1]);
	slog(" < 15% "$Level.AIProfile[2]);
	slog(" < 20% "$Level.AIProfile[3]);
	slog(" < 25% "$Level.AIProfile[4]);
	slog(" < 30% "$Level.AIProfile[5]);
	slog(" < 35% "$Level.AIProfile[6]);
	slog(" > 35% "$Level.AIProfile[7]);
}

// Execute an administrative console command on the server.
exec function Admin( string CommandLine )
{
	local string Result;
	if( bAdmin )
		Result = ConsoleCommand( CommandLine );
	if( Result!="" )
		ClientMessage( Result );
}

// Login as the administrator.
exec function AdminLogin( string Password )
{
	Level.Game.AdminLogin( Self, Password );
}

// Logout as the administrator.
exec function AdminLogout()
{
	Level.Game.AdminLogout( Self );
}

exec function SShot()
{
	local float b;
	b = float(ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness"));
	ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness 1");
	ConsoleCommand("flush");
	ConsoleCommand("shot");
	ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness "$string(B));
	ConsoleCommand("flush");
}


exec function DebugContinue()
{
	local Pawn P;

	if (AnimRate == 0)
		AnimRate = 1.0;

	// Players only off
	if (Level.bPlayersOnly)
		Level.bPlayersOnly = false;

	// Turn off Debug info
	if (myDebugHud != None)
	{
		myDebugHUD.SetMode(DEBUG_NONE);
		myDebugHUD.SetWatch(None);
		myDebugHUD.SaveConfig();
	}
}

exec function PlayerList()
{
	local PlayerReplicationInfo PRI;

	log("Player List:");
	ForEach AllActors(class'PlayerReplicationInfo', PRI)
		log(PRI.PlayerName@"( ping"@PRI.Ping$")"@"Team="$PRI.Team);
}

exec function RuleList()
{
	log("Rule List:");
	if (Level.Game != None)
		log(Level.Game.GetRules());
}

//=============================================================================
//
// Bug
//
// RUNE:  A convenient bug report tool that outputs a message long with the
// current player location
//=============================================================================
	
exec function Bug(string Msg)
{
	local int x, y, z;

	// Truncate location
	x = Location.X;
	y = Location.Y;
	z = Location.Z;
	slog("BUG REPORT: " $Msg$ " Loc: ("$x$", "$y$", "$z$")");
}

//=============================================================================
//
// Loc
//
// RUNE:  debugging tool.  Prints a message to the screen with the player location
//=============================================================================
	
exec function Loc()
{
	local int x, y, z;
	local string LevelName;

	// Truncate location
	x = Location.X;
	y = Location.Y;
	z = Location.Z;

	LevelName = Left(Level, InStr(Level, "."));

	// This doesn't use slog, because there's no reason for this to be logged
	ClientMessage("Current location is ("$x$", "$y$", "$z$") on Level: "$Level.Title);
}

//=============================================================================
//
// Tele
//
// RUNE:  debugging tool.  Teleports the player to a given location
//=============================================================================

exec function Tele(vector newLoc)
{
	if(bAdmin || (Level.Netmode == NM_Standalone))
		SetLocation(newLoc);
}

exec function ShutUp()
{
	StopAllSound();
}

//
// Native ClientSide Functions
//
event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Message.Static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

event ClientMessage( coerce string S, optional Name Type, optional bool bBeep )
{
	local Class<LocalMessage> MessageClass;

	if (Player == None)
		return;

	if (Type == '')
		Type = 'Event';

	if ( myHUD != None )
	{
		MessageClass = myHUD.DetermineClass(Type);
		MessageClass.Static.ClientReceiveMessage(Self, S, PlayerReplicationInfo);
	}
	else
	{
		if (Player.Console != None)
			Player.Console.Message( PlayerReplicationInfo, S, Type );
		if (bBeep && bMessageBeep)
			PlayBeepSound();
	}
}

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep  )
{
	local Class<LocalMessage> MessageClass;

	if (Type == '')
		Type = 'Event';
	if ( myHUD != None )
	{
		MessageClass = myHUD.DetermineClass(Type);
		MessageClass.Static.ClientReceiveMessage(Self, S, PRI);
	}
	else
	{
		if (Player.Console != None)
			Player.Console.Message( PRI, S, Type );
		if (bBeep && bMessageBeep)
			PlayBeepSound();
	}
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	local VoicePack V;

	if ( (Sender == None) || (Sender.voicetype == None) || (Player.Console == None) )
		return;
		
	V = Spawn(Sender.voicetype, self);
	if ( V != None )
		V.ClientInitialize(Sender, Recipient, messagetype, messageID);
}

simulated function PlayBeepSound();

//
// Send movement to the server.
// Passes acceleration in components so it doesn't get rounded.
//
function ServerMove
(
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
	optional int OldAccel
)
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
		return;

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
	if ( Level.TimeSeconds - LastUpdateTime > 500.0/Player.CurrentNetSpeed )
		ClientErr = 10000;
	else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
	{
		LocDiff = Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > 3 )
	{
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
}	

function ProcessMove ( float DeltaTime, vector newAccel, eDodgeDir DodgeMove, rotator DeltaRot)
{
	Acceleration = newAccel;
}

final function MoveAutonomous
(	
	float DeltaTime, 	
	bool NewbRun,
	bool NewbDuck,
	bool NewbPressedJump, 
	eDodgeDir DodgeMove, 
	vector newAccel, 
	rotator DeltaRot
)
{
	if ( NewbRun )
		bRun = 1;
	else
		bRun = 0;

	if ( NewbDuck )
		bDuck = 1;
	else
		bDuck = 0;
	bPressedJump = NewbPressedJump;

	HandleWalking();
	ProcessMove(DeltaTime, newAccel, DodgeMove, DeltaRot);	
	AutonomousPhysics(DeltaTime);
	//log("Role "$Role$" moveauto time "$100 * DeltaTime$" ("$Level.TimeDilation$")");
}

// ClientAdjustPosition - pass newloc and newvel in components so they don't get rounded

function ClientAdjustPosition
(
	float TimeStamp, 
	name newState, 
	EPhysics newPhysics,
	float NewLocX, 
	float NewLocY, 
	float NewLocZ, 
	float NewVelX, 
	float NewVelY, 
	float NewVelZ,
	Actor NewBase
)
{
	local vector OldLoc, NewLocation;

	if ( CurrentTimeStamp > TimeStamp )
		return;
	CurrentTimeStamp = TimeStamp;

	NewLocation.X = NewLocX;
	NewLocation.Y = NewLocY;
	NewLocation.Z = NewLocZ;
	Velocity.X = NewVelX;
	Velocity.Y = NewVelY;
	Velocity.Z = NewVelZ;

	SetBase(NewBase);
	if ( Mover(NewBase) != None )
		NewLocation += NewBase.Location;

	//log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" location "$Location);
	OldLoc = Location;
	bCanTeleport = false;
	SetLocation(NewLocation);
	bCanTeleport = true;

	SetPhysics(newPhysics);
	if ( !IsInState(newState) )
	{
//log("CAP: GotoState("$newState$")");
		GotoState(newState);
	}

	bUpdatePosition = true;
}

function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int realbRun, realbDuck;
	local bool bRealJump;

	local float AdjPCol, SavedRadius, TotalTime;
	local pawn SavedPawn, P;
	local vector Dist;

	bUpdatePosition = false;
	realbRun= bRun;
	realbDuck = bDuck;
	bRealJump = bPressedJump;
	CurrentMove = SavedMoves;
	bUpdating = true;
	while ( CurrentMove != None )
	{
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
			// adjust radius of nearby players with uncertain location
			if ( TotalTime > 0 )
				ForEach AllActors(class'Pawn', P)
					if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
					{
						Dist = P.Location - Location;
						AdjPCol = 0.0004 * PlayerReplicationInfo.Ping * ((P.Velocity - Velocity) Dot Normal(Dist));
						if ( VSize(Dist) < AdjPCol + P.CollisionRadius + CollisionRadius + CurrentMove.Delta * GroundSpeed * (Normal(Velocity) Dot Normal(Dist)) )
						{
							SavedPawn = P;
							SavedRadius = P.CollisionRadius;
							Dist.Z = 0;
							P.SetCollisionSize(FClamp(AdjPCol + P.CollisionRadius, 0.5 * P.CollisionRadius, VSize(Dist) - CollisionRadius - P.CollisionRadius), P.CollisionHeight);
							break;
						}
					} 
			TotalTime += CurrentMove.Delta;
			MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, 
				CurrentMove.DodgeMove, CurrentMove.Acceleration, rot(0,0,0));
			CurrentMove = CurrentMove.NextMove;
			if ( SavedPawn != None )
			{
				SavedPawn.SetCollisionSize(SavedRadius, P.CollisionHeight);
				SavedPawn = None;
			}
		}
	}
	bUpdating = false;
	bDuck = realbDuck;
	bRun = realbRun;
	bPressedJump = bRealJump;
	//log("Client adjusted "$self$" stamp "$CurrentTimeStamp$" location "$Location$" dodge "$DodgeDir);
}

final function SavedMove GetFreeMove()
{
	local SavedMove s;

	if ( FreeMoves == None )
		return Spawn(class'SavedMove');
	else
	{
		s = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		return s;
	}	
}

function int CompressAccel(int C)
{
	if ( C >= 0 )
		C = Min(C, 127);
	else
		C = Min(abs(C), 127) + 128;
	return C;
}

//
// Replicate this client's desired movement to the server.
//
function ReplicateMove
(
	float DeltaTime, 
	vector NewAccel, 
	eDodgeDir DodgeMove, 
	rotator DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
	local byte ClientRoll;
	local int i;
	local float OldTimeDelta, TotalTime, NetMoveDelta;
	local int OldAccel;
	local vector BuildAccel, AccelNorm;

	local float AdjPCol, SavedRadius;
	local pawn SavedPawn, P;
	local vector Dist;

	// if am network client and am carrying flag - 
	//	make its position look good client side
	if ( (PlayerReplicationInfo != None) 
		&& (PlayerReplicationInfo.HasFlag != None) )
		PlayerReplicationInfo.HasFlag.FollowHolder(self);

	// Get a SavedMove actor to store the movement in.
	if ( PendingMove != None )
	{
		//add this move to the pending move
		PendingMove.TimeStamp = Level.TimeSeconds; 
		if ( VSize(NewAccel) > 3072 )
			NewAccel = 3072 * Normal(NewAccel);
		TotalTime = PendingMove.Delta + DeltaTime;
		PendingMove.Acceleration = (DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration)/TotalTime;

		// Set this move's data.
		if ( PendingMove.DodgeMove == DODGE_None )
			PendingMove.DodgeMove = DodgeMove;
		PendingMove.bRun = (bRun > 0);
		PendingMove.bDuck = (bDuck > 0);
		PendingMove.bPressedJump = bPressedJump || PendingMove.bPressedJump;
		PendingMove.bFire = PendingMove.bFire || bJustFired || (bFire != 0);
		PendingMove.bForceFire = PendingMove.bForceFire || bJustFired;
		PendingMove.bAltFire = PendingMove.bAltFire || bJustAltFired || (bAltFire != 0);
		PendingMove.bForceAltFire = PendingMove.bForceAltFire || bJustFired;
		PendingMove.Delta = TotalTime;
	}
	if ( SavedMoves != None )
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		while ( NewMove.NextMove != None )
		{
			// find most recent interesting move to send redundantly
			if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
				|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
			|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = GetFreeMove();
	NewMove.Delta = DeltaTime;
	if ( VSize(NewAccel) > 3072 )
		NewAccel = 3072 * Normal(NewAccel);
	NewMove.Acceleration = NewAccel;

	// Set this move's data.
	NewMove.DodgeMove = DodgeMove;
	NewMove.TimeStamp = Level.TimeSeconds;
	NewMove.bRun = (bRun > 0);
	NewMove.bDuck = (bDuck > 0);
	NewMove.bPressedJump = bPressedJump;
	NewMove.bFire = (bJustFired || (bFire != 0));
	NewMove.bForceFire = bJustFired;
	NewMove.bAltFire = (bJustAltFired || (bAltFire != 0));
	NewMove.bForceAltFire = bJustAltFired;

	bJustFired = false;
	bJustAltFired = false;
	
	// adjust radius of nearby players with uncertain location
	ForEach AllActors(class'Pawn', P)
		if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
		{
			Dist = P.Location - Location;
			AdjPCol = 0.0004 * PlayerReplicationInfo.Ping * ((P.Velocity - Velocity) Dot Normal(Dist));
			if ( VSize(Dist) < AdjPCol + P.CollisionRadius + CollisionRadius + NewMove.Delta * GroundSpeed * (Normal(Velocity) Dot Normal(Dist)) )
			{
				SavedPawn = P;
				SavedRadius = P.CollisionRadius;
				Dist.Z = 0;
				P.SetCollisionSize(FClamp(AdjPCol + P.CollisionRadius, 0.5 * P.CollisionRadius, VSize(Dist) - CollisionRadius - P.CollisionRadius), P.CollisionHeight);
				break;
			}
		} 
	// Simulate the movement locally.
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DodgeMove, DeltaRot);
	AutonomousPhysics(NewMove.Delta);
	if ( SavedPawn != None )
		SavedPawn.SetCollisionSize(SavedRadius, P.CollisionHeight);

	//log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

	// Decide whether to hold off on move
	// send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}
	NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);
	
	if ( !PendingMove.bForceFire && !PendingMove.bForceAltFire && !PendingMove.bPressedJump
		&& (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		// save as pending move
		return;
	}
	else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
		return;
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
		if ( SavedMoves == None )
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	// check if need to redundantly send previous move
	if ( OldMove != None )
	{
		// log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
		// old move important to replicate redundantly
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel = (CompressAccel(BuildAccel.X) << 23) 
					+ (CompressAccel(BuildAccel.Y) << 15) 
					+ (CompressAccel(BuildAccel.Z) << 7);
		if ( OldMove.bRun )
			OldAccel += 64;
		if ( OldMove.bDuck )
			OldAccel += 32;
		if ( OldMove.bPressedJump )
			OldAccel += 16;
		OldAccel += OldMove.DodgeMove;
	}
	//else
	//	log("No redundant timestamp at "$Level.TimeSeconds$" with accel "$NewAccel);

	// Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
	if ( NewMove.bPressedJump )
		bJumpStatus = !bJumpStatus;
	ServerMove
	(
		NewMove.TimeStamp, 
		NewMove.Acceleration * 10, 
		Location, 
		NewMove.bRun,
		NewMove.bDuck,
		bJumpStatus, 
		NewMove.bFire,
		NewMove.bAltFire,
		NewMove.bForceFire,
		NewMove.bForceAltFire,
		NewMove.DodgeMove, 
		ClientRoll,
		(32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2)),
		OldTimeDelta,
		OldAccel 
	);
	//log("Replicated "$self$" stamp "$NewMove.TimeStamp$" location "$Location$" dodge "$NewMove.DodgeMove$" to "$DodgeDir);
}

function HandleWalking()
{
//	bIsWalking = ((bRun != 0) || (bDuck != 0)) && !Region.Zone.IsA('WarpZoneInfo'); 
	bIsWalking = ((bRun != 0) || bIsCrouching) && !Region.Zone.IsA('WarpZoneInfo');  // RUNE
}

//----------------------------------------------

simulated event Destroyed()
{
	Super.Destroyed();
	if ( myHud != None )
		myHud.Destroy();
	if ( Scoring != None )
		Scoring.Destroy();

	While ( FreeMoves != None )
	{
		FreeMoves.Destroy();
		FreeMoves = FreeMoves.NextMove;
	}

	While ( SavedMoves != None )
	{
		SavedMoves.Destroy();
		SavedMoves = SavedMoves.NextMove;
	}
}

function ServerReStartGame()
{
	Level.Game.RestartGame();
}

function PlayHit(float Damage, vector HitLocation, name damageType, float MomentumZ)
{
	Level.Game.SpecialDamageString = "";
}

function SetFOVAngle(float newFOV)
{
	FOVAngle = newFOV;
}
	 
function ClientFlash( float scale, vector fog )
{
	DesiredFlashScale = scale;
	DesiredFlashFog = 0.001 * fog;
}

function ClientInstantFlash( float scale, vector fog )
{
	InstantFlash = scale;
	InstantFog = 0.001 * fog;
}

//Play a sound client side (so only client will hear it
simulated function ClientPlaySound(sound ASound, optional bool bInterrupt, optional bool bVolumeControl )
{	
	local actor SoundPlayer;

	LastPlaySound = Level.TimeSeconds;	// so voice messages won't overlap
	if ( ViewTarget != None )
		SoundPlayer = ViewTarget;
	else
		SoundPlayer = self;

	SoundPlayer.PlaySound(ASound, SLOT_None, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Interface, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Misc, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Talk, 16.0, bInterrupt);
}

simulated function ClientReliablePlaySound(sound ASound, optional bool bInterrupt, optional bool bVolumeControl )
{
	ClientPlaySound(ASound, bInterrupt, bVolumeControl);
}
   
function ClientAdjustGlow( float scale, vector fog )
{
	ConstantGlowScale += scale;
	ConstantGlowFog += 0.001 * fog;
}

function ClientShake(vector shake)
{
	if ( (shakemag < shake.X) || (shaketimer <= 0.01 * shake.Y) )
	{
		shakemag = shake.X;
		shaketimer = 0.01 * shake.Y;	
		maxshake = 0.01 * shake.Z;
		verttimer = 0;
		ShakeVert = -1.1 * maxshake;
	}
}

function ShakeView( float shaketime, float RollMag, float vertmag)
{
	local vector shake;

	shake.X = RollMag;
	shake.Y = 100 * shaketime;
	shake.Z = 100 * vertmag;
	ClientShake(shake);
}

function ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
	Song        = NewSong;
	SongSection = NewSection;
	CdTrack     = NewCdTrack;
	Transition  = NewTransition;
}

function ServerFeignDeath()
{
/* RUNE:  Obsolete Unreal Weapon Code
	PendingWeapon = Weapon;
	if ( Weapon != None )
		Weapon.PutDown();
*/
	GotoState('FeigningDeath');

}


function ServerReStartPlayer()
{
}

function ServerChangeSkin( int SkinIndex )
{
	if ( Level.Game.bCanChangeSkin )
	{
		CurrentSkin = SkinIndex;
		Self.static.SetSkinActor(Self, SkinIndex);
	}
}

//*************************************************************************************
// Normal gameplay execs
// Type the name of the exec function at the console to execute it

exec function ShowSpecialMenu( string ClassName )
{
	local class<menu> aMenuClass;

	aMenuClass = class<menu>( DynamicLoadObject( ClassName, class'Class' ) );
	if( aMenuClass!=None )
	{
		bSpecialMenu = true;
		SpecialMenu = aMenuClass;
		ShowMenu();
	}
}
	
exec function Jump( optional float F )
{
	if ( !bShowMenu && (Level.Pauser == PlayerReplicationInfo.PlayerName) )
		SetPause(False);
	else
		bPressedJump = true;
}


// ShowTags [f] [<classname>]
exec function ShowTags(optional string cmdline)
{
	local actor a;
	local string tagsMsg, tempMsg1, tempMsg2;
	local bool tagsFilter;
	local class<Actor> tagsClass;

	if(!bAdmin && (Level.Netmode != NM_Standalone))
		return;
	tagsClass = class'Actor';
	tagsFilter = False;
	if(cmdline != "")
	{
		if(cmdline ~= "F" || Left(cmdline, 2) ~= "F ")
		{
			tagsFilter = True;
			cmdline = Right(cmdline, Len(cmdline)-1);
			while(Len(cmdline) > 0 && Asc(cmdline) < 33)
				cmdline = Right(cmdline, Len(cmdline)-1);
		}
		if(Len(cmdline) > 0)
		{
			tagsClass = None;
			foreach AllActors(class'Actor', a)
			{
				if(string(a.Class.Name) ~= cmdline)
				{
					tagsClass = a.Class;
					break;
				}
			}
			if(tagsClass == None)
			{
				slog("Class '" $ cmdline $ "' not found");
				return;
			}
		}
	}
	foreach AllActors(tagsClass, a)
	{
		if(a.Tag == '' || a.Tag == 'None' || string(a.Tag) ~= string(a.Class.Name))
			continue;
		if(tagsFilter)
			if(a.IsA('InterpolationPoint') || a.IsA('PathNode') || a.IsA('PatrolPoint'))
				continue;
		tempMsg1 = string(a.Tag) $ "(" $ string(a.Class.Name) $ ") ";
		tempMsg2 = tagsMsg $ tempMsg1;
		if (Len(tempMsg2) > 80)
		{
			slog(tagsMsg);
			tagsMsg = tempMsg1;
		}
		else
			tagsMsg = tempMsg2;
	}
	if(Len(tagsMsg) > 0)
		slog(tagsMsg);
}

exec function CauseEvent( name N )
{
	local actor A;
	local int triggerCount;

	if( !bCheatsEnabled )
		return;

	if( (bAdmin || (Level.Netmode == NM_Standalone)) && (N != '') )
	{
		triggerCount = 0;
		foreach AllActors( class 'Actor', A, N )
		{
			A.Trigger( Self, Self );
			triggerCount++;
		}
		slog(triggerCount $ " actor(s) triggered");
	}
}

exec function Taunt()
{
}

function ServerTaunt(name Sequence )
{
	PlayUninterruptedAnim(Sequence);
}

exec function FeignDeath()
{
}

exec function CallForHelp()
{
	local Pawn P;

	if ( !Level.Game.bTeamGame || (Enemy == None) || (Enemy.Health <= 0) )
		return;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
			P.HandleHelpMessageFrom(self);
}

function damageAttitudeTo(pawn Other)
{
	if ( Other != Self )
		Enemy = Other;
}

exec function Grab()
{
	// was used for decoration grab/drop
}

// Send a voice message of a certain type to a certain player.
exec function Speech( int Type, int Index, int Callsign )
{
	local VoicePack V;

	V = Spawn( PlayerReplicationInfo.VoiceType, Self );
	if (V != None)
		V.PlayerSpeech( Type, Index, Callsign );
}

function PlayChatting();

function Typing( bool bTyping )
{
	bIsTyping = bTyping;
	if (bTyping)
	{
		if (Level.Game != None)
		{
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogTypingEvent(True, Self);
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogTypingEvent(True, Self);
		}
		PlayChatting();
	} 
	else 
	{
		if (Level.Game != None)
		{
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogTypingEvent(False, Self);
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogTypingEvent(False, Self);
		}
	}
}

// Send a message to all players.
exec function Say( string Msg )
{
	local Pawn P;

	if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
			if( P.bIsPlayer || P.IsA('MessagingSpectator') )
				P.TeamMessage( PlayerReplicationInfo, Msg, 'Say', true );
	return;
}

exec function TeamSay( string Msg )
{
	local Pawn P;

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
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
			if( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
			{
				if ( P.IsA('PlayerPawn') )
					P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
			}
}

exec function RestartLevel()
{
	if( bAdmin || Level.Netmode==NM_Standalone )
		ClientTravel( "?restart", TRAVEL_Relative, false );
}

exec function LocalTravel( string URL )
{
	if( bAdmin || Level.Netmode==NM_Standalone )
		ClientTravel( URL, TRAVEL_Relative, true );
}

function ToggleZoom()
{
	if ( DefaultFOV != DesiredFOV )
		EndZoom();
	else
		StartZoom();
}
	
function StartZoom()
{
	ZoomLevel = 0.0;
	bZooming = true;
}

function StopZoom()
{
	bZooming = false;
}

function EndZoom()
{
	bZooming = false;
	DesiredFOV = DefaultFOV;
}

exec function FOV(float F)
{
	SetDesiredFOV(F);
}
	
exec function SetDesiredFOV(float F)
{
	if( (F >= 80.0) || Level.bAllowFOV || bAdmin || (Level.Netmode==NM_Standalone) )
	{
		DefaultFOV = FClamp(F, 1, 170);
		DesiredFOV = DefaultFOV;
		SaveConfig();
	}
}

/* PrevWeapon()
- switch to previous inventory group weapon
*/
exec function PrevWeapon()
{
/* RUNE:  Obsolete Unreal Weapon Code

	local int prevGroup;
	local Inventory inv;
	local Weapon realWeapon, w, Prev;
	local bool bFoundWeapon;

	if( bShowMenu || Level.Pauser!="" )
		return;
	if ( Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	prevGroup = 0;
	realWeapon = Weapon;
	if ( PendingWeapon != None )
		Weapon = PendingWeapon;
	PendingWeapon = None;
	
	for (inv=Inventory; inv!=None; inv=inv.Inventory)
	{
		w = Weapon(inv);
		if ( w != None )
		{
			if ( w.InventoryGroup == Weapon.InventoryGroup )
			{
				if ( w == Weapon )
				{
					bFoundWeapon = true;
					if ( Prev != None )
					{
						PendingWeapon = Prev;
						break;
					}
				}
				else if ( !bFoundWeapon )
					Prev = W;
			}
			else if ( (w.InventoryGroup < Weapon.InventoryGroup) 					 
					&& (w.InventoryGroup >= prevGroup) )
			{
				prevGroup = w.InventoryGroup;
				PendingWeapon = w;
			}
		}
	}
	bFoundWeapon = false;
	prevGroup = Weapon.InventoryGroup;
	if ( PendingWeapon == None )
		for (inv=Inventory; inv!=None; inv=inv.Inventory)
		{
			w = Weapon(inv);
			if ( w != None )
			{
				if ( w.InventoryGroup == Weapon.InventoryGroup )
				{
					if ( w == Weapon )
						bFoundWeapon = true;
					else if ( bFoundWeapon && (PendingWeapon == None) )
						PendingWeapon = W;
				}
				else if ( (w.InventoryGroup > PrevGroup) ) 
				{
					prevGroup = w.InventoryGroup;
					PendingWeapon = w;
				}
			}
		}

	Weapon = realWeapon;
	if ( PendingWeapon == None )
		return;

	if ( Weapon != PendingWeapon )
		Weapon.PutDown();
*/
}

/* NextWeapon()
- switch to next inventory group weapon
*/
exec function NextWeapon()
{
/* RUNE:  Obsolete Unreal Weapon Code

	local int nextGroup;
	local Inventory inv;
	local Weapon realWeapon, w, Prev;
	local bool bFoundWeapon;

	if( bShowMenu || Level.Pauser!="" )
		return;
	if ( Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	nextGroup = 100;
	realWeapon = Weapon;
	if ( PendingWeapon != None )
		Weapon = PendingWeapon;
	PendingWeapon = None;

	for (inv=Inventory; inv!=None; inv=inv.Inventory)
	{
		w = Weapon(inv);
		if ( w != None )
		{
			if ( w.InventoryGroup == Weapon.InventoryGroup )
			{
				if ( w == Weapon )
					bFoundWeapon = true;
				else if ( bFoundWeapon )
				{
					PendingWeapon = W;
					break;
				}
			}
			else if ( w.InventoryGroup > Weapon.InventoryGroup
					&& (w.InventoryGroup < nextGroup) )
			{
				nextGroup = w.InventoryGroup;
				PendingWeapon = w;
			}
		}
	}

	bFoundWeapon = false;
	nextGroup = Weapon.InventoryGroup;
	if ( PendingWeapon == None )
		for (inv=Inventory; inv!=None; inv=inv.Inventory)
		{
			w = Weapon(Inv);
			if ( w != None )
			{
				if ( w.InventoryGroup == Weapon.InventoryGroup )
				{
					if ( w == Weapon )
					{
						bFoundWeapon = true;
						if ( Prev != None )
							PendingWeapon = Prev;
					}
					else if ( !bFoundWeapon && (PendingWeapon == None) )
						Prev = W;
				}
				else if ( w.InventoryGroup < nextGroup ) 
				{
					nextGroup = w.InventoryGroup;
					PendingWeapon = w;
				}
			}
		}

	Weapon = realWeapon;
	if ( PendingWeapon == None )
		return;

	if ( Weapon != PendingWeapon )
		Weapon.PutDown();
*/
}

exec function Mutate(string MutateString)
{
	if( Level.NetMode == NM_Client )
		return;
	Level.Game.BaseMutator.Mutate(MutateString, Self);
}

exec function QuickSave()
{
	if ( (Health > 0) 
		&& (Level.NetMode == NM_Standalone)
		&& !Level.Game.bDeathMatch 
		&& GetStateName() != 'Scripting'
		&& GetStateName() != 'Uninterrupted')
	{ // Disallow save if in multiplay, dead, or in a cinematic
		ClientMessage(QuickSaveString);
		ConsoleCommand("SaveGame 9");
	}
}

exec function QuickLoad()
{
	if ( (Level.NetMode == NM_Standalone)
		&& !Level.Game.bDeathMatch )
		ClientTravel( "?load=9", TRAVEL_Absolute, false);
}

exec function Kick( string S ) 
{
	local Pawn aPawn;
	if( !bAdmin )
		return;
	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if
		(	aPawn.bIsPlayer
			&&	aPawn.PlayerReplicationInfo.PlayerName~=S 
			&&	(PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
		{
			aPawn.Destroy();
			return;
		}
}

exec function KickBan( string S ) 
{
	local Pawn aPawn;
	local string IP;
	local int j;
	if( !bAdmin )
		return;
	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if
		(	aPawn.bIsPlayer
			&&	aPawn.PlayerReplicationInfo.PlayerName~=S 
			&&	(PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
		{
			IP = PlayerPawn(aPawn).GetPlayerNetworkAddress();
			if(Level.Game.CheckIPPolicy(IP))
			{
				IP = Left(IP, InStr(IP, ":"));
				Log("Adding IP Ban for: "$IP);
				for(j=0;j<50;j++)
					if(Level.Game.IPPolicies[j] == "")
						break;
				if(j < 50)
					Level.Game.IPPolicies[j] = "DENY,"$IP;
				Level.Game.SaveConfig();
			}
			aPawn.Destroy();
			return;
		}
}

// Try to set the pause state; returns success indicator.
function bool SetPause( BOOL bPause )
{
	if (Level.Game == None)
		return false;
	return Level.Game.SetPause(bPause, self);
}

exec function SetMouseSmoothThreshold( float F )
{
	MouseSmoothThreshold = FClamp(F, 0, 0.1);
	SaveConfig();
}

exec function SetMaxMouseSmoothing( bool B )
{
	bMaxMouseSmoothing = B;
	SaveConfig();
}

// Try to pause the game.
exec function Pause()
{
	if ( bShowMenu )
		return;
	if( !SetPause(Level.Pauser=="") )
		ClientMessage(NoPauseMessage);
}

// Activate specific inventory item
exec function ActivateInventoryItem( class InvItem )
{
	local Inventory Inv;

	Inv = FindInventoryType(InvItem);
	if ( Inv != None )
		Inv.Activate();
}

// HUD
exec function ToggleRuneHUD()
{
	if (myHud != None)
		myHUD.ChangeHud(1);
	myHUD.SaveConfig();
}

exec function ChangeHud()
{
	if( !bCheatsEnabled )
		return;

	if ( myDebugHud != None )
		myDebugHUD.ChangeHud(1);
	myDebugHUD.SaveConfig();
}

// Crosshair
exec function ChangeCrosshair()
{
	if( !bCheatsEnabled )
		return;

	if ( myDebugHud != None ) 
		myDebugHUD.ChangeCrosshair(1);
	myDebugHUD.SaveConfig();
}


event PreRender( canvas Canvas )
{
	if (bDebug==1)
	{
		if (myDebugHUD	 != None)
			myDebugHUD.PreRender(Canvas);
		else if ( Viewport(Player) != None )
			myDebugHUD = spawn(class'Engine.DebugHUD', self);
	}

	if ( myHud != None )
		myHUD.PreRender(Canvas);
	else if ( (Viewport(Player) != None) && (HUDType != None) )
		myHUD = spawn(HUDType, self);

	if (bClientSideAlpha)
	{
		OldStyle = Style;
		OldScale = AlphaScale;
		Style = STY_AlphaBlend;
		AlphaScale = ClientSideAlphaScale;
	}
}

event PostRender( canvas Canvas )
{
	if (bClientSideAlpha)
	{
		Style = OldStyle;
		AlphaScale = OldScale;
	}

	if (bDebug==1)
	{
		if ( myDebugHud != None )
			myDebugHud.PostRender(Canvas);
		else if ( Viewport(Player) != None )
			myDebugHud = spawn(class'Engine.DebugHUD', self);
	}

	if ( myHud != None )
		myHUD.PostRender(Canvas);
	else if ( (Viewport(Player) != None) && (HUDType != None) )
		myHUD = spawn(HUDType, self);

	// Call start event here so HUD exists (for cinematics)
	if(StartEvent != '')
	{
		FireEvent(StartEvent);
		StartEvent = '';
	}
}

//=============================================================================
// Inventory-related input notifications.

// Handle function keypress for F1-F10.
exec function FunctionKey( byte Num )
{
}

exec function Throw()
{
}

exec function Use()
{
}

exec function PowerUp()
{
}

// The player wants to switch to weapon group numer I.
exec function SwitchWeapon (byte F )
{
/* RUNE:  Obsolete Unreal Weapon Code
	local weapon newWeapon;

	if ( bShowMenu || Level.Pauser!="" )
	{
		if ( myHud != None )
			myHud.InputNumber(F);
		return;
	}
	if ( Inventory == None )
		return;
	if ( (Weapon != None) && (Weapon.Inventory != None) )
		newWeapon = Weapon.Inventory.WeaponChange(F);
	else
		newWeapon = None;	
	if ( newWeapon == None )
		newWeapon = Inventory.WeaponChange(F);
	if ( newWeapon == None )
		return;

	if ( Weapon == None )
	{
		PendingWeapon = newWeapon;
		ChangedWeapon();
	}
	else if ( (Weapon != newWeapon) && Weapon.PutDown() )
		PendingWeapon = newWeapon;
*/
}

exec function GetWeapon(class<Weapon> NewWeaponClass )
{
/* RUNE:  Obsolete Unreal Weapon Code

	local Inventory Inv;

	if ( (Inventory == None) || (NewWeaponClass == None)
		|| ((Weapon != None) && (Weapon.Class == NewWeaponClass)) )
		return;

	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Inv.Class == NewWeaponClass )
		{
			PendingWeapon = Weapon(Inv);
			Weapon.PutDown();
			return;
		}
*/
}
	
// The player wants to select previous item
exec function PrevItem()
{
	local Inventory Inv, LastItem;

	if ( bShowMenu || Level.Pauser!="" )
		return;
	if (SelectedItem==None) {
		SelectedItem = Inventory.SelectNext();
		Return;
	}
	if (SelectedItem.Inventory!=None) 
		for( Inv=SelectedItem.Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if (Inv==None) Break;
			if (Inv.bActivatable) LastItem=Inv;
		}
	for( Inv=Inventory; Inv!=SelectedItem; Inv=Inv.Inventory ) {
		if (Inv==None) Break;
		if (Inv.bActivatable) LastItem=Inv;
	}
	if (LastItem!=None) {
		SelectedItem = LastItem;
		ClientMessage(SelectedItem.ItemName$SelectedItem.M_Selected);
	}
}

// The player wants to active selected item
exec function ActivateItem()
{
	if( bShowMenu || Level.Pauser!="" )
		return;
	if (SelectedItem!=None) 
		SelectedItem.Activate();
}

// The player wants to fire.
exec function Fire( optional float F )
{
	bJustFired = true;
	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) )
		return;

	if(Weapon != None)
		PlayFiring();

/* RUNE:  Obsolete Unreal Weapon Code

	bJustFired = true;
	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) )
	{
		if( (Role < ROLE_Authority) && (Weapon!=None) )
			bJustFired = Weapon.ClientFire(F);
		if ( !bShowMenu && (Level.Pauser == PlayerReplicationInfo.PlayerName)  )
			SetPause(False);
		return;
	}
	if( Weapon!=None )
	{
		Weapon.bPointing = true;
		PlayFiring();
		Weapon.Fire(F);
	}
*/
}

function PlayFiring()
{
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	bJustAltFired = true;
	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) )
		return;

	if(Shield != None)
		PlayAltFiring();

/* RUNE:  Obsolete Unreal Weapon Code

	bJustAltFired = true;
	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) )
	{
		if( (Role < ROLE_Authority) && (Weapon!=None) )
			bJustAltFired = Weapon.ClientAltFire(F);
		if ( !bShowMenu && (Level.Pauser == PlayerReplicationInfo.PlayerName) )
			SetPause(False);
		return;
	}
	if( Weapon!=None )
	{
		Weapon.bPointing = true;
		PlayFiring();
		Weapon.AltFire(F);
	}
*/
}

function PlayAltFiring()
{
}

/*
// The player wants to defend
exec function Defend( optional float F )
{
	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) )
		return;
}
*/


//Player Jumped
function DoJump( optional float F )
{
	if ( !bIsCrouching && (Physics == PHYS_Walking) )
	{
		if ( !bUpdating )
			PlayOwnedSound(JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
		if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
			MakeNoise(0.1 * Level.Game.Difficulty);
		PlayInAir(0.1);
		if ( bCountJumps && (Role == ROLE_Authority) && (Inventory != None) )
			Inventory.OwnerJumped();
		Velocity.Z = JumpZ;
		if ( (Base != Level) && (Base != None) )
			Velocity.Z += Base.Velocity.Z; 
		SetPhysics(PHYS_Falling);
	}
}

exec function Suicide()
{
	KilledBy( None );
}

exec function AlwaysMouseLook( Bool B )
{
	ChangeAlwaysMouseLook(B);
	SaveConfig();
}

function ChangeAlwaysMouseLook(Bool B)
{
	bAlwaysMouseLook = B;
	if ( bAlwaysMouseLook )
		bLookUpStairs = false;
}
	
exec function SnapView( bool B )
{
	ChangeSnapView(B);
	SaveConfig();
}

function ChangeSnapView( bool B )
{
	bSnapToLevel = B;
}
	
exec function StairLook( bool B )
{
	ChangeStairLook(B);
	SaveConfig();
}

function ChangeStairLook( bool B )
{
	bLookUpStairs = B;
	if ( bLookUpStairs )
		bAlwaysMouseLook = false;
}

exec function SetDodgeClickTime( float F )
{
	ChangeDodgeClickTime(F);
	SaveConfig();
}

function ChangeDodgeClickTime( float F )
{
	DodgeClickTime = FMin(0.3, F);
}
final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;
		
	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{	
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));	
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

exec function SetName( coerce string S )
{
	if ( Len(S) > 28 )
		S = left(S,28);
	ReplaceText(S, " ", "_");
	ChangeName(S);
	UpdateURL("Name", S, true);
	SaveConfig();
}

exec function Name( coerce string S )
{
	SetName(S);
}

function ChangeName( coerce string S )
{
	Level.Game.ChangeName( self, S, false );
}

exec function Team( int N )
{
	ChangeTeam(N);
}

function ChangeTeam( int N )
{
	local int OldTeam;
	OldTeam = PlayerReplicationInfo.Team;
	Level.Game.ChangeTeam(self, N);
	if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team != OldTeam) )
		Died( None, '', Location );
}

function ClientChangeTeam( int N )
{
	local Pawn P;

	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.Team = N;

	// if listen server, this may be called for non-local players that are logging in
	// if so, don't update URL
	if ( (Level.NetMode == NM_ListenServer) && (Player == None) )
	{
		// check if any other players exist
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.IsA('PlayerPawn') && (ViewPort(PlayerPawn(P).Player) != None) )
				return;
	}
		
	UpdateURL("Team",string(N), true);	
}
exec function SetAutoAim( float F )
{
	ChangeAutoAim(F);
	SaveConfig();
}

function ChangeAutoAim( float F )
{
	MyAutoAim = FMax(Level.Game.AutoAim, F);
}

exec function PlayersOnly()
{
	if ( Level.Netmode != NM_Standalone )
		return;

	Level.bPlayersOnly = !Level.bPlayersOnly;
}

exec function ViewPlayer( string S )
{
	local pawn P;

	for ( P=Level.pawnList; P!=None; P= P.NextPawn )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.PlayerName ~= S) )
			break;

	if ( (P != None) && Level.Game.CanSpectate(self, P) )
	{
		ClientMessage(ViewingFrom@P.PlayerReplicationInfo.PlayerName, 'Event', true);
		if ( P == self)
			ViewTarget = None;
		else
			ViewTarget = P;
	}
	else
		ClientMessage(FailedView);

	bBehindView = ( ViewTarget != None );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

exec function CheatView( class<actor> aClass )
{
	local actor other, first;
	local bool bFound;

	if( !bCheatsEnabled )
		return;

	if( !bAdmin && Level.NetMode!=NM_Standalone )
		return;

	first = None;
	ForEach AllActors( aClass, other )
	{
		if ( (first == None) && (other != self) )
		{
			first = other;
			bFound = true;
		}
		if ( other == ViewTarget ) 
			first = None;
	}  

	if ( first != None )
	{
		if ( first.IsA('Pawn') && Pawn(first).bIsPlayer && (Pawn(first).PlayerReplicationInfo.PlayerName != "") )
			ClientMessage(ViewingFrom@Pawn(first).PlayerReplicationInfo.PlayerName, 'Event', true);
		else
			ClientMessage(ViewingFrom@first, 'Event', true);
		ViewTarget = first;
	}
	else
	{
		if ( bFound )
			ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
		else
			ClientMessage(FailedView, 'Event', true);
		ViewTarget = None;
	}

	bBehindView = ( ViewTarget != None );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

exec function ViewSelf()
{
	bBehindView = false;
	Viewtarget = None;
	ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
}

exec function ViewClass( class<actor> aClass, optional bool bQuiet )
{
	local actor other, first;
	local bool bFound;

	if ( (Level.Game != None) && !Level.Game.bCanViewOthers )
		return;

	first = None;
	ForEach AllActors( aClass, other )
	{
		if ( (first == None) && (other != self)
			 && ( (bAdmin && Level.Game==None) || Level.Game.CanSpectate(self, other) ) )
		{
			first = other;
			bFound = true;
		}
		if ( other == ViewTarget ) 
			first = None;
	}  

	if ( first != None )
	{
		if ( !bQuiet )
		{
			if ( first.IsA('Pawn') && Pawn(first).bIsPlayer && (Pawn(first).PlayerReplicationInfo.PlayerName != "") )
				ClientMessage(ViewingFrom@Pawn(first).PlayerReplicationInfo.PlayerName, 'Event', true);
			else
				ClientMessage(ViewingFrom@first, 'Event', true);
		}
		ViewTarget = first;
	}
	else
	{
		if ( !bQuiet )
		{
			if ( bFound )
				ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
			else
				ClientMessage(FailedView, 'Event', true);
		}
		ViewTarget = None;
	}

	bBehindView = ( ViewTarget != None );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

exec function NeverSwitchOnPickup( bool B )
{
	bNeverAutoSwitch = B;
	bNeverSwitchOnPickup = B;
	ServerNeverSwitchOnPickup(B);
	SaveConfig();
}

function ServerNeverSwitchOnPickup(bool B)
{
	bNeverSwitchOnPickup = B;
}
	
exec function InvertMouse( bool B )
{
	bInvertMouse = B;
	SaveConfig();
}

exec function SwitchLevel( string URL )
{
	if( bAdmin || Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
		Level.ServerTravel( URL, false );
}

exec function SwitchCoopLevel( string URL )
{
	if( bAdmin || Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
		Level.ServerTravel( URL, true );
}

exec function ShowScores()
{
	bShowScores = !bShowScores;
}
 
exec function ShowMenu()
{
	WalkBob = vect(0,0,0);
	bShowMenu = true; // menu is responsible for turning this off
	Player.Console.GotoState('Menuing');
		
	if( Level.Netmode == NM_Standalone )
		SetPause(true);
}

exec function ShowLoadMenu()
{
	ShowMenu();
}

exec function AddBots(int N)
{
	ServerAddBots(N);
}

function ServerAddBots(int N)
{
	local int i;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if ( !Level.Game.bDeathMatch )
		return;

	for ( i=0; i<N; i++ )
		Level.Game.ForceAddBot();
}

	
//*************************************************************************************
// Special purpose/cheat execs

exec function ClearProgressMessages()
{
	local int i;

	for (i=0; i<8; i++)
	{
		ProgressMessage[i] = "";
		ProgressColor[i].R = 255;
		ProgressColor[i].G = 255;
		ProgressColor[i].B = 255;
	}
}

exec function SetProgressMessage( string S, int Index )
{
	if (Index < 8)
		ProgressMessage[Index] = S;
}

exec function SetProgressColor( color C, int Index )
{
	if (Index < 8)
		ProgressColor[Index] = C;
}

exec function SetProgressTime( float T )
{
	ProgressTimeOut = T + Level.TimeSeconds;
}

exec event ShowUpgradeMenu();

exec function Amphibious()
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	if (HeadRegion.Zone.bWaterZone)
		PainTime=0;
	UnderwaterTime = +999999.0;
}
	
exec function Fly()
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
		
	UnderWaterTime = Default.UnderWaterTime;	
	ClientMessage("You feel much lighter");
	SetCollision(true, true , true);
	bCollideWorld = true;
	GotoState('CheatFlying');
}

exec function SetWeaponStay( bool B)
{
	local Weapon W;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	Level.Game.bCoopWeaponMode = B;
	ForEach AllActors(class'Weapon', W)
	{
		W.bWeaponStay = false;
		W.SetWeaponStay();
	}
}

exec function Walk()
{	
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	StartWalk();
}

function StartWalk()
{
	UnderWaterTime = Default.UnderWaterTime;	
	SetCollision(true, true , true);
	SetPhysics(PHYS_Walking);
	bCollideWorld = true;
	if ( Region.Zone.bWaterZone && (PlayerRestartState == 'PlayerWalking') )
	{
		if (HeadRegion.Zone.bWaterZone)
			PainTime = UnderWaterTime;
		setPhysics(PHYS_Swimming);
		GotoState('PlayerSwimming');
	}
	else
		GotoState(PlayerReStartState);
	ClientReStart();
}

exec function Ghost()
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	
	UnderWaterTime = -1.0;	
	ClientMessage("You feel ethereal");
	SetCollision(false, false, false);
	bCollideWorld = false;
	GotoState('CheatFlying');
}

exec function ShowInventory()
{
	local Inventory Inv;
	
	if( Weapon!=None )
		log( "   Weapon: " $ Weapon.Class );
	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) 
		log( "Inv: "$Inv $ " state "$Inv.GetStateName());
	if ( SelectedItem != None )
		log( "Selected Item"@SelectedItem@"Charge"@SelectedItem.Charge );
}


exec function Invisible(bool B)
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if (B)
	{
		bHidden = true;
		Visibility = 0;
	}
	else
	{
		bHidden = false;
		Visibility = Default.Visibility;
	}	
}

exec function CheatPlease()
{
	if(bAdmin || (Level.Netmode == NM_Standalone))
	{
		bCheatsEnabled = !bCheatsEnabled;
		if(bCheatsEnabled)
			ClientMessage("Cheats Enabled");
		else
			ClientMessage("Cheats Disabled");
	}
}
	
exec function God()
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if ( ReducedDamageType == 'All' )
	{
		ReducedDamageType = '';
		ClientMessage("God mode off");
		return;
	}

	ReducedDamageType = 'All'; 
	ClientMessage("God Mode on");
}

exec function BehindView( Bool B )
{
	bBehindView = B;
}

exec function SetBob(float F)
{
	UpdateBob(F);
	SaveConfig();
}

function UpdateBob(float F)
{
	Bob = FClamp(F,0,0.032);
}

exec function SetSensitivity(float F)
{
	UpdateSensitivity(F);
	SaveConfig();
}

function UpdateSensitivity(float F)
{
	MouseSensitivity = FMax(0,F);
}

exec function SloMo( float T )
{
		ServerSetSloMo(T);
}

function ServerSetSloMo(float T)
{
	if ( bAdmin || (Level.Netmode == NM_Standalone) )
	{
		Level.Game.SetGameSpeed(T);
		Level.Game.SaveConfig(); 
		Level.Game.GameReplicationInfo.SaveConfig();
	}
}

exec function SetJumpZ( float F )
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	JumpZ = F;
}


exec function SetFriction( float F )
{
	local ZoneInfo Z;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	ForEach AllActors(class'ZoneInfo', Z)
		Z.ZoneGroundFriction = F;
}

exec function SetSpeed( float F )
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	GroundSpeed = Default.GroundSpeed * f;
	WaterSpeed = Default.WaterSpeed * f;
}

exec function KillAll(class<actor> aClass)
{
	local Actor A;

	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	ForEach AllActors(class 'Actor', A)
		if ( ClassIsChildOf(A.class, aClass) )
			A.Destroy();
}

exec function KillPawns()
{
	local Pawn P;
	
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	ForEach AllActors(class 'Pawn', P)
		if (PlayerPawn(P) == None)
			P.Destroy();
}

exec function Summon( string ClassName )
{
	local class<actor> NewClass;

	if( !bCheatsEnabled )
		return;
	if( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	log( "Fabricate " $ ClassName );
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
		Spawn( NewClass,,,Location + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
}

exec function DebugCommand( string text )
{
//	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
//		return;

	if ( myDebugHud != None )
		myDebugHud.Command(text);
}

exec function Watch( string ClassName )
{
//	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
//		return;

	if ( myDebugHud != None )
		myDebugHud.Command("WATCH"@ClassName);
}


exec function ActorState( class<actor> aClass, name statename )
{	// Order the closest scriptpawn to enter a state
	local actor A, Nearest;
	local float nearestdist, dist;

	//fixme: the exec function parser cuts the first char from 2nd parameter
	
	nearestdist = 999999999;
	nearest = None;
	foreach AllActors(aClass, A)
	{
		dist = VSize(A.Location - Location);
		if (dist < nearestdist)
		{
			nearestdist = dist;
			nearest = A;
		}
	}

	if (nearest != None)
	{
		slog(nearest.name@"->"@statename);
		nearest.GotoState(statename, '');
	}
}

exec function ShowPath()
{
	//find next path to remembered spot
	local Actor node;
	slog("show path to: "$Destination);
	if (pointReachable(Destination))
	{
		slog("destination is reachable");
		Spawn(class 'WayBeaconDest', self, '', Destination);
	}
	else
	{
	slog("destination not reachable, trying FindPathTo");
		node = FindPathTo(Destination);
		if (node != None)
		{
			slog("found path");
			Spawn(class 'WayBeacon', self, '', node.location);
		}
		else
			slog("didn't find path");
	}
}

exec function RememberSpot()
{	//remember spot
	Destination = Location;
}

//=============================================================================
// Input related functions.

// Postprocess the player's input.

event PlayerInput( float DeltaTime )
{
	local float SmoothTime, FOVScale, MouseScale, AbsSmoothX, AbsSmoothY, MouseTime;

	if ( bShowMenu && (myHud != None) ) 
	{
		if ( myHud.MainMenu != None )
			myHud.MainMenu.MenuTick( DeltaTime );
		// clear inputs
		bEdgeForward = false;
		bEdgeBack = false;
		bEdgeLeft = false;
		bEdgeRight = false;
		bWasForward = false;
		bWasBack = false;
		bWasLeft = false;
		bWasRight = false;
		aStrafe = 0;
		aTurn = 0;
		aForward = 0;
		aLookUp = 0;

		return;
	}
	else if ( bDelayedCommand )
	{
		bDelayedCommand = false;
		ConsoleCommand(DelayedCommand);
	}
				
	// Check for Dodge move
	// flag transitions
	bEdgeForward = (bWasForward ^^ (aBaseY > 0));
	bEdgeBack = (bWasBack ^^ (aBaseY < 0));
	bEdgeLeft = (bWasLeft ^^ (aStrafe > 0));
	bEdgeRight = (bWasRight ^^ (aStrafe < 0));
	bWasForward = (aBaseY > 0);
	bWasBack = (aBaseY < 0);
	bWasLeft = (aStrafe > 0);
	bWasRight = (aStrafe < 0);
	
	// Smooth and amplify mouse movement
	SmoothTime = FMin(0.2, 3 * DeltaTime * Level.TimeDilation);
	FOVScale = DesiredFOV * 0.01111; 
	MouseScale = MouseSensitivity * FOVScale;
	aMouseX *= MouseScale;
	aMouseY *= MouseScale;

//************************************************************************

	//log("X "$aMouseX$" Smooth "$SmoothMouseX$" Borrowed "$BorrowedMouseX$" zero time "$(Level.TimeSeconds - MouseZeroTime)$" vs "$MouseSmoothThreshold);
	AbsSmoothX = SmoothMouseX;
	AbsSmoothY = SmoothMouseY;
	MouseTime = (Level.TimeSeconds - MouseZeroTime)/Level.TimeDilation;
	if ( bMaxMouseSmoothing && (aMouseX == 0) && (MouseTime < MouseSmoothThreshold) )
	{
		SmoothMouseX = 0.5 * (MouseSmoothThreshold - MouseTime) * AbsSmoothX/MouseSmoothThreshold;
		BorrowedMouseX += SmoothMouseX;
	}
	else
	{
		if ( (SmoothMouseX == 0) || (aMouseX == 0) 
				|| ((SmoothMouseX > 0) != (aMouseX > 0)) )
		{
			SmoothMouseX = aMouseX;
			BorrowedMouseX = 0;
		}
		else
		{
			SmoothMouseX = 0.5 * (SmoothMouseX + aMouseX - BorrowedMouseX);
			if ( (SmoothMouseX > 0) != (aMouseX > 0) )
			{
				if ( AMouseX > 0 )
					SmoothMouseX = 1;
				else
					SmoothMouseX = -1;
			} 
			BorrowedMouseX = SmoothMouseX - aMouseX;
		}
		AbsSmoothX = SmoothMouseX;
	}
	if ( bMaxMouseSmoothing && (aMouseY == 0) && (MouseTime < MouseSmoothThreshold) )
	{
		SmoothMouseY = 0.5 * (MouseSmoothThreshold - MouseTime) * AbsSmoothY/MouseSmoothThreshold;
		BorrowedMouseY += SmoothMouseY;
	}
	else
	{
		if ( (SmoothMouseY == 0) || (aMouseY == 0) 
				|| ((SmoothMouseY > 0) != (aMouseY > 0)) )
		{
			SmoothMouseY = aMouseY;
			BorrowedMouseY = 0;
		}
		else
		{
			SmoothMouseY = 0.5 * (SmoothMouseY + aMouseY - BorrowedMouseY);
			if ( (SmoothMouseY > 0) != (aMouseY > 0) )
			{
				if ( AMouseY > 0 )
					SmoothMouseY = 1;
				else
					SmoothMouseY = -1;
			} 
			BorrowedMouseY = SmoothMouseY - aMouseY;
		}
		AbsSmoothY = SmoothMouseY;
	}
	if ( (aMouseX != 0) || (aMouseY != 0) )
		MouseZeroTime = Level.TimeSeconds;

	// adjust keyboard and joystick movements
	aLookUp *= FOVScale;
	aTurn   *= FOVScale;

	// Remap raw x-axis movement.
	if( bStrafe!=0 )
	{
		// Strafe.
		aStrafe += aBaseX + SmoothMouseX;
		aBaseX   = 0;
	}
	else
	{
		// Forward.
		aTurn  += aBaseX * FOVScale + SmoothMouseX;
		aBaseX  = 0;
	}

	// Remap mouse y-axis movement.
	if( (bStrafe == 0) && (bAlwaysMouseLook || (bLook!=0)) )
	{
		// Look up/down.
		if ( bInvertMouse )
			aLookUp -= SmoothMouseY;
		else
			aLookUp += SmoothMouseY;
	}
	else
	{
		// Move forward/backward.
		aForward += SmoothMouseY;
	}
	SmoothMouseX = AbsSmoothX;
	SmoothMouseY = AbsSmoothY;

	if ( bSnapLevel != 0 )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}
	else if (aLookUp != 0)
	{
		bCenterView = false;
		bKeyboardLook = true;
	}
	else if ( bSnapToLevel && !bAlwaysMouseLook )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}

	// Remap other y-axis movement.
	if ( bFreeLook != 0 )
	{
		bKeyboardLook = true;
		aLookUp += 0.5 * aBaseY * FOVScale;
	}
	else
		aForward += aBaseY;

	aBaseY = 0;

	// Handle walking.
	HandleWalking();
}

//=============================================================================
// functions.

event UpdateEyeHeight(float DeltaTime)
{
	local float smooth, bound;
	

	// smooth up/down stairs
	If( (Physics==PHYS_Walking) && !bJustLanded )
	{
		smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
		EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + ( ShakeVert + BaseEyeHeight) * smooth;
		bound = -0.5 * CollisionHeight;
		if (EyeHeight < bound)
			EyeHeight = bound;
		else
		{
			bound = CollisionHeight + FClamp((OldLocation.Z - Location.Z), 0.0, MaxStepHeight); 
			if ( EyeHeight > bound )
				EyeHeight = bound;
		}
	}
	else
	{
		smooth = FClamp(10.0 * DeltaTime/Level.TimeDilation, 0.35,1.0);
		bJustLanded = false;
		EyeHeight = EyeHeight * ( 1 - smooth) + (BaseEyeHeight + ShakeVert) * smooth;
	}

	// teleporters affect your FOV, so adjust it back down
	if ( FOVAngle != DesiredFOV )
	{
		if ( FOVAngle > DesiredFOV )
			FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV)); 
		else 
			FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV)); 
		if ( Abs(FOVAngle - DesiredFOV) <= 10 )
			FOVAngle = DesiredFOV;
	}

	// adjust FOV for weapon zooming
	if ( bZooming )
	{	
		ZoomLevel += DeltaTime * 1.0;
		if (ZoomLevel > 0.9)
			ZoomLevel = 0.9;
		DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
	} 
}

event PlayerTimeOut()
{
	if (Health > 0)
		Died(None, 'suicided', Location);
}

// Just changed to pendingWeapon
function ChangedWeapon()
{
	Super.ChangedWeapon();
//	if ( PendingWeapon != None )
//		PendingWeapon.SetHand(Handedness);
}

function JumpOffPawn()
{
	Velocity += 60 * VRand();
	Velocity.Z = 120;
	SetPhysics(PHYS_Falling);
}

event TravelPostAccept()
{
	if ( Health <= 0 )
		Health = Default.Health;
}

// This pawn was possessed by a player.
event Possess()
{
	if ( Level.Netmode == NM_Client )
	{
		// replicate client weapon preferences to server
		ServerNeverSwitchOnPickup(bNeverAutoSwitch);
//		ServerSetHandedness(Handedness);
		UpdateWeaponPriorities();
	}
	ServerUpdateWeapons();
	bIsPlayer = true;
	DodgeClickTime = FMin(0.3, DodgeClickTime);
	EyeHeight = BaseEyeHeight;
	NetPriority = 3;
	StartWalk();
}

function UpdateWeaponPriorities()
{
	local byte i;

	// send new priorities to server
	if ( Level.Netmode == NM_Client )
		for ( i=0; i<ArrayCount(WeaponPriority); i++ )
			ServerSetWeaponPriority(i, WeaponPriority[i]);
}

function ServerSetWeaponPriority(byte i, name WeaponName )
{
	local inventory inv;

	WeaponPriority[i] = WeaponName;
/*
	for ( inv=Inventory; inv!=None; inv=inv.inventory )
		if ( inv.class.name == WeaponName )
			Weapon(inv).SetSwitchPriority(self);
*/
}

// This pawn was unpossessed by a player.
event UnPossess()
{
	log(Self$" being unpossessed");
	if ( myHUD != None )
		myHUD.Destroy();
	bIsPlayer = false;
	EyeHeight = 0.8 * CollisionHeight;
}

event PlayerTick( float Time )
{
}

function BoostStrength(int amount);
function StrengthDecay(float Time);

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	bIsPlayer = true;
	Super.PreBeginPlay();
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Level.LevelEnterText != "" )
		ClientMessage(Level.LevelEnterText);
	if ( Level.NetMode != NM_Client )
	{
		HUDType = Level.Game.HUDType;
		ScoringType = Level.Game.ScoreboardType;
		MyAutoAim = FMax(MyAutoAim, Level.Game.AutoAim);
	}
	bIsPlayer = true;
	DodgeClickTime = FMin(0.3, DodgeClickTime);
	DesiredFOV = DefaultFOV;
	EyeHeight = BaseEyeHeight;
}

function ServerUpdateWeapons()
{
/* RUNE:  Obsolete Unreal Weapon Code

	local inventory Inv;

	For ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Inv.IsA('Weapon') )
			Weapon(Inv).SetSwitchPriority(self); 

*/
}

//=============================================================================
// Animation playing - should be implemented in subclass, 
//

function PlayDodge(eDodgeDir DodgeMove)
{
	PlayDuck();
}

function PlayTurning(optional float tween);

function PlaySwimming()
{
	PlayMoving();
}

function TweenToSwimming(float tween);
function PlayFeignDeath();
function PlayRising();


/* AdjustAim()
Calls this version for player aiming help.
Aimerror not used in this version.
Only adjusts aiming at pawns
*/

function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
	local vector FireDir, AimSpot, HitNormal, HitLocation;
	local actor BestTarget;
	local float bestAim, bestDist;
	local actor HitActor;
	
	FireDir = vector(ViewRotation);
	HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
	if ( (HitActor != None) && HitActor.bProjTarget )
	{
		if ( bWarnTarget && HitActor.IsA('Pawn') )
			Pawn(HitActor).WarnTarget(self, projSpeed, FireDir);
		return ViewRotation;
	}

	bestAim = FMin(0.93, MyAutoAim);
	BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart);

	if ( bWarnTarget && (Pawn(BestTarget) != None) )
		Pawn(BestTarget).WarnTarget(self, projSpeed, FireDir);	

	if ( (Level.NetMode != NM_Standalone) || (Level.Game.Difficulty > 2) 
		|| bAlwaysMouseLook || ((BestTarget != None) && (bestAim < MyAutoAim)) || (MyAutoAim >= 1) )
		return ViewRotation;
	
	if ( BestTarget == None )
	{
		bestAim = MyAutoAim;
		BestTarget = PickAnyTarget(bestAim, bestDist, FireDir, projStart);
		if ( BestTarget == None )
			return ViewRotation;
	}

	AimSpot = projStart + FireDir * bestDist;
	AimSpot.Z = BestTarget.Location.Z + 0.3 * BestTarget.CollisionHeight;

	return rotator(AimSpot - projStart);
}

/* 
function Falling()
{
	//SetPhysics(PHYS_Falling); //Note - physics changes type to PHYS_Falling by default
	//log(class$" Falling");
	PlayInAir(0.1);
}
*/

function Died(pawn Killer, name damageType, vector HitLocation)
{
	StopZoom();

	// RUNE:  Fire an event that is zone-specific when the player dies
	if(Region.Zone.ZonePlayerDiedEvent != '')
		FireEvent(Region.Zone.ZonePlayerDiedEvent);

	Super.Died(Killer, damageType, HitLocation);	
}

function eAttitude AttitudeTo(Pawn Other)
{
	if (Other.bIsPlayer)
		return AttitudeToPlayer;
	else 
		return Other.AttitudeToPlayer;
}


function string KillMessage( name damageType, pawn Other )
{
	return ( Level.Game.PlayerKillMessage(damageType, Other.PlayerReplicationInfo)$PlayerReplicationInfo.PlayerName );
}
	
//=============================================================================
// Player Control

function KilledBy( pawn EventInstigator )
{
	Health = 0;
	Died( EventInstigator, 'suicided', Location );
}

// Player view.
// Compute the rendering viewpoint for the player.
//

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	CameraRotation = ViewRotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View; 
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Pawn PTarget;

	if ( ViewTarget != None )
	{
		ViewActor = ViewTarget;
		CameraLocation = ViewTarget.Location;
		CameraRotation = ViewTarget.Rotation;
		PTarget = Pawn(ViewTarget);
		if ( PTarget != None )
		{
			if ( Level.NetMode == NM_Client )
			{
				if ( PTarget.bIsPlayer )
					PTarget.ViewRotation = TargetViewRotation;
				PTarget.EyeHeight = TargetEyeHeight;
/* RUNE:  Obsolete Unreal Weapon Code
				if ( PTarget.Weapon != None )
					PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
*/
			}
			if ( PTarget.bIsPlayer )
				CameraRotation = PTarget.ViewRotation;
			if ( !bBehindView )
				CameraLocation.Z += PTarget.EyeHeight;
		}
		if ( bBehindView )
			CalcBehindView(CameraLocation, CameraRotation, 180);
		return;
	}

	ViewActor = Self;
	CameraLocation = Location;

	if( bBehindView ) //up and behind
		CalcBehindView(CameraLocation, CameraRotation, 150);
	else
	{
		// First-person view.
		CameraRotation = ViewRotation;
		CameraLocation.Z += EyeHeight;
		CameraLocation += WalkBob;
	}
}

exec function SetViewFlash(bool B)
{
	bNoFlash = !B;
}

function ViewFlash(float DeltaTime)
{
	local vector goalFog;
	local float goalscale, delta;

	if ( bNoFlash )
	{
		InstantFlash = 0;
		InstantFog = vect(0,0,0);
		FlashFog = vect(0,0,0);
		FlashScale = vect(1,1,1);
		return;
	}


	delta = FMin(0.1, DeltaTime);
	goalScale = 1 + DesiredFlashScale + ConstantGlowScale + HeadRegion.Zone.ViewFlash.X; 
	goalFog = DesiredFlashFog + ConstantGlowFog + HeadRegion.Zone.ViewFog;
	DesiredFlashScale -= DesiredFlashScale * 2 * delta;  
	DesiredFlashFog -= DesiredFlashFog * 2 * delta;
	FlashScale.X += (goalScale - FlashScale.X + InstantFlash) * 10 * delta;
	FlashFog += (goalFog - FlashFog + InstantFog) * 10 * delta;
	InstantFlash = 0;
	InstantFog = vect(0,0,0);

	if ( FlashScale.X > 0.981 )
		FlashScale.X = 1;
	FlashScale = FlashScale.X * vect(1,1,1);

	if ( FlashFog.X < 0.019 )
		FlashFog.X = 0;
	if ( FlashFog.Y < 0.019 )
		FlashFog.Y = 0;
	if ( FlashFog.Z < 0.019 )
		FlashFog.Z = 0;
}

// NOTE:  This function is overridden in RunePlayer
function ViewShake(float DeltaTime)
{
	local float delta;

	if (shaketimer > 0.0) //shake view
	{
		shaketimer -= DeltaTime;
		if ( verttimer == 0 )
		{
			verttimer = 0.1;
			ShakeVert = -1.1 * maxshake;
		}
		else
		{
			verttimer -= DeltaTime;
			if ( verttimer < 0 )
			{
				verttimer = 0.2 * FRand();
				shakeVert = (2 * FRand() - 1) * maxshake;  
			}
		}
		ViewRotation.Roll = ViewRotation.Roll & 65535;
		if (bShakeDir)
		{
			ViewRotation.Roll += Int( 10 * shakemag * FMin(0.1, DeltaTime));
			bShakeDir = (ViewRotation.Roll > 32768) || (ViewRotation.Roll < (0.5 + FRand()) * shakemag);
			if ( (ViewRotation.Roll < 32768) && (ViewRotation.Roll > 1.3 * shakemag) )
			{
				ViewRotation.Roll = 1.3 * shakemag;
				bShakeDir = false;
			}
			else if (FRand() < 3 * DeltaTime)
				bShakeDir = !bShakeDir;
		}
		else
		{
			ViewRotation.Roll -= Int( 10 * shakemag * FMin(0.1, DeltaTime));
			bShakeDir = (ViewRotation.Roll > 32768) && (ViewRotation.Roll < 65535 - (0.5 + FRand()) * shakemag);
			if ( (ViewRotation.Roll > 32768) && (ViewRotation.Roll < 65535 - 1.3 * shakemag) )
			{
				ViewRotation.Roll = 65535 - 1.3 * shakemag;
				bShakeDir = true;
			}
			else if (FRand() < 3 * DeltaTime)
				bShakeDir = !bShakeDir;
		}
	}
	else
	{
		ShakeVert = 0;
		ViewRotation.Roll = ViewRotation.Roll & 65535;
		if (ViewRotation.Roll < 32768)
		{
			if ( ViewRotation.Roll > 0 )
				ViewRotation.Roll = Max(0, ViewRotation.Roll - (Max(ViewRotation.Roll,500) * 10 * FMin(0.1,DeltaTime)));
		}
		else
		{
			ViewRotation.Roll += ((65536 - Max(500,ViewRotation.Roll)) * 10 * FMin(0.1,DeltaTime));
			if ( ViewRotation.Roll > 65534 )
				ViewRotation.Roll = 0;
		}
	} 
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator newRotation;
	
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
//	ViewShake(deltaTime); // RUNE:  ViewShake is handled in the Camera code
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

function SwimAnimUpdate(bool bNotForward)
{
	if ( !bAnimTransition && (GetAnimGroup(AnimSequence) != 'Gesture') )
	{
		if ( bNotForward )
	 	{
		 	 if ( GetAnimGroup(AnimSequence) != 'Waiting' )
				TweenToWaiting(0.1);
		}
		else if ( GetAnimGroup(AnimSequence) == 'Waiting' )
			TweenToSwimming(0.1);
	}
}

auto state InvalidState
{
	event PlayerTick( float DeltaTime )
	{
		log(self$" invalid state");
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove( float DeltaTime )
	{
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), Dodge_None, rot(0,0,0));
	}
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	exec function FeignDeath()
	{
		if ( Physics == PHYS_Walking )
		{
			ServerFeignDeath();
			Acceleration = vect(0,0,0);
			GotoState('FeigningDeath');
		}
	}

	function ZoneChange( ZoneInfo NewZone )
	{
		if (NewZone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
	}

	function AnimEnd()
	{
		local name MyAnimGroup;

		bAnimTransition = false;
		if (Physics == PHYS_Walking)
		{
			if (bIsCrouching)
			{
				if ( !bIsTurning && ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000) )
					PlayDuck();	
				else
					PlayCrawling();
			}
			else
			{
				MyAnimGroup = GetAnimGroup(AnimSequence);
				if ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000)
				{
					if ( MyAnimGroup == 'Waiting' )
						PlayWaiting();
					else
					{
						bAnimTransition = true;
						TweenToWaiting(0.2);
					}
				}	
				else
				{
					if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
					{
						TweenToMoving(0.1);
						bAnimTransition = true;
					}
					else 
						PlayMoving();
				}
			}
		}
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		Super.Landed(HitNormal, HitActor);

		if (Velocity.Z < -1.4 * JumpZ)
			ShakeView(0.175 - 0.00007 * Velocity.Z, -0.85 * Velocity.Z, -0.002 * Velocity.Z);

		if (DodgeDir == DODGE_Active)
		{
			DodgeDir = DODGE_Done;
			DodgeClickTimer = 0.0;
			Velocity *= 0.1;
		}
		else
			DodgeDir = DODGE_None;
	}

	function Dodge(eDodgeDir DodgeMove)
	{
		local vector X,Y,Z;

		if ( bIsCrouching || (Physics != PHYS_Walking) )
			return;

		GetAxes(Rotation,X,Y,Z);
		if (DodgeMove == DODGE_Forward)
			Velocity = 1.3*GroundSpeed*X + (Velocity Dot Y)*Y;
		else if (DodgeMove == DODGE_Back)
			Velocity = -1.3*GroundSpeed*X + (Velocity Dot Y)*Y; 
		else if (DodgeMove == DODGE_Left)
			Velocity = 1.3*GroundSpeed*Y + (Velocity Dot X)*X; 
		else if (DodgeMove == DODGE_Right)
			Velocity = -1.3*GroundSpeed*Y + (Velocity Dot X)*X; 

		Velocity.Z = 180;
		PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
		PlayDodge(DodgeMove);
		DodgeDir = DODGE_Active;
		SetPhysics(PHYS_Falling);
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		local vector OldAccel;

		OldAccel = Acceleration;
		Acceleration = NewAccel;
		bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );
		if ( (DodgeMove == DODGE_Active) && (Physics == PHYS_Falling) )
			DodgeDir = DODGE_Active;	
		else if ( (DodgeMove != DODGE_None) && (DodgeMove < DODGE_Active) )
			Dodge(DodgeMove);

		if ( bPressedJump )
			DoJump();
		if ( (Physics == PHYS_Walking) && (GetAnimGroup(AnimSequence) != 'Dodge') )
		{
			if (!bIsCrouching)
			{
				if (bDuck != 0)
				{
					bIsCrouching = true;
					PlayDuck();
				}
			}
			else if (bDuck == 0)
			{
				OldAccel = vect(0,0,0);
				bIsCrouching = false;
				TweenToMoving(0.1);
//				TweenToRunning(0.1);
			}

			if ( !bIsCrouching )
			{
				if ( (!bAnimTransition || (AnimFrame > 0)) && (GetAnimGroup(AnimSequence) != 'Landing') )
				{
					if ( Acceleration != vect(0,0,0) )
					{
						if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture') || (GetAnimGroup(AnimSequence) == 'TakeHit') )
						{
							bAnimTransition = true;
							TweenToMoving(0.1);
						}
					}
			 		else if ( (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000) 
						&& (GetAnimGroup(AnimSequence) != 'Gesture') ) 
			 		{
			 			if ( GetAnimGroup(AnimSequence) == 'Waiting' )
			 			{
							if ( bIsTurning && (AnimFrame >= 0) ) 
							{
								bAnimTransition = true;
								PlayTurning();
							}
						}
			 			else if ( !bIsTurning ) 
						{
							bAnimTransition = true;
							TweenToWaiting(0.2);
						}
					}
				}
			}
			else
			{
				if ( (OldAccel == vect(0,0,0)) && (Acceleration != vect(0,0,0)) )
					PlayCrawling();
			 	else if ( !bIsTurning && (Acceleration == vect(0,0,0)) && (AnimFrame > 0.1) )
					PlayDuck();
			}
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
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool	bSaveJump;
		local name AnimGroupName;

		GetAxes(Rotation,X,Y,Z);

		aForward *= 0.4;
		aStrafe  *= 0.4;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y; 
		NewAccel.Z = 0;
		// Check for Dodge move
		if ( DodgeDir == DODGE_Active )
			DodgeMove = DODGE_Active;
		else
			DodgeMove = DODGE_None;
		if (DodgeClickTime > 0.0)
		{
			if ( DodgeDir < DODGE_Active )
			{
				OldDodge = DodgeDir;
				DodgeDir = DODGE_None;
				if (bEdgeForward && bWasForward)
					DodgeDir = DODGE_Forward;
				if (bEdgeBack && bWasBack)
					DodgeDir = DODGE_Back;
				if (bEdgeLeft && bWasLeft)
					DodgeDir = DODGE_Left;
				if (bEdgeRight && bWasRight)
					DodgeDir = DODGE_Right;
				if ( DodgeDir == DODGE_None)
					DodgeDir = OldDodge;
				else if ( DodgeDir != OldDodge )
					DodgeClickTimer = DodgeClickTime + 0.5 * DeltaTime;
				else 
					DodgeMove = DodgeDir;
			}
	
			if (DodgeDir == DODGE_Done)
			{
				DodgeClickTimer -= DeltaTime;
				if (DodgeClickTimer < -0.35) 
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}		
			else if ((DodgeDir != DODGE_None) && (DodgeDir != DODGE_Active))
			{
				DodgeClickTimer -= DeltaTime;			
				if (DodgeClickTimer < 0)
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}
		}
	
		AnimGroupName = GetAnimGroup(AnimSequence);		
		if ( (Physics == PHYS_Walking) && (AnimGroupName != 'Dodge') )
		{
			//if walking, look up/down stairs - unless player is rotating view
			if ( !bKeyboardLook && (bLook == 0) )
			{
				if ( bLookUpStairs )
					ViewRotation.Pitch = FindStairRotation(deltaTime);
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(ViewRotation.Pitch) < 1000 )
						ViewRotation.Pitch = 0;	
				}
			}

			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			//add bobbing when walking
			if ( !bShowMenu )
				CheckBob(DeltaTime, Speed2D, Y);
		}	
		else if ( !bShowMenu )
		{ 
			BobTime = 0;
			WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		// Update rotation.
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( bPressedJump && (AnimGroupName == 'Dodge') )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
		if ( Mesh == None )
			SetMesh();
		WalkBob = vect(0,0,0);
		DodgeDir = DODGE_None;
		bIsCrouching = false;
		bIsTurning = false;
		bPressedJump = false;
		if (Physics != PHYS_Falling) SetPhysics(PHYS_Walking);
		if ( !IsAnimating() )
			PlayWaiting();
	}
	
	function EndState()
	{
		WalkBob = vect(0,0,0);
		bIsCrouching = false;
	}
}

//-----------------------------------------------------------------------------
//
// STATE EdgeHanging
//
//-----------------------------------------------------------------------------

state EdgeHanging
{
ignores SeePlayer, HearNoise, Bump, Fire, AltFire, GrabEdge, Jump, SwitchWeapon;

	function ZoneChange( ZoneInfo NewZone )
	{
		if (NewZone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
	}

	function bool CanGotoPainState()
	{ // Do not allow the actor to enter the painstate when edge hanging
		return(false);
	}

	function PlayChatting()
	{
	}

	exec function Taunt()
	{
	}

	function AnimEnd()
	{
	}
	
	function Landed(vector HitNormal, actor HitActor)
	{
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		if(bPressedJump)
		{
			SetPhysics(PHYS_Falling);
			GotoState('PlayerWalking');
		}
		Acceleration = vect(0,0,0);
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
		local rotator currentRot;
		local vector NewAccel;

		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		if ( !IsAnimating() && (aForward != 0) || (aStrafe != 0) )
			NewAccel = vect(0,0,1);
		else
			NewAccel = vect(0,0,0);

		// Update view rotation.
		currentRot = Rotation;
		UpdateRotation(DeltaTime, 1);
		SetRotation(currentRot);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		bPressedJump = false;
	}

	function PlayTakeHit(float tweentime, int damage, vector HitLoc, name damageType, vector Momentum, int BodyPart)
	{
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

	function EndState()
	{
	}

	function BeginState()
	{
		bIsCrouching = false;
		bPressedJump = false;
		
	}

begin:
	PlayPullUp();
	
	Sleep(0.2);
	AirSpeed = 175;
	
	SetPhysics(PHYS_Flying);
	MoveTo(GrabLocationUp);
	MoveTo(GrabLocationIn);
	SetPhysics(PHYS_None);
	FinishAnim();

	PlayWaiting();
	AirSpeed = Default.AirSpeed;
//	CameraRotSpeed = Default.CameraRotSpeed;
	
	GotoState('PlayerWalking');
}

state FeigningDeath
{
ignores SeePlayer, HearNoise, Bump;

	function ZoneChange( ZoneInfo NewZone )
	{
		if (NewZone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
	}

	exec function Fire( optional float F )
	{
		bJustFired = true;
	}

	exec function AltFire( optional float F )
	{
		bJustFired = true;
	}

	function PlayChatting()
	{
	}

	exec function Taunt()
	{
	}

	function AnimEnd()
	{
		if ( (Role == ROLE_Authority) && (Health > 0) )
		{
			GotoState('PlayerWalking');
//			PendingWeapon.SetDefaultDisplayProperties();
			ChangedWeapon();
		}
	}
	
	function Rise()
	{
		if ( !bRising )
		{
			Enable('AnimEnd');
			BaseEyeHeight = Default.BaseEyeHeight;
			bRising = true;
			PlayRising();
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		if ( bJustFired || bPressedJump || (NewAccel.Z > 0) )
			Rise();
		Acceleration = vect(0,0,0);
	}

	event PlayerTick( float DeltaTime )
	{
		Weapon = None; // in case client confused because of weapon switch just before feign death
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
		local rotator currentRot;
		local vector NewAccel;

		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		if ( !IsAnimating() && (aForward != 0) || (aStrafe != 0) )
			NewAccel = vect(0,0,1);
		else
			NewAccel = vect(0,0,0);

		// Update view rotation.
		currentRot = Rotation;
		UpdateRotation(DeltaTime, 1);
		SetRotation(currentRot);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		bPressedJump = false;
	}

	function PlayTakeHit(float tweentime, int damage, vector HitLoc, name damageType, vector Momentum, int BodyPart)
	{
		if ( IsAnimating() )
		{
			Enable('AnimEnd');
			Global.PlayTakeHit(tweentime, damage, HitLoc, damageType, Momentum, BodyPart);
		}
	}
	
	function PlayDying(name DamageType, vector HitLocation)
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( bRising || IsAnimating() )
			Global.PlayDying(DamageType, HitLocation);
	}
	
	function ChangedWeapon()
	{
		Weapon = None;
		Inventory.ChangedWeapon();
	}

	function EndState()
	{
		bJustFired = false;
		PlayerReplicationInfo.bFeigningDeath = false;
	}

	function BeginState()
	{
		local rotator NewRot;
		NewRot = Rotation;
		NewRot.Pitch = 0;
		SetRotation(NewRot);
		BaseEyeHeight = -0.5 * CollisionHeight;
		bIsCrouching = false;
		bPressedJump = false;
		bJustFired = false;
		bRising = false;
		Disable('AnimEnd');
		PlayFeignDeath();
		PlayerReplicationInfo.bFeigningDeath = true;
	}
}

// Player movement.
// Player Swimming
state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;

	event UpdateEyeHeight(float DeltaTime)
	{
		local float smooth, bound;
		
		// smooth up/down stairs
		if( !bJustLanded )
		{
			smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
			EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + ( ShakeVert + BaseEyeHeight) * smooth;
			bound = -0.5 * CollisionHeight;
			if (EyeHeight < bound)
				EyeHeight = bound;
			else
			{
				bound = CollisionHeight + FClamp((OldLocation.Z - Location.Z), 0.0, MaxStepHeight); 
				 if ( EyeHeight > bound )
					EyeHeight = bound;

			}
		}
		else
		{
			smooth = FClamp(10.0 * DeltaTime/Level.TimeDilation, 0.35, 1.0);
			bJustLanded = false;
			EyeHeight = EyeHeight * ( 1 - smooth) + (BaseEyeHeight + ShakeVert) * smooth;
		}

		// teleporters affect your FOV, so adjust it back down
		if ( FOVAngle != DesiredFOV )
		{
			if ( FOVAngle > DesiredFOV )
				FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV)); 
			else 
				FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV)); 
			if ( Abs(FOVAngle - DesiredFOV) <= 10 )
				FOVAngle = DesiredFOV;
		}

		// adjust FOV for weapon zooming
		if ( bZooming )
		{	
			ZoomLevel += DeltaTime * 1.0;
			if (ZoomLevel > 0.9)
				ZoomLevel = 0.9;
			DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
		} 
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		if ( !bUpdating )
		{
			//log(class$" Landed while swimming");
			PlayLanded(Velocity.Z);
			//TakeFallingDamage();
			bJustLanded = true;
		}
		if ( Region.Zone.bWaterZone )
			SetPhysics(PHYS_Swimming);
		else
		{
			GotoState('PlayerWalking');
			AnimEnd();
		}
	}

	function AnimEnd()
	{
		local vector X,Y,Z;
		GetAxes(Rotation, X,Y,Z);
		if ( (Acceleration Dot X) <= 0 )
		{
			if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
			{
				bAnimTransition = true;
				TweenToWaiting(0.2);
			} 
			else
				PlayWaiting();
		}	
		else
		{
			if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
			{
				bAnimTransition = true;
				TweenToSwimming(0.2);
			} 
			else
				PlaySwimming();
		}
	}
	
	function ZoneChange( ZoneInfo NewZone )
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, checkpoint;

		if (!NewZone.bWaterZone)
		{
			SetPhysics(PHYS_Falling);
			if (bUpAndOut && CheckWaterJump(HitNormal)) //check for waterjump
			{
				velocity.Z = 330 + 2 * CollisionRadius; //set here so physics uses this for remainder of tick
				PlayDuck();
				GotoState('PlayerWalking');
			}				
			else if (!FootRegion.Zone.bWaterZone || (Velocity.Z > 160) )
			{
				GotoState('PlayerWalking');
				AnimEnd();
			}
			else //check if in deep water
			{
				checkpoint = Location;
				checkpoint.Z -= (CollisionHeight + 6.0);
				HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, false);
				if (HitActor != None)
				{
					GotoState('PlayerWalking');
					AnimEnd();
				}
				else
				{
					Enable('Timer');
					SetTimer(0.7,false);
				}
			}
			//log("Out of water");
		}
		else
		{
			Disable('Timer');
			SetPhysics(PHYS_Swimming);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		local vector X,Y,Z, Temp;
	
		GetAxes(ViewRotation,X,Y,Z);
		Acceleration = NewAccel;

		SwimAnimUpdate( (X Dot Acceleration) <= 0 );

		bUpAndOut = ((X Dot Acceleration) > 0) && ((Acceleration.Z > 0) || (ViewRotation.Pitch > 2048));
		if ( bUpAndOut && !Region.Zone.bWaterZone && CheckWaterJump(Temp) ) //check for waterjump
		{
			velocity.Z = 330 + 2 * CollisionRadius; //set here so physics uses this for remainder of tick
			PlayDuck();
			GotoState('PlayerWalking');
		}				
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;
		local float Speed2D;
	
		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.2;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;  
		
		NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1); 
	
		//add bobbing when swimming
		if ( !bShowMenu )
		{
			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
			WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);
		}

		// Update rotation.
		oldRotation = Rotation;
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
		bPressedJump = false;
	}

	function Timer()
	{
		if ( !Region.Zone.bWaterZone && (Role == ROLE_Authority) )
		{
			//log("timer out of water");
			GotoState('PlayerWalking');
			AnimEnd();
		}
	
		Disable('Timer');
	}
	
	function BeginState()
	{
		Disable('Timer');
		if ( !IsAnimating() )
			TweenToWaiting(0.3);
		//log("player swimming");
	}
}

state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;
		
	function AnimEnd()
	{
		PlaySwimming();
	}
	
	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
	
		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		aForward *= 0.2;
		aStrafe  *= 0.2;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		Acceleration = aForward*X + aStrafe*Y;  
		// Update rotation.
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}
	
	function BeginState()
	{
		SetPhysics(PHYS_Flying);
		if  ( !IsAnimating() ) PlayMoving();
		//log("player flying");
	}
}

state CheatFlying
{
ignores SeePlayer, HearNoise, Bump, JointDamaged;
		
	function AnimEnd()
	{
		PlaySwimming();
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		Acceleration = Normal(NewAccel);
		Velocity = Normal(NewAccel) * 300;
		AutonomousPhysics(DeltaTime);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;
	
		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function BeginState()
	{
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_Flying);
		if  ( !IsAnimating() ) PlaySwimming();
	}
}

state PlayerWaiting
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange;

	exec function Jump( optional float F )
	{
	}

	exec function Suicide()
	{
	}

	function ChangeTeam( int N )
	{
		Level.Game.ChangeTeam(self, N);
	}

	exec function Fire(optional float F)
	{
		bReadyToPlay = true;
	}
	
	exec function AltFire(optional float F)
	{
		bReadyToPlay = true;
	}
		
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	function PlayWaiting(optional float tween){}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;
	
		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function EndState()
	{
		SetMesh();
		PlayerReplicationInfo.bIsSpectator = false;
		PlayerReplicationInfo.bWaitingPlayer = false;
		SetCollision(true,true,true);
	}

	function BeginState()
	{
		Mesh = None;
		if ( PlayerReplicationInfo != None )
		{
			PlayerReplicationInfo.bIsSpectator = true;
			PlayerReplicationInfo.bWaitingPlayer = true;
		}
		SetCollision(false,false,false);
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_None);
	}
}

state PlayerSpectating
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange;

	exec function Suicide()
	{
	}

	function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
	{
	}

	exec function AltFire( optional float F )
	{
		bBehindView = false;
		Viewtarget = None;
		ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
	}

	function ChangeTeam( int N )
	{
		Level.Game.ChangeTeam(self, N);
	}

	exec function Fire( optional float F )
	{
		if ( Role == ROLE_Authority )
		{
			ViewPlayerNum(-1);
			bBehindView = true;
		}
	} 

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;
	
		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function EndState()
	{
		PlayerReplicationInfo.bIsSpectator = false;
		PlayerReplicationInfo.bWaitingPlayer = false;
		SetMesh();
		SetCollision(true,true,true);
	}

	function BeginState()
	{
		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bWaitingPlayer = true;
		bShowScores = true;
		Mesh = None;
		SetCollision(false,false,false);
		EyeHeight = Default.BaseEyeHeight;
		SetPhysics(PHYS_None);
	}
}

//------------------------------------------------------------
//
// Pain
//
// For now, the pain state does nothing on the player
//------------------------------------------------------------

state Pain
{
	function bool CanGotoPainState()
	{ // Do not allow the actor to enter the painstate when already in pain
		return(false);
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

Begin:
	GotoState(NextStateAfterPain);
}

//------------------------------------------------------------
//
// Uninterrupted
//
//------------------------------------------------------------

state Uninterrupted
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, Landed;

	function bool CanGotoPainState()
	{ // Do not allow the actor to enter the painstate when in uninterrupted mode
		return(false);
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

	function AnimEnd()
	{
	}

begin:
	if(UninterruptedAnim != '')
	{
		PlayAnim(UninterruptedAnim, 1.0, 0.1);
		if(AnimProxy != None)
			AnimProxy.PlayAnim(UninterruptedAnim, 1.0, 0.1);
		
		FinishAnim();
		
		// Clear out any blending information (if it exists)
		BlendAnimSequence = 'None';
		if(AnimProxy != None)
		{
			AnimProxy.BlendAnimSequence = 'None';			
			AnimProxy.GotoState('Idle');
		}

		GotoState(NextState);
	}
}

//------------------------------------------------------------
//
// Dying
//
//------------------------------------------------------------
state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, Landed, SwitchWeapon;

	function ServerReStartPlayer()
	{
		//slog("calling restartplayer in dying with netmode "$Level.NetMode);
		if ( Level.NetMode == NM_Client )
			return;
		if (Level.Game.bGameEnded)
			return;
		if( Level.Game.RestartPlayer(self) )
		{
			ServerTimeStamp = 0;
			TimeMargin = 0;
			Enemy = None;
			Level.Game.StartPlayer(self);
			ClientReStart();
		}
		else
			log("Restartplayer failed");
	}

	exec function Fire( optional float F )
	{
		if ( !bFrozen )
			ServerReStartPlayer();
		return;


		if ( (Level.NetMode == NM_Standalone) && !Level.Game.bDeathMatch )
		{
			if ( bFrozen )
				return;
			ShowLoadMenu();
		}
		else if ( !bFrozen || (FRand() < 0.2) )
			ServerReStartPlayer();
	}
	
	exec function AltFire( optional float F )
	{
		Fire(F);
	}
	exec function Use()
	{
		Fire(0);
	}

	function PlayChatting()
	{
	}

	exec function Taunt()
	{
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
		Global.ServerMove(
					TimeStamp,
					Accel, 
					ClientLoc,
					false,
					false,
					false, 
					false,
					false,
					false,
					false,
					DodgeMove, 
					ClientRoll, 
					View);
	}

/*
	function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
	{
		local vector View,HitLocation,HitNormal, FirstHit, spot;
		local float DesiredDist, ViewDist, WallOutDist;
		local actor HitActor;
		local Pawn PTarget;

		if ( ViewTarget != None )
		{
			ViewActor = ViewTarget;
			CameraLocation = ViewTarget.Location;
			CameraRotation = ViewTarget.Rotation;
			PTarget = Pawn(ViewTarget);
			if ( PTarget != None )
			{
				if ( Level.NetMode == NM_Client )
				{
					if ( PTarget.bIsPlayer )
						PTarget.ViewRotation = TargetViewRotation;
					PTarget.EyeHeight = TargetEyeHeight;
				}
				if ( PTarget.bIsPlayer )
					CameraRotation = PTarget.ViewRotation;
				CameraLocation.Z += PTarget.EyeHeight;
			}

			if ( Carcass(ViewTarget) != None )
			{
				if ( bBehindView || (ViewTarget.Physics == PHYS_None) )
					CameraRotation = ViewRotation;
				else 
					ViewRotation = CameraRotation;
				if ( bBehindView )
					CalcBehindView(CameraLocation, CameraRotation, 190);
			}
			else if ( bBehindView )
				CalcBehindView(CameraLocation, CameraRotation, 180);

			return;
		}

		// View rotation.
		CameraRotation = ViewRotation;
		DesiredFOV = DefaultFOV;		
		ViewActor = self;
		if( bBehindView ) //up and behind (for death scene)
			CalcBehindView(CameraLocation, CameraRotation, 180);
		else
		{
			// First-person view.
			CameraLocation = Location;
			CameraLocation.Z += Default.BaseEyeHeight;
		}
	}
*/

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		if ( !bFrozen )
		{
			if ( bPressedJump )
			{
				Fire(0);
				bPressedJump = false;
			}
			GetAxes(ViewRotation,X,Y,Z);
			// Update view rotation.
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		}
		else
		{
			GetAxes(ViewRotation,X,Y,Z);
			// Update view rotation.
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		}
//		ViewShake(DeltaTime); // RUNE:  ViewShake is handled in the Camera code
		ViewFlash(DeltaTime);
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;
		
		//fixme - try to pick view with killer visible
		//fixme - also try varying starting pitch
		////log("Find good death scene view");
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;
		
		for (tries=0; tries<16; tries++)
		{
			cameraLoc = Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;	
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}
			
		ViewRotation.Yaw = startYaw + besttry * 4096;
	}
	
	function bool JointDamaged(int Damage, Pawn Instigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		if (!bHidden)
			return Super.JointDamaged(Damage, Instigator, HitLoc, Momentum, DamageType, joint);
		return true;
	}

	
	function Timer()
	{
		bFrozen = false;
		bShowScores = true;
		bPressedJump = false;
		Super.Timer();
	}

	function BeginState()
	{
		BaseEyeheight = Default.BaseEyeHeight;
		EyeHeight = BaseEyeHeight;
		bBehindView = true;
		bFrozen = true;
		bPressedJump = false;
		bJustFired = false;
		bJustAltFired = false;
		LookTarget=None;
		LookSpot=vect(0,0,0);
//		FindGoodView();
		if ( (Role == ROLE_Authority) && !bHidden )
		{
			ReplaceWithCarcass();
		}
		SetTimer(1.0, false);

		// clean out saved moves
		while ( SavedMoves != None )
		{
			SavedMoves.Destroy();
			SavedMoves = SavedMoves.NextMove;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}
	}
	
	function EndState()
	{
		// clean out saved moves
		while ( SavedMoves != None )
		{
			SavedMoves.Destroy();
			SavedMoves = SavedMoves.NextMove;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		bShowScores = false;
		bJustFired = false;
		bJustAltFired = false;
		bPressedJump = false;
		if ( Carcass(ViewTarget) != None )
			ViewTarget = None;
		//Log(self$" exiting dying with remote role "$RemoteRole$" and role "$Role);
	}
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, JointDamaged, PainTimer, Died, Suicide;

	exec function Taunt()
	{
		if ( Health > 0 )
			Global.Taunt();
	}

	exec function ViewClass( class<actor> aClass, optional bool bQuiet )
	{
	}
	exec function ViewPlayer( string S )
	{
	}
	exec function Fire( optional float F )
	{
		if ( Role < ROLE_Authority)
			return;
		if ( !bFrozen )
			ServerReStartGame();
		else if ( TimerRate <= 0 )
			SetTimer(1.5, false);
	}
	
	exec function AltFire( optional float F )
	{
		Fire(F);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		
		GetAxes(ViewRotation,X,Y,Z);
		// Update view rotation.

		if ( !bFixedCamera )
		{
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
		}
		else if ( ViewTarget != None )
			ViewRotation = ViewTarget.Rotation;

//		ViewShake(DeltaTime); // RUNE:  ViewShake is handled in the Camera code
		ViewFlash(DeltaTime);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		bPressedJump = false;
	}

	function ServerMove
	(
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
		optional int OldAccel
	)
	{
		Global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,
							bFired, bAltFired, bForceFire, bForceAltFire, DodgeMove, ClientRoll, (32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2)) );

	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;
		
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;
		
		for (tries=0; tries<16; tries++)
		{
			if ( ViewTarget != None )
				cameraLoc = ViewTarget.Location;
			else
				cameraLoc = Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;	
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}
			
		ViewRotation.Yaw = startYaw + besttry * 4096;
	}
	
	function Timer()
	{
		bFrozen = false;
	}
	
	function BeginState()
	{
		EndZoom();
		AnimRate = 0.0;
		SimAnim.Y = 0;
		if (AnimProxy!=None)
		{
			AnimProxy.AnimRate = 0;
			AnimProxy.SimAnim.Y = 0;
		}
		bFire = 0;
		bAltFire = 0;
		SetCollision(false,false,false);
		bShowScores = true;
		bFrozen = true;
		if ( !bFixedCamera )
		{
			FindGoodView();
			bBehindView = true;
		}
		SetTimer(1.5, false);
		SetPhysics(PHYS_None);
	}

	function Done()
	{
		// Handle LOD issues
		LODCurve = LOD_CURVE_AGGRESSIVE;
		LODPercentMax = 0.4; // Reduce the max polycount allowed on dead bodies

		bCollideWorld = false;
	}

Death:
	SetPhysics(PHYS_Falling);

	WaitForLanding();
	FinishAnim();
	SetPhysics(PHYS_None);

	Done();
	Goto('PostDeath');
}

// ngStats Accessors
function string GetNGSecret()
{
	return ngWorldSecret;
}

function SetNGSecret(string newSecret)
{
	ngWorldSecret = newSecret;
}

simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);

	Canvas.DrawText("PlayerPawn:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  bReadyToPlay: " $ bReadyToPlay);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bShowScores:  " $ bShowScores);
	Canvas.CurY -= 8;
	Canvas.DrawText("  Strength:     " $ Strength$"/"$MaxStrength);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bBloodlust    " $ bBloodlust);
	Canvas.CurY -= 8;
	Canvas.DrawText("  AtrophyTimer  " $ AtrophyTimer);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bClientSideAlpha: " $ bClientSideAlpha);
	Canvas.CurY -= 8;
	Canvas.DrawText("  ClientSideAlphaScale: " $ ClientSideAlphaScale);
	Canvas.CurY -= 8;
	Canvas.DrawText("  HudType: " $ HudType);
	Canvas.CurY -= 8;
	Canvas.DrawText("  myHud: " $ myHud);
	Canvas.CurY -= 8;
}

defaultproperties
{
     DodgeClickTime=0.250000
     Bob=0.016000
     FlashScale=(X=1.000000,Y=1.000000,Z=1.000000)
     DesiredFOV=125.000000
     DefaultFOV=125.000000
     HudTranslucency=0.800000
     CdTrack=255
     MyAutoAim=1.000000
     PolyColorAdjust=(X=255.000000,Y=255.000000,Z=255.000000)
     DesiredPolyColorAdjust=(X=255.000000,Y=255.000000,Z=255.000000)
     bAlwaysMouseLook=True
     bKeyboardLook=True
     MouseSensitivity=1.000000
     MouseSmoothThreshold=0.160000
     MaxTimeMargin=3.000000
     QuickSaveString="Quick Saving"
     NoPauseMessage="Game is not pauseable"
     ViewingFrom="Now viewing from "
     OwnCamera="own camera"
     FailedView="Failed to change view."
     bIsPlayer=True
     bCanJump=True
     bViewTarget=True
     DesiredSpeed=0.300000
     SightRadius=4100.000000
     LookDegPerSec=0.000000
     bStasis=False
     bTravel=True
     RotationRate=(Pitch=0,Yaw=0,Roll=0)
     NetPriority=3.000000
}
