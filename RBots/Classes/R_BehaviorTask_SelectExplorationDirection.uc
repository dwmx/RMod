class R_BehaviorTask_SelectExplorationDirection extends R_BehaviorTask;

const TaskParamExplorationDirection = 'ExplorationDirection';

static function String GetTaskDisplayString() { return "SelectExplorationDirection"; }

function int TickTask(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local Vector ExplorationDirection;

	ExplorationDirection = Vect(1,0,0);
	if(!SetBlackBoardVector(BlackBoard, TaskInstance, TaskParamExplorationDirection, ExplorationDirection))
	{
		return TaskFail;
	}

	return TaskInProgress;
}