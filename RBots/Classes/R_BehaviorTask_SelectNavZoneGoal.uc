class R_BehaviorTask_SelectNavZoneGoal extends R_BehaviorTask;

const TaskParamNavZoneGoalIndex = 'NavZoneGoalIndex';

static function String GetTaskDisplayString() { return "SelectNavZoneGoal"; }

function int TickTask(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local int NavZoneGoalIndex;

	NavZoneGoalIndex = Rand(5);

	if(!SetBlackBoardInt(BlackBoard, TaskInstance, TaskParamNavZoneGoalIndex, NavZoneGoalIndex))
	{
		return TaskFail;
	}

	return TaskSuccess;
}