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

function bool GetTaskBool(R_BehaviorTaskInstance TaskInstance, Name Key, bool bDefaultValue)
{
	local byte ByteValue;
	if(TaskInstance != None && TaskInstance.GetTaskBool(Key, ByteValue))
	{
		if(ByteValue == 0)	return false;
		else				return true;
	}
	return bDefaultValue;
}

function int GetTaskInt(R_BehaviorTaskInstance TaskInstance, Name Key, int DefaultValue)
{
	local int Value;
	if(TaskInstance != None && TaskInstance.GetTaskInt(Key, Value))
	{
		return Value;
	}
	return DefaultValue;
}

function float GetTaskFloat(R_BehaviorTaskInstance TaskInstance, Name Key, float DefaultValue)
{
	local float Value;
	if(TaskInstance != None && TaskInstance.GetTaskFloat(Key, Value))
	{
		return Value;
	}
	return DefaultValue;
}

function Vector GetTaskVector(R_BehaviorTaskInstance TaskInstance, Name Key, Vector DefaultValue)
{
	local Vector Value;
	if(TaskInstance != None && TaskInstance.GetTaskVector(Key, Value))
	{
		return Value;
	}
	return DefaultValue;
}

function Actor GetTaskActor(R_BehaviorTaskInstance TaskInstance, Name Key, Actor DefaultValue)
{
	local Actor Value;
	if(TaskInstance != None && TaskInstance.GetTaskActor(Key, Value))
	{
		return Value;
	}
	return DefaultValue;
}

function Object GetTaskObject(R_BehaviorTaskInstance TaskInstance, Name Key, Object DefaultValue)
{
	local Object Value;
	if(TaskInstance != None && TaskInstance.GetTaskObject(Key, Value))
	{
		return Value;
	}
	return DefaultValue;
}

function Class GetTaskClass(R_BehaviorTaskInstance TaskInstance, Name Key, Class DefaultValue)
{
	local Class Value;
	if(TaskInstance != None && TaskInstance.GetTaskClass(Key, Value))
	{
		return Value;
	}
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