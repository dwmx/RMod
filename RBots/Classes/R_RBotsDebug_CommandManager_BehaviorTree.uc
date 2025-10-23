//==============================================================================
//	R_RBotsDebug_CommandManager_BehaviorTree
//	Debug commands for Behavior Trees
//==============================================================================
class R_RBotsDebug_CommandManager_BehaviorTree extends R_RBotsDebug_CommandManager;

const LogCategory = 'BehaviorTreeCommandManager';

const Utilities = Class'RBots.R_BotUtilities';

const Command_Show = "Show";
const Command_Hide = "Hide";
const Command_Toggle = "Toggle";
const Command_DumpBT = "DumpBT";

function RegisterCommandList()
{
	RegisterCommand(Command_Show);
	RegisterCommand(Command_Hide);
	RegisterCommand(Command_Toggle);
	RegisterCommand(Command_DumpBT);
}

function bool TryHandleCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_Show:		HandleCommand_Show(DebugMutator, Sender);		return true;
		case Command_Hide:		HandleCommand_Hide(DebugMutator, Sender);		return true;
		case Command_Toggle:	HandleCommand_Toggle(DebugMutator, Sender);		return true;
		case Command_DumpBT:	HandleCommand_DumpBT(DebugMutator, Sender);		return true;
	}

	return false;
}

//------------------------------------------------------------------------------

final function R_RBotsDebug_View_BehaviorTree GetDVBehaviorTree(R_RBotsDebug DebugMutator)
{
	if(DebugMutator == None)
	{
		return None;
	}

	return R_RBotsDebug_View_BehaviorTree(DebugMutator.GetDebugView(Class'RBots.R_RBotsDebug_View_BehaviorTree'));
}

final function R_BehaviorTree GetDebugTargetBehaviorTree(R_RBotsDebug DebugMutator)
{
	local R_Bot Bot;
	local R_BotBehavior ActiveBehavior;

	if(DebugMutator != None)
	{
		Bot = DebugMutator.GetDebugTarget();
		if(Bot != None)
		{
			ActiveBehavior = Bot.GetActiveBehavior();
			if(ActiveBehavior != None)
			{
				return ActiveBehavior.GetBehaviorTree();
			}
		}
	}
	return None;
}

final function R_BlackBoard GetDebugTargetBlackBoard(R_RBotsDebug DebugMutator)
{
	local R_Bot Bot;
	local R_BotBehavior ActiveBehavior;

	if(DebugMutator != None)
	{
		Bot = DebugMutator.GetDebugTarget();
		if(Bot != None)
		{
			ActiveBehavior = Bot.GetActiveBehavior();
			if(ActiveBehavior != None)
			{
				return ActiveBehavior.GetBlackBoard();
			}
		}
	}
	return None;
}

//------------------------------------------------------------------------------

function HandleCommand_Show(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.EnableDebugView(Class'RBots.R_RBotsDebug_View_BehaviorTree');
	}
}

function HandleCommand_Hide(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.DisableDebugView(Class'RBots.R_RBotsDebug_View_BehaviorTree');
	}
}

function HandleCommand_Toggle(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.ToggleDebugView(Class'RBots.R_RBotsDebug_View_BehaviorTree');
	}
}

//------------------------------------------------------------------------------
//	Dump BehaviorTree
function HandleCommand_DumpBT(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_BehaviorTree BehaviorTree;
	local R_BTNode Node;
	local R_BTNode_Composite CompositeNode;
	local R_BTNode NodeStack[128];
	local int NodeDepth[128];
	local int CurrentDepth;
	local int NumNodes, NumChildren;
	local String LogString;
	local int i;

	Utilities.Static.RLog("----------------------", LogCategory);
	Utilities.Static.RLog("Behavior Tree Log Dump", LogCategory);

	BehaviorTree = GetDebugTargetBehaviorTree(DebugMutator);

	if(BehaviorTree == None)
	{
		Utilities.Static.RLog("No Behavior Tree selected for the current Debug Target", LogCategory);
	}
	else
	{
		NodeStack[0] = BehaviorTree.GetRoot();
		NodeDepth[0] = 0;

		NumNodes = 0;
		if(NodeStack[0] != None)
		{
			NumNodes = 1;
		}

		while(NumNodes > 0)
		{
			--NumNodes;
			Node = NodeStack[NumNodes];
			CompositeNode = R_BTNode_Composite(Node);
			CurrentDepth = NodeDepth[NumNodes];

			if(CompositeNode != None)
			{
				NumChildren = CompositeNode.GetChildCount();
				for(i = 0; i < NumChildren; ++i)
				{
					NodeStack[NumNodes] = CompositeNode.GetChild(i);
					NodeDepth[NumNodes] = CurrentDepth + 1;
					++NumNodes;
				}
			}

			LogString = GetNodeLogString(Node, CurrentDepth);
			Utilities.Static.RLog(LogString, LogCategory);
		}
	}

	Utilities.Static.RLog("----------------------", LogCategory);
}

function String GetNodeLogString(R_BTNode Node, int Depth)
{
	local int i;
	local String Result;

	Result = " - ";
	for(i = 0; i < Depth; ++i)
	{
		Result = " - " $ Result;
	}
	Result = Result @ Node.Class;
	return Result;
}