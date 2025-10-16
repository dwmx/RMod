class R_BTTask_Delay extends R_BTTask;

function int TickTask(R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	if(ActiveTime >= 5.0)
	{
		return TaskSuccess();
	}
	return TaskInProgress();
}