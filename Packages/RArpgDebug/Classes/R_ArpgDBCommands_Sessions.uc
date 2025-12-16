//==============================================================================
//	R_ArpgDBCommands_Sessions
//	Debug commands for sessions
//==============================================================================
class R_ArpgDBCommands_Sessions extends R_ArpgDBCommandManager;

const Command_Toggle = "Toggle";

function RegisterCommandList()
{
	RegisterCommand(Command_Toggle);
}

function bool TryHandleArpgCommand(String CommandString, R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_Toggle:		HandleCommand_Toggle(DebugMutator, Sender);	return true;
	}

	return false;
}

//------------------------------------------------------------------------------
//	Command handlers

function HandleCommand_Toggle(R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.ToggleDebugView(Class'RArpgDebug.R_ArpgDBView_Sessions');
	}
}