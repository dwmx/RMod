//==============================================================================
//	R_BTNode_Task
//	Behavior Tree node which runs a Task
//==============================================================================
class R_BTNode_Task extends R_BTNode;

var private R_BTI_TaskInstance BehaviorTaskInstance;

const TaskSuccess = 0;
const TaskFail = 1;
const TaskInProgress = 2;

function String GetNodeDisplayString()
{
	local R_BehaviorTask Task;
	local Class<R_BehaviorTask> TaskClass;

	if(BehaviorTaskInstance == None)
	{
		return "ERR: INVALID BEHAVIOR TASK INSTANCE";
	}

	Task = BehaviorTaskInstance.GetBehaviorTask();
	if(Task == None)
	{
		return "ERR: INVALID BEHAVIOR TASK";
	}

	TaskClass = Task.Class;
	if(TaskClass != None)
	{
		return TaskClass.Static.GetTaskDisplayString();
	}

	return "ERR:" @ String(TaskClass);
}

//------------------------------------------------------------------------------

function SetBehaviorTaskInstance(R_BTI_TaskInstance NewBehaviorTaskInstance)
{
	BehaviorTaskInstance = NewBehaviorTaskInstance;
}

function R_BTI_TaskInstance GetBehaviorTaskInstance()
{
	return BehaviorTaskInstance;
}

//------------------------------------------------------------------------------

function BaseNodeActivated(R_BehaviorTreeContext Context)
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;

	Super.BaseNodeActivated(Context);

	if(BehaviorTaskInstance != None)
	{
		Bot = Context.GetBot();
		BlackBoard = Context.GetBlackBoard();

		if(Bot != None && BlackBoard != None)
		{
			BehaviorTaskInstance.TaskActivated(Bot, BlackBoard);
		}
	}
}

function BaseNodeDeactivated(R_BehaviorTreeContext Context)
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;

	Super.BaseNodeDeactivated(Context);

	if(BehaviorTaskInstance != None)
	{
		Bot = Context.GetBot();
		BlackBoard = Context.GetBlackBoard();

		if(Bot != None && BlackBoard != None)
		{
			BehaviorTaskInstance.TaskDeactivated(Bot, BlackBoard);
		}
	}
}

function int Tick(R_BehaviorTreeContext Context, float DeltaSeconds)
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;
	local float ActiveTime;
	local int TaskResult;

	if(BehaviorTaskInstance == None)
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

	TaskResult = BehaviorTaskInstance.TickTask(Bot, BlackBoard, ActiveTime, DeltaSeconds);
	switch(TaskResult)
	{
	case TaskInProgress:	return NodeRunning;
	case TaskSuccess:		return NodeSuccess;
	case TaskFail:			return NodeFail;
	}

	return NodeFail;
}