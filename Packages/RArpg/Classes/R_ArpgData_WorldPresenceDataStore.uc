//==============================================================================
//	R_ArpgData_WorldPresenceDataStore
//	Stores world-presence data information for items
//==============================================================================
class R_ArpgData_WorldPresenceDataStore extends R_ArpgDataStore;

const DataStoreClass = Class'RArpgCore.R_ArpgDataStoreArray';
var private R_ArpgDataStore DataStore;

//------------------------------------------------------------------------------

function bool GetWorldPresence(R_ArpgItem Item, out R_ArpgData_WorldPresence OutWorldPresence)
{
	local R_ArpgObject Data;
	local bool bResult;

	if(Item == None)
	{
		return false;
	}

	bResult = DataStore.GetData(Item.GetItemTag(), Data);
	OutWorldPresence = R_ArpgData_WorldPresence(Data);
	return bResult;
}

//------------------------------------------------------------------------------

function InitializeArpgObject()
{
	Log("Loading WorldPresence Data Store from class" @ Self.Class);
	DataStore = R_ArpgDataStore(ArpgLib.Static.CreateArpgObject(DataStoreClass, Self));
	PopulateDataStore();
}

function LogDumpArpgObject()
{
	Super.LogDumpArpgObject();
	DataStore.LogDumpArpgObject();
}

function R_ArpgData_WorldPresence CreateWorldPresence(
	SkelModel Skeletal)
{
	local R_ArpgData_WorldPresence Data;

	Data = R_ArpgData_WorldPresence(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgData_WorldPresence', Self));
	Data.Skeletal = Skeletal;
	return Data;
}

//------------------------------------------------------------------------------

function PopulateDataStore()
{
//--------------------------------------------------------------------------
	//	Weapons
	DataStore.AddData(	// BroadSword
		TagLib.Static.MakeTag('Item','Weapon','Sword','BroadSword'),
		CreateWorldPresence(SkelModel'weapons.broadsword')
	);

	DataStore.AddData(	// BattleSword
		TagLib.Static.MakeTag('Item','Weapon','Sword','BattleSword'),
		CreateWorldPresence(SkelModel'weapons.battlesword')
	);

	DataStore.AddData(	// BattleAxe
		TagLib.Static.MakeTag('Item','Weapon','Axe','BattleAxe'),
		CreateWorldPresence(SkelModel'weapons.battleaxe')
	);

	DataStore.AddData(	// BattleHammer
		TagLib.Static.MakeTag('Item','Weapon','Hammer','BattleHammer'),
		CreateWorldPresence(SkelModel'weapons.battlehammer')
	);
	
	//--------------------------------------------------------------------------
	//	Shields
	DataStore.AddData(	// WoodShield
		TagLib.Static.MakeTag('Item','Shield','WoodShield'),
		CreateWorldPresence(SkelModel'weapons.woodshield')
	);
}