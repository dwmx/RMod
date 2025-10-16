//==============================================================================
//	R_VirtualAssetManager_Implementation
//==============================================================================
class R_VirtualAssetManager_Implementation extends R_VirtualAssetManager;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'VirtualAssetManager';

var private R_VirtualAsset LoadedAssets[256];
var private int NumLoadedAssets;

var private Class<R_VirtualAsset> PreCacheAssetClasses[128];

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
	local R_VirtualAsset Asset;

	if(AssetClass == None)
	{
		return None;
	}

	Asset = FindLoadedVirtualAsset(AssetClass);
	if(Asset != None)
	{
		return Asset;
	}

	if(NumLoadedAssets >= ArrayCount(LoadedAssets))
	{
		LogString = "LoadAsset failed to load asset from class" @ AssetClass @ "-- array overflow";
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
		return None;
	}

	Utilities.Static.RLog("Loading asset from class" @ AssetClass, LogCategory);
	Asset = new(None) AssetClass;
	if(Asset == None)
	{
		LogString = "LoadAsset failed to load asset from class" @ AssetClass @"-- instantiation failed";
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
		return None;
	}

	Asset.Load();
	LoadedAssets[NumLoadedAssets] = Asset;
	++NumLoadedAssets;
}