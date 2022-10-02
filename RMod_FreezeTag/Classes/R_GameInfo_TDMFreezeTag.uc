//==============================================================================
//  R_GameInfo_TDMFreezeTag
//  Round-based TDM freeze tag game mode.
//==============================================================================
class R_GameInfo_TDMFreezeTag extends R_GameInfo_TDMRB;

var Class<R_AFreezeTagStatics> FreezeTagStaticsClass;

function NotifyFrozen(R_RunePlayer Victim, R_RunePlayer Instigator)
{
	if(Instigator != None && R_PlayerReplicationInfo_FreezeTag(Instigator.PlayerReplicationInfo) != None)
	{
		R_PlayerReplicationInfo_FreezeTag(Instigator.PlayerReplicationInfo).PlayerFreezes += 1.0;
	}
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

defaultproperties
{
    FreezeTagStaticsClass=Class'RMod_FreezeTag.R_AFreezeTagStatics'
    RunePlayerClass=Class'RMod_FreezeTag.R_RunePlayer_FreezeTag'
    PlayerReplicationInfoClass=Class'RMod_FreezeTag.R_PlayerReplicationInfo_FreezeTag'
}