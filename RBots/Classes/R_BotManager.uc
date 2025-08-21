//==============================================================================
//	R_BotManager
//	This Actor should be spawned as a ServerActor in your Server's ini
//	This Actor takes care of all bot management and map data setup
//==============================================================================
class R_BotManager extends Actor config(RBots);

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BotManager';

const MAP_DATA_ARRAY_SIZE = 128;
struct MapData
{
	var String MapName;
	var String DataClass;
};
var config MapData MapDataArray[128];

var Class<R_DynamicMapData> LoadedMapDataClass;

event BeginPlay()
{
	local String CurrentMapName;
	local String DataClassName;
	local bool bValidMapDataClass;
	local bool bLoadedMapData;
	local Class<R_DynamicMapData> DynamicMapDataClass;

	Super.BeginPlay();
	Utilities.Static.RLog("BotManager spawned", LogCategory);
	SaveConfig();

	// Get current map name
	CurrentMapName = GetCurrentMapName();

	// Find matching MapData entry for the current map name
	Utilities.Static.RLog("Locating MapData for current map: '" $ CurrentMapName $ "'", LogCategory);
	bValidMapDataClass = TryFindMapDataForMapName(CurrentMapName, DataClassName);
	if(!bValidMapDataClass)
	{
		Utilities.Static.RLog("Failed to locate configured MapData for current map: '" $ CurrentMapName $ "' -- check RBots.R_BotManager.MapDataArray in your configuration file", LogCategory);
	}
	else
	{
		Utilities.Static.RLog("Located configured MapData for current map: '" $ CurrentMapName $ "': " $ DataClassName $ "'", LogCategory);
		bLoadedMapData = TryLoadMapDataClass(DataClassName, DynamicMapDataClass);
		if(bLoadedMapData)
		{
			Utilities.Static.RLog("Spawning MapData from class" @ DynamicMapDataClass, LogCategory);
			Spawn(DynamicMapDataClass);
			LoadedMapDataClass = DynamicMapDataClass;
		}
	}
}

function String GetCurrentMapName()
{
	local String LocalURL;
	local String MapName;

	LocalURL = Level.GetLocalURL();
	LocalURL = Caps(LocalURL);

	MapName = Mid(LocalURL, InStr(LocalURL, "/") + 1);

	if(InStr(MapName, "?") != -1)
	{
		MapName = Left(MapName, InStr(MapName, "?"));
	}

	if(InStr(MapName, ".RUN") != -1)
	{
		MapName = Left(MapName, InStr(MapName, ".RUN"));
	}
	
	return MapName;
}

function bool TryFindMapDataForMapName(String MapName, out String OutDataClass)
{
	local String MapNameCaps;
	local String DataClass;
	local bool bFoundDataClass;
	local int i;

	MapNameCaps = Caps(MapName);

	bFoundDataClass = false;
	for(i = 0; i < MAP_DATA_ARRAY_SIZE; ++i)
	{
		if(Caps(MapDataArray[i].MapName) == MapNameCaps)
		{
			DataClass = MapDataArray[i].DataClass;
			bFoundDataClass = true;
		}
	}

	if(!bFoundDataClass)
	{
		return false;
	}

	OutDataClass = DataClass;
	return bFoundDataClass;
}

function bool TryLoadMapDataClass(String DataClass, out Class<R_DynamicMapData> OutLoadedClass)
{
	local Class<R_DynamicMapData> DynamicMapDataClass;
	local int i;

	Utilities.Static.RLog("Attempting to load MapDataClass '" $ DataClass $ "'", LogCategory);
	DynamicMapDataClass = Class<R_DynamicMapData>(DynamicLoadObject(DataClass, Class'Class'));

	if(DynamicMapDataClass == None)
	{
		Utilities.Static.RLog("Failed to load MapDataClass: '" $ DataClass $ "'", LogCategory);
		return false;
	}

	OutLoadedClass = DynamicMapDataClass;
	Utilities.Static.RLog("Loaded MapDataClass: '" $ DataClass $ "': " @ OutLoadedClass, LogCategory);
	return true;
}

/**
	SpawnBot
	Main function for adding bots to the game
	
	bDeferredInitialization is provided as a means for callers to perform additional bot
	configuration before they begin playing
	NOTE: If caller provides bDeferredInitialization = true, they are responsible for calling
	R_Bot.InitializeBot
*/
function R_Bot SpawnBot(optional bool bDeferredInitialization)
{
	local R_Bot NewBot;
	local PlayerPawn NewPlayerPawn;
	local NavigationPoint StartPoint;

	if(bDeferredInitialization)
	{
		Utilities.Static.RLog("Spawning Bot with deferred initialization", LogCategory);
	}
	else
	{
		Utilities.Static.RLog("Spawning Bot", LogCategory);
	}
	
	StartPoint = Level.Game.FindPlayerStart(None);

	NewBot = Spawn(Class'RBots.R_Bot');
	NewPlayerPawn = Spawn(Class'RuneI.PlayerAlric',,,StartPoint.Location, StartPoint.Rotation);
	
	NewPlayerPawn.SetOwner(NewBot);
	NewBot.PossessedPlayerPawn(NewPlayerPawn);

	if(!bDeferredInitialization)
	{
		NewBot.InitializeBot();
	}

	return NewBot;
}

function RemoveBot(R_Bot Bot)
{
	local PlayerPawn P;
	local PlayerReplicationInfo PRI;

	if(Bot == None)
	{
		return;
	}

	Utilities.Static.RLog("Removing Bot:" @ Bot, LogCategory);
	P = Bot.GetOwnedPlayerPawn();
	PRI = Bot.GetOwnedPRI();

	if(P != None)
	{
		P.Destroy();
	}

	if(PRI != None)
	{
		PRI.Destroy();
	}

	Bot.Destroy();
}

defaultproperties
{
	RemoteRole=ROLE_None
	MapDataArray(0)=(MapName="DM-Bothvar",DataClass="RBots.R_MapData_Bothvar")
	MapDataArray(1)=(MapName="DM-Hildir",DataClass="RBots.R_MapData_Hildir")
	MapDataArray(2)=(MapName="DM-Hudson",DataClass="RBots.R_MapData_Hudson")
	MapDataArray(3)=(MapName="DM-Wonderland",DataClass="RBots.R_MapData_Wonderland")
	MapDataArray(4)=(MapName="DM-Constable",DataClass="RBots.R_MapData_Constable")
	MapDataArray(5)=(MapName="DM-Thorstadt",DataClass="RBots.R_MapData_Thorstadt")
	MapDataArray(5)=(MapName="AR-8on8-ChampionsER",DataClass="RBots.R_MapData_Champions8on8ER");
}