//==============================================================================
//	R_RBotsDebug_CommandManager_Player
//	Debug commands for Player
//==============================================================================
class R_RBotsDebug_CommandManager_Player extends R_RBotsDebug_CommandManager;

const Command_Show = "Show";
const Command_Hide = "Hide";
const Command_Toggle = "Toggle";
const Command_Animation = "Animation";

function RegisterCommandList()
{
	RegisterCommand(Command_Show);
	RegisterCommand(Command_Hide);
	RegisterCommand(Command_Toggle);
	RegisterCommand(Command_Animation);
}

function bool TryHandleCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_Show:					HandleCommand_Show(DebugMutator, Sender);						return true;
		case Command_Hide:					HandleCommand_Hide(DebugMutator, Sender);						return true;
		case Command_Toggle:				HandleCommand_Toggle(DebugMutator, Sender);						return true;
		case Command_Animation:				HandleCommand_Animation(DebugMutator, Sender);					return true;
	}

	return false;
}

function R_RBotsDebug_View_Player GetDVPlayer(R_RBotsDebug DebugMutator)
{
	if(DebugMutator == None)
	{
		return None;
	}

	return R_RBotsDebug_View_Player(DebugMutator.GetDebugView(Class'RBots.R_RBotsDebug_View_Player'));
}

function HandleCommand_Show(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.EnableDebugView(Class'RBots.R_RBotsDebug_View_Player');
	}
}

function HandleCommand_Hide(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.DisableDebugView(Class'RBots.R_RBotsDebug_View_Player');
	}
}

function HandleCommand_Toggle(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.ToggleDebugView(Class'RBots.R_RBotsDebug_View_Player');
	}
}

function HandleCommand_Animation(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_Player DVPlayer;

	DVPlayer = GetDVPlayer(DebugMutator);
	if(DVPlayer != None)
	{
		DVPlayer.ToggleDrawAnimationInfo();
	}
}