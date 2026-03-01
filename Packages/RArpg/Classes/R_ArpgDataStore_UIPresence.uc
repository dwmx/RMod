//==============================================================================
//	R_ArpgDataStore_UIPresence
//==============================================================================
class R_ArpgDataStore_UIPresence extends R_ArpgObject;

const DataStoreClass = Class'RArpgCore.R_ArpgDataStoreArray';
var private R_ArpgDataStore DataStore;

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

function R_ArpgDataObject_UIPresence CreateUIPresence(
	Texture DrawTexture,
	float TexX, float TexY, float TexW, float TexH,
	optional Sound PickupSound,
	optional Sound PlaceSound)
{
	local R_ArpgDataObject_UIPresence Data;

	Data = R_ArpgDataObject_UIPresence(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgDataObject_UIPresence', Self));
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
	
	//--------------------------------------------------------------------------
	//	Shields
	DataStore.AddData(	// WoodShield
		TagLib.Static.MakeTag('Item','Shield','WoodShield'),
		CreateUIPresence(Texture'RArpg.UIWoodShield', 0.0, 0.0, 256.0, 256.0)
	);
}