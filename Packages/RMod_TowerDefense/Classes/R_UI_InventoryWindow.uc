class R_UI_InventoryWindow extends UWindowDialogClientWindow;

const MathLibrary = Class'RBase.R_AMathLibrary';

var R_UI_InventoryItem ActiveUIItem;

var Texture TestItemTexture;
var int ActiveX, ActiveY;
var int ActiveX1, ActiveY1;

var Vector DebugP0, DebugP1, DebugMouse;

var R_UI_InventoryItem UIInventoryItem;

/*

X = FClamp(X, 0.0, FullWidth);
Y = FClamp(Y, 0.0, FullHeight);

ActiveX = int(X / CellWidth);
ActiveY = int(Y / CellHeight);

*/

function GetGridCellAreaFromLocation(
	Vector Location,
	Vector Alignment,
	int GridUnitSize,
	int CellCountX, int CellCountY,
	out int OutX0, out int OutX1,
	out int OutY0, out int OutY1)
{
	local Vector P0, P1;
	local float AreaWidth, AreaHeight;

	CellCountX = Max(1, CellCountX);
	CellCountY = Max(1, CellCountY);

	AreaWidth = GridUnitSize * (CellCountX - 1);
	AreaHeight = GridUnitSize * (CellCountY - 1);

	P0.X = Location.X - Alignment.X * AreaWidth;
	P0.Y = Location.Y - Alignment.Y * AreaHeight;

	//P1.X = Location.X + (1.0 - Alignment.X) * AreaWidth;
	//P1.Y = Location.Y + (1.0 - Alignment.Y) * AreaHeight;

	P0.X = Max(0.0, P0.X);
	P0.Y = Max(0.0, P0.Y);

	OutX0 = int(P0.X / GridUnitSize);
	OutX1 = OutX0 + CellCountX;
	//OutX1 = MathLibrary.Static.Ceil(P1.X / GridUnitSize);
	OutY0 = int(P0.Y / GridUnitSize);
	OutY1 = OutY0 + CellCountY;
	//OutY1 = MathLibrary.Static.Ceil(P1.Y / GridUnitSize);

	DebugP0 = P0;
	DebugP1 = P1;
	DebugMouse = Location;
}

function Click(float X, float Y)
{
	local Vector MouseLocation;
	local int X0, X1, Y0, Y1;

	MouseLocation.X = X;
	MouseLocation.Y = Y;
	GetGridCellAreaFromLocation(MouseLocation, Vect(0.5,0.5,0.0), 48, 2, 3, X0, X1, Y0, Y1);

	if(ActiveUIItem != None)
	{
		ActiveUIItem.Position.X = X0 * 48;
		ActiveUIItem.Position.Y = Y0 * 48;
		ActiveUIItem.bTrackMouse = false;
		ActiveUIItem = None;
	}

	//Super.LMouseDown(X, Y);
	//Log("CLICK ON THE INVENTORY WINDOW");
}

function PlaceInventoryAt(int GridCellX, int GridCellY)
{

}

function Created()
{
	//local R_MyButton CreatedButton;
	local R_UI_InventoryItem InventoryItem;
	local R_UI_InventoryItem InventoryItem2;

	Super.Created();

	// Add a test inventory item
	//InventoryItem = R_UI_InventoryItem(CreateControl(Class'R_UI_InventoryItem', 0.0, 0.0, 128.0, 128.0));

	InventoryItem2 = R_UI_InventoryItem(CreateControl(Class'R_UI_InventoryItem', 0, 0, 128, 128));
	
	InventoryItem2 = R_UI_InventoryItem(CreateControl(Class'R_UI_InventoryItem', 0, 0, 128, 128));
	InventoryItem2.Position.X = 48 * 4;

	InventoryItem2 = R_UI_InventoryItem(CreateControl(Class'R_UI_InventoryItem', 0, 0, 128, 128));
	InventoryItem2.Position.X = 48 * 8;
	InventoryItem2.Position.Y = 48 * 1;
	//InventoryItem2.bTrackMouse = true;

	ActiveUIItem = None;
	//UIInventoryItem = InventoryItem2;
	/*
	// Button 1
	CreatedButton = R_MyButton(CreateControl(class'R_MyButton', 0, 0, 180, 40));
	CreatedButton.Text = "Dwarf Mech Tower";
	CreatedButton.SetHelpText("ExampleButton");
	CreatedButton.WinLeft = 10;
	CreatedButton.WinTop = 10;
	CreatedButton.OverSound = Sound'RMenu.LeftMouseOver';
	CreatedButton.DownSound = Sound'RMenu.LeftButton';
	CreatedButton.BuildableIndex = 0;

	CreatedButton = R_MyButton(CreateControl(class'R_MyButton', 0, 0, 180, 40));
	CreatedButton.Text = "Tree One Tower";
	CreatedButton.SetHelpText("ExampleButton");
	CreatedButton.WinLeft = 10;
	CreatedButton.WinTop = 70;
	CreatedButton.OverSound = Sound'RMenu.LeftMouseOver';
	CreatedButton.DownSound = Sound'RMenu.LeftButton';
	CreatedButton.BuildableIndex = 1;
	*/
}

event Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);
}

event Paint(Canvas C, float X, float Y)
{
	WinWidth = Root.WinWidth;
	WinHeight = Root.WinHeight;
	ClippingRegion.X = Root.ClippingRegion.X;
	ClippingRegion.Y = Root.ClippingRegion.Y;
	ClippingRegion.W = Root.ClippingRegion.W;
	ClippingRegion.H = Root.ClippingRegion.H;
	//DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'UWindow.WhiteTexture');
	//DrawStretchedTextureModded(C, 0, 0, WinWidth, WinHeight, Texture'UWindow.WhiteTexture');
	//ExampleButton.Paint(C, X, Y);
	//PaintClients(C, X, Y);

	PaintInventoryGrid(C, X, Y);
	PaintDebug(C, X, Y);
}

function PaintDebug(Canvas C, float X, float Y)
{
	local float DebugLineHeight;
	local float DebugLineWidth;

	C.DrawColor.R = 255;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	DebugLineWidth = FMax(DebugP1.X - DebugP0.X, 3.0);
	DebugLineHeight = FMax(DebugP1.Y - DebugP0.Y, 3.0);
	DrawLittlePoint(C, DebugP0.X, DebugP0.Y);
	DrawLittlePoint(C, DebugP1.X, DebugP0.Y);
	//DrawStretchedTexture(C, DebugP0.X, DebugP0.Y, DebugLineWidth, DebugLineHeight, Texture'UWindow.WhiteTexture');
}

function DrawLittlePoint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, X - 4, Y - 4, 8, 8, Texture'UWindow.WhiteTexture');
}

function PaintInventoryGrid(Canvas C, float X, float Y)
{
	local float FullWidth, FullHeight;
	local float CellWidth, CellHeight;
	local int GridXCount, GridYCount;
	local int GridX, GridY;
	local Color SavedColor;
	local Byte SavedStyle;
	local int actx, acty;

	FullWidth = 768.0;
	FullHeight = 192.0;

	GridXCount = 16;
	GridYCount = 4;

	CellWidth = FullWidth / GridXCount;
	CellHeight = FullHeight / GridYCount;

	SavedStyle = C.Style;
	C.Style = 2;

	// Draw backdrop
	SavedColor = C.DrawColor;
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	DrawStretchedTexture(C, 0.0, 0.0, FullWidth, FullHeight, Texture'UWindow.WhiteTexture');
	C.DrawColor = SavedColor;

	for(GridX = 0; GridX <= GridXCount; ++GridX)
	{
		DrawStretchedTexture(C, GridX * CellWidth - 2.0, 0.0, 4.0, FullHeight, Texture'UWindow.WhiteTexture');
		/*
		for(GridY = 0; GridY < GridYCount; ++GridY)
		{
			DrawStretchedTexture(C, GridX * CellWidth, GridY * CellHeight, )
		}
			*/
	}

	for(GridY = 0; GridY <= GridYCount; ++GridY)
	{
		DrawStretchedTexture(C, 0.0, 0.0 + GridY * CellHeight - 2.0, FullWidth, 4.0, Texture'UWindow.WhiteTexture');
	}

	if(ActiveUIItem != None)
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 255;
		C.DrawColor.B = 0;
		for(actx = ActiveX; actx < ActiveX1; ++actx)
		{
			for(acty = ActiveY; acty < ActiveY1; ++acty)
			{
				DrawStretchedTexture(C, 0.0 + actx * CellWidth, 0.0 + acty * CellHeight, CellWidth - 2.0, CellHeight - 2.0, Texture'UWindow.WhiteTexture');
			}
		}
	}
	
	
	/*
	// Draw a 3x3 section of green cells
	C.DrawColor.R = 0;
	C.DrawColor.G = 255;
	C.DrawColor.B = 0;
	for(GridX = 0; GridX < 3; ++GridX)
	{
		for(GridY = 0; GridY < 3; ++GridY)
		{
			DrawStretchedTexture(C, 0.0 + GridX * CellWidth, 128.0 + GridY * CellHeight, CellWidth - 2.0, CellHeight - 2.0, Texture'UWindow.WhiteTexture');
		}
	}
		*/


	////DrawStretchedTexture(C, 0.0, 128.0, 128.0, 128.0, TestItemTexture);
	//C.SetPos(8.0, 128.0);
	//C.DrawIcon(TestItemTexture, 1.0);
	//C.Style = SavedStyle;

	/*
	for(i = 0; i < 10; ++i)
	{
		DrawStretchedTexture(C, i * 10.0, 0.0, 4.0, 128.0, Texture'UWindow.WhiteTexture');
	}
		*/
	//Log("PaintInventoryGrid: " $ X @ Y);
}

function MouseMove(float X, float Y)
{
	local Vector MouseLoc;
	local int X0, X1, Y0, Y1;

	MouseLoc.X = X;
	MouseLoc.Y = Y;
	GetGridCellAreaFromLocation(MouseLoc, Vect(0.5,0.5,0.0), 48, 2, 3, X0, X1, Y0, Y1);

	ActiveX = X0;
	ActiveY = Y0;
	ActiveX1 = X1;
	ActiveY1 = Y1;

	/*
	local float FullWidth, FullHeight;
	local float CellWidth, CellHeight;
	local int GridXCount, GridYCount;
	local int GridX, GridY;

	Super.MouseMove(X, Y);

	FullWidth = 768.0;
	FullHeight = 192.0;

	GridXCount = 16;
	GridYCount = 4;

	CellWidth = FullWidth / GridXCount;
	CellHeight = FullHeight / GridYCount;

	X = FClamp(X, 0.0, FullWidth);
	Y = FClamp(Y, 0.0, FullHeight);

	ActiveX = int(X / CellWidth);
	ActiveY = int(Y / CellHeight);

	//DrawStretchedTexture(C, 0.0 + GridX * CellWidth, 128.0 + GridY * CellHeight, CellWidth - 2.0, CellHeight - 2.0, Texture'UWindow.WhiteTexture');
	*/
}

defaultproperties
{
	TestItemTexture=Texture'Spells.uidba'
	//TestItemTexture=Texture'RuneFX2.WordBalloon'
}