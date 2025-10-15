//==============================================================================
//	R_BTTask
//	Asynchronous Behavior Task
//	Do not override Tick -- use TickTask
//	Tasks will continue to run until the Task calls:
//		- EndTaskSuccess -- Finished successfully
//		- EndTaskFail -- Task failed
//==============================================================================
class R_BTTask extends R_BTNode abstract;

var private int Result;

function int Tick(float DeltaSeconds)
{
	Result = NodeRunning;
	TickTask(DeltaSeconds);
	return Result;
}

function EndTaskSuccess()
{
	Result = NodeSuccess;
}

function EndTaskFail()
{
	Result = NodeFail;
}

function TickTask(float DeltaSeconds);
