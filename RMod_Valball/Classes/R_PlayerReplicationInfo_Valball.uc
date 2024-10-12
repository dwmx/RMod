class R_PlayerReplicationInfo_Valball extends R_PlayerReplicationInfo;

var float HoldTimeSeconds; // How long this player has held the ball

replication
{
    unreliable if(Role == ROLE_Authority)
        HoldTimeSeconds;
}

defaultproperties
{
    HoldTimeSeconds=0.0
}