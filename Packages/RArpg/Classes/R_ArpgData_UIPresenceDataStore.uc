//==============================================================================
//	R_ArpgData_UIPresenceDataStore
//	Holds all of the UI data used by items
//	Textures, texture draw parameters, sounds, etc
//==============================================================================
class R_ArpgData_UIPresenceDataStore extends R_ArpgDataStore;

const DataStoreClass = Class'RArpgCore.R_ArpgDataStoreArray';
var private R_ArpgDataStore DataStore;

//------------------------------------------------------------------------------

function bool GetUIPresence(R_ArpgItem Item, out R_ArpgData_UIPresence OutUIPresence)
{
	local R_ArpgObject Data;
	local bool bResult;

	if(Item == None)
	{
		return false;
	}

	bResult = DataStore.GetData(Item.GetItemTag(), Data);
	OutUIPresence = R_ArpgData_UIPresence(Data);
	return bResult;
}

//------------------------------------------------------------------------------

function InitializeArpgObject()
{
	Log("Loading UIPresence Data Store from class" @ Self.Class);
	DataStore = R_ArpgDataStore(ArpgLib.Static.CreateArpgObject(DataStoreClass, Self));
	PopulateDataStore();
}

function LogDumpArpgObject()
{
	Super.LogDumpArpgObject();
	DataStore.LogDumpArpgObject();
}

function R_ArpgData_UIPresence CreateUIPresence(
	Texture DrawTexture,
	float TexX, float TexY, float TexW, float TexH,
	optional Sound PickupSound,
	optional Sound PlaceSound)
{
	local R_ArpgData_UIPresence Data;

	Data = R_ArpgData_UIPresence(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgData_UIPresence', Self));
	Data.DrawTexture = DrawTexture;
	Data.TexX = TexX;
	Data.TexY = TexY;
	Data.TexW = TexW;
	Data.TexH = TexH;
	return Data;
}

//------------------------------------------------------------------------------

function PopulateDataStore()
{
	//--------------------------------------------------------------------------
	//	Weapons
	DataStore.AddData(	// BroadSword
		TagLib.Static.MakeTag('Item','Weapon','Sword','BroadSword'),
		CreateUIPresence(Texture'RArpg.UIBroadSword', 86.0, 0.0, 86.0, 256.0)
	);
	
	DataStore.AddData(	// BattleAxe
		TagLib.Static.MakeTag('Item','Weapon','Axe','BattleAxe'),
		CreateUIPresence(Texture'RArpg.UIBattleAxe', 42.0, 0.0, 172.0, 256.0)
	);

	DataStore.AddData(	// BattleHammer
		TagLib.Static.MakeTag('Item','Weapon','Hammer','BattleHammer'),
		CreateUIPresence(Texture'RArpg.UIBattleHammer', 42.0, 0.0, 172.0, 256.0)
	);

	//--------------------------------------------------------------------------
	//	Shields
	DataStore.AddData(	// WoodShield
		TagLib.Static.MakeTag('Item','Shield','WoodShield'),
		CreateUIPresence(Texture'RArpg.UIWoodShield', 0.0, 0.0, 256.0, 256.0)
	);
}