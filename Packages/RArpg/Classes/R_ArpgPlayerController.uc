//==============================================================================
//	R_ArpgPlayerController
//	RunePlayer class for Arpg game modes
//==============================================================================
class R_ArpgPlayerController extends R_RunePlayer;

const CanvasLib = Class'RBase.R_ACanvasLibrary';
const MathLib = Class'RBase.R_AMathLibrary';
const TagLib = Class'RArpg.R_ArpgTagLibrary';

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
const UICommand_ShowItems = 'ShowItems';
const UICommand_HideItems = 'HideItems';
const UICommand_ShowInWorldHUD = 'ShowInWorldHUD';
const UICommand_HideInWorldHUD = 'HideInWorldHUD';

var private bool bAttacking;

//------------------------------------------------------------------------------
const SessionEndPointClass = Class'RArpg.R_ArpgSessionEndPoint';
var private R_ArpgSessionEndPoint SessionEndPoint;

var private R_ArpgPawn ControlledPawn;

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

function R_UI_ArpgGameUserInterface GetGameUI()
{
	return GameUI;
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

	TickPawnRotation(DeltaSeconds);

	if(GameUI != None)
	{
		GameUI.Tick(DeltaSeconds);
	}

	if(bAttacking)
	{
		GetControlledPawn().Input_Skill('Attack');
	}
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

function Vector GetViewLocation()
{
	return SavedCameraLoc;
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

exec function InputLMouseDown()
{
	local Vector CursorPosition;
	//Log("LMouseDown");
	if(GameUI != None)
	{
		GameCursor.GetCursorPosition(CursorPosition.X, CursorPosition.Y);
		if(GameUI.InputLMouseDown(CursorPosition.X, CursorPosition.Y))
		{
			return;
		}
	}

	if(ControlledPawn != None)
	{
		bAttacking = true;
		//ControlledPawn.Input_Skill('Attack');
	}
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

	bAttacking = false;
}

exec function Fire(optional float F)
{
}

exec function TestTakeDamage(float Amount)
{
	GetControlledPawn().ArpgTakeDamage(Amount);
}

event PostRender(Canvas C)
{
	if(GameUI != None)
	{
		GameUI.PostRender(C);
	}

	Super.PostRender(C);
}

/*
exec function SetAnimFrame(float Frame)
{
	ControlledPawn.AnimRate = 0.0;
	ControlledPawn.AnimFrame = Frame;
}

exec function TrySetAttribute(Name AttributeName, float Value)
{
	Log("Attempting to set Attribute" @ AttributeName @ "to a value of" @ Value);
	ControlledPawn.GetEntity().GetEntityAttributeSet().SetAttributeBaseValue(AttributeName, Value);
}

exec function TryAddModifier(Name AttributeName, int Operator, float Magnitude)
{
	ControlledPawn.GetEntity().GetEntityAttributeSet().AddAttributeModifier(AttributeName, Magnitude, Operator, 100);
}

exec function TryRemoveAllModifiers()
{
	ControlledPawn.GetEntity().GetEntityAttributeSet().RemoveAttributeModifiersBySource(100);
}
	*/

exec function TestItemPickup()
{
	local Vector SpawnLocation;
	local R_ArpgItemActor_Pickup A;
	local R_ArpgGameInfo GI;
	local R_ArpgItemFactory ItemFactory;
	local R_ArpgItem NewItem;

	GI = R_ArpgGameInfo(Level.Game);
	ItemFactory = GI.GetItemFactory();
	NewItem = ItemFactory.CreateItemFromTag(TagLib.Static.MakeTag('Item','Weapon','Axe','BattleAxe'));

	SpawnLocation = ControlledPawn.Location;
	A = Spawn(Class'RArpg.R_ArpgItemActor_Pickup',,,SpawnLocation);
	A.SetItem(NewItem);
}

exec function TestTossFloat()
{
	R_ArpgPawn_Hero(GetControlledPawn()).TryTossFloatingItem();
}

exec function TestUICommand(Name UICommand)
{
	GameUI.InputCommand(UICommand);
}

exec function TestSession()
{
	SessionEndPoint.TestSession();
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