class RKSClientChannel extends Mutator;

var bool bRegisteredHUDMutator;
var RKSHUD ClientHUD;

replication
{
    reliable if(Role == ROLE_Authority && RemoteRole == ROLE_AutonomousProxy)
        ClientReceiveLocalizedMessage;
}

simulated event BeginPlay()
{
    Super.BeginPlay();
    bRegisteredHUDMutator = false;

    if(Role == ROLE_Authority)
    {
        Class'RKSStatics'.Static.RKSLog("Opened RKSClientChannel for" @ Owner);
    }
}

simulated function RegisterHUDMutator()
{
    local HUD MyHUD;

    if(bRegisteredHUDMutator)
    {
        return;
    } 

    if((Level.NetMode == NM_Client && Owner != None && Owner.Role == ROLE_AutonomousProxy)
    ||  Level.NetMode == NM_Standalone)
    {
        if(PlayerPawn(Owner) != None)
        {
            MyHUD = PlayerPawn(Owner).MyHUD;
            if(MyHUD != None)
            {
                NextHUDMutator = MyHUD.HUDMutator;
                MyHUD.HUDMutator = Self;
                bHUDMutator = true;
                bRegisteredHUDMutator = true;
                ClientHUD = Spawn(Class'RKSHUD', Owner);
            }
        }
    }
}

simulated event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);
    RegisterHUDMutator();
}

simulated event PostRender(Canvas C)
{
    Super.PostRender(C);

    if(ClientHUD != None)
    {
        ClientHUD.PostRender(C);
    }
}

simulated function ClientReceiveLocalizedMessage(
    class<LocalMessage> MessageClass,
    optional int Switch,
    optional PlayerReplicationInfo PRI1,
    optional PlayerReplicationInfo PRI2,
    optional Object OptionalObject
)
{
    if(ClientHUD != None)
    {
        ClientHUD.LocalizedMessage(MessageClass, Switch, PRI1, PRI2, OptionalObject);
    }
}

defaultproperties
{
    RemoteRole=ROLE_AutonomousProxy;
}