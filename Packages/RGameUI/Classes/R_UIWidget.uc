//==============================================================================
// R_UIWidget
// Base class for all UI Widgets in the RMod User Interface package
//==============================================================================
class R_UIWidget extends Object;

// Libraries
const MathLibrary = Class'RBase.R_AMathLibrary';
const CanvasLibrary = Class'RBase.R_ACanvasLibrary';
const UILibrary = Class'RGameUI.R_AUILibrary';

// Common events
//	- Emitted via BroadcastEvent
//	- Received via ReceiveEvent
const WidgetEvent_Pressed = 'Pressed';
const WidgetEvent_Clicked = 'Clicked';

// Optional Name tag given to this widget at time of creation
var private Name WidgetTag;

// Event listeners
// All widgets in this list will receive events from Self
var private R_ObjectList EventListeners;

// Child widgets
var private R_ObjectList ChildWidgets;

// Event related
var private bool bWaitingMouseUp;
var private bool bHovered;

// The owning PlayerPawn
var PlayerPawn OwningPlayer;

// Anchor testing
var Vector AnchorMin;
var Vector AnchorMax;

// Bounding box for this widget, used for collision
// This updates in Draw, because it needs Canvas reference
var private Vector WidgetExtentMin;
var private Vector WidgetExtentMax;

var float ColorR, ColorG, ColorB, ColorA;

/**
*   InitializeWidget
*   Called immediately after the owning player has created this widget
*   OwningPlayer is valid by the time this function is called
*/
final function bool InitializeWidget(PlayerPawn NewOwningPlayer, optional Name NewWidgetTag)
{
	local String LogString;

    if(NewOwningPlayer == None)
    {
        Warn(Class @ "InitializeWidget failed, NewOwningPlayer = None");
        return false;
    }

	WidgetTag = NewWidgetTag;

	EventListeners = New(None) Class'RBase.R_ObjectList';
	ChildWidgets = New(None) Class'RBase.R_ObjectList';
    
	bWaitingMouseUp = false;
	bHovered = false;

    OwningPlayer = NewOwningPlayer;

	LogString = "Widget initialized for class" @ Class;
	if(WidgetTag != '')
	{
		LogString = LogString @ "with tag" @ WidgetTag;
	}

	LogString = LogString @ "---- Calling BuildWidget";
    Log(LogString, UILibrary.Static.LogCategory());
    BuildWidget();
    
    return true;
}

/**
*	GetWidgetTag
*	Returns the tag associated with this widget from UILibrary.CreateWidget, if one was given
*	This is primarily for identifying widgets in the ReceiveEvent function without having to
*	hold a direct reference to them
*/
function Name GetWidgetTag()
{
	return WidgetTag;
}

/**
*   BuildWidget
*   This function should construct your widget
*/
function BuildWidget()
{
    Log("Building widget" @ Class, UILibrary.Static.LogCategory());
}

/**
*   AddChild
*   Add child node
*/
function AddChild(R_UIWidget NewChildWidget)
{
	ChildWidgets.AddUnique(NewChildWidget);
}

/**
*	AddEventListener
*	Register a widget to receive events emitted from this widget
*/
function AddEventListener(R_UIWidget NewEventListener)
{
	EventListeners.AddUnique(NewEventListener);
}

/**
*	BroadcastEvent
*	Send an event to all event listeners, which will be received
*	in the listener's ReceiveEvent function
*/
function BroadcastEvent(Name EventName)
{
	local R_ObjectList NodeIt;
	local Object ObjectIt;
	local R_UIWidget WidgetIt;

	NodeIt = EventListeners.Begin();
	while(EventListeners.Iterate(NodeIt, ObjectIt))
	{
		WidgetIt = R_UIWidget(ObjectIt);
		if(WidgetIt != None)
		{
			WidgetIt.ReceiveEvent(Self, EventName);
		}
	}
}

/**
*	ReceiveEvent
*	Called when this Widget has received an event from some Widget (Emitter)
*	that this widget has registered itself as an event listener on
*/
function ReceiveEvent(R_UIWidget Emitter, Name EventName)
{}

/**
*   DrawWidget
*   Main draw function for each widget
*/
function DrawWidget(Canvas C)
{
    local Vector SavedOrigin;
    local Vector SavedClip;
    local Vector Extent1, Extent2;
    local float OrgX, OrgY;
    local float Width, Height;

    // Push canvas state
    SavedOrigin.X = C.OrgX;
    SavedOrigin.Y = C.OrgY;
    SavedClip.X = C.ClipX;
    SavedClip.Y = C.ClipY;
    
    // Calc draw space
    CanvasLibrary.Static.ConstrainExtentsInPlace(C, AnchorMin, AnchorMax);
    Extent1.X = C.ClipX * AnchorMin.X;
    Extent1.Y = C.ClipY * AnchorMin.Y;
    Extent2.X = C.ClipX * AnchorMax.X;
    Extent2.Y = C.ClipY * AnchorMax.Y;

    OrgX = C.OrgX + C.ClipX * AnchorMin.X;
    OrgY = C.OrgY + C.ClipY * AnchorMin.Y;
    Width = Extent2.X - Extent1.X;
    Height = Extent2.Y - Extent1.Y;

	// Update instance vars -- these are used in collision checks
	WidgetExtentMin.X = OrgX;
	WidgetExtentMin.Y = Orgy;
	WidgetExtentMax.X = OrgX + Width;
	WidgetExtentMax.Y = OrgY + Height;
    
    // Draw Self and children
    C.SetOrigin(OrgX, OrgY);
    C.SetClip(Width, Height);
	C.Z = 100.0;
    
    DrawSelfAsBox(C);
	DrawChildren(C);
    
    // Restore canvas state
    C.SetClip(SavedClip.X, SavedClip.Y);
    C.SetOrigin(SavedOrigin.X, SavedOrigin.Y);
    
    //C.Font = C.SmallFont;
    //DrawTestString(C, -300.0);
    //
    //C.Font = C.MedFont;
    //DrawTestString(C, -200.0);
    //
    //C.Font = C.BigFont;
    //DrawTestString(C, -100.0);
    //
    //C.Font = C.LargeFont;
    //DrawTestString(C, 0.0);
    //
    //C.Font = C.RuneMedFont;
    //DrawTestString(C, 100.0);
    //
    //C.Font = C.CredsFont;
    //DrawTestString(C, 200.0);
    //
    //C.Font = C.ButtonFont;
    //DrawTestString(C, 300.0);
}

function DrawChildren(Canvas C)
{
	local R_ObjectList NodeIt;
	local Object ObjectIt;
	local R_UIWidget WidgetIt;

	NodeIt = ChildWidgets.Begin();
	while(ChildWidgets.Iterate(NodeIt, ObjectIt))
	{
		WidgetIt = R_UIWidget(ObjectIt);
		if(WidgetIt != None)
		{
			WidgetIt.DrawWidget(C);
		}
	}
}

function DrawSelfAsBox(Canvas C)
{
    local Vector Extent1, Extent2;
    
    Extent1.X = 0.0;
    Extent1.Y = 0.0;
    Extent2.X = 1.0 * C.ClipX;
    Extent2.Y = 1.0 * C.ClipY;
    
    //CanvasLibrary.Static.DrawBoxOutline(C, Extent1, Extent2, 4.0, ColorR, ColorG, ColorB, ColorA);
	CanvasLibrary.Static.DrawBoxSolid(C, Extent1, Extent2, ColorR, ColorG, ColorB, ColorA);
}

function DrawTestString(Canvas C, float YOffset)
{
    local float DrawX, DrawY;
    local float StrW, StrH;
    local String DrawString;
    
    DrawString = "My User Interface Is Working!!!!";
    C.SetColor(255.0, 255.0, 255.0);
    C.Style = 1;
    
    //C.Font = C.BigFont;
    C.StrLen(DrawString, StrW, StrH);
    DrawX = C.ClipX * 0.5 - StrW * 0.5;
    DrawY = C.ClipY * 0.5 - StrH * 0.5 + YOffset;
    C.SetPos(DrawX, DrawY);
    C.DrawText(DrawString);
}

function DrawTestBox(Canvas C)
{
    
}

/**
*	NotifyInputEvent
*	This is initially called at the root widget by the owning player, and it trickles down
*	through all child widgets
*	Returning true means that the event was handled by the returning widget, and should terminate any further calls
*
*	For the owning Player, 'true' tells them that the UI consumed the event, so don't send it to the game
*
*	For Widgets, 'true' tells them that some child widget consumed the event, so don't send it anywhere else
*
*	Events:
*		Event = 'CursorPosition' 	Payload = Cursor position
*		Event = 'MouseDown'			Payload = Cursor position
*		Event = 'MouseUp'			Payload = Cursor position
*/
final function bool NotifyInputEvent(Name Event, optional Vector Payload)
{
	if(Event == 'MouseDown')
	{
		return HandleMouseDownEvent(Payload);
	}
	if(Event == 'MouseUp')
	{
		return HandleMouseUpEvent(Payload);
	}
	if(Event == 'CursorPosition')
	{
		return HandleCursorPositionEvent(Payload);
	}

	return false;
}

/**
*	HandleMouseDownEvent
*	Prioritizes sending the event to all children first -- if any child handles the event
*	then the event is ignored by Self
*
*	Do not override this function -- override OnMouseDown
*/
final function bool HandleMouseDownEvent(Vector CursorPosition)
{
	local R_ObjectList Node;
	local Object ObjectIt;
	local R_UIWidget ChildIt;

	// Cursor must be over the widget
	if(!MathLibrary.Static.CheckBoundingBoxCollisionWithPoint(WidgetExtentMin, WidgetExtentMax, CursorPosition))
	{
		return false;
	}

	bWaitingMouseUp = true;

	// Try to pass the event to children first
	Node = ChildWidgets.Begin();
	while(ChildWidgets.Iterate(Node, ObjectIt))
	{
		ChildIt = R_UIWidget(ObjectIt);
		if(ChildIt != None && ChildIt.HandleMouseDownEvent(CursorPosition))
		{
			return true;
		}
	}

	// Let widgets respond to mouse down
	OnMouseDown();

	return false;
}

/**
*	HandleMouseUpEvent
*	Prioritizes sending the event to a all children first -- if any child handles the event
*	then the event is ignored
*
*	Do not override this function -- override OnMouseUp
*/
final function bool HandleMouseUpEvent(Vector CursorPosition)
{
	local R_ObjectList Node;
	local Object ObjectIt;
	local R_UIWidget ChildIt;

	// Always fire mouse up whether or not the cursor is over the widget
	if(bWaitingMouseUp)
	{
		OnMouseUp();
		bWaitingMouseUp = false;
	}

	// Try to pass the event to children
	Node = ChildWidgets.Begin();
	while(ChildWidgets.Iterate(Node, ObjectIt))
	{
		ChildIt = R_UIWidget(ObjectIt);
		if(ChildIt != None && ChildIt.HandleMouseUpEvent(CursorPosition))
		{
			return true;
		}
	}

	return false;
}

/**
*	HandleCursorPositionEvent
*	Prioritizes sending the event to a all children first -- if any child handles the event
*	then the event is ignored
*	Do not override this function -- override OnMouseMove
*/
final function bool HandleCursorPositionEvent(Vector CursorPosition)
{
	local R_ObjectList Node;
	local Object ObjectIt;
	local R_UIWidget ChildIt;
	local bool bNewHovered;

	// Try to pass the event to children first
	Node = ChildWidgets.Begin();
	while(ChildWidgets.Iterate(Node, ObjectIt))
	{
		ChildIt = R_UIWidget(ObjectIt);
		if(ChildIt != None && ChildIt.HandleCursorPositionEvent(CursorPosition))
		{
			// Never consume cursor position events
			//return true;
		}
	}

	bNewHovered = MathLibrary.Static.CheckBoundingBoxCollisionWithPoint(WidgetExtentMin, WidgetExtentMax, CursorPosition);

	// Check for mouse enter condition
	if(!bHovered && bNewHovered)
	{
		OnCursorEnter();
	}

	// Check for mouse leave condition
	if(bHovered && !bNewHovered)
	{
		OnCursorLeave();
	}
	
	bHovered = bNewHovered;

	return false;
}

//==============================================================================
//	Events
//
//	Your Widget classes should override and define these functions in order
//	to respond to them
//==============================================================================
function OnCursorEnter() 	{}
function OnCursorLeave() 	{}
function OnMouseDown()		{}
function OnMouseUp()		{}
//==============================================================================

defaultproperties
{
    AnchorMin=(X=0.25,Y=0.25)
    AnchorMax=(X=0.75,Y=0.75)
    ColorR=1.0
    ColorG=1.0
    ColorB=0.0
    ColorA=0.5
}