//==============================================================================
//	R_ArpgData_ItemTypeDataStore
//==============================================================================
class R_ArpgData_ItemTypeDataStore extends R_ArpgDataStore;

const DataStoreClass = Class'RArpgCore.R_ArpgDataStoreArray';
var private R_ArpgDataStore DataStore;

//------------------------------------------------------------------------------

function bool GetItemType(R_ArpgTag ItemTag, out R_ArpgData_ItemType OutItemType)
{
	local R_ArpgObject Data;
	local bool bResult;

	bResult = DataStore.GetData(ItemTag, Data);
	OutItemType = R_ArpgData_ItemType(Data);
	return bResult;
}

//------------------------------------------------------------------------------

function InitializeArpgObject()
{
	Log("Loading ItemType Data Store from class" @ Self.Class);
	DataStore = R_ArpgDataStore(ArpgLib.Static.CreateArpgObject(DataStoreClass, Self));
	PopulateDataStore();
}

function LogDumpArpgObject()
{
	Super.LogDumpArpgObject();
	DataStore.LogDumpArpgObject();
}

function R_ArpgData_ItemType CreateItemType(
	R_ArpgTag ItemTag,
	String ItemTypeString,
	int ItemSizeX, int ItemSizeY)
{
	local R_ArpgData_ItemType Data;

	Data = R_ArpgData_ItemType(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgData_ItemType', Self));
	Data.ItemTag = ItemTag;
	Data.ItemTypeString = ItemTypeString;
	Data.ItemSizeX = ItemSizeX;
	Data.ItemSizeY = ItemSizeY;
	return Data;
}

//------------------------------------------------------------------------------

function PopulateDataStore()
{
	local R_ArpgTag ItemTag;

	//--------------------------------------------------------------------------
	//	Weapons

	// BroadSword
	ItemTag = TagLib.Static.MakeTag('Item','Weapon','Sword','BroadSword');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Broad Sword", 1, 3));

	ItemTag = TagLib.Static.MakeTag('Item','Weapon','Axe','BattleAxe');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Battle Axe", 2, 3));
	
	//--------------------------------------------------------------------------
	//	Shields

	// WoodShield
	ItemTag = TagLib.Static.MakeTag('Item','Shield','WoodShield');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Wood Shield", 2, 3));
}