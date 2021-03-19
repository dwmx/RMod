//=============================================================================
// UTerminal.Command_Commands
// Return a list of all commands available for the current terminal
//=============================================================================
class Command_Commands extends UTerminal.Command;

static function String HelpString_Basic()
{
    return "Print a list of all commands available for the current game";
}

function Execute()
{
    local ListNode IteratorNode;
    local class<Command> CommandClass;
    local String HelpString;
    local String CRLF;
    local String PaddingString;
    local int CommandColumnLength;
    local int i;

    if(TerminalInstance == None)
    {
        return;
    }

    CRLF = Utilities.Static.CRLF();

    CommandColumnLength = GetLengthOfLongestCommandTag();

    ResponseString = "";
    IteratorNode = TerminalInstance.CommandList;
    while(IteratorNode != None)
    {
        // Command name
        if(ResponseString != "")
        {
            ResponseString = ResponseString $ CRLF;
        }
        ResponseString = ResponseString $ IteratorNode.Tag;

        // Simple command description
        CommandClass = class<Command>(
            DynamicLoadObject(IteratorNode.Data, class'Class'));

        if(CommandClass != None)
        {
            HelpString = CommandClass.Static.HelpString_Basic();
            if(HelpString != "")
            {
                // Guarantee there's at least 8 spaces between columns
                PaddingString = "";
                for(i = Len(IteratorNode.Tag); i < CommandColumnLength + 8; ++i)
                {
                    PaddingString = PaddingString $ ".";
                }

                ResponseString = ResponseString $ PaddingString $
                    CommandClass.Static.HelpString_Basic();
            }
        }

        IteratorNode = IteratorNode.Next;
    }
}

function int GetLengthOfLongestCommandTag()
{
    local ListNode IteratorNode;
    local int Result;
    local int Candidate;

    Result = 0;
    for(IteratorNode = TerminalInstance.CommandList;
        IteratorNode != None;
        IteratorNode = IteratorNode.Next)
    {
        Result = Max(Result, Len(IteratorNode.Tag));
    }
    
    return Result;
}

defaultproperties
{
    ExecString="Commands"
}