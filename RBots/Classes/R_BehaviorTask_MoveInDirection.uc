//==============================================================================
//	R_BehaviorTask_MoveInDirection
//	Move in the given direction
//==============================================================================
class R_BehaviorTask_MoveInDirection extends R_BehaviorTask;

const TaskParamMoveDirection = 'MoveDirection';

static function String GetTaskDisplayString() { return "MoveInDirection"; }

function int TickTask(R_BehaviorTaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local R_BotPawnController PawnController;
	local Vector MoveDirection;

	PawnController = GetPawnController(Bot);
	if(PawnController == None)
	{
		return TaskFail;
	}

	if(!GetBlackBoardVector(BlackBoard, TaskInstance, TaskParamMoveDirection, MoveDirection))
	{
		return TaskFail;
	}
	
	PawnController.AddMovementInput_WorldSpace(MoveDirection);
	return TaskInProgress;
}