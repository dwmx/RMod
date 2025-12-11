//==============================================================================
//	R_RBotsDebug_CommandManager_Target
//	Debug commands for R_Bot debug target view
//==============================================================================
class R_RBotsDebug_CommandManager_Target extends R_RBotsDebug_CommandManager;

const Command_Show				= "Show";
const Command_Hide				= "Hide";
const Command_Toggle			= "Toggle";
const Command_TogglePerception	= "Perception";

function RegisterCommandList()
{
	RegisterCommand(Command_Show);
	RegisterCommand(Command_Hide);
	RegisterCommand(Command_Toggle);
	RegisterCommand(Command_TogglePerception);
}

function bool TryHandleRBotsCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_Show:					HandleCommand_Show(DebugMutator, Sender);					return true;
		case Command_Hide:					HandleCommand_Hide(DebugMutator, Sender);					return true;
		case Command_Toggle:				HandleCommand_Toggle(DebugMutator, Sender);					return true;
		case Command_TogglePerception:		HandleCommand_TogglePerception(DebugMutator, Sender);		return true;
	}

	return false;
}

function R_RBotsDebug_View_Bots GetDVBots(R_RBotsDebug DebugMutator)
{
	if(DebugMutator == None)
	{
		return None;
	}

	return R_RBotsDebug_View_Bots(DebugMutator.GetDebugView(Class'RBots.R_RBotsDebug_View_Bots'));
}

function HandleCommand_Show(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.EnableDebugView(Class'RBots.R_RBotsDebug_View_Bots');
	}
}

function HandleCommand_Hide(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.DisableDebugView(Class'RBots.R_RBotsDebug_View_Bots');
	}
}

function HandleCommand_Toggle(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.ToggleDebugView(Class'RBots.R_RBotsDebug_View_Bots');
	}
}

function HandleCommand_TogglePerception(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_Bots DVBots;

	DVBots = GetDVBots(DebugMutator);
	if(DVBots != None)
	{
		DVBots.ToggleDrawPerception();
	}
}