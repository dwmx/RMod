class R_LCI_Server extends TcpLink config;

var Class<R_AUtilities> UtilitiesClass;
var config int ListenPort;

event BeginPlay()
{
    Super.BeginPlay();
    UtilitiesClass.Static.RModLog(Self @ "spawned, listening on port" @ ListenPort);
    BindPort(ListenPort);
    Listen();
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities_LCI'
    AcceptClass=Class'RMod.R_LCI_Connection'
    ListenPort=70
}