class R_GameReplicationInfo_Arena extends R_GameReplicationInfo;

var int curTimer;
var bool bDrawTimer;
var bool bInMatch;
var byte TeamColor[2];
var byte matchSize;
var int CurMatch;

replication
{
    reliable if ( Role == ROLE_Authority )
        bDrawTimer, curTimer, bInMatch, TeamColor, matchSize, CurMatch;
}

/**
*	CheckShouldPlayerRespawn (override)
*	Called from dead arena players while in PlayerSpectating state
*	This should return true when the round is over and the calling player's team has
*	not won the match
*/
simulated function bool CheckShouldPlayerRespawn(R_RunePlayer RP, Name RelevantState)
{
    if(RP != None && RelevantState == 'PlayerSpectating')
    {
        if(RP.PlayerReplicationInfo != None)
        {
            if(RP.PlayerReplicationInfo.Team == 255 && !RP.PlayerReplicationInfo.bIsSpectator)
            {
                return true;
            }
        }
    }
    return false;
}

defaultproperties
{
     TeamColor(1)=1
     SpectatorCameraClass=Class'RMod_Arena.R_Camera_ArenaSpectator'
}