//==============================================================================
//	R_UI_ArpgGameUserInterface_InventoryTest
//	A test example of the ArpgUI implementing a basic inventory screen
//==============================================================================
class R_UI_ArpgGameUserInterface_InventoryTest extends R_UI_ArpgGameUserInterface;

const ArpgLib = Class'RArpgCore.R_ArpgLibrary';

// UI Objects
// These are the UI counter-parts that point to Data objects and know how to
// draw and interact with them
var private R_UI_ArpgWindow UIInventoryWindow;
var private R_UI_ArpgItemGrid UIPersonalInventory;
var private R_UI_ArpgItemSlot UIItemSlotMainHand;
var private R_UI_ArpgItemSlot UIItemSlotOffHand;
var private R_UI_ArpgItemSlot UIItemSlotArmor;
var private R_UI_ArpgItemSlot UIItemSlotHelm;
var private R_UI_ArpgItemInteractor UIItemInteractor;

//------------------------------------------------------------------------------

function ConstructUI()
{
	local UWindowRootWindow LocalRootWindow;
	local R_UI_ArpgRootWindow LocalArpgRootWindow;
	local float RootX, RootY, RootW, RootH;
	local float OldX, OldY, OldW, OldH;
	local float X, Y, W, H;

	//--------------------------------------------------------------------------
	// Build the UI
	LocalRootWindow = GetRootWindow();
	LocalArpgRootWindow = R_UI_ArpgRootWindow(LocalRootWindow);
	RootX = LocalRootWindow.WinLeft;
	RootY = LocalRootWindow.WinTop;
	RootW = LocalRootWindow.WinWidth;
	RootH = LocalRootWindow.WinHeight;

	// Main Inventory window
	W = RootW * 0.4;
	H = RootH * 0.85;

	X = RootX + RootW - W - 32.0;
	//X = RootX + RootW * 0.5 - W * 0.5;
	Y = RootY + RootH * 0.5 - H * 0.5;
	UIInventoryWindow = R_UI_ArpgWindow(CreateWindow(Class'RArpgUI.R_UI_ArpgWindow', X, Y, W, H));
	OldX = X;
	OldY = Y;
	OldW = W;
	OldH = H;

	// Item Grid
	LocalArpgRootWindow.GetGridPixelDimensions(12, 4, W, H);
	X = OldW * 0.5 - W * 0.5;
	Y = OldH - H - 32.0;
	UIPersonalInventory = R_UI_ArpgItemGrid(UIInventoryWindow.CreateWindow(Class'R_UI_ArpgItemGrid', X, Y, W, H));

	// Main Hand
	LocalArpgRootWindow.GetGridPixelDimensions(2, 4, W, H);
	X = UIPersonalInventory.WinLeft + 64.0;
	Y = OldH * 0.5 - H * 0.5;
	UIItemSlotMainHand = R_UI_ArpgItemSlot(UIInventoryWindow.CreateWindow(Class'R_UI_ArpgItemSlot', X, Y, W, H));

	// Off Hand
	LocalArpgRootWindow.GetGridPixelDimensions(2, 4, W, H);
	X = UIPersonalInventory.WinLeft + UIPersonalInventory.WinWidth - W - 64.0;
	Y = OldH * 0.5 - H * 0.5;
	UIItemSlotOffHand = R_UI_ArpgItemSlot(UIInventoryWindow.CreateWindow(Class'R_UI_ArpgItemSlot', X, Y, W, H));

	// Armor
	LocalArpgRootWindow.GetGridPixelDimensions(2, 3, W, H);
	X = UIInventoryWindow.WinWidth * 0.5 - W * 0.5;
	Y = UIItemSlotMainHand.WinTop + UIItemSlotMainHand.WinHeight - H;
	UIItemSlotArmor = R_UI_ArpgItemSlot(UIInventoryWindow.CreateWindow(Class'R_UI_ArpgItemSlot', X, Y, W, H));

	// Helm
	LocalArpgRootWindow.GetGridPixelDimensions(2, 2, W, H);
	X = UIInventoryWindow.WinWidth * 0.5 - W * 0.5;
	Y = UIItemSlotArmor.WinTop - H - 32.0;
	UIItemSlotHelm = R_UI_ArpgItemSlot(UIInventoryWindow.CreateWindow(Class'R_UI_ArpgItemSlot', X, Y, W, H));

	// ItemInteractor
	X = LocalRootWindow.WinLeft;
	Y = LocalRootWindow.WinTop;
	W = LocalRootWindow.WinWidth;
	H = LocalRootWindow.WinHeight;
	UIItemInteractor = R_UI_ArpgItemInteractor(CreateWindow(Class'RArpgUI.R_UI_ArpgItemInteractor', X, Y, W, H));
	UIItemInteractor.bAlwaysOnTop = true;
	UIItemInteractor.SetMousePassThrough(true);

	// Tell the root window to route mouse input to the ItemInteractor
	R_UI_ArpgRootWindow(LocalRootWindow).SetMouseEventWindow(UIItemInteractor);
}

function HandleCommand_Inventory()
{
	if(UIInventoryWindow.WindowIsVisible())
	{
		UIInventoryWindow.HideWindow();
	}
	else
	{
		UIInventoryWindow.ShowWindow();
	}
}

function bool IsWindowVisible(Name WindowName)
{
	if(WindowName == 'Inventory')
	{
		return UIInventoryWindow.WindowIsVisible();
	}
}

function SetItemContainerSet(R_ArpgItemContainerSet NewItemContainerSet)
{
	// Clear all UIItemContainers
	UIPersonalInventory.SetItemGrid(None);
	UIItemSlotMainHand.SetItemSlot(None);
	UIItemSlotOffHand.SetItemSlot(None);
	UIItemSlotArmor.SetItemSlot(None);
	UIItemSlotHelm.SetItemSlot(None);
	UIItemInteractor.SetFloatingItemSlot(None);

	if(NewItemContainerSet != None)
	{
		UIPersonalInventory.SetItemGrid(R_ArpgItemGrid(NewItemContainerSet.GetItemContainer('PersonalInventory')));
		UIItemSlotMainHand.SetItemSlot(R_ArpgItemSlot(NewItemContainerSet.GetItemContainer('MainHand')));
		UIItemSlotOffHand.SetItemSlot(R_ArpgItemSlot(NewItemContainerSet.GetItemContainer('OffHand')));
		UIItemSlotArmor.SetItemSlot(R_ArpgItemSlot(NewItemContainerSet.GetItemContainer('Armor')));
		UIItemSlotHelm.SetItemSlot(R_ArpgItemSlot(NewItemContainerSet.GetItemContainer('Helm')));
		UIItemInteractor.SetFloatingItemSlot(R_ArpgItemSlot(NewItemContainerSet.GetItemContainer('Float')));
	}
}