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

function bool CheckConsumeMouseEvent(WinMessage Msg)
{
	return true;
}

function bool CheckMousePassThrough(float X, float Y)
{
	if(bMousePassThrough)
	{
		return true;
	}

	return Super.CheckMousePassThrough(X, Y);
}

function bool TryHandleLMouseDown();
function bool TryHandleLMouseUp();

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
	local int ItemGridSizeX, ItemGridSizeY;
	local float GridCellPixelSizeX, GridCellPixelSizeY;
	local float ScaleFactor;
	local Texture DrawTexture;
	local float TexX, TexY;
	local float TexW, TexH;
	local float DrawX, DrawY;
	local float DrawW, DrawH;

	// Get the unit size of Item
	Item.GetItemGridSize(ItemGridSizeX, ItemGridSizeY);
	GetGridCellPixelSize(GridCellPixelSizeX, GridCellPixelSizeY);

	// Retrieve the texture info for the item
	if(!GetItemUITextureInfo(Item, DrawTexture, TexX, TexY, TexW, TexH))
	{
		// Failed to retrieve UI Texture info for the item, use defaults
		DrawTexture = WhiteTexture;
		DrawX = 0.0;
		DrawY = 0.0;
		DrawW = DrawTexture.USize;
		DrawH = DrawTexture.VSize;
	}

	DrawW = TexW;
	DrawH = TexH;

	ScaleFactor = 1.0;
	ScaleFactor = FMin(ScaleFactor, FClamp((GridCellPixelSizeX * ItemGridSizeX) / DrawW, 0.0, 1.0));
	ScaleFactor = FMin(ScaleFactor, FClamp((GridCellPixelSizeY * ItemGridSizeY) / DrawH, 0.0, 1.0));

	DrawW *= ScaleFactor;
	DrawH *= ScaleFactor;

	DrawX = X - DrawW * Alignment.X;
	DrawY = Y - DrawH * Alignment.Y;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.Style = 1;

	DrawStretchedTextureSegment(
		C,
		DrawX, DrawY, DrawW, DrawH,
		TexX, TexY, TexW, TexH,
		DrawTexture);
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

function bool GetItemUITextureInfo(
	R_ArpgItem Item,
	out Texture OutDrawTexture,
	out float OutTexX, out float OutTexY,
	out float OutTexW, out float OutTexH)
{
	local R_UI_ArpgRootWindow LocalRootWindow;
	LocalRootWindow = GetArpgRootWindow();
	if(LocalRootWindow != None)
	{
		return LocalRootWindow.GetItemUITextureInfo(Item, OutDrawTexture, OutTexX, OutTexY, OutTexW, OutTexH);
	}
	else
	{
		OutDrawTexture = None;
		OutTexX = 0.0;
		OutTexY = 0.0;
		OutTexW = 0.0;
		OutTexH = 0.0;
		return false;
	}
}

defaultproperties
{
	bMousePassThrough=false
}