//==============================================================================
//  R_GameInfo_TDMFreezeTag
//  Round-based TDM freeze tag game mode.
//==============================================================================
class R_GameInfo_TDMFreezeTag extends R_GameInfo_TDMRB;

var Class<R_AFreezeTagStatics> FreezeTagStaticsClass;

function ScoreKill(Pawn Killer, Pawn Other)
{
    Super.ScoreKill(Killer, Other);
    if(Killer != None && R_PlayerReplicationInfo_FreezeTag(Killer.PlayerReplicationInfo) != None)
    {
        R_PlayerReplicationInfo_FreezeTag(Killer.PlayerReplicationInfo).PlayerFreezes += 1.0;
    }
}

function NotifyFrozen(R_RunePlayer Victim, R_RunePlayer Instigator)
{
    ScoreKill(Instigator, Victim);
}

function NotifyThawed(R_RunePlayer Victim, R_RunePlayer Instigator)
{
	if(Instigator != None && R_PlayerReplicationInfo_FreezeTag(Instigator.PlayerReplicationInfo) != None)
	{
		R_PlayerReplicationInfo_FreezeTag(Instigator.PlayerReplicationInfo).PlayerThaws += 1.0;
	}
}

function byte GetCurrentDiedBehaviorAsByte(R_RunePlayer Caller)
{
    return FreezeTagStaticsClass.Static.GetDeathBehaviorAsByte_DieOnDeath();
}

/**
*   State LiveRound
*   Round is in progress
*/
state LiveRound
{
    event EndState()
    {
        Super.EndState();
        DestroyAllFrozenPlayers();
    }

    function byte GetCurrentDiedBehaviorAsByte(R_RunePlayer Caller)
    {
        return FreezeTagStaticsClass.Static.GetDeathBehaviorAsByte_FreezeOnDeath();
    }

    /**
    *   CheckIsPlayerConsideredAlive (override)
    *   Overridden to treat frozen state as dead instead of health <= 0
    */
    function bool CheckIsPlayerConsideredAlive(R_RunePlayer RRP)
    {
        if(RRP.GetStateName() == 'Frozen' || RRP.Health <= 0)
        {
            return false;
        }
        return true;
    }

    function DestroyAllFrozenPlayers()
    {
        local Pawn P;
        local R_RunePlayer_FreezeTag RRPFT;

        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            RRPFT = R_RunePlayer_FreezeTag(P);
            if(RRPFT != None && RRPFT.GetStateName() == 'Frozen')
            {
                RRPFT.NotifyEjectedFromArena();
            }
        }
    }
}

defaultproperties
{
    FreezeTagStaticsClass=Class'RMod_FreezeTag.R_AFreezeTagStatics'
    RunePlayerClass=Class'RMod_FreezeTag.R_RunePlayer_FreezeTag'
    PlayerReplicationInfoClass=Class'RMod_FreezeTag.R_PlayerReplicationInfo_FreezeTag'
    HUDType=Class'RMod_FreezeTag.R_RunePlayerHUD_TDMFreezeTag'
}