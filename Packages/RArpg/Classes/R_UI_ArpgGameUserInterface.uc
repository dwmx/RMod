//==============================================================================
//	R_UI_ArpgGameUserInterface
//	Top-level Game User interface class for Arpg mode
//==============================================================================
class R_UI_ArpgGameUserInterface extends RGameUI.R_UI_GameUserInterface;

const ArpgLib = Class'RArpgCore.R_ArpgLibrary';

// UIPresence DataStore
var private R_ArpgData_UIPresenceDataStore DataStoreUIPresence;

// UI Commands
const UICommand_Inventory = 'Inventory';

function ConstructUI()
{
	local R_UI_ArpgGameRootWindow GameRootWindow;

	GameRootWindow = R_UI_ArpgGameRootWindow(GetRootWindow());
	GameRootWindow.SetGameUserInterface(Self);

	//--------------------------------------------------------------------------
	// Load the UIPresence data store
	DataStoreUIPresence = R_ArpgData_UIPresenceDataStore(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgData_UIPresenceDataStore', Self));
}

function R_ArpgData_UIPresenceDataStore GetDataStoreUIPresence()
{
	return DataStoreUIPresence;
}

function InputCommand(Name Command)
{
	switch(Command)
	{
		case UICommand_Inventory:	HandleCommand_Inventory();	break;
	}	
}

function HandleCommand_Inventory() {}
function SetItemContainerSet(R_ArpgItemContainerSet NewItemContainerSet) {}

function bool IsWindowVisible(Name WindowName) { return false; }

defaultproperties
{
	RootWindowClass=Class'RArpg.R_UI_ArpgGameRootWindow'
}