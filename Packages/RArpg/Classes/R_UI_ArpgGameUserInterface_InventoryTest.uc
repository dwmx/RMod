//==============================================================================
//	R_UI_ArpgGameUserInterface_InventoryTest
//	A test example of the ArpgUI implementing a basic inventory screen
//==============================================================================
class R_UI_ArpgGameUserInterface_InventoryTest extends R_UI_ArpgGameUserInterface;

const ArpgLib = Class'RArpgCore.R_ArpgLibrary';

// Data Objects
// These are only here for testing purposes
// In an actual game, these instances will exist on a Pawn most likely
var private R_ArpgItem Item, Item2, Item3;
var private R_ArpgItemGrid ItemGrid;
var private R_ArpgItemSlot ItemSlotMainHand;
var private R_ArpgItemSlot ItemSlotOffHand;
var private R_ArpgItemSlot ItemSlotArmor;
var private R_ArpgItemSlot ItemSlotHelm;
var private R_ArpgItemSlot ItemSlotFloat;

// UI Objects
// These are the UI counter-parts that point to Data objects and know how to
// draw and interact with them
var private R_UI_ArpgWindow UIInventoryWindow;
var private R_UI_ArpgItemGrid UIItemGrid;
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
	// Create and initialize the item data classes

	// Item Containers
	ItemGrid = R_ArpgItemGrid(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItemGrid', Self));
	ItemGrid.SetGridSize(12, 4);

	ItemSlotMainHand = R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItemSlot', Self));
	ItemSlotOffHand = R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItemSlot', Self));
	ItemSlotArmor = R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItemSlot', Self));
	ItemSlotHelm = R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItemSlot', Self));

	ItemSlotFloat = R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItemSlot', Self));
	
	// Items
	Item = R_ArpgItem(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItem', Self));
	Item.SetItemGridSize(2,2);
	Item.SetItemUITexture(Texture'RuneFX2.ssword1b');

	Item2 = R_ArpgItem(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItem', Self));
	Item2.SetItemGridSize(2,2);
	Item2.SetItemUITexture(Texture'RuneFX2.ssword1b');

	Item3 = R_ArpgItem(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItem', Self));
	Item3.SetItemGridSize(2,2);
	Item3.SetItemUITexture(Texture'RuneFX2.ssword1b');

	// Place each item in a container
	ItemSlotFloat.AddItem(Item);
	ItemGrid.AddItem(Item2);
	ItemGrid.AddItem(Item3);

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
	H = RootH * 0.7;
	X = RootX + RootW * 0.5 - W * 0.5;
	Y = RootY + RootH * 0.5 - H * 0.5;
	UIInventoryWindow = R_UI_ArpgWindow(CreateWindow(Class'RArpgUI.R_UI_ArpgWindow', X, Y, W, H));
	OldX = X;
	OldY = Y;
	OldW = W;
	OldH = H;

	// Item Grid
	LocalArpgRootWindow.GetGridPixelDimensions(12, 4, W, H);
	//X = OldW * 0.5 - W * 0.5;
	//Y = OldH * 0.5 - H * 0.5;
	X = OldW * 0.5 - W * 0.5;
	Y = OldH - H - 32.0;
	UIItemGrid = R_UI_ArpgItemGrid(UIInventoryWindow.CreateWindow(Class'R_UI_ArpgItemGrid', X, Y, W, H));
	UIItemGrid.SetItemGrid(ItemGrid);

	// Main Hand
	LocalArpgRootWindow.GetGridPixelDimensions(2, 4, W, H);
	X = UIItemGrid.WinLeft + 64.0;
	Y = OldH * 0.5 - H * 0.5;
	UIItemSlotMainHand = R_UI_ArpgItemSlot(UIInventoryWindow.CreateWindow(Class'R_UI_ArpgItemSlot', X, Y, W, H));
	UIItemSlotMainHand.SetItemSlot(ItemSlotMainHand);

	// Off Hand
	LocalArpgRootWindow.GetGridPixelDimensions(2, 4, W, H);
	X = UIItemGrid.WinLeft + UIItemGrid.WinWidth - W - 64.0;
	Y = OldH * 0.5 - H * 0.5;
	UIItemSlotOffHand = R_UI_ArpgItemSlot(UIInventoryWindow.CreateWindow(Class'R_UI_ArpgItemSlot', X, Y, W, H));
	UIItemSlotOffHand.SetItemSlot(ItemSlotOffHand);

	// Armor
	LocalArpgRootWindow.GetGridPixelDimensions(2, 3, W, H);
	X = UIInventoryWindow.WinWidth * 0.5 - W * 0.5;
	Y = UIItemSlotMainHand.WinTop + UIItemSlotMainHand.WinHeight - H;
	UIItemSlotArmor = R_UI_ArpgItemSlot(UIInventoryWindow.CreateWindow(Class'R_UI_ArpgItemSlot', X, Y, W, H));
	UIItemSlotArmor.SetItemSlot(ItemSlotArmor);

	// Helm
	LocalArpgRootWindow.GetGridPixelDimensions(2, 2, W, H);
	X = UIInventoryWindow.WinWidth * 0.5 - W * 0.5;
	Y = UIItemSlotArmor.WinTop - H - 32.0;
	UIItemSlotHelm = R_UI_ArpgItemSlot(UIInventoryWindow.CreateWindow(Class'R_UI_ArpgItemSlot', X, Y, W, H));
	UIItemSlotHelm.SetItemSlot(ItemSlotHelm);

	// ItemInteractor
	X = LocalRootWindow.WinLeft;
	Y = LocalRootWindow.WinTop;
	W = LocalRootWindow.WinWidth;
	H = LocalRootWindow.WinHeight;
	UIItemInteractor = R_UI_ArpgItemInteractor(CreateWindow(Class'RArpgUI.R_UI_ArpgItemInteractor', X, Y, W, H));
	UIItemInteractor.bAlwaysOnTop = true;
	UIItemInteractor.SetMousePassThrough(true);
	UIItemInteractor.SetFloatingItemSlot(ItemSlotFloat);

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