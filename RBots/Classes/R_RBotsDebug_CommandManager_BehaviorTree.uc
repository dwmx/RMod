//==============================================================================
//	R_RBotsDebug_CommandManager_BehaviorTree
//	Debug commands for Behavior Trees
//==============================================================================
class R_RBotsDebug_CommandManager_BehaviorTree extends R_RBotsDebug_CommandManager;

const Command_Show = "Show";
const Command_Hide = "Hide";
const Command_Toggle = "Toggle";

function RegisterCommandList()
{
	RegisterCommand(Command_Show);
	RegisterCommand(Command_Hide);
	RegisterCommand(Command_Toggle);
}

function bool TryHandleCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_Show:						HandleCommand_Show(DebugMutator, Sender);					return true;
		case Command_Hide:						HandleCommand_Hide(DebugMutator, Sender);					return true;
		case Command_Toggle:					HandleCommand_Toggle(DebugMutator, Sender);					return true;
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