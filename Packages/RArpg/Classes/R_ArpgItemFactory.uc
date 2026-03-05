//==============================================================================
//  R_ArpgItemFactory
//  Provides the interface and functionality for creating items
//==============================================================================
class R_ArpgItemFactory extends R_ArpgObject;

const DataStoreClass_ItemTypes = Class'RArpg.R_ArpgData_ItemTypeDataStore';
var private R_ArpgData_ItemTypeDataStore DataStore_ItemTypes;

const DataStoreClass_ItemInstructions = Class'RArpg.R_ArpgData_ItemInstructionsDataStore';
var private R_ArpgData_ItemInstructionsDataStore DataStore_ItemInstructions;

function InitializeArpgObject()
{
    DataStore_ItemTypes = R_ArpgData_ItemTypeDataStore(ArpgLib.Static.CreateArpgObject(DataStoreClass_ItemTypes, Self));
	DataStore_ItemInstructions = R_ArpgData_ItemInstructionsDataStore(ArpgLib.Static.CreateArpgObject(DataStoreClass_ItemInstructions, Self));
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
    Item.SetItemGridSize(ItemType.ItemSizeX, ItemType.ItemSizeY);
    Item.SetItemUID(Rand(5000) + 3000);

	// These are just some test affixes
	// These need to be moved into a magical item property generator tree, and set up as R_ArpgAffixInstructions
    Item.AddAffix(Class'RArpg.R_ArpgAffix_AllSkills', 2);
    Item.AddAffix(Class'RArpg.R_ArpgAffix_MaxHealth', Rand(30) + 20);
    Item.AddAffix(Class'RArpg.R_ArpgAffix_MaxHealthPercent', Rand(15) + 15);
    Item.AddAffix(Class'RArpg.R_ArpgAffix_MaxMana', Rand(30) + 20);
	Item.AddAffix(Class'RArpg.R_ArpgAffix_MaxManaPercent', Rand(15) + 15);
	
    return Item;
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