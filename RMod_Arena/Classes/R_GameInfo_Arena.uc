//=============================================================================
// ArenaGameInfo.
// Changes for 1.08 are all made by Lar
//=============================================================================
// changes by blitznuckel - http://blitznuckel.twoday.net
// (A) logout bug fix
// (B) blood lust fix
// (C) auto-team-size addition
// (D) upgrade to 8 on 8 fights
// (E) increase queue length to 32
//=============================================================================
class R_GameInfo_Arena extends RMod.R_GameInfo config(RMod);

var() config int TimeBetweenMatch;
var() config int MaxTeamSupport;

// <-- blitznuckel (C) auto team size config variables
var() config bool bAutoArenaTeamSizeEnabled; // weather if the the mutator is enabled at startup or not
var() config int secondsBeforeTeamSizeChange; // time to pass before the teamsize will be decreased
var int maxMapSupport; // the maximal teamsize supported by the current map.

var localized string teamSizeIncreaseA;
var localized string teamSizeIncreaseB;
var localized string teamSizeDecreaseA;
var localized string teamSizeDecreaseB;
// -->

const LTYPE_Champion	=	0;
const LTYPE_Challenger	=	1;

struct PlayerInventory
{
	var class<Inventory> StowedWeapons[14];
	var class<Inventory> HeldWeapon;
	var class<Inventory> HeldShield;
};

var enum ArenaState
{
	ASTATE_WaitingPlayers,
	ASTATE_DuringMatch,
	ASTATE_PreMatch,
	ASTATE_PostMatch
} GameState;
	
var struct ArenaPlayerInfo
{
	var PlayerPawn aPlayer;
	var bool bUsed;
} ArenaQueue[32]; // blitznuckel (E)

var byte ListColor[2];

var struct FighterList
{
	var Pawn Fighter;
	var bool bNewFighter;
	var PlayerInventory FighterInventory;
	
} ChampionList[8], ChallengerList[8]; // blitznuckel (D)

var bool bStartedTimer;
var int curTimer;
var int maxArenaTeam;
var int MaxArenaPlayers;		//Max Per Team

var int ChallengersLeft;
var int ChampionsLeft;

//var NavigationPoint lastStartSpot[2];
var byte TeamCurrentColor[2];
var byte CurrentCountdownIndex;
var Sound CountdownSound[3];
var Sound ArenaLeadInSound[4];
var Sound MatchStartSound[4];
var Sound MatchEndSound[4];
var PlayerPawn LastRestarted;
var int CurrentMatch;
var localized string GetReadyMessage;
var localized string FightMessage;
var localized string SuicideDeathMessage;
var localized string CrushDeathMessage;
var localized string FellDeathMessage;
var localized string DrownDeathMessage;
var localized string ThrownDeathMessage;
var localized string KillDeathMessage;
var localized string BurnedDeathMessage;
var localized string HeadDeathMessage;
var localized string GenericDeathMessage;

//==============================================================
//
// PostBeginPlay
//
//==============================================================
function PostBeginPlay()
{
	local int i;
	local NavigationPoint N;
	local ArenaStart aStart;
	local int numChampSpots;
	local int numNormSpots;
	local int curSupport;
	local Inventory Inv;
	
	Super.PostBeginPlay();

	numChampSpots = 0;
	numNormSpots = 0;
	for(N = Level.NavigationPointList; N != None; N = N.nextNavigationPoint)
	{
		if(N.IsA('ArenaStart'))
		{
			aStart = ArenaStart(N);
			if(aStart != None)
			{
				if(aStart.bChampion || aStart.bChampionTeam)
					numChampSpots++;
				else
					numNormSpots++;
			}
		}
	}

// --> Thanks for Lar
      //if (ArenaGameInfo(Level.Game).MaxTeamSupport > 1)
      //    Level.Game.bTeamGame = true;     //make this a bonified TeamGame if playing as teams.
      //else                                 //code in the Weapon class prevents teammates from hurting each others shields
      //    Level.Game.bTeamGame = false;    //for it to work, bTeamGame MUST me declared true

      foreach AllActors(class'Inventory', Inv)
      {
         if((Inv.IsA('Weapon') || Inv.IsA('Shield')) && !Inv.Region.Zone.IsA('ArenaZone') && !Inv.Region.Zone.IsA('QueueZone') && !Inv.Region.Zone.IsA('SafeZone'))
             Inv.default.RespawnTime = 0.5;
             Inv.RespawnTime = Inv.default.RespawnTime;  //correct respawn time of weapons and shields on some maps
      }
// <--

	//Compute which is smaller, the number the Level Supports, or what the Server wants
	curSupport = Min(numChampSpots, numNormSpots);
	maxArenaTeam = Min(curSupport, MaxTeamSupport);
	// <-- blitznuckel (C)
	maxMapSupport = Min(curSupport, MaxArenaPlayers);
	// -->
	
	GameState = ASTATE_WaitingPlayers;
	// <-- blitznuckel (C)
	curTimer=0;
	// -->
	CurrentMatch = 0; // Lar
	if(ArenaGameReplicationInfo(GameReplicationInfo) != None)
	{
		ArenaGameReplicationInfo(GameReplicationInfo).CurMatch = CurrentMatch;
		ArenaGameReplicationInfo(GameReplicationInfo).matchSize = maxArenaTeam;
	}

	ChampionsLeft = maxArenaTeam;
	ChallengersLeft = maxArenaTeam;
}

//==============================================================
//
// SetAutoArenaTeamSizeEnabled
//
//==============================================================
function SetAutoArenaTeamSizeEnabled(bool bEnabled)
{
	if(bAutoArenaTeamSizeEnabled == bEnabled)
	{
		return;
	}
	bAutoArenaTeamSizeEnabled = bEnabled;
	if(bAutoArenaTeamSizeEnabled)
	{
		BroadcastMessage("Auto team size enabled");
	}
	else
	{
		BroadcastMessage("Auto team size disabled");
	}
}

//==============================================================
//
// Tick
//
//==============================================================
event Tick(float DeltaSeconds)
{
	DisableQueueZoneEvents();
}

//==============================================================
//
// DisableQueueZoneEvents
//
// Called at PostBeginPlay to prevent QueueZones from sending
// calls back to ArenaGameInfo, which no longer exists.
// ZoneEventFollower now sends these messages.
//==============================================================
function DisableQueueZoneEvents()
{
	local QueueZone QZ;

	foreach AllActors(class'Arena.QueueZone', QZ)
	{
		QZ.Disable('ActorEntered');
		QZ.Disable('ActorLeaving');
	}
}

//==============================================================
//
// CanStartMatch
//
//==============================================================
function bool CanStartMatch()
{
	local int missing;

	if(bGameEnded)
		return false;

	if(!(GameState == ASTATE_PreMatch || GameState == ASTATE_WaitingPlayers))
		return false;

	missing = maxArenaTeam - GetListSize(LTYPE_Champion);
	missing += maxArenaTeam - GetListSize(LTYPE_Challenger);
	
	if(missing > GetQueueSize())
		return false;
	
	return true;
}

//==============================================================
//
// SetupMatch
//
//==============================================================
function bool SetupMatch()
{
	if(GameState != ASTATE_PreMatch)
		return false;
	
	if(!IsFull(LTYPE_Champion))
		GetNewChampions();

	else if(!IsFull(LTYPE_Challenger))
		GetNextChallengers(0);

	return true;
}

//==============================================================
//
// ReduceDamage.
//
//NOTE: Should I change this to work with FriendlyFireScale??
//==============================================================
function ReduceDamage( out int BluntDamage, out int SeverDamage, name DamageType, pawn injured, pawn instigatedBy )
{
	local PlayerPawn aInstigator, aInjured;

	Super.ReduceDamage(BluntDamage, SeverDamage, DamageType, injured, instigatedBy);

	aInstigator = PlayerPawn(instigatedBy);
	aInjured = PlayerPawn(injured);
	if(aInjured == None || aInstigator == None)
		return;

	if(aInstigator.PlayerReplicationInfo.Team == aInjured.PlayerReplicationInfo.Team)
	{
		BluntDamage = 0;
		SeverDamage = 0;
	}
}

//==============================================================
//
// ResetMatchVariables
//
//==============================================================
function ResetMatchVariables()
{
	ChallengersLeft = maxArenaTeam;
	ChampionsLeft = maxArenaTeam;
}

//==============================================================
//
// PlayCountdown
//
//==============================================================
function PlayCountdown(int currentIndex)
{
	local Pawn P;
	local PlayerPawn Player;

	for(P=Level.PawnList; P != None; P = P.NextPawn)
	{
		if(IsPlaying(P, 255))
		{
			Player = PlayerPawn(P);
			if(Player != None)
				Player.ClientPlaySound(CountdownSound[currentIndex]);
		}
	}
}

//==============================================================
//
// PlayBeginMatch
//
//==============================================================
function PlayBeginMatch()
{
	local Pawn P;
	local PlayerPawn Player;
	local int randSound;

	randSound = Rand(4);

	for(P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if(IsPlaying(P, 255))
		{
			Player = PlayerPawn(P);
			if(Player != None)
				Player.ClientPlaySound(MatchStartSound[randSound]);
		}
	}
}

//==============================================================
//
// PlayEndMatch
//
//==============================================================
function PlayEndMatch()
{
	local Pawn P;
	local PlayerPawn Player;
	local int randSound;

	randSound = Rand(4);

	for(P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if(IsPlaying(P, 255))
		{
			Player = PlayerPawn(P);
			if(Player != None)
				Player.ClientPlaySound(MatchEndSound[randSound]);
		}
	}
}

//==============================================================
//
// ResetDeadPlayers.
//
//==============================================================
function ResetDeadPlayers()
{
	local Pawn aPawn;
	local RunePlayer rPlayer;

	for(aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
	{
		rPlayer = RunePlayer(aPawn);
		if(rPlayer != None && !rPlayer.bCanRestart)
		{
			rPlayer.bCanRestart = true;
			if(rPlayer.PlayerReplicationInfo.Team == LTYPE_Champion)
				RestartFighter(aPawn);
		}
	}
}

//==============================================================
//
// SendFightMessage()
//
//==============================================================
function SendFightMessage()
{
	local int i;

	for(i = 0; i < maxArenaTeam; i++)
	{
		if(ChampionList[i].Fighter != None)
			ChampionList[i].Fighter.ClientMessage(FightMessage);

		if(ChallengerList[i].Fighter != None)
			ChallengerList[i].Fighter.ClientMessage(FightMessage);
	}
}

//==============================================================
//
// SetTeamSize
//
//==============================================================
function SetTeamSize(int TeamSize)
{
	Log(Self @ "SetTeamSize:" @ TeamSize);

	if(TeamSize == maxArenaTeam)
	{
		return;
	}

	if(GameState == ASTATE_WaitingPlayers)
	{
		if(TeamSize < maxArenaTeam)
		{
			decreaseTeamSize(TeamSize);
		}
		else if(TeamSize > maxArenaTeam)
		{
			increaseTeamSize(TeamSize);
		}
	}
}

//==============================================================
//
// Timer
//
//==============================================================
function Timer()
{
	local ArenaGameReplicationInfo ArenaRepInfo;
	local ZoneInfo A;
	local Pawn aPawn;
	
	// <-- blitznuckel (C)
	local int newTeamSize;
	// -->
	
	Super.Timer();
	ArenaRepInfo = ArenaGameReplicationInfo(GameReplicationInfo);
	
	switch(GameState)
	{
		case ASTATE_WaitingPlayers:
			// <-- blitznuckel (C) decrease team size
			if( secondsBeforeTeamSizeChange <= curTimer && bAutoArenaTeamSizeEnabled ){
				newTeamSize = calcNewTeamSize(countReadyPlayers());
				if( newTeamSize < maxArenaTeam ){
					decreaseTeamSize(newTeamSize);
					if(newTeamSize==1) fixChangeTo1on1();
					curTimer=0; // wait before decreasing team size once more
					InterruptMatchStart();
				}
			}
			curTimer++;
			// -->
			return;
		break;

		case ASTATE_DuringMatch:
			if(!bStartedTimer)
			{
				ArenaRepInfo.bInMatch = true;
				curTimer = 0;
				bStartedTimer = true;

				StateChangeFighters(true);
				SendFightMessage();
				PlayBeginMatch();
			}
		break;

		case ASTATE_PreMatch:

			if(!bStartedTimer)
			{
				ArenaRepInfo.curTimer = TimeBetweenMatch;
				curTimer = TimeBetweenMatch;
				ArenaRepInfo.bDrawTimer = true;
				bStartedTimer = true;

				SetupMatch();
				SendGetReadyMsg();
				CurrentCountdownIndex = Rand(3);
				if(curTimer == 5)
					PlayCountdown(CurrentCountdownIndex);	
			}
			else if(curTimer == 3)
			{
				StateChangeFighters(false);
				curTimer--;
				ArenaRepInfo.curTimer = curTimer;
				PlayCountdown(CurrentCountdownindex);
			}
			
			// <-- blitznuckel (C) increase team size
			else if ( curTimer==1 && bAutoArenaTeamSizeEnabled ) {
				newTeamSize = calcNewTeamSize(countReadyPlayers());
				if( newTeamSize > maxArenaTeam ){
					increaseTeamSize(newTeamSize);
					StateChangeFighters(true); // unfreeze fighters
					curTimer=TimeBetweenMatch; // reset countdown
				}else{
					curTimer--;
				}
			}
			// -->

			else if(curTimer == 0)
			{
				foreach AllActors(class 'ZoneInfo', A)
				{
					if(A.IsA('ArenaZone'))
						ArenaZone(A).BeginArenaMatch();
				}

				StartMatch();
				bStartedTimer = false;
				ArenaRepInfo.bDrawTimer = false;
			}
			else
			{
				curTimer--;
				ArenaRepInfo.curTimer = curTimer;
				if(curTimer > 0 && curTimer < 6)
					PlayCountdown(CurrentCountdownIndex);
			}
		break;

		case ASTATE_PostMatch:

			if(!bStartedTimer)
			{
				PlayEndMatch();
				ArenaRepInfo.bInMatch = false;
				
				if(DetermineWinner() == LTYPE_Challenger)
					MoveChallengers();

				ResetDeadPlayers();

				foreach AllActors(class 'ZoneInfo', A)
				{
					if(A.IsA('ArenaZone'))
						ArenaZone(A).EndArenaMatch();
				}

				ResetMatchVariables();
				curTimer = 5;
				bStartedTimer = true;
			}
			else if(curTimer <= 0)
			{
				GameState = ASTATE_WaitingPlayers;
				// <-- blitznuckel (C)
				curTimer=0;
				// -->
				InterruptMatchStart();
			}
			else
				curTimer--;
		break;

		default:

		break;
	}
}

//==============================================================
//
// FindOneOnOneStart
//
//==============================================================
function ArenaStart FindOneOnOneStart(Pawn Player, byte lType)
{
	local NavigationPoint N;
	local ArenaStart aStart;

	N = Level.NavigationPointList;

	while(N != None)
	{
		if(N.IsA('ArenaStart'))
		{
			aStart = ArenaStart(N);
			if(aStart != None && ((lType == LTYPE_Champion && aStart.bChampion)
				|| (lType == LTYPE_Challenger && aStart.bChallenger)))
			{
				return aStart;
			}
		}

		N = N.nextNavigationPoint;
	}

	return None;
}


//==============================================================
//
// FindArenaStart
//
//==============================================================
function ArenaStart FindArenaStart(Pawn Player, byte lType)
{
	local ArenaStart Dest, Candidate[8], Best; // blitznuckel (D)
	local float Score[8], BestScore, NextDist; // blitznuckel (D)
	local pawn OtherPlayer;
	local int i, num;
	local NavigationPoint N;
	local ArenaStart aStart;

	if(maxArenaTeam == 1)
		return FindOneOnOneStart(Player, lType);

	num = 0;
	//choose candidates

	if(lType != LTYPE_Champion && lType != LTYPE_Challenger)
		return None;

	N = Level.NavigationPointList;
	while (N != None)
	{
		if (N.IsA('ArenaStart'))
		{
			aStart = ArenaStart(N);
			if(aStart != None && ((lType == LTYPE_Champion && aStart.bChampionTeam) 
				|| (lType == LTYPE_Challenger && !aStart.bChampionTeam)))
			{
				if(num < 8) // blitznuckel (D)
					Candidate[num] = aStart;
				num++;
			}
		}
		N = N.nextNavigationPoint;
	}

	if (num>8) // blitznuckel (D) 
		num = 8; // blitznuckel (D)
	else if (num == 0)
		return None;

	//Don't randomize - cause problems
	//for (i=0;i<num;i++)
	//	Score[i] = 4000 * FRand(); //randomize

	for (OtherPlayer = Level.PawnList; OtherPlayer != None; OtherPlayer = OtherPlayer.NextPawn)
	{
		if (OtherPlayer.bIsPlayer && OtherPlayer.Health > 0 && OtherPlayer.PlayerReplicationInfo.Team == lType
			&& OtherPlayer != Player)
		{
			for (i=0; i<num; i++)
			{
				NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);

				if (NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight)
				{
					Score[i] -= 1000000.0;
				}
			}
		}
	}

	BestScore = Score[0];
	Best = Candidate[0];

	for (i=1;i<num;i++)
	{
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}
	}
	
	return Best;	
}

//==============================================================
//
// GetListColor
//
//==============================================================
function byte GetListColor(byte aType)
{
	return TeamCurrentColor[aType];

}

//==============================================================
//
// PlaceFighterInArena
//
//==============================================================
function PlaceFighterInArena(Pawn aFighter, byte aType)
{
	local ArenaStart aStart;

	if(maxArenaTeam != 1)
		aFighter.DesiredColorAdjust = GetTeamVectorColor(GetListColor(aType));
	
	aStart = FindArenaStart(aFighter, aType);
	if(aStart != None)
		SetArenaTeleportSpot(aStart, aFighter);
}

//==============================================================
//
// GetTeamVectorColor
//
//==============================================================
function vector GetTeamVectorColor(int num)
{
	local float brightness;
	brightness = 102;
	switch(num)
	{
		case 0:
			return vect(1,0,0)*brightness;
		case 1:
			return vect(0,0,1)*brightness;
	}
	return vect(0,0,0);
}

//==============================================================
//
// StartMatch
//
//==============================================================
function StartMatch()
{
	local int i;

	CurrentMatch++;
	ArenaGameReplicationInfo(GameReplicationInfo).CurMatch = CurrentMatch;

 	GameState = ASTATE_DuringMatch;
	bStartedTimer = false;

	DestroyArenaWeapons();

	for(i = 0; i < maxArenaTeam; i++)
	{
		if(ChampionList[i].bNewFighter && ChampionList[i].Fighter != None)
		{
			SavePawnsWeapons(ChampionList[i].Fighter, ChampionList[i].FighterInventory);
			ChampionList[i].bNewFighter = false;
		}

		if(ChallengerList[i].bNewFighter && ChallengerList[i].Fighter != None)
		{
			SavePawnsWeapons(ChallengerList[i].Fighter, ChallengerList[i].FighterInventory);
			ChallengerList[i].bNewFighter = false;
		}

		DestroyPawnsWeapons(ChampionList[i].Fighter);
		DestroyPawnsWeapons(ChallengerList[i].Fighter);
	}

	for(i = 0; i < maxArenaTeam; i++)
	{
		if(ChampionList[i].Fighter != None)
		{
			RestorePawnHealth(ChampionList[i].Fighter);
			PlaceFighterInArena(ChampionList[i].Fighter, LTYPE_Champion);
			EquipPawn(ChampionList[i].Fighter, ChampionList[i].FighterInventory);
			// <-- blitznuckel (C)
			if( ChampionList[i].Fighter.PlayerReplicationInfo != None ){
				ChampionList[i].Fighter.PlayerReplicationInfo.Team = LTYPE_Champion;
				//ChampionList[i].Fighter.PlayerReplicationInfo.TeamID = 255;
			}
			// -->
		}
	}

	for(i = 0; i < maxArenaTeam; i++)
	{
		if(ChallengerList[i].Fighter != None)
		{
			RestorePawnHealth(ChallengerList[i].Fighter);
			PlaceFighterInArena(ChallengerList[i].Fighter, LTYPE_Challenger);
			EquipPawn(ChallengerList[i].Fighter, ChallengerList[i].FighterInventory);
			// <-- blitznuckel (C)
			if( ChallengerList[i].Fighter.PlayerReplicationInfo != None ){
				ChallengerList[i].Fighter.PlayerReplicationInfo.Team = LTYPE_Challenger;
				//ChallengerList[i].Fighter.PlayerReplicationInfo.TeamID = 255;
			}
			// -->
		}
	}
}

//==============================================================
//
// Logout
//
//==============================================================
function Logout( pawn Exiting )
{
	local int i;
	local byte lType;
	local byte TeamType;
	
	TeamType = Exiting.PlayerReplicationInfo.Team;

	switch(TeamType)
	{
	case LTYPE_Champion:
		lType = LTYPE_Challenger;
		RemoveFighter(LTYPE_Champion, Exiting);

		if(GameState == ASTATE_DuringMatch 
				// <-- blitznuckel (A)
					&& !Exiting.IsInState('Dying') )
				// -->
			ChampionsLeft--;
		else
			RemoveFromQueue(Exiting);
			//ChampionsQuit++;
	break;

	case LTYPE_Challenger:
		lType = LTYPE_Champion;
		RemoveFighter(LTYPE_Challenger, Exiting);
		
		if(GameState == ASTATE_DuringMatch
				// <-- blitznuckel (A)
					&& !Exiting.IsInState('Dying') )
				// -->
			ChallengersLeft--;
		else
			RemoveFromQueue(Exiting);
			//ChallengersQuit++;
	break;

	default:
		RemoveFromQueue(Exiting);
		if(GameState == ASTATE_PreMatch && Exiting.PlayerReplicationInfo.TeamID <= maxArenaTeam)
		{
			RemoveFromQueue(Exiting);
			ResetStateChange();
			InterruptMatchStart();
		}
		else
			RemoveFromQueue(Exiting);

		Super.Logout(Exiting);
		return;
	break;
	}

	if(GameState == ASTATE_DuringMatch
		// <-- blitznuckel (A)
			&& ( ChampionsLeft <= 0 || ChallengersLeft <= 0 )
		// -->
	)
	{
		if(ClearList(DetermineLoser()))
		{
			GameState = ASTATE_PostMatch;
			bStartedTimer = false;
		}
	}
	else if(GameState == ASTATE_PreMatch)
	{
		ResetStateChange();
		InterruptMatchStart();
	}

	Super.Logout(Exiting);
}

//==============================================================
//
// HandleKill
//
//==============================================================
function bool HandleKill(Pawn Died, Pawn Killer, name DamageType)
{
	local byte lType;

	if(GameState == ASTATE_PreMatch)
	{
		ResetStateChange();
		if(IsPlaying(Died, LTYPE_Champion))
			RemoveFighter(LTYPE_Champion, Died);
		
		else if(IsPlaying(Died, LTYPE_Challenger))
			RemoveFighter(LTYPE_Challenger, Died);
		
		InterruptMatchStart();
		return false;
	}

	else if(GameState != ASTATE_DuringMatch)
	{
		if(IsPlaying(Died, LTYPE_Champion))
		{
			RemoveFighter(LTYPE_Champion, Died);
			InterruptMatchStart();
		}
	
		return false;
	}
	
	if(IsPlaying(Died, LTYPE_Champion)) 
	{
		if(maxArenaTeam > 1)
			RunePlayer(Died).bCanRestart = false;	//DISALLOW RESTARTING UNTIL MATCH DONE

		//ChampionsDied++;
		ChampionsLeft--;
	}

	else if(IsPlaying(Died, LTYPE_Challenger))
	{
		if(maxArenaTeam > 1)
			RunePlayer(Died).bCanRestart = false;	//DISALLOW RESTARTING UNTIL MATCH DONE

		//ChallengersDied++;
		ChallengersLeft--;
	}

	if(ClearList(DetermineLoser()))
	{
		bStartedTimer = false;
		GameState = ASTATE_PostMatch;
	}
	
	return true;
}

//==============================================================
//
// AnnounceResults
//
//==============================================================
function AnnounceResults(byte lType)
{
	local Pawn aPawn;
	local PlayerPawn aPlayer, aLoser, aWinner;
	
	if(maxArenaTeam == 1)
	{
		if(lType == LTYPE_Champion)
		{
			aWinner = PlayerPawn(ChampionList[0].Fighter);
			if(aWinner == None)
				return;

			aLoser = PlayerPawn(ChallengerList[0].Fighter);
			if(aLoser == None)
				return;

			BroadcastLocalizedMessage(class'MatchResultMessage', 1, aWinner.PlayerReplicationInfo, aLoser.PlayerReplicationInfo);
	
		}
		else if(lType == LTYPE_Challenger)
		{
			aWinner = PlayerPawn(ChallengerList[0].Fighter);
			if(aWinner == None)
				return;

			aLoser = PlayerPawn(ChampionList[0].Fighter);
			if(aLoser == None)
				return;

			BroadcastLocalizedMessage(class'MatchResultMessage', 2, aWinner.PlayerReplicationInfo, aLoser.PlayerReplicationInfo);
	
		}
		
	}
	else
	{
		if(lType == LTYPE_Champion)
			BroadcastLocalizedMessage(class'MatchResultMessage', 3);

		else if(lType == LTYPE_Challenger)
			BroadcastLocalizedMessage(class'MatchResultMessage', 4);
	}

}

//==============================================================
//
// MoveChallengers
//
//==============================================================
function MoveChallengers()
{
	local int i, temp;
	local PlayerPawn aPlayer;
	local ArenaGameReplicationInfo ArenaGRI;

	if(!IsEmpty(LTYPE_Challenger))
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChallengerList[i].Fighter != None)
			{
				aPlayer = PlayerPawn(ChallengerList[i].Fighter);
				if(aPlayer != None)
					aPlayer.PlayerReplicationInfo.Team = LTYPE_Champion;

				CopyFighterList(ChampionList[i], ChallengerList[i]);
				ClearFighterList(ChallengerList[i]);
			}
		}

		if(maxArenaTeam != 1)
		{
			ArenaGRI = ArenaGameReplicationInfo(GameReplicationInfo);
			temp = TeamCurrentColor[LTYPE_Champion];
			TeamCurrentColor[LTYPE_Champion] = TeamCurrentColor[LTYPE_Challenger];
			TeamCurrentColor[LTYPE_Challenger] = temp;
			if(ArenaGRI != None)
			{
				ArenaGRI.TeamColor[LTYPE_Champion] = TeamCurrentColor[LTYPE_Champion];
				ArenaGRI.TeamColor[LTYPE_Challenger] = TeamCurrentColor[LTYPE_Challenger];
			}
		}
	}
}

//==============================================================
//
// GetNewChampions
//
//==============================================================
function GetNewChampions()
{
	local int i;
	
	i = 0;
	while(!IsFull(LTYPE_Champion))
	{
		if(ArenaQueue[i].bUsed && ArenaQueue[i].aPlayer != None)
		{
			if(!IsPlaying(ArenaQueue[i].aPlayer, 255))
			{
				ArenaQueue[i].aPlayer.PlayerReplicationInfo.Team = LTYPE_Champion;
				AddFighter(LTYPE_Champion, ArenaQueue[i].aPlayer);
			}
		
			i++;
		}
		else 
			break;
	}

	GetNextChallengers(i);
}

//==============================================================
//
// GetNextChallengers
//
//==============================================================
function GetNextChallengers(int startIndex)
{
	local int i, x;
	local Pawn NewChallenger;

	x = startIndex;
	while(!IsFull(LTYPE_Challenger))
	{
		if(!ArenaQueue[x].bUsed || ArenaQueue[x].aPlayer == None)
			return;

		if(!IsPlaying(ArenaQueue[x].aPlayer, 255))
		{
			ArenaQueue[x].aPlayer.PlayerReplicationInfo.Team = LTYPE_Challenger;
			AddFighter(LTYPE_Challenger, ArenaQueue[x].aPlayer);
		}
		
		x++;
	}

	return;
}

//==============================================================
//
// InterruptMatchStart
//
//==============================================================
function InterruptMatchStart()
{
	if(GameState == ASTATE_DuringMatch)
		return;

	ArenaGameReplicationInfo(GameReplicationInfo).bDrawTimer = false;
	bStartedTimer = false;

	if(!CanStartMatch()){
		GameState = ASTATE_WaitingPlayers;
		// <-- blitznuckel (C)
		curTimer=0;
		// -->
	}else
		GameState = ASTATE_PreMatch;	
}

//==============================================================
//
// CheckWinState
//
//==============================================================
function bool CheckWinState(byte aType)
{
	if(aType == LTYPE_Champion)
	{
		//if((ChallengersQuit + ChallengersDied) >= maxArenaTeam)
		if(ChallengersLeft <= 0)
			return true;
	}
	else if(aType == LTYPE_Challenger)
	{
		//if((ChampionsQuit + ChampionsDied) >= maxArenaTeam)
		if(ChampionsLeft <= 0)
			return true;
	}

	return false;
}

//==============================================================
//
// DetermineWinnner
//
//==============================================================
function byte DetermineWinner()
{
	if(CheckWinState(LTYPE_Champion))
		return LTYPE_Champion;

	else if(CheckWinState(LTYPE_Challenger))
		return LTYPE_Challenger;

	else
		return 255;
}

//==============================================================
//
// DetermineLoser
//
//==============================================================
function byte DetermineLoser()
{
	if(CheckWinState(LTYPE_Champion))
		return LTYPE_Challenger;

	else if(CheckWinState(LTYPE_Challenger))
		return LTYPE_Champion;

	else 
		return 255;
}

//==============================================================
//
// RestartFighter
//
//==============================================================
function RestartFighter(Pawn aPlayer)
{
	local ArenaStart aStart;
	local bool foundStart;
	local RunePlayer rPlayer;
	local PlayerPawn aPlayerPawn;

	aPlayerPawn = PlayerPawn(aPlayer);
	if(aPlayerPawn == None)
		return;

	LastRestarted = aPlayerPawn;

	aPlayerPawn.ServerRestartPlayer();

	aStart = FindArenaStart(aPlayer, aPlayerPawn.PlayerReplicationInfo.Team);
	foundStart = aPlayer.SetLocation(aStart.Location);
	if(foundStart)
		SetArenaTeleportSpot(aStart, aPlayer);

	RestorePawnHealth(aPlayer);

	rPlayer = RunePlayer(aPlayer);
	if (rPlayer!=None)
	{
		rPlayer.OldCameraStart = rPlayer.Location;
		rPlayer.OldCameraStart.Z += rPlayer.CameraHeight;
		rPlayer.CurrentDist = rPlayer.CameraDist;
		rPlayer.LastTime = 0;
		rPlayer.CurrentTime = 0;
		rPlayer.CurrentRotation = rPlayer.Rotation;
	}

	if(maxArenaTeam != 1)
		rPlayer.DesiredColorAdjust = GetTeamVectorColor(GetListColor(aPlayerPawn.PlayerReplicationInfo.Team));
}

//==============================================================
//
// RestorePawnHealth
//
//==============================================================
function RestorePawnHealth(Pawn aPlayer)
{
	local int i;
	local actor A;

	aPlayer.SetCollision( true, true, true );
	aPlayer.bCollideWorld = true;
	aPlayer.SetCollisionSize(aPlayer.Default.CollisionRadius, aPlayer.Default.CollisionHeight);	
	aPlayer.ReducedDamageType = aPlayer.Default.ReducedDamageType;
	aPlayer.ReducedDamagePct = aPlayer.Default.ReducedDamagePct;
	aPlayer.Style = aPlayer.Default.Style;
	aPlayer.bInvisible = aPlayer.Default.bInvisible;
	aPlayer.SpeedScale = SS_Circular;
	aPlayer.bLookFocusPlayer = aPlayer.Default.bLookFocusPlayer;
	aPlayer.bAlignToFloor = aPlayer.Default.bAlignToFloor;
	aPlayer.ColorAdjust = aPlayer.Default.ColorAdjust;
	aPlayer.ScaleGlow = aPlayer.Default.ScaleGlow;
	aPlayer.Fatness = aPlayer.Default.Fatness;
	aPlayer.BlendAnimSequence = aPlayer.Default.BlendAnimSequence;
	aPlayer.DesiredFatness = aPlayer.Default.DesiredFatness;

	if (PlayerPawn(aPlayer)!=None)
	{
		PlayerPawn(aPlayer).DesiredPolyColorAdjust = PlayerPawn(aPlayer).Default.DesiredPolyColorAdjust;
		PlayerPawn(aPlayer).PolyColorAdjust = PlayerPawn(aPlayer).Default.PolyColorAdjust;
		/* <-- blitznuckel (B)
		PlayerPawn(aPlayer).bBloodLust = false;
		--> */
	}

	aPlayer.bHidden = false;
	aPlayer.DamageScaling = aPlayer.Default.DamageScaling;
	aPlayer.SoundDampening = aPlayer.Default.SoundDampening;

	aPlayer.Strength = aPlayer.Default.Strength;
	aPlayer.MaxStrength = aPlayer.Default.MaxStrength;
	aPlayer.RunePower = aPlayer.Default.RunePower;
	aPlayer.MaxPower = aPlayer.Default.MaxPower;
	aPlayer.GroundSpeed = aPlayer.Default.GroundSpeed;

	aPlayer.SetDefaultPolyGroups();
	aPlayer.SetDefaultJointFlags();
	
	for (i=0; i<aPlayer.NumJoints(); i++)
	{	// Get rid of all attachments
		A = aPlayer.DetachActorFromJoint(i);
		if (A!=None)
			A.Destroy();
	}
	
	for (i=0; i<NUM_BODYPARTS; i++)
	{	// Restore body part health
		aPlayer.BodyPartHealth[i] = aPlayer.Default.BodyPartHealth[i];
	}
	// Restore joint flags
	aPlayer.SetDefaultJointFlags();
	for (i=0; i<16; i++)
	{	// Restore polygroup skins/properties
		aPlayer.SkelGroupSkins[i] = aPlayer.Default.SkelGroupSkins[i];
		aPlayer.SkelGroupFlags[i] = aPlayer.Default.SkelGroupFlags[i];
	}
	aPlayer.SetSkinActor(aPlayer, aPlayer.CurrentSkin);

	// Reset anim proxy vars
	if(PlayerPawn(aPlayer) != None && PlayerPawn(aPlayer).AnimProxy != None)
	{
		PlayerPawn(aPlayer).AnimProxy.GotoState('Idle');
	}

	aPlayer.Health = 200;
	aPlayer.MaxHealth = 200;
	aPlayer.Strength = aPlayer.Default.Strength;
	aPlayer.MaxStrength = aPlayer.Default.MaxStrength;
}

//==============================================================
//
// AddFighter
//
//==============================================================
function Pawn AddFighter(byte aType, Pawn aPawn)
{
	local int i;
	local PlayerPawn aPlayer;

	if(aType == LTYPE_Champion)
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChampionList[i].Fighter == None)
			{
				ChampionList[i].Fighter = aPawn;
				aPlayer = PlayerPawn(aPawn);
				if(aPlayer != None)
					aPlayer.PlayerReplicationInfo.Team = LTYPE_Champion;
				
				ChampionList[i].bNewFighter = true;
				return ChampionList[i].Fighter;
			}
		}
	}
	else if(aType == LTYPE_Challenger)
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChallengerList[i].Fighter == None)
			{
				ChallengerList[i].Fighter = aPawn;
				aPlayer = PlayerPawn(aPawn);
				if(aPlayer != None)
					aPlayer.PlayerReplicationInfo.Team = LTYPE_Challenger;

				ChallengerList[i].bNewFighter = true;
				return ChallengerList[i].Fighter;
			}
		}
	}

	return None;
}

//==============================================================
//
// ResetStateChange
//
// Utility to reset Players back to 'normal' state in case the match
// Is interrupted after they are stuck into the 'Unresponsive' state.
//==============================================================
function ResetStateChange()
{
	local int i;
	local RunePlayer aPlayer;

	for(i = 0; i < maxArenaTeam; i++)
	{
		if(ChampionList[i].Fighter != None && ChampionList[i].Fighter.Health > 0)
		{
			aPlayer = RunePlayer(ChampionList[i].Fighter);
			if(aPlayer != None && aPlayer.GetStateName() == 'Unresponsive')
				aPlayer.GotoState('PlayerWalking');
		}

		if(ChallengerList[i].Fighter != None && ChallengerList[i].Fighter.Health > 0)
		{
			aPlayer = RunePlayer(ChallengerList[i].Fighter);
			if(aPlayer != None && aPlayer.GetStateName() == 'Unresponsive')
				aPlayer.GotoState('PlayerWalking');
		}
	}
}

//==============================================================
//
// StateChangeFighters
//
// Will iterate through all fighters about to fight/in fight to pause their
// ability to do any animation.  If bStop, it iterates thru and returns them to 
// a normal state.
//==============================================================
function StateChangeFighters(bool bStop)
{
	local int i;
	local RunePlayer aPlayer;

	if(!bStop)
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChampionList[i].Fighter != None && ChampionList[i].Fighter.Health > 0)
			{
				aPlayer = RunePlayer(ChampionList[i].Fighter);
				if(aPlayer != None)
					aPlayer.GotoState('Unresponsive');
			}
			
			if(ChallengerList[i].Fighter != None && ChallengerList[i].Fighter.Health > 0)
			{
				aPlayer = RunePlayer(ChallengerList[i].Fighter);
				if(aPlayer != None)
					aPlayer.GotoState('Unresponsive');
			}
		}
	}
	else
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChampionList[i].Fighter != None && ChampionList[i].Fighter.Health > 0)
			{
				aPlayer = RunePlayer(ChampionList[i].Fighter);
				if(aPlayer != None)
					aPlayer.GotoState('PlayerWalking');
			}
				
			if(ChallengerList[i].Fighter != None && ChallengerList[i].Fighter.Health > 0)
			{
				aPlayer = RunePlayer(ChallengerList[i].Fighter);
				if(aPlayer != None)
					aPlayer.GotoState('PlayerWalking');
			}
		}
	}
}

//==============================================================
//
// Login
//
//==============================================================
function playerpawn Login(string Portal, string Options, out string Error, class<playerpawn> SpawnClass)
{
	local PlayerPawn newPlayer;
	
	newPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	newPlayer.MaxHealth = 200;
	newPlayer.Health = newPlayer.MaxHealth;

	newPlayer.PlayerReplicationInfo.Team = 255;
	newPlayer.PlayerReplicationInfo.TeamID = 255;

	// RMod: Spawn a follower to receive zone changes
	Spawn(class'RMod_Arena.R_ZoneEventFollower', newPlayer);

	return newPlayer;
}

//==============================================================
//
// RestartPlayer
//
//==============================================================
function bool RestartPlayer(pawn aPlayer)
{
	local bool result;
	local PlayerPawn aPlayerPawn;

	aPlayerPawn = PlayerPawn(aPlayer);

	//HACK TO WORK WITH RESTARTING PLAYERS
	if(aPlayerPawn != None && aPlayerPawn == LastRestarted)
	{
		LastRestarted = None;
		return true;
	}

	result = Super.RestartPlayer(aPlayer);
	aPlayer.DesiredColorAdjust = aPlayer.Default.DesiredColorAdjust;
	//aPlayer.MaxHealth = 200;
	//aPlayer.Health = 200;
	aPlayerPawn = PlayerPawn(aPlayer);
	if(aPlayerPawn != None)
	{
		aPlayerPawn.PlayerReplicationInfo.Team = 255;
		aPlayerPawn.PlayerReplicationInfo.TeamID = 255;
	}

	return result;
}


//==============================================================
//
// KillMessage
//
//==============================================================
static function string KillMessage( name damageType, pawn killer )
{
	if (killer == None)
	{
		switch(damageType)
		{
			case 'suicided':
				return default.SuicideDeathMessage;
			case 'crushed':
				return default.CrushDeathMessage;
			case 'fell':
				return default.FellDeathMessage;
		}
		return default.GenericDeathMessage;
	}

	switch(damageType)
	{
		case 'drowned':
			return default.DrownDeathMessage;
		case 'thrownweaponblunt':
		case 'thrownweaponsever':
		case 'thrownweaponbluntsever':
			return default.ThrownDeathMessage;
		case 'blunt':
		case 'sever':
		case 'bluntsever':
		case 'gibbed':
			return default.KillDeathMessage;
		case 'fire':
		case 'electricity':
			return default.BurnedDeathMessage;
		case 'decapitated':
			return default.HeadDeathMessage;
	}
	return default.GenericDeathMessage;
}

//==============================================================
//
// ScoreKill
//
//==============================================================
function ScoreKill(pawn Killer, pawn Other)
{
	if (Other==None)
		return;

	if(Other.bIsPlayer)// && Other.PlayerReplicationInfo != None && Other.PlayerReplicationInfo.Team != 255)
	{
		Other.DieCount++;
		//Other.PlayerReplicationInfo.Deaths +=1;
	}

	if(killer != None && killer != Other)
	{
		//if (killer.PlayerReplicationInfo != None && killer.PlayerReplicationInfo.Team != 255)
		//{
			killer.killCount++;
		//	killer.PlayerReplicationInfo.Score += 1;
		//}
	}

	BaseMutator.ScoreKill(Killer, Other);
}	

//==============================================================
//
// IsPlaying
//
//==============================================================
function bool IsPlaying(Pawn aPawn, byte aType)
{
	local int i;
	local PlayerPawn aPlayer;

	aPlayer = PlayerPawn(aPawn);

	if(aPlayer != None)
	{
		if(aType == 255 && (aPlayer.PlayerReplicationInfo.Team == 0 || aPlayer.PlayerReplicationInfo.Team == 1))
			return true;

		else if(aType != 255 && aPlayer.PlayerReplicationInfo.Team == aType)
			return true;
	}

	return false;
}

//==============================================================
//
// SendGetReadyMsg
//
//==============================================================
function SendGetReadyMsg()
{
	local Pawn aPawn;
	local PlayerPawn aPlayer;

	for(aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
	{
		aPlayer = PlayerPawn(aPawn);
		if(aPlayer != None && aPlayer.PlayerReplicationInfo != None)
		{
			if(aPlayer.PlayerReplicationInfo.Team == 0 || aPlayer.PlayerReplicationInfo.Team == 1)
				aPlayer.ClientMessage(GetReadyMessage);
		}
	}
}

//==============================================================
//
// ChangeTeam
//
//==============================================================
function bool ChangeTeam(Pawn Other, int N)
{
	return true;
}

//==============================================================
//
// Killed
//
//==============================================================
function Killed(Pawn Killer, Pawn Other, name damageType)
{
	if(Other == None || Other.PlayerReplicationInfo == None)
		return;

	if(IsPlaying(Other, 255))
	{
		Super(GameInfo).Killed(Killer, Other, damageType);
		HandleKill(Other, Killer, damageType);
	}
	else if(Other.PlayerReplicationInfo.TeamID <= maxArenaTeam && GameState == ASTATE_PreMatch)
	{
		RemoveFromQueue(Other);
		ResetStateChange();
		InterruptMatchStart();
	}
	else
		RemoveFromQueue(Other);

	if(DetermineWinner() != 255 && FragLimit > 0 && ((CurrentMatch) >= FragLimit))
		EndGame("Match Limit");
		
}

//==============================================================
//
// EquipPawn
// Lars comments:
// This is where we need to fix the "restore shield health" bug
// While we're at it, let's do the same thing to weapons, so that
// breakable weapon mutators work correctly
//
//==============================================================
function EquipPawn(Pawn aPlayerPawn, PlayerInventory myInventory)
{
	local Inventory HeldShield, HeldWeapon, StowedWeapon;
	local int i;

	for(i = 13; i >= 0; i--)
	{
		if(myInventory.StowedWeapons[i] != None)
		{
			StowedWeapon = spawn(myInventory.StowedWeapons[i],,,aPlayerPawn.Location);
			if(StowedWeapon != None)
			{
				StowedWeapon.bTossedOut = true;
				StowedWeapon.Instigator = aPlayerPawn;
				StowedWeapon.BecomeItem();
				aPlayerPawn.AddInventory(StowedWeapon);
				aPlayerPawn.AcquireInventory(StowedWeapon);
				StowedWeapon.RespawnTime = 0.0; // 108
				RunePlayer(aPlayerPawn).StowWeapon(Weapon(StowedWeapon));
			}
		}
	}

	if(myInventory.HeldWeapon != None)
	{
		HeldWeapon = spawn(myInventory.HeldWeapon, , ,aPlayerPawn.Location);
		if(HeldWeapon != None)
		{
			HeldWeapon.bTossedOut = true;
			HeldWeapon.Instigator = aPlayerPawn;
			HeldWeapon.BecomeItem();
			aPlayerPawn.AddInventory(HeldWeapon);
			aPlayerPawn.AcquireInventory(HeldWeapon);
			aPlayerPawn.Weapon = Weapon(HeldWeapon);
			HeldWeapon.RespawnTime = 0.0; // 108
			HeldWeapon.GotoState('Active');
		}
	} 

	if(myInventory.HeldShield != None)
	{
		HeldShield = spawn(myInventory.HeldShield,,,aPlayerPawn.Location);
		if(HeldShield != None)
		{
			HeldShield.bTossedOut = true;
			HeldShield.Instigator = aPlayerPawn;
			HeldShield.BecomeItem();
			aPlayerPawn.AddInventory(HeldShield);
			aPlayerPawn.AcquireInventory(HeldShield);
			aPlayerPawn.Shield = Shield(HeldShield);
			HeldShield.RespawnTime = 0.0;  // 108 (Lar)this is the line we need to prevent rehealth and respawn
			HeldShield.GotoState('Active');
		}
	}
}

//==============================================================
//
// DestroyPawnsWeapons
//
//==============================================================
function DestroyPawnsWeapons(Pawn PlayerPawn)
{
	local Inventory Inv;
	local Inventory next;
	local int i;

	i = 0;
	
	for(Inv = PlayerPawn.Inventory; Inv != None; Inv = next)
	{
		next = Inv.Inventory;
		Inv.Destroy();

	}

	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
}

//==============================================================
//
// DestroyArenaWeapons
//
//==============================================================
function DestroyArenaWeapons()
{
	local Inventory A;
	local Carcass C;

	foreach AllActors(class 'Inventory', A)
	{
		if((A.IsA('Weapon') || A.IsA('Shield')) && A.Region.Zone.IsA('ArenaZone'))
		{
			if(A.Owner == None || A.GetStateName() == 'Throw' || A.GetStateName() == 'Settling')
				A.Destroy();
		}
	}

	foreach AllActors(class 'Carcass', C)
	{
		if(C.Region.Zone.IsA('ArenaZone'))
			C.Destroy();
	}
}

//==============================================================
//
// SetArenaTeleportSpot
//
//==============================================================
function SetArenaTeleportSpot(NavigationPoint N, Pawn aPlayer)
{
	local bool foundStart;

	PlayTeleportEffect(aPlayer, false, true);

	foundStart = aPlayer.SetLocation(N.Location);
	if(foundStart)
	{
		N.PlayTeleportEffect(aPlayer, true);
		aPlayer.SetRotation(N.Rotation);
		aPlayer.ViewRotation = aPlayer.Rotation;
		aPlayer.Acceleration = vect(0,0,0);
		aPlayer.Velocity = vect(0,0,0);
		aPlayer.ClientSetLocation(N.Location, N.Rotation);
	}

	ArenaStart(N).Trigger(None, None);
}



//==============================================================
//
// FindPlayerStart
//
//==============================================================
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest, Candidate[8], Best; // blitznuckel (D)
	local float Score[8], BestScore, NextDist; // blitznuckel (D)
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;
	local NavigationPoint N;

	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;

	num = 0;
	//choose candidates
	N = Level.NavigationPointList;
	While ( N != None )
	{
		if ( N.IsA('PlayerStart') && !N.Region.Zone.bWaterZone && !N.IsA('ArenaStart'))
		{
			if (num<8) // blitznuckel (D)
				Candidate[num] = PlayerStart(N);
			else if (Rand(num) < 8) // blitznuckel (D)
				Candidate[Rand(8)] = PlayerStart(N); // blitznuckel (D)
			num++;
		}
		N = N.nextNavigationPoint;
	}

	if (num == 0 )
		foreach AllActors( class 'PlayerStart', Dest )
		{
			if(!Dest.IsA('ArenaStart'))
			{
				if (num<8) // blitznuckel (D)
					Candidate[num] = Dest;
				else if (Rand(num) < 8) // blitznuckel (D)
					Candidate[Rand(8)] = Dest; // blitznuckel (D)
				num++;
			}
		}

	if (num>8) num = 8; // blitznuckel (D)
	else if (num == 0)
		return None;

	//assess candidates
	for (i=0;i<num;i++)
		Score[i] = 4000 * FRand(); //randomize

	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) )
			for (i=0;i<num;i++)
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
				{
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if (NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight)
						Score[i] -= 1000000.0;
					else if ( (NextDist < 2000) && OtherPlayer.LineOfSightTo(Candidate[i]) )
						Score[i] -= 10000.0;
				}

	BestScore = Score[0];
	Best = Candidate[0];
	for (i=1;i<num;i++)
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}

	return Best;
}

//==============================================================
//
// RemoveQueueElement
//
//==============================================================
function RemoveQueueElement(int element)
{
	local int i;

	if(ArenaQueue[element].bUsed)
	{
		ArenaQueue[element].aPlayer.PlayerReplicationInfo.TeamID = 255;
		ArenaQueue[element].bUsed = false;
		ArenaQueue[element].aPlayer = None;

		for(i = element; i < 31; i++) // blitznuckel (E)
		{
			if(!ArenaQueue[i+1].bUsed)
				return;

			CopyPlayerInfo(ArenaQueue[i], ArenaQueue[i+1]);
		
			ArenaQueue[i].aPlayer.PlayerReplicationInfo.TeamID = (i+1);
			ArenaQueue[i+1].bUsed = false;
			ArenaQueue[i+1].aPlayer = None;
		}
	}
}

//==============================================================
//
// RemoveFromQueue
//
//==============================================================
function RemoveFromQueue(Pawn aPawn)
{
	local bool bFound;
	local PlayerPawn aPlayer;
	local int i;

	bFound = false;

	aPlayer = PlayerPawn(aPawn);
	if(aPlayer == None)
		return;

	for(i = 0; i < 32; i++) // blitznuckel (E)
	{
		if(bFound)
		{
			if(ArenaQueue[i].bUsed)
			{
				aPlayer.PlayerReplicationInfo.TeamID = 255;
				CopyPlayerInfo(ArenaQueue[i-1], ArenaQueue[i]);
				
				ArenaQueue[i-1].aPlayer.PlayerReplicationInfo.TeamID = (i);
				ArenaQueue[i].bUsed = false;
				ArenaQueue[i].aPlayer = None;
			}
			else
				return;
		}
		else if(ArenaQueue[i].bUsed && ArenaQueue[i].aPlayer == aPlayer)
		{
			bFound = true;
			
			ArenaQueue[i].aPlayer.PlayerReplicationInfo.TeamID = 255;
			ArenaQueue[i].bUsed = false;
			ArenaQueue[i].aPlayer = None;
		}
		else if(!ArenaQueue[i].bUsed)
			return;	
	}
}

//==============================================================
//
// GetQueueSize
//
//==============================================================
function int GetQueueSize()
{
	local int i;
	local int count;

	count = 0;

	for(i = 0; i < 32; i++) // blitznuckel (E)
	{
		if(!ArenaQueue[i].bUsed)
			return count;
		else if(ArenaQueue[i].aPlayer != None && !IsPlaying(ArenaQueue[i].aPlayer, 255) && ArenaQueue[i].aPlayer.Health > 0)
			count++;
		else if(ArenaQueue[i].aPlayer != None && ArenaQueue[i].aPlayer.Health <= 0)
			RemoveQueueElement(i);	//Safety precaution in case somehow queue member died w/o being removed
	}

	return count;
}

//==============================================================
//
// CopyPlayerInfo
//
//==============================================================
function CopyPlayerInfo(out ArenaPlayerInfo dest, ArenaPlayerInfo src)
{
	dest.bUsed = src.bUsed;
	dest.aPlayer = src.aPlayer;
}

//==============================================================
//
// ClearFighterList
//
//==============================================================
function ClearFighterList(out FighterList myList)
{
	myList.bNewFighter = true;
	myList.Fighter = None;
	ClearWeaponInfo(myList.FighterInventory);
}

//==============================================================
//
// CopyFighterList
//
//==============================================================
function CopyFighterList(out FighterList dest, FighterList src)
{
	dest.Fighter = src.Fighter;
	dest.bNewFighter = src.bNewFighter;
	CopyWeaponInfo(dest.FighterInventory, src.FighterInventory);
}

//==============================================================
//
// SavePawnsWeapons
//
//==============================================================
function SavePawnsWeapons(Pawn aPawn, out PlayerInventory myInventory)
{
	local Inventory Inv;
	local Inventory next;
	local int i;

	i = 0;
	
	if(aPawn.Weapon != None)
		myInventory.HeldWeapon = aPawn.Weapon.Class;
	if(aPawn.Shield != None)
		myInventory.HeldShield = aPawn.Shield.Class;

	for(Inv = aPawn.Inventory; Inv != None; Inv = next)
	{
		next = Inv.Inventory;
		if(i >= 14)
			return;//Max amount of stowed-weapons to save

		if(Inv != aPawn.Weapon && Inv.IsA('Weapon') && !Inv.IsA('NonStow'))
		{
			myInventory.StowedWeapons[i] = Inv.Class;
				i++;
		}
	}
}	

//==============================================================
//
// CopyWeaponInfo
//
//==============================================================
function CopyWeaponInfo(out PlayerInventory dest, PlayerInventory src)
{
	local int i;

	dest.HeldWeapon = src.HeldWeapon;
	dest.HeldShield = src.HeldShield;

	for(i = 0; i < 14; i++)
		dest.StowedWeapons[i] = src.StowedWeapons[i];
}

//==============================================================
//
// ClearWeaponInfo
//
//==============================================================
function ClearWeaponInfo(out PlayerInventory myInventory)
{
	local int i;

	myInventory.HeldWeapon = None;
	myInventory.HeldShield = None;

	for(i = 0; i < 14; i++)
		myInventory.StowedWeapons[i] = None;
}

//==============================================================
//
// IsFull
//
//==============================================================
function bool IsFull(byte aType)
{
	local int i;
	if(aType == LTYPE_Champion)
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChampionList[i].Fighter == None)
				return false;
		}
		return true;
	}
	else if(aType == LTYPE_Challenger)
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChallengerList[i].Fighter == None)
				return false;
		}

		return true;
	}
	else
		return false;
}

//==============================================================
//
// GetListSize
//
//==============================================================
function int GetListSize(byte aType)
{
	local int i;

	if(aType == LTYPE_Champion)
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChampionList[i].Fighter == None)
				return i;
		}

		return maxArenaTeam;

	}
	else if(aType == LTYPE_Challenger)
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChallengerList[i].Fighter == None)
				return i;
		}

		return maxArenaTeam;
	}
	return 0;
}


//==============================================================
//
// IsEmpty
//
//==============================================================
function bool IsEmpty(byte aType)
{
	if(aType == LTYPE_Champion)
	{
		if(ChampionList[0].Fighter == None)
			return true;
		else 
			return false;
	}
	else if(aType == LTYPE_Challenger)
	{
		if(ChallengerList[0].Fighter == None)
			return true;
		else
			return false;
	}
}

//==============================================================
//
// RemoveFighter
//
//==============================================================
function Pawn RemoveFighter(byte aType, Pawn aPawn)
{
	local int i;
	local Pawn foundPawn;
	local PlayerPawn aPlayer;

	if(aType == LTYPE_Champion)
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChampionList[i].Fighter == aPawn)
			{
				foundPawn = ChampionList[i].Fighter;
				
				aPlayer = PlayerPawn(foundPawn);
				if(aPlayer != None)
					aPlayer.PlayerReplicationInfo.Team = 255;

				ClearFighterList(ChampionList[i]);
				for(i = i; i < maxArenaTeam - 1; i++)
				{
					if(ChampionList[i+1].Fighter != None)
					{
						CopyFighterList(ChampionList[i], ChampionList[i+1]);
						ClearFighterList(ChampionList[i+1]);
					}
					else
						return foundPawn;
				}

				return foundPawn;
			}
		}
	}
	else if(aType == LTYPE_Challenger)
	{
		for(i = 0; i < maxArenaTeam; i++)
		{
			if(ChallengerList[i].Fighter == aPawn)
			{
				foundPawn = ChallengerList[i].Fighter;
				
				aPlayer = PlayerPawn(foundPawn);
				if(aPlayer != None)
					aPlayer.PlayerReplicationInfo.Team = 255;

				ClearFighterList(ChallengerList[i]);
				for(i = i; i < maxArenaTeam - 1; i++)
				{
					if(ChallengerList[i+1].Fighter != None)
					{
						CopyFighterList(ChallengerList[i], ChallengerList[i+1]);
						ClearFighterList(ChallengerList[i+1]);
					}
					else
						return foundPawn;
				}

				return foundPawn;
			}
		}
	}

	return None;
}

//==============================================================
//
// LeftQueueZone
//
//==============================================================
function LeftQueueZone(Pawn aPawn)
{
    if(aPawn.IsA('Spectator')) //108
            return;

	// RMod
	if(aPawn.GetStateName() == 'PlayerSpectating')
		return;
	if(aPawn.PlayerReplicationInfo != None
	&& aPawn.PlayerReplicationInfo.bIsSpectator)
		return;
	
 	if(IsPlaying(aPawn, 255))
 	{
		if(GameState == ASTATE_DuringMatch)
		{
			RemoveFromQueue(aPawn);
			return;
		}
		else
		{
			if(IsPlaying(aPawn, LTYPE_Champion))
				RemoveFighter(LTYPE_Champion, aPawn);

			else if(IsPlaying(aPawn, LTYPE_Challenger))
				RemoveFighter(LTYPE_Challenger, aPawn);

			RemoveFromQueue(aPawn);
			InterruptMatchStart();
		}
 	}
 	else if(aPawn.PlayerReplicationInfo.TeamID <= maxArenaTeam)
	{
		RemoveFromQueue(aPawn);
		InterruptMatchStart();
	}
	else
		RemoveFromQueue(aPawn);	
}

//==============================================================
//
// EnteredQueueZone
//
//==============================================================
function EnteredQueueZone(Pawn aPawn)
{
	local int i;
	local PlayerPawn aPlayer;

	aPlayer = PlayerPawn(aPawn);
	if(aPlayer == None || aPawn.IsA('Spectator') || aPlayer.IsA('Spectator')) // 108
		return;
	
	// RMod
	if(aPawn.GetStateName() == 'PlayerSpectating')
		return;
	if(aPawn.PlayerReplicationInfo != None
	&& aPawn.PlayerReplicationInfo.bIsSpectator)
		return;

	for(i = 0; i < 32; i++) // blitznuckel (E)
	{
		if(!ArenaQueue[i].bUsed)
		{
			ArenaQueue[i].bUsed = true;
			ArenaQueue[i].aPlayer = aPlayer;
			
			aPlayer.PlayerReplicationInfo.TeamID = (i+1);
			i = 32; //Early break-out... // blitznuckel (E)
		}
	}

	if(GameState == ASTATE_WaitingPlayers)
	{
		InterruptMatchStart();
		
		//if(!CanStartMatch())
		//	GameState = ASTATE_WaitingPlayers;
		//else
		//	GameState = ASTATE_PreMatch;
	}
}

//==============================================================
//
// ClearList
//
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
// Debug
//
//==============================================================
simulated function Debug(Canvas canvas, int mode)
{
	local int i;

	//Super.Debug(canvas, mode);

	Canvas.DrawText("ArenaGameInfo:");
	Canvas.CurY -= 8;

	switch(GameState)
	{
		case ASTATE_WaitingPlayers:
			Canvas.DrawText("ASTATE_WaitingPlayers");
			break;
		case ASTATE_DuringMatch:
			Canvas.DrawText("ASTATE_DuringMatch");
			break;
		case ASTATE_PreMatch:
			Canvas.DrawText("ASTATE_PreMatch");
			break;
		case ASTATE_PostMatch:
			Canvas.DrawText("ASTATE_PostMatch");
			break;
	}
	Canvas.CurY -= 8;

	Canvas.DrawText("curTimer: " $curTimer);
	//Canvas.CurY -= 8;
	
	
	Canvas.DrawText("ChallengersReady: " $GetListSize(LTYPE_Challenger));
	Canvas.CurY -= 8;
	
	Canvas.DrawText("ChampionsReady: " $GetListSize(LTYPE_Champion));
	Canvas.CurY -= 8;
	
	Canvas.DrawText("QueueReady: " $GetQueueSize());
	//Canvas.CurY -= 8;
	
	
	Canvas.DrawText("ChampionsLeft: " $ChampionsLeft);
	Canvas.CurY -= 8;

	Canvas.DrawText("ChallengersLeft: " $ChallengersLeft);
	Canvas.CurY -= 8;

	for(i = 0; i < maxArenaTeam; i++)
	{
		if(ChampionList[i].Fighter == None)
			break;

		Canvas.DrawText("Champion-> " $ChampionList[i].Fighter.PlayerReplicationInfo.PlayerName);
		Canvas.CurY -= 8;
	}
	for(i = 0; i < maxArenaTeam; i++)
	{
		if(ChallengerList[i].Fighter == None)
			break;

		Canvas.DrawText("Challenger-> " $ChallengerList[i].Fighter.PlayerReplicationInfo.PlayerName);
		Canvas.CurY -= 8;
	}

	for(i = 0; i < 32; i++) // blitznuckel (E)
	{
		if(!ArenaQueue[i].bUsed)
			break;

		Canvas.DrawText("Queue " $ i $ "--> " $ArenaQueue[i].aPlayer.PlayerReplicationInfo.PlayerName);
		Canvas.CurY -= 8;
	}
}


// <-- blitznuckel (C): additional functions for auto team sizing

function int calcNewTeamSize(int numberOfPlayers){
	if( (numberOfPlayers % 2)==1 )
		return max(1,min(maxMapSupport,(numberOfPlayers-1)/2));
	else
		return max(1,min(maxMapSupport,numberOfPlayers/2));
}

function int countReadyPlayers(){
	return GetListSize(LTYPE_Champion)
				+ GetListSize(LTYPE_Challenger)
				+ GetQueueSize() ;
}

function fixChangeTo1on1(){
	local Pawn p;
	local PlayerPawn player;
	
	for( p = Level.PawnList; p != None; p = p.NextPawn ){
		player = PlayerPawn(p);
		if( player != None ){
			player.DesiredColorAdjust = player.default.DesiredColorAdjust;
		}
	}
}

function decreaseTeamSize(int newTeamSize){
	
	local int i,j;
	local int numChamps;
	local int excrescentChamps; // number of champs that have to leave the team.
	
	local PlayerPawn p;
	
	if( maxArenaTeam >= newTeamSize && newTeamSize >= 1 ){
		
		excrescentChamps = GetListSize(LTYPE_Champion)-newTeamSize; 
		
		j = 0;
		for( i = (maxArenaTeam-1); i > (maxArenaTeam-1-excrescentChamps); i--){
			
			if( j < newTeamSize ){ // check if there are not too many players left in arena
				
				// move champs to challengers.
				if(ChampionList[i].Fighter != None){
					p = PlayerPawn(ChallengerList[i].Fighter);
					if( p != None )
						p.PlayerReplicationInfo.Team = LTYPE_Challenger;
					CopyFighterList(ChallengerList[j], ChampionList[i]);
					ClearFighterList(ChampionList[i]);
				}
			
			}else{ // reset all players that are too much for new team size ..
				
				if(ChampionList[i].Fighter != None){
					if( LastRestarted == ChampionList[i].Fighter )
						LastRestarted = none;
					RestartPlayer(ChampionList[i].Fighter); // reset health, strenght, ..  and move champ to a startpoint
					RemoveFighter(LTYPE_Champion,ChampionList[i].Fighter); // kick champ from champions team
					RemoveFromQueue(ChampionList[i].Fighter); // kick champ from the arenaqueue
				}
				
			}
			
			j++;
			
		}
		
		updateArenaTeamSize(newTeamSize);
		BroadcastMessage(teamSizeDecreaseA$(newTeamSize)$teamSizeDecreaseB);
		
	}
}

function increaseTeamSize(int newTeamSize){
	if( maxMapSupport >= newTeamSize && newTeamSize > maxArenaTeam ){
		updateArenaTeamSize(newTeamSize);
		BroadcastMessage(teamSizeIncreaseA$(newTeamSize)$teamSizeIncreaseB);
		InterruptMatchStart();
	}
}

function updateArenaTeamSize(int newTeamSize){
	
	maxArenaTeam = newTeamSize;
	maxTeamSupport = newTeamSize;
	ChampionsLeft = newTeamSize;
	ChallengersLeft = newTeamSize;
	ArenaGameReplicationInfo(GameReplicationInfo).matchSize = newTeamSize;
	
}

// -->


//==============================================================
//
// DefaultProperties
//
//==============================================================

defaultproperties
{
    RunePlayerClass=Class'RMod_Arena.R_RunePlayer_Arena'
    TimeBetweenMatch=5
    MaxTeamSupport=1
    bAutoArenaTeamSizeEnabled=True
    secondsBeforeTeamSizeChange=15
    teamSizeIncreaseA="Team size has been increased to "
    teamSizeDecreaseA="Team size has been decreased to "
    maxArenaTeam=1
    MaxArenaPlayers=8
    TeamCurrentColor(1)=1
    CountDownSound(0)=Sound'AddOn.Arena.countdown01'
    CountDownSound(1)=Sound'AddOn.Arena.countdown02'
    CountDownSound(2)=Sound'AddOn.Arena.countdown03'
    ArenaLeadInSound(0)=Sound'AddOn.Arena.lead01'
    ArenaLeadInSound(1)=Sound'AddOn.Arena.lead02'
    ArenaLeadInSound(2)=Sound'AddOn.Arena.lead03'
    ArenaLeadInSound(3)=Sound'AddOn.Arena.lead04'
    MatchStartSound(0)=Sound'AddOn.Arena.start01'
    MatchStartSound(1)=Sound'AddOn.Arena.start02'
    MatchStartSound(2)=Sound'AddOn.Arena.start03'
    MatchStartSound(3)=Sound'AddOn.Arena.start04'
    MatchEndSound(0)=Sound'AddOn.Arena.end01'
    MatchEndSound(1)=Sound'AddOn.Arena.end02'
    MatchEndSound(2)=Sound'AddOn.Arena.end03'
    GetReadyMessage="Its Your Turn to fight! Get Ready!"
    FightMessage="THE BATTLE BEGINS!!"
    SuicideDeathMessage=" suicided!!"
    CrushDeathMessage=" got crushed!!"
    FellDeathMessage=" fell to death!!"
    DrownDeathMessage="%o drowned!!"
    ThrownDeathMessage="%o died by a thrown weapon from %k"
    KillDeathMessage="%o was killed by %k"
    BurnedDeathMessage="%o was burned by %k"
    HeadDeathMessage="%o has given up a head to %k!!"
    GenericDeathMessage=" died!!"
    bCoopWeaponMode=False
    DefaultWeapon=None
    ScoreBoardType=Class'RMod_Arena.R_Scoreboard_Arena'
    RulesMenuType="Arena.ArenaMenuRulesSC"
    HUDType=Class'RMod_Arena.R_RunePlayerHUD_Arena'
    MapListType=Class'Arena.ARMapList'
    MapPrefix="AR"
    BeaconName="AR"
    GameName="Arena Match"
    GameReplicationInfoClass=Class'Arena.ArenaGameReplicationInfo'
    bAllowLimbSever=False
    DefaultPlayerMaxHealth=200
    DefaultPlayerHealth=200
    GameOptionsClass=Class'RMod.R_GameOptions_Arena'
}
