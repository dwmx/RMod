//==============================================================================
//	R_ArpgItem
//==============================================================================
class R_ArpgItem extends R_ArpgObject;

var private R_ArpgTag ItemTag;

var private int ItemGridSizeX;
var private int ItemGridSizeY;

const ITEM_RARITY_NORMAL = 0;
const ITEM_RARITY_MAGIC = 1;
const ITEM_RARITY_RARE = 2;
const ITEM_RARITY_UNIQUE = 3;

var private String ItemSpecialString;
var private String ItemTypeString;
var private int ItemRarity;

struct R_ArpgItemModifierInstance
{
	var Class<R_ArpgItemModifier> ItemModifierClass;
	var int Parameters;
};
var private R_ArpgItemModifierInstance ItemModifierInstances[16];
var private int ItemModifierInstanceCount;

//------------------------------------------------------------------------------

function AddItemModifier(Class<R_ArpgItemModifier> ItemModifierClass, int Parameters)
{
	local int i;

	if(ItemModifierInstanceCount >= ArrayCount(ItemModifierInstances) || ItemModifierClass == None)
	{
		return;
	}

	// Make sure an ItemModifier of this class is not already present
	for(i = 0; i < ItemModifierInstanceCount; ++i)
	{
		if(ItemModifierInstances[i].ItemModifierClass == ItemModifierClass)
		{
			return;
		}
	}

	ItemModifierInstances[ItemModifierInstanceCount].ItemModifierClass = ItemModifierClass;
	ItemModifierInstances[ItemModifierInstanceCount].Parameters = Parameters;
	++ItemModifierInstanceCount;
}

function int GetItemModifierCount()
{
	return ItemModifierInstanceCount;
}

function String GetItemModifierInspectionString(int ItemModifierIndex)
{
	local Class<R_ArpgItemModifier> ItemModifierClass;
	local int Parameters;

	if(ItemModifierIndex >= 0 && ItemModifierIndex < ItemModifierInstanceCount)
	{
		ItemModifierClass = ItemModifierInstances[ItemModifierIndex].ItemModifierClass;
		Parameters = ItemModifierInstances[ItemModifierIndex].Parameters;
		if(ItemModifierClass != None)
		{
			return ItemModifierClass.Static.GetItemModifierInspectionString(Parameters);
		}
	}

	return "";
}

function String GetItemSpecialName()
{
	return ItemSpecialString;
}

function String GetItemTypeString()
{
	return ItemTypeString;
}

function int GetItemRarity()
{
	return ItemRarity;
}

function SetItemTag(R_ArpgTag NewItemTag)
{
	ItemTag = NewItemTag;
}

function R_ArpgTag GetItemTag()
{
	return ItemTag;
}

function InitializeArpgObject()
{
	// Initialize ItemModifierInstances
	ItemModifierInstanceCount = 0;

	// Force clamping on defaultproperties
	SetItemGridSize(ItemGridSizeX, ItemGridSizeY);

	// Some test stuff
	ItemTypeString = "Broad Sword";
	ItemSpecialString = "Ragnar's Steel";
	ItemRarity = ITEM_RARITY_UNIQUE;
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
	ItemGridSizeX=1
	ItemGridSizeY=1
}