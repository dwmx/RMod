//==============================================================================
//	R_ArpgDBCommands_Main
//	Top level command manager for Arpg debug package
//==============================================================================
class R_ArpgDBCommands_Main extends R_ArpgDBCommandManager;

const Command_NextTarget = "NextTarget";

function RegisterCommandList()
{
	RegisterCommand(Command_NextTarget);
}

function bool TryHandleArpgCommand(String CommandString, R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_NextTarget:		HandleCommand_NextTarget(DebugMutator, Sender);	return true;
	}

	return false;
}

//------------------------------------------------------------------------------
//	Command handlers

function HandleCommand_NextTarget(R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.SelectNextDebugTarget();
	}
}