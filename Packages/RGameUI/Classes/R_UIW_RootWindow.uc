//==============================================================================
//	R_UIW_RootWindow
//==============================================================================
class R_UIW_RootWindow extends UWindowRootWindow;

const PlayerLib = Class'RBase.R_APlayerLibrary';

var bool bHiddenWindow;

function SetupFonts()
{
	if(GUIScale >= 2)
	{
		Fonts[F_Normal] =		Font(DynamicLoadObject("UWindowFonts.Tahoma20", class'Font'));
		Fonts[F_Bold] =			Font(DynamicLoadObject("UWindowFonts.TahomaB20", class'Font'));
		Fonts[F_Large] =		Font(DynamicLoadObject("UWindowFonts.Tahoma30", class'Font'));
		Fonts[F_LargeBold] =	Font(DynamicLoadObject("UWindowFonts.TahomaB30", class'Font'));
		Fonts[F_RuneMedium] =	Font'Engine.RuneMed';
		Fonts[F_RuneBig] =		Font'Engine.RuneBig';
		Fonts[F_RuneLarge] =	Font'Engine.RuneLarge';
		Fonts[F_RuneButton] =	Font'Engine.RuneButton';
	}
	else if (GUIScale <= 0.5)
	{
		Fonts[F_Normal] =		Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
		Fonts[F_Bold] =			Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
		Fonts[F_Large] =		Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
		Fonts[F_LargeBold] =	Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
		Fonts[F_RuneMedium] =	Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
		Fonts[F_RuneBig] =		Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
		Fonts[F_RuneLarge] =	Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
		Fonts[F_RuneButton] =	Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
	}
	else if (GUIScale <= 0.8)
	{
		Fonts[F_Normal] =		Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
		Fonts[F_Bold] =			Font(DynamicLoadObject("UWindowFonts.TahomaB10", class'Font'));
		Fonts[F_Large] =		Font(DynamicLoadObject("UWindowFonts.Tahoma20", class'Font'));
		Fonts[F_LargeBold] =	Font(DynamicLoadObject("UWindowFonts.TahomaB20", class'Font'));
		Fonts[F_RuneMedium] =	Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
		Fonts[F_RuneBig] =		Font'Engine.RuneMed';
		Fonts[F_RuneLarge] =	Font'Engine.RuneMed';
		Fonts[F_RuneButton] =	Font(DynamicLoadObject("UWindowFonts.TahomaB10", class'Font'));
	}
	else
	{
		Fonts[F_Normal] =		Font(DynamicLoadObject("UWindowFonts.Tahoma10", class'Font'));
		Fonts[F_Bold] =			Font(DynamicLoadObject("UWindowFonts.TahomaB10", class'Font'));
		Fonts[F_Large] =		Font(DynamicLoadObject("UWindowFonts.Tahoma20", class'Font'));
		Fonts[F_LargeBold] =	Font(DynamicLoadObject("UWindowFonts.TahomaB20", class'Font'));
		Fonts[F_RuneMedium] =	Font'Engine.RuneMed';
		Fonts[F_RuneBig] =		Font'Engine.RuneBig';
		Fonts[F_RuneLarge] =	Font'Engine.RuneLarge';
		Fonts[F_RuneButton] =	Font'Engine.RuneButton';
	}	
}

function Created()
{
	//ComputeGuiScale(WinWidth, WinHeight);
	//SetScale(GUIScale);
	//bHiddenWindow = true;
	bHiddenWindow = false;
	FitRootWindowToScreenResolution();
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	if(bHiddenWindow)
	{
		return;
	}
	Super.WindowEvent(Msg, C, X, Y, Key);
}

function Paint(Canvas C, float X, float Y)
{
	FitRootWindowToScreenResolution();
	Super.Paint(C, X, Y);
}

function FitRootWindowToScreenResolution()
{
	local PlayerPawn PlayerOwner;
	local float ScreenWidth, ScreenHeight;

	PlayerOwner = GetPlayerOwner();
	if(PlayerOwner == None)
	{
		return;
	}

	PlayerLib.Static.GetScreenResolutionFromPlayerPawnInPixels(PlayerOwner, ScreenWidth, ScreenHeight);

	WinTop = 0;
	WinLeft = 0;
	WinWidth = ScreenWidth;
	WinHeight = ScreenHeight;

	ClippingRegion.X = 0;
	ClippingRegion.Y = 0;
	ClippingRegion.W = WinWidth;
	ClippingRegion.H = WinHeight;
}

defaultproperties
{
     LookAndFeelClass="RMenu.RuneLookAndFeel"
}
