//==============================================================================
//	R_UI_InWorldUI
//==============================================================================
class R_UI_InWorldUI extends RGameUI.R_UI_GameUserInterface;

function ConstructUI()
{
	local UWindowRootWindow LocalRootWindow;
	local float X, Y, W, H;

	LocalRootWindow = GetRootWindow();
	if(LocalRootWindow != None)
	{
		X = LocalRootWindow.WinLeft;
		Y = LocalRootWindow.WinTop;
		W = LocalRootWindow.WinWidth;
		H = LocalRootWindow.WinHeight;
	}
	else
	{
		X = 0.0;
		Y = 0.0;
		W = 1920.0;
		H = 1080.0;
	}

	W *= 0.5;
	H *= 0.5;
	CreateWindow(Class'RArpg.R_UIW_InWorldInteraction', X, Y, W, H);
}

defaultproperties
{
	RootWindowClass=Class'RArpg.R_UIW_InWorldRootWindow'
}