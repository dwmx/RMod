class R_GameInfo_ArenaFreezeTag extends R_GameInfo_Arena;

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
    // Ignore unless game is in progress
    if(GameState != ASTATE_DuringMatch)
    {
        return;
    }

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

    ScoreKill(Instigator, Victim);

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

	if(Instigator != None && R_PlayerReplicationInfo_FreezeTag(Instigator.PlayerReplicationInfo) != None)
	{
		R_PlayerReplicationInfo_FreezeTag(Instigator.PlayerReplicationInfo).PlayerThaws += 1.0;
	}
}

function byte GetCurrentDiedBehaviorAsByte(R_RunePlayer Caller)
{
    if(IsPlaying(Caller, LTYPE_Champion) || IsPlaying(Caller, LTYPE_Challenger))
    {
        return FreezeTagStaticsClass.Static.GetDeathBehaviorAsByte_FreezeOnDeath();
    }

    return FreezeTagStaticsClass.Static.GetDeathBehaviorAsByte_DieOnDeath();
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

//==============================================================
//
// CheckWinState
// Overridden to check the arena state with each call, instead
// of relying on the challengers left and champions left vars.
//
//==============================================================
function bool CheckWinState(byte aType)
{
	local int TotalChallengersCount;
	local int TotalChampionsCount;
	local Pawn P;
	local R_RunePlayer_FreezeTag RP;

	TotalChallengersCount = 0;
	TotalChampionsCount = 0;

	foreach AllActors(Class'Engine.Pawn', P)
	{
		RP = R_RunePlayer_FreezeTag(P);
		if(P.Health > 1 || (RP != None && !RP.bInFrozenState))
		{
			if(IsPlaying(P, LTYPE_Challenger))
			{
				++TotalChallengersCount;
			}
			else if(IsPlaying(P, LTYPE_Champion))
			{
				++TotalChampionsCount;
			}
		}
	}
	
	if(aType == LTYPE_Challenger && TotalChampionsCount == 0)
	{
		return true;
	}
	else if(aType == LTYPE_Champion && TotalChallengersCount == 0)
	{
		return true;
	}

	return false;
}

defaultproperties
{
    FreezeTagStaticsClass=Class'RMod_FreezeTag.R_AFreezeTagStatics'
    RunePlayerClass=Class'RMod_FreezeTag.R_RunePlayer_FreezeTag'
	PlayerReplicationInfoClass=Class'RMod_FreezeTag.R_PlayerReplicationInfo_FreezeTag'
    GameReplicationInfoClass=Class'Arena.ArenaGameReplicationInfo'
    HUDType=Class'RMod_Arena.R_RunePlayerHUD_Arena'
	ScoreBoardType=Class'RMod_FreezeTag.R_Scoreboard_ArenaFreezeTag'
}