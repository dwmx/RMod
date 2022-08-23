//=============================================================================
// RuneMultiPlayer.
//=============================================================================
class RuneMultiPlayer extends RuneGameInfo;

var() globalconfig int	FragLimit;
var() globalconfig int	TimeLimit; // time limit in minutes
//var() globalconfig bool	bMultiPlayerBots;
var() globalconfig bool bChangeLevels;
var() globalconfig bool bHardCoreMode;
var() globalconfig bool bMegaSpeed;

var bool	bDontRestart;
var bool	bAlreadyChanged;
var bool	bFirstBlood;
var int		RemainingTime;

// Bot related info
//var   int			NumBots;
//var	int			RemainingBots;
//var() globalconfig int	InitialBots;
//var		BotInfo		BotConfig;
//var class<BotInfo> BotConfigType;

var localized string GlobalNameChange;
var localized string NoNameChange;
var localized string TimeMessage[16];
var localized string GlobalNameChangeTrailer;
var localized string FirstBloodMsg;
var localized string SpreeMsg;
var localized string SpreeEndMsg;
var localized string SpreeEndTrailer;
var localized string HeadKillMsg;

// Damage specific death messages
var localized string CrushedMessage;
var localized string DrownedMessage;
var localized string FellMessage;
var localized string ThrownMessage;
var localized string NormalMessage;
var localized string FireMessage;
var localized string HeadMessage;
var localized string SuicidedMessage;

var NavigationPoint LastStartSpot;

var bool bLevelHasTeamOnly;			//Keeps track of if level has team-only PlayerStarts


function PostBeginPlay()
{
	local string NextPlayerClass;
	local int i;
	local NavigationPoint N;

//	BotConfig = spawn(BotConfigType);
	RemainingTime = 60 * TimeLimit;
//	if ( (Level.NetMode == NM_Standalone) || bMultiPlayerBots )
//		RemainingBots = InitialBots;
	Super.PostBeginPlay();

	GameReplicationInfo.RemainingTime = RemainingTime;

	//Addition to allow TEAM-based maps to also be used correctly in regular DM
	for(N = Level.NavigationPointList; N != None; N = N.nextNavigationPoint)
	{
		if(N.IsA('PlayerStart') && PlayerStart(N).bTeamOnly)
		{
			bLevelHasTeamOnly = true;
			return;
		}
	}
}

function PreCacheReferences()
{	// Never called - here to force precaching of meshes
//	spawn(class'ragnarsnow');
}

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
	if ( !bTeamGame && (ParseString ~= "Team") )
		return 255;

	return Super.GetIntOption(Options, ParseString, CurrentValue);
}

function bool IsRelevant(actor Other) 
{
	if ( bMegaSpeed && Other.IsA('Pawn') && Pawn(Other).bIsPlayer )
	{
		Pawn(Other).GroundSpeed *= 1.5;
		Pawn(Other).WaterSpeed *= 1.5;
		Pawn(Other).AirSpeed *= 1.5;
		Pawn(Other).Acceleration *= 1.5;
	}
	return Super.IsRelevant(Other);
}

function LogGameParameters(StatLog StatLog)
{
	if (StatLog == None)
		return;
	
	Super.LogGameParameters(StatLog);

	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"FragLimit"$Chr(9)$FragLimit);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"TimeLimit"$Chr(9)$TimeLimit);
//	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MultiPlayerBots"$Chr(9)$bMultiPlayerBots);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"HardCore"$Chr(9)$bHardCoreMode);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MegaSpeed"$Chr(9)$bMegaSpeed);
}

function float PlayerJumpZScaling()
{
//	if ( bHardCoreMode )
//		return 1.1;
//	else
		return 1.0;
}

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
	GameSpeed = FMax(T, 0.1);
	Level.TimeDilation = GameSpeed;
	SetTimer(Level.TimeDilation, true);
}

event InitGame( string Options, out string Error )
{
	local string InOpt;

	Super.InitGame(Options, Error);

	FragLimit = GetIntOption( Options, "FragLimit", FragLimit );
	TimeLimit = GetIntOption( Options, "TimeLimit", TimeLimit );

	InOpt = ParseOption( Options, "CoopWeaponMode");
	if ( InOpt != "" )
	{
		log("CoopWeaponMode "$bool(InOpt));
		bCoopWeaponMode = bool(InOpt);
	}
}

//------------------------------------------------------------------------------
// Game Querying.

function string GetRules()
{
	local string ResultSet;
	ResultSet = Super.GetRules();

	// Timelimit.
	ResultSet = ResultSet$"\\timelimit\\"$TimeLimit;
		
	// Fraglimit
	ResultSet = ResultSet$"\\fraglimit\\"$FragLimit;
		
/*	// Bots in Multiplay
	if( bMultiplayerBots )
		Resultset = ResultSet$"\\MultiplayerBots\\"$true;
	else
		Resultset = ResultSet$"\\MultiplayerBots\\"$false;
*/

	// Change levels?
	if( bChangeLevels )
		Resultset = ResultSet$"\\ChangeLevels\\"$true;
	else
		Resultset = ResultSet$"\\ChangeLevels\\"$false;

	return ResultSet;
}

function ReduceDamage(out int BluntDamage, out int SeverDamage, name DamageType, pawn injured, pawn instigatedBy)
{
	if (injured.Region.Zone.bNeutralZone)
	{
		BluntDamage = 0;
		SeverDamage = 0;
	}
	else if (injured.bIsPlayer)
	{
		if ( bHardCoreMode )
		{
			BluntDamage *= 1.5;
			SeverDamage *= 1.5;
		}

		if (injured.ReducedDamageType=='All')
		{	// God Mode
			BluntDamage = 0;
			SeverDamage = 0;
		}
		else if (injured.ReducedDamageType=='conventional')
		{	// Spirit
			if (DamageType=='blunt' || DamageType=='thrownweaponblunt' ||
				DamageType=='sever' || DamageType=='thrownweaponsever' ||
				DamageType=='bluntsever' || DamageType=='thrownweaponbluntsever')
			{
				BluntDamage = float(BluntDamage) * (1 - injured.ReducedDamagePct);
				SeverDamage = float(SeverDamage) * (1 - injured.ReducedDamagePct);
			}
		}
		else if (injured.Inventory != None)
		{	//then check if carrying armor
			injured.Inventory.ReduceDamage(BluntDamage, SeverDamage, DamageType, injured.Location);
		}
	}

	if ( instigatedBy == None)
		return;

	BluntDamage *= instigatedBy.DamageScaling;
	SeverDamage *= instigatedBy.DamageScaling;
}

function float PlaySpawnEffect(inventory Inv)
{
	spawn( class 'RespawnFire',,, Inv.Location );
	return 0.3;
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
	local actor PTE;

	if ( Incoming.bIsPawn && (Incoming.Skeletal != None) )
	{
		if ( bSound )
		{
 			PTE = spawn(class'RespawnFire',Incoming,, Incoming.Location, Incoming.Rotation);
//			PTE.Initialize(Pawn(Incoming), bOut);
			PTE.PlaySound(Sound'OtherSnd.Respawns.respawn02',, 10.0);
		}
	}
}

function RestartGame()
{
	local string NextMap;
	local MapList myList;

	// multipurpose don't restart variable
	if ( bDontRestart )
		return;

	log("Restart Game");

	// these server travels should all be relative to the current URL
	if ( bChangeLevels && !bAlreadyChanged && (MapListType != None) )
	{
		// open a the nextmap actor for this game type and get the next map
		bAlreadyChanged = true;
		myList = spawn(MapListType);
		NextMap = myList.GetNextMap();
		myList.Destroy();
		if ( NextMap == "" )
			NextMap = GetMapName(MapPrefix, NextMap,1);
		if ( NextMap != "" )
		{
			log("Changing to "$NextMap);
			Level.ServerTravel(NextMap, false);
			return;
		}
	}

	Level.ServerTravel("?Restart" , false);
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local playerpawn NewPlayer;

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass );
	if ( NewPlayer != None )
	{
		if ( Left(NewPlayer.PlayerReplicationInfo.PlayerName, 6) == DefaultPlayerName )
			ChangeName( NewPlayer, (DefaultPlayerName$NumPlayers), false );
		NewPlayer.bAutoActivate = true;
	}

	return NewPlayer;
}

function bool AddBot()
{
/*	local NavigationPoint StartSpot;
	local bots NewBot;
	local int BotN;

	Difficulty = BotConfig.Difficulty;
	BotN = BotConfig.ChooseBotInfo();
	
	// Find a start spot.
	StartSpot = FindPlayerStart(None, 255);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return false;
	}

	// Try to spawn the player.
	NewBot = Spawn(BotConfig.GetBotClass(BotN),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot == None )
		return false;

	if ( (bHumansOnly || Level.bHumansOnly) && !NewBot.bIsHuman )
	{
		NewBot.Destroy();
		log("Failed to spawn bot");
		return false;
	}

	StartSpot.PlayTeleportEffect(NewBot, true);

	// Init player's information.
	BotConfig.Individualize(NewBot, BotN, NumBots);
	NewBot.ViewRotation = StartSpot.Rotation;

	// broadcast a welcome message.
	BroadcastMessage( NewBot.PlayerReplicationInfo.PlayerName$EnteredMessage, true );

	AddDefaultInventory( NewBot );
	NumBots++;

	NewBot.PlayerReplicationInfo.bIsABot = True;

	// Set the player's ID.
	NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;

	// Log it.
	if (LocalLog != None)
		LocalLog.LogPlayerConnect(NewBot);
	if (WorldLog != None)
		WorldLog.LogPlayerConnect(NewBot);
*/
	return true;
}

function Logout(pawn Exiting)
{
	Super.Logout(Exiting);
//	if ( Exiting.IsA('Bots') )
//		NumBots--;
}

function SendCountdownMessage()
{
/* Could use BroadCastEvent() to send a Voice Message
	switch (RemainingTime)
	{
		case 300:
			BroadcastMessage(TimeMessage[0], True, 'CriticalEvent');
			break;
		case 240:
			BroadcastMessage(TimeMessage[1], True, 'CriticalEvent');
			break;
		case 180:
			BroadcastMessage(TimeMessage[2], True, 'CriticalEvent');
			break;
		case 120:
			BroadcastMessage(TimeMessage[3], True, 'CriticalEvent');
			break;
		case 60:
			BroadcastMessage(TimeMessage[4], True, 'CriticalEvent');
			break;
		case 30:
			BroadcastMessage(TimeMessage[5], True, 'CriticalEvent');
			break;
		case 10:
			BroadcastMessage(TimeMessage[6], True, 'CriticalEvent');
			break;
		case 5:
			BroadcastMessage(TimeMessage[7], True, 'CriticalEvent');
			break;
		case 4:
			BroadcastMessage(TimeMessage[8], True, 'CriticalEvent');
			break;
		case 3:
			BroadcastMessage(TimeMessage[9], True, 'CriticalEvent');
			break;
		case 2:
			BroadcastMessage(TimeMessage[10], True, 'CriticalEvent');
			break;
		case 1:
			BroadcastMessage(TimeMessage[11], True, 'CriticalEvent');
			break;
		case 0:
			BroadcastMessage(TimeMessage[12], True, 'CriticalEvent');
			break;
	}
*/
}

function Timer()
{
	Super.Timer();

	if ( bGameEnded )
	{
		RemainingTime--;
		if ( RemainingTime < -7 )
			RestartGame();
	}
	else if ( TimeLimit > 0 )
	{
		RemainingTime--;
		GameReplicationInfo.RemainingTime = RemainingTime;
		if (RemainingTime % 60 == 0)
			GameReplicationInfo.RemainingMinute = RemainingTime;
		SendCountdownMessage();
		if ( RemainingTime <= 0 )
			EndGame("timelimit");
	}
}

/* FindPlayerStart()
returns the 'best' player start for this player to start from.
Re-implement for each game type
*/
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest, Candidate[4], Best;
	local float Score[4], BestScore, NextDist;
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
		if ( N.IsA('PlayerStart') && !N.Region.Zone.bWaterZone )
		{
			if(bLevelHasTeamOnly)
			{
				if((PlayerStart(N).bTeamOnly && bTeamGame) || (!PlayerStart(N).bTeamOnly && !bTeamGame))
				{
					if(num < 4)
						Candidate[num] = PlayerStart(N);
					else if(Rand(num) < 4)
						Candidate[Rand(4)] = PlayerStart(N);
					num++;
				}
			}
			else
			{
				if (num<4)
					Candidate[num] = PlayerStart(N);
				else if (Rand(num) < 4)
					Candidate[Rand(4)] = PlayerStart(N);
				num++;
			}
		}
		N = N.nextNavigationPoint;
	}

	if (num == 0 )
		foreach AllActors( class 'PlayerStart', Dest )
		{
			if (num<4)
				Candidate[num] = Dest;
			else if (Rand(num) < 4)
				Candidate[Rand(4)] = Dest;
			num++;
		}

	if (num>4) num = 4;
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

/* AcceptInventory()
Examine the passed player's inventory, and accept or discard each item
* AcceptInventory needs to gracefully handle the case of some inventory
being accepted but other inventory not being accepted (such as the default
weapon).  There are several things that can go wrong: A weapon's
AmmoType not being accepted but the weapon being accepted -- the weapon
should be killed off. Or the player's selected inventory item, active
weapon, etc. not being accepted, leaving the player weaponless or leaving
the HUD inventory rendering messed up (AcceptInventory should pick another
applicable weapon/item as current).
*/
function AcceptInventory(pawn PlayerPawn)
{
	//deathmatch accepts no inventory
	local inventory Inv;
	local inventory next;

	for( Inv=PlayerPawn.Inventory; Inv!=None; Inv = next )
	{
		next = Inv.Inventory;
		Inv.Destroy();
	}
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
	AddDefaultInventory( PlayerPawn );
}

function ChangeName( Pawn Other, coerce string S, bool bNameChange )
{
	local pawn APlayer;

	if ( S == "" )
		return;

	if (Other.PlayerReplicationInfo.PlayerName~=S)
		return;
	
	APlayer = Level.PawnList;
	
	While ( APlayer != None )
	{	
		if ( APlayer.bIsPlayer && (APlayer.PlayerReplicationInfo.PlayerName~=S) )
		{
			Other.ClientMessage(S$NoNameChange);
			return;
		}
		APlayer = APlayer.NextPawn;
	}

	if (bNameChange)
		BroadcastMessage(Other.PlayerReplicationInfo.PlayerName$GlobalNameChange$S$GlobalNameChangeTrailer, false);
			
	Other.PlayerReplicationInfo.PlayerName = S;

	if (LocalLog != None)
		LocalLog.LogNameChange(Other);
	if (WorldLog != None)
		WorldLog.LogNameChange(Other);
}

function bool ShouldRespawn(Actor Other)
{
	return ( (Inventory(Other) != None) && (Inventory(Other).ReSpawnTime!=0.0) );
}

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return ( (Level.NetMode == NM_Standalone) || (Spectator(Viewer) != None) );
}

function NotifySpree(Pawn Killer, int num)
{
	Killer.PlayerReplicationInfo.MaxSpree = Max(num, Killer.PlayerReplicationInfo.MaxSpree);
	BroadcastMessage(num@SpreeMsg@Killer.PlayerReplicationInfo.PlayerName, false );
}

function EndSpree(Pawn Killer, Pawn Other)
{
	if ( !Other.bIsPlayer )
		return;

	if ( (Killer != None) && Killer.bIsPlayer )
		BroadcastMessage(Killer.PlayerReplicationInfo.PlayerName@ SpreeEndMsg @Other.PlayerReplicationInfo.PlayerName$SpreeEndTrailer, false );
}

// Monitor killed messages for fraglimit
function Killed(pawn killer, pawn Other, name damageType)
{
	Super.Killed(killer, Other, damageType);

	// Clear spree for victim
	if (Other.Spree > 2)
		EndSpree(Killer, Other);
	Other.Spree = 0;

	// Suicides don't count
	if ( (killer == None) || (Other == None) )
		return;

	// Handle decapitation
	if ( damageType == 'decapitated' && Killer.bIsPlayer && (Killer != Other))
	{
		Killer.PlayerReplicationInfo.HeadKills++;
		BroadcastMessage(Killer.PlayerReplicationInfo.PlayerName@HeadKillMsg, false );
	}

	// Handle first blood
	if ( !bFirstBlood )
	{
		if ( Killer.bIsPlayer && (Killer != Other) )
		{
			bFirstBlood = true;
			Killer.PlayerReplicationInfo.bFirstBlood = true;
			BroadcastMessage(Killer.PlayerReplicationInfo.PlayerName@FirstBloodMsg, false );
		}
	}

	// Handle sprees
	if ( Other.bIsPlayer && (Killer != None) && Killer.bIsPlayer && (Killer != Other) 
		&& (!bTeamGame || (Other.PlayerReplicationInfo.Team != Killer.PlayerReplicationInfo.Team)) )
	{
		Killer.Spree++;
		if ( Killer.Spree > 2 )
			NotifySpree(Killer, Killer.Spree);
	} 

	// Check for frag limit
	if ( !bTeamGame && (FragLimit > 0) && (killer.PlayerReplicationInfo.Score >= FragLimit) )
		EndGame("fraglimit");
}	

function EndGame( string Reason )
{
	local actor A;
	local pawn aPawn;

	Super.EndGame(Reason);

	GameReplicationInfo.GameEndedComments = Reason;
	GameReplicationInfo.bStopCountdown = true;

	bGameEnded = true;
	aPawn = Level.PawnList;
	RemainingTime = -1; // use timer to force restart
}

static function string KillMessage( name damageType, pawn killer )
{
	if (killer == None)
	{
		switch(damageType)
		{
			case 'suicided':
				return default.SuicidedMessage;
			case 'crushed':
				return default.CrushedMessage;
			case 'fell':
				return default.FellMessage;
		}
		return default.SuicidedMessage;
	}

	switch(damageType)
	{
		case 'drowned':
			return default.DrownedMessage;
		case 'thrownweaponblunt':
		case 'thrownweaponsever':
		case 'thrownweaponbluntsever':
			return default.ThrownMessage;
		case 'blunt':
		case 'sever':
		case 'bluntsever':
		case 'gibbed':
			return default.NormalMessage;
		case 'fire':
		case 'electricity':
			return default.FireMessage;
		case 'decapitated':
			return default.HeadMessage;
	}
	return default.NormalMessage;
}

simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);

	Canvas.DrawText("RuneMultiPlayer:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  FragLimit:       " $ FragLimit);
	Canvas.CurY -= 8;
	Canvas.DrawText("  TimeLimit:       " $ TimeLimit);
	Canvas.CurY -= 8;
	Canvas.DrawText("  RemainingTime:   " $ RemainingTime);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bChangeLevels:   " $ bChangeLevels);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bHardCoreMode:   " $ bHardCoreMode);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bMegaSpeed:      " $ bMegaSpeed);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bDontRestart:    " $ bDontRestart);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bAlreadyChanged: " $ bAlreadyChanged);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bFirstBlood:     " $ bFirstBlood);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bLevelHasTeamOnly: " $ bLevelHasTeamOnly);
	Canvas.CurY -= 8;
}

defaultproperties
{
     bChangeLevels=True
     bHardCoreMode=True
     GlobalNameChange=" changed name to "
     NoNameChange=" is already in use"
     TimeMessage(0)="5 minutes left in the game!"
     TimeMessage(1)="4 minutes left in the game!"
     TimeMessage(2)="3 minutes left in the game!"
     TimeMessage(3)="2 minutes left in the game!"
     TimeMessage(4)="1 minute left in the game!"
     TimeMessage(5)="30 seconds left!"
     TimeMessage(6)="10 seconds left!"
     TimeMessage(7)="5 seconds and counting..."
     TimeMessage(8)="4..."
     TimeMessage(9)="3..."
     TimeMessage(10)="2..."
     TimeMessage(11)="1..."
     TimeMessage(12)="Time Up!"
     FirstBloodMsg="drew FIRST BLOOD"
     SpreeMsg="in a row for"
     SpreeEndMsg="stopped"
     SpreeEndTrailer="'s killing spree."
     HeadKillMsg=" took a trophy."
     CrushedMessage=" was crushed."
     DrownedMessage="%o got a mouthful."
     FellMessage=" suffered deceleration trauma."
     ThrownMessage="%o got skewered by %k."
     NormalMessage="%o was whacked up by %k."
     FireMessage="%o got smoked by %k."
     HeadMessage="%o died by %k's blade."
     SuicidedMessage=" died."
     bRestartLevel=False
     bPauseable=False
     bDeathMatch=True
     DefaultWeapon=Class'RuneI.handaxe'
     ScoreBoardType=Class'RuneI.RuneScoreboard'
     RulesMenuType="RMenu.RuneMenuRulesScrollClient"
     SettingsMenuType="RMenu.RuneMenuSettingsScrollClient"
     MutatorMenuType="RMenu.RuneMenuMutatorScrollClient"
     MaplistMenuType="RMenu.RuneMenuMaplistScrollClient"
     GameUMenuType="RMenu.RuneMenu"
     MultiplayerUMenuType="RMenu.RuneMenuMultiplayerTop"
     GameOptionsMenuType="RMenu.RuneMenuOptionsTop"
     MapListType=Class'RuneI.DMmaplist'
     MapPrefix="DM"
     BeaconName="DM"
     GameName="RuneMatch"
}
