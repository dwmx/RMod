//==============================================================================
//	R_UI_ArpgWindow
//	Base class for UI windows in Arpg
//==============================================================================
class R_UI_ArpgWindow extends UWindowWindow;

const INVALID_INDEX = -1;

// QueryResult Consts
const QUERY_RESULT_INVALID = -1;
const QUERY_RESULT_CANNOT_PLACE = 0;
const QUERY_RESULT_CAN_PLACE = 1;
const QUERY_RESULT_CAN_SWAP = 2;

// ArpgWindowRegion
struct R_ArpgWindowRegion
{
	var float PositionX;
	var float PositionY;
	var float SizeX;
	var float SizeY;
};

const CanvasLib = Class'RBase.R_ACanvasLibrary';
const ArpgUILib = Class'RArpgUI.R_UI_ArpgLibrary';
const WhiteTexture = Texture'UWindow.WhiteTexture';

var private bool bMousePassThrough;

//------------------------------------------------------------------------------
//	ArpgWindowRegion
function R_ArpgWindowRegion ArpgWindowRegion(float PositionX, float PositionY, float SizeX, float SizeY)
{
	local R_ArpgWindowRegion W;
	W.PositionX = PositionX;
	W.PositionY = PositionY;
	W.SizeX = SizeX;
	W.SizeY = SizeY;
	return W;
}

function R_UI_ArpgRootWindow GetArpgRootWindow()
{
	return R_UI_ArpgRootWindow(Root);
}

function bool CheckMousePassThrough(float X, float Y)
{
	if(bMousePassThrough)
	{
		return true;
	}

	return Super.CheckMousePassThrough(X, Y);
}

function SetMousePassThrough(bool bNewMousePassThrough)
{
	bMousePassThrough = bNewMousePassThrough;
}

function Paint(Canvas C, float X, float Y)
{
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.Style = 1;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, WhiteTexture);
}

function PaintItem(Canvas C, float X, float Y, Vector Alignment, R_ArpgItem Item)
{
	local int ItemSizeX, ItemSizeY;
	local float CellSizeX, CellSizeY;
	local Texture DrawTexture;
	local float DrawX, DrawY, DrawW, DrawH;
	local float MaxDimension;
	local float ScaleFactor;

	if(Item == None)
	{
		return;
	}

	// Get the unit size of Item
	Item.GetItemGridSize(ItemSizeX, ItemSizeY);
	GetGridCellPixelSize(CellSizeX, CellSizeY);

	// Determine size from texture
	if(Item.GetItemUITexture(DrawTexture))
	{
		DrawW = DrawTexture.USize;
		DrawH = DrawTexture.VSize;
	}
	else
	{
		DrawTexture = WhiteTexture; // Could use a better invalid texture here
		DrawW = MaxDimension;
		DrawH = MaxDimension;
	}

	// Scale the texture down if necessary
	MaxDimension = FMin(ItemSizeX * CellSizeX, ItemSizeY * CellSizeY);
	ScaleFactor = FClamp(FMin(MaxDimension / DrawW, MaxDimension / DrawH), 0.0, 1.0);

	DrawW *= ScaleFactor;
	DrawH *= ScaleFactor;

	DrawX = X - DrawW * Alignment.X;
	DrawY = Y - DrawH * Alignment.Y;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.Style = 1;
	DrawStretchedTexture(C, DrawX, DrawY, DrawW, DrawH, DrawTexture);
}

function GetGridCellPixelSize(out float OutGridPixelSizeX, out float OutGridPixelSizeY)
{
	local R_UI_ArpgRootWindow LocalRootWindow;

	LocalRootWindow = GetArpgRootWindow();
	if(LocalRootWindow == None)
	{
		return;
	}

	LocalRootWindow.GetGridCellPixelSize(OutGridPixelSizeX, OutGridPixelSizeY);
}

defaultproperties
{
	bMousePassThrough=false
}