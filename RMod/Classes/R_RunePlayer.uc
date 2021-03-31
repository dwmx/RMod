class R_RunePlayer extends RunePlayer config(RMod);

var class<R_AUtilities> UtilitiesClass;

var class<RunePlayer> RunePlayerSubClass;
var class<RunePlayerProxy> RunePlayerProxyClass;
var class<Actor> RunePlayerSeveredHeadClass;
var class<Actor> RunePlayerSeveredLimbClass;
var byte PolyGroupBodyParts[16];

var class<R_ACamera> SpectatorCameraClass;
var R_ACamera Camera;

// Replicated POV view rotation
var private float ViewRotPovPitch;
var private float ViewRotPovYaw;

var private bool bForceClientAdjustPosition;

// PainSkin arrays
const MAX_SKEL_GROUP_SKINS = 16;
struct FSkelGroupSkinArray
{
	var Texture Textures[16];
};
// Indexed by BODYPART consts
var FSkelGroupSkinArray PainSkinArrays[16];
var FSkelGroupSkinArray GoreCapArrays[16];

replication
{	
	reliable if(Role == ROLE_Authority && bNetInitial)
		RunePlayerSubClass;
	
	reliable if(Role == ROLE_Authority)
		Camera;

	reliable if(Role == ROLE_Authority && RemoteRole == ROLE_AutonomousProxy)
		ClientReceiveUpdatedGamePassword,
		ClientReceiveSessionKey;

	reliable if(Role < ROLE_Authority)
		ServerResetLevel,
		ServerSwitchGame,
		ServerSpectate,
		ServerTimeLimit,
		ServerSetGameLocked,
		ServerMakeTeam,
		ServerCauseEvent;
		
	unreliable if(Role == ROLE_Authority && RemoteRole != ROLE_AutonomousProxy)
		ViewRotPovPitch,
		ViewRotPovYaw;
}

function ServerCauseEvent(Name N)
{
	local actor A;
	local int triggerCount;

	if(!VerifyAdminWithErrorMessage())
	{
		return;
	}

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

function ClientReceiveUpdatedGamePassword(String NewGamePassword)
{
	UpdateURL("Password", NewGamePassword, false);
	ClientMessage("Local password has been updated:" @ NewGamePassword);
}

exec function CauseEvent( name N )
{
	ServerCauseEvent(N);
}

exec function LogPlayerIDs()
{
	local PlayerReplicationInfo PRI;
	
	UtilitiesClass.Static.RModLog("LogPlayerIDs output:");
	foreach AllActors(class'Engine.PlayerReplicationInfo', PRI)
	{
		UtilitiesClass.Static.RModLog(
			"ID: " $ PRI.PlayerID $ ", " $
			"Name: " $ PRI.PlayerName);
	}
}

exec function MakeTeam(int TeamID, string PlayerIDs)
{
	if(Len(PlayerIDs) > 64)
	{
		return;
	}
	ServerMakeTeam(TeamID, PlayerIDs);
}

function ServerMakeTeam(int TeamID, string PlayerIDs)
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
	
	GI.PlayerMakeTeam(self, TeamID, PlayerIDs);
}

function ReceiveSessionKey(int SessionKey)
{
	if(PlayerReplicationInfo.bIsSpectator)
	{
		return;
	}
	
	ClientReceiveSessionKey(SessionKey);
}

function ClientReceiveSessionKey(int SessionKey)
{
	UtilitiesClass.Static.RModLog("Updated session key: " $ SessionKey);
	UpdateURL("SessionKey", String(SessionKey), true);
}

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

event PreBeginPlay()
{
	Enable('Tick');

	if(R_GameInfo(Level.Game) != None)
	{
		PlayerReplicationInfoClass = R_GameInfo(Level.Game).PlayerReplicationInfoClass;
	}

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

function ApplySubClass(class<RunePlayer> SubClass)
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
}

function ApplySubClass_ExtractDefaults(class<RunePlayer> SubClass)
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

function ApplySubClass_ExtractBodyPartData(class<RunePlayer> SubClass, RunePlayer SubClassInstance)
{
	local int i;

	for(i = 0; i < 16; ++i)
	{
		PolyGroupBodyParts[i] = SubClassInstance.BodyPartForPolyGroup(i);
	}

	RunePlayerSeveredHeadClass = SubClassInstance.SeveredLimbClass(BODYPART_HEAD);
	RunePlayerSeveredLimbClass = SubClassInstance.SeveredLimbClass(BODYPART_LARM1);
}

function ApplySubClass_ExtractPainSkinData(class<RunePlayer> SubClass, RunePlayer SubClassInstance)
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

function ApplySubClass_ExtractGoreCapData(class<RunePlayer> SubClass, RunePlayer SubClassInstance)
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

static function ApplyDummyTag(Actor A)
{
	A.Tag = 'RMODDUMMY';
}

static function bool CheckForDummyTag(Actor A)
{
	if(A.Tag == 'RMODDUMMY')
	{
		return true;
	}
	return false;
}

////////////////////////////////////////////////////////////////////////////////
//	ServerMove
//	Overridden to replicate player's view pitch, so that spectators can view
//	in POV.
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

// Overridden to keep track of damage dealt through the game
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local int PreviousHealth;
	local int DamageDealt;
	local R_PlayerReplicationInfo RPRI;
	local bool bResult;

	PreviousHealth = Health;
	bResult = Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
	DamageDealt = PreviousHealth - Health;

	if(EventInstigator != None && EventInstigator.PlayerReplicationInfo != None)
	{
		RPRI = R_PlayerReplicationInfo(EventInstigator.PlayerReplicationInfo);
		if(RPRI != None)
		{
			RPRI.DamageDealt += DamageDealt;
		}
	}
}

static function SetSkinActor(actor SkinActor, int NewSkin) // override
{
	local R_RunePlayer RP;
	local class<RunePlayer> RPSubClass;
	local int i;
	
	RP = R_RunePlayer(SkinActor);
	if(RP == None)
	{
		class'RuneI.RunePlayer'.Static.SetSkinActor(SkinActor, NewSkin);
		return;
	}
	
	RPSubClass = RP.RunePlayerSubClass;
	if(RPSubClass == None)
	{
		RPSubClass = class'RMod.R_RunePlayer';
	}
	
	for(i = 0; i < 16; ++i)
	{
		RP.SkelGroupSkins[i] = RPSubClass.Default.SkelGroupSkins[i];
	}
}

// Apply pain skin which was extract from subclass
function Texture PainSkin(int BodyPart) // override
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

// Apply gore cap using extracted subclass data
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

function int BodyPartForPolyGroup(int PolyGroup) // override
{
	if(PolyGroup < 0 || PolyGroup >= 16)
	{
		return BODYPART_BODY;
	}

	return PolyGroupBodyParts[PolyGroup];
}

function class<Actor> SeveredLimbClass(int BodyPart) // override
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

simulated function Rotator GetViewRotPov()
{
	local Rotator ViewRotPov;
	
	ViewRotPov.Pitch = ViewRotPovPitch;
	ViewRotPov.Yaw = ViewRotPovYaw;
	ViewRotPov.Roll = 0;
	return ViewRotPov;
}

// Admin verification
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

// SwitchGame command
exec function SwitchGame(String S)
{
	ServerSwitchGame(S);
}

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

// ResetLevel command
exec function ResetLevel(optional int DurationSeconds)
{
	ServerResetLevel(DurationSeconds);
}

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

// TimeLimit command
exec function TimeLimit(int DurationMinutes)
{
	ServerTimeLimit(DurationMinutes);
}

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

// LockGame and UnlockGame commands
exec function LockGame()
{
	ServerSetGameLocked(true);
}

exec function UnlockGame()
{
	ServerSetGameLocked(false);
}

function ServerSetGameLocked(bool bGameLocked)
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
	
	GI.PlayerSetGameLocked(self, bGameLocked);
}

// Spectate command
exec function Spectate()
{
	ServerSpectate();
}

function ServerSpectate()
{
	local R_GameInfo GI;
	GI = R_GameInfo(Level.Game);
	if(GI != None)
	{
		GI.RequestSpectate(Self);
	}
}

state PlayerSpectating
{
	event BeginState()
    {	
        Self.SetCollision(false, false, false);
        Self.bCollideWorld = false;
        Self.DrawType = DT_None;
        Self.bAlwaysRelevant = false;
        Self.SetPhysics(PHYS_None);
		Self.PlayerReplicationInfo.bIsSpectator = true;
		
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
        Self.bAlwaysRelevant = Self.Default.bAlwaysRelevant;
		Self.PlayerReplicationInfo.bIsSpectator = false;

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

defaultproperties
{
     UtilitiesClass=Class'RMod.R_AUtilities'
     RunePlayerProxyClass=Class'RMod.R_RunePlayerProxy'
     SpectatorCameraClass=Class'RMod.R_Camera_Spectator'
     bMessageBeep=True
}
