//==============================================================================
//	R_ArpgItemInteractor
//==============================================================================
class R_UI_ArpgItemInteractor extends R_UI_ArpgWindow;

var private R_ArpgItemSlot FloatingItemSlot;
var private float PositionX, PositionY;

const STATE_INSPECTING = 'Inspecting';	// Inspecting items
const STATE_FLOATING = 'Floating';		// Moving a floating item
var Name InteractorState;

var private R_ArpgItem FloatingItem;
var private Vector FloatingAlignment;
var private R_UI_ArpgItemContainer FloatingItemContainerWindow;
var private R_ArpgWindowRegion FloatingItemQueryRegion;
var private int FloatingQueryResult;
var private R_ArpgWindowRegion SwapItemQueryRegion;
var private R_ArpgItem SwapItem;

var private R_ArpgItem InspectedItem;

//------------------------------------------------------------------------------

function SetFloatingItemSlot(R_ArpgItemSlot NewFloatingItemSlot)
{
	FloatingItemSlot = NewFloatingItemSlot;
}

//------------------------------------------------------------------------------

function Tick(float DeltaSeconds)
{
	if(Root != None)
	{
		GlobalToWindow(Root.MouseX, Root.MouseY, PositionX, PositionY);
	}

	UpdateInteractorState();

	switch(InteractorState)
	{
	case STATE_FLOATING:
		TickFloating(DeltaSeconds);
		break;
	case STATE_INSPECTING:
	default:
		TickInspecting(DeltaSeconds);
		break;
	}
}

function UpdateInteractorState()
{
	local R_ArpgItem NewFloatingItem;

	FloatingItem = None;
	if(FloatingItemSlot != None)
	{
		if(FloatingItemSlot.GetItem(0, NewFloatingItem))
		{
			InteractorState = STATE_FLOATING;
			FloatingItem = NewFloatingItem;
			return;
		}
	}

	InteractorState = STATE_INSPECTING;
}

function TickFloating(float DeltaSeconds)
{
	local R_UI_ArpgItemContainer NewFloatingItemContainerWindow;
	local float GlobalX, GlobalY;
	local float WindowX, WindowY;

	if(FloatingItem == None)
	{
		return;
	}

	NewFloatingItemContainerWindow = R_UI_ArpgItemContainer(ArpgUILib.Static.FindWindowUnderPoint(Root, PositionX, PositionY));

	FloatingItemContainerWindow = NewFloatingItemContainerWindow;

	if(FloatingItemContainerWindow != None)
	{
		WindowToGlobal(PositionX, PositionY, GlobalX, GlobalY);
		FloatingItemContainerWindow.GlobalToWindow(GlobalX, GlobalY, WindowX, WindowY);

		FloatingItemContainerWindow.QueryPlaceFloatingItem(
			FloatingItem,
			WindowX, WindowY, FloatingAlignment,
			FloatingQueryResult,
			FloatingItemQueryRegion,
			SwapItem,
			SwapItemQueryRegion);
		
		FloatingItemContainerWindow.WindowToGlobal(FloatingItemQueryRegion.PositionX, FloatingItemQueryRegion.PositionY, GlobalX, GlobalY);
		GlobalToWindow(GlobalX, GlobalY, FloatingItemQueryRegion.PositionX, FloatingItemQueryRegion.PositionY);
	}
}

function TickInspecting(float DeltaSeconds)
{
	local R_UI_ArpgItemContainer NewFloatingItemContainerWindow;
	local R_ArpgItem NewInspectedItem;
	local float GlobalX, GlobalY;
	local float WindowX, WindowY;

	InspectedItem = None;

	WindowToGlobal(PositionX, PositionY, GlobalX, GlobalY);
	NewFloatingItemContainerWindow = R_UI_ArpgItemContainer(ArpgUILib.Static.FindWindowUnderPoint(Root, GlobalX, GlobalY));

	if(NewFloatingItemContainerWindow != None)
	{
		NewFloatingItemContainerWindow.GlobalToWindow(GlobalX, GlobalY, WindowX, WindowY);
		if(NewFloatingItemContainerWindow.QueryItemAtLocation(WindowX, WindowY, NewInspectedItem))
		{
			InspectedItem = NewInspectedItem;
		}
	}
}

//------------------------------------------------------------------------------

function Paint(Canvas C, float X, float Y)
{
	switch(InteractorState)
	{
	case STATE_FLOATING:
		PaintFloating(C, X, Y);
		break;
	case STATE_INSPECTING:
	default:
		PaintInspecting(C, X, Y);
		break;
	}
}

function PaintFloating(Canvas C, float X, float Y)
{
	if(FloatingItem != None)
	{
		if(FloatingQueryResult == QUERY_RESULT_CANNOT_PLACE)
		{
			C.DrawColor.R = 255;
			C.DrawColor.G = 25;
			C.DrawColor.B = 25;
		}
		else if(FloatingQueryResult == QUERY_RESULT_CAN_PLACE)
		{
			C.DrawColor.R = 25;
			C.DrawColor.G = 255;
			C.DrawColor.B = 25;
		}
		else if(FloatingQueryResult == QUERY_RESULT_CAN_SWAP)
		{
			C.DrawColor.R = 180;
			C.DrawColor.G = 180;
			C.DrawColor.B = 180;
		}
		C.Style = 5;
		C.AlphaScale = 0.5;

		DrawStretchedTexture(C, FloatingItemQueryRegion.PositionX, FloatingItemQueryRegion.PositionY, FloatingItemQueryRegion.SizeX, FloatingItemQueryRegion.SizeY, WhiteTexture);
		PaintItem(C, PositionX, PositionY, FloatingAlignment, FloatingItem);
	}
}

function PaintInspecting(Canvas C, float X, float Y)
{
	local float PanelX, PanelY, PanelW, PanelH;
	local Vector Alignment, Offset;

	if(InspectedItem != None)
	{
		Alignment = Vect(0.5,1.0,0.0);
		Offset = Vect(0.0,-32.0,0.0);

		PanelW = 512.0;
		PanelH = 512.0;
		PanelX = PositionX - PanelW * Alignment.X + Offset.X;
		PanelY = PositionY - PanelH * Alignment.Y + Offset.Y;

		PaintInspectedItemPanel(C, PanelX, PanelY, PanelW, PanelH, InspectedItem);
	}
}

function PaintInspectedItemPanel(Canvas C, float PanelX, float PanelY, float PanelW, float PanelH, R_ArpgItem Item)
{
	C.DrawColor.R = 32.0;
	C.DrawColor.G = 32.0;
	C.DrawColor.B = 32.0;
	C.Style = 1;
	DrawStretchedTexture(C, PanelX, PanelY, PanelW, PanelH, WhiteTexture);
}

//------------------------------------------------------------------------------

function LMouseDown(float X, float Y)
{
	local R_ArpgItem LocalFloatingItem;
	local float GlobalX, GlobalY, WindowX, WindowY;

	if(FloatingItemSlot != None && FloatingItemSlot.GetItem(0, LocalFloatingItem))
	{
		if(FloatingItemContainerWindow != None)
		{
			WindowToGlobal(PositionX, PositionY, GlobalX, GlobalY);
			FloatingItemContainerWindow.GlobalToWindow(GlobalX, GlobalY, WindowX, WindowY);
			if(FloatingItemContainerWindow.TryPlaceFloatingItem(LocalFloatingItem, WindowX, WindowY, FloatingAlignment))
			{
				FloatingItemSlot.RemoveItem(LocalFloatingItem);
			}
		}
	}
}

defaultproperties
{
	FloatingAlignment=(X=0.5,Y=0.5)
}