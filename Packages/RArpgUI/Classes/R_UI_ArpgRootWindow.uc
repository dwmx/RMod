//==============================================================================
//	R_UI_ArpgRootWindow
//==============================================================================
class R_UI_ArpgRootWindow extends RGameUI.R_UIW_RootWindow;

var private float GridPixelSizeX;
var private float GridPixelSizeY;

var private R_UI_ArpgWindow MouseEventWindowStack[12];

function PushMouseEventWindow(R_UI_ArpgWindow MouseEventWindow)
{
	local int i;

	for(i = 0; i < ArrayCount(MouseEventWindowStack); ++i)
	{
		if(MouseEventWindowStack[i] == None)
		{
			MouseEventWindowStack[i] = MouseEventWindow;
			return;
		}
	}
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local R_UI_ArpgWindow MouseEventWindow;
	local int i;

	switch(Msg)
	{
	case WM_LMouseDown:
	case WM_LMouseUp:
	case WM_RMouseDown:
	case WM_RMouseUp:
	case WM_MMouseDown:
	case WM_MMouseUp:
		for(i = 0; i < ArrayCount(MouseEventWindowStack); ++i)
		{
			MouseEventWindow = MouseEventWindowStack[i];
			if(MouseEventWindow == None)
			{
				break;
			}

			if(MouseEventWindow.CheckConsumeMouseEvent(Msg))
			{
				MouseEventWindow.WindowEvent(Msg, C, X, Y, Key);
				return;
			}
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