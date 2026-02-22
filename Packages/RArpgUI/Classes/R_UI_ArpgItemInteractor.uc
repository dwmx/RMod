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

		FloatingItemContainerWindow.WindowToGlobal(SwapItemQueryRegion.PositionX,SwapItemQueryRegion.PositionY, GlobalX, GlobalY);
		GlobalToWindow(GlobalX, GlobalY, SwapItemQueryRegion.PositionX, SwapItemQueryRegion.PositionY);
	}
}

function bool GetHoveredItemAndContainerWindow(
	out R_ArpgItem OutItem,
	out R_UI_ArpgItemContainer OutItemContainerWindow)
{
	local float GlobalX, GlobalY;
	local float WindowX, WindowY;
	local R_UI_ArpgItemContainer HoveredItemContainerWindow;
	local R_ArpgItem HoveredItem;

	OutItem = None;
	OutItemContainerWindow = None;

	WindowToGlobal(PositionX, PositionY, GlobalX, GlobalY);
	HoveredItemContainerWindow = R_UI_ArpgItemContainer(ArpgUILib.Static.FindWindowUnderPoint(Root, GlobalX, GlobalY));
	if(HoveredItemContainerWindow == None)
	{
		return false;
	}

	HoveredItemContainerWindow.GlobalToWindow(GlobalX, GlobalY, WindowX, WindowY);
	if(HoveredItemContainerWindow.QueryItemAtLocation(WindowX, WindowY, HoveredItem))
	{
		OutItem = HoveredItem;
		OutItemContainerWindow = HoveredItemContainerWindow;
		return true;
	}

	return false;
}

function TickInspecting(float DeltaSeconds)
{
	local R_ArpgItem HoveredItem;
	local R_UI_ArpgItemContainer HoveredItemContainerWindow;

	if(GetHoveredItemAndContainerWindow(HoveredItem, HoveredItemContainerWindow))
	{
		InspectedItem = HoveredItem;
	}
	else
	{
		InspectedItem = None;
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
		{	// Cannot place -- Draw a red region
			C.DrawColor.R = 255;
			C.DrawColor.G = 25;
			C.DrawColor.B = 25;
			C.Style = 5;
			C.AlphaScale = 0.35;
			DrawStretchedTexture(
				C,
				FloatingItemQueryRegion.PositionX, FloatingItemQueryRegion.PositionY,
				FloatingItemQueryRegion.SizeX, FloatingItemQueryRegion.SizeY,
				WhiteTexture);
		}
		else if(FloatingQueryResult == QUERY_RESULT_CAN_PLACE)
		{	// Can place -- Draw a green region
			C.DrawColor.R = 25;
			C.DrawColor.G = 255;
			C.DrawColor.B = 25;
			C.Style = 5;
			C.AlphaScale = 0.35;
			DrawStretchedTexture(
				C,
				FloatingItemQueryRegion.PositionX, FloatingItemQueryRegion.PositionY,
				FloatingItemQueryRegion.SizeX, FloatingItemQueryRegion.SizeY,
				WhiteTexture);
		}
		if(FloatingQueryResult == QUERY_RESULT_CAN_SWAP)
		{	// Can swap -- Draw grey region on the swap item and faint green floating region
			C.DrawColor.R = 180;
			C.DrawColor.G = 180;
			C.DrawColor.B = 180;
			C.Style = 5;
			C.AlphaScale = 0.65;
			DrawStretchedTexture(
				C,
				SwapItemQueryRegion.PositionX, SwapItemQueryRegion.PositionY,
				SwapItemQueryRegion.SizeX, SwapItemQueryRegion.SizeY,
				WhiteTexture);
			
			C.DrawColor.R = 25;
			C.DrawColor.G = 255;
			C.DrawColor.B = 25;
			C.Style = 5;
			C.AlphaScale = 0.35;
			DrawStretchedTexture(
				C,
				FloatingItemQueryRegion.PositionX, FloatingItemQueryRegion.PositionY,
				FloatingItemQueryRegion.SizeX, FloatingItemQueryRegion.SizeY,
				WhiteTexture);
		}
		
		// Paint floating item
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
	local float BorderThickness;
	local float DrawX, DrawY;
	local String DrawString;
	local float StrW, StrH;

	C.Style = 5;
	C.AlphaScale = 0.85;

	// Draw backdrop
	C.DrawColor.R = 32.0;
	C.DrawColor.G = 32.0;
	C.DrawColor.B = 32.0;
	DrawStretchedTexture(C, PanelX, PanelY, PanelW, PanelH, WhiteTexture);

	// Draw border
	BorderThickness = 2.0;
	C.DrawColor.R = 180.0;
	C.DrawColor.G = 180.0;
	C.DrawColor.B = 180.0;
	C.Style = 1;

	DrawStretchedTexture(C, PanelX, PanelY, PanelW, BorderThickness, WhiteTexture);	// Top
	DrawStretchedTexture(C, PanelX, PanelY + PanelH - BorderThickness, PanelW, BorderThickness, WhiteTexture); // Bottom
	DrawStretchedTexture(C, PanelX, PanelY + BorderThickness, BorderThickness, PanelH - BorderThickness, WhiteTexture); // Left
	DrawStretchedTexture(C, PanelX + PanelW - BorderThickness, PanelY + BorderThickness, BorderThickness, PanelH - BorderThickness, WhiteTexture); // Right

	//--------------------------------------------------------------------------
	//	Prepare for drawing text
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.Style = 1;

	DrawY = PanelY + BorderThickness + 16.0;

	// Draw Item name
	C.Font = C.CredsFont;
	DrawString = "Item Name";
	C.StrLen(DrawString, StrW, StrH);
	DrawX = PanelX + PanelW * 0.5 - StrW * 0.5;
	C.SetPos(DrawX, DrawY);
	C.DrawText(DrawString);
}

//------------------------------------------------------------------------------

function LMouseDown(float X, float Y)
{
	local R_ArpgItem LocalFloatingItem;
	local float GlobalX, GlobalY, WindowX, WindowY;

	if(FloatingItemSlot != None && FloatingItemSlot.GetItem(0, LocalFloatingItem))
	{
		TryPlaceFloatingItem();
	}
	else
	{
		TryPickUpItem();
	}
}

// Attempts to the current floating item, and will perform swap if necessary
function bool TryPlaceFloatingItem()
{
	local R_ArpgItem LocalFloatingItem;
	local R_ArpgItem LocalSwapItem;
	local float GlobalX, GlobalY;
	local float WindowX, WindowY;

	if(FloatingItemContainerWindow == None)
	{
		return false;
	}

	FloatingItemSlot.GetItem(0, LocalFloatingItem);
	if(LocalFloatingItem == None)
	{
		return false;
	}

	LocalSwapItem = None;
	if(SwapItem != None)
	{
		LocalSwapItem = SwapItem;
	}

	if(LocalSwapItem != None && !FloatingItemContainerWindow.RemoveItem(LocalSwapItem))
	{	// Failed to remove the swap item from its container
		return false;
	}

	SwapItem = None;

	WindowToGlobal(PositionX, PositionY, GlobalX, GlobalY);
	FloatingItemContainerWindow.GlobalToWindow(GlobalX, GlobalY, WindowX, WindowY);
	if(!FloatingItemContainerWindow.TryPlaceFloatingItem(LocalFloatingItem, WindowX, WindowY, FloatingAlignment))
	{	// Only issue here is that now the swap item will be removed
		return false;
	}

	FloatingItemSlot.RemoveItem(FloatingItem);
	FloatingItem = None;
	if(LocalSwapItem != None)
	{
		FloatingItemSlot.AddItem(LocalSwapItem);
	}

	FloatingItem = None;
	SwapItem = None;

	return true;
}

function bool TryPickUpItem()
{
	local R_ArpgItem HoveredItem;
	local R_UI_ArpgItemContainer HoveredItemContainerWindow;

	if(FloatingItemSlot == None || !FloatingItemSlot.IsEmpty())
	{
		return false;
	}

	if(GetHoveredItemAndContainerWindow(HoveredItem, HoveredItemContainerWindow))
	{
		if(HoveredItemContainerWindow.RemoveItem(HoveredItem))
		{
			FloatingItemSlot.AddItem(HoveredItem);
			return true;
		}
	}

	return false;
}

defaultproperties
{
	FloatingAlignment=(X=0.5,Y=0.5)
}