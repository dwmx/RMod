//==============================================================================
//	R_BTNode_Task
//	Behavior Tree node which runs a Task
//==============================================================================
class R_BTNode_Task extends R_BTNode_Action;

var private R_BTI_TaskInstance TaskInstance;

const TaskSuccess = 0;
const TaskFail = 1;
const TaskInProgress = 2;

//------------------------------------------------------------------------------
// Composite Functions
// Task nodes are always leaf nodes, so composite functionality is removed

function bool CanContainChildren()					{ return false; }
function bool IsFull()								{ return true; }
function int GetChildCount()						{ return 0; }
function R_BTNode GetChild(optional int Index)		{ return None; }
function AddChild(R_BTNode NewChildNode)			{ return; }

function bool TryInsertChildBetween(R_BTNode CurrentChild, R_BTNode NewChild)
{ return false; }

//------------------------------------------------------------------------------

function R_BTI_TaskInstance GetTaskInstance()
{
	if(TaskInstance == None)
	{
		TaskInstance = R_BTI_TaskInstance(GetBehaviorActionInstance());
	}
	return TaskInstance;
}

function String GetNodeDisplayString()
{
	local R_BTI_TaskInstance LocalTaskInstance;
	local R_BehaviorTask Task;
	local Class<R_BehaviorTask> TaskClass;

	LocalTaskInstance = GetTaskInstance();
	if(LocalTaskInstance == None)
	{
		return "ERR: INVALID BEHAVIOR TASK INSTANCE";
	}

	Task = LocalTaskInstance.GetBehaviorTask();
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

function BaseNodeActivated(R_BehaviorTreeContext Context)
{
	local R_BTI_TaskInstance LocalTaskInstance;
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;

	Super.BaseNodeActivated(Context);

	LocalTaskInstance = GetTaskInstance();
	if(LocalTaskInstance != None)
	{
		Bot = Context.GetBot();
		BlackBoard = Context.GetBlackBoard();

		if(Bot != None && BlackBoard != None)
		{
			LocalTaskInstance.TaskActivated(Bot, BlackBoard);
		}
	}
}

function BaseNodeDeactivated(R_BehaviorTreeContext Context)
{
	local R_BTI_TaskInstance LocalTaskInstance;
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;

	Super.BaseNodeDeactivated(Context);
	LocalTaskInstance = GetTaskInstance();

	if(LocalTaskInstance != None)
	{
		Bot = Context.GetBot();
		BlackBoard = Context.GetBlackBoard();

		if(Bot != None && BlackBoard != None)
		{
			LocalTaskInstance.TaskDeactivated(Bot, BlackBoard);
		}
	}
}

function int Tick(R_BehaviorTreeContext Context, float DeltaSeconds)
{
	local R_BTI_TaskInstance LocalTaskInstance;
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;
	local float ActiveTime;
	local int TaskResult;

	LocalTaskInstance = GetTaskInstance();
	if(LocalTaskInstance == None)
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

	TaskResult = LocalTaskInstance.TickTask(Bot, BlackBoard, ActiveTime, DeltaSeconds);
	switch(TaskResult)
	{
	case TaskInProgress:	return NodeRunning;
	case TaskSuccess:		return NodeSuccess;
	case TaskFail:			return NodeFail;
	}

	return NodeFail;
}

defaultproperties
{
	RequiredBehaviorActionInstanceClass=Class'RBots.R_BTI_TaskInstance'
}