//==============================================================================
//	R_ArpgDBCommands_Pawns
//	Debug commands for sessions
//==============================================================================
class R_ArpgDBCommands_Pawns extends R_ArpgDBCommandManager;

const Command_Toggle = "Toggle";
const Command_Tags = "Tags";
const Command_Attributes = "Attributes";

function RegisterCommandList()
{
	RegisterCommand(Command_Toggle);
	RegisterCommand(Command_Tags);
	RegisterCommand(Command_Attributes);
}

function bool TryHandleArpgCommand(String CommandString, R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_Toggle:		HandleCommand_Toggle(DebugMutator, Sender);	return true;
		case Command_Tags:			HandleCommand_Tags(DebugMutator, Sender);	return true;
		case Command_Attributes:	HandleCommand_Attributes(DebugMutator, Sender);	return true;
	}

	return false;
}

function R_ArpgDBView_Pawns GetDVPawns(R_ArpgDBMutator DebugMutator)
{
	if(DebugMutator == None)
	{
		return None;
	}

	return R_ArpgDBView_Pawns(DebugMutator.GetDebugView(Class'RArpgDebug.R_ArpgDBView_Pawns'));
}

//------------------------------------------------------------------------------
//	Command handlers

function HandleCommand_Toggle(R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.ToggleDebugView(Class'RArpgDebug.R_ArpgDBView_Pawns');
	}
}

function HandleCommand_Tags(R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{
	local R_ArpgDBView_Pawns View;

	View = GetDVPawns(DebugMutator);
	if(View != None)
	{
		View.ToggleTags();
	}
}

function HandleCommand_Attributes(R_ArpgDBMutator DebugMutator, PlayerPawn Sender)
{
	local R_ArpgDBView_Pawns View;

	View = GetDVPawns(DebugMutator);
	if(View != None)
	{
		View.ToggleAttributes();
	}
}