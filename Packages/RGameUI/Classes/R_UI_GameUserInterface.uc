//==============================================================================
//	R_UI_GameUserInterface
//	Manages a custom UWindow-based user interface outside of the normal
//	WindowConsole windowing system
//==============================================================================
class R_UI_GameUserInterface extends Object abstract;

const Utilities = Class'RBase.R_AUtilityLibrary';

const LogCategory = 'GameUI';
const LogSubCategory = 'UserInterface';

const DefaultRootWindowClass = Class'UWindow.UWindowRootWindow';
var private Class<UWindowRootWindow> RootWindowClass;
var private UWindowRootWindow RootWindow;

function Initialize(Player OwningPlayer)
{
	local Class<UWindowRootWindow> LocalRootWindowClass;
	local float ScreenWidth, ScreenHeight;

	if(OwningPlayer == None)
	{
		Utilities.Static.RLog("Failed to initialize User Interface -- Bad Player", LogCategory, LogSubCategory);
		return;
	}

	Utilities.Static.RLog("Initializing User Interface with Player" @ OwningPlayer, LogCategory, LogSubCategory);

	LocalRootWindowClass = RootWindowClass;
	if(LocalRootWindowClass == None)
	{
		LocalRootWindowClass = DefaultRootWindowClass;
	}

	RootWindow = new(Self) LocalRootWindowClass;
	RootWindow.BeginPlay();

	//if(OwningPlayer.Actor != None)
	//{
	//	PlayerLib.Static.GetScreenResolutionFromPlayerPawnInPixels(OwningPlayer.Actor, ScreenWidth, ScreenHeight);
	//}

	//RootWindow.WinTop = 0;
	//RootWindow.WinLeft = 0;
	//RootWindow.WinWidth = ScreenWidth;
	//RootWindow.WinHeight = ScreenHeight;
//
	//RootWindow.ClippingRegion.X = 0;
	//RootWindow.ClippingRegion.Y = 0;
	//RootWindow.ClippingRegion.W = RootWindow.WinWidth;
	//RootWindow.ClippingRegion.H = RootWindow.WinHeight;

	RootWindow.Console = WindowConsole(OwningPlayer.Console);
	RootWindow.bUWindowActive = true;
	RootWindow.Created();

	ConstructUI();
}

function UWindowRootWindow GetRootWindow()
{
	return RootWindow;
}

function UWindowWindow CreateWindow(
	Class<UWindowWindow> WindowClass,
	float X, float Y,
	float W, float H,
	optional UWindowWindow OwnerWindow,
	optional bool bUnique,
	optional Name ObjectName)
{
	if(RootWindow != None)
	{
		return RootWindow.CreateWindow(WindowClass, X, Y, W, H, OwnerWindow, bUnique, ObjectName);
	}
	return None;
}

function ConstructUI() {}

function Tick(float DeltaSeconds)
{
	if(RootWindow != None)
	{
		RootWindow.DoTick(DeltaSeconds);
	}
}

function PostRender(Canvas C)
{
	if(RootWindow != None)
	{
		RootWindow.WindowEvent(WM_Paint, C, 0.0, 0.0, 0);
	}
}

function InputMouseMove(float MouseX, float MouseY)
{
	if(RootWindow != None)
	{
		RootWindow.MoveMouse(MouseX, MouseY);
	}
}

function InputLMouseDown(float MouseX, float MouseY)
{
	if(RootWindow != None)
	{
		RootWindow.WindowEvent(WM_LMouseDown, None, MouseX, MouseY, 0);
	}
}

function InputLMouseUp(float MouseX, float MouseY)
{
	if(RootWindow != None)
	{
		RootWindow.WindowEvent(WM_LMouseUp, None, MouseX, MouseY, 0);
	}
}

function InputCommand(Name Command);