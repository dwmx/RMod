//==============================================================================
//	R_ArpgDBCommands_UI
//	Debug commands for sessions
//==============================================================================
class R_ArpgDBCommands_UI extends R_ArpgDBCommandManager;

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

function R_ArpgDBView_UI GetDVUI(R_ArpgDBMutator DebugMutator)
{
	if(DebugMutator == None)
	{
		return None;
	}

	return R_ArpgDBView_UI(DebugMutator.GetDebugView(Class'RArpgDebug.R_ArpgDBView_UI'));
}

//------------------------------------------------------------------------------
//	Command handlers

function HandleCommand_Toggle(R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.ToggleDebugView(Class'RArpgDebug.R_ArpgDBView_UI');
	}
}