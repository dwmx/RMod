class R_GameReplicationInfo_ArenaFreezeTag extends R_GameReplicationInfo;

var Name GameStateName;

replication
{
    reliable if(Role == ROLE_Authority)
        GameStateName;
}