//==============================================================================
//  R_UI_ArpgInWorldWindow
//==============================================================================
class R_UI_ArpgInWorldWindow extends R_UI_ArpgWindow;

struct R_ArpgCachedInteractionProxy
{
	var R_ArpgInteractionProxy Proxy;

};
var private R_ArpgCachedInteractionProxy CachedInteractionProxies[256];
var private int CachedInteractionProxyCount;

var private bool bShowItems;

var private Font F_ItemNameFont;

//------------------------------------------------------------------------------
function ClearCachedInteractionProxies()
{
	CachedInteractionProxyCount = 0;
}

function AddCachedInteractionProxy(R_ArpgInteractionProxy Proxy)
{
	if(CachedInteractionProxyCount >= ArrayCount(CachedInteractionProxies))
	{
		return;
	}

	CachedInteractionProxies[CachedInteractionProxyCount].Proxy = Proxy;
	++CachedInteractionProxyCount;
}

function Tick(float DeltaSeconds)
{
	local PlayerPawn PlayerOwner;
	local R_ArpgInteractionProxy Proxy;

	Super.Tick(DeltaSeconds);

	PlayerOwner = GetPlayerOwner();
	if(PlayerOwner == None)
	{
		return;
	}

	ClearCachedInteractionProxies();
	foreach PlayerOwner.AllActors(Class'RArpg.R_ArpgInteractionProxy', Proxy)
	{
		AddCachedInteractionProxy(Proxy);
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