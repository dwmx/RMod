//==============================================================================
//	R_BTT_Delay
//==============================================================================
class R_BTT_Delay extends R_BehaviorTask;

function AddParameters(R_BehaviorActionInstance Instance)
{
	Instance.AddParameter('Duration', TypeCodeFloat);
}

function int TickTask(R_BTI_TaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local R_Variant DurationValue;
	local float Duration;

	Duration = 3.0;
	if(TaskInstance.GetParameter('Duration', DurationValue))
	{
		Duration = GetFloatVariant(DurationValue);
	}

	if(ActiveTime >= Duration)
	{
		return TaskSuccess;
	}

	return TaskInProgress;
}