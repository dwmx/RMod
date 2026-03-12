//==============================================================================
//  R_ArpgItemFactory
//  Provides the interface and functionality for creating items
//==============================================================================
class R_ArpgItemFactory extends R_ArpgObject;

const DataStoreClass_ItemTypes = Class'RArpg.R_ArpgData_ItemTypeDataStore';
var private R_ArpgData_ItemTypeDataStore DataStore_ItemTypes;

const DataStoreClass_ItemInstructions = Class'RArpg.R_ArpgData_ItemInstructionsDataStore';
var private R_ArpgData_ItemInstructionsDataStore DataStore_ItemInstructions;

var private int ItemInstantiationCount;

function InitializeArpgObject()
{
    DataStore_ItemTypes = R_ArpgData_ItemTypeDataStore(ArpgLib.Static.CreateArpgObject(DataStoreClass_ItemTypes, Self));
	DataStore_ItemInstructions = R_ArpgData_ItemInstructionsDataStore(ArpgLib.Static.CreateArpgObject(DataStoreClass_ItemInstructions, Self));
	ItemInstantiationCount = 0;
}

function R_ArpgItem InstantiateFromItemType(R_ArpgData_ItemType ItemType)
{
    local R_ArpgItem Item;

    if(ItemType == None)
    {
        return None;
    }

    Item = R_ArpgItem(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgItem'));
    Item.SetItemTag(ItemType.ItemTag);
	Item.SetItemTypeString(ItemType.ItemTypeString);
    Item.SetItemGridSize(ItemType.ItemSizeX, ItemType.ItemSizeY);
    Item.SetItemUID(Rand(5000) + 3000);

	// Test -- Apply some magical properties to the item using item instructions
	TestApplyItemInstructions(Item);

	// Test -- Cycle through the different rarities
	switch(ItemInstantiationCount % 5)
	{
	case 0: Item.SetItemRarityType('Normal'); Item.SetItemSpecialString(""); break;
	case 1: Item.SetItemRarityType('Magic'); break;
	case 2: Item.SetItemRarityType('Rare'); break;
	case 3: Item.SetItemRarityType('Unique'); break;
	case 4: Item.SetItemRarityType('Crafted'); break;
	}

	++ItemInstantiationCount;
    return Item;
}

function TestApplyItemInstructions(R_ArpgItem Item)
{
	local R_ArpgTag InstructionsTag;
	local R_ArpgData_ItemInstructions ItemInstructions;
	local int AffixInstructionCount;
	local Class<R_ArpgAffix> AffixClass;
	local int AffixParameters;
	local int i;

	InstructionsTag = TagLib.Static.MakeTag('Instruction','Unique','Weapon','OdinsBlade');
	DataStore_ItemInstructions.GetItemInstructions(InstructionsTag, ItemInstructions);

	AffixInstructionCount = ItemInstructions.GetAffixInstructionCount();
	for(i = 0; i < AffixInstructionCount; ++i)
	{
		ItemInstructions.RollAffix(i, AffixClass, AffixParameters);
		Item.AddAffix(AffixClass, AffixParameters);
	}

	Item.SetItemSpecialString(ItemInstructions.InstructionsString);
}

//------------------------------------------------------------------------------

function R_ArpgItem CreateItemFromTag(R_ArpgTag ItemTag)
{
    local R_ArpgData_ItemType ItemType;

    if(DataStore_ItemTypes.GetItemType(ItemTag, ItemType))
    {
        return InstantiateFromItemType(ItemType);
    }
    return None;
}