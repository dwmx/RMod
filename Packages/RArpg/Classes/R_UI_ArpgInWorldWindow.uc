//==============================================================================
//  R_UI_ArpgInWorldWindow
//==============================================================================
class R_UI_ArpgInWorldWindow extends R_UI_ArpgWindow;

var private bool bShowItems;

var private Font F_ItemNameFont;

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
	local PlayerPawn PlayerOwner;
	local R_ArpgItemActor_Pickup A;

	PlayerOwner = GetPlayerOwner();
	if(PlayerOwner == None)
	{
		return;
	}

	foreach PlayerOwner.AllActors(Class'RArpg.R_ArpgItemActor_Pickup', A)
	{
		PaintBoxForItem(C, A);
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

	CanvasLib.Static.GetScreenSpaceLocationAboveActor(C, ItemActor, DrawLocation, 16.0);

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