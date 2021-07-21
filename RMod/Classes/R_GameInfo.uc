class R_GameInfo extends RuneI.RuneMultiPlayer;

var class<RunePlayer> RunePlayerClass;
var class<RunePlayer> SpectatorMarkerClass;
var class<PlayerReplicationInfo> PlayerReplicationInfoClass;

var class<R_GamePresets> GamePresetsClass;
var class<R_AUtilities> UtilitiesClass;

var private String OldGamePassword;

var class<HUD> HUDTypeSpectator;
var bool bAllowSpectatorBroadcastMessage;

// Used at level start to mark actors which stay during level reset
var bool bMarkSpawnedActorsAsNativeToLevel;

// Gameplay modifications
var bool bRModEnabled;

event Tick(float DeltaSeconds)
{
	local String CurrentGamePassword;
	local R_RunePlayer RP;

	// Game password updates
	CurrentGamePassword = ConsoleCommand("Get Engine.GameInfo GamePassword");

	// Watch for changes and send updates to players
	if(OldGamePassword != CurrentGamePassword)
	{
		OldGamePassword = CurrentGamePassword;
		foreach AllActors(class'RMod.R_RunePlayer', RP)
		{
			RP.ClientReceiveUpdatedGamePassword(CurrentGamePassword);
		}
	}
}

function bool CheckMapExists(String MapString)
{
	if(MapString == ""
	|| LevelInfo(DynamicLoadObject(
		MapString$".LevelInfo0", class'LevelInfo')) == None)
	{
		return false;
	}
	return true;
}

function SwitchGame(PlayerPawn Sender, String S)
{
	//TODO:
	// native(539) final function string GetMapName( string NameEnding, string MapName, int Dir );
	// native(547) final function string GetURLMap();
	local R_GamePresets GP;
	local String GameTag;
	local String MapString;
	local String ErrorToken;
	local String URL;
	local int i;
	
	// Verify valid input string
	GameTag = GetToken(S);
	MapString = GetToken(S);
	ErrorToken = GetToken(S);
	
	if(ErrorToken != "")
	{
		SwitchGameErrorMessage(Sender);
		return;
	}
	
	// Find options string
	GP = Spawn(GamePresetsClass);
	URL = GP.FindOptions(GameTag);
	GP.Destroy();
	
	if(URL == "")
	{
		SwitchGameErrorMessage(
			Sender, "Game tag " $ GameTag $ " is not configured");
		return;
	}
	
	// Verify map is installed
	if(MapString == "")
	{
		SwitchGameErrorMessage(
			Sender, "Map name not specified");
		return;
	}
	else if(!CheckMapExists(MapString))
	{
		SwitchGameErrorMessage(
			Sender, "Map: " $ MapString $ " is not installed on this server");
		return;
	}
	
	// Switch level
	URL = MapString $ "?" $ URL;
	Level.ServerTravel(URL, false);
}

function SwitchGameErrorMessage(PlayerPawn Sender, optional String ErrorMessage)
{
	if(ErrorMessage != "")
	{
		Sender.ClientMessage(ErrorMessage);
	}
	Sender.ClientMessage("Usage: SwitchGame <game tag> <map name>");
}

function PlayerSetTimeLimit(PlayerPawn P, int DurationMinutes)
{
	local R_RunePlayer RP;
	local R_GameReplicationInfo GRI;
	
	TimeLimit = DurationMinutes;
	RemainingTime = TimeLimit * 60;
	
	GRI = R_GameReplicationInfo(GameReplicationInfo);
	if(GRI != None)
	{
		GRI.UpdateTimeLimit(RemainingTime);
	}
	
	SaveConfig();
	
	BroadcastMessage("TimeLimit has been set to " $ DurationMinutes $ " minutes.");
}

event PostBeginPlay()
{
	local String CurrentGamePassword;

	Super.PostBeginPlay();
	
	// Actors spawned after this point are not a part of the level's original
	// state, so they won't be respawned on level reset
	bMarkSpawnedActorsAsNativeToLevel = false;

	CurrentGamePassword = ConsoleCommand("Get Engine.GameInfo GamePassword");
	OldGamePassword = CurrentGamePassword;
}

/////////////////////////////////////////////////////////////////////////////////
//	NativeLevelCleanup
//	Remove all non-essential actors in the level that were not there at startup
final function MarkActorAsNativeToLevel(Actor A)	{ A.bDifficulty3 = true; }
final function MarkActorAsNotNativeToLevel(Actor A)	{ A.bDifficulty3 = false; }
final function bool CheckActorNativeToLevel(Actor A){ return A.bDifficulty3; }

// Check up the actor's owner hierarchy, return true if any owner is native
final function bool RecursiveCheckActorNativeToLevel(Actor A)
{
	local Actor AOwner;
	
	AOwner = A;
	while(AOwner != None)
	{
		if(CheckActorNativeToLevel(AOwner))
		{
			return true;
		}
		AOwner = AOwner.Owner;
	}
	return false;
}

// Check up the actors owner hierarchy, return true if any owner is a player
final function bool RecursiveCheckOwnedByPlayer(Actor A)
{
	local Actor AOwner;
	
	AOwner = A;
	while(AOwner != None)
	{
		if(PlayerPawn(AOwner) != None)
		{
			return true;
		}
		AOwner = AOwner.Owner;
	}
	return false;
}

// Authoritative function determining whether or not to destroy an actor
final function bool CheckShouldNativeLevelCleanupDestroyActor(Actor A)
{
	// Do not destroy info actors
	if(Info(A) != None)
	{
		return false;
	}
	
	// Don't destroy players or anything owned by players (anim proxy)
	if(RecursiveCheckOwnedByPlayer(A))
	{
		return false;
	}
	
	// Don't destroy anything that has been marked native or has a native owner
	if(RecursiveCheckActorNativeToLevel(A))
	{
		return false;
	}
	
	return true;
}

// Restore a given actor to its native state
final function RestoreActorToNativeState(Actor A)
{
	if(Inventory(A) != None && A.Owner == None)
	{
		Inventory(A).GotoState('Pickup');
		return;
	}
}

// Restore the level to its native state
final function NativeLevelCleanup()
{
	local Actor A;
	local Actor AOwner;
	
	UtilitiesClass.Static.RModLog("Performing native level cleanup");
	
	foreach AllActors(class'Engine.Actor', A)
	{
		if(CheckShouldNativeLevelCleanupDestroyActor(A))
		{
			A.Destroy();
		}
		else
		{
			RestoreActorToNativeState(A);
		}
	}
}

function ResetGameReplicationInfo()
{
	local PlayerPawn P;
	local RuneMultiPlayer RMP;
	local int i;
	
	UtilitiesClass.Static.RModLog("Reinitializing game replication info");
	
	RMP = RuneMultiPlayer(Level.Game);
	if(RMP != None)
	{
		RMP.RemainingTime = 60 * RMP.TimeLimit;
		
		// Reinitialize game replication info
		if(Level.Game.GameReplicationInfo != None)
		{
			Level.Game.GameReplicationInfo.Destroy();
		}
		
		if(Level.Game.GameReplicationInfoClass != None)
		{
			Level.Game.GameReplicationInfo = Spawn(Level.Game.GameReplicationInfoClass);
		}
		else
		{
			Level.Game.GameReplicationInfo = Spawn(class'Engine.GameReplicationInfo');
		}
		
		Level.Game.GameReplicationInfo.RemainingTime = RMP.RemainingTime;
		Level.Game.InitGameReplicationInfo();
		
		foreach AllActors(class'Engine.PlayerPawn', P)
		{
			P.GameReplicationInfo = Level.Game.GameReplicationInfo;
		}
	}
}

function ResetPlayerReplicationInfos()
{
	local PlayerReplicationInfo PRI;
	
	UtilitiesClass.Static.RModLog("Resetting all player replication infos");
	
	foreach AllActors(class'Engine.PlayerReplicationInfo', PRI)
	{
		PRI.Score = 0;
		PRI.Deaths = 0;
		PRI.bFirstBlood = false;
		PRI.MaxSpree = 0;
		PRI.HeadKills = 0;
	}
}

function ResetTeamReplicationInfos()
{
	local TeamInfo TRI;
	
	UtilitiesClass.Static.RModLog("Resetting all team replication infos");
	
	foreach AllActors(class'RuneI.TeamInfo', TRI)
	{
		TRI.Score = 0;
	}
}

function ResetPlayerPawnStatistics()
{
	local PlayerPawn P;
	
	foreach AllActors(class'Engine.PlayerPawn', P)
	{
		P.DieCount = 0;
		P.ItemCount = 0;
		P.KillCount = 0;
		P.SecretCount = 0;
		P.Spree = 0;
	}
}

function ResetLevel(optional int DelaySeconds)
{
	local PlayerPawn P;
	local R_GameResetAgent GRA;
	
	DelaySeconds = Clamp(DelaySeconds, 0, 10);
	if(DelaySeconds > 0)
	{
		// GameResetAgent will call back after countdown
		GRA = Spawn(class'RMod.R_GameResetAgent');
		if(GRA != None)
		{
			GRA.DurationSeconds = DelaySeconds;
		}
		return;
	}
	
	UtilitiesClass.Static.RModLog("Resetting level");
	
	// Remove non-native actors
	NativeLevelCleanup();

	// Reset game stats
	ResetGameReplicationInfo();
	ResetPlayerReplicationInfos();
	ResetTeamReplicationInfos();
	ResetPlayerPawnStatistics();

	// Restart all players
	foreach AllActors(class'Engine.PlayerPawn', P)
	{
		// Do not restart spectators
		if(Spectator(P) != None
		|| P.GetStateName() == 'PlayerSpectating')
		{
			continue;
		}
		
		Level.Game.RestartPlayer(P);
	}
}

function bool RestartPlayer( pawn aPlayer )	
{
	if(R_RunePlayer(aPlayer) != None)
	{
		R_RunePlayer(aPlayer).DiscardInventory();
	}
	DiscardInventory(aPlayer);
	return Super.RestartPlayer(aPlayer);
}

function PlayerPawn GetPlayerPawnByID(int PlayerID)
{
	local PlayerPawn P;
	
	foreach AllActors(class'Engine.PlayerPawn', P)
	{
		if(P.PlayerReplicationInfo != None
		&& P.PlayerReplicationInfo.PlayerID == PlayerID)
		{
			return P;
		}
	}
	return None;
}

//////////////////////////////////////////////////////////////////////////////////
////	PreLogin
////	TODO: Add an incoming message or something
//event PreLogin(
//	String Options,
//	String Address,
//	out String Error,
//	out String FailCode)
//{
//	Super.PreLogin(Options, Address, Error, FailCode);
//}

////////////////////////////////////////////////////////////////////////////////
//	Login
event PlayerPawn Login(
	String Portal,
	String Options,
	out String Error,
	class<PlayerPawn> SpawnClass)
{
	local class<PlayerPawn> IncomingClass;
	local PlayerPawn P;
	
	IncomingClass = SpawnClass;
	
	SpawnClass = RunePlayerClass;
	
	P = Super.Login(
		Portal,
		Options,
		Error,
		SpawnClass);
	
	if(class<RunePlayer>(IncomingClass) != None
	&& class<R_RunePlayer>(IncomingClass) == None)
	{
		UtilitiesClass.Static.RModLog("Incoming player subclass: " $ IncomingClass);
		if(R_RunePlayer(P) != None)
		{
			R_RunePlayer(P).ApplySubClass(class<RunePlayer>(IncomingClass));
		}
	}
	else if(class<Spectator>(IncomingClass) != None)
	{
		// Destroy PRI for messaging spectators (webadmin spectator)
		if(class<MessagingSpectator>(IncomingClass) != None)
		{
			P.PlayerReplicationInfo.Destroy();
		}
		
		UtilitiesClass.Static.RModLog("Incoming spectator class: " $ IncomingClass);
		if(R_RunePlayer(P) != None)
		{
			R_RunePlayer(P).ApplySubClass(Self.SpectatorMarkerClass);
		}
	}
	
	return P;
}

event PostLogin(PlayerPawn NewPlayer)
{
	Super.PostLogin(NewPlayer);
	
	// Take care of incoming spectators
	if(R_RunePlayer(NewPlayer) != None)
	{
		if(R_RunePlayer(NewPlayer).RunePlayerSubClass == SpectatorMarkerClass)
		{
			MakePlayerSpectate(R_RunePlayer(NewPlayer));
		}
	}
}

event Logout(Pawn P)
{
	// Do not logout the dummy pawns used for copying
	if(class'RMod.R_RunePlayer'.Static.CheckForDummyTag(P))
	{
		return;
	}
	
	Super.Logout(P);
}

event bool IsRelevant(Actor A)
{
	local Vector Loc;
	local Rotator Rot;
	
	if(!Super.IsRelevant(A))
	{
		return false;
	}
	
	// Mark for native level
	if(bMarkSpawnedActorsAsNativeToLevel)
	{
		MarkActorAsNativeToLevel(A);
	}
	else
	{
		MarkActorAsNotNativeToLevel(A);
	}
	
	return true;
}

function bool ChangeTeam(Pawn Other, int N)
{
	if(Other.PlayerReplicationInfo == None
	|| Other.PlayerReplicationInfo.bIsSpectator
	|| Other.GetStateName() == 'PlayerSpectating')
	{
		return false;
	}
	
	Other.PlayerReplicationInfo.Team = N;
	if (LocalLog != None)
		LocalLog.LogTeamChange(Other);
	if (WorldLog != None)
		WorldLog.LogTeamChange(Other);
	return true;
}

function ScoreKill(Pawn Killer, Pawn Other)
{
    if (Other==None)
    {
        log("Warning: ScoreKill (OTHER==NONE): Killer="$Killer@"Other="$Other);
        return;
    }

    Other.DieCount++;
    if (Other.bIsPlayer && Other.PlayerReplicationInfo != None)
	{
        Other.PlayerReplicationInfo.Deaths +=1;
	}

    if( (Killer == Other) || (Killer == None) )
    {
        if (Other.PlayerReplicationInfo != None)
		{
            Other.PlayerReplicationInfo.Score -= 1;
		}
	}
    else if ( Killer != None )
    {
		if(bTeamGame && Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team)
		{
			Killer.PlayerReplicationInfo.Score -= 1;
		}
		else
		{
			Killer.killCount++;
			if ( Killer.PlayerReplicationInfo != None )
			{
				Killer.PlayerReplicationInfo.Score += 1;
			}
		}
	}
    BaseMutator.ScoreKill(Killer, Other);
}

function MakePlayerSpectate(R_RunePlayer P)
{
	P.GoToState('PlayerSpectating');
	P.PlayerReplicationInfo.Team = 255;
}

function RequestSpectate(R_RunePlayer P)
{
	MakePlayerSpectate(P);
}

function bool SetEndCams(string Reason)
{
	local pawn aPawn;

	for ( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if ( aPawn.bIsPlayer )
		{
			if(!(aPawn.GetStateName() == 'PlayerSpectating'
			|| (aPawn.PlayerReplicationInfo != None && aPawn.PlayerReplicationInfo.bIsSpectator)))
			{
				aPawn.GotoState('GameEnded');
			}
			aPawn.ClientGameEnded();
		}	

	return true;
}

defaultproperties
{
     RunePlayerClass=Class'RMod.R_RunePlayer'
     SpectatorMarkerClass=Class'RMod.R_ASpectatorMarker'
     PlayerReplicationInfoClass=Class'RMod.R_PlayerReplicationInfo'
     GamePresetsClass=Class'RMod.R_GamePresets'
     UtilitiesClass=Class'RMod.R_AUtilities'
     bMarkSpawnedActorsAsNativeToLevel=True
     bRModEnabled=True
     ScoreBoardType=Class'RMod.R_Scoreboard'
     HUDType=Class'RMod.R_RunePlayerHUD'
	 HUDTypeSpectator=Class'RMod.R_RunePlayerHUDSpectator'
     GameReplicationInfoClass=Class'RMod.R_GameReplicationInfo'
	 bAllowSpectatorBroadcastMessage=false
}
