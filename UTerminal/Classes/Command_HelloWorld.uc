//=============================================================================
// UTerminal.Command_HelloWorld
// Hello world example command for UTerminal
//=============================================================================
class Command_HelloWorld extends UTerminal.Command;

// Example string argument
var String Message;

// Example int argument
var int Number;

static function String HelpString_Basic()
{
    return "This is the 'Hello World!' example";
}

function ExposeParameters()
{
    ExposeStringParameter("Message");
    ExposeIntParameter("Number");
}

// Run the command from console or terminal client as follows:
//      HelloWorld Message=<String> Number=<Int>
//      e.g. HelloWorld Message=Hello Number=20
function Execute()
{
    local String Result;

    Result = "Hello World!";
    if(Message != Class.Default.Message)
    {
        Result = Result @ "User says" @ Message;
    }
    if(Number != Class.Default.Number)
    {
        Result = Result @ "User likes the number" @ Number;
    }

    if(TerminalInstance != None)
    {
        TerminalInstance.BroadcastMessage(Result);
    }
    Log(Result);

    ErrorString = "This is what an error string looks like";
    ResponseString = "You successfully executed the HelloWorld command";
}

defaultproperties
{
    ExecString="HelloWorld"
    Message=""
    Number=0
}