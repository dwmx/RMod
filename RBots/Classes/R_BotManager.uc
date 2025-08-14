//==============================================================================
//	R_BotManager
//	This Actor should be spawned as a ServerActor in your Server's ini
//	This Actor takes care of all bot management and map data setup
//==============================================================================
class R_BotManager extends Actor config(RBots);

const Utilities = Class'RBots.R_BotUtilities';

struct MapData
{
	var String MapName;
	var String DataClass;
};
var config MapData MapDataArray[128];

event BeginPlay()
{
	Super.BeginPlay();
	Utilities.Static.RLog("BotManager spawned");
	SaveConfig();
	
	Utilities.Static.RLog(Level.GetLocalURL());
	Utilities.Static.RLog(GetCurrentMapName());
}

function String GetCurrentMapName()
{
	local String LocalURL;
	local String MapName;

	LocalURL = Level.GetLocalURL();
	MapName = Mid(LocalURL, InStr(LocalURL, "/") + 1);
	MapName = Left(MapName, InStr(MapName, ".run"));
	return MapName;
}

function FindMapDataForCurrentMap()
{

}

defaultproperties
{
	RemoteRole=ROLE_None
	MapDataArray(0)=(MapName="DM-Hildir",DataClass="RBots.R_MapData_Hildir")
}