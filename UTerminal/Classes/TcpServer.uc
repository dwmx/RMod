//=============================================================================
// UTerminal.TcpServer
// Provides access to all terminal functionality via TCP connection
//=============================================================================
class TcpServer extends IpDrv.TcpLink;

var config int ListenPort;

// Users
struct FUser
{
    var config String UserName;
    var config String Password;
};
const MAX_USERS = 16;
var config FUser Users[16];

event BeginPlay()
{
    Log(Self @ "UTerminal.TcpServer spawned, listening on port" @ ListenPort);
    BindPort(ListenPort);
    Listen();
}

function bool CheckValidUsername(String UserName)
{
    local int i;

    for(i = 0; i < MAX_USERS; ++i)
    {
        if(Users[i].UserName == "")
        {
            continue;
        }
        if(Users[i].UserName == UserName)
        {
            return true;
        }
    }

    return false;
}

function bool ValidateCredentials(String Username, String Password)
{
    local int i;

    for(i = 0; i < MAX_USERS; ++i)
    {
        if(Users[i].UserName == "")
        {
            continue;
        }
        if(Users[i].UserName == UserName)
        {
            return Users[i].Password == Password;
        }
    }
    
    return false;
}

defaultproperties
{
    AcceptClass=class'UTerminal.TcpConnection'
    ListenPort=70
}