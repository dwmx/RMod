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

function BuildBehaviorTree(R_BTBuilder BT)
{
	BT.CreateSequence();
	BT.Push();
		BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
		BT.SetTaskFloat('Duration', 20.0);

		BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
		BT.SetTaskFloat('Duration', 10.0);

		BT.CreateTask(Class'RBots.R_BehaviorTask_SelectEquipTarget');
		BT.CreateTask(Class'RBots.R_BehaviorTask_Equip');

	return;
	BT.CreateSequence();
	BT.Push();
		BT.CreateSequence();
		BT.Push();
			BT.CreateSequence();
			BT.Push();
				BT.CreateTask(Class'RBots.R_BehaviorTask_SelectWaitTime');
				BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
				BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
				//BT.CreateTask(Class'RBots.R_BehaviorTask_SelectEquipTarget');
				BT.CreateTask(Class'RBots.R_BehaviorTask_Equip');
				BT.Pop();
			BT.CreateSelector();
			BT.Push();
				BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
				BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
				BT.Pop();
			BT.CreateSequence();
			BT.Push();
				BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
				BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
				BT.Pop();
			BT.CreateParallel();
			BT.Push();
				BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
				BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
				BT.CreateSequence();
				BT.Push();
					BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
					BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
					BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
					BT.Pop();
				BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
}