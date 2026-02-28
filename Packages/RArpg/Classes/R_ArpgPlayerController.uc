//==============================================================================
//	R_ArpgPlayerController
//	RunePlayer class for Arpg game modes
//==============================================================================
class R_ArpgPlayerController extends R_RunePlayer;

const CanvasLib = Class'RBase.R_ACanvasLibrary';
const MathLib = Class'RBase.R_AMathLibrary';

//------------------------------------------------------------------------------
var private Class<R_ArpgPlayerCamera> PlayerCameraClass;
var private R_ArpgPlayerCamera PlayerCamera;

//------------------------------------------------------------------------------
//	GameUI
var private Class<R_UI_ArpgGameUserInterface> GameUIClass;
var private R_UI_ArpgGameUserInterface GameUI;

// Commands that the GameUI needs to be able to handle
// These should be reflected in any UI designed for Arpg
const UICommand_Inventory = 'Inventory';

//------------------------------------------------------------------------------
const SessionEndPointClass = Class'RArpg.R_ArpgSessionEndPoint';
var private R_ArpgSessionEndPoint SessionEndPoint;

// The current selection target
// i.e. what actor the mouse is currently hovered over
var private Actor SelectionTarget;
var private Actor InteractionActor;

var private R_ArpgPawn ControlledPawn;

var private Vector LastTraceStart;
var private Vector LastTraceEnd;
var private Vector LastHitLocation;

replication
{
	reliable if(Role == ROLE_Authority)
		SessionEndPoint;
}

//------------------------------------------------------------------------------

event PostBeginPlay()
{
	Super.PostBeginPlay();
	InitializeSessionEndPoint();
	SpawnPlayerCamera();

	GotoState('PlayerController');
}

function SpawnPlayerCamera()
{
	if(PlayerCameraClass != None)
	{
		if(PlayerCamera != None)
		{
			PlayerCamera.Destroy();
			PlayerCamera = None;
		}
		PlayerCamera = Spawn(PlayerCameraClass, Self);
	}
}

function R_ArpgPawn GetControlledPawn()
{
	return ControlledPawn;
}

exec function TestHero()
{
	SetCollision(false, false, false);
	DrawType = DT_None;
	ControlledPawn = Spawn(Class'RArpg.R_ArpgPawn_Hero', Self,, Self.Location, Self.Rotation);
}

function SetControlledPawn(R_ArpgPawn NewControlledPawn)
{
	ControlledPawn = NewControlledPawn;
	GameUI.SetItemContainerSet(None);
	if(ControlledPawn != None)
	{
		GameUI.SetItemContainerSet(ControlledPawn.GetInventorySet());
	}
}

function InitializeSessionEndPoint()
{
	SessionEndPoint = Spawn(SessionEndPointClass, Self);
}

exec function TestSession()
{
	SessionEndPoint.TestSession();
}

function InitializePlayerAfterPossess(bool bIsLocallyControlled)
{
    Super.InitializePlayerAfterPossess(bIsLocallyControlled);
    
    // For local player only
    if(bIsLocallyControlled)
    {
		// Enable and initialize the game cursor
        EnableGameCursor();
		if(GameCursor != None)
		{
			GameCursor.SetDragSelectionEnabled(false);
		}
    }
}

function InitializeGameUserInterface()
{
	Log("Initializing game ui from class" @ GameUIClass);
	GameUI = new(Self) GameUIClass;
	GameUI.Initialize(Self.Player);
}


exec function ArpgInventory()
{
	Log(GameUIClass);
	Log(GameUI);
	if(GameUI != None)
	{
		GameUI.InputCommand(UICommand_Inventory);
	}
}

event Tick(float DeltaSeconds)
{
	if(GetStateName() != 'PlayerController')
	{
		GotoState('PlayerController');
	}

	Super.Tick(DeltaSeconds);

	TickSelectionTarget(DeltaSeconds);
	TickPawnRotation(DeltaSeconds);

	/*
	if(InteractionActor != None)
	{
		if(VSize2D(InteractionActor.Location - ControlledPawn.Location) >= 128.0)
		{
			GameUI.CloseInteractionMenu();
			InteractionActor = None;
		}
	}
		*/

	if(GameUI != None)
	{
		GameUI.Tick(DeltaSeconds);
	}
}

function TickSelectionTarget(float DeltaSeconds)
{
	local Vector TraceOrigin, TraceDirection;
	local float TraceDistance;
	local Actor A;
	local R_ArpgTraceProxy TraceProxy;
	local Vector HitLoc, HitNorm;
	local Vector TraceStart, TraceEnd;

	if(!GameCursor.GetTraceWorldRay(TraceOrigin, TraceDirection))
	{
		return;
	}

	TraceDistance = 10240.0;
	TraceStart = TraceOrigin;
	TraceEnd = TraceStart + TraceDirection * TraceDistance;
	foreach TraceActors(Class'Actor', A, HitLoc, HitNorm, TraceEnd, TraceStart,, false)
	{
		TraceProxy = R_ArpgTraceProxy(A);
		if(TraceProxy == None)
		{
			continue;
		}

		A = TraceProxy.GetProxyOwner();
		if(A == None)
		{
			continue;
		}

		if(SelectionTarget == A)
		{
			return;
		}
		else
		{
			SetSelectionTarget(A);
			return;
		}
	}

	SetSelectionTarget(None);
}

function Actor GetSelectionTarget()
{
	return SelectionTarget;
}

function SetSelectionTarget(Actor NewSelectionTarget)
{
	if(SelectionTarget == NewSelectionTarget)
	{
		return;
	}
	SelectionTarget = NewSelectionTarget;
	OnSelectionTargetChange(NewSelectionTarget);
}

function OnSelectionTargetChange(Actor NewSelectionTarget)
{
	Log("New selection target is" @ NewSelectionTarget);
}

function TickPawnRotation(float DeltaSeconds)
{
	local Vector IntersectLocation;
	local Vector Delta;
	local Rotator NewRotation;
	local Vector BasisLocation;

	if(GameCursor == None)
	{
		return;
	}

	if(ControlledPawn != None)
	{
		BasisLocation = ControlledPawn.Location;
	}
	else
	{
		BasisLocation = Self.Location;
	}

	if(!GameCursor.PlaneIntersectUnderCursor(
		BasisLocation,
		Vect(0,0,1),
		IntersectLocation))
	{
		return;
	}

	Delta = Vect(1,1,0) * Normal(IntersectLocation - BasisLocation);
	if(ControlledPawn != None)
	{
		ControlledPawn.SetLookDirection(Delta);
	}

	NewRotation = Rotator(Delta);
	NewRotation.Pitch = 0;
	NewRotation.Roll = 9000;

	SetRotation(NewRotation);
	ViewRotation = NewRotation;
	//Log(NewRotation);
}

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

event PlayerInput(float DeltaSeconds)
{
	local Vector InputVector;
	local Vector X, Y, Z;
	local float CursorX, CursorY;

	GetMovementOrienation(X, Y, Z);

	InputVector = X * aBaseY * 0.4 + Y * aStrafe * 0.4;
	if(ControlledPawn != None)
	{
		ControlledPawn.AddMovementInput(InputVector);
	}

	Super.PlayerInput(DeltaSeconds);

	if(GameUI != None)
	{
		GameCursor.GetCursorPosition(CursorX, CursorY);
		GameUI.InputMouseMove(CursorX, CursorY);
	}
}

event PlayerCalcView(
    out Actor ViewActor,
    out vector CameraLocation,
    out rotator CameraRotation)
{
	if(PlayerCamera != None)
	{
		if(GameUI != None && GameUI.IsWindowVisible('Inventory'))
		{
			PlayerCamera.SetLocalOffset(Vect(0,1,0) * 128.0);
		}
		else
		{
			PlayerCamera.SetLocalOffset(Vect(0,0,0));
		}

		PlayerCamera.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
		SavedCameraLoc = CameraLocation;
		SavedCameraRot = CameraRotation;
	}
}

//==============================================================================
state PlayerWalking
{
	

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

exec function InputLMouseDown()
{
	local Vector CursorPosition;
	//Log("LMouseDown");
	if(GameUI != None)
	{
		GameCursor.GetCursorPosition(CursorPosition.X, CursorPosition.Y);
		GameUI.InputLMouseDown(CursorPosition.X, CursorPosition.Y);
	}

	//Fire();
}

exec function InputLMouseUp()
{
	local Vector CursorPosition;
	//Log("LMouseUp");
	if(GameUI != None)
	{
		GameCursor.GetCursorPosition(CursorPosition.X, CursorPosition.Y);
		GameUI.InputLMouseUp(CursorPosition.X, CursorPosition.Y);
	}
}

exec function Fire(optional float F)
{
	//if(ControlledPawn != None)
	//{
	//	ControlledPawn.Input_Fire();
	//}

	/*
	// Determine context of the click
	if(SelectionTarget != None && R_ArpgPawn_Merchant(SelectionTarget) != None)
	{
		GameUI.OpenInteractionMenu(SelectionTarget);
		InteractionActor = SelectionTarget;
	}
	else
	{
		if(ControlledPawn != None)
		{
			ControlledPawn.Input_Fire();
		}
	}
		*/
}

exec function TestHit()
{
	local Vector Start, End;
	local Vector HitLocation, HitNormal;
	local Actor HitActor;

	if(ControlledPawn == None)
	{
		return;
	}

	Start = ControlledPawn.Location;
	End = ControlledPawn.Location + Vector(ControlledPawn.Rotation) * 128.0;

	HitActor = Trace(HitLocation, HitNormal, End, Start, true);
	LastTraceEnd = End;
	LastTraceStart = Start;
	LastHitLocation = HitLocation;
}

event PostRender(Canvas C)
{
	if(GameUI != None)
	{
		GameUI.PostRender(C);
	}

	Super.PostRender(C);
}

exec function SetAnimFrame(float Frame)
{
	ControlledPawn.AnimRate = 0.0;
	ControlledPawn.AnimFrame = Frame;
}

auto state PlayerController
{
	event BeginState()
	{
		SetPhysics(PHYS_Flying);
		SetCollision(false, false, false);
		bCollideWorld = false;
	}

	function PlayerTick(float DeltaSeconds)
	{
		if(ControlledPawn != None)
		{
			SetLocation(ControlledPawn.Location);
		}
		else
		{
			Super.PlayerTick(DeltaSeconds);
		}
	}
}

defaultproperties
{
	InitialState=PlayerController
	PlayerCameraClass=Class'RArpg.R_ArpgPlayerCamera'
	//GameUIClass=Class'RArpg.R_UI_ArpgGameUserInterface'
	//GameUIClass=Class'RArpg.R_UI_ArpgGameUserInterface_ItemSlotTest'
	GameUIClass=Class'RArpg.R_UI_ArpgGameUserInterface_InventoryTest'
	DrawType=DT_Sprite
    Style=STY_Normal
	Texture=Texture'Engine.S_Pawn'
	bHidden=true
}