//==============================================================================
//	R_VirtualAssetManager_Implementation
//==============================================================================
class R_VirtualAssetManager_Implementation extends R_VirtualAssetManager config(RBots);

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'VirtualAssetManager';

var private R_VirtualAsset LoadedAssets[256];
var private int NumLoadedAssets;

var private config Class<R_VirtualAsset> PreCacheAssetClasses[128];

function Initialize()
{
	NumLoadedAssets = 0;
	LoadPreCacheAssets();
}

function LoadPreCacheAssets()
{
	local int BeforeCount;
	local int i;

	Utilities.Static.RLog("Loading PreCache assets", LogCategory);

	BeforeCount = NumLoadedAssets;
	for(i = 0; i < ArrayCount(PreCacheAssetClasses); ++i)
	{
		if(PreCacheAssetClasses[i] != None)
		{
			LoadAsset(PreCacheAssetClasses[i]);
		}
	}
	Utilities.Static.RLog("Loaded" @ NumLoadedAssets - BeforeCount @ "PreCache assets", LogCategory);
}

function R_VirtualAsset FindLoadedVirtualAsset(Class<R_VirtualAsset> AssetClass)
{
	local int i;

	for(i = 0; i < NumLoadedAssets; ++i)
	{
		if(LoadedAssets[i] != None && LoadedAssets[i].Class == AssetClass)
		{
			return LoadedAssets[i];
		}
	}
	return None;
}

function R_VirtualAsset LoadAsset(Class<R_VirtualAsset> AssetClass)
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;
	local R_VirtualAsset Asset;

	if(AssetClass == None)
	{	// Invalid AssetClass check
		LogString = "Invalid AssetClass:" @ AssetClass;
		GoTo LoadFailWithLogString;
	}

	Asset = FindLoadedVirtualAsset(AssetClass);
	if(Asset != None)
	{
		return Asset;
	}

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{	// Cannot load assets without access to RBotsServerActor
		LogString = "Invalid RBotsServerActor reference";
		GoTo LoadFailWithLogString;
	}

	if(NumLoadedAssets >= ArrayCount(LoadedAssets))
	{	// Array overflow
		LogString = "Array overflow";
		GoTo LoadFailWithLogString;
	}

	Utilities.Static.RLog("Loading asset from class" @ AssetClass, LogCategory);
	Asset = R_VirtualAsset(LocalRBots.CreateRBotsObject(AssetClass, Self));
	if(Asset == None)
	{
		LogString = "Instantiation failed";
		GoTo LoadFailWithLogString;
	}

	Asset.Load();
	LoadedAssets[NumLoadedAssets] = Asset;
	++NumLoadedAssets;
	return Asset;

LoadFailWithLogString:
	LogString = "LoadAsset failed for class" @ AssetClass @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return None;
}

defaultproperties
{
	PreCacheAssetClasses(0)=Class'RBots.R_BehaviorTree_Wander'
}