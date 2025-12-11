class R_RunePlayer_TD extends R_RunePlayer;

const LogCategory = 'RModPlayer';
const CanvasLibrary = Class'RBase.R_ACanvasLibrary';

// The class used for drawing the in-world HUD elements
var Class<R_InWorldHUD> InWorldHUDClass;
var R_InWorldHUD InWorldHUD;

// The class used to build things in the world
var Class<R_BuilderBrush> BuilderBrushClass;
var R_BuilderBrush BuilderBrush;

// The class used to manage actor selection
var Class<R_ActorSelector> ActorSelectorClass;
var R_ActorSelector ActorSelector;

var UWindowRootWindow MyRootWindow;
var UWindowWindow MyTestWindow;
var UWindowWindow InventoryWindow;

var Vector TestDrawLoc;
var Vector TestDrawDelta;

replication
{
	// Server --> Client functions
	reliable if(Role == ROLE_Authority)
		ClientReceiveInWorldMessage;

    // Client --> Server functions
    reliable if(Role < ROLE_Authority)
        ServerTryExecuteBuild;
}

/**
*   InitializePlayerAfterPossess (override)
*   Called for both server and clients, but some initialization should
*   only occur for the controlling instance
*/
function InitializePlayerAfterPossess(bool bIsLocallyControlled)
{
    Super.InitializePlayerAfterPossess(bIsLocallyControlled);
    
    // For local player only
    if(bIsLocallyControlled)
    {
		SpawnInWorldHUD();
        //SpawnBuilderBrush();
        SpawnActorSelector();

		// Enable and initialize the game cursor
        EnableGameCursor();
		if(GameCursor != None)
		{
			GameCursor.SetDragSelectionEnabled(false);
		}
    }
}

/**
*   PlayerCalcView (override)
*   Overridden to test overhead view
*/
event PlayerCalcView(
    out Actor ViewActor,
    out vector CameraLocation,
    out rotator CameraRotation)
{
    local float CamDistance;
    local Vector OffsetVector;
    
    CamDistance = 1024.0;
    OffsetVector.X = 1.0;
    OffsetVector.Y = 1.0;
    OffsetVector.Z = 2.0;
    OffsetVector = Normal(OffsetVector) * CamDistance;
    
    CameraLocation = Location + OffsetVector;
    
    CameraRotation = Rotator(Location - CameraLocation);
    ViewActor = Self;
    
    // Cursor needs these when selecting objects in world
    SavedCameraLoc = CameraLocation;
    SavedCameraRot = CameraRotation;
}

/**
*   Tick (override)
*   Overridden to update the position of the BuilderBrush when active
*/
event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);
    
    TickBuilderBrushDesiredLocation(DeltaSeconds);
	TickPawnRotation(DeltaSeconds);

	if(MyRootWindow != None)
	{
		MyRootWindow.DoTick(DeltaSeconds);
	}
}

function TickPawnRotation(float DeltaSeconds)
{
	local Vector IntersectLocation;
	local Vector Delta;
	local Rotator NewRotation;

	if(GameCursor == None)
	{
		return;
	}

	if(!GameCursor.PlaneIntersectUnderCursor(
		Self.Location,
		Vect(0,0,1),
		IntersectLocation))
	{
		return;
	}

	Delta = Normal(IntersectLocation - Self.Location);

	NewRotation = Rotator(Delta);
	NewRotation.Pitch = 0;
	NewRotation.Roll = 9000;

	TestDrawLoc = IntersectLocation;
	TestDrawDelta = Delta;
	SetRotation(NewRotation);
	ViewRotation = NewRotation;
	//Log(NewRotation);
}

function TickBuilderBrushDesiredLocation(float DeltaSeconds)
{
    local Vector HitLocation, HitNormal;
    
    if(BuilderBrush == None)
    {
        return;
    }
    
    if(GameCursor != None)
    {
        GameCursor.TraceUnderCursor(
            10000.0,
            HitLocation,
            HitNormal);
        
        BuilderBrush.SetDesiredBrushLocation(HitLocation);
    }
}

/**
*   PostRender (override)
*   Overridden to send PostRender calls to the BuilderBrush when it's active
*/
event PostRender(Canvas C)
{
    //Super.PostRender(C);

	if(InWorldHUD != None)
	{
		InWorldHUD.InWorldHUDPostRender(C);
	}

    //if(BuilderBrush != None)
    //{
    //    BuilderBrush.BuilderBrushPostRender(C);
    //}
    
    //if(ActorSelector != None)
    //{
    //    ActorSelector.ActorSelectorPostRender(C);
    //}

	if(MyRootWindow != None)
	{
		MyRootWindow.WindowEvent(WM_Paint, C, 0.0, 0.0, 0);
		MyRootWindow.Paint(C, 0.0, 0.0);
		//MyRootWindow.PainClients(C, X, Y);
	}

	// Debug draw cursor world intersection
	/*
	CanvasLibrary.Static.DrawCircle3D(
		C,
		TestDrawLoc, Vect(0,0,1),
		32.0, 64,
		1.0, 1.0, 0.0);

	CanvasLibrary.Static.DrawRay3D(
		C,
		Self.Location, TestDrawDelta, 256.0,
		1.0, 0.0, 0.0);
		*/

	// Super draws cursor, render it on top
	Super.PostRender(C);
}

/**
*	ClientReceiveInWorldMessage
*	Received an In-World message from the owning Game Info, along with type of message
*	Should be forwarded to the InWorldHUD
*/
function ClientReceiveInWorldMessage(String MessageString, Vector Location, Name MessageType)
{
	local Color DrawColor;

	if(InWorldHUD != None)
	{
		if(MessageType == 'Gold')
		{
			DrawColor.R = 255;
			DrawColor.G = 255;
			DrawColor.B = 0;
			InWorldHUD.ReceiveInWorldMessage(MessageString, Location, DrawColor);
		}
	}
}

exec function Fire(optional float F)
{
    TryExecuteBuilderBrush();
    
    Super.Fire(F);
}

exec function PlayerMouseDown()
{
	local Vector UIEventPayload;

	if(MyRootWindow != None && GameCursor != None && GameCursor.IsEnabled())
	{
		GameCursor.GetCursorPosition(UIEventPayload.X, UIEventPayload.Y);
		MyRootWindow.WindowEvent(WM_LMouseDown, None, UIEventPayload.X, UIEventPayload.Y, 0);
		//return;
	}

	TryExecuteBuilderBrush();
	if(GameCursor != None && GameCursor.IsEnabled())
    {
        GameCursor.BeginDragSelection();
    }
}

exec function PlayerMouseUp()
{
	local Vector UIEventPayload;

	if(MyRootWindow != None && GameCursor != None && GameCursor.IsEnabled())
	{
		GameCursor.GetCursorPosition(UIEventPayload.X, UIEventPayload.Y);
		MyRootWindow.WindowEvent(WM_LMouseUp, None, UIEventPayload.X, UIEventPayload.Y, 0);
		//return;
	}

	// Otherwise pass it to game cursor
	if(GameCursor != None && GameCursor.IsEnabled())
    {
        GameCursor.EndDragSelection();
    }
}

event PlayerInput(float DeltaSeconds)
{
	local Vector UIEventPayload;
	local Vector GameCursorPosition;

	Super.PlayerInput(DeltaSeconds);

	// Pass game cursor info to root window
	if(MyRootWindow != None && GameCursor != None)
	{
		GameCursor.GetCursorPosition(GameCursorPosition.X, GameCursorPosition.Y);
		MyRootWindow.MoveMouse(GameCursorPosition.X, GameCursorPosition.Y);
	}
}

function LogUnderMouseCursor()
{
    local Vector HitLocation, HitNormal;
    local Actor HitActor;
    
    if(GameCursor != None && GameCursor.IsEnabled())
    {
        HitActor = GameCursor.TraceUnderCursor(
            10000.0,
            HitLocation,
            HitNormal,
            true);
        Log("Mouse click hit actor" @ HitActor);
    }
}

function SpawnInWorldHUD()
{
	local Class<R_InWorldHUD> LocalInWorldHUDClass;

	LocalInWorldHUDClass = InWorldHUDClass;
	if(LocalInWorldHUDClass == None)
	{
		LocalInWorldHUDClass = Class'RMod_TowerDefense.R_InWorldHUD';
	}

	if(LocalInWorldHUDClass == None)
	{
		Warn("Failed to spawn InWorldHUD, Class=" $ InWorldHUDClass);
		return;
	}

	Log("Spawning InWorldHUD from class" @ LocalInWorldHUDClass, LogCategory);
	InWorldHUD = New(None) LocalInWorldHUDClass;

	if(InWorldHUD != None)
	{
		InWorldHUD.InitializeInWorldHUD(Self);
		Log("InWorldHUD created and initialized from class" @ LocalInWorldHUDClass, LogCategory);
	}
	else
	{
		Warn("Failed to spawn InWorldHUD from class" @ LocalInWorldHUDClass);
		return;
	}
}

/**
*   SpawnBuilderBrush
*   Primary function for spawning the BuilderBrush local actor when player enters build mode
*   BuilderBrush will only be spawned on the locally controlled player (client or server)
*/
function SpawnBuilderBrush()
{
    local Class<R_BuilderBrush> LocalBuilderBrushClass;
    local Rotator SpawnRotation;

    if(BuilderBrush != None)
    {
        BuilderBrush.Destroy();
    }
    
    LocalBuilderBrushClass = BuilderBrushClass;
    if(LocalBuilderBrushClass == None)
    {
        LocalBuilderBrushClass = Class'RMod_TowerDefense.R_BuilderBrush';
    }
    
    if(LocalBuilderBrushClass != None)
    {
        SpawnRotation.Yaw = 0;
        SpawnRotation.Pitch = 0;
        SpawnRotation.Roll = 0;
        BuilderBrush = Spawn(LocalBuilderBrushClass, Self, /*SpawnTag*/, Location, SpawnRotation);
    }
    
    // Log failed spawns -- class may be configured incorrectly
    if(LocalBuilderBrushClass == None || BuilderBrush == None)
    {
        UtilitiesClass.Static.RModWarn("Failed to spawn BuilderBrush from class" @ LocalBuilderBrushClass);
    }
}

/**
*   ServerTryExecuteBuild
*   Client --> Server
*   Tells the current game info that this player wants to build the specified class at the specified location
*   Owning R_GameInfo_TD will perform the transaction, spawn the building and notify the player
*/
function ServerTryExecuteBuild(Class<R_ABuildableActor> BuildableClass, Vector BuildLocation)
{
    local R_GameInfo_TD GameInfoTD;
    
    GameInfoTD = R_GameInfo_TD(Level.Game);
    if(GameInfoTD != None)
    {
        if(BuildableClass != None)
        {
            GameInfoTD.PlayerRequestBuild(Self, BuildableClass, BuildLocation);
        }
        else
        {
            UtilitiesClass.Static.RModWarn("R_RunePlayer_TD.ServerTryExecuteBuild called with BuildableClass == None");
            return;
        }
    }
}

/**
*   TryExecuteBuilderBrush
*   Called locally
*   Verifies builder brush location and class locally, and then sends RPC to server
*/
function TryExecuteBuilderBrush()
{
    local Class<R_ABuildableActor> BuildableClass;
    
    if(BuilderBrush != None)
    {
        BuildableClass = BuilderBrush.GetBuildableActorClass();
        if(BuildableClass != None)
        {
            ServerTryExecuteBuild(BuildableClass, BuilderBrush.Location);
			BuilderBrush.SetBuildableActorClass(None);
        }
    }
}

function SpawnActorSelector()
{
    local Class<R_ActorSelector> LocalActorSelectorClass;
    
    // If there's already an ActorSelector, notify it that it's being released
    if(ActorSelector != None)
    {
        ActorSelector.NotifyReleasedByOwningPlayer();
        ActorSelector = None;
    }
    
    LocalActorSelectorClass = ActorSelectorClass;
    if(LocalActorSelectorClass == None)
    {
        LocalActorSelectorClass = Class'RMod_TowerDefense.R_ActorSelector';
        UtilitiesClass.Static.RModLog(
            "ActorSelectorClass not configured, defaulting to" @ LocalActorSelectorClass);
    }
    
    if(LocalActorSelectorClass != None)
    {
        ActorSelector = New(None) LocalActorSelectorClass;
    }
    
    if(ActorSelector == None)
    {
        UtilitiesClass.Static.RModWarn("Failed to create ActorSelector from class" @ LocalActorSelectorClass);
    }
    else
    {
        ActorSelector.InitializeActorSelector(Self);
        UtilitiesClass.Static.RModLog(
            "ActorSelector created and initialized from class" @ LocalActorSelectorClass);
    }
}

//==============================================================================
// Test exec functions
exec function TestExecuteBuilderBrush()
{
    UtilitiesClass.Static.RModLog("TestExecuteBuilderBrush called");
    if(BuilderBrush != None)
    {
        TryExecuteBuilderBrush();
    }
}

function TestRTSStyleStuff()
{
    local String WindowResResult;
    
    WindowResResult = ConsoleCommand("GetCurrentRes");
    Log("GET CURRENT RES RETURNED:" @ WindowResResult);
}

exec function LogNetState()
{
    UtilitiesClass.Static.LogNetworkStateForActor(Self);
}

exec function TestBuildableIndex(int BuildableIndex)
{
    local Class<R_ABuildableActor> BuildableClass;
    
    UtilitiesClass.Static.RModLog("TestBuildableIndex called");
    
    if(BuilderBrush != None)
    {
        switch(BuildableIndex)
        {
            case 0: BuildableClass = Class'R_Tower_DwarfMech'; break;
            case 1: BuildableClass = Class'R_Tower_TreeOneLauncher'; break;
            default: BuildableClass = None;
        }
        
		R_TowerDefenseRootWindow(MyRootWindow).bHiddenWindow = true;
        BuilderBrush.SetBuildableActorClass(BuildableClass);
    }
}

exec function IncrementRowsCols(int Rows, int Cols)
{
	BuilderBrush.GridActor.TestRows += Rows;
	BuilderBrush.GridActor.TestCols += Cols;
}

exec function CreateTowerDefenseTestWindow()
{
	local Class<UWindowRootWindow> RootWindowClass;

	if(MyTestWindow != None)
	{
		return;
	}

	Log("Creating test root window and client window");

	// Create Root window
	RootWindowClass = Class'RMod_TowerDefense.R_TowerDefenseRootWindow';
	MyRootWindow = New(None) RootWindowClass;//Class<UWindowRootWindow>//(DynamicLoadObject(RootWindowClass, Class'Class'));
	MyRootWindow.BeginPlay();
	MyRootWindow.WinTop = 0;
	MyRootWindow.WinLeft = 0;
	MyRootWindow.WinWidth = 1920;
	MyRootWindow.WinHeight = 1080;
	//MyRootWindow.RealWidth = 1920;
	//MyRootWindow.RealHeight = 1080;

	MyRootWindow.ClippingRegion.X = 0;
	MyRootWindow.ClippingRegion.Y = 0;
	MyRootWindow.ClippingRegion.W = MyRootWindow.WinWidth;
	MyRootWindow.ClippingRegion.H = MyRootWindow.WinHeight;

	MyRootWindow.Console = WindowConsole(Player.Console);
	MyRootWindow.bUWindowActive = true;
	MyRootWindow.Created();
	//MyRootWindow.ShowWindow();

	// Now create a test window on that root
	// AND set it to the first child!!
	//MyTestWindow = MyRootWindow.CreateWindow(Class'RMod_TowerDefense.R_MyTestWindow', 100, 100, 200, 200);
	InventoryWindow = MyRootWindow.CreateWindow(Class'RMod_TowerDefense.R_UI_InventoryWindow', MyRootWindow.WinLeft, MyRootWindow.WinTop, MyRootWindow.WinWidth, MyRootWindow.WinHeight);

	//MyTestWindow.bWindowVisible = false;

	//MyRootWindow.ShowChildWindow(MyTestWindow);
	//Log("First child window:" @ MyRootWindow.FirstChildWindow);

	////
	//// Example of how to create UWindow instances outside of Root
	//// See UWindowWindow.Create for an example of what you need to manually
	//// call when creating windows
	////
	//Log("Creating test window", 'TEST');
	//MyTestWindow = New(None) Class'RMod_TowerDefense.R_MyTestWindow';
	//MyTestWindow.BeginPlay();
//
	//// Maybe can connect root to consoles root?
	//// MyTestWindow.Root = Player.Console.Root??
//
	//// UWindow also defines a Cursor struct and gives every child a reference to it
	//// Could grab MyTestWindow.Cursor = Player.Console.Cursor
	//// Maybe thats enough to receive events from owning
//
	//MyTestWindow.BeforeCreate();
	//MyTestWindow.Created();
	////ShowChildWindow() might be important
	//MyTestWindow.AfterCreate();
}

exec function BuildTower()
{
	R_TowerDefenseRootWindow(MyRootWindow).bHiddenWindow = !R_TowerDefenseRootWindow(MyRootWindow).bHiddenWindow;
}

exec function ToggleInventory()
{
	if(MyRootWindow == None)
	{
		CreateTowerDefenseTestWindow();
	}

	if(InventoryWindow == None)
	{
		return;
	}

	if(InventoryWindow.WindowIsVisible())
	{
		InventoryWindow.HideWindow();
	}
	else
	{
		InventoryWindow.ShowWindow();
	}
}

//==============================================================================
state PlayerWalking
{
	function GetMovementOrienation(out Vector OutX, out Vector OutY, out Vector OutZ)
	{
		local Vector X, Y, Z;

		GetAxes(SavedCameraRot, X, Y, Z);
		Z = Vect(0,0,1);
		X = Normal(X - (Z * (X Dot Z)));
		Y = Normal(Z Cross X);

		OutX = X;
		OutY = Y;
		OutZ = Z;
	}

	function Dodge(eDodgeDir DodgeMove)
	{
		local vector X,Y,Z;

		if ( bIsCrouching || (Physics != PHYS_Walking) )
			return;

		//GetAxes(Rotation,X,Y,Z);
		GetMovementOrienation(X, Y, Z);
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

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool	bSaveJump;
		local name AnimGroupName;

		GetMovementOrienation(X, Y, Z);

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

defaultproperties
{
	InWorldHUDClass=Class'RMod_TowerDefense.R_InWorldHUD'
    BuilderBrushClass=Class'RMod_TowerDefense.R_BuilderBrush'
    ActorSelectorClass=Class'RMod_TowerDefense.R_ActorSelector'
    //RootWidgetClass=Class'RMod_TowerDefense.R_UIPrimaryLayout'
}