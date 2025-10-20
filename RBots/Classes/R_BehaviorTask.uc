//==============================================================================
//	R_BehaviorTask
//==============================================================================
class R_BehaviorTask extends R_VirtualAsset abstract;

const LogCategory = 'BehaviorTask';

const TaskInstanceClass = Class'RBots.R_BehaviorTaskInstance';

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
// BlackBoard Functions
//
// These functions first check to see if the given TaskParameter has been mapped
// to a BlackBoard key in the TaskInstance, and if so, uses that mapped key to
// access the BlackBoard variable
//
// If no mapped key was found, the TaskParameter name itself will be attempted
// If both fail, the provided DefaultValue will be returned
//
// Related functions:
//	- R_BehaviorTreeBuilder.MapKeySelector

function Name GetBlackBoardKeyForTaskParameter(R_BehaviorTaskInstance TaskInstance, Name TaskParameter)
{
	local Name Key;
	
	if(TaskInstance != None && TaskInstance.GetMappedKeySelector(TaskParameter, Key))
	{
		return Key;
	}

	return TaskParameter;
}

//------------------------------------------------------------------------------
// BlackBoard Getters

function bool GetBlackBoardBool(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, out byte OutValue)
{
	local Name Key;

	if(BlackBoard == None) { return false; }
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.GetBool(Key, OutValue);
}

function bool GetBlackBoardInt(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, out int OutValue)
{
	local Name Key;

	if(BlackBoard == None) { return false; }
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.GetInt(Key, OutValue);
}

function bool GetBlackBoardFloat(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, out float OutValue)
{
	local Name Key;

	if(BlackBoard == None) { return false; }
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.GetFloat(Key, OutValue);
}

function bool GetBlackBoardVector(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, out Vector OutValue)
{
	local Name Key;

	if(BlackBoard == None) { return false; }
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.GetVector(Key, OutValue);
}

function bool GetBlackBoardActor(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, out Actor OutValue)
{
	local Name Key;

	if(BlackBoard == None) { return false; }
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.GetActor(Key, OutValue);
}

function bool GetBlackBoardObject(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, out Object OutValue)
{
	local Name Key;

	if(BlackBoard == None) { return false; }
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.GetObject(Key, OutValue);
}

function bool GetBlackBoardClass(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, out Class OutValue)
{
	local Name Key;

	if(BlackBoard == None) { return false; }
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.GetClass(Key, OutValue);
}

//------------------------------------------------------------------------------
// BlackBoard Setters

function bool SetBlackBoardBool(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, bool Value)
{
	local Name Key;
	local byte ByteValue;

	if(BlackBoard == None)	return false;
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	if(Value)	ByteValue = 1;
	else		ByteValue = 0;
	return BlackBoard.SetBool(Key, ByteValue);
}

function bool SetBlackBoardInt(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, int Value)
{
	local Name Key;

	if(BlackBoard == None)	return false;
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.SetInt(Key, Value);
}

function bool SetBlackBoardFloat(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, float Value)
{
	local Name Key;

	if(BlackBoard == None)	return false;
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.SetFloat(Key, Value);
}

function bool SetBlackBoardVector(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, Vector Value)
{
	local Name Key;

	if(BlackBoard == None)	return false;
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.SetVector(Key, Value);
}

function bool SetBlackBoardActor(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, Actor Value)
{
	local Name Key;

	if(BlackBoard == None)	return false;
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.SetActor(Key, Value);
}

function bool SetBlackBoardObject(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, Object Value)
{
	local Name Key;

	if(BlackBoard == None)	return false;
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.SetObject(Key, Value);
}

function bool SetBlackBoardClass(R_BlackBoard BlackBoard, R_BehaviorTaskInstance TaskInstance, Name TaskParameter, Class Value)
{
	local Name Key;

	if(BlackBoard == None)	return false;
	Key = GetBlackBoardKeyForTaskParameter(TaskInstance, TaskParameter);
	return BlackBoard.SetClass(Key, Value);
}

//------------------------------------------------------------------------------
// TaskParameter Getters
// These are parameters that are configured on a per-node basis during
// construction of the BehaviorTree
//
// The values for TaskParameters are stored on the TaskInstance and then
// retrieved during execution of the given Task
//
// Related functions:
//	- R_BehaviorTreeBuilder.SetTaskInt
//	- R_BehaviorTreeBuilder.SetTaskFloat
//	etc...

function bool GetTaskBool(R_BehaviorTaskInstance TaskInstance, Name TaskParameter, bool bDefaultValue)
{
	local byte ByteValue;

	if(TaskInstance != None && TaskInstance.GetTaskBool(TaskParameter, ByteValue))
	{
		if(ByteValue == 0)	return false;
		else				return true;
	}
	return bDefaultValue;
}

function int GetTaskInt(R_BehaviorTaskInstance TaskInstance, Name TaskParameter, int DefaultValue)
{
	local int Value;

	if(TaskInstance != None && TaskInstance.GetTaskInt(TaskParameter, Value))	{ return Value; }
	return DefaultValue;
}

function float GetTaskFloat(R_BehaviorTaskInstance TaskInstance, Name TaskParameter, float DefaultValue)
{
	local float Value;

	if(TaskInstance != None && TaskInstance.GetTaskFloat(TaskParameter, Value))	{ return Value; }
	return DefaultValue;
}

function Vector GetTaskVector(R_BehaviorTaskInstance TaskInstance, Name TaskParameter, Vector DefaultValue)
{
	local Vector Value;

	if(TaskInstance != None && TaskInstance.GetTaskVector(TaskParameter, Value)){ return Value; }
	return DefaultValue;
}

function Actor GetTaskActor(R_BehaviorTaskInstance TaskInstance, Name TaskParameter, Actor DefaultValue)
{
	local Actor Value;

	if(TaskInstance != None && TaskInstance.GetTaskActor(TaskParameter, Value))	{ return Value; }
	return DefaultValue;
}

function Object GetTaskObject(R_BehaviorTaskInstance TaskInstance, Name TaskParameter, Object DefaultValue)
{
	local Object Value;

	if(TaskInstance != None && TaskInstance.GetTaskObject(TaskParameter, Value)){ return Value; }
	return DefaultValue;
}

function Class GetTaskClass(R_BehaviorTaskInstance TaskInstance, Name TaskParameter, Class DefaultValue)
{
	local Class Value;

	if(TaskInstance != None && TaskInstance.GetTaskClass(TaskParameter, Value))	{ return Value; }
	return DefaultValue;
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