class R_BTTask_Delay extends R_BTTask;

function int TickTask(R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	if(ActiveTime >= 5.0)
	{
		Log("HOly shit this is actually working didnt think it woudl");
		return TaskSuccess();
	}
	return TaskInProgress();
}