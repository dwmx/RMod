class R_ArpgSession extends Object;

const SessionMessage_SendSnapShot = 6;

const SessionState_Inactive = 0;
const SessionState_Requested = 1;
const SessionState_Active = 2;

var float TimeStamp;
var int SessionID;
var int SessionState;

var R_ArpgSessionEndPoint SessionEndPoint;

function InitializeSession()
{
    SessionState = SessionState_Inactive;
}

function ChangeSessionState(int NewSessionState)
{
    SessionState = NewSessionState;

    if(SessionState == SessionState_Active)
    {
        Log("Session is now active with ID" @ SessionID);
        if(SessionEndPoint.Role == Role_AutonomousProxy)
        {
            RequestSnapshot();
        }
    }
}

function RequestSnapshot()
{
    Log("Requestion snapshot");
    SessionEndPoint.ServerSessionMessage(SessionID, SessionMessage_SendSnapShot);
}

function ReceiveSessionMessage(int SessionMessage)
{
    if(SessionMessage == SessionMessage_SendSnapShot)
    {
        SendSnapShot();
    }
}

function SendSnapShot()
{
    local int Payload[32];
    local int i, j;

    for(i = 0; i < ArrayCount(Payload); ++i)
    {
        Payload[i] = Rand(10000);
    }

    Log("Sending SnapShot");
    Log("-------------------------");
    for(j = 0; j < 2; ++j)
    {
        for(i = 0; i < ArrayCount(Payload); ++i)
        {
            Log("Payload[" $ i $ "]:" @ Payload[i]);
        }

        //SessionEndPoint.ClientReceiveSnapShot(SessionID, Payload);
        SessionEndPoint.SendSnapShot(SessionID, Payload, j);
    }
    
}

function ReceiveSnapshot(int Payload[32], int Sequence)
{
    local int i;
    Log("Received snapshot Sequence" @ Sequence);
    Log("-------------------------");
    for(i = 0; i < ArrayCount(Payload); ++i)
    {
        Log("Payload[" $ i $ "]:" @ Payload[i]);
    }
}

function SetSessionID(int NewSessionID)
{
    SessionID = NewSessionID;
}

function SetTimeStamp(float NewTimeStamp)
{
    TimeStamp = NewTimeStamp;
}

function TickSession(float DeltaSeconds)
{
    local float NewTimeSeconds;
    local float RequestTimeOutSeconds;

    if(SessionState == SessionState_Requested)
    {
        RequestTimeOutSeconds = SessionEndPoint.GetRequestTimeOutSeconds();
        NewTimeSeconds = SessionEndPoint.Level.TimeSeconds;
        if(NewTimeSeconds - TimeStamp >= RequestTimeOutSeconds)
        {
            Log("Session request timed out");
            ChangeSessionState(SessionState_Inactive);
        }
    }
}