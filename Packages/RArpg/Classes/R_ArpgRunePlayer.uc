//==============================================================================
//	R_ArpgRunePlayer
//	RunePlayer class for Arpg game modes
//==============================================================================
class R_ArpgRunePlayer extends R_RunePlayer;

const CanvasLib = Class'RBase.R_ACanvasLibrary';
const MathLib = Class'RBase.R_AMathLibrary';

const InWorldUIClass = Class'RArpg.R_UI_InWorldUI';
var private R_UI_GameUserInterface InWorldUI;

const SessionEndPointClass = Class'RArpg.R_ArpgSessionEndPoint';
var private R_ArpgSessionEndPoint SessionEndPoint;

// The current selection target
// i.e. what actor the mouse is currently hovered over
var private Actor SelectionTarget;

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
	InWorldUI = new(Self) InWorldUIClass;
	InWorldUI.Initialize(Self.Player);
}

event Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);

	TickSelectionTarget(DeltaSeconds);
	TickPawnRotation(DeltaSeconds);

	if(InWorldUI != None)
	{
		InWorldUI.Tick(DeltaSeconds);
	}
}

function TickSelectionTarget(float DeltaSeconds)
{
	local Actor A;
	local Vector HitLocation, HitNormal;

	A = GameCursor.TraceUnderCursor(10240.0, HitLocation, HitNormal, true);

	if(SelectionTarget != A)
	{
		SetSelectionTarget(A);
	}
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

	SetRotation(NewRotation);
	ViewRotation = NewRotation;
	//Log(NewRotation);
}

event PostRender(Canvas C)
{
	Super.PostRender(C);

	/*
	if(InWorldUI != None)
	{
		InWorldUI.PostRender(C);
	}
		*/
}

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