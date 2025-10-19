//==============================================================================
//	R_BlackBoard_Implementation
//	Implementation of the R_BlackBoard class
//==============================================================================
class R_BlackBoard_Implementation extends R_BlackBoard;

const KeyValueStoreClass = Class'RBots.R_KeyValueStore_Implementation';
var private R_KeyValueStore KeyValueStore;

function Initialize()
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{	// Need RBots reference
		LogString = "Invalid reference to RBotsServerActor";
		GoTo FailWithLogString;
	}

	KeyValueStore = R_KeyValueStore(LocalRBots.CreateRBotsObject(KeyValueStoreClass, Self));
	if(KeyValueStore == None)
	{
		LogString = "Failed to create KeyValueStore -- BlackBoard will not work";
		GoTo FailWithLogString;
	}

	return;

FailWithLogString:
	LogString = "Initialize failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function R_KeyValueStore GetKeyValueStore()
{
	return KeyValueStore;
}