//==============================================================================
//  R_UI_ArpgInWorldWindow
//==============================================================================
class R_UI_ArpgInWorldWindow extends R_UI_ArpgWindow;

const UIGameLib = Class'RArpg.R_UI_ArpgUIGameLib';

// Thse must match definitions in R_ArpgInteractionProxy
const PROXY_TYPE_PROXY 	= 'Proxy';
const PROXY_TYPE_PICKUP = 'Pickup';

struct R_ArpgCachedInteractionProxy
{
	var R_ArpgInteractionProxy Proxy;
	var float MinX, MinY; // Screen-space bounding box min
	var float MaxX, MaxY; // Screen-space bounding box max

};
var private R_ArpgCachedInteractionProxy CachedInteractionProxies[256];
var private int CachedInteractionProxyCount;

var private int SelectedProxyIndex;
var private R_ArpgInteractionProxy SelectedProxy;

var private bool bShowItems;
var private bool bShowInWorldHUD;
var private bool bInteractionEnabled;

var private Font F_ItemNameFont;

//------------------------------------------------------------------------------

static function CalcScreenSpaceBoundingBoxForActor(
	Canvas C,
	Actor A,
	Vector ViewLocation,
	out Vector OutMin,
	out Vector OutMax)
{
	local Vector LocationDelta;
	local Vector BasisX, BasisY, BasisZ;
	local Vector WorldPoints[6];
	local int ScreenX, ScreenY;
	local int i;

	LocationDelta = A.Location - ViewLocation;
	BasisX = Normal(Vect(1.0, 1.0, 0.0) * LocationDelta);
	BasisZ = Vect(0.0, 0.0, 1.0);
	BasisY = BasisX Cross BasisZ;

	WorldPoints[0] = A.Location + BasisY * A.CollisionRadius *  1.0;
	WorldPoints[1] = A.Location + BasisY * A.CollisionRadius * -1.0;
	WorldPoints[2] = A.Location + BasisZ * A.CollisionHeight *  1.0 + BasisX * A.CollisionRadius *  1.0;
	WorldPoints[3] = A.Location + BasisZ * A.CollisionHeight *  1.0 + BasisX * A.CollisionRadius * -1.0;
	WorldPoints[4] = A.Location + BasisZ * A.CollisionHeight * -1.0 + BasisX * A.CollisionRadius *  1.0;
	WorldPoints[5] = A.Location + BasisZ * A.CollisionHeight * -1.0 + BasisX * A.CollisionRadius * -1.0;

	OutMin = Vect(1,1,0) *  100000000.0;
	OutMax = Vect(1,1,0) * -100000000.0;
	for(i = 0; i < 6; ++i)
	{
		C.TransformPoint(WorldPoints[i], ScreenX, ScreenY);
		OutMin.X = FMin(OutMin.X, float(ScreenX));
		OutMin.Y = FMin(OutMin.Y, float(ScreenY));
		OutMax.X = FMax(OutMax.X, float(ScreenX));
		OutMax.Y = FMax(OutMax.Y, float(ScreenY));
	}
}

//------------------------------------------------------------------------------
function int GetCachedInteractionProxyCount()
{
	return CachedInteractionProxyCount;
}

function bool GetCachedInteractionProxy(
	int Index,
	out R_ArpgInteractionProxy OutProxy,
	out Vector OutAABBMin,
	out Vector OutAABBMax)
{
	if(Index < 0 || Index >= CachedInteractionProxyCount)
	{
		return false;
	}

	OutProxy = CachedInteractionProxies[Index].Proxy;

	OutAABBMin.X = CachedInteractionProxies[Index].MinX;
	OutAABBMin.Y = CachedInteractionProxies[Index].MinY;
	OutAABBMin.Z = 0.0;

	OutAABBMax.X = CachedInteractionProxies[Index].MaxX;
	OutAABBMax.Y = CachedInteractionProxies[Index].MaxY;
	OutAABBMax.Z = 0.0;
}

function int GetSelectedProxyIndex()
{
	return SelectedProxyIndex;
}

function ClearCachedInteractionProxies()
{
	SelectedProxyIndex = INVALID_INDEX;
	CachedInteractionProxyCount = 0;
}

function AddCachedInteractionProxy(
	R_ArpgInteractionProxy Proxy,
	float MinX, float MinY,
	float MaxX, float MaxY)
{
	if(CachedInteractionProxyCount >= ArrayCount(CachedInteractionProxies))
	{
		return;
	}

	CachedInteractionProxies[CachedInteractionProxyCount].Proxy = Proxy;
	CachedInteractionProxies[CachedInteractionProxyCount].MinX = MinX;
	CachedInteractionProxies[CachedInteractionProxyCount].MinY = MinY;
	CachedInteractionProxies[CachedInteractionProxyCount].MaxX = MaxX;
	CachedInteractionProxies[CachedInteractionProxyCount].MaxY = MaxY;
	++CachedInteractionProxyCount;
}

function UpdateInteractionArray(Canvas C)
{
	local R_ArpgPlayerController PlayerController;
	local Vector ViewLocation;
	local R_ArpgInteractionProxy Proxy;
	local Vector AABBMin, AABBMax;
	local int SelectedIndex;

	ClearCachedInteractionProxies();

	if(!bInteractionEnabled)
	{
		return;
	}

	PlayerController = R_ArpgPlayerController(GetPlayerOwner());
	if(PlayerController == None)
	{
		return;
	}

	SelectedIndex = INVALID_INDEX;
	ViewLocation = PlayerController.GetViewLocation();
	foreach PlayerController.AllActors(Class'RArpg.R_ArpgInteractionProxy', Proxy)
	{
		CalcScreenSpaceBoundingBoxForActor(C, Proxy, ViewLocation, AABBMin, AABBMax);
		AddCachedInteractionProxy(Proxy, AABBMin.X, AABBMin.Y, AABBMax.X, AABBMax.Y);

		// Checking mouse intersection
		if(Root.MouseX < AABBMin.X || Root.MouseX > AABBMax.X) continue;
		if(Root.MouseY < AABBMin.Y || Root.MouseY > AABBMax.Y) continue;
		SelectedIndex = CachedInteractionProxyCount - 1;
	}
	SetSelectedProxyIndex(SelectedIndex);
}

function SetSelectedProxyIndex(int NewSelectedProxyIndex)
{
	SelectedProxyIndex = NewSelectedProxyIndex;

	if(SelectedProxy != None)
	{
		SelectedProxy.NotifySelectionStateChanged(false);
	}

	if(SelectedProxyIndex != INVALID_INDEX)
	{
		SelectedProxy = CachedInteractionProxies[SelectedProxyIndex].Proxy;
		SelectedProxy.NotifySelectionStateChanged(true);
	}
}

//------------------------------------------------------------------------------

function bool CheckConsumeMouseEvent(WinMessage Msg)
{
	if(SelectedProxyIndex != INVALID_INDEX)
	{	// Only consume mouse event if hovering over an interaction proxy
		return true;
	}
	return false;
}

function bool TryHandleLMouseDown()
{
	local R_ArpgPlayerController PlayerController;
	local R_ArpgPawn_Hero HeroPawn;

	if(SelectedProxyIndex == INVALID_INDEX)
	{
		return false;
	}

	PlayerController = R_ArpgPlayerController(GetPlayerOwner());
	if(PlayerController != None)
	{
		HeroPawn = R_ArpgPawn_Hero(PlayerController.GetControlledPawn());
	}

	if(HeroPawn == None)
	{
		return false;
	}

	return HeroPawn.TryInteract(CachedInteractionProxies[SelectedProxyIndex].Proxy);
}

//------------------------------------------------------------------------------

function Created()
{
	Super.Created();
	F_ItemNameFont = Font(DynamicLoadObject("RArpgFonts.Marcellus16", Class'Font'));
}

function SetShowItems(bool bNewShowItems)
{
	bShowItems = bNewShowItems;
}

function SetShowInWorldHUD(bool bNewShowInWorldHUD)
{
	bShowInWorldHUD = bNewShowInWorldHUD;
}

function SetInteractionEnabled(bool bNewInteractionEnabled)
{
	bInteractionEnabled = bNewInteractionEnabled;
}

function Paint(Canvas C, float X, float Y)
{
	UpdateInteractionArray(C);

	if(bShowItems)
	{
		PaintItems(C, X, Y);
	}
	if(bShowInWorldHUD)
	{
		PaintInWorldHUD(C, X, Y);
	}
	else if(SelectedProxyIndex != INVALID_INDEX)
	{
		PaintProxyAsSelected(C, CachedInteractionProxies[SelectedProxyIndex].Proxy);
	}
}

function PaintProxyAsSelected(Canvas C, R_ArpgInteractionProxy Proxy)
{
	local Name ProxyType;

	if(Proxy == None)
	{
		return;
	}

	ProxyType = Proxy.GetProxyType();
	switch(ProxyType)
	{
	case PROXY_TYPE_PICKUP:
		PaintLabelBoxForProxy(C, CachedInteractionProxies[SelectedProxyIndex].Proxy);
		PaintCircleForItem(C, R_ArpgItemActor_Pickup(CachedInteractionProxies[SelectedProxyIndex].Proxy.GetProxyOwner()));
		break;
	}
}

function Color GetLabelColorForProxy(R_ArpgInteractionProxy Proxy)
{
	local Color Result;
	local Name ProxyType;

	if(Proxy == None)
	{
		return UIGameLib.Static.MakeColor3(255,50,50);
	}

	ProxyType = Proxy.GetProxyType();
	if(ProxyType == PROXY_TYPE_PICKUP)
	{
		if(Proxy.GetNameParam('PickupType') == 'Item')
		{
			return UIGameLib.Static.GetItemRarityTypeDrawColor(Proxy.GetNameParam('RarityType'));
		}
	}

	return UIGameLib.Static.MakeColor3(255,255,255);
}

function PaintLabelBoxForProxy(Canvas C, R_ArpgInteractionProxy Proxy)
{
	local Vector DrawLocation;
	local String DrawString;
	local Color DrawColor;
	local float StrW, StrH;
	local float DrawX, DrawY;
	local float DrawW, DrawH;

	if(Proxy == None)
	{
		return;
	}

	CanvasLib.Static.GetScreenSpaceLocationAboveActor(C, Proxy, DrawLocation);
	DrawColor = GetLabelColorForProxy(Proxy);

	DrawString = Proxy.GetDisplayString();
	C.Font = F_ItemNameFont;
	C.StrLen(DrawString, StrW, StrH);

	// Draw backdrop
	DrawW = StrW + 4.0;
	DrawH = StrH + 4.0;
	DrawX = DrawLocation.X - DrawW * 0.5;
	DrawY = DrawLocation.Y - DrawH * 0.5;
	C.DrawColor.R = 25;
	C.DrawColor.G = 25;
	C.DrawColor.B = 25;
	C.Style = 1;
	DrawStretchedTexture(C, DrawX, DrawY, DrawW, DrawH, WhiteTexture);

	// Draw item name
	DrawX = DrawLocation.X - StrW * 0.5;
	DrawY = DrawLocation.Y - StrH * 0.5;
	C.DrawColor = DrawColor;
	C.Style = 1;
	ClipText(C, DrawX, DrawY, DrawString);
}

function PaintItems(Canvas C, float X, float Y)
{
	local int i;
	local R_ArpgInteractionProxy Proxy;
	//local R_ArpgItemActor_Pickup ItemActor;

	for(i = 0; i < CachedInteractionProxyCount; ++i)
	{
		Proxy = CachedInteractionProxies[i].Proxy;
		if(Proxy == None)
		{
			continue;
		}

		if(Proxy.GetProxyType() == PROXY_TYPE_PICKUP)
		{
			PaintLabelBoxForProxy(C, Proxy);
		}
	}
}

function PaintInWorldHUD(Canvas C, float X, float Y)
{
	local Pawn LocalPlayerOwner;
	local Pawn PawnIt;
	local R_ArpgPawn ArpgPawnIt;
	local float HealthBase, HealthAggregate;
	local float MaxHealthBase, MaxHealthAggregate;

	LocalPlayerOwner = GetPlayerOwner();
	if(LocalPlayerOwner == None)
	{
		return;
	}

	for(PawnIt = LocalPlayerOwner.Level.PawnList; PawnIt != None; PawnIt = PawnIt.NextPawn)
	{
		ArpgPawnIt = R_ArpgPawn(PawnIt);
		if(ArpgPawnIt != None)
		{
			ArpgPawnIt.DrawInWorldHUD(C);
		}
	}
}

function PaintCircleForItem(Canvas C, R_ArpgItemActor_Pickup ItemActor)
{
	if(ItemActor == None)
	{
		return;
	}

	CanvasLib.Static.DrawCircle3D(
		C,
		ItemActor.Location + Vect(0,0,-1) * ItemActor.CollisionHeight,
		Vect(0,0,1),
		ItemActor.CollisionRadius,
		32,
		0.25, 1.0, 1.0);
}

defaultproperties
{
	bInteractionEnabled=true
}