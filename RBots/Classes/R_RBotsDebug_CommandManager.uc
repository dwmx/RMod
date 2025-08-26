//==============================================================================
//	R_RBotsDebug_CommandManager
//	Manages all debug commands available with the RBots debug mutator
//
//	This supports a hierarchical structure for commands, where command manager
//	places a list of commands inside of a namespace
//
//	e.g. for the command string 'RBots.NavMesh.Show':
//	- Command manager with namespace 'RBots'
//	- Contains command manager with namespace 'NavMesh'
//	- Which handles a command 'Show'
//
//	To implement commands, extend this class and override functions:
//	- RegisterCommandList
//	- TryHandleCommand
//==============================================================================
class R_RBotsDebug_CommandManager extends Object;

const LogCategory = 'CommandManager';
const Utilities = Class'RBots.R_BotUtilities';

var private Name NameSpace;

const MAX_SUB_COMMAND_MANAGERS = 16;
var private R_RBotsDebug_CommandManager SubCommandManagers[16];
var private int NumSubCommandManagers;

const MAX_COMMANDS = 128;
var private String CommandStrings[128];
var private int NumCommandStrings;

function Initialize(Name NewNameSpace)
{
	NameSpace = NewNameSpace;
	NumSubCommandManagers = 0;
	NumCommandStrings = 0;

	RegisterCommandList();
}

final function RegisterCommand(String CommandString)
{
	if(NumCommandStrings == MAX_COMMANDS)
	{
		Utilities.Static.RLog("RegisterSingleCommand failed for '" $ CommandString $ "' -- Maximum commands reached:" @ MAX_COMMANDS);
		return;
	}
	CommandStrings[NumCommandStrings] = CommandString;
	++NumCommandStrings;
}

function AddSubCommandManager(R_RBotsDebug_CommandManager SubCommandManager)
{
	if(SubCommandManager == None)
	{
		return;
	}

	if(NumSubCommandManagers >= MAX_SUB_COMMAND_MANAGERS)
	{
		Utilities.Static.RLog("AddSubCommandManager failed -- maximum sub command managers reached:" @ MAX_SUB_COMMAND_MANAGERS, LogCategory);
		return;
	}

	SubCommandManagers[NumSubCommandManagers] = SubCommandManager;
	++NumSubCommandManagers;
}

function PrintAllCommands(PlayerPawn Receiver, optional String ParentNameSpaceString)
{
	local String NameSpaceString;
	local int i;

	if(Receiver == None)
	{
		return;
	}

	NameSpaceString = ParentNameSpaceString $ "." $ String(NameSpace);

	for(i = 0; i < NumCommandStrings; ++i)
	{
		Receiver.ClientMessage(NameSpaceString $ "." $ CommandStrings[i]);
	}
}

final function bool ReceiveCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local String TopLevelString, RemainingString;

	local int DotIndex;
	local int i;

	// If plain namespace, print available commands
	if(Caps(CommandString) == Caps(String(NameSpace)))
	{
		PrintAllCommands(Sender);
		return true;
	}

	// Pull out command namespace
	TopLevelString = "";
	DotIndex = InStr(CommandString, ".");
	if(DotIndex != -1)
	{
		TopLevelString = Mid(CommandString, 0, DotIndex);
		CommandString = Mid(CommandString, DotIndex + 1);
	}

	if(TopLevelString != "" && Caps(TopLevelString) != Caps(String(NameSpace)))
	{	// Command string not sent to this namespace
		return false;
	}

	// Try to handle the command in this namespace
	if(InStr(CommandString, ".") == -1)
	{
		if(TryHandleCommand(CommandString, DebugMutator, Sender))
		{
			return true;
		}
	}

	// If not handled, try to pass on to sub managers
	for(i = 0; i < NumSubCommandManagers; ++i)
	{
		if(SubCommandManagers[i].ReceiveCommand(CommandString, DebugMutator, Sender))
		{
			return true;
		}
	}

	return false;
}

// Provides commands the ability to respond to the user
final function CommandResponse(R_RBotsDebug DebugMutator, PlayerPawn Sender, String ResponseString)
{
	if(Sender != None)
	{
		Sender.ClientMessage(ResponseString);
	}
}

//------------------------------------------------------------------------------
// Implement these functions in sub command managers to add commands
function RegisterCommandList() {}
function bool TryHandleCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender) { return false; }