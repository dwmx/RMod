//==============================================================================
//	R_RBotsDebug_CommandManager
//==============================================================================
class R_RBotsDebug_CommandManager extends RDebugTools.R_DBCommandManager;

function bool TryHandleCommand(String CommandString, R_DBMutator DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug RBotsDebug;

	RBotsDebug = R_RBotsDebug(DebugMutator);
	return TryHandleRBotsCommand(CommandString, RBotsDebug, Sender);
}

function bool TryHandleRBotsCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{ return false; }