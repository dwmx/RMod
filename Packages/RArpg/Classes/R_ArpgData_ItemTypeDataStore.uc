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

	// RomanSword
	ItemTag = TagLib.Static.MakeTag('Item','Weapon','Sword','RomanSword');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Roman Sword", 1, 2));

	// BroadSword
	ItemTag = TagLib.Static.MakeTag('Item','Weapon','Sword','BroadSword');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Broad Sword", 1, 3));

	// WorkSword
	ItemTag = TagLib.Static.MakeTag('Item','Weapon','Sword','WorkSword');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Work Sword", 2, 3));

	// BattleSword
	ItemTag = TagLib.Static.MakeTag('Item','Weapon','Sword','BattleSword');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Battle Sword", 2, 3));

	// HandAxe
	ItemTag = TagLib.Static.MakeTag('Item','Weapon','Axe','HandAxe');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Hand Axe", 1, 2));

	// BattleAxe
	ItemTag = TagLib.Static.MakeTag('Item','Weapon','Axe','BattleAxe');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Battle Axe", 2, 3));

	// BattleHammer
	ItemTag = TagLib.Static.MakeTag('Item','Weapon','Hammer','BattleHammer');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Battle Hammer", 2, 3));
	
	//--------------------------------------------------------------------------
	//	Shields

	// WoodShield
	ItemTag = TagLib.Static.MakeTag('Item','Shield','WoodShield');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Wood Shield", 2, 3));

	//--------------------------------------------------------------------------
	//	Heads

	// SkullHead
	ItemTag = TagLib.Static.MakeTag('Item','Head','SkullHead');
	DataStore.AddData(ItemTag, CreateItemType(ItemTag, "Skull Head", 2, 2));
}