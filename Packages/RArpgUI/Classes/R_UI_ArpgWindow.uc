//==============================================================================
//	R_UI_ArpgWindow
//	Base class for UI windows in Arpg
//==============================================================================
class R_UI_ArpgWindow extends UWindowWindow;

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
	local Texture DrawTexture;
	local float DrawX, DrawY, DrawW, DrawH;

	if(Item == None)
	{
		return;
	}

	if(Item.GetItemUITexture(DrawTexture))
	{
		DrawW = DrawTexture.USize;
		DrawH = DrawTexture.VSize;
	}
	else
	{
		DrawTexture = WhiteTexture; // Could use a better invalid texture here
		DrawW = 96.0;
		DrawH = 96.0;
	}

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