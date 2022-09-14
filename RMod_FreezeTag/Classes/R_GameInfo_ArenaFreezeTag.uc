class R_GameInfo_ArenaFreezeTag extends R_GameInfo_Arena;

function NotifyFrozen(R_RunePlayer Victim, R_RunePlayer Instigator)
{
    // This is a copy from HandleKill in Arena game info
	if(Victim != None)
	{
		if(IsPlaying(Victim, LTYPE_Champion))
		{
			ChampionsLeft--;
		}
		else if(IsPlaying(Victim, LTYPE_Challenger))
		{
			ChallengersLeft--;
		}
	}

	if(Instigator != None && R_PlayerReplicationInfo_ArenaFreezeTag(Instigator.PlayerReplicationInfo) != None)
	{
		R_PlayerReplicationInfo_ArenaFreezeTag(Instigator.PlayerReplicationInfo).PlayerFreezes += 1.0;
	}

    if(ClearList(DetermineLoser()))
    {
        bStartedTimer = false;
        GameState = ASTATE_PostMatch;
    }
}

function NotifyThawed(R_RunePlayer Victim, R_RunePlayer Instigator)
{
	if(Victim != None)
	{
		if(IsPlaying(Victim, LTYPE_Champion))
		{
			ChampionsLeft++;
		}
		else if(IsPlaying(Victim, LTYPE_Challenger))
		{
			ChallengersLeft++;
		}
	}

	if(Instigator != None && R_PlayerReplicationInfo_ArenaFreezeTag(Instigator.PlayerReplicationInfo) != None)
	{
		R_PlayerReplicationInfo_ArenaFreezeTag(Instigator.PlayerReplicationInfo).PlayerThaws += 1.0;
	}
}

//==============================================================
//
//  ClearList
//  Overridden from Blitznuckle's ArenaGameInfo in order to send
//  a notify call to players when they are ejected from the
//  arena.
//==============================================================
function bool ClearList(byte lType)
{
	local int i;
	local PlayerPawn aPlayer;

	if(lType == LTYPE_Champion)
	{
		AnnounceResults(LTYPE_Challenger);
		
		for(i = 0; i < MaxArenaPlayers; i++)
		{
			aPlayer = PlayerPawn(ChampionList[i].Fighter);
			if(aPlayer != None)
			{
				aPlayer.PlayerReplicationInfo.Deaths += 1;
				aPlayer.PlayerReplicationInfo.Team = 255;
			}

            if(R_RunePlayer_FreezeTag(aPlayer) != None)
            {
                R_RunePlayer_FreezeTag(aPlayer).NotifyEjectedFromArena();
            }

			ClearFighterList(ChampionList[i]);

			aPlayer = PlayerPawn(ChallengerList[i].Fighter);
			if(aPlayer != None)
				aPlayer.PlayerReplicationInfo.Score += 1;
		}

		return true;
	}
	else if(lType == LTYPE_Challenger)
	{
		AnnounceResults(LTYPE_Champion);
	
		for(i = 0; i < MaxArenaPlayers; i++)
		{	
			aPlayer = PlayerPawn(ChallengerList[i].Fighter);
			if(aPlayer != None)
			{
				aPlayer.PlayerReplicationInfo.Deaths += 1;
				aPlayer.PlayerReplicationInfo.Team = 255;
			}

            if(R_RunePlayer_FreezeTag(aPlayer) != None)
            {
                R_RunePlayer_FreezeTag(aPlayer).NotifyEjectedFromArena();
            }

			ClearFighterList(ChallengerList[i]);

			aPlayer = PlayerPawn(ChampionList[i].Fighter);
			if(aPlayer != None)
				aPlayer.PlayerReplicationInfo.Score += 1;
		}

		return true;
	}

	return false;
}

defaultproperties
{
    RunePlayerClass=Class'RMod_FreezeTag.R_RunePlayer_FreezeTag'
	PlayerReplicationInfoClass=Class'RMod_FreezeTag.R_PlayerReplicationInfo_ArenaFreezeTag'
    GameReplicationInfoClass=Class'Arena.ArenaGameReplicationInfo'
    HUDType=Class'RMod_Arena.R_RunePlayerHUD_Arena'
	ScoreBoardType=Class'RMod_FreezeTag.R_Scoreboard_ArenaFreezeTag'
}