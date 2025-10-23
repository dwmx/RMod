//==============================================================================
//	R_BehaviorTaskInstance
//	Represents an individual instance of an R_BehaviorTask in a BehaviorTree
//==============================================================================
class R_BehaviorTaskInstance extends R_BehaviorActionInstance;

const LogCategory = 'BehaviorTaskInstance';

const TaskSuccess = 0;
const TaskFail = 1;
const TaskInProgress = 2;

var private R_BehaviorTask BehaviorTask;

//------------------------------------------------------------------------------

function SetBehaviorTask(R_BehaviorTask NewBehaviorTask)
{
	BehaviorTask = NewBehaviorTask;
}

function R_BehaviorTask GetBehaviorTask()
{
	return BehaviorTask;
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