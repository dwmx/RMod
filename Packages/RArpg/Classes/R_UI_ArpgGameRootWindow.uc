//==============================================================================
//	R_UI_ArpgGameRootWindow
//	Root Window class for the Arpg Game UI
//	Needs to implement access to the data that the rest of the UI uses
//==============================================================================
class R_UI_ArpgGameRootWindow extends R_UI_ArpgRootWindow;

// The owning Game UI
var private R_UI_ArpgGameUserInterface GameUserInterface;

//------------------------------------------------------------------------------

function SetGameUserInterface(R_UI_ArpgGameUserInterface NewGameUserInterface)
{
	GameUserInterface = NewGameUserInterface;
}

function R_ArpgDataStore_UIPresence GetDataStoreUIPresence()
{
	if(GameUserInterface != None)
	{
		return GameUserInterface.GetDataStoreUIPresence();
	}
	return None;
}

//------------------------------------------------------------------------------

function bool GetItemUITextureInfo(
	R_ArpgItem Item,
	out Texture OutDrawTexture,
	out float OutTexX, out float OutTexY,
	out float OutTexW, out float OutTexH)
{
	local R_ArpgDataStore_UIPresence DataStore;
	local R_ArpgData_UIPresence Data;

	DataStore = GetDataStoreUIPresence();
	if(DataStore != None)
	{
		if(DataStore.GetUIPresence(Item, Data))
		{
			OutDrawTexture = Data.DrawTexture;
			OutTexX = Data.TexX;
			OutTexY = Data.TexY;
			OutTexW = Data.TexW;
			OutTexH = Data.TexH;
			return true;
		}
	}

	// Failed to retrieve texture info from data store
	OutDrawTexture = None;
	OutTexX = 0.0;
	OutTexY = 0.0;
	OutTexW = 0.0;
	OutTexH = 0.0;
	return false;
}