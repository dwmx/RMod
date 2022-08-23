//=============================================================================
// GameInfo.
//
// default game info is normal single player
//
//=============================================================================
class GameInfo extends Info
	native;

//-----------------------------------------------------------------------------
// Variables.

var int ItemGoals, KillGoals, SecretGoals;				// Special game goals.
var byte  Difficulty;									// 0=easy, 1=medium, 2=hard, 3=very hard.
var() config bool   		  bNoMonsters;				// Whether monsters are allowed in this play mode.
var() globalconfig bool		  bMuteSpectators;			// Whether spectators are allowed to speak.
var() config bool			  bHumansOnly;				// Whether non human player models are allowed.
var() bool				      bRestartLevel;	
var() bool				      bPauseable;				// Whether the level is pauseable.
var() config bool			  bCoopWeaponMode;			// Whether or not weapons stay when picked up.
var() config bool			  bClassicDeathmessages;	// Weapon deathmessages if false.
var   globalconfig bool	      bLowGore;					// Whether or not to reduce gore.
var	  bool				      bCanChangeSkin;			// Allow player to change skins in game.
var() bool				      bTeamGame;				// This is a teamgame.
var	  globalconfig bool	      bVeryLowGore;				// Greatly reduces gore.
var() globalconfig bool       bNoCheating;				// Disallows cheating. Hehe.
var() globalconfig bool       bAllowFOV;				// Allows FOV changes in net games
var() bool					  bDeathMatch;				// This game is some type of deathmatch (where players can respawn during gameplay)
var	  bool					  bGameEnded;				// set when game ends
var	  bool					  bOverTime;
var localized bool			  bAlternateMode;
var		bool				  bCanViewOthers;
var() bool					  bAllowWeaponDrop;			// RUNE: Allow weapons to be dropped after death
var() bool					  bAllowShieldDrop;			// RUNE: Allow shields to be dropped after death
var() globalconfig bool		  bAutoPickup;				// RUNE: Autopickup inventory items


var() globalconfig float	  AutoAim;					// How much autoaiming to do (1 = none, 0 = always).
														// (cosine of max error to correct)

var() globalconfig float	  GameSpeed;				// Scale applied to game rate.
var   float                   StartTime;

var() class<playerpawn>       DefaultPlayerClass;
var() class<weapon>           DefaultWeapon;			// Default weapon given to player at start.
var() class<shield>			  DefaultShield;			// Default shield given to player at start

var() globalconfig int	      MaxSpectators;			// Maximum number of spectators.
var	  int					  NumSpectators;			// Current number of spectators.

var() private globalconfig string AdminPassword;	    // Password to receive bAdmin privileges.
var() private globalconfig string GamePassword;		    // Password to enter game.

var() class<scoreboard>		  ScoreBoardType;			// Type of scoreboard this game uses.
var() class<menu>			  GameMenuType;				// Type of oldstyle game options menu to display.
var() string			      BotMenuType;				// Type of bot menu to display.
var() string			      RulesMenuType;			// Type of rules menu to display.
var() string				  SettingsMenuType;			// Type of settings menu to display.
var() string                  MutatorMenuType;			// Type of mutator menu to display
var() string                  MaplistMenuType;			// Type of maplist menu to display
var() string				  GameUMenuType;			// Type of Game dropdown to display.
var() string				  MultiplayerUMenuType;		// Type of Multiplayer dropdown to display.
var() string				  GameOptionsMenuType;		// Type of options dropdown to display.

var() class<hud>			  HUDType;					// HUD class this game uses.
var() class<MapList>		  MapListType;				// Maplist this game uses.
var() string			      MapPrefix;				// Prefix characters for names of maps for this game type.
var() string			      BeaconName;				// Identifying string used for finding LAN servers.
var() string			      SpecialDamageString;
var localized string	      SwitchLevelMessage;
var	int					      SentText;
var localized string	      DefaultPlayerName;
var localized string	      LeftMessage;
var localized string	      FailedSpawnMessage;
var localized string	      FailedPlaceMessage;
var localized string	      FailedTeamMessage;
var localized string	      NameChangedMessage;
var localized string	      EnteredMessage;
var localized string	      GameName;
var	localized string	      MaxedOutMessage;
var	localized string	      WrongPassword;
var	localized string          NeedPassword;
var	localized string          IPBanned;

var() globalconfig int		  MaxPlayers; 
var   int					  NumPlayers;
var   int					  CurrentID;
var() globalconfig string     IPPolicies[50];

// Message classes.
var class<LocalMessage>		  DeathMessageClass;
var class<LocalMessage>		  DMMessageClass;

// Mutator (for modifying actors as they enter the game)
var class<Mutator> MutatorClass;
var Mutator BaseMutator;
var Mutator DamageMutator;	// linked list of mutators which affect damage

// Default waterzone entry and exit effects
var class<ZoneInfo> WaterZoneType;

// What state a player should start in for this game type
var name DefaultPlayerState;

// ReplicationInfo
var() class<GameReplicationInfo> GameReplicationInfoClass;
var GameReplicationInfo GameReplicationInfo;

// Server Log
var globalconfig string         ServerLogName;

// Statistics Logging
var StatLog						LocalLog;
var StatLog						WorldLog;
var globalconfig bool			bLocalLog;
var globalconfig bool			bWorldLog;
var globalconfig bool			bBatchLocal;
var globalconfig bool			bSubtitles;		// display subtitles
var bool						bLoggingGame;			// Does this gametype log?
var string					    LocalLogFileName;
var string					    WorldLogFileName;
var class<StatLog>				StatLogClass;

// Demo Information
var globalconfig int DemoBuild;
var globalconfig int DemoHasTuts;

var globalconfig float DebrisPercentage;		// Percentage of normal debris spawned
var globalconfig float ParticlePercentage;		// Percentage of nomral particles spawned

var() config bool bAllowLimbSever;		//RUNE: Allow arms to be chopped-off

//=============================================================================
// [RMod]
// RMod variables
var bool bAllowHeadSever;			// Whether or not decapitations can happen
var bool bShieldHitStun;			// If true, shield hits cause hit-stun
var bool bShieldTakesAllHits;		// It true, shields act as armor
var float FriendlyFireMultiplier;	// In team games, the team damage multiplier
//=============================================================================

//------------------------------------------------------------------------------
// Admin

function AdminLogin( PlayerPawn P, string Password )
{
	if (AdminPassword == "")
		return;

	if (Password == AdminPassword)
	{
		P.bAdmin = True;
		P.PlayerReplicationInfo.bAdmin = P.bAdmin;
		Log("Administrator logged in.");
		BroadcastMessage( P.PlayerReplicationInfo.PlayerName@"became a server administrator." );
	}
}

function AdminLogout( PlayerPawn P )
{
	if (AdminPassword == "")
		return;

	if (P.bAdmin)
	{
		P.bAdmin = False;
		P.PlayerReplicationInfo.bAdmin = P.bAdmin;
		Log("Administrator logged out.");
		BroadcastMessage( P.PlayerReplicationInfo.PlayerName@"gave up administrator abilities." );
	}
}

//------------------------------------------------------------------------------
// Engine notifications.

function PreBeginPlay()
{
	StartTime = 0;
	SetGameSpeed(GameSpeed);
	Level.bNoCheating = bNoCheating;
	Level.bAllowFOV = bAllowFOV;
	
	if (GameReplicationInfoClass != None)
		GameReplicationInfo = Spawn(GameReplicationInfoClass);
	else
		GameReplicationInfo = Spawn(class'GameReplicationInfo');
	InitGameReplicationInfo();
}

function PostBeginPlay()
{
	local ZoneInfo W;

	if ( bAlternateMode )
	{
		bLowGore = true;
		bVeryLowGore = true;
	}

	if ( bVeryLowGore )
		bLowGore = true;

	if ( WaterZoneType != None )
	{
		ForEach AllActors(class'ZoneInfo', W )
			if ( W.bWaterZone )
			{
				if( W.EntryActor == None )
					W.EntryActor = WaterZoneType.Default.EntryActor;
				if( W.ExitActor == None )
					W.ExitActor = WaterZoneType.Default.ExitActor;
				if( W.EntrySound == None )
					W.EntrySound = WaterZoneType.Default.EntrySound;
				if( W.ExitSound == None )
					W.ExitSound = WaterZoneType.Default.ExitSound;
			}
	}

	// Setup local statistics logging.
	InitLogging();

	Super.PostBeginPlay();
}

function InitLogging()
{
	local Mutator M;

	if (bLocalLog && bLoggingGame)
	{
		Log("Initiating local logging...");
		LocalLog = spawn(StatLogClass);
		LocalLog.bWorld = False;
		LocalLog.StartLog();
		LocalLog.LogStandardInfo();
		LocalLog.LogServerInfo();
		LocalLog.LogMapParameters();
		for (M = BaseMutator; M != None; M = M.NextMutator)
			LocalLog.LogMutator(M);
		LogGameParameters(LocalLog);
		LocalLogFileName = LocalLog.GetLogFileName();
	}

	// Setup world statistics logging.
	if ((Level.NetMode != NM_DedicatedServer) && (Level.NetMode != NM_ListenServer))
		return;

	if (bWorldLog && bLoggingGame)
	{
		Log("Initiating world logging...");
		WorldLog = spawn(StatLogClass);
		WorldLog.bWorld = True;
		WorldLog.StartLog();
		WorldLog.LogStandardInfo();
		WorldLog.LogServerInfo();
		WorldLog.LogMapParameters();
		WorldLog.InitialCheck(Self);
		for (M = BaseMutator; M != None; M = M.NextMutator)
			WorldLog.LogMutator(M);
		LogGameParameters(WorldLog);
		WorldLogFileName = WorldLog.GetLogFileName();
	}
}

function Timer()
{
	SentText = 0;
}

// Called when game shutsdown.
event GameEnding()
{
	if (LocalLog != None)
	{
		LocalLog.LogGameEnd("serverquit");
		LocalLog.StopLog();
		LocalLog.Destroy();
		LocalLog = None;
	}

	if (WorldLog != None)
	{
		WorldLog.LogGameEnd("serverquit");
		WorldLog.StopLog();
		WorldLog.Destroy();
		WorldLog = None;
	}
}

//------------------------------------------------------------------------------
// Replication

function InitGameReplicationInfo()
{
	GameReplicationInfo.bTeamGame = bTeamGame;
	GameReplicationInfo.GameName = GameName;
	GameReplicationInfo.GameClass = string(Class);
	GameReplicationInfo.bClassicDeathmessages = bClassicDeathmessages;
}

native function string GetNetworkNumber();

//------------------------------------------------------------------------------
// Game Querying.

function string GetInfo()
{
	local string ResultSet;

	// World logging
	if (WorldLog != None)
		ResultSet = "\\worldlog\\true";
	else
		ResultSet = "\\worldlog\\false";

	return ResultSet;
}

function string GetRules()
{
	local string ResultSet;
	local Mutator M;
	local string NextMutator, NextDesc;
	local string EnabledMutators;
	local int Num, i;

	ResultSet = "";

	EnabledMutators = "";
	for (M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
	{
		Num = 0;
		NextMutator = "";
		GetNextIntDesc("Engine.Mutator", 0, NextMutator, NextDesc);
		while( (NextMutator != "") && (Num < 50) )
		{
			if(NextMutator ~= string(M.Class))
			{
				i = InStr(NextDesc, ",");
				if(i != -1)
					NextDesc = Left(NextDesc, i);

				if(EnabledMutators != "")
					EnabledMutators = EnabledMutators $ ", ";
				 EnabledMutators = EnabledMutators $ NextDesc;
				 break;
			}
			
			Num++;
			GetNextIntDesc("Engine.Mutator", Num, NextMutator, NextDesc);
		}
	}
	if(EnabledMutators != "")
		ResultSet = ResultSet $ "\\mutators\\"$EnabledMutators;

	ResultSet = ResultSet $ "\\listenserver\\"$string(Level.NetMode==NM_ListenServer);

	// Add gamespeed
	ResultSet = ResultSet $ "\\gamespeed\\"$int(Level.TimeDilation*100)$"%";

	// Add autopickup
	ResultSet = ResultSet $ "\\autopickup\\"$string(bAutoPickup);

	return ResultSet;
}

// Return the server's port number.
function int GetServerPort()
{
	local string S;
	local int i;

	// Figure out the server's port.
	S = Level.GetAddressURL();
	i = InStr( S, ":" );
	assert(i>=0);
	return int(Mid(S,i+1));
}

function bool SetPause( BOOL bPause, PlayerPawn P )
{
	if( bPauseable || P.bAdmin || Level.Netmode==NM_Standalone )
	{
		if( bPause )
			Level.Pauser=P.PlayerReplicationInfo.PlayerName;
		else
			Level.Pauser="";
		return True;
	}
	else return False;
}

//------------------------------------------------------------------------------
// Stat Logging.

function LogGameParameters(StatLog StatLog)
{
	if (StatLog == None)
		return;

	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameName"$Chr(9)$GameName);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NoMonsters"$Chr(9)$bNoMonsters);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NoMonsters"$Chr(9)$bNoMonsters);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MuteSpectators"$Chr(9)$bMuteSpectators);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"HumansOnly"$Chr(9)$bHumansOnly);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"WeaponsStay"$Chr(9)$bCoopWeaponMode);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"ClassicDeathmessages"$Chr(9)$bClassicDeathmessages);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"LowGore"$Chr(9)$bLowGore);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"VeryLowGore"$Chr(9)$bVeryLowGore);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"TeamGame"$Chr(9)$bTeamGame);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameSpeed"$Chr(9)$int(GameSpeed*100));
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MaxSpectators"$Chr(9)$MaxSpectators);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MaxPlayers"$Chr(9)$MaxPlayers);
}

//------------------------------------------------------------------------------
// Game parameters.

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
//	GameSpeed = FMax(T, 0.1);	// RUNE: Not enforced for debugging
	if (T==0) T=0.1;
	GameSpeed = FMax(T, 0.001);
	Level.TimeDilation = GameSpeed;
	SetTimer(Level.TimeDilation, true);
}

static function ResetGame();

//
// Called after setting low or high detail mode.
//
event DetailChange()
{
	local actor A;
	local zoneinfo Z;
	local skyzoneinfo S;
	if( !Level.bHighDetailMode )
	{
		foreach AllActors(class'Actor', A)
		{
			if( A.bHighDetail && !A.bGameRelevant )
				A.Destroy();
		}
	}
	foreach AllActors(class'ZoneInfo', Z)
		Z.LinkToSkybox();
}

//
// Return whether an actor should be destroyed in
// this type of game.
//	
function bool IsRelevant( actor Other )
{
	local byte bSuperRelevant;

	// let the mutators mutate the actor or choose to remove it
	if ( BaseMutator.AlwaysKeep(Other) )
		return true;
	if ( BaseMutator.IsRelevant(Other, bSuperRelevant) )
	{
		if ( bSuperRelevant == 1 ) // mutator wants to override any logic in here
			return true;
	}
	else return false;

	if
	(	(Difficulty==0 && !Other.bDifficulty0 )
	||  (Difficulty==1 && !Other.bDifficulty1 )
	||  (Difficulty==2 && !Other.bDifficulty2 )
	||  (Difficulty==3 && !Other.bDifficulty3 )
	||  (!Other.bSinglePlayer && (Level.NetMode==NM_Standalone) ) 
	||  (!Other.bNet && ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
	||  (!Other.bNetSpecial  && (Level.NetMode==NM_Client)) )
		return False;

	if( bNoMonsters && (Pawn(Other) != None) && !Pawn(Other).bIsPlayer )
		return False;

	if( FRand() > Other.OddsOfAppearing )
		return False;

    // Update the level info goal counts.
    if( Other.bIsSecretGoal )
       SecretGoals++;

    if( Other.bIsItemGoal )
       ItemGoals++;

    if( Other.bIsKillGoal )
       KillGoals++;

	return True;
}

//------------------------------------------------------------------------------
// Player start functions

//
// Grab the next option from a string.
//
function bool GrabOption( out string Options, out string Result )
{
	if( Left(Options,1)=="?" )
	{
		// Get result.
		Result = Mid(Options,1);
		if( InStr(Result,"?")>=0 )
			Result = Left( Result, InStr(Result,"?") );

		// Update options.
		Options = Mid(Options,1);
		if( InStr(Options,"?")>=0 )
			Options = Mid( Options, InStr(Options,"?") );
		else
			Options = "";

		return true;
	}
	else return false;
}

//
// Break up a key=value pair into its key and value.
//
function GetKeyValue( string Pair, out string Key, out string Value )
{
	if( InStr(Pair,"=")>=0 )
	{
		Key   = Left(Pair,InStr(Pair,"="));
		Value = Mid(Pair,InStr(Pair,"=")+1);
	}
	else
	{
		Key   = Pair;
		Value = "";
	}
}

//
// See if an option was specified in the options string.
//
function bool HasOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return true;
	}
	return false;
}

//
// Find an option in the options string and return it.
//
function string ParseOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return Value;
	}
	return "";
}

//
// Initialize the game.
//warning: this is called before actors' PreBeginPlay.
//
event InitGame( string Options, out string Error )
{
	local string InOpt, LeftOpt;
	local int pos;
	local class<Mutator> MClass;

	log( "InitGame:" @ Options );
	MaxPlayers = Min( 32,GetIntOption( Options, "MaxPlayers", MaxPlayers ));
	InOpt = ParseOption( Options, "Difficulty" );
	if( InOpt != "" )
		Difficulty = int(InOpt);

	InOpt = ParseOption( Options, "AdminPassword");
	if( InOpt!="" )
		AdminPassword = InOpt;

	InOpt = ParseOption( Options, "GameSpeed");
	if( InOpt != "" )
	{
		log("GameSpeed"@InOpt);
		SetGameSpeed(float(InOpt));
	}

	BaseMutator = spawn(MutatorClass);
	log("Base Mutator is "$BaseMutator);
	InOpt = ParseOption( Options, "Mutator");
	if ( InOpt != "" )
	{
		log("Mutators"@InOpt);
		while ( InOpt != "" )
		{
			pos = InStr(InOpt,",");
			if ( pos > 0 )
			{
				LeftOpt = Left(InOpt, pos);
				InOpt = Right(InOpt, Len(InOpt) - pos - 1);
			}
			else
			{
				LeftOpt = InOpt;
				InOpt = "";
			}
			log("Add mutator "$LeftOpt);
			MClass = class<Mutator>(DynamicLoadObject(LeftOpt, class'Class'));	
			BaseMutator.AddMutator(Spawn(MClass));
		}
	}

	InOpt = ParseOption( Options, "GamePassword");
	if( InOpt != "" )
	{
		GamePassWord = InOpt;
		log( "GamePassword" @ InOpt );
	}

	InOpt = ParseOption( Options, "LocalLog");
	if( InOpt ~= "true" )
		bLocalLog = True;

	InOpt = ParseOption( Options, "WorldLog");
	if( InOpt ~= "true" )
		bWorldLog = True;
}

//
// Return beacon text for serverbeacon.
//
event string GetBeaconText()
{	
	return
		Level.ComputerName
	$	" "
	$	Left(Level.Title,24) 
	$	" "
	$	BeaconName
	$	" "
	$	NumPlayers
	$	"/"
	$	MaxPlayers;
}

//
// Optional handling of ServerTravel for network games.
//
function ProcessServerTravel( string URL, bool bItems )
{
	local playerpawn P, LocalPlayer;

	if (LocalLog != None)
	{
		LocalLog.LogGameEnd("mapchange");
		LocalLog.StopLog();
		LocalLog.Destroy();
		LocalLog = None;
	}

	if (WorldLog != None)
	{
		WorldLog.LogGameEnd("mapchange");
		WorldLog.StopLog();
		WorldLog.Destroy();
		WorldLog = None;
	}

	// Notify clients we're switching level and give them time to receive.
	// We call PreClientTravel directly on any local PlayerPawns (ie listen server)
	log("ProcessServerTravel:"@URL);
	foreach AllActors( class'PlayerPawn', P )
		if( NetConnection(P.Player)!=None )
			P.ClientTravel( URL, TRAVEL_Relative, bItems );
		else
		{	
			LocalPlayer = P;
			P.PreClientTravel();
		}

	if ( (Level.NetMode == NM_ListenServer) && (LocalPlayer != None) )
		Level.NextURL = Level.NextURL$"?Skin="$LocalPlayer.GetDefaultURL("Skin")
					 $"?Face="$LocalPlayer.GetDefaultURL("Face")
					 $"?Team="$LocalPlayer.GetDefaultURL("Team")
					 $"?Name="$LocalPlayer.GetDefaultURL("Name")
					 $"?Class="$LocalPlayer.GetDefaultURL("Class");

	// Switch immediately if not networking.
	if( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		Level.NextSwitchCountdown = 0.0;
}

function bool AtCapacity(string Options)
{
	return ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) );
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode
)
{
	// Do any name or password or name validation here.
	local string InPassword;
	Error="";
	InPassword = ParseOption( Options, "Password" );
	if( (Level.NetMode != NM_Standalone) && AtCapacity(Options) )
	{
		Error=MaxedOutMessage;
	}
	else if
	(	GamePassword!=""
	&&	caps(InPassword)!=caps(GamePassword)
	&&	(AdminPassword=="" || caps(InPassword)!=caps(AdminPassword)) )
	{
		if( InPassword == "" )
		{
			Error = NeedPassword;
			FailCode = "NEEDPW";
		}
		else
		{
			Error = WrongPassword;
			FailCode = "WRONGPW";
		}
	}

	if(!CheckIPPolicy(Address))
		Error = IPBanned;
}

function bool CheckIPPolicy(string Address)
{
	local int i, j, LastMatchingPolicy;
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;
	
	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<50 && IPPolicies[i] != ""; i++)
	{
		j = InStr(IPPolicies[i], ",");
		if(j==-1)
			continue;
		Policy = Left(IPPolicies[i], j);
		Mask = Mid(IPPolicies[i], j+1);
		if(Policy ~= "ACCEPT") 
			bAcceptPolicy = True;
		else
		if(Policy ~= "DENY") 
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
	}

	if(!bAcceptAddress)
		Log("Denied connection for "$Address$" with IP policy "$IPPolicies[LastMatchingPolicy]);
		
	return bAcceptAddress;
}

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	if ( InOpt != "" )
	{
		log(ParseString@InOpt);
		return int(InOpt);
	}	
	return CurrentValue;
}

//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local NavigationPoint StartSpot;
	local PlayerPawn      NewPlayer, TestPlayer;
	local Pawn            PawnLink;
	local string          InName, InPassword, InSkin, InFace, InChecksum;
	local byte            InTeam;

	// Make sure there is capacity. (This might have changed since the PreLogin call).
	if ( Level.NetMode != NM_Standalone )
	{
		if ( ClassIsChildOf(SpawnClass, class'Spectator') )
		{
			if ( (NumSpectators >= MaxSpectators)
				&& ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) )
			{
				Error=MaxedOutMessage;
				return None;
			}
		}		
		else if ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) )
		{
			Error=MaxedOutMessage;
			return None;
		}
	}

	// Get URL options.
	InName     = Left(ParseOption ( Options, "Name"), 20);
	InTeam     = GetIntOption( Options, "Team", 255 ); // default to "no team"
	InPassword = ParseOption ( Options, "Password" );
	InSkin	   = ParseOption ( Options, "Skin"    );
	InFace     = ParseOption ( Options, "Face"    );
	InChecksum = ParseOption ( Options, "Checksum" );

	log( "Login:" @ InName );
	if( InPassword != "" )
		log( "Password"@InPassword );
	 
	// Find a start spot.
	StartSpot = FindPlayerStart( None, InTeam, Portal );

	if( StartSpot == None )
	{
		Error = FailedPlaceMessage;
		return None;
	}

	// Try to match up to existing unoccupied player in level,
	// for savegames and coop level switching.
	for( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.NextPawn )
	{
		TestPlayer = PlayerPawn(PawnLink);
		if
		(	TestPlayer!=None
		&&	TestPlayer.Player==None 
		&&  TestPlayer.PlayerReplicationInfo != None
		&&  TestPlayer.bIsPlayer
		&&	TestPlayer.PlayerReplicationInfo.PlayerName != class'PlayerReplicationInfo'.default.PlayerName
		)
		{
			if
			(	(Level.NetMode==NM_Standalone)
			||	(TestPlayer.PlayerReplicationInfo.PlayerName~=InName && TestPlayer.Password~=InPassword) )
			{
				// Found matching unoccupied player, so use this one.
				NewPlayer = TestPlayer;
				NewPlayer.Tag = 'Player';
				break;
			}
		}
	}

	// In not found, spawn a new player.
	if( NewPlayer==None )
	{
		// Make sure this kind of player is allowed.
		if ( (bHumansOnly || Level.bHumansOnly) && !SpawnClass.Default.bIsHuman
			&& !ClassIsChildOf(SpawnClass, class'Spectator') )
			SpawnClass = DefaultPlayerClass;

		NewPlayer = Spawn(SpawnClass,,'Player',StartSpot.Location,StartSpot.Rotation);
		if( NewPlayer!=None )
		{
			NewPlayer.ViewRotation = StartSpot.Rotation;

			// Save the playerstart event for later firing
			NewPlayer.StartEvent = StartSpot.Event;

			NewPlayer.bJustSpawned = true;
		}
	}
	else
	{
		NewPlayer.bJustSpawned = false;
	}

	// Handle spawn failure.
	if( NewPlayer == None )
	{
		log("Couldn't spawn player at "$StartSpot);
		Error = FailedSpawnMessage;
		return None;
	}

//	NewPlayer.static.SetMultiSkin(NewPlayer, InSkin, InFace, InTeam);
	NewPlayer.CurrentSkin = int(InSkin);
	NewPlayer.static.SetSkinActor(NewPlayer, int(InSkin));

	// Set the player's ID.
	NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

	// Init player's information.
	NewPlayer.ClientSetRotation(NewPlayer.Rotation);
	if( InName=="" )
		InName=DefaultPlayerName;
	if( Level.NetMode!=NM_Standalone || NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName )
		ChangeName( NewPlayer, InName, false );

	// Change player's team.
	if ( !ChangeTeam(newPlayer, InTeam) )
	{
		Error = FailedTeamMessage;
		return None;
	}

	if( NewPlayer.IsA('Spectator') && (Level.NetMode == NM_DedicatedServer) )
		NumSpectators++;

	// Init player's administrative privileges
	NewPlayer.Password = InPassword;
	NewPlayer.bAdmin = AdminPassword!="" && caps(InPassword)==caps(AdminPassword);
	NewPlayer.PlayerReplicationInfo.bAdmin = NewPlayer.bAdmin;
	if( NewPlayer.bAdmin )
		log( "Administrator logged in!" );

	// Init player's replication info
	NewPlayer.GameReplicationInfo = GameReplicationInfo;

	// If we are a server, broadcast a welcome message.
	if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
		BroadcastMessage( NewPlayer.PlayerReplicationInfo.PlayerName$EnteredMessage, false );

	// Teleport-in effect.
	StartSpot.PlayTeleportEffect( NewPlayer, true );

	// Log it.
	if ( LocalLog != None )
		LocalLog.LogPlayerConnect(NewPlayer);
	if ( WorldLog != None )
		WorldLog.LogPlayerConnect(NewPlayer, InChecksum);

	if ( !NewPlayer.IsA('Spectator') )
		NumPlayers++;

//	newPlayer.FireEvent(StartSpot.Event);
		
	return newPlayer;
}	

//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
event PostLogin( playerpawn NewPlayer )
{
	local Pawn P;
	// Start player's music.
	NewPlayer.ClientSetMusic( Level.Song, Level.SongSection, Level.CdTrack, MTRAN_Fade );
	if ( Level.NetMode != NM_Standalone )
	{
		// replicate skins
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && (P != NewPlayer) )
			{
				if ( P.bIsMultiSkinned )
					NewPlayer.ClientReplicateSkins(P.MultiSkins[0], P.MultiSkins[1], P.MultiSkins[2], P.MultiSkins[3]);
				else
					NewPlayer.ClientReplicateSkins(P.Skin);	
					
				if ( (P.PlayerReplicationInfo != None) && P.PlayerReplicationInfo.bWaitingPlayer && P.IsA('PlayerPawn') )
				{
					if ( NewPlayer.bIsMultiSkinned )
						PlayerPawn(P).ClientReplicateSkins(NewPlayer.MultiSkins[0], NewPlayer.MultiSkins[1], NewPlayer.MultiSkins[2], NewPlayer.MultiSkins[3]);
					else
						PlayerPawn(P).ClientReplicateSkins(NewPlayer.Skin);	
				}						
			}
	}
}

//
// Add bot to game.
//
function bool AddBot();
function bool ForceAddBot();

//
// Pawn exits.
//
function Logout( pawn Exiting )
{
	local bool bMessage;

	bMessage = true;
	if ( Exiting.IsA('PlayerPawn') )

	{
		if ( Exiting.IsA('Spectator') )
		{
			bMessage = false;
			if ( Level.NetMode == NM_DedicatedServer )
				NumSpectators--;
		}
		else
			NumPlayers--;
	}
	if( bMessage && (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer) )
		BroadcastMessage( Exiting.PlayerReplicationInfo.PlayerName$LeftMessage, false );

	if ( LocalLog != None )
		LocalLog.LogPlayerDisconnect(Exiting);
	if ( WorldLog != None )
		WorldLog.LogPlayerDisconnect(Exiting);
}

//
// Examine the passed player's inventory, and accept or discard each item.
// AcceptInventory needs to gracefully handle the case of some inventory
// being accepted but other inventory not being accepted (such as the default
// weapon).  There are several things that can go wrong: The player's selected
// inventory item, active
// weapon, etc. not being accepted, leaving the player weaponless or leaving
// the HUD inventory rendering messed up (AcceptInventory should pick another
// applicable weapon/item as current).
//
event AcceptInventory(pawn PlayerPawn)
{
	//default accept all inventory except default weapon (spawned explicitly)

	local inventory inv;

	// Initialize the inventory.
	AddDefaultInventory( PlayerPawn );

	log( "All inventory from" @ PlayerPawn.PlayerReplicationInfo.PlayerName @ "is accepted" );
}

//
// Spawn any default inventory for the player.
//
function AddDefaultInventory( pawn PlayerPawn )
{
	local Weapon newWeapon;
	local Shield newShield;

	PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ * PlayerJumpZScaling();
	 
	if( PlayerPawn.IsA('Spectator') )
		return;

	// Spawn default weapon.
	if (PlayerPawn.Weapon == None)
	{
		if( (DefaultWeapon!=None && PlayerPawn.FindInventoryType(DefaultWeapon)==None) ||	// Default weapon exists that player doesn't yet have
			BaseMutator.MutatedDefaultWeapon()!=None )										// Mutators dictating a default weapon
		{
			newWeapon = Spawn(BaseMutator.MutatedDefaultWeapon(),,,PlayerPawn.Location);
			if( newWeapon != None )
			{
				newWeapon.bTossedOut = true;
				newWeapon.Instigator = PlayerPawn;
				newWeapon.BecomeItem();
				PlayerPawn.AddInventory(newWeapon);
				PlayerPawn.AcquireInventory(newWeapon);
				PlayerPawn.Weapon = newWeapon;
				newWeapon.GotoState('Active');
	//			newWeapon.BringUp();
	//			newWeapon.SetSwitchPriority(PlayerPawn);
	//			newWeapon.WeaponSet(PlayerPawn);
			}
		}
	}

	// Spawn default shield
	if (PlayerPawn.Shield == None)
	{
		if( (DefaultShield!=None && PlayerPawn.FindInventoryType(DefaultShield)==None) ||
			BaseMutator.MutatedDefaultShield()!=None )
		{
			newShield = Spawn(BaseMutator.MutatedDefaultShield(),,,PlayerPawn.Location);
			if( newShield != None )
			{
				newShield.bTossedOut = true;
				newShield.Instigator = PlayerPawn;
				newShield.BecomeItem();
				PlayerPawn.AddInventory(newShield);
				PlayerPawn.AcquireInventory(newShield);
				PlayerPawn.Shield = newShield;
				newShield.GotoState('Active');
			}
		}
	}

	BaseMutator.ModifyPlayer(PlayerPawn);
}


//
// Return the 'best' player start for this player to start from.
// Re-implement for each game type.
//
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest;
	local Teleporter Tel;
	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;
	foreach AllActors( class 'PlayerStart', Dest )
		if( Dest.bSinglePlayerStart && Dest.bEnabled )
			return Dest;

	// if none, check for any that aren't enabled
	log("WARNING: All single player starts were disabled - picking one anyway!");
	foreach AllActors( class 'PlayerStart', Dest )
		if( Dest.bSinglePlayerStart )
			return Dest;
	log( "No single player start found" );
	return None;
}

//
// Restart a player.
//
function bool RestartPlayer( pawn aPlayer )	
{
	local NavigationPoint startSpot;
	local bool foundStart;
	local int i;
	local actor A;

	if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		return true;

	startSpot = FindPlayerStart(aPlayer, 255);
	if( startSpot == None )
	{
		log(" Player start not found!!!");
		return false;
	}
		
	foundStart = aPlayer.SetLocation(startSpot.Location);
	if( foundStart )
	{
		startSpot.PlayTeleportEffect(aPlayer, true);
		aPlayer.SetRotation(startSpot.Rotation);
		aPlayer.ViewRotation = aPlayer.Rotation;
		aPlayer.Acceleration = vect(0,0,0);
		aPlayer.Velocity = vect(0,0,0);
		aPlayer.Health = aPlayer.Default.Health;
		aPlayer.SetCollision( true, true, true );
		aPlayer.bCollideWorld = true;
		aPlayer.SetCollisionSize(aPlayer.Default.CollisionRadius, aPlayer.Default.CollisionHeight);
		aPlayer.ClientSetLocation( startSpot.Location, startSpot.Rotation );
		aPlayer.bHidden = false;
		aPlayer.DamageScaling = aPlayer.Default.DamageScaling;
		aPlayer.SoundDampening = aPlayer.Default.SoundDampening;

		// Team games require this
		if (bTeamGame)
			aPlayer.DesiredColorAdjust = GetTeamVectorColor(aPlayer.PlayerReplicationInfo.Team);
		else
			aPlayer.DesiredColorAdjust = aPlayer.Default.DesiredColorAdjust;

		if (PlayerPawn(aPlayer)!=None)
		{
			PlayerPawn(aPlayer).DesiredPolyColorAdjust = PlayerPawn(aPlayer).Default.DesiredPolyColorAdjust;
			PlayerPawn(aPlayer).PolyColorAdjust = PlayerPawn(aPlayer).Default.PolyColorAdjust;
		}

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
		aPlayer.MaxHealth = aPlayer.Default.MaxHealth;
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

		AddDefaultInventory(aPlayer);

		// Reset anim proxy vars
		if(PlayerPawn(aPlayer) != None && PlayerPawn(aPlayer).AnimProxy != None)
		{
			PlayerPawn(aPlayer).AnimProxy.GotoState('Idle');
		}
	}
	else
		log(startspot$" Player start not useable!!!");

	return foundStart;
}

//
// Start a player.
//
function StartPlayer(PlayerPawn Other)
{
	if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer || !bRestartLevel )
		Other.GotoState(Other.PlayerRestartState);
	else
		Other.ClientTravel( "?restart", TRAVEL_Relative, false );
}

//------------------------------------------------------------------------------
// Level death message functions.
//------------------------------------------------------------------------------

//-------------------------------------------------------
//
// Killed
//
// Display a death message, called when a pawn is killed
//-------------------------------------------------------
function Killed( pawn killer, pawn Other, name damageType )
{
	local string killed;
	local string message;
	local string KillerWeaponName;
	local string VictimWeaponName;
	local string DeathMessage;

	if (Other.bIsPlayer)
	{
		if ( (Killer == Other) || (Killer == None) )
		{
			// suicide
			if ( LocalLog != None )
				LocalLog.LogSuicide(Other, damageType, Killer);
			if ( WorldLog != None )
				WorldLog.LogSuicide(Other, damageType, Killer);
			message = KillMessage(damageType, None);
			BroadcastMessage(Other.PlayerReplicationInfo.PlayerName$message, false, 'DeathMessage');
		}
		else
		{
			DeathMessage = KillMessage(damageType, Killer);
			if (Killer.Weapon != None)
				KillerWeaponName = Killer.Weapon.ItemName;
			if (Other.Weapon != None)
				VictimWeaponName = Other.Weapon.ItemName;
			if ( LocalLog != None && Killer.bIsPlayer)
				LocalLog.LogKill(
						Killer.PlayerReplicationInfo.PlayerID,
						Other.PlayerReplicationInfo.PlayerID,
						KillerWeaponName,
						VictimWeaponName,
						damageType
				);
			if ( WorldLog != None  && Killer.bIsPlayer)
				WorldLog.LogKill(
						Killer.PlayerReplicationInfo.PlayerID,
						Other.PlayerReplicationInfo.PlayerID,
						KillerWeaponName,
						VictimWeaponName,
						damageType
				);

			killed = Other.PlayerReplicationInfo.PlayerName;
			if ( (DamageType == 'SpecialDamage') && (SpecialDamageString != "") && Killer.bIsPlayer)
			{
				message = ParseKillMessage(
					Killer.PlayerReplicationInfo.PlayerName,
					Other.PlayerReplicationInfo.PlayerName,
					KillerWeaponName,
					SpecialDamageString
				);
				BroadcastMessage(message, false, 'DeathMessage');
			}
			else if (Killer.bIsPlayer)
			{
				message = ParseKillMessage(
					Killer.PlayerReplicationInfo.PlayerName,
					Other.PlayerReplicationInfo.PlayerName,
					KillerWeaponName,
					DeathMessage
				);
				BroadcastMessage(message, false, 'DeathMessage');
			}
		}
	}
	ScoreKill(killer, Other);
}

function BroadcastRegularDeathMessage(pawn Killer, pawn Other, name damageType)
{
	BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, Killer.Weapon.Class);
}

// %k = Owner's PlayerName (Killer)
// %o = Other's PlayerName (Victim)
// %w = Owner's Weapon ItemName
static native function string ParseKillMessage( string KillerName, string VictimName, string WeaponName, string DeathMessage );

function ScoreKill(pawn Killer, pawn Other)
{
	if (Other==None)
	{
		log("Warning: ScoreKill (OTHER==NONE): Killer="$Killer@"Other="$Other);
		return;
	}

	Other.DieCount++;
	if (Other.bIsPlayer && Other.PlayerReplicationInfo != None)
		Other.PlayerReplicationInfo.Deaths +=1;

	if( (killer == Other) || (killer == None) )
	{
		if (Other.PlayerReplicationInfo != None)
			Other.PlayerReplicationInfo.Score -= 1;
	}
	else if ( killer != None )
	{
		killer.killCount++;
		if ( killer.PlayerReplicationInfo != None )
			killer.PlayerReplicationInfo.Score += 1;
	}
	BaseMutator.ScoreKill(Killer, Other);
}	

//
// Default death message.
//
static function string KillMessage( name damageType, pawn killer )
{
	return " died.";
}

//-------------------------------------------------------------------------------------
// Level gameplay modification.

//
// Return whether Viewer is allowed to spectate from the
// point of view of ViewTarget.
//
function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return true;
}

function RegisterDamageMutator(Mutator M)
{
	M.NextDamageMutator = DamageMutator;
	DamageMutator = M;
}


//
// Use reduce damage for teamplay modifications, etc.
//
function ReduceDamage( out int BluntDamage, out int SeverDamage, name DamageType, pawn injured, pawn instigatedBy )
{
	if (injured.Region.Zone.bNeutralZone)
	{	// Sanctuary
		BluntDamage = 0;
		SeverDamage = 0;
	}
	else if ( injured.bIsPlayer )
	{
		switch(Difficulty)
		{
		case 0:
			BluntDamage = BluntDamage * 0.5;
			SeverDamage = SeverDamage * 0.5;
			break;
		case 1:
			BluntDamage = BluntDamage;
			SeverDamage = SeverDamage;
			break;
		case 2:
			BluntDamage = BluntDamage * 1.5;
			SeverDamage = SeverDamage * 1.5;
			break;
		case 3:
			BluntDamage = BluntDamage * 2;
			SeverDamage = SeverDamage * 2;
			break;
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
	else if ( (injured.ReducedDamageType == 'All') || 
		((injured.ReducedDamageType != '') && (injured.ReducedDamageType == damageType)) )
	{	// Reduced damage
		BluntDamage = float(BluntDamage) * (1 - injured.ReducedDamagePct);
		SeverDamage = float(SeverDamage) * (1 - injured.ReducedDamagePct);
	}
}

//
// Award a score to an actor.
//
function ScoreEvent( name EventName, actor EventActor, pawn InstigatedBy )
{
}

//
// Return whether an item should respawn.
//
function bool ShouldRespawn( actor Other )
{
	if( Level.NetMode == NM_StandAlone )
		return false;
	return Inventory(Other)!=None && Inventory(Other).ReSpawnTime!=0.0;
}

//
// Called when pawn has a chance to pick Item up (i.e. when 
// the pawn touches a weapon pickup). Should return true if 
// he wants to pick it up, false if he does not want it.
//
function bool PickupQuery( Pawn Other, Inventory item )
{
	if ( !Other.CanPickup(item) )
		return false;
	
	if ( !Other.WantsToPickup(item) )
		return false;
		
	if ( Other.Inventory == None )
		return true;
	else
		return !Other.Inventory.HandlePickupQuery(Item);
}

function bool AllowWeaponDrop()
{
	return (bAllowWeaponDrop && BaseMutator.AllowWeaponDrop());
}

function bool AllowShieldDrop()
{
	return (bAllowShieldDrop && BaseMutator.AllowShieldDrop());
}

//
// Discard a player's inventory after he dies.
//
function DiscardInventory( Pawn Other )
{
	local actor dropped;
	local inventory Inv;
	local weapon weap;
	local float speed;
	local inventory next;

	if( Other.DropWhenKilled != None )
	{
		dropped = Spawn(Other.DropWhenKilled,,,Other.Location);
		Inv = Inventory(dropped);
		if ( Inv != None )
		{ 
			Inv.RespawnTime = 0.0; //don't respawn
			Inv.BecomePickup();		
		}
		if ( dropped != None )
		{
			dropped.RemoteRole = ROLE_DumbProxy;
			dropped.SetPhysics(PHYS_Falling);
			dropped.bCollideWorld = true;
			dropped.Velocity = Other.Velocity + VRand() * 280;
		}
		if ( Inv != None )
			Inv.GotoState('PickUp', 'Dropped');
	}

	Other.Weapon = None;
	Other.Shield = None;
	Other.SelectedItem = None;
	for( Inv=Other.Inventory; Inv!=None; Inv = next )
	{
		next = Inv.Inventory;
		Inv.Destroy();
	}
}

// Return the player jumpZ scaling for this gametype
function float PlayerJumpZScaling()
{
	return 1.0;
}

//
// Try to change a player's name.
//	
function ChangeName( Pawn Other, coerce string S, bool bNameChange )
{
	if( S == "" )
		return;
	if (LocalLog != None)
		LocalLog.LogNameChange(Other);
	if (WorldLog != None)
		WorldLog.LogNameChange(Other);
	Other.PlayerReplicationInfo.PlayerName = S;
	if( bNameChange )
		Other.ClientMessage( NameChangedMessage $ Other.PlayerReplicationInfo.PlayerName );
}

//
// Return whether a team change is allowed.
//
function bool ChangeTeam(Pawn Other, int N)
{
	Other.PlayerReplicationInfo.Team = N;
	if (LocalLog != None)
		LocalLog.LogTeamChange(Other);
	if (WorldLog != None)
		WorldLog.LogTeamChange(Other);
	return true;
}

//
// Play an inventory respawn effect.
//
function float PlaySpawnEffect( inventory Inv )
{
	return 0.3;
}

//
// Generate a player killled message.
//
static function string PlayerKillMessage( name damageType, PlayerReplicationInfo Other )
{
	local string message;

	message = " was killed by ";
	return message;
}

//
// Generate a killed by creature message.
//
static function string CreatureKillMessage( name damageType, pawn Other )
{
	return " was killed by a ";
}

//
// Send a player to a URL.
//
function SendPlayer( PlayerPawn aPlayer, string URL )
{
	aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
}

//
// Play a teleporting special effect.
//
function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound);

//
// Restart the game.
//
function RestartGame()
{
	Level.ServerTravel( "?Restart", false );
}

//
// Whether players are allowed to broadcast messages now.
//
function bool AllowsBroadcast( actor broadcaster, int Len )
{
	SentText += Len;

	return (SentText < 260);
}

//
// End of game.
//
function EndGame( string Reason )
{
	local actor A;

	// don't end game if not really ready
	if ( !SetEndCams(Reason) )
	{
		bOverTime = true;
		return;
	}
	bGameEnded = true;
	foreach AllActors(class'Actor', A, 'EndGame')
		A.trigger(self, none);

	if (LocalLog != None)
	{
		LocalLog.LogGameEnd(Reason);
		LocalLog.StopLog();
		if (bBatchLocal)
			LocalLog.ExecuteSilentLogBatcher();
		LocalLog.Destroy();
		LocalLog = None;
	}
	if (WorldLog != None)
	{
		WorldLog.LogGameEnd(Reason);
		WorldLog.StopLog();
		WorldLog.ExecuteWorldLogBatcher();
		WorldLog.Destroy();
		WorldLog = None;
	}
}

function bool SetEndCams(string Reason)
{
	local pawn aPawn;

	for ( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if ( aPawn.bIsPlayer )
		{
			aPawn.GotoState('GameEnded');
			aPawn.ClientGameEnded();
		}	

	return true;
}

function vector GetTeamVectorColor(int num)
{
	return vect(255,255,255);
}

simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);

	Canvas.DrawText("GameInfo:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  bGameEnded: " $ bGameEnded);
	Canvas.CurY -= 8;
	Canvas.DrawText("  RuleList:   " $ GetRules());
	Canvas.CurY -= 8;
	Canvas.DrawText("  bAllowWeaponDrop: " $ bAllowWeaponDrop);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bAllowShieldDrop: " $ bAllowShieldDrop);
	Canvas.CurY -= 8;

}

defaultproperties
{
     Difficulty=1
     bRestartLevel=True
     bPauseable=True
     bCanChangeSkin=True
     bNoCheating=True
     bCanViewOthers=True
     bAllowWeaponDrop=True
     bAllowShieldDrop=True
     AutoAim=0.930000
     GameSpeed=0.100000
     MaxSpectators=2
     AdminPassword="b"
     SwitchLevelMessage="Switching Levels"
     DefaultPlayerName="Player"
     LeftMessage=" left the game."
     FailedSpawnMessage="Failed to spawn player actor"
     FailedPlaceMessage="Could not find starting spot (level might need a 'PlayerStart' actor)"
     FailedTeamMessage="Could not find team for player"
     NameChangedMessage="Name changed to "
     EnteredMessage=" entered the game."
     GameName="Game"
     MaxedOutMessage="Server is already at capacity."
     WrongPassword="The password you entered is incorrect."
     NeedPassword="You need to enter a password to join this game."
     IPBanned="Your IP address has been banned on this server."
     MaxPlayers=16
     IPPolicies(0)="ACCEPT,*"
     DeathMessageClass=Class'Engine.LocalMessage'
     MutatorClass=Class'Engine.Mutator'
     DefaultPlayerState=PlayerWalking
     ServerLogName="server.log"
     bLocalLog=True
     bWorldLog=True
     bSubtitles=True
     StatLogClass=Class'Engine.StatLogFile'
     DebrisPercentage=0.900000
     ParticlePercentage=1.000000
     bAllowLimbSever=True
	 bAllowHeadSever=True
	 bShieldHitStun=False
	 bShieldTakesAllHits=False
	 FriendlyFireMultiplier=0.0
}