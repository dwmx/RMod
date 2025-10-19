//==============================================================================
//	R_BehaviorTree_Wander
//	Wander around like an idiot
//==============================================================================
class R_BehaviorTree_Wander extends R_BehaviorTree;

function AddKeySetToBlackBoard(R_BlackBoard BlackBoard)
{
	local R_KeyValueStore KeyValueStore;

	if(BlackBoard != None)
	{
		KeyValueStore = BlackBoard.GetKeyValueStore();
	}
	if(KeyValueStore != None)
	{
		KeyValueStore.AddFloat('WaitTime');
		KeyValueStore.AddActor('PickupTarget');
		KeyValueStore.AddActor('EquipTarget');
	}
}

function BuildBehaviorTree(R_BehaviorTreeBuilder BT)
{
	BT.CreateSequence();
	BT.Push();
		//BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
		//BT.SetTaskFloat('Duration', 4.0);

		BT.CreateSubTree(Class'RBots.R_BehaviorTree_NavigateToGoal');

		BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
		BT.SetTaskFloat('Duration', 5.0);

		return;

		BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
		BT.SetTaskFloat('Duration', 10.0);


		return;
		BT.CreateSequence();
		BT.Push();
			BT.CreateSequence();
			BT.Push();
				BT.CreateSequence();
				BT.Push();
					BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
					BT.SetTaskFloat('Duration', 2.0);
					BT.Pop();
				BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
				BT.SetTaskFloat('Duration', 3.0);
				BT.Pop();
			BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
			BT.SetTaskFloat('Duration', 3.0);
			BT.Pop();
		BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
		BT.SetTaskFloat('Duration', 3.0);
				
		BT.CreateTask(Class'RBots.R_BehaviorTask_SelectEquipTarget');
		BT.CreateTask(Class'RBots.R_BehaviorTask_Equip');
}