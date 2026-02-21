class R_UI_Inventory extends R_UI_DialogClientWindow;

var private R_UI_EquipmentSlot WeaponSlot;
var private R_UI_Item InventoryItem;

function Created()
{
	Super.Created();

	WeaponSlot = R_UI_EquipmentSlot(CreateWindow(Class'RArpg.R_UI_EquipmentSlot', 64, 64, 96, 192));
	InventoryItem = R_UI_Item(CreateWindow(Class'RArpg.R_UI_Item', 0, 0, 128, 128));
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float CenterX, CenterY;

	CenterX = (ParentWindow.WinWidth - ParentWindow.WinLeft) * 0.75;
	CenterY = (ParentWindow.WinHeight - ParentWindow.WinTop) * 0.5;

	WinHeight = 768.0;
	WinWidth = 768.0;

	WinLeft = CenterX - WinWidth * 0.5;
	WinTop = CenterY - WinHeight * 0.5;

	ClippingRegion.X = Root.ClippingRegion.X;
	ClippingRegion.Y = Root.ClippingRegion.Y;
	ClippingRegion.W = Root.ClippingRegion.W;
	ClippingRegion.H = Root.ClippingRegion.H;

	//WinLeft = ParentWindow.WinWidth * 0.5;
	////Log(WinLeft);
	//WinTop = 0;
	//WinWidth = 512;
	//WinHeight = 512;

	Super.BeforePaint(C, X, Y);
}

function Paint(Canvas C, float X, float Y)
{
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.Style = 1;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, WhiteTexture);
}