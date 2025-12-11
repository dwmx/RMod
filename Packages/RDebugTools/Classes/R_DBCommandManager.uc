//==============================================================================
//	R_DBCommandManager
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
class R_DBCommandManager extends Object;

const LogCategory = 'Debug';
const LogSubCategory = 'CommandManager';

const Utilities = Class'RBase.R_AUtilityLibrary';

var private Name NameSpace;
var private String ParentNameSpace;

const MAX_SUB_COMMAND_MANAGERS = 16;
var private R_DBCommandManager SubCommandManagers[16];
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
		Utilities.Static.RLog("RegisterSingleCommand failed for '" $ CommandString $ "' -- Maximum commands reached:" @ MAX_COMMANDS, LogCategory, LogSubCategory);
		return;
	}
	CommandStrings[NumCommandStrings] = CommandString;
	++NumCommandStrings;
}

function AddSubCommandManager(R_DBCommandManager SubCommandManager)
{
	if(SubCommandManager == None)
	{
		return;
	}

	if(NumSubCommandManagers >= MAX_SUB_COMMAND_MANAGERS)
	{
		Utilities.Static.RLog("AddSubCommandManager failed -- maximum sub command managers reached:" @ MAX_SUB_COMMAND_MANAGERS, LogCategory, LogSubCategory);
		return;
	}

	SubCommandManagers[NumSubCommandManagers] = SubCommandManager;
	if(ParentNameSpace == "")
	{
		SubCommandManagers[NumSubCommandManagers].ParentNameSpace = String(NameSpace);
	}
	else
	{
		SubCommandManagers[NumSubCommandManagers].ParentNameSpace = ParentNameSpace $ "." $ String(NameSpace);
	}
	
	++NumSubCommandManagers;
}

function Name GetNameSpace()
{
	return NameSpace;
}

function String GetFullyQualifiedNameSpaceString()
{
	if(ParentNameSpace == "")
	{
		return String(NameSpace);
	}
	return ParentNameSpace $ "." $ String(NameSpace);
}

function PrintAllCommands(PlayerPawn Receiver)
{
	local String NameSpaceString;
	local int i;

	if(Receiver == None)
	{
		return;
	}

	NameSpaceString = GetFullyQualifiedNameSpaceString();

	// Print all command strings inside this namespace
	Receiver.ClientMessage("-------------Available Commands-------------");
	for(i = 0; i < NumCommandStrings; ++i)
	{
		Receiver.ClientMessage(NameSpaceString $ "." $ CommandStrings[i]);
	}

	// Print all sub-command manager namespaces
	if(NumSubCommandManagers > 0)
	{
		Receiver.ClientMessage("-------------Available NameSpaces-------------");
		for(i = 0; i < NumSubCommandManagers; ++i)
		{
			Receiver.ClientMessage(NameSpaceString $ "." $ String(SubCommandManagers[i].GetNameSpace()));
		}
	}
}

final function bool ReceiveCommand(String CommandString, R_DBMutator DebugMutator, PlayerPawn Sender)
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
final function CommandResponse(R_DBMutator DebugMutator, PlayerPawn Sender, String ResponseString)
{
	if(Sender != None)
	{
		Sender.ClientMessage(ResponseString);
	}
}

//------------------------------------------------------------------------------
// Implement these functions in sub command managers to add commands
function RegisterCommandList() {}
function bool TryHandleCommand(String CommandString, R_DBMutator DebugMutator, PlayerPawn Sender) { return false; }