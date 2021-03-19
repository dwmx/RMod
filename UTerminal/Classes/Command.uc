//=============================================================================
// UTerminal.Command
// Base class for all commands capable of being executed by the terminal
// To extend UTerminal for custom functionality, create a child class and
// register the command in your package's .int file
//=============================================================================
class Command extends Object abstract;

// The string to be typed in order to execute this command
var String ExecString;

// Execution context
var Terminal TerminalInstance;

// Actor who called this command, typically will be a PlayerPawn if called
// from the game console, or a TcpConnection if called from a terminal client
var Actor Caller;

// Both strings initially set to the empty string
// If the command sets these, they will be sent to the caller after execution
var String ResponseString;
var String ErrorString;

// Helper functions
var class<StaticUtilities> Utilities;
 
// Used for type checking during argument parsing
enum EParameterType
{
    PT_Bool,
    PT_Int,
    PT_Float,
    PT_String
};

const MAX_PARAMETERS = 16;
var private struct FParameterDecl
{
    var EParameterType Type;    // Enum parameter type
    var String ParameterName;    // String name of the exposed parameter
    var bool bPassedIn;         // Has this parameter been passed in or not
} ParameterDecls[16];
var int ParameterDeclCount;

// Called by Terminal immediately after creation
final function Initialize(String Arguments)
{
    local String ArgumentToken;
    local int i;

    ParameterDeclCount = 0;
    for(i = 0; i < MAX_PARAMETERS; ++i)
    {
        ParameterDecls[i].bPassedIn = false;
    }
    ExposeParameters();

    while(Arguments != "")
    {
        ArgumentToken = GetToken(Arguments);
        ParseArgument(ArgumentToken);
    }
}

final function ParseArgument(String Argument)
{
    local String ParameterName;
    local String VariableValue;
    local int Index;
    local int i;

    Index = InStr(Argument, "=");
    if(Index != -1)
    {
        ParameterName = Left(Argument, Index);
        VariableValue = Mid(Argument, Index + 1);
    }

    // Find a matching exposed variable
    for(i = 0; i < ParameterDeclCount; ++i)
    {
        if(Caps(ParameterDecls[i].ParameterName) == Caps(ParameterName))
        {
            break;
        }
    }

    if(i >= ParameterDeclCount)
    {
        Warn("Invalid argument:" @ Argument);
        return;
    }

    // TODO: Perform value verification based on param type

    ParameterDecls[i].bPassedIn = true;
    SetPropertyText(ParameterName, VariableValue);
}

final function bool CheckParameterPassedIn(String ParameterName)
{
    local int i;

    for(i = 0; i < ParameterDeclCount; ++i)
    {
        if(ParameterDecls[i].ParameterName == ParameterName)
        {
            return ParameterDecls[i].bPassedIn;
        }
    }
    return false;
}

final function ExposeParameter(
    EParameterType Type,
    String ParameterName)
{
    if(ParameterDeclCount >= MAX_PARAMETERS)
    {
        Warn("Too many parameters declared for command, failed to declare:" @ ParameterName);
        return;
    }

    ParameterDecls[ParameterDeclCount].Type = Type;
    ParameterDecls[ParameterDeclCount].ParameterName = ParameterName;
    ++ParameterDeclCount;
}

final function ExposeBoolParameter(String ParameterName)
{
    ExposeParameter(PT_Bool, ParameterName);
}

final function ExposeIntParameter(String ParameterName)
{
    ExposeParameter(PT_Int, ParameterName);
}

final function ExposeFloatParameter(String ParameterName)
{
    ExposeParameter(PT_Float, ParameterName);
}

final function ExposeStringParameter(String ParameterName)
{
    ExposeParameter(PT_String, ParameterName);
}

////////////////////////////////////////////////////////////////////////////////
// Functions to be implemented for each command

// Returns true if this command should be enabled for the current game
// Use LevelContext to check relevant conditions like game mode
static function bool ShouldEnableCommand(LevelInfo LevelContext)
{
    return true;
}

// Return a basic, one-line help string for the command
static function String HelpString_Basic()
{
    return "";
}

// Return a detailed help string for the command
static function String HelpString_Detailed()
{
    return "";
}

// Expose uc variables to the command interface
function ExposeParameters();

// Run the command, returns true is executed successfully
// If OutResponse is set, it will be sent to the caller
function Execute();

// Called immediately before command destruction
function Cleanup();

defaultproperties
{
    ExecString=""
    ResponseString=""
    ErrorString=""
    Utilities=class'UTerminal.StaticUtilities'
}