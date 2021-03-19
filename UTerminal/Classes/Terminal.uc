//=============================================================================
// UTerminal.Terminal
// Primary server-side Actor which manages the command interface
// Enable terminal by adding ServerActors=UTerminal.Terminal to config
//=============================================================================
class Terminal extends Engine.Actor;

var ListNode CommandList;

// Remote server access
var private TcpServer RemoteServer;
var config bool bEnableRemoteServer;
var class<TcpServer> RemoteServerClass;

// In-game console access
var private ConsoleInterfaceDaemon ConsoleServer;
var config bool bEnableConsoleInterface;
var class<ConsoleInterfaceDaemon> ConsoleServerClass;

event PostBeginPlay()
{
    Log("Terminal created");
    LoadCommandList();

    // Spawn remote server
    if(bEnableRemoteServer && RemoteServerClass != None)
    {
        RemoteServer = Spawn(RemoteServerClass, Self);
    }
    else
    {
        Log(Self @ ": Terminal remote server disabled");
    }

    // Spawn in-game console server
    if(bEnableConsoleInterface && ConsoleServerClass != None)
    {
        ConsoleServer = Spawn(ConsoleServerClass, Self);
    }
    else
    {
        Log(Self @ ": In-game console interface disabled");
    }
}

event Destroyed()
{
    if(RemoteServer != None)
    {
        RemoteServer.Destroy();
    }

    if(ConsoleServer != None)
    {
        ConsoleServer.Destroy();
    }
}

function LoadCommandList()
{
    local ListNode TempNode;
    local String CommandClassString;
    local class<Command> CommandClass;
    local int i;

    Log("Loading registered terminal commands");

    CommandList = None;
    CommandClassString = Level.GetNextInt("UTerminal.Command", 0);

    for(i = 0; CommandClassString != "";
        CommandClassString = Level.GetNextInt("UTerminal.Command", ++i))
    {
        CommandClass = class<Command>(
            DynamicLoadObject(CommandClassString, class'Class'));
        
        // Validate command
        if(CommandClass == None)
        {
            // Invalid command registered in an int file
            Warn("No matching command class for:" @ CommandClassString);
            continue;
        }
        
        // Allow command to determine if it should or should not be loaded
        if(!CommandClass.Static.ShouldEnableCommand(Level))
        {
            continue;
        }
        
        TempNode = new(None) class'ListNode';
        TempNode.Tag = CommandClass.Default.ExecString;
        TempNode.Data = CommandClassString;

        if(CommandList == None)
        {
            CommandList = TempNode;
        }
        else
        {
            CommandList.AddElement(TempNode);
        }
    }

    // Log all loaded commands
    TempNode = CommandList;
    while(TempNode != None)
    {
        TempNode = TempNode.Next;
    }
}

function class<Command> FindCommandClassByExecString(String ExecString)
{
    local ListNode IteratorNode;

    IteratorNode = CommandList;
    while(IteratorNode != None)
    {
        if(Caps(IteratorNode.Tag) == Caps(ExecString))
        {
            return class<Command>(
                DynamicLoadObject(IteratorNode.Data, class'Class'));
        }
        IteratorNode = IteratorNode.Next;
    }
    return None;
}

function RunCommand(
    Actor Caller,
    class<Command> CommandClass,
    String Arguments,
    optional out String ResponseString,
    optional out String ErrorString)
{
    local Command CommandInstance;

    CommandInstance = new(None) CommandClass;
    if(CommandInstance == None)
    {
        Warn("Failed to run command" @ CommandClass);
        return;
    }
    
    CommandInstance.TerminalInstance = Self;
    CommandInstance.Caller = Caller;
    CommandInstance.Initialize(Arguments);
    CommandInstance.Execute();
    CommandInstance.Cleanup();
    ResponseString = CommandInstance.ResponseString;
    ErrorString = CommandInstance.ErrorString;
    CommandInstance = None;
}

function ExecuteInputString(
    Actor Caller,
    String InputString,
    optional out String ResponseString,
    optional out String ErrorString)
{
    local String ExecStringToken;
    local class<Command> CommandClass;

    ExecStringToken = GetToken(InputString);
    CommandClass = FindCommandClassByExecString(ExecStringToken);
    if(CommandClass == None)
    {
        Warn("No matching command found for" @ ExecStringToken);
        return;
    }
    
    RunCommand(Caller, CommandClass, InputString, ResponseString, ErrorString);
}

defaultproperties
{
    RemoteRole=ROLE_None
    DrawType=DT_None
    bEnableRemoteServer=true
    RemoteServerClass=class'UTerminal.TcpServer'
    bEnableConsoleInterface=true
    ConsoleServerClass=class'UTerminal.ConsoleInterfaceDaemon'
}