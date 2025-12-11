class R_LCI_Connection extends TcpLink;

var Class<R_AUtilities> UtilitiesClass;
var R_LCI_Server LCI_Server;
var R_LCI_Actor LCI_Actor;

event BeginPlay()
{
    if(Owner != None && R_LCI_Server(Owner) != None)
    {
        LCI_Server = R_LCI_Server(Owner);
        if(LCI_Server.Owner != None && R_LCI_Actor(LCI_Server.Owner) != None)
        {
            LCI_Actor = R_LCI_Actor(LCI_Server.Owner);
        }
    }
}

event ReceivedText(String Text)
{
    UtilitiesClass.Static.RModLog(Self @ "received text:" @ Text);
    if(LCI_Actor != None)
    {
        LCI_Actor.HandleMessage(Text);
    }
}

event Opened()
{
    UtilitiesClass.Static.RModLog(Self @ "opened connection");
}

event Closed()
{
    UtilitiesClass.Static.RModLog(Self @ "closed connection");
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities_LCI'
}