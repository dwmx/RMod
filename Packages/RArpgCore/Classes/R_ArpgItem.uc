//==============================================================================
//	R_ArpgItem
//==============================================================================
class R_ArpgItem extends R_ArpgObject;

var private SkelModel ItemSkelModel;
var private Texture ItemUITexture;

var private int ItemGridSizeX;
var private int ItemGridSizeY;

function InitializeArpgObject()
{
	// Force clamping on defaultproperties
	SetItemGridSize(ItemGridSizeX, ItemGridSizeY);
}

function bool GetItemSkelModel(out SkelModel OutItemSkelModel)
{
	OutItemSkelModel = None;
	if(ItemSkelModel == None)
	{
		return false;
	}
	OutItemSkelModel = ItemSkelModel;
	return true;
}

function SetItemSkelModel(SkelModel NewItemSkelModel)
{
	ItemSkelModel = NewItemSkelModel;
}

function bool GetItemUITexture(out Texture OutItemUITexture)
{
	OutItemUITexture = None;
	if(ItemUITexture == None)
	{
		return false;
	}
	OutItemUITexture = ItemUITexture;
	return true;
}

function SetItemUITexture(Texture NewItemUITexture)
{
	ItemUITexture = NewItemUITexture;
}

function bool GetItemGridSize(out int OutItemGridSizeX, out int OutItemGridSizeY)
{
	OutItemGridSizeX = ItemGridSizeX;
	OutItemGridSizeY = ItemGridSizeY;
	if(ItemGridSizeX <= 0 || ItemGridSizeY <= 0)
	{
		return false;
	}

	return true;
}

function SetItemGridSize(int NewItemGridSizeX, int NewItemGridSizeY)
{
	ItemGridSizeX = Max(1, NewItemGridSizeX);
	ItemGridSizeY = Max(1, NewItemGridSizeY);
}

defaultproperties
{
	ItemSkelModel=None
	ItemUITexture=None
	ItemGridSizeX=1
	ItemGridSizeY=1
}