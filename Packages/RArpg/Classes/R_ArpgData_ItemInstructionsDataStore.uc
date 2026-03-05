//==============================================================================
//	R_ArpgData_ItemInstructionsDataStore
//==============================================================================
class R_ArpgData_ItemInstructionsDataStore extends R_ArpgDataStore;

const DataStoreClass = Class'RArpgCore.R_ArpgDataStoreArray';
var private R_ArpgDataStore DataStore;

function InitializeArpgObject()
{
	Log("Loading Item Instructions Data Store from class" @ Self.Class);
	DataStore = R_ArpgDataStore(ArpgLib.Static.CreateArpgObject(DataStoreClass, Self));
	PopulateDataStore();
}

function PopulateDataStore()
{}