//==============================================================================
//	R_BehaviorTree_Wander
//	Wander around like an idiot
//==============================================================================
class R_BehaviorTree_Wander extends R_BehaviorTree;

const BTT_Delay 					= Class'RBots.R_BehaviorTask_Delay';
const BTT_SelectNavZoneGoal 		= Class'RBots.R_BehaviorTask_SelectNavZoneGoal';
const BTT_SelectNavZoneDirection	= Class'RBots.R_BehaviorTask_SelectNavZoneDirection';
const BTT_MoveInDirection			= Class'RBots.R_BehaviorTask_MoveInDirection';

const BBKey_NavZoneGoalIndex 		= 'NavZoneGoalIndex';
const BBKey_MoveDirection 			= 'MoveDirection';

//------------------------------------------------------------------------------

function AddKeySetToBlackBoard(R_BlackBoard BlackBoard)
{
	if(BlackBoard == None)
	{
		return;
	}

	BlackBoard.AddInt(BBKey_NavZoneGoalIndex);
	BlackBoard.AddVector(BBKey_MoveDirection);
}

function BuildBehaviorTree(R_BehaviorTreeBuilder BT)
{
	BT.CreateSequence();
	BT.Push();
		BT.CreateTask(BTT_Delay);
		BT.SetTaskFloat('Duration', 10.0);

		BT.CreateParallel();
		BT.Push();
			BT.CreateSequence();
			BT.Push();
				BT.CreateTask(BTT_SelectNavZoneGoal);
				BT.MapKeySelector('NavZoneGoalIndex', BBKey_NavZoneGoalIndex);

				BT.CreateTask(BTT_SelectNavZoneDirection);
				BT.MapKeySelector('NavZoneGoalIndex', BBKey_NavZoneGoalIndex);
				BT.MapKeySelector('NavZoneGoalDirection', BBKey_MoveDirection);

				BT.Pop();

			BT.CreateTask(BTT_MoveInDirection);
			BT.MapKeySelector('MoveDirection', BBKey_MoveDirection);
}