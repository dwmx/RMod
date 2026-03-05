//==============================================================================
//	R_ArpgItem
//==============================================================================
class R_ArpgItem extends R_ArpgObject;

var private R_ArpgTag ItemTag;
var private int ItemUID;

var private int ItemGridSizeX;
var private int ItemGridSizeY;

const ITEM_RARITY_NORMAL = 0;
const ITEM_RARITY_MAGIC = 1;
const ITEM_RARITY_RARE = 2;
const ITEM_RARITY_UNIQUE = 3;

var private String ItemSpecialString;
var private String ItemTypeString;
var private int ItemRarity;

struct R_ArpgAffixInstance
{
	var Class<R_ArpgAffix> AffixClass;
	var int Parameters;
};
var private R_ArpgAffixInstance AffixInstances[32];
var private int AffixInstanceCount;

function int GetItemUID() { return ItemUID; }
function SetItemUID(int NewItemUID) { ItemUID = NewItemUID; }

//------------------------------------------------------------------------------

function AddAffix(Class<R_ArpgAffix> AffixClass, int Parameters)
{
	local int i;

	if(AffixInstanceCount >= ArrayCount(AffixInstances) || AffixClass == None)
	{
		return;
	}

	// Make sure an Affix of this class is not already present
	for(i = 0; i < AffixInstanceCount; ++i)
	{
		if(AffixInstances[i].AffixClass == AffixClass)
		{
			return;
		}
	}

	AffixInstances[AffixInstanceCount].AffixClass = AffixClass;
	AffixInstances[AffixInstanceCount].Parameters = Parameters;
	++AffixInstanceCount;
}

function int GetAffixCount()
{
	return AffixInstanceCount;
}

function bool GetAffix(int Index, out Class<R_ArpgAffix> OutAffixClass, out int OutParameters)
{
	if(Index < 0 || Index >= AffixInstanceCount)
	{
		return false;
	}

	OutAffixClass = AffixInstances[Index].AffixClass;
	OutParameters = AffixInstances[Index].Parameters;
	return true;
}

function String GetAffixInspectionString(int AffixIndex)
{
	local Class<R_ArpgAffix> AffixClass;
	local int Parameters;

	if(AffixIndex >= 0 && AffixIndex < AffixInstanceCount)
	{
		AffixClass = AffixInstances[AffixIndex].AffixClass;
		Parameters = AffixInstances[AffixIndex].Parameters;
		if(AffixClass != None)
		{
			return AffixClass.Static.GetAffixInspectionString(Parameters);
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
	// Initialize AffixInstances
	AffixInstanceCount = 0;

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