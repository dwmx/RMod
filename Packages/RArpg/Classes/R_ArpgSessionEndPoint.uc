//==============================================================================
//  R_ArpgSessionEndPoint
//  Represents one end point of an item session
//==============================================================================
class R_ArpgSessionEndPoint extends Actor;

var int RequestID;
var R_ArpgSession ItemSession;

var private float RequestTimeOutSeconds; // How long a session will wait for a request response before giving up

struct DataPacket
{
    var int Payload[32];
    var int Sequence;
};

replication
{
    // Server --> Client RPCs
    reliable if(Role == ROLE_Authority)
        ClientAcceptSession,
        ClientReceiveSnapShot;

    // Client --> Server RPCs
    reliable if(Role == ROLE_AutonomousProxy)
        ServerRequestSession,
        ServerSessionMessage;
}

function float GetRequestTimeOutSeconds()
{
    return RequestTimeOutSeconds;
}


function TestSession()
{
    Log("TestSession:" @ Role);
    RequestSession();
}

function RequestSession()
{
    RequestID = Rand(10000);
    Log("I am requesting a session with RequestID" @ RequestID);

    if(ItemSession == None)
    {
        ItemSession = new(Self) Class'RArpg.R_ArpgSession';
        ItemSession.InitializeSession();
        ItemSession.SessionEndPoint = Self;
    }

    ItemSession.ChangeSessionState(1);
    ItemSession.SetSessionID(RequestID);
    ItemSession.SetTimeStamp(Level.TimeSeconds);

    ServerRequestSession(RequestID);
}

function ServerRequestSession(int InRequestID)
{
    local int NewSessionID;
    Log("Server received RequestSession with ID" @ InRequestID);

    NewSessionID = Rand(10000);
    Log("Accepting session with session ID" @ NewSessionID);

    ItemSession = new(Self) Class'RArpg.R_ArpgSession';
    ItemSession.InitializeSession();
    ItemSession.SessionEndPoint = Self;
    
    ItemSession.SetSessionID(NewSessionID);
    ItemSession.ChangeSessionState(2);
    
    ClientAcceptSession(InRequestID, NewSessionID);
}

function ClientAcceptSession(int InRequestID, int SessionID)
{
    Log("Received session accepted, RequestID" @ InRequestID @ "SessionID:" @ SessionID);
    if(InRequestID == ItemSession.SessionID)
    {
        Log("Request ID matched what the client sent -- establishing session");
        ItemSession.SessionID = SessionID;
        ItemSession.ChangeSessionState(2);
    }
    else
    {
        Log("Request ID did not match what client sent, ignoring");
    }
}

event Tick(float DeltaSeconds)
{
    if(ItemSession != None)
    {
        ItemSession.TickSession(DeltaSeconds);
    }
}

function ServerSessionMessage(int SessionID, int SessionMessage)
{
    Log("Server message" @ SessionMessage @ "for SessionID" @ SessionID);
    if(SessionID == ItemSession.SessionID)
    {
        ItemSession.ReceiveSessionMessage(SessionMessage);
    }
}

function SendSnapShot(int SessionID, int Payload[32], int Sequence)
{
    local DataPacket Packet;
    local int i;

    for(i = 0; i < ArrayCount(Payload); ++i)
    {
        Packet.Payload[i] = Payload[i];
    }
    Packet.Sequence = Sequence;

    ClientReceiveSnapShot(SessionID, Packet);
}

function ClientReceiveSnapShot(int SessionID, DataPacket Packet)
{
    local int Payload[32];
    local int i;

    for(i = 0; i < ArrayCount(Payload); ++i)
    {
        Payload[i] = Packet.Payload[i];
    }

    if(ItemSession.SessionID == SessionID)
    {
        ItemSession.ReceiveSnapshot(Payload, Packet.Sequence);
    }
}

defaultproperties
{
    RemoteRole=ROLE_AutonomousProxy
    RequestTimeOutSeconds=5.0
}