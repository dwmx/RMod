//==============================================================================
//	R_BTTask
//	Asynchronous Behavior Task
//	Do not override Tick -- use TickTask
//	Tasks will continue to run until the Task calls:
//		- EndTaskSuccess -- Finished successfully
//		- EndTaskFail -- Task failed
//==============================================================================
class R_BTTask extends R_BTNode abstract;

static function String GetNodeClassString() { return "Task"; }

function int Tick(R_BTContext Context, float DeltaSeconds)
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;
	local float ActiveTime;
	local int Result;

	Bot = Context.GetBot();
	BlackBoard = Context.GetBlackBoard();
	ActiveTime = Context.GetNodeActiveTime(GetNodeUID());
	Result = TickTask(Bot, BlackBoard, ActiveTime, DeltaSeconds);
	return Result;
}

//------------------------------------------------------------------------------

function int TaskSuccess()
{
	return NodeSuccess;
}

function int TaskFail()
{
	return NodeFail;
}

function int TaskInProgress()
{
	return NodeRunning;
}

//------------------------------------------------------------------------------

function int TickTask(R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds);