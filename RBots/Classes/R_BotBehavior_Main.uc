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
		BT.Pop();
		BT.CreateSelector();
			BT.Push();
			BT.CreateSequence();
			BT.CreateSequence();
				BT.Push();
				BT.CreateSelector();
			BT.Pop();
		BT.Pop();
		BT.CreateSequence();
}