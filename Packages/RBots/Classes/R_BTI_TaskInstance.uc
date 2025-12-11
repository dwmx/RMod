//==============================================================================
//	R_BTI_TaskInstance
//	Represents an individual instance of an R_BehaviorTask in a BehaviorTree
//==============================================================================
class R_BTI_TaskInstance extends R_BehaviorActionInstance;

const LogCategory = 'BehaviorTaskInstance';

const TaskSuccess = 0;
const TaskFail = 1;
const TaskInProgress = 2;

var private R_BehaviorTask BehaviorTask;

//------------------------------------------------------------------------------

function R_BehaviorTask GetBehaviorTask()
{
	if(BehaviorTask == None)
	{
		BehaviorTask = R_BehaviorTask(GetBehaviorAction());
	}
	return BehaviorTask;
}

//------------------------------------------------------------------------------

function TaskActivated(R_Bot Bot, R_BlackBoard BlackBoard)
{
	local R_BehaviorTask LocalBehaviorTask;
	LocalBehaviorTask = GetBehaviorTask();
	if(LocalBehaviorTask != None)
	{
		LocalBehaviorTask.TaskActivated(Self, Bot, BlackBoard);
	}
}

function TaskDeactivated(R_Bot Bot, R_BlackBoard BlackBoard)
{
	local R_BehaviorTask LocalBehaviorTask;
	LocalBehaviorTask = GetBehaviorTask();
	if(LocalBehaviorTask != None)
	{
		LocalBehaviorTask.TaskDeactivated(Self, Bot, BlackBoard);
	}
}

function int TickTask(R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local R_BehaviorTask LocalBehaviorTask;
	LocalBehaviorTask = GetBehaviorTask();
	if(LocalBehaviorTask != None)
	{
		return LocalBehaviorTask.TickTask(Self, Bot, BlackBoard, ActiveTime, DeltaSeconds);
	}
	return TaskFail;
}

//------------------------------------------------------------------------------

defaultproperties
{
	RequiredBehaviorActionClass=Class'RBots.R_BehaviorTask'
}