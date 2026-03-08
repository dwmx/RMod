//==============================================================================
//	R_ArpgDBView_UI
//	Debug view for UI
//==============================================================================
class R_ArpgDBView_UI extends R_ArpgDBView config(RArpgDebug);

const DebugCategory_UI = 'UI';
const DebugCategory_Proxies = 'UIProxies';

var config private bool bDrawProxies;

simulated function ToggleProxies()
{
	bDrawProxies = !bDrawProxies;
	SaveConfig();
}

//------------------------------------------------------------------------------

simulated function R_UI_ArpgGameUserInterface GetArpgGameUI()
{
	local R_ArpgPlayerController PlayerController;
	local R_UI_ArpgGameUserInterface GameUI;

	GameUI = None;
	PlayerController = R_ArpgPlayerController(GetPlayerPawnOwner());
	if(PlayerController != None)
	{
		GameUI = PlayerController.GetGameUI();
	}
	return GameUI;
}

simulated function R_UI_ArpgWindow GetArpgGameUIWindow(Name WindowName)
{
	local R_UI_ArpgGameUserInterface GameUI;
	local R_UI_ArpgWindow Window;

	Window = None;
	GameUI = GetArpgGameUI();
	if(GameUI != None)
	{
		Window = GameUI.GetWindow(WindowName);
	}
	return Window;
}

//------------------------------------------------------------------------------

simulated function DrawDebugView(Canvas C, R_DBStringManager StringManager)
{
	StringManager.AddWarning(DebugCategory_UI, "UI View is good to go");

	if(bDrawProxies)
	{
		DrawProxies(C, StringManager);
	}
}

simulated function DrawProxies(Canvas C, R_DBStringManager StringManager)
{
	local R_UI_ArpgInWorldWindow InWorldWindow;
	local R_ArpgInteractionProxy Proxy;
	local Vector AABBMin, AABBMax;
	local int ProxyCount;
	local int i;

	StringManager.AddCategory(DebugCategory_Proxies);

	InWorldWindow = R_UI_ArpgInWorldWindow(GetArpgGameUIWindow('InWorld'));
	if(InWorldWindow == None)
	{
		StringManager.AddWarning(DebugCategory_Proxies, "Failed to retrieve InWorld UI Window");
		return;
	}

	ProxyCount = InWorldWindow.GetCachedInteractionProxyCount();
	StringManager.AddInt(DebugCategory_Proxies, "Proxy Count", ProxyCount);

	for(i = 0; i < ProxyCount; ++i)
	{
		InWorldWindow.GetCachedInteractionProxy(i, Proxy, AABBMin, AABBMax);

		// Draw world collision cylinder
		CanvasLib.Static.DrawCylinderAxisAligned3D(
			C,
			Proxy.Location,
			Vect(0,0,0),
			Proxy.CollisionRadius,
			Proxy.CollisionHeight * 2.0,
			32,
			0.0, 1.0, 1.0);

		// Draw screen space AABB
		CanvasLib.Static.DrawBoxOutline(
			C, AABBMin, AABBMax, 2.0,
			1.0, 1.0, 0.0, 1.0);
	}
}

simulated function DrawInWorldBoundingBoxes(Canvas C, R_DBStringManager StringManager)
{
	
}