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
{}

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
		C.DrawColor.R = 25;
		C.DrawColor.G = 255;
		C.DrawColor.B = 25;
		C.Style = 1;
		DrawStretchedTexture(C, FloatingItemQueryRegion.PositionX, FloatingItemQueryRegion.PositionY, FloatingItemQueryRegion.SizeX, FloatingItemQueryRegion.SizeY, WhiteTexture);
		PaintItem(C, PositionX, PositionY, FloatingAlignment, FloatingItem);
	}
}

function PaintInspecting(Canvas C, float X, float Y)
{}

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