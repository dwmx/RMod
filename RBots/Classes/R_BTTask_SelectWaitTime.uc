//==============================================================================
//	R_BTTask_SelectWaitTime
//	Selects some random amount of time to wait and outputs it to 'WaitTime'
//==============================================================================
class R_BTTask_SelectWaitTime extends R_BTTask;

const TaskParam_WaitTime = 'WaitTime';

static function String GetNodeClassString() { return "Task: Select Wait Time"; }

function int TickTask(R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local float NewWaitTime;

	NewWaitTime = FRand() * 5.0 + 5.0;

	WriteMappedFloat(BlackBoard, TaskParam_WaitTime, NewWaitTime);
	return TaskSuccess();
}