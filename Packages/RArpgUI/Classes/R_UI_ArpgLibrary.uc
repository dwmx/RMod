//==============================================================================
//	R_UI_ArpgLibrary
//==============================================================================
class R_UI_ArpgLibrary extends Object abstract;

static function UWindowWindow FindWindowUnderPoint(UWindowWindow Window, float X, float Y)
{
	if(Window == None)
	{
		return None;
	}
	return Window.FindWindowUnder(X, Y);
}

static function UWindowWindow FindWindowUnderRect(UWindowWindow Window, float X, float Y, float W, float H)
{
	local UWindowWindow Child;

	Child = Window.LastChildWindow;

	while(Child != None)
	{
		Child.bUWindowActive = Window.bUWindowActive;

		if(Window.bLeaveOnscreen)
		{
			Child.bLeaveOnscreen = true;
		}

		if(Window.bUWindowActive || Child.bLeaveOnscreen)
		{
			if(	(X <= Child.WinLeft + Child.WinWidth) && (X + W >= Child.WinLeft) &&
				(Y <= Child.WinTop + Child.WinHeight) && (Y + H >= Child.WinTop) &&
				(!Child.CheckMousePassThrough(X - Child.WinLeft, Y - Child.WinTop)))
			{
				return FindWindowUnderRect(Child, X - Child.WinLeft, Y - Child.WinTop, W, H);
			}
		}

		Child = Child.PrevSiblingWindow;
	}

	return Window;
}