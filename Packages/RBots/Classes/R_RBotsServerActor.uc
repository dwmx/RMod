//==============================================================================
//	R_RBotsServerActor
//	This Actor should be spawned as a ServerActor in your Server's ini
//	This Actor takes care of all bot management and map data setup
//==============================================================================
class R_RBotsServerActor extends Actor config(RBots);

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'RBotsServerActor';

const MAP_DATA_ARRAY_SIZE = 128;
struct MapData
{
	var String MapName;
	var String DataClass;
};
var config MapData MapDataArray[128];

const AssetManagerClass = Class'RBots.R_VirtualAssetManager_Implementation';
var private R_VirtualAssetManager AssetManager;

const BotManagerClass = Class'RBots.R_BotManager';
var private R_BotManager BotManager;

var Class<R_DynamicMapData> LoadedMapDataClass;
var private R_DynamicMapData LoadedMapData;

const NavQueryInterfaceClass = Class'RBots.R_NavQueryInterface_Impl';
var private R_NavQueryInterface NavQueryInterface;

//------------------------------------------------------------------------------

final function R_VirtualAssetManager GetAssetManager()		{ return AssetManager; }
final function R_BotManager GetBotManager()					{ return BotManager; }
final function R_DynamicMapData GetMapData()				{ return LoadedMapData; }
final function R_NavQueryInterface GetNavQueryInterface()	{ return NavQueryInterface; }

//------------------------------------------------------------------------------

function R_RBotsObject CreateRBotsObject(
	Class<R_RBotsObject> RBotsObjectClass,
	optional R_RBotsObject OptionalOuter,
	optional bool bDeferInitialization)
{
	local String LogString;
	local R_RBotsObject NewObject;

	if(RBotsObjectClass == None)
	{
		LogString = "CreateRBotsObject failed -- Bad RBotsObjectClass" @ RBotsObjectClass;
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
		return None;
	}

	if(OptionalOuter == None)
	{
		NewObject = new(Self) RBotsObjectClass;
	}
	else
	{
		NewObject = new(OptionalOuter) RBotsObjectClass;
	}

	if(NewObject == None)
	{
		LogString = "CreateRBotsObject failed -- Instantiation failed for class" @ RBotsObjectClass;
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
		return None;
	}

	NewObject.SetRBotsServerActor(Self);
	NewObject.BaseCreated();
	if(!bDeferInitialization)
	{
		NewObject.Initialize();
	}
	return NewObject;
}

//------------------------------------------------------------------------------

event BeginPlay()
{
	local String CurrentMapName;
	local String DataClassName;
	local bool bValidMapDataClass;
	local bool bLoadedMapData;
	local Class<R_DynamicMapData> DynamicMapDataClass;

	Super.BeginPlay();
	Utilities.Static.RLog("RBots spawned", LogCategory);
	SaveConfig();

	// Get current map name
	CurrentMapName = GetCurrentMapName();

	// Find matching MapData entry for the current map name
	Utilities.Static.RLog("Locating MapData for current map: '" $ CurrentMapName $ "'", LogCategory);
	bValidMapDataClass = TryFindMapDataForMapName(CurrentMapName, DataClassName);
	if(!bValidMapDataClass)
	{
		Utilities.Static.RLog("Failed to locate configured MapData for current map: '" $ CurrentMapName $ "' -- check RBots.R_RBotsServerActor.MapDataArray in your configuration file", LogCategory);
	}
	else
	{
		Utilities.Static.RLog("Located configured MapData for current map: '" $ CurrentMapName $ "': " $ DataClassName $ "'", LogCategory);
		bLoadedMapData = TryLoadMapDataClass(DataClassName, DynamicMapDataClass);
		if(bLoadedMapData)
		{
			Utilities.Static.RLog("Spawning MapData from class" @ DynamicMapDataClass, LogCategory);
			LoadedMapData = Spawn(DynamicMapDataClass);
			LoadedMapDataClass = DynamicMapDataClass;
		}
	}

	// Initialize manager classes
	AssetManager = R_VirtualAssetManager(CreateRBotsObject(AssetManagerClass,,true));
	AssetManager.Initialize(); // This is deferred because Initialize triggers PreCache assets
	BotManager = R_BotManager(CreateRBotsObject(BotManagerClass));
	NavQueryInterface = R_NavQueryInterface(CreateRBotsObject(NavQueryInterfaceClass));
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

function R_DynamicMapData GetLoadedMapData()
{
	return LoadedMapData;
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