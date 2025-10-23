//==============================================================================
//	R_BehaviorActionInstance
//==============================================================================
class R_BehaviorActionInstance extends R_RBotsObject;

const LogCategory = 'BehaviorActionInstance';

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

function bool AddParameter(Name ParamName, int TypeCode)
{
	return KeyValueStore.Add(ParamName, TypeCode);
}

function bool GetParameter(Name ParamName, out R_Variant OutValue)
{
	return KeyValueStore.Get(ParamName, OutValue);
}