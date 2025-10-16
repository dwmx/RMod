//==============================================================================
//	R_BehaviorTree_Wander
//	Wander around like an idiot
//==============================================================================
class R_BehaviorTree_Wander extends R_BehaviorTree;

function BuildBehaviorTree(R_BTBuilder BT)
{
	BT.CreateSequence();
	BT.Push();
		BT.CreateSequence();
		BT.Push();
			BT.CreateSequence();
			BT.Push();
				BT.CreateTask(Class'RBots.R_BTTask_Delay');
				BT.CreateTask(Class'RBots.R_BTTask_Delay');
				BT.Pop();
			BT.CreateSelector();
			BT.Push();
				BT.CreateTask(Class'RBots.R_BTTask_Delay');
				BT.CreateTask(Class'RBots.R_BTTask_Delay');
				BT.Pop();
			BT.CreateSequence();
			BT.Push();
				BT.CreateTask(Class'RBots.R_BTTask_Delay');
				BT.CreateTask(Class'RBots.R_BTTask_Delay');
}