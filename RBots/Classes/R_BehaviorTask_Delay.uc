//==============================================================================
//	R_BehaviorTask_Delay
//	Simple delay node -- pauses for some time before continuing
//	Attempts to read 'Duration' key from BlackBoard, but falls back to
//	default delay time if reading fails
//==============================================================================
class R_BehaviorTask_Delay extends R_BehaviorTask;

const TaskParamDuration = 'Duration';

static function String GetTaskDisplayString() { return "Delay"; }

function AddTaskParameters(R_BehaviorTaskInstance TaskInstance)
{
	if(TaskInstance != None)
	{
		TaskInstance.AddTaskFloat(TaskParamDuration);
	}
}

//------------------------------------------------------------------------------

function int TickTask(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local float Duration;

	Duration = GetTaskFloat(TaskInstance, TaskParamDuration, 7.0);

	if(ActiveTime >= Duration)
	{
		return TaskSuccess;
	}
	
	return TaskInProgress;
}