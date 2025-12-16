class R_ArpgDBCommandMain extends R_ArpgDBCommandManager;

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

function HandleCommand_NextTarget(R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{
	if(Sender != None)
	{
		Sender.ClientMessage("Next target stub");
	}
}