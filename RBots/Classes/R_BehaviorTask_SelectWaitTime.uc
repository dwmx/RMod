//==============================================================================
//	R_BehaviorTask_SelectWaitTime
//	Selects some random amount of time to wait and outputs it to 'WaitTime'
//==============================================================================
class R_BehaviorTask_SelectWaitTime extends R_BehaviorTask;

const TaskParam_WaitTime = 'WaitTime';

static function String GetTaskDisplayString() { return "Select Wait Time"; }

function int TickTask(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local float NewWaitTime;

	NewWaitTime = FRand() * 5.0 + 5.0;

	WriteMappedFloat(BlackBoard, TaskParam_WaitTime, NewWaitTime);
	return TaskSuccess;
}