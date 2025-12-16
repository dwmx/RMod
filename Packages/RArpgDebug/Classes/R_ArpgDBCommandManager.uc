//==============================================================================
//	R_ArpgDBCommandManager
//	Base command manager class for RArpg debug package
//==============================================================================
class R_ArpgDBCommandManager extends RDebugTools.R_DBCommandManager;

function bool TryHandleCommand(String CommandString, R_DBMutator DebugMutator, PlayerPawn Sender)
{
	local R_ArpgDBMutator ArpgDBMutator;

	ArpgDBMutator = R_ArpgDBMutator(DebugMutator);
	return TryHandleArpgCommand(CommandString, ArpgDBMutator, Sender);
}

function bool TryHandleArpgCommand(String CommandString, R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{ return false; }