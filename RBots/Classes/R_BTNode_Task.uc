//==============================================================================
//	R_BTNode_Task
//	Behavior Tree node which runs a Task
//==============================================================================
class R_BTNode_Task extends R_BTNode;

var private R_BehaviorTask BehaviorTask;

const TaskSuccess = 0;
const TaskFail = 1;
const TaskInProgress = 2;

function String GetNodeDisplayString()
{
	local Class<R_BehaviorTask> BehaviorTaskClass;
	if(BehaviorTask == None)
	{
		return "ERR: INVALID";
	}

	BehaviorTaskClass = BehaviorTask.Class;
	if(BehaviorTaskClass != None)
	{
		return BehaviorTaskClass.Static.GetTaskDisplayString();
	}
	
	return "ERR:" @ String(BehaviorTaskClass);
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

//------------------------------------------------------------------------------

function BaseNodeActivated(R_BTContext Context)
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;

	Super.BaseNodeActivated(Context);

	if(BehaviorTask != None)
	{
		Bot = Context.GetBot();
		BlackBoard = Context.GetBlackBoard();

		if(Bot != None && BlackBoard != None)
		{
			BehaviorTask.TaskActivated(Bot, BlackBoard);
		}
	}
}

function BaseNodeDeactivated(R_BTContext Context)
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;

	Super.BaseNodeDeactivated(Context);

	if(BehaviorTask != None)
	{
		Bot = Context.GetBot();
		BlackBoard = Context.GetBlackBoard();

		if(Bot != None && BlackBoard != None)
		{
			BehaviorTask.TaskDeactivated(Bot, BlackBoard);
		}
	}
}

function int Tick(R_BTContext Context, float DeltaSeconds)
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;
	local float ActiveTime;
	local int TaskResult;

	if(BehaviorTask == None)
	{
		return NodeFail;
	}

	Bot = Context.GetBot();
	BlackBoard = Context.GetBlackBoard();
	ActiveTime = Context.GetNodeActiveTime(GetNodeUID());

	if(Bot == None || BlackBoard == None)
	{
		return NodeFail;
	}

	TaskResult = BehaviorTask.TickTask(Bot, BlackBoard, ActiveTime, DeltaSeconds);
	switch(TaskResult)
	{
	case TaskInProgress:	return NodeRunning;
	case TaskSuccess:		return NodeSuccess;
	case TaskFail:			return NodeFail;
	}

	return NodeFail;
}