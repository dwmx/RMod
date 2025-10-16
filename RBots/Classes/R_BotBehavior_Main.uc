//==============================================================================
//	R_BotBehavior_Main
//	Main bot behavior
//==============================================================================
class R_BotBehavior_Main extends R_BotBehavior;

function BuildBehaviorTree(R_BTBuilder BT)
{
	BT.CreateSequence();
	BT.Push();
		BT.CreateSequence();
		BT.Push();
			BT.CreateSequence();
			BT.Push();
				BT.CreateTask(Class'RBots.R_BTTask_Delay');
				//BT.CreateTask(Class'RBots.R_BTTask_SelectInventory');
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
	return;


/*

				BT.CreateTask(Class'RBots.R_BTTask_MoveInDirection');

				BT.Pop();
			BT.Pop();
		BT.CreateSelector();
		BT.Push();
			BT.CreateSequence();
			BT.Push();
				BT.CreateTask(Class'RBots.R_BTTask_Delay');
				BT.CreateTask(Class'RBots.R_BTTask_Delay');
				BT.Pop();
			BT.CreateSequence();
			BT.Push();
				BT.CreateSelector();
				BT.Push();
					BT.CreateTask(Class'RBots.R_BTTask_Delay');
					BT.CreateTask(Class'RBots.R_BTTask_Delay');
					BT.Pop();
				BT.Pop();
			BT.Pop();
		BT.CreateSequence();
		BT.Push();
			BT.CreateTask(Class'RBots.R_BTTask_Delay');
			*/
}