//==============================================================================
//	R_UI_InWorldUI
//==============================================================================
class R_UI_InWorldUI extends RGameUI.R_UI_GameUserInterface;

var private UWindowWindow InteractionWindow;
var private UWindowWindow InventoryWindow;

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

	//W *= 0.5;
	//H *= 0.5;
	//CreateWindow(Class'RArpg.R_UIW_InWorldInteraction', X, Y, W, H);

	//CreateWindow(Class'RArpg.R_UI_GameUI', X, Y, W, H);

	//X = LocalRootWindow.WinWidth * 0.5;
	//Y = LocalRootWindow.WinTop;
	//W = LocalRootWindow.WinWidth * 0.5;
	//H = LocalRootWindow.WinHeight;
	//X = LocalRootWindow.WinWidth * 0.25;
	//Y = 0;
	//W = LocalRootWindow.WinWidth * 0.25;
	//H = LocalRootWindow.WinHeight;
	InventoryWindow = CreateWindow(Class'RArpg.R_UI_Inventory', X, Y, W, H);
	InventoryWindow.HideWindow();
}

function bool IsInventoryOpen()
{
	return InventoryWindow.WindowIsVisible();
}

function OpenInventory()
{
	InventoryWindow.ShowWindow();
}

function CloseInventory()
{
	InventoryWindow.HideWindow();
}

function OpenInteractionMenu(Actor InteractionActor)
{
	local UWindowRootWindow LocalRootWindow;
	local float X, Y, W, H;
	local R_UIW_InWorldInteraction InWorldInteraction;

	if(InWorldInteraction != None)
	{
		InWorldInteraction.ShowWindow();
	}
	else
	{
		LocalRootWindow = GetRootWindow();
		if(LocalRootWindow != None)
		{
			X = LocalRootWindow.WinLeft;
			Y = LocalRootWindow.WinTop;
			//W = LocalRootWindow.WinWidth;
			//H = LocalRootWindow.WinHeight;
			W = 96.0;
			H = 64.0;
		}
		InteractionWindow = CreateWindow(Class'RArpg.R_UIW_InWorldInteraction', X, Y, W, H);
		InWorldInteraction = R_UIW_InWorldInteraction(InteractionWindow);
	}
	
	if(InWorldInteraction != None)
	{
		InWorldInteraction.SetInteractionActor(InteractionActor);
	}
}

function CloseInteractionMenu()
{
	if(InteractionWindow != None)
	{
		InteractionWindow.HideWindow();
	}
}

/*
function Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);

	if(InteractionWindow != None)
	{
		InteractionWindow.WinLeft += 10.0 * DeltaSeconds;
	}
}
	*/

defaultproperties
{
	RootWindowClass=Class'RArpg.R_UIW_InWorldRootWindow'
}