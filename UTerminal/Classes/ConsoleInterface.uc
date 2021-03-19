//=============================================================================
// UTerminal.ConsoleInterface
// Server-side actor which attaches to a PlayerPawn to intercept console
// commands and forward them to the Terminal
// ConsoleInterfaceDaemon manages all of the ConsoleInterface actors and
// which PlayerPawns they are attached to
//=============================================================================
class ConsoleInterface extends Engine.Inventory;

var Terminal TerminalInterface;
var class<StaticUtilities> Utilities;

// Message the owner to inform them they have access to this interface now
event BeginPlay()
{
    if(Owner == None || PlayerPawn(Owner) == None)
    {
        return;
    }
    
    //PlayerPawn(Owner).ClientMessage(
    //    "UTerminal enabled, execute commands with 'admin cmd <command name>'");
    //PlayerPawn(Owner).ClientMessage(
    //    "Type 'admin cmd commands' for a list of all available commands");
}

// Server-side console comand interceptor
// Clients will execute command as follows:
//      admin cmd <command string>
//      e.g. admin cmd helloworld message=hello
exec function Cmd(String InputString)
{
    local String ResponseString;
    local String ErrorString;
    local String Result;

    Log(Self $ ".Cmd:" @ InputString);

    // If no input, print command list
    if(InputString == "")
    {
        InputString = "commands";
    }

    TerminalInterface.ExecuteInputString(
        Self, InputString, ResponseString, ErrorString);
    
    if(Owner == None || PlayerPawn(Owner) == None)
    {
        return;
    }

    if(ErrorString != "")
    {
        Result = "ERROR: (" $ ErrorString $ ") ";
    }
    Result = Result @ ResponseString;
    SendCommandStringAsClientMessages(Result);
}

// Given a message with CRLFs, send the lines as multiple client messages
function SendCommandStringAsClientMessages(String CommandString)
{
    local String CRLF;
    local String Line;

    if(Owner == None || PlayerPawn(Owner) == None)
    {
        return;
    }

    CRLF = Utilities.Static.CRLF();
    while(CommandString != "")
    {
        Line = Utilities.Static.GetTokenUsingDelimiter(CommandString, CRLF);
        PlayerPawn(Owner).ClientMessage(Line);
    }
}

defaultproperties
{
    RemoteRole=ROLE_None
    Utilities=class'UTerminal.StaticUtilities'
}