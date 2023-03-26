//=============================================================================
// UTerminal.TcpConnection
// Represents a connection to the terminal over tcp
//=============================================================================
class TcpConnection extends IpDrv.TcpLink;

var Terminal TerminalInterface;
var TcpServer Server;
var String UserName;

// Helper functions
var class<StaticUtilities> Utilities;

//=============================================================================
// Queue of buffered messages, processed by Tick
enum EMessageType
{
    MT_Auth,    // Authorization
    MT_Cmd,     // Message contains a commang string
    MT_Msg      // Message should be sent to players as a game-message
};

struct FBufferedMessage
{
    var EMessageType MessageType;
    var String Message;
};

const MAX_BUFFERED_MESSAGES = 32;
struct FBufferedMessageQueue
{
    var FBufferedMessage Messages[32];
    var int HeadIndex;
    var int TailIndex;
};
var FBufferedMessageQueue BufferedMessageQueue;

function FBufferedMessageQueue_Initialize(
    out FBufferedMessageQueue Queue)
{
    Queue.HeadIndex = 0;
    Queue.TailIndex = 0;
}

function FBufferedMessageQueue_Push(
    out FBufferedMessageQueue Queue,
    EMessageType MessageType,
    String Message)
{
    if((Queue.HeadIndex + 1) % MAX_BUFFERED_MESSAGES == Queue.TailIndex)
    {
        // Queue full
        Warn("Dropped message due to full buffer");
        return;
    }
    
    Queue.Messages[Queue.HeadIndex].MessageType = MessageType;
    Queue.Messages[Queue.HeadIndex].Message = Message;
    Queue.HeadIndex = (Queue.HeadIndex + 1) % MAX_BUFFERED_MESSAGES;
}

function FBufferedMessage FBufferedMessageQueue_Pop(
    out FBufferedMessageQueue Queue)
{
    local FBufferedMessage Result;

    if(Queue.HeadIndex == Queue.TailIndex)
    {
        return Result;
    }
    
    Result.MessageType = Queue.Messages[Queue.TailIndex].MessageType;
    Result.Message = Queue.Messages[Queue.TailIndex].Message;
    Queue.TailIndex = (Queue.TailIndex + 1) % MAX_BUFFERED_MESSAGES;
    return Result;
}

function bool FBufferedMessageQueue_HasMessages(
    out FBufferedMessageQueue Queue)
{
    if(Queue.HeadIndex == Queue.TailIndex)
    {
        return false;
    }
    return true;
}

event BeginPlay()
{
    // Cache server
    if(Owner != None && TcpServer(Owner) != None)
    {
        Server = TcpServer(Owner);
    }

    // Cache terminal
    if(Server != None && Server.Owner != None && Terminal(Owner.Owner) != None)
    {
        TerminalInterface = Terminal(Owner.Owner);
    }

    if(TerminalInterface == None)
    {
        Warn("Failed to establish connection to terminal interface");
    }

    FBufferedMessageQueue_Initialize(BufferedMessageQueue);
}

event ReceivedText(String Text)
{
    local String Token;
    local EMessageType MessageType;
    local String Message;

    Token = GetToken(Text);
    switch(Caps(Token))
    {
        case "AUTH":
            MessageType = MT_Auth;
            break;
        case "CMD":
            MessageType = MT_Cmd;
            break;
        case "MSG":
            MessageType = MT_Msg;
            break;
        default:
            Warn(Self @ "unhandled message type:" @ Token);
            break;
    }
    
    Message = Text;
    FBufferedMessageQueue_Push(BufferedMessageQueue, MessageType, Message);
}

event Tick(float DeltaSeconds)
{
    local FBufferedMessage BufferedMessage;

    while(FBufferedMessageQueue_HasMessages(BufferedMessageQueue))
    {
        BufferedMessage = FBufferedMessageQueue_Pop(BufferedMessageQueue);
        switch(BufferedMessage.MessageType)
        {
            case MT_Auth:
                ProcessMessage_Auth(BufferedMessage.Message);
                break;
            case MT_Cmd:
                ProcessMessage_Cmd(BufferedMessage.Message);
                break;
            case MT_Msg:
                ProcessMessage_Msg(BufferedMessage.Message);
                break;
            default:
                Warn("Unhandled message:" @ BufferedMessage.Message);
                break;
        }
    }
}

// To be implemented in states
function ProcessMessage_Auth(String Message);
function ProcessMessage_Cmd(String Message);
function ProcessMessage_Msg(String Message);

event Opened()
{
    Log(Self @ "opened connection");
}

event Closed()
{
    log(Self @ "closed connection");
}

//=============================================================================
// Awaiting user authentication credentials
auto state AuthUserName
{
    event Accepted()
    {
        Log(Self @ "established connection:" @
            IpAddrToString(RemoteAddr) $ ", awaiting authentication");
    }

    function ProcessMessage_Auth(String Message)
    {
        local String AuthToken;

        Log(Self @ "authenticating user name");
        if(Server.CheckValidUsername(Message))
        {
            UserName = Message;
            GotoState('AuthPassword');
        }
        else
        {
            SendText("No such user");
            Close();
        }
    }
}

state AuthPassword
{
    event BeginState()
    {
        SendText("Password for" @ UserName $ ": ");
    }

    function ProcessMessage_Auth(String Message)
    {
        Log("Password:" @ Message);
        if(Server.ValidateCredentials(UserName, Message))
        {
            Log(Self @ UserName @ "authenticated");
            GotoState('Active');
        }
        else
        {
            Log(Self @ UserName @ "failed password authentication");
        }
    }
}

//=============================================================================
// User has been authenticated and is connected to terminal
state Active
{
    event BeginState()
    {
        local String ConnectedString;
        local String CRLF;

        Log(Self @ "active and listening for user input");

        CRLF = Utilities.Static.CRLF();
        ConnectedString = "Welcome" @ UserName $ CRLF;
        ConnectedString = ConnectedString $
            "Type 'commands' for a list of available commands";
        SendText(ConnectedString);
    }

    function ProcessMessage_Cmd(String Message)
    {
        local String ResponseString;
        local String ErrorString;
        local String CRLF;

        TerminalInterface.ExecuteInputString(
            Self, Message, ResponseString, ErrorString);
        
        CRLF = Utilities.Static.CRLF();
        if(ErrorString != "")
        {
            ResponseString = "Error:" @ ErrorString;
        }
        else
        {
            ResponseString = "Response:" $ CRLF $ ResponseString;
        }
        SendText(ResponseString);
    }
    
    function ProcessMessage_Msg(String Message)
    {
        local String SayString;

        SayString = UserName $ ":" @ Message;
        TerminalInterface.BroadcastMessage(SayString);
        SendText(SayString);
    }
}

defaultproperties
{
    Utilities=class'UTerminal.StaticUtilities'
}