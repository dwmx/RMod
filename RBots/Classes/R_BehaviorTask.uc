//==============================================================================
//	R_BehaviorTask
//==============================================================================
class R_BehaviorTask extends R_VirtualAsset abstract;

const LogCategory = 'BehaviorTask';

const TaskInstanceClass = Class'RBots.R_BehaviorTaskInstance';

struct R_ParameterMappings
{
	var Name BlackBoardKey;
	var Name TaskParameter;
};
var private R_ParameterMappings ParameterMappings[32];
var private int NumParameterMappings;

const TaskSuccess = 0;
const TaskFail = 1;
const TaskInProgress = 2;

static function String GetTaskDisplayString() { return "Task"; }

function R_BehaviorTaskInstance CreateInstance()
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;
	local R_BehaviorTaskInstance TaskInstance;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{
		LogString = "Invalid reference to RBotsServerActor";
		GoTo FailWithLogString;
	}

	// Create with deferred initialization so that the Task reference can be set first
	TaskInstance = R_BehaviorTaskInstance(LocalRBots.CreateRBotsObject(TaskInstanceClass, Self, true));
	if(TaskInstance == None)
	{
		LogString = "Failed to create TaskInstance from Class:" @ TaskInstanceClass;
		GoTo FailWithLogString;
	}

	TaskInstance.SetBehaviorTask(Self);
	TaskInstance.Initialize();
	AddTaskParameters(TaskInstance);
	return TaskInstance;

FailWithLogString:
	LogString = "CreateInstance failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return None;
}

function AddTaskParameters(R_BehaviorTaskInstance TaskInstance);

//------------------------------------------------------------------------------

function MapBlackBoardKey(Name BlackBoardKey, Name TaskParameter)
{
	local String LogString;

	if(NumParameterMappings >= ArrayCount(ParameterMappings))
	{
		LogString = "MapBlackBoardKey failed -- array overflow";
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
		return;
	}

	ParameterMappings[NumParameterMappings].BlackBoardKey = BlackBoardKey;
	ParameterMappings[NumParameterMappings].TaskParameter = TaskParameter;
	++NumParameterMappings;
}

function bool GetMappedBlackBoardKey(Name TaskParameter, out Name OutBlackBoardKey)
{
	local int i;

	for(i = 0; i < NumParameterMappings; ++i)
	{
		if(ParameterMappings[i].TaskParameter == TaskParameter)
		{
			OutBlackBoardKey = ParameterMappings[i].BlackBoardKey;
			return true;
		}
	}
	return false;
}

//------------------------------------------------------------------------------

function R_KeyValueStore GetBlackBoardKeyValueStore(R_BlackBoard BlackBoard)
{
	if(BlackBoard == None)
	{
		return None;
	}
	return BlackBoard.GetKeyValueStore();
}

//------------------------------------------------------------------------------
//	Read from BlackBoard

function bool ReadMappedInt(R_BlackBoard BlackBoard, Name TaskParameter, out int OutValue)
{
	local R_KeyValueStore KeyValueStore;
	local Name BBKey;
	KeyValueStore = GetBlackBoardKeyValueStore(BlackBoard);
	if(KeyValueStore != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return KeyValueStore.GetInt(BBKey, OutValue);
	}
	return false;
}

function bool ReadMappedFloat(R_BlackBoard BlackBoard, Name TaskParameter, out float OutValue)
{
	local R_KeyValueStore KeyValueStore;
	local Name BBKey;
	KeyValueStore = GetBlackBoardKeyValueStore(BlackBoard);
	if(KeyValueStore != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return KeyValueStore.GetFloat(BBKey, OutValue);
	}
	return false;
}

function bool ReadMappedVector(R_BlackBoard BlackBoard, Name TaskParameter, out Vector OutValue)
{
	local R_KeyValueStore KeyValueStore;
	local Name BBKey;
	KeyValueStore = GetBlackBoardKeyValueStore(BlackBoard);
	if(KeyValueStore != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return KeyValueStore.GetVector(BBKey, OutValue);
	}
	return false;
}

function bool ReadMappedActor(R_BlackBoard BlackBoard, Name TaskParameter, out Actor OutValue)
{
	local R_KeyValueStore KeyValueStore;
	local Name BBKey;
	KeyValueStore = GetBlackBoardKeyValueStore(BlackBoard);
	if(KeyValueStore != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return KeyValueStore.GetActor(BBKey, OutValue);
	}
	return false;
}

//------------------------------------------------------------------------------
//	Write to BlackBoard

function bool WriteMappedInt(R_BlackBoard BlackBoard, Name TaskParameter, int Value)
{
	local R_KeyValueStore KeyValueStore;
	local Name BBKey;
	KeyValueStore = GetBlackBoardKeyValueStore(BlackBoard);
	if(KeyValueStore != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return KeyValueStore.SetInt(BBKey, Value);
	}
	return false;
}

function bool WriteMappedFloat(R_BlackBoard BlackBoard, Name TaskParameter, float Value)
{
	local R_KeyValueStore KeyValueStore;
	local Name BBKey;
	KeyValueStore = GetBlackBoardKeyValueStore(BlackBoard);
	if(KeyValueStore != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return KeyValueStore.SetFloat(BBKey, Value);
	}
	return false;
}

function bool WriteMappedVector(R_BlackBoard BlackBoard, Name TaskParameter, Vector Value)
{
	local R_KeyValueStore KeyValueStore;
	local Name BBKey;
	KeyValueStore = GetBlackBoardKeyValueStore(BlackBoard);
	if(KeyValueStore != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return KeyValueStore.SetVector(BBKey, Value);
	}
	return false;
}

function bool WriteMappedActor(R_BlackBoard BlackBoard, Name TaskParameter, Actor Value)
{
	local R_KeyValueStore KeyValueStore;
	local Name BBKey;
	KeyValueStore = GetBlackBoardKeyValueStore(BlackBoard);
	if(KeyValueStore != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return KeyValueStore.SetActor(BBKey, Value);
	}
	return false;
}

//------------------------------------------------------------------------------
//	Bot Utilities
function R_BotPawnController GetPawnController(R_Bot Bot)
{
	if(Bot == None)
	{
		return None;
	}
	return Bot.GetBotPawnController();
}

function PlayerPawn GetPlayerPawn(R_Bot Bot)
{
	if(Bot == None)
	{
		return None;
	}
	return Bot.GetOwnedPlayerPawn();
}

//------------------------------------------------------------------------------

function TaskActivated(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard);
function TaskDeactivated(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard);
function int TickTask(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds);