//==============================================================================
//	R_BehaviorTree_Wander
//	Wander around like an idiot
//==============================================================================
class R_BehaviorTree_Wander extends R_BehaviorTree;

function AddKeySetToBlackBoard(R_BlackBoard BlackBoard)
{
	if(BlackBoard == None)
	{
		return;
	}

	BlackBoard.AddFloat('WaitTime');
	BlackBoard.AddActor('PickupTarget');
	BlackBoard.AddActor('EquipSelection');
}

function BuildBehaviorTree(R_BehaviorTreeBuilder BT)
{
	BT.CreateSequence();
	BT.Push();
		BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
		BT.SetTaskFloat('Duration', 5.0);

		BT.CreateTask(Class'RBots.R_BehaviorTask_SelectEquipTarget');
		BT.MapKeySelector('EquipTarget', 'EquipSelection');

		BT.CreateTask(Class'RBots.R_BehaviorTask_Equip');
		BT.MapKeySelector('InventoryToEquip', 'EquipSelection');

		BT.CreateTask(Class'RBots.R_BehaviorTask_Delay');
		BT.SetTaskFloat('Duration', 5.0);

		return;

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