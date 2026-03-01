//==============================================================================
//	R_UI_ArpgRootWindow
//==============================================================================
class R_UI_ArpgRootWindow extends RGameUI.R_UIW_RootWindow;

var private float GridPixelSizeX;
var private float GridPixelSizeY;

// If not none, this window will consume all mouse input
var private UWindowWindow MouseEventWindow;

function SetMouseEventWindow(UWindowWindow NewMouseEventWindow)
{
	MouseEventWindow = NewMouseEventWindow;
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	if(MouseEventWindow != None)
	{
		switch(Msg)
		{
		case WM_LMouseDown:
		case WM_LMouseUp:
		case WM_RMouseDown:
		case WM_RMouseUp:
		case WM_MMouseDown:
		case WM_MMouseUp:
			MouseEventWindow.WindowEvent(Msg, C, X, Y, Key);
			return;
		}
	}

	Super.WindowEvent(Msg, C, X, Y, Key);
}

function GetGridCellPixelSize(out float OutGridPixelSizeX, out float OutGridPixelSizeY)
{
	OutGridPixelSizeX = GridPixelSizeX;
	OutGridPixelSizeY = GridPixelSizeY;
}

function GetGridPixelDimensions(int GridSizeX, int GridSizeY, out float OutGridPixelSizeX, out float OutGridPixelSizeY)
{
	OutGridPixelSizeX = float(GridSizeX) * GridPixelSizeX;
	OutGridPixelSizeY = float(GridSizeY) * GridPixelSizeY;
}

function bool GetItemUITextureInfo(
	R_ArpgItem Item,
	out Texture OutDrawTexture,
	out float OutTexX, out float OutTexY,
	out float OutTexW, out float OutTexH)
{
	// Implementing class needs to determine how the item texture data is stored and retrieved
	OutDrawTexture = None;
	OutTexX = 0.0;
	OutTexY = 0.0;
	OutTexW = 0.0;
	OutTexH = 0.0;
	return false;
}

defaultproperties
{
	GridPixelSizeX=48.0
	GridPixelSizeY=48.0
}