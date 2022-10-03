class R_PlayerReplicationInfo_FreezeTag extends R_PlayerReplicationInfo;

var float PlayerThaws;
var float PlayerFreezes;
var FStatTracker PlayerThawsTracker;
var FStatTracker PlayerFreezesTracker;

replication
{
    reliable if(Role == ROLE_Authority)
        PlayerThaws,
        PlayerFreezes;
}

simulated event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);

    if(Level.NetMode == NM_StandAlone || Role < ROLE_Authority)
    {
        UpdateStatTracker(PlayerThawsTracker, int(PlayerThaws));
        UpdateStatTracker(PlayerFreezesTracker, int(PlayerFreezes));
    }
}

function ResetPlayerReplicationInfo()
{
    Super.ResetPlayerReplicationInfo();

    PlayerThaws = Default.PlayerThaws;
    PlayerFreezes = Default.PlayerFreezes;
}

defaultproperties
{
    PlayerThaws=0.0
    PlayerFreezes=0.0
}