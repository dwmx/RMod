//==============================================================================
//  R_RunePlayer_Arena
//  Main RunePlayer class for R_GameInfo_Arena game mode
//==============================================================================
class R_RunePlayer_Arena extends R_RunePlayer;

state PlayerSpectating
{
    function bool CheckShouldRespawn()
    {
        if(PlayerReplicationInfo != None)
        {
            if(PlayerReplicationInfo.Team == 255 && !PlayerReplicationInfo.bIsSpectator)
            {
                return true;
            }
        }
        return false;
    }

    /**
    *   Fire (override)
    *   Overridden to respawn dead player spectators in the arena zone after the match finishes
    */
    exec function Fire(optional float F)
    {
        if(CheckShouldRespawn())
        {
            ServerReStartPlayer();
        }
        else
        {
            Super.Fire(F);
        }
    }
}

defaultproperties
{
	SpectatorCameraClass=Class'RMod_Arena.R_Camera_ArenaSpectator'
}