//==============================================================================
//	R_BehaviorTree_NavigateToGoal
//	Navigate toward some selected goal, performing potentially complex actions
//	along the way
//==============================================================================
class R_BehaviorTree_NavigateToGoal extends R_BehaviorTree;

function BuildBehaviorTree(R_BehaviorTreeBuilder BT)
{
	BT.CreateSequence();
	BT.Push();
		BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
		BT.CreateTask(Class'RBots.R_BehaviorTask_SelectEquipTarget');
		BT.CreateTask(Class'RBots.R_BehaviorTask_Equip');
}