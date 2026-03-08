//==============================================================================
//  R_UI_ArpgInWorldWindow
//==============================================================================
class R_UI_ArpgInWorldWindow extends R_UI_ArpgWindow;

struct R_ArpgCachedInteractionProxy
{
	var R_ArpgInteractionProxy Proxy;
	var float MinX, MinY; // Screen-space bounding box min
	var float MaxX, MaxY; // Screen-space bounding box max

};
var private R_ArpgCachedInteractionProxy CachedInteractionProxies[256];
var private int CachedInteractionProxyCount;

var private bool bShowItems;

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

function ClearCachedInteractionProxies()
{
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

	ClearCachedInteractionProxies();

	PlayerController = R_ArpgPlayerController(GetPlayerOwner());
	if(PlayerController == None)
	{
		return;
	}

	ViewLocation = PlayerController.GetViewLocation();
	foreach PlayerController.AllActors(Class'RArpg.R_ArpgInteractionProxy', Proxy)
	{
		CalcScreenSpaceBoundingBoxForActor(C, Proxy, ViewLocation, AABBMin, AABBMax);
		AddCachedInteractionProxy(Proxy, AABBMin.X, AABBMin.Y, AABBMax.X, AABBMax.Y);
	}
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

function Paint(Canvas C, float X, float Y)
{
	UpdateInteractionArray(C);

	if(bShowItems)
	{
		PaintItems(C, X, Y);
	}
}

function PaintItems(Canvas C, float X, float Y)
{
	local int i;
	local R_ArpgItemActor_Pickup ItemActor;

	for(i = 0; i < CachedInteractionProxyCount; ++i)
	{
		ItemActor = R_ArpgItemActor_Pickup(CachedInteractionProxies[i].Proxy.GetProxyOwner());
		if(ItemActor != None)
		{
			PaintBoxForItem(C, ItemActor);
		}
	}
}

function PaintBoxForItem(Canvas C, R_ArpgItemActor_Pickup ItemActor)
{
	local R_ArpgItem Item;
	local String DrawString;
	local float StrW, StrH;
	local Vector DrawLocation;
	local float DrawX, DrawY;
	local float DrawW, DrawH;

	if(ItemActor != None)
	{
		Item = ItemActor.GetItem();
	}
	if(Item == None)
	{
		return;
	}

	CanvasLib.Static.GetScreenSpaceLocationAboveActor(C, ItemActor, DrawLocation);

	DrawString = Item.GetItemTypeString();
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
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.Style = 1;
	ClipText(C, DrawX, DrawY, DrawString);
}

defaultproperties
{
	bShowItems=true
}