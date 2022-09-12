class R_GameReplicationInfo_LastManStanding extends R_GameReplicationInfo;

var Name GameStateName;

replication
{
    reliable if(Role == ROLE_Authority)
        GameStateName;
}