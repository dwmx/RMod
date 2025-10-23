//==============================================================================
//	R_BehaviorTask
//==============================================================================
class R_BehaviorTask extends R_VirtualAsset abstract;

const LogCategory = 'BehaviorTask';

const TaskInstanceClass = Class'RBots.R_BehaviorTaskInstance';

const TaskSuccess = 0;
const TaskFail = 1;
const TaskInProgress = 2;

//------------------------------------------------------------------------------

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
// TaskParameter Getters



//------------------------------------------------------------------------------
//	RBots Utilities
function R_NavQueryInterface GetNavQueryInterface()
{
	local R_RBotsServerActor LocalRBots;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots != None)
	{
		return LocalRBots.GetNavQueryInterface();
	}
	return None;
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

function Vector GetPawnLocation(R_Bot Bot)
{
	local Pawn P;

	P = GetPlayerPawn(Bot);
	if(P != None)
	{
		return P.Location;
	}
	return Vect(0,0,0);
}

//------------------------------------------------------------------------------

function TaskActivated(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard);
function TaskDeactivated(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard);
function int TickTask(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds);