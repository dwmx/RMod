//==============================================================================
//	R_BTTask_Delay
//	Simple delay node -- pauses for some time before continuing
//	Attempts to read 'Duration' key from BlackBoard, but falls back to
//	default delay time if reading fails
//==============================================================================
class R_BTTask_Delay extends R_BTTask;

const TaskParam_Delay = 'Delay';
const DefaultDelay = 3.0;

static function String GetNodeClassString() { return "Task: Delay"; }

function int TickTask(R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local float Duration;

	if(!ReadMappedFloat(BlackBoard, 'Duration', Duration))
	{
		Duration = DefaultDelay;
	}

	if(ActiveTime >= Duration)
	{
		return TaskSuccess();
	}
	
	return TaskInProgress();
}