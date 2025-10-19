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
// Task Parameters
// Each BehaviorTask can define its own set of configurable parameters via R_BehaviorTask.AddTaskParameters
// The BehaviorTreeBuilder class can then configure these parameters when constructing the tree on a per-node basis
function bool AddTaskBool(Name Key)		{ if(KeyValueStore != None) { return KeyValueStore.AddBool(Key); 	} return false; }
function bool AddTaskInt(Name Key) 		{ if(KeyValueStore != None) { return KeyValueStore.AddInt(Key); 	} return false; }
function bool AddTaskFloat(Name Key) 	{ if(KeyValueStore != None) { return KeyValueStore.AddFloat(Key); 	} return false; }
function bool AddTaskVector(Name Key)	{ if(KeyValueStore != None) { return KeyValueStore.AddVector(Key);	} return false; }
function bool AddTaskActor(Name Key)	{ if(KeyValueStore != None) { return KeyValueStore.AddActor(Key); 	} return false; }
function bool AddTaskObject(Name Key)	{ if(KeyValueStore != None) { return KeyValueStore.AddObject(Key);  } return false; }
function bool AddTaskClass(Name Key)	{ if(KeyValueStore != None) { return KeyValueStore.AddClass(Key);   } return false; }

function bool GetTaskBool(Name Key, out byte OutValue)		{ if(KeyValueStore != None)	{ return KeyValueStore.GetBool(Key, OutValue);		} return false;	}
function bool GetTaskInt(Name Key, out int OutValue)		{ if(KeyValueStore != None)	{ return KeyValueStore.GetInt(Key, OutValue); 		} return false; }
function bool GetTaskFloat(Name Key, out float OutValue)	{ if(KeyValueStore != None)	{ return KeyValueStore.GetFloat(Key, OutValue);		} return false; }
function bool GetTaskVector(Name Key, out Vector OutValue)	{ if(KeyValueStore != None) { return KeyValueStore.GetVector(Key, OutValue);	} return false; }
function bool GetTaskActor(Name Key, out Actor OutValue)	{ if(KeyValueStore != None) { return KeyValueStore.GetActor(Key, OutValue); 	} return false; }
function bool GetTaskObject(Name Key, out Object OutValue)	{ if(KeyValueStore != None) { return KeyValueStore.GetObject(Key, OutValue);	} return false; }
function bool GetTaskClass(Name Key, out Class OutValue)	{ if(KeyValueStore != None) { return KeyValueStore.GetClass(Key, OutValue); 	} return false; }

function bool SetTaskBool(Name Key, byte Value)		{ if(KeyValueStore != None) { return KeyValueStore.SetBool(Key, Value);		} return false; }
function bool SetTaskInt(Name Key, int Value)		{ if(KeyValueStore != None) { return KeyValueStore.SetInt(Key, Value); 		} return false; }
function bool SetTaskFloat(Name Key, float Value)	{ if(KeyValueStore != None) { return KeyValueStore.SetFloat(Key, Value);	} return false; }
function bool SetTaskVector(Name Key, Vector Value)	{ if(KeyValueStore != None) { return KeyValueStore.SetVector(Key, Value); 	} return false; }
function bool SetTaskActor(Name Key, Actor Value)	{ if(KeyValueStore != None)	{ return KeyValueStore.SetActor(Key, Value);	} return false; }
function bool SetTaskObject(Name Key, Object Value)	{ if(KeyValueStore != None)	{ return KeyValueStore.SetObject(Key, Value); 	} return false; }
function bool SetTaskClass(Name Key, Class Value)	{ if(KeyValueStore != None) { return KeyValueStore.SetClass(Key, Value); 	} return false; }

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