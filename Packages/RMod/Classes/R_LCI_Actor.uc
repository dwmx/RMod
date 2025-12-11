class R_LCI_Actor extends Actor;

var Class<R_AUtilities> UtilitiesClass;
var R_LCI_Server Server;
var Class<R_LCI_Server> ServerClass;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    UtilitiesClass.Static.RModLog(Self @ "created");

    // Spawn Server
    if(ServerClass != None)
    {
        if(Server != None)
        {
            Server.Destroy();
        }
        Server = Spawn(ServerClass, Self);
    }
}

event Destroyed()
{
    Super.Destroyed();
    if(Server != None)
    {
        Server.Destroy();
    }
}

function HandleMessage(String Message)
{
    BroadcastMessage(Message, true, 'LCI');
}

defaultproperties
{
    RemoteRole=ROLE_None
    DrawType=DT_None
    UtilitiesClass=Class'RMod.R_AUtilities_LCI'
    ServerClass=Class'RMod.R_LCI_Server'
}