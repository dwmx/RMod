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
    var EParameterType Type;
    var String VariableName;
} ParameterDecls[16];
var int ParameterDeclCount;

// Called by Terminal immediately after creation
final function Initialize(String Arguments)
{
    local String ArgumentToken;

    ParameterDeclCount = 0;
    ExposeParameters();

    while(Arguments != "")
    {
        ArgumentToken = GetToken(Arguments);
        ParseArgument(ArgumentToken);
    }
}

final function ParseArgument(String Argument)
{
    local String VariableName;
    local String VariableValue;
    local int Index;
    local int i;

    Index = InStr(Argument, "=");
    if(Index != -1)
    {
        VariableName = Left(Argument, Index);
        VariableValue = Mid(Argument, Index + 1);
    }

    // Find a matching exposed variable
    for(i = 0; i < ParameterDeclCount; ++i)
    {
        if(Caps(ParameterDecls[i].VariableName) == Caps(VariableName))
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

    SetPropertyText(VariableName, VariableValue);
}

final function ExposeParameter(
    EParameterType Type,
    String VariableName)
{
    if(ParameterDeclCount >= MAX_PARAMETERS)
    {
        Warn("Too many parameters declared for command, failed to declare:" @ VariableName);
        return;
    }

    ParameterDecls[ParameterDeclCount].Type = Type;
    ParameterDecls[ParameterDeclCount].VariableName = VariableName;
    ++ParameterDeclCount;
}

final function ExposeBoolParameter(String VariableName)
{
    ExposeParameter(PT_Bool, VariableName);
}

final function ExposeIntParameter(String VariableName)
{
    ExposeParameter(PT_Int, VariableName);
}

final function ExposeFloatParameter(String VariableName)
{
    ExposeParameter(PT_Float, VariableName);
}

final function ExposeStringParameter(String VariableName)
{
    ExposeParameter(PT_String, VariableName);
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