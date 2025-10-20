class R_BehaviorTask_SelectNavZoneDirection extends R_BehaviorTask;

const TaskParamNavZoneGoalIndex = 'NavZoneGoalIndex';
const TaskParamMoveDirection = 'NavZoneGoalDirection';

static function String GetTaskDisplayString() { return "SelectNavZoneDirection"; }

function int TickTask(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local R_NavQueryInterface NavQuery;
	local Vector PawnLocation;
	local int NavZoneGoalIndex;
	local Vector MoveDirection;

	if(!GetBlackBoardInt(BlackBoard, TaskInstance, TaskParamNavZoneGoalIndex, NavZoneGoalIndex))
	{
		return TaskFail;
	}

	NavQuery = GetNavQueryInterface();
	if(NavQuery == None)
	{
		return TaskFail;
	}

	PawnLocation = GetPawnLocation(Bot);
	if(!NavQuery.FindDirectionTowardsNavZoneByIndex(PawnLocation, NavZoneGoalIndex, MoveDirection))
	{
		return TaskFail;
	}

	if(!SetBlackBoardVector(BlackBoard, TaskInstance, TaskParamMoveDirection, MoveDirection))
	{
		return TaskFail;
	}

	return TaskInProgress;
}