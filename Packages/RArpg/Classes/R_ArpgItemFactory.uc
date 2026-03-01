//==============================================================================
//  R_ArpgItemFactory
//  Provides the interface and functionality for creating items
//==============================================================================
class R_ArpgItemFactory extends R_ArpgObject;

const DataStoreClass_ItemTypes = Class'RArpg.R_ArpgData_ItemTypeDataStore';
var private R_ArpgData_ItemTypeDataStore DataStore_ItemTypes;

function InitializeArpgObject()
{
    DataStore_ItemTypes = R_ArpgData_ItemTypeDataStore(ArpgLib.Static.CreateArpgObject(DataStoreClass_ItemTypes, Self));
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