class R_RunePlayer extends RunePlayer config(RMod);

var class<R_AUtilities> UtilitiesClass;

var class<RunePlayer> RunePlayerSubClass;
var class<RunePlayerProxy> RunePlayerProxyClass;
var class<Actor> RunePlayerSeveredHeadClass;
var class<Actor> RunePlayerSeveredLimbClass;
var byte PolyGroupBodyParts[16];

// Move Buffering.
var RMove SavedMoves;
var RMove FreeMoves;
var RMove PendingMove;

var transient float AccumulatedHTurn, AccumulatedVTurn; // Discarded fractional parts of horizontal (Yaw) and vertical (Pitch) turns
var float LastMessageWindow;
const SmoothAdjustLocationTime = 0.35f;
const MinPosError = 10;
const MaxPosError = 1000;
var transient vector PreAdjustLocation;
var transient vector AdjustLocationOffset;
var transient float AdjustLocationAlpha;
var bool OnMover, FakeUpdate, ForceUpdate;
var float LastClientErr, IgnoreUpdateUntil, ForceUpdateUntil, LastStuffUpdate;
var transient float LastClientTimestamp;

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

	unreliable if (RemoteRole == ROLE_AutonomousProxy)
		FakeCAP;

	reliable if(Role == ROLE_Authority && RemoteRole == ROLE_AutonomousProxy)
		ClientReceiveUpdatedGamePassword;

	reliable if(Role < ROLE_Authority)
		ServerResetLevel,
		ServerSwitchGame,
		ServerSpectate,
		ServerTimeLimit,
		ServerCauseEvent,
		ServerMove_v2;
		
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
		PlayerReplicationInfoClass = R_GameInfo(Level.Game).PlayerReplicationInfoClass;	

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

	// Extract the menu name so this looks correct in server browser
	ApplySubClass_ExtractMenuName(SubClass);
}

function ApplySubClass_ExtractDefaults(class<RunePlayer> SubClass)
{
	local int i;

	Self.CarcassType = SubClass.Default.CarcassType;
	Self.WeaponPickupSound          = SubClass.Default.WeaponPickupSound;
    Self.WeaponThrowSound           = SubClass.Default.WeaponThrowSound;
    Self.WeaponDropSound            = SubClass.Default.WeaponDropSound;
    for(i = 0; i < 3; ++i)
        Self.JumpGruntSound[i]      = SubClass.Default.JumpGruntSound[i];
    Self.JumpSound                  = SubClass.Default.JumpSound;
    Self.LandGrunt                  = SubClass.Default.LandGrunt;
	Self.LandSoundWood = SubClass.Default.LandSoundWood;
	Self.LandSoundMetal = SubClass.Default.LandSoundMetal;
	Self.LandSoundStone = SubClass.Default.LandSoundStone;
	Self.LandSoundFlesh = SubClass.Default.LandSoundFlesh;
	Self.LandSoundIce = SubClass.Default.LandSoundIce;
	Self.LandSoundSnow = SubClass.Default.LandSoundSnow;
	Self.LandSoundEarth = SubClass.Default.LandSoundEarth;
	Self.LandSoundWater = SubClass.Default.LandSoundWater;
	Self.LandSoundMud = SubClass.Default.LandSoundMud;
	Self.LandSoundLava = SubClass.Default.LandSoundLava;
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
	for (i = 0; i < 3; i++)
		Self.UnderWaterHitSound[i] = SubClass.Default.UnderWaterHitSound[i];
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
	Self.Die4 = SubClass.Default.Die4;
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

function ApplySubClass_ExtractMenuName(class<RunePlayer> SubClass)
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

function ClientAdjustPosition(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	float NewVelX,
	float NewVelY,
	float NewVelZ,
	Actor NewBase)
{
	local vector OldLoc, NewLocation, NewVelocity;
	local RMove CurrentMove;

	if (CurrentTimeStamp > TimeStamp)
		return;

	CurrentTimeStamp = TimeStamp;

	NewLocation.X = NewLocX;
	NewLocation.Y = NewLocY;
	NewLocation.Z = NewLocZ;
	NewVelocity.X = NewVelX;
	NewVelocity.Y = NewVelY;
	NewVelocity.Z = NewVelZ;

	// Higor: keep track of Position prior to adjustment
	// and stop current smoothed adjustment (if in progress).
	PreAdjustLocation = Location;
	if (AdjustLocationAlpha > 0)
	{
		AdjustLocationAlpha = 0;
		AdjustLocationOffset = vect(0, 0, 0);
	}

	// stijn: Remove acknowledged moves from the savedmoves list
	CurrentMove = SavedMoves;
	while (CurrentMove != None)
	{
		if (CurrentMove.TimeStamp <= CurrentTimeStamp)
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
			// not yet acknowledged. break out of the loop
			CurrentMove = None;
		}
	}

	SetBase(NewBase);
	if (Mover(NewBase) != None)
		NewLocation += NewBase.Location;

	//log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" location "$Location);
	OldLoc = Location;
	bCanTeleport = false;
	SetLocation(NewLocation);
	bCanTeleport = true;
	Velocity = NewVelocity;

	SetPhysics(newPhysics);
	if (!IsInState(newState))
	{
		//log("CAP: GotoState("$newState$")");
		GotoState(newState);
	}

	bUpdatePosition = true;
}

function ReplicateMove(
	float DeltaTime,
	vector NewAccel,
	eDodgeDir DodgeMove,
	rotator DeltaRot)
{
	local RMove NewMove, OldMove, LastMove;
	local float TotalTime, NetMoveDelta;

	local float AdjustAlpha;

	// Higor: process smooth adjustment.
	if (AdjustLocationAlpha > 0)
	{
		AdjustAlpha = fMin(AdjustLocationAlpha, DeltaTime / SmoothAdjustLocationTime);
		MoveSmooth(AdjustLocationOffset * AdjustAlpha);
		AdjustLocationAlpha -= AdjustAlpha;
	}

	Hack108();

	NetMoveDelta = FMax(64.0 / Player.CurrentNetSpeed, 0.011);

	// if am network client and am carrying flag -
	//	make its position look good client side
	if ((PlayerReplicationInfo != None) && (PlayerReplicationInfo.HasFlag != None))
		PlayerReplicationInfo.HasFlag.FollowHolder(self);

	// Get a SavedMove actor to store the movement in.
	if (PendingMove != None)
	{
		if (PendingMove.CanMergeAccel(NewAccel))
		{
			//add this move to the pending move
			PendingMove.TimeStamp = Level.TimeSeconds;
			if (VSize(NewAccel) > 3072)
				NewAccel = 3072 * Normal(NewAccel);
			TotalTime = DeltaTime + PendingMove.Delta;
			// Set this move's data.
			if (PendingMove.DodgeMove == DODGE_None)
				PendingMove.DodgeMove = DodgeMove;
			PendingMove.Acceleration = (DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration) / TotalTime;
			PendingMove.SetRotation(Rotation);
			PendingMove.SavedViewRotation = ViewRotation;
			PendingMove.bRun = (bRun > 0);
			PendingMove.bDuck = (bDuck > 0);
			PendingMove.bPressedJump = bPressedJump || PendingMove.bPressedJump;
			PendingMove.bFire = PendingMove.bFire || bJustFired || (bFire != 0);
			PendingMove.bForceFire = PendingMove.bForceFire || bJustFired;
			PendingMove.bAltFire = PendingMove.bAltFire || bJustAltFired || (bAltFire != 0);
			PendingMove.bForceAltFire = PendingMove.bForceAltFire || bJustFired;
			PendingMove.Delta = TotalTime;
			PendingMove.MergeCount++;
		}
		else
		{
			// Burst old move and remove from Pending
			// Log("Bursting move"@Level.TimeSeconds);
			SendServerMove(PendingMove);
			ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
			if (SavedMoves == None)
				SavedMoves = PendingMove;
			else
			{
				for (LastMove = SavedMoves; LastMove.NextMove != None; LastMove = LastMove.NextMove);
				LastMove.NextMove = PendingMove;
			}
			PendingMove = None;
		}
	}
	if (SavedMoves != None)
	{
		NewMove = SavedMoves;
		while (NewMove.NextMove != None)
		{
			// find most recent interesting (and unacknowledged) move to send redundantly
			if (NewMove.CanSendRedundantly(NewAccel))
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if (NewMove.CanSendRedundantly(NewAccel))
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = NGetFreeMove();
	NewMove.Delta = DeltaTime;
	if (VSize(NewAccel) > 3072)
		NewAccel = 3072 * Normal(NewAccel);
	NewMove.Acceleration = NewAccel;
	NewAccel = Acceleration;

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

	// Simulate the movement locally.
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DodgeMove, DeltaRot);
	AutonomousPhysics(NewMove.Delta);

	// Decide whether to hold off on move
	// send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	if (PendingMove == None)
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}

	NewMove.SetRotation(Rotation);
	NewMove.SavedViewRotation = ViewRotation;
	NewMove.SavedLocation = Location;
	NewMove.SavedVelocity = Velocity;

	if (PendingMove.CanBuffer(NewAccel) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime))
	{
	    // save as pending move
	    return;
	}
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
		if (SavedMoves == None)
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	if (NewMove.bPressedJump)
		bJumpStatus = !bJumpStatus;

	SendServerMove(NewMove, OldMove);
}

function ServerMove_v2(
	float TimeStamp,
	vector InAccel,
	vector ClientLoc,
	vector ClientVel,
	byte MoveFlags,
	EDodgeDir DodgeMove,
	byte ClientRoll,
	int View,
	int MergeCount,
	optional byte OldTimeDelta,
	optional int OldAccel)
{
	local float DeltaTime;
	local rotator DeltaRot, Rot;
	local vector Accel;
	local int maxPitch, ViewPitch, ViewYaw;
	local bool NewbPressedJump;
	local bool NewbRun, NewbDuck, NewbJumpStatus, bFired, bAltFired, bForceFire, bForceAltFire;

	// If this move is outdated, discard it.
	if (CurrentTimeStamp >= TimeStamp)
		return;

	if(MergeCount > 31)
		return;
	
	// Update bReadyToPlay for clients
	if (PlayerReplicationInfo != None)
		PlayerReplicationInfo.bReadyToPlay = bReadyToPlay;

	// Decompress move flags.
	NewbRun = (MoveFlags & 1) != 0;
	NewbDuck = (MoveFlags & 2) != 0;
	bFired = (MoveFlags & 4) != 0;
	bAltFired = (MoveFlags & 8) != 0;
	bForceFire = (MoveFlags & 16) != 0;
	bForceAltFire = (MoveFlags & 32) != 0;
	NewbJumpStatus = (MoveFlags & 128) != 0;

	// if OldTimeDelta corresponds to a lost packet, process it first
	if (OldTimeDelta != 0)
		OldServerMove(TimeStamp, NewbJumpStatus, OldTimeDelta, OldAccel);

	// View components
	ViewPitch = View / 32768;
	ViewYaw = 2 * (View - 32768 * ViewPitch);
	ViewPitch *= 2;

	// Make acceleration.
	Accel = InAccel / 10;
	NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	bJumpStatus = NewbJumpStatus;
	// handle firing and alt-firing
	if (bFired)
	{
		if ((bForceFire && (Weapon != None)) || bFire == 0)
			Fire(0);

		bFire = 1;
	}
	else
		bFire = 0;

	if (bAltFired)
	{
		if (bAltFire == 0 || (bForceAltFire && (Weapon != None)))
			AltFire(0);

		bAltFire = 1;
	}
	else
		bAltFire = 0;
	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if (ServerTimeStamp > 0)
	{
		// allow 1% error
		TimeMargin = FMax(0, TimeMargin + DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp));
		if (TimeMargin > MaxTimeMargin)
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if (TimeMargin < 0.5)
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
	if ((Physics == PHYS_Swimming) || (Physics == PHYS_Flying))
		maxPitch = 2;
	else
		maxPitch = 1;
	If((ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch))
	{
		If(ViewPitch < 32768)
			Rot.Pitch = maxPitch * RotationRate.Pitch;
		else Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	else 
		Rot.Pitch = ViewPitch;
	DeltaRot = (Rotation - Rot);
	ViewRotation.Pitch = ViewPitch;
	ViewRotation.Yaw = ViewYaw;
	ViewRotation.Roll = 0;
	SetRotation(Rot);

	// Perform actual movement, reproduced step by step as on client (approximate)
	if ((Level.Pauser == "") && (DeltaTime > 0))
	{
		DeltaTime /= MergeCount + 1;
		while ( MergeCount > 0 )
		{
			MoveAutonomous( DeltaTime, NewbRun, NewbDuck, false, DODGE_None, Accel, rot(0,0,0) );
			MergeCount--;
		}
		// Important input is usually the cause for buffer breakup, so it happens last on the client.
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DodgeMove, Accel, DeltaRot);
	}

 	LastClientTimeStamp = TimeStamp;
	CheckClientError(TimeStamp, ClientLoc, ClientVel);
}

function CheckClientError(float TimeStamp, vector ClientLoc, vector ClientVel)
{
	local float ClientErr;
	local vector ClientLocation, LocDiff;
	local bool bTooLong, bOnMover, bMoveSmooth;
	local Pawn P;

	if (TimeStamp == 0 )
		return;

	LocDiff = Location - ClientLoc;
	ClientErr = LocDiff Dot LocDiff;

	if (Player.CurrentNetSpeed == 0)
		bTooLong = ServerTimeStamp - LastUpdateTime > 0.025;
	else
		bTooLong = ServerTimeStamp - LastUpdateTime > 500.0/Player.CurrentNetSpeed;
	
	if (!bTooLong)
		bTooLong = ClientErr > MinPosError;
	
	if (!bTooLong)
		return;		

	// PlayerReplicationInfo.Ping = int(ConsoleCommand("GETPING"));
	bOnMover = Mover(Base) != None;
	if (bOnMover && OnMover)
	{
		IgnoreUpdateUntil = ServerTimeStamp + 0.15;
	}
	else if (IgnoreUpdateUntil > 0)
	{
		if (IgnoreUpdateUntil > ServerTimeStamp && (Base == None ||  !bOnMover || bOnMover != OnMover) && Physics != PHYS_Falling)
			IgnoreUpdateUntil = 0;

		ForceUpdate = false;
	}

	LastUpdateTime = ServerTimeStamp;

	if (ForceUpdateUntil > 0 || IgnoreUpdateUntil == 0 && ClientErr > MaxPosError)
	{
		ForceUpdate = true;
		if (ServerTimeStamp > ForceUpdateUntil)
			ForceUpdateUntil = 0;
	}

	if(ForceUpdate)
	{
		ForceUpdate = false;		

		if (bOnMover)
			ClientLocation = Location - Base.Location;
		else
			ClientLocation = Location;

		// Make sure Z is rounded up.
		if (Base != None && Base != Level)
			ClientLocation.Z += float(int(Base.Location.Z + 0.9)) - Base.Location.Z;

		ClientAdjustPosition(
			TimeStamp,
			GetStateName(),
			Physics,
			ClientLocation.X,
			ClientLocation.Y,
			ClientLocation.Z,
			Velocity.X,
			Velocity.Y,
			Velocity.Z,
			Base);

		LastClientErr = 0;		
		FakeUpdate = false;
		Hack108();
		return;
	}

	if (ClientErr > MinPosError)
	{
		if (LastClientErr == 0 || ClientErr < LastClientErr)	
		{	
			LastClientErr = ClientErr;
		}
		else if(!bOnMover)
		{
			bMoveSmooth = FastTrace(ClientLoc);
			if (!bMoveSmooth)
			{
				for (P = Level.PawnList; P != None; P = P.NextPawn)
				{
					if (P.bCollideActors && P.bCollideWorld && P.bBlockActors && P != Self && VSize(P.Location - ClientLoc) < ((P.CollisionRadius + CollisionRadius) * CollisionHeight))
					{
						bMoveSmooth = true;
						break;
					}
				}
			}
			
			if (bMoveSmooth)
			{
				if( MoveSmooth(ClientLoc - Location))
					Velocity = ClientVel;
				LastClientErr = 0;
			}
			else
			{				
				bCanTeleport = false;
				if (SetLocation(ClientLoc))
					Velocity = ClientVel;
				bCanTeleport = true;

				LastClientErr = 0;
			}
		}
	}

	FakeCAP(TimeStamp);
}

function FakeCAP(float TimeStamp)
{
	if (CurrentTimeStamp > TimeStamp )
		return;
	CurrentTimeStamp = TimeStamp;

	FakeUpdate = true;
	bUpdatePosition = true;
}

function Hack108()
{
	// 108  this is a hack to fix the incorrect replication rules in Actor
	if (AmbientGlow != 0)
		AmbientGlow = 0;
	if (ScaleGlow != 1.0)
		ScaleGlow = 1.0;
	if (bUnlit)
		bUnlit = false;
	if (bMeshEnviroMap)
		bMeshEnviroMap = false;
	if (PrePivot != vect(0, 0, 0))
		PrePivot = vect(0, 0, 0);
}

function SendServerMove(RMove Move, optional RMove OldMove)
{
	local byte ClientRoll;
	local float OldTimeDelta;
	local int OldAccel;
	local byte MoveFlags;
	local int View;
	local EDodgeDir DodgeMove;
	ClientRoll = (Rotation.Roll >> 8) & 255;
	View = (32767 & (Move.SavedViewRotation.Pitch/2)) * 32768 + (32767 & (Move.SavedViewRotation.Yaw/2));

	// check if need to redundantly send previous move
	if (OldMove != None)
	{
		// log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
		// old move important to replicate redundantly
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		OldAccel = OldMove.CompressOld();
	}

	// There's no need to send DODGE_Active, Dodge() sets it.
	DodgeMove = Move.DodgeMove;
	if (DodgeMove == DODGE_Active)
		DodgeMove = DODGE_None;

	MoveFlags = Move.CompressFlags();
	MoveFlags += int(bJumpStatus) * 128;
	ServerMove_v2(
		Move.TimeStamp,
		Move.Acceleration * 10,
		Location,
		Velocity,
		MoveFlags,
		DodgeMove,
		ClientRoll,
		View,
		Move.MergeCount,
		OldTimeDelta,
		OldAccel);
}

function RMove NGetFreeMove()
{
	local RMove s;
	if (FreeMoves == None)
		return Spawn(class 'RMove', self);
	else
	{
		s = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		if (s.Owner != self)
			s.SetOwner(self);
		return s;
	}
}

final function float DecompressAccel(int C)
{
	if (C > 127)
		C = -1 * (C - 128);
	return C;
}

final function OldServerMove(float TimeStamp, bool NewbJumpStatus, byte OldTimeDelta, int OldAccel)
{
	local float OldTimeStamp;
	local bool OldbRun, OldbDuck, NewbPressedJump;
	local vector Accel;
	local EDodgeDir OldDodgeMove;

	OldTimeStamp = TimeStamp - float(OldTimeDelta) / 500 - 0.001;
	if (CurrentTimeStamp < OldTimeStamp - 0.001)
	{
		// split out components of lost move (approx)
		Accel.X = DecompressAccel(OldAccel >>> 23);
		Accel.Y = DecompressAccel((OldAccel >>> 15) & 255);
		Accel.Z = DecompressAccel((OldAccel >>> 7) & 255);
		Accel *= 20;
		OldbRun = ((OldAccel & 64) != 0);
		OldbDuck = ((OldAccel & 32) != 0);
		NewbPressedJump = ((OldAccel & 16) != 0);
		if (NewbPressedJump)
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
		//		log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
		MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, OldbDuck, NewbPressedJump, OldDodgeMove, Accel, rot(0, 0, 0));
		CurrentTimeStamp = OldTimeStamp;
	}
}

function int AccumulatedPlayerTurn(float CurrentTurn, out float AccumulatedTurn)
{
	local int IntTurn;

	CurrentTurn += AccumulatedTurn;
	IntTurn = CurrentTurn;
	AccumulatedTurn = CurrentTurn - IntTurn;
	return IntTurn;
}

event bool EncroachingOn(actor Other)
{
	if ((Other.Brush != None) || (Brush(Other) != None))
		return true;

	if (!bCanTeleport && (Pawn(Other) != None) && (Level.NetMode == NM_Client))
		return false; // Allow relocating inside pawns during ClientAdjustPosition

	if ((!bIsPlayer || bWarping) && (Pawn(Other) != None))
		return true;

	return false;
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator newRotation;

	DesiredRotation = ViewRotation; //save old rotation
	ViewRotation.Pitch += AccumulatedPlayerTurn(32.0 * DeltaTime * aLookUp, AccumulatedVTurn);
	ViewRotation.Pitch = ViewRotation.Pitch & 65535;
	If((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
	{
		If(aLookUp > 0)
			ViewRotation.Pitch = 18000;
		else ViewRotation.Pitch = 49152;
	}
	ViewRotation.Yaw += AccumulatedPlayerTurn(32.0 * DeltaTime * aTurn, AccumulatedHTurn);
	//	ViewShake(deltaTime); // RUNE:  ViewShake is handled in the Camera code
	ViewFlash(deltaTime);

	newRotation = Rotation;
	newRotation.Yaw = ViewRotation.Yaw;
	newRotation.Pitch = ViewRotation.Pitch;
	If((newRotation.Pitch > maxPitch * RotationRate.Pitch) && (newRotation.Pitch < 65536 - maxPitch * RotationRate.Pitch))
	{
		If(ViewRotation.Pitch < 32768)
			newRotation.Pitch = maxPitch * RotationRate.Pitch;
		else newRotation.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	setRotation(newRotation);
}

function ClientUpdatePosition()
{
	local RMove CurrentMove;
	local int realbRun, realbDuck;
	local bool bRealJump;
	local rotator RealViewRotation, RealRotation;

	local float AdjustDistance;
	local vector PostAdjustLocation;

	bUpdatePosition = false;
	realbRun = bRun;
	realbDuck = bDuck;
	bRealJump = bPressedJump;
	RealRotation = Rotation;
	RealViewRotation = ViewRotation;
	CurrentMove = SavedMoves;
	bUpdating = true;

	while (CurrentMove != None)
	{
		if (CurrentMove.TimeStamp <= CurrentTimeStamp)
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
			if(!FakeUpdate)			
				ClientReplayMove(CurrentMove);			

			CurrentMove = CurrentMove.NextMove;
		}
	}

	// stijn: The original code was not replaying the pending move
	// here. This was a huge oversight and caused non-stop resynchronizations
	// because the playerpawn position would be off constantly until the player
	// stopped moving!
	if(!FakeUpdate)
	{
		if (PendingMove != none)
			ClientReplayMove(PendingMove);

		// Higor: evaluate location adjustment and see if we should either
		// - Discard it
		// - Negate and process over a certain amount of time.
		// - Keep adjustment as is (instant relocation)
		AdjustLocationOffset = (Location - PreAdjustLocation);
		AdjustDistance = VSize(AdjustLocationOffset);
		AdjustLocationAlpha = 0;
		if (AdjustDistance < VSize(Acceleration)) //Only do this if player is trying to move
		{
			if (AdjustDistance < 2)
			{
				// Discard
				MoveSmooth(-AdjustLocationOffset);
			}
			else if ((AdjustDistance < 50) && FastTrace(Location, PreAdjustLocation))
			{
				// Undo adjustment and re-enact smoothly
				PostAdjustLocation = Location;
				MoveSmooth(-AdjustLocationOffset);
				AdjustLocationOffset = PostAdjustLocation - Location;
				AdjustLocationAlpha = 1;
			}
		}
	}

	bUpdating = false;
	bDuck = realbDuck;
	bRun = realbRun;
	bPressedJump = bRealJump;
	SetRotation(RealRotation);
	ViewRotation = RealViewRotation;
	FakeUpdate = false;
	//log("Client adjusted "$self$" stamp "$CurrentTimeStamp$" location "$Location$" dodge "$DodgeDir);
}

function ClientReplayMove(RMove Move)
{
	local int i;
	local float DeltaTime;

	SetRotation(Move.Rotation);
	ViewRotation = Move.SavedViewRotation;
	// Replay the move in the same amount of ticks they were created+merged.
	// Important input needs to be processed last (as it's usually the cause of buffer breakup)
	DeltaTime = Move.Delta;
	DeltaTime /= Move.MergeCount + 1;
	for ( i=0; i<Move.MergeCount; i++)
		MoveAutonomous( DeltaTime, Move.bRun, Move.bDuck, false, DODGE_None, Move.Acceleration, rot(0,0,0));

	MoveAutonomous(DeltaTime, Move.bRun, Move.bDuck, Move.bPressedJump, Move.DodgeMove, Move.Acceleration, rot(0, 0, 0));
	Move.SavedLocation = Location;
	Move.SavedVelocity = Velocity;
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
		RPSubClass = class'RMod.R_RunePlayer';
	
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

function PlayerTickEvents()
{
	if (Player.CurrentNetSpeed != 0 && Level.TimeSeconds - LastStuffUpdate > 500.0/Player.CurrentNetSpeed)	
		LastStuffUpdate = CurrentTime;	
}

event PlayerTick( float Time )
{
	PlayerTickEvents();
}


state PlayerWalking
{
	event PlayerTick(float DeltaTime)
	{
		local float ZDist;

		PlayerTickEvents();

		if (bUpdatePosition)
			ClientUpdatePosition();

		//
		// stijn: if the server corrected our position in the middle of
		// a dodge, we might end up in DODGE_Active state with our
		// Physics set to PHYS_Walking. If this happened before 469,
		// the player would not be able to dodge again until triggering
		// a landed event (which usually meant you had to jump).
		// Here, we just wait for the dodge animation to play out and
		// then manually force a dodgedir reset.
		//
		if (DodgeDir == DODGE_Active &&
			Physics != PHYS_Falling &&
			GetAnimGroup(AnimSequence) != 'Dodge' &&
			GetAnimGroup(AnimSequence) != 'Jumping')
		{
			DodgeDir = DODGE_None;
			DodgeClickTimer = DodgeClickTime;
		}

		PlayerMove(DeltaTime);

		// Check to player falling death scream
		if (!bPlayedFallingSound && Physics == PHYS_Falling && Velocity.Z < -1300)
		{ // Play death scream
			bPlayedFallingSound = true;
			PlaySound(FallingScreamSound, SLOT_Talk, , true);
		}

		// Update ZTarget (only if in single-player)
		if (ZTarget != None && Level.Netmode == NM_Standalone)
		{
			ZDist = VSize(ZTarget.Location - Location);
			if (ZTarget.Health <= 0 || ZDist > ZTARGET_DIST)
			{
				ZTarget = None;
			}
			else
			{
				if (ZTargetDecal == None)				
					ZTargetDecal = Spawn(class 'ZTargetDecal', ZTarget, , Location, Rotation);				

				ZTargetDecal.SetOwner(ZTarget);
				ZTargetDecal.Update(None);
			}
		}
	}	

	function bool GrabEdge(float grabDistance, vector grabNormal)
	{ 
		local float colRad;
		local vector edgeLocation;
		local rotator edgeRotation;

		// Save the final distance (used for choosing the correct anim)
		GrabLocationDist = grabDistance + 8;

		// client hits this section a bunch of times when attacking or throwing while near edge
		// which causes bunch of glitching movement
		// just skip all client code and let server sync back
		// we still set GrabLocationDist so client knows which animation to use
		if(Level.NetMode == NM_Client)			
			return false;	

		// Only grab edges if in the idle state
		if(AnimProxy != None && AnimProxy.GetStateName() == 'Idle')
		{ 					
			colRad = CollisionRadius + 4;
			edgeRotation = rotator(grabNormal);

			SetRotation(edgeRotation);
			ViewRotation.Yaw = Rotation.Yaw;

			edgeLocation.X = Location.X + grabNormal.X * colRad;
			edgeLocation.Y = Location.Y + grabNormal.Y * colRad;
			edgeLocation.Z = Location.Z + GrabLocationDist + CollisionHeight;

			// Final, absolute check if the player can fit in the new location.
			// if the player fits, then it is a valid edge grab										
			if(SetLocation(edgeLocation))
			{
				// sync up client location and rotation
				ClientSetLocation(edgeLocation, edgeRotation);

				GotoState('EdgeHanging');
				return(true);			
			}
		}
		
		return(false);
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
	function BeginState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;

		Super.BeginState();
	}

	function EndState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;

		Super.EndState();
	}
}


state Dying
{
	function PlayerMove(float DeltaTime)
	{
		local vector X, Y, Z;

		if (!bFrozen)
		{
			if (bPressedJump)
			{
				Fire(0);
				bPressedJump = false;
			}
			GetAxes(ViewRotation, X, Y, Z);
			// Update view rotation.
			aLookup *= 0.24;
			aTurn *= 0.24;
			ViewRotation.Yaw += AccumulatedPlayerTurn(32.0 * DeltaTime * aTurn, AccumulatedHTurn);
			ViewRotation.Pitch += AccumulatedPlayerTurn(32.0 * DeltaTime * aLookUp, AccumulatedVTurn);
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If(aLookUp > 0)
					ViewRotation.Pitch = 18000;
				else ViewRotation.Pitch = 49152;
			}
			if (Role < ROLE_Authority) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0, 0, 0), DODGE_None, rot(0, 0, 0));
		}
		else
		{
			GetAxes(ViewRotation, X, Y, Z);
			// Update view rotation.
			aLookup *= 0.24;
			aTurn *= 0.24;
			ViewRotation.Yaw += AccumulatedPlayerTurn(32.0 * DeltaTime * aTurn, AccumulatedHTurn);
			ViewRotation.Pitch += AccumulatedPlayerTurn(32.0 * DeltaTime * aLookUp, AccumulatedVTurn);
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If(aLookUp > 0)
					ViewRotation.Pitch = 18000;
				else ViewRotation.Pitch = 49152;
			}
			if (Role < ROLE_Authority) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0, 0, 0), DODGE_None, rot(0, 0, 0));
		}
		//		ViewShake(DeltaTime); // RUNE:  ViewShake is handled in the Camera code
		ViewFlash(DeltaTime);
	}

	simulated function BeginState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;

		Super.BeginState();
	}

	function EndState()
	{
		ForceUpdate = true;
		ForceUpdateUntil = Level.TimeSeconds + 0.15;
		IgnoreUpdateUntil = 0;	

		Super.EndState();
	}
}

state PlayerWaiting
{
	exec function Fire(optional float F)
	{
		bReadyToPlay = true;
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;
	}
	
	exec function AltFire(optional float F)
	{
		bReadyToPlay = true;
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;
	}
}

state Uninterrupted
{
	function BeginState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;

		Super.BeginState();
	}

	function EndState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;	

		Super.EndState();
	}
}

state Unresponsive
{
	function BeginState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;

		Super.BeginState();
	}

	function EndState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;	

		Super.EndState();
	}
}

state Statue
{
	function BeginState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;

		Super.BeginState();
	}

	function EndState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;

		Super.EndState();
	}
}

state IceStatue
{
	function BeginState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;

		Super.BeginState();
	}

	function EndState()
	{
		ForceUpdate = true;
		IgnoreUpdateUntil = 0;

		Super.EndState();
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
