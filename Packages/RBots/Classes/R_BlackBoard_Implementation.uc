//==============================================================================
//	R_BlackBoard_Implementation
//	Implementation of the R_BlackBoard class
//==============================================================================
class R_BlackBoard_Implementation extends R_BlackBoard;

const KeyValueStoreClass = Class'RBots.R_KeyValueStore_Implementation';
var private R_KeyValueStore KeyValueStore;

//------------------------------------------------------------------------------

function Initialize()
{
	Super.Initialize();
	InitializeKeyValueStore();
}

function InitializeKeyValueStore()
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{
		LogString = CommonError_InvalidRBots;
		GoTo FailWithLogString;
	}

	KeyValueStore = R_KeyValueStore(LocalRBots.CreateRBotsObject(KeyValueStoreClass, Self));
	if(KeyValueStore == None)
	{
		LogString = "Failed to instantiate KeyValueStore";
		GoTo FailWithLogString;
	}

	return;

FailWithLogString:
	LogString = "InitializeKeyValueStore failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

//------------------------------------------------------------------------------

function bool Add(Name Key, int TypeCode)			{ return KeyValueStore.Add(Key, TypeCode); }
function bool Get(Name Key, out R_Variant OutValue)	{ return KeyValueStore.Get(Key, OutValue); }
function bool Set(Name Key, R_Variant Value)		{ return KeyValueStore.Set(Key, Value); }

function int GetMaxKeys()							{ return KeyValueStore.GetMaxKeys(); }
function int GetNumKeys()							{ return KeyValueStore.GetNumKeys(); }

function bool GetKeyTypeAtIndex(int Index, out Name OutKey, out int OutTypeCode)
{
	return KeyValueStore.GetKeyTypeAtIndex(Index, OutKey, OutTypeCode);
}