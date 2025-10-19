//==============================================================================
//	R_BehaviorTaskInstance
//	Represents an individual instance of an R_BehaviorTask in a BehaviorTree
//==============================================================================
class R_BehaviorTaskInstance extends R_RBotsObject;

const LogCategory = 'BehaviorTaskInstance';

const TaskSuccess = 0;
const TaskFail = 1;
const TaskInProgress = 2;

var private R_BehaviorTask BehaviorTask;

const KeyValueStoreClass = Class'RBots.R_KeyValueStore_Implementation';
var private R_KeyValueStore KeyValueStore;

//------------------------------------------------------------------------------
//	Task Parameters
function bool AddTaskFloat(Name Key)
{
	if(KeyValueStore != None)
	{
		return KeyValueStore.AddFloat(Key);
	}
	return false;
}

function bool GetTaskFloat(Name Key, out float OutValue)
{
	local float Value;
	if(KeyValueStore != None)
	{
		return KeyValueStore.GetFloat(Key, OutValue);
	}
	return false;
}

function bool SetTaskFloat(Name Key, float Value)
{
	if(KeyValueStore != None)
	{
		return KeyValueStore.SetFloat(Key, Value);
	}
	return false;
}

//------------------------------------------------------------------------------

function SetBehaviorTask(R_BehaviorTask NewBehaviorTask)
{
	BehaviorTask = NewBehaviorTask;
}

function R_BehaviorTask GetBehaviorTask()
{
	return BehaviorTask;
}

function Initialize()
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{
		LogString = "Invalid reference to RBotsServerActor";
		GoTo FailWithLogString;
	}

	KeyValueStore = R_KeyValueStore(LocalRBots.CreateRBotsObject(KeyValueStoreClass));
	if(KeyValueStore == None)
	{
		LogString = "Failed to create KeyValueStore";
		GoTo FailWithLogString;
	}

	return;

FailWithLogString:
	LogString = "Initialize failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function TaskActivated(R_Bot Bot, R_BlackBoard BlackBoard)
{
	if(BehaviorTask != None)
	{
		BehaviorTask.TaskActivated(Self, Bot, BlackBoard);
	}
}

function TaskDeactivated(R_Bot Bot, R_BlackBoard BlackBoard)
{
	if(BehaviorTask != None)
	{
		BehaviorTask.TaskDeactivated(Self, Bot, BlackBoard);
	}
}

function int TickTask(R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	if(BehaviorTask == None)
	{
		return TaskFail;
	}
	return BehaviorTask.TickTask(Self, Bot, BlackBoard, ActiveTime, DeltaSeconds);
}