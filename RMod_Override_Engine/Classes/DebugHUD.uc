//=============================================================================
// DebugHUD.
//=============================================================================
class DebugHUD extends HUD
	native;

/* Description:
	HUD used for debug

	ChangeCrosshair (BACKSPACE):
		Changes the selection criteria (none, target, player, visible, navpoints, all)
	ChangeHUD (\)
		Changes the debug mode (Actor, Skel, LOD, POV)

	To Add a new mode:
		Define a new state (see BlankMode)
		Bump ModeTable size
		Add the mode state name to the mode table in PostBegin()

*/

var Name ModeTable[11];

var actor watch;					// Used by all single-selection modes
var globalconfig int DebugMode;		// Cycled by ChangeCrosshair
var globalconfig int DebugHudMode;	// Cycled by ChangeHUD



/*	These are defined in ACTOR.UC for access in the Debug() functions
	
const DEBUG_NONE		=	0;	// No Debugging
const DEBUG_TARGET		=	1;	// Debug the target actor
const DEBUG_CONSTANT	=	2;	// Debug an actor and don't change
const DEBUG_AI			=	3;	// Debug AI (navpoints,constantTarget,POV)
const DEBUG_PLAYER		=	4;	// Debug the player
const DEBUG_LEVEL		=	5;	// Debug the level info actor
const DEBUG_ZONE		=	6;	// Debug current Zoneinfo
const DEBUG_MULTIPLE	=	7;	// ** this is the lowest multiple selection mode
const DEBUG_VISIBLE		=	7;	// Debug all visible actors
const DEBUG_LIGHTS		=	8;	// Debug lights
const DEBUG_NAVPOINTS	=	9;	// Debug all navigation points
const DEBUG_TRIGGERS	=	10;
const DEBUG_MAX			=	10;

const HUD_ACTOR			=	0;	// Call the actors debug function
const HUD_SKELETON		=	1;	// Draw skeleton
const HUD_SKELNAMES		=	2;	// Draw skeleton with joint names
const HUD_SKELJOINTS	=	3;	// Draw skeleton with collision joints
const HUD_SKELAXES		=	4;	// Draw skeleton with rotation axes
const HUD_LOD			=	5;	// Draw LOD
const HUD_POV			=	6;	// Draw POV of actor
ocnst HUD_SCRIPT		=	7;
const HUD_NETWORK		=	8;
const HUD_MAX			=   8;
const HUD_NONE			=   9;

*/

// ==================================================================
// Debugger interface
// ==================================================================

function Command( string text )
{
	local string verb, object;
	local int space;
	local Class<actor> NewClass;
	local actor A;
	local bool nextone;
	
	// Parse text into commands
	space = InStr(text, " ");
	if (space == -1)
	{
		verb = text;
		object = "";
	}
	else
	{
		verb = left(text, space);
		object = mid(text, space+1);
	}
	
//	slog("received command <"$verb$"> <"$object$">");
	
	if (verb ~= "watch")
	{
		if (InStr(object, ".")==-1)
			object = "RuneI."$object;
		NewClass = class<actor>( DynamicLoadObject( Object, class'Class' ) );
		if (NewClass == None)
		{
			object = "Engine."$object;
			NewClass = class<actor>( DynamicLoadObject( Object, class'Class' ) );
		}
		if (NewClass != None)
		{
			if (Watch != None)
			{
				foreach AllActors(NewClass, A)
				{
					if (Watch == A)
					{
						nextone = true;
						break;
					}
				}
			}
			if (!nextone)
				SetWatch(None);

			nextone = false;
			foreach AllActors(NewClass, A)
			{
				if (Watch != None)
				{	// Cycle to next of this type
					if (nextone)
					{
						SetWatch(A);
						return;
					}
					else if (Watch == A)
					{
						nextone = true;
					}
				}
				else
				{
					SetWatch(A);
					return;
				}
			}
			SetWatch(None);
		}
	}
}

// ==================================================================
// Hud interface functions
// ==================================================================

simulated function PostBeginPlay()
{
	SetTimer(0.5, true);

	ModeTable[0]  = 'BlankMode';
	ModeTable[1]  = 'ActorMode';
	ModeTable[2]  = 'ConstantMode';
	ModeTable[3]  = 'AIMode';
	ModeTable[4]  = 'PlayerMode';
	ModeTable[5]  = 'LevelMode';
	ModeTable[6]  = 'ZoneMode';
	ModeTable[7]  = 'VisibleMode';
	ModeTable[8]  = 'LightMode';
	ModeTable[9]  = 'NavPointMode';
	ModeTable[10] = 'TriggerMode';
}


auto State Startup
{
Begin:
	GotoState( ModeTable[DebugMode] );
}


simulated function CreateMenu()
{
	if ( PlayerPawn(Owner).bSpecialMenu && (PlayerPawn(Owner).SpecialMenu != None) )
	{
		MainMenu = Spawn(PlayerPawn(Owner).SpecialMenu, self);
		PlayerPawn(Owner).bSpecialMenu = false;
	}
	
	if ( MainMenu == None )
		MainMenu = Spawn(MainMenuType, self);
		
	if ( MainMenu == None )
	{
		PlayerPawn(Owner).bShowMenu = false;
		Level.bPlayersOnly = false;
		return;
	}
	else
	{
		MainMenu.PlayerOwner = PlayerPawn(Owner);
		MainMenu.PlayEnterSound();
	}
}

simulated function DefaultCanvas( canvas Canvas )
{
	Canvas.Reset();
	Canvas.SpaceX=0;
	Canvas.SpaceY=0;
	Canvas.bNoSmooth = True;
	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.b = 255;	
		
	Canvas.Font = Canvas.SmallFont;
	/*			//DebugHUD does not support non-latin character sets..
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticSmallFont();
	else
		Canvas.Font = Canvas.SmallFont;
	*/
}

simulated function InputNumber(byte F)
{
}

simulated function ChangeHud(int d)
{
	local int newmode;
		
	newmode = DebugHudMode + d;
	if ( newmode > HUD_MAX )
		newmode = 0;
	else if ( newmode < 0 )
		newmode = HUD_MAX;

	SetHudMode(newmode);
}

simulated function ChangeCrosshair(int d)
{
	local int newmode;
	
	newmode = DebugMode + d;
	if (newmode > DEBUG_MAX)
		newmode = 0;
	else if (newmode < 0)
		newmode = DEBUG_MAX;

	SetMode(newmode);
}

simulated function SetMode(int mode)
{
	DebugMode = mode;
	GotoState(ModeTable[DebugMode]);
}

simulated function SetHudMode(int mode)
{
	local int oldmode;
	oldmode = DebugHudMode;
	DebugHudMode = mode;
	ChangeHudMode(oldmode, DebugHudMode);
}

simulated function DrawCrossHair( canvas Canvas, int StartX, int StartY)
{
	local PlayerPawn P;
	local vector X,Y,Z;

	P = PlayerPawn(Owner);
	if ( !P.bShowMenu )
	{
		GetAxes(PlayerPawn(Owner).ViewRotation,X,Y,Z);
		Canvas.DrawLine3D(Owner.Location, Owner.Location+X*5000, 255, 255, 255);
	}
}

// ===================================================================
// NEW DEBUGHUD INFRASTRUCTURE
// ===================================================================


// This is the pure virtual interface
simulated function ChooseTarget(){}
simulated function DrawTitle(canvas Canvas){}
simulated function Render(canvas Canvas, int mode){}
simulated function ChangeHudMode(int from, int to){}
simulated function bool RelevantActor(Actor A){}


simulated function SetWatch(actor A)
{
	if (Watch != None)
	{
		HudModeShutdown(DebugHudMode, Watch);
	}
	Watch = A;
	if (Watch != None)
	{
		HudModeInitialize(DebugHudMode, Watch);
	}
}

simulated function PostRender( canvas Canvas )
{
	DefaultCanvas(Canvas);

	// Handle ancestor menus
	if ( PlayerPawn(Owner) != None )
	{
		if ( PlayerPawn(Owner).bShowMenu )
		{
			if ( MainMenu == None )
				CreateMenu();
			if ( MainMenu != None )
				MainMenu.DrawMenu(Canvas);
			return;
		}
	}

	// Draw the title
	if (DebugMode != DEBUG_NONE)
	{
		Canvas.SetPos(Canvas.ClipX-135, Canvas.ClipY-20);
		DrawTitle(Canvas);
		Canvas.SetPos(Canvas.ClipX-135, Canvas.ClipY-10);
		switch(DebugHudMode)
		{
			case HUD_ACTOR:
				Canvas.DrawText(" Mode: Actor Info");
				break;
			case HUD_SKELETON:
				Canvas.DrawText(" Mode: Skeleton");
				break;
			case HUD_SKELNAMES:
				Canvas.DrawText(" Mode: Joint Names");
				break;
			case HUD_SKELJOINTS:
				Canvas.DrawText(" Mode: Collision Joints");
				break;
			case HUD_SKELAXES:
				Canvas.DrawText(" Mode: Joint Axes");
				break;
			case HUD_LOD:
				Canvas.DrawText(" Mode: LOD Polys");
				break;
			case HUD_POV:
				Canvas.DrawText(" Mode: POV");
				break;
		}
	}

	Render(Canvas, HudMode);
}

simulated function Timer()
{
	ChooseTarget();
}






// ==================================================================
// ==================================================================
// Debug Mode States
// ==================================================================
// ==================================================================



// ------------------------------------------------------------------
//
// BlankMode
//
// ------------------------------------------------------------------
State BlankMode
{
	simulated function BeginState()
	{	// Do one time initialization
	}
	
	simulated function EndState()
	{	// Do cleanup
	}

	simulated function DrawTitle(canvas Canvas)
	{	// Draw the mode title
	}

	simulated function ChangeHudMode(int from, int to)
	{	// Call ChangeHudModeForActor() on all this mode's actors
	}

	simulated function ChooseTarget()
	{	// Called at 2 Hz
	}

	simulated function Render(canvas Canvas, int mode)
	{	// Render the HUD
	}

	simulated function bool RelevantActor(Actor A)
	{	// Decide if actor is relevant to this set
	}
}


// ------------------------------------------------------------------
//
// ActorMode
//
// ------------------------------------------------------------------
State ActorMode
{
	simulated function BeginState()
	{
		SetWatch(None);
	}
	
	simulated function EndState()
	{
	}

	simulated function DrawTitle(canvas Canvas)
	{
		Canvas.DrawText("Debug Target Actor");
	}

	simulated function ChangeHudMode(int from, int to)
	{
		HudModeShutdown(from, Watch);
		HudModeInitialize(to, Watch);
	}

	simulated function ChooseTarget()
	{
		local vector HL,HN,X,Y,Z;
		local actor A;
		
		GetAxes(PlayerPawn(Owner).ViewRotation,X,Y,Z);
		foreach TraceActors(class'actor', A, HL, HN, Owner.Location+X*5000, Owner.Location)
		{
			if ((A != Level) && (A != None))
			{
				SetWatch(A);
			}
			break;
		}
	}
	
	simulated function Render(canvas Canvas, int mode)
	{
		DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
		DrawHUD(Canvas, Watch);
	}
}


// ------------------------------------------------------------------
//
// ConstantMode
//
// ------------------------------------------------------------------
State ConstantMode
{
	simulated function BeginState()
	{
		SetWatch(None);
	}
	
	simulated function EndState()
	{
	}

	simulated function DrawTitle(canvas Canvas)
	{
		Canvas.DrawText("Debug Constant Target");
	}

	simulated function ChangeHudMode(int from, int to)
	{
		HudModeShutdown(from, Watch);
		HudModeInitialize(to, Watch);
	}

	simulated function ChooseTarget()
	{
		local vector HL,HN,X,Y,Z;
		local actor A;
		
		if (Owner==None)
			return;

		if (Watch == None)
		{
			GetAxes(PlayerPawn(Owner).ViewRotation,X,Y,Z);
			foreach TraceActors(class'actor', A, HL, HN, Owner.Location+X*5000, Owner.Location)
			{
				if ((A != Level) && (A != None))
				{
					SetWatch(A);
				}
				break;
			}
		}
	}
	
	simulated function Render(canvas Canvas, int mode)
	{
		if (Watch == None)
			DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
		else
		{
			// The pawn currently disappears if you switch mode while he's in wireframe
			/*
			if (Pawn(Owner).LineOfSightTo(Watch))
			{
				Canvas.DrawActor(Watch, false, false);
			}
			else
			{
				Canvas.DrawActor(Watch, true, true);
			}
			*/
			DrawHUD(Canvas, Watch);
		}
	}
}


// ------------------------------------------------------------------
//
// AIMode
//
// ------------------------------------------------------------------
State AIMode
{
	simulated function BeginState()
	{	// Do one time initialization
		local NavigationPoint N;
		
		SetWatch(None);
//		PlayerPawn(Owner)->bOverheadCamera = true; (must move bOverhead... to PlayerPawn)
		foreach AllActors(class'NavigationPoint', N)
			N.bHidden = false;
	}
	
	simulated function EndState()
	{	// Do cleanup
		local NavigationPoint N;
		
//		PlayerPawn(Owner)->bOverheadCamera = false; (must move bOverhead... to PlayerPawn)
		foreach AllActors(class'NavigationPoint', N)
			N.bHidden = true;
	}

	simulated function DrawTitle(canvas Canvas)
	{	// Draw the mode title
		Canvas.DrawText("Debug AI");
	}

	simulated function ChangeHudMode(int from, int to)
	{	// Call ChangeHudModeForActor() on all this mode's actors
		HudModeShutdown(from, Watch);
		HudModeInitialize(to, Watch);
	}

	simulated function ChooseTarget()
	{	// Called at 2 Hz
		local vector HL,HN,X,Y,Z;
		local actor A;
		
		if (Watch == None)
		{
			GetAxes(PlayerPawn(Owner).ViewRotation,X,Y,Z);
			foreach TraceActors(class'actor', A, HL, HN, Owner.Location+X*5000, Owner.Location)
			{
				if ((A != Level) && (A != None))
				{
					SetWatch(A);
				}
				break;
			}
		}
	}

	simulated function Render(canvas Canvas, int mode)
	{	// Render the HUD
		DrawNavPoints(Canvas);
		Canvas.SetOrigin(0,0);
		if (Watch == None)
			DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
		else
		{
			// The pawn currently disappears if you switch mode while he's in wireframe
			/*
			if (Pawn(Owner).LineOfSightTo(Watch))
			{
				Canvas.DrawActor(Watch, false, false);
			}
			else
			{
				Canvas.DrawActor(Watch, true, true);
			}
			*/
			DrawHUD(Canvas, Watch);
			if (DebugHudMode != HUD_POV && DebugHudMode != HUD_ACTOR)
				DrawViewFrom(Canvas, Watch);
		}
	}
}


// ------------------------------------------------------------------
//
// PlayerMode
//
// ------------------------------------------------------------------
State PlayerMode
{
	simulated function BeginState()
	{	// Do one time initialization
	}
	
	simulated function EndState()
	{	// Do cleanup
	}

	simulated function DrawTitle(canvas Canvas)
	{	// Draw the mode title
		Canvas.DrawText("Debug Player");
	}

	simulated function ChangeHudMode(int from, int to)
	{
		HudModeShutdown(from, Watch);
		HudModeInitialize(to, Watch);
	}

	simulated function ChooseTarget()
	{	// Called at 2 Hz
		SetWatch(Owner);
	}

	simulated function Render(canvas Canvas, int mode)
	{	// Render the HUD
		DrawHUD(Canvas, Watch);
	}
}


// ------------------------------------------------------------------
//
// VisibleMode
//
// ------------------------------------------------------------------
State VisibleMode
{
	simulated function BeginState()
	{	// Do one time initialization
		local actor A;
		foreach AllActors(class'actor', A)
		{
			HudModeInitialize(DebugHudMode, A);
		}
	}
	
	simulated function EndState()
	{	// Do cleanup
		local actor A;
		foreach AllActors(class'actor', A)
		{
			HudModeShutdown(DebugHudMode, A);
		}
	}

	simulated function DrawTitle(canvas Canvas)
	{	// Draw the mode title
		Canvas.DrawText("Debug Visible Actors");
	}

	simulated function ChangeHudMode(int from, int to)
	{
		local actor A;
		foreach AllActors(class'actor', A)
		{
			HudModeShutdown(from, A);
			HudModeInitialize(to, A);
		}
	}

	simulated function ChooseTarget()
	{	// Called at 2 Hz
	}

	simulated function Render(canvas Canvas, int mode)
	{	// Render the HUD
		local actor A;
		local int sx,sy;
		
		foreach Owner.VisibleActors(class'actor', A)
		{
			Canvas.TransformPoint(A.Location, sx, sy);
			Canvas.SetOrigin(sx,sy);
			DrawHUD(Canvas, A);
		}
	}
}


// ------------------------------------------------------------------
//
// LevelMode
//
// ------------------------------------------------------------------
State LevelMode
{
	simulated function BeginState()
	{	// Do one time initialization
		local LevelInfo L;
		Owner.ConsoleCommand("rmode 3");
		foreach AllActors(class'LevelInfo', L)
			L.bHidden = false;
	}
	
	simulated function EndState()
	{	// Do cleanup
		local LevelInfo L;
		Owner.ConsoleCommand("rmode 5");
		foreach AllActors(class'LevelInfo', L)
			L.bHidden = true;
	}

	simulated function DrawTitle(canvas Canvas)
	{	// Draw the mode title
		Canvas.DrawText("Debug Level");
	}

	simulated function ChangeHudMode(int from, int to)
	{
		HudModeShutdown(from, Watch);
		HudModeInitialize(to, Watch);
	}

	simulated function ChooseTarget()
	{	// Called at 2 Hz
		SetWatch(Owner.Level);
	}

	simulated function Render(canvas Canvas, int mode)
	{	// Render the HUD
//		DrawHUD(Canvas, Watch);
		DrawDebugActor(Canvas, Watch);
	}
}


// ------------------------------------------------------------------
//
// ZoneMode
//
// ------------------------------------------------------------------
State ZoneMode
{
	simulated function BeginState()
	{	// Do one time initialization
		local ZoneInfo A;
		Owner.ConsoleCommand("rmode 2");
		foreach AllActors(class'ZoneInfo', A)
			A.bHidden = false;
	}
	
	simulated function EndState()
	{	// Do cleanup
		local ZoneInfo A;
		Owner.ConsoleCommand("rmode 5");
		foreach AllActors(class'ZoneInfo', A)
			A.bHidden = true;
	}

	simulated function DrawTitle(canvas Canvas)
	{	// Draw the mode title
		Canvas.DrawText("Debug Zone");
	}

	simulated function ChangeHudMode(int from, int to)
	{
		HudModeShutdown(from, Watch);
		HudModeInitialize(to, Watch);
	}

	simulated function ChooseTarget()
	{	// Called at 2 Hz
		SetWatch(Owner.Region.Zone);
	}

	simulated function Render(canvas Canvas, int mode)
	{	// Render the HUD
		DrawHUD(Canvas, Watch);
	}
}


// ------------------------------------------------------------------
//
// LightMode
//
// ------------------------------------------------------------------
State LightMode
{
	simulated function BeginState()
	{	// Do one time initialization
		local Light A;
		foreach AllActors(class'Light', A)
			A.bHidden = false;
	}
	
	simulated function EndState()
	{	// Do cleanup
		local Light A;
		foreach AllActors(class'Light', A)
			A.bHidden = true;
	}

	simulated function DrawTitle(canvas Canvas)
	{	// Draw the mode title
		Canvas.DrawText("Debug Lights");
	}

	simulated function ChangeHudMode(int from, int to)
	{
	}

	simulated function ChooseTarget()
	{	// Called at 2 Hz
	}

	simulated function Render(canvas Canvas, int mode)
	{	// Render the HUD
		local Light L;
		local int sx,sy;
		
		foreach Owner.VisibleActors(class'light', L)
		{
			DrawLightActor(Canvas, L);
			Canvas.TransformPoint(L.Location, sx, sy);
			Canvas.SetOrigin(sx,sy);
			DrawHUD(Canvas, L);
		}
	}
}


// ------------------------------------------------------------------
//
// NavPointMode
//
// ------------------------------------------------------------------
State NavPointMode
{
	simulated function BeginState()
	{	// Do one time initialization
		local NavigationPoint N;
		foreach AllActors(class'NavigationPoint', N)
			N.bHidden = false;
	}
	
	simulated function EndState()
	{	// Do cleanup
		local NavigationPoint N;
		foreach AllActors(class'NavigationPoint', N)
			N.bHidden = true;
	}

	simulated function DrawTitle(canvas Canvas)
	{
		Canvas.DrawText("Debug NavPoints");
	}

	simulated function ChangeHudMode(int from, int to)
	{
	}

	simulated function ChooseTarget()
	{
	}

	simulated function Render(canvas Canvas, int mode)
	{
		DrawNavPoints(Canvas);
	}
}


// ------------------------------------------------------------------
//
// TriggerMode
//
// ------------------------------------------------------------------
State TriggerMode
{
	simulated function bool RelevantActor(Actor A)
	{
		return
		(
			A.Event != '' ||
			(ZoneInfo(A) != None && (ZoneInfo(A).ZonePlayerEvent != '' || ZoneInfo(A).ZonePlayerExitEvent != '')) ||
			PolyObj(A) != None ||
			Mover(A) != None ||
			Triggers(A) != None
		);
	}

	simulated function BeginState()
	{	// Do one time initialization
		local Actor A;
		foreach AllActors(class'Actor', A)
			if (RelevantActor(A))
				A.bHidden = false;
	}
	
	simulated function EndState()
	{	// Do cleanup
		local Actor A;
		foreach AllActors(class'Actor', A)
			if (RelevantActor(A))
				A.bHidden = A.Default.bHidden;
	}

	simulated function DrawTitle(canvas Canvas)
	{
		Canvas.DrawText("Debug Triggers");
	}

	simulated function ChangeHudMode(int from, int to)
	{
	}

	simulated function ChooseTarget()
	{
	}

	simulated function Render(canvas Canvas, int mode)
	{
		DrawTriggers(Canvas);
	}
}



// ==================================================================
// ==================================================================
// Hud Mode functions (sub-modes)
// ==================================================================
// ==================================================================

simulated function HudModeInitialize(int mode, actor A)
{
	if (A==None)
		return;

	// Entering this mode
	switch(mode)
	{
		case HUD_ACTOR:
		case HUD_LOD:
		case HUD_NETWORK:
			break;
		case HUD_POV:
			break;
		case HUD_SKELETON:
			if (A.Skeletal != None)
			{
				A.Style = STY_TRANSLUCENT;
				A.bDrawSkel = true;
			}
			break;
		case HUD_SKELNAMES:
			if (A.Skeletal != None)
			{
				A.Style = STY_TRANSLUCENT;
				A.bDrawSkel = true;
			}
			break;
		case HUD_SKELJOINTS:
			if (A.Skeletal != None)
			{
				A.Style = STY_TRANSLUCENT;
				A.bDrawSkel = true;
				A.bDrawJoints = true;
			}
			break;
		case HUD_SKELAXES:
			if (A.Skeletal != None)
			{
				A.Style = STY_TRANSLUCENT;
				A.bDrawSkel = true;
				A.bDrawAxes = true;
			}
			break;

	}
}

simulated function HudModeShutdown(int mode, actor A)
{
	if (A==None)
		return;

	// Leaving this mode
	switch(mode)
	{
		case HUD_ACTOR:
		case HUD_LOD:
		case HUD_POV:
		case HUD_NETWORK:
			break;

		case HUD_SKELETON:
			A.Style = A.default.Style;
			A.bDrawSkel = false;
			break;
		case HUD_SKELNAMES:
			A.Style = A.default.Style;
			A.bDrawSkel = false;
			break;
		case HUD_SKELJOINTS:
			A.Style = A.default.Style;
			A.bDrawSkel = false;
			A.bDrawJoints = false;
			break;
		case HUD_SKELAXES:
			A.Style = A.default.Style;
			A.bDrawSkel = false;
			A.bDrawAxes = false;
			break;
	}
}

simulated function DrawHUD(canvas Canvas, actor A)
{
	local int actorX, actorY;
	
	if (A==None)
		return;

	actorX = Canvas.OrgX;
	actorY = Canvas.OrgY;
	
	Canvas.SetPos(0,0);

	switch(DebugHudMode)
	{
		case HUD_ACTOR:
			Canvas.SetOrigin(Canvas.default.OrgX, Canvas.default.OrgY);
			DrawActorCylinder(Canvas, A);
			DrawActorVectors(Canvas, A);
	
			Canvas.SetOrigin(actorX, actorY);
			DrawDebugActor(Canvas, A);
			break;

		case HUD_NETWORK:
			Canvas.SetOrigin(Canvas.default.OrgX, Canvas.default.OrgY);
			DrawActorCylinder(Canvas, A);
			Canvas.SetOrigin(actorX, actorY);
			DrawDebugActorNet(Canvas, A);
			break;

		case HUD_SKELETON:
			DrawDebugActor(Canvas, A);
			break;

		case HUD_SKELNAMES:
			Canvas.SetOrigin(Canvas.default.OrgX, Canvas.default.OrgY);
			DrawActorJointNames(Canvas, A);
			Canvas.SetOrigin(actorX, actorY);
			DrawDebugActor(Canvas, A);
			break;
			
		case HUD_SKELJOINTS:
			DrawDebugActor(Canvas, A);
			break;
			
		case HUD_SKELAXES:
			DrawDebugActor(Canvas, A);
			break;
			
		case HUD_LOD:
			Canvas.SetOrigin(Canvas.default.OrgX, Canvas.default.OrgY);
			DrawPolyCount(Canvas, A);
			break;
			
		case HUD_POV:
			if (DebugMode < DEBUG_MULTIPLE)
			{
				DrawViewFrom(Canvas, A);
			}
			break;
	}
	
	Canvas.SetColor(255, 255, 255);
}

// ==================================================================
// Debug info drawing routines
// ==================================================================

simulated function DrawActorVectors(canvas Canvas, actor A)
{
	local vector X,Y,Z;

	// Draw orientation coordinate frame
	GetAxes(A.Rotation,X,Y,Z);
	X *= 10;
	Y *= 10;
	Z *= 10;
	Canvas.DrawLine3D(A.Location, A.Location+X, 10,  0,  0);
	Canvas.DrawLine3D(A.Location, A.Location+Y,  0, 10,  0);
	Canvas.DrawLine3D(A.Location, A.Location+Z,  0,  0, 10);

	// Draw these vectors from top of cyllinder
	X = A.Location;
	X.Z += A.CollisionHeight;
		
	// Draw Velocity vector
	Canvas.DrawLine3D(X, X+A.Velocity, 0, 150, 200);
	
	// Draw Acceleration vector
	Canvas.DrawLine3D(X, X+A.Acceleration, 30, 0, 20);
}

simulated function DrawActorCylinder(canvas Canvas, actor A)
{
	local vector Extents;
	
	Canvas.SetColor(255,0,0);
	Extents.X = A.CollisionRadius;
	Extents.Y = A.CollisionRadius;
	Extents.Z = A.CollisionHeight;
	Canvas.DrawBox3D(A.Location, Extents, 10, 10, 10);
}

simulated function DrawActorJointNames(canvas Canvas, actor A)
{
	local int i, sx, sy;
	local vector jointpos;
	local string flags;
	
	if (A.Skeletal != None)
	{
		if (PlayerPawn(A)!=None && !Pawn(A).bBehindView)
			return;
		
		for (i=0; i<A.NumJoints(); i++)
		{
			jointpos = A.GetJointPos(i);
			flags = "";
			if (A.JointFlags[i] != 0)
			{
				flags = "(";
				if ((A.JointFlags[i] & JOINT_FLAG_SPRINGPOINT)!=0)
					flags = flags $ "S";
				if ((A.JointFlags[i] & JOINT_FLAG_ACCELERATIVE)!=0)
					flags = flags $ "A";
				if ((A.JointFlags[i] & JOINT_FLAG_GRAVJOINT)!=0)
					flags = flags $ "G";
				if ((A.JointFlags[i] & JOINT_FLAG_BLENDJOINT)!=0)
					flags = flags $ "B";
				if ((A.JointFlags[i] & JOINT_FLAG_IKCHAIN)!=0)
					flags = flags $ "I";
				if ((A.JointFlags[i] & JOINT_FLAG_COLLISION)!=0)
					flags = flags $ "C";
				if ((A.JointFlags[i] & JOINT_FLAG_ABSPOSITION)!=0)
					flags = flags $ "P";
				if ((A.JointFlags[i] & JOINT_FLAG_ABSROTATION)!=0)
					flags = flags $ "R";
				flags = flags$")";
			}
			Canvas.TransformPoint(jointpos, sx, sy);
			Canvas.SetPos(sx,sy);
			Canvas.SetColor(255,255,255);
			Canvas.DrawText(A.GetJointName(i)@flags);
		}
	}
}

simulated function DrawPolyCount(canvas Canvas, actor A)
{
	local int sx, sy;

	if(A.Skeletal != None)
	{
		Canvas.TransformPoint(A.Location, sx, sy);
		Canvas.SetPos(sx,sy);
		Canvas.SetColor(255,255,0);
		Canvas.DrawText("" $A.LODPolyCount);
	}
}


simulated function DrawNavPoints(canvas Canvas)
{
	local NavigationPoint A;
	local int sx, sy;

	Canvas.SetPos(Canvas.ClipX-135, Canvas.ClipY-30);
	switch(DebugHudMode)
	{
		case HUD_ACTOR:			// Normal paths
			Canvas.DrawText("Paths");
			break;
		case HUD_SKELETON:		// VisNoReach paths
			Canvas.DrawText("VisNoReach Paths");
			break;
		case HUD_SKELNAMES:		// Pruned paths
			Canvas.DrawText("Pruned Paths");
			break;
		case HUD_SKELJOINTS:	// Radii/Height Tubes
			Canvas.DrawText("Collision Thresholds");
			break;
		case HUD_SKELAXES:		// End point info
			Canvas.DrawText("End Point Info");
			break;
		case HUD_LOD:
			Canvas.DrawText("Misc info");
			break;
		case HUD_POV:
			Canvas.DrawText("None");
			break;
	}		
	
	foreach Owner.VisibleActors(class'NavigationPoint', A)
	{
		Canvas.TransformPoint(A.Location, sx, sy);
		Canvas.SetOrigin(sx, sy);
		Canvas.SetPos(0, 0);
		Canvas.SetColor(255,255,255);
		Canvas.DrawText(A.Name);
		Canvas.CurY -= 8;

		Canvas.SetOrigin(0, 0);
		A.Debug(Canvas, DebugHudMode);
	}
}


simulated function DrawTriggers(canvas Canvas)
{
	local Actor A;
	local int sx, sy;

	Canvas.SetPos(Canvas.ClipX-135, Canvas.ClipY-30);
/*	switch(DebugHudMode)
	{
		case HUD_ACTOR:			// Normal paths
			Canvas.DrawText("Paths");
			break;
		case HUD_SKELETON:		// VisNoReach paths
			Canvas.DrawText("VisNoReach Paths");
			break;
		case HUD_SKELNAMES:		// Pruned paths
			Canvas.DrawText("Pruned Paths");
			break;
		case HUD_SKELJOINTS:	// Radii/Height Tubes
			Canvas.DrawText("Collision Thresholds");
			break;
		case HUD_SKELAXES:		// End point info
			Canvas.DrawText("End Point Info");
			break;
		case HUD_LOD:
			Canvas.DrawText("Misc info");
			break;
		case HUD_POV:
			Canvas.DrawText("None");
			break;
	}		
*/

	foreach Owner.VisibleActors(class'Actor', A)
	{
		if (RelevantActor(A))
		{
			Canvas.SetOrigin(Canvas.default.OrgX, Canvas.default.OrgY);

			DrawActorCylinder(Canvas, A);

			Canvas.TransformPoint(A.Location, sx, sy);
			Canvas.SetOrigin(sx, sy);
			Canvas.SetPos(0, 0);
			Canvas.SetColor(255,255,0);

			A.Debug(Canvas, HUD_SCRIPT);
		}
	}
}



function HSV_to_RGB(int H, int S, int V, out int R, out int G, out int B)
{
	local float brightness;
	local vector hue,rgb;
	
	Brightness = V * 1.4 / 255.0;
	Brightness *= 0.70 / (0.01 + Sqrt(Brightness));
	Brightness  = Clamp(Brightness, 0.0, 1.0);
	if (H<86)
	{
		hue.X = (85-H)/85.0;
		hue.Y = H/85.0;
		hue.Z = 0;
	}
	else if (H<171)
	{
		hue.X = 0;
		hue.Y = (170-H)/85.0;
		hue.Z = (H-85)/85.0;
	}
	else
	{
		hue.X = (H-170)/85.0;
		hue.Y = 0;
		hue.Z = (255-H)/84.0;
	}

	rgb = (hue + (S/255.0) * (vect(1,1,1) - hue)) * Brightness;
	R = rgb.X;
	G = rgb.Y;
	B = rgb.Z;
}

simulated function DrawLightActor(canvas Canvas, actor A)
{
	local int R,G,B;
	local vector extents;
	
	HSV_to_RGB(A.LightHue,A.LightSaturation,A.LightBrightness,R,G,B);
	Canvas.SetColor(R,G,B);
	extents.X = A.LightRadius;
	extents.Y = A.LightRadius;
	extents.Z = A.LightRadius;
	Canvas.DrawBox3D(A.Location, extents, R, G, B);
}

simulated function DrawViewFrom(canvas Canvas, actor A)
{
	local rotator rot;
	local vector loc;
	
	A.bHidden = true;
	rot = A.Rotation;
	if (Pawn(A) != None)
		rot = rot + Pawn(A).LookAngle;
	loc = A.Location;
//When GetJointPos() is decoupled from render, this can be put back in
/*	if (A.Skeletal != None && A.JointNamed('head') != 0)
		loc = A.GetJointPos(A.JointNamed('head'));*/
	Canvas.DrawPortal(Canvas.ClipX-160, 0, 160, 120, A, loc, rot, 90, true );
	A.bHidden = A.default.bHidden;
	
	Canvas.SetPos(600, 470);
//	Canvas.SetPos(Canvas.ClipX-150, 110);
	Canvas.DrawText(A.Name@"CAM");
}

simulated function DrawDebugActor(canvas Canvas, actor A)
{
	Canvas.SetColor(255, 0, 0);
	A.Debug(Canvas, DebugMode);
}

simulated function name GetRoleName(ENetRole theRole)
{
	switch(theRole)
	{
	case ROLE_None:				return 'ROLE_None';
	case ROLE_DumbProxy:		return 'ROLE_DumbProxy';
	case ROLE_SimulatedProxy:	return 'ROLE_SimulatedProxy';
	case ROLE_AutonomousProxy:	return 'ROLE_AutonomousProxy';
	case ROLE_Authority:		return 'ROLE_Authority';
	}
}

simulated function DrawDebugActorNet(canvas Canvas, actor A)
{
	Canvas.SetColor(255, 0, 0);
//	A.Debug(Canvas, DebugMode);

	Canvas.DrawText("Name: "@A.name);
	Canvas.CurY -= 8;
	Canvas.DrawText("Class:"@A.class);
	Canvas.CurY -= 8;
	Canvas.DrawText("State:"@A.GetStateName());
	Canvas.CurY -= 8;
	Canvas.DrawText("Owner:"@A.Owner);
	Canvas.CurY -= 8;
	Canvas.DrawText("Role:       "@GetRoleName(A.Role));
	Canvas.CurY -= 8;
	Canvas.DrawText("RemoteRole: "@GetRoleName(A.RemoteRole));
	Canvas.CurY -= 8;
	Canvas.DrawText("bNetOwner:     "@A.bNetOwner);
	Canvas.CurY -= 8;
	Canvas.DrawText("bNetInitial:   "@A.bNetInitial);
	Canvas.CurY -= 8;
	Canvas.DrawText("bSimulatedPawn:"@A.bSimulatedPawn);
	Canvas.CurY -= 8;
	Canvas.DrawText("bIsPawn:       "@A.bIsPawn);
	Canvas.CurY -= 8;
	Canvas.DrawText("bClientAnim:   "@A.bClientAnim);
	Canvas.CurY -= 8;
	Canvas.DrawText("SimAnimFrame:  "@A.SimAnim.X*0.0001$"/"$A.AnimFrame);
	Canvas.CurY -= 8;
	Canvas.DrawText("SimAnimRate:   "@A.SimAnim.Y*0.0002$"/"$A.AnimRate);
	Canvas.CurY -= 8;
	Canvas.DrawText("SimTweenRate:  "@A.SimAnim.Z*0.001$"/"$A.TweenRate);
	Canvas.CurY -= 8;
	Canvas.DrawText("SimAnimLast:   "@A.SimAnim.w*0.0001$"/"$A.AnimLast);
	Canvas.CurY -= 8;
	Canvas.DrawText("bSimFall:      "@A.bSimFall);
	Canvas.CurY -= 8;
	Canvas.DrawText("bNetOptional:  "@A.bNetOptional);
	Canvas.CurY -= 8;
	Canvas.DrawText("bNetTemporary: "@A.bNetTemporary);
	Canvas.CurY -= 8;
}

defaultproperties
{
}
