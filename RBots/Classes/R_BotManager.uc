//==============================================================================
//	R_BotManager
//	Top level Bot manager class for RBots
//	Spawned and managed by RBotsServerActor
//==============================================================================
class R_BotManager extends Actor;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BotManager';

event BeginPlay()
{
	Super.BeginPlay();
	Utilities.Static.RLog("BotManager spawned from class" @ Class, LogCategory);
}

/**
	SpawnBot
	Main function for adding bots to the game
	
	bDeferredInitialization is provided as a means for callers to perform additional bot
	configuration before they begin playing
	NOTE: If caller provides bDeferredInitialization = true, they are responsible for calling
	R_Bot.InitializeBot
*/
unction R_Bot SpawnBot(optional bool bDeferredInitialization)
{
	local R_Bot NewBot;
	local PlayerPawn NewPlayerPawn;
	local NavigationPoint StartPoint;
	local GameInfo GI;
	local String ErrorStr;
	local int CurrentPlayers;
	local PlayerPawn P;

	GI = Level.Game;

	foreach AllActors(class'PlayerPawn', P)
	{
		if (!P.bDeleteMe)
		{
			CurrentPlayers++;
		}
	}

	if (GI != None && CurrentPlayers >= GI.MaxPlayers)
	{
		Utilities.Static.RLog("Spawning Bot failed: MaxPlayers limit reached (" $ CurrentPlayers $ "/" $ GI.MaxPlayers $ ")", LogCategory);
		return None;
	}

	if(bDeferredInitialization)
	{
		Utilities.Static.RLog("Spawning Bot with deferred initialization", LogCategory);
	}
	else
	{
		Utilities.Static.RLog("Spawning Bot", LogCategory);
	}
	
	StartPoint = Level.Game.FindPlayerStart(None);

	NewBot = Spawn(Class'RBots.R_Bot');
	//NewPlayerPawn = Spawn(Class'RBots.R_RBotsDebug_RunePlayer',,,StartPoint.Location, StartPoint.Rotation);

	if(GI != None)
	{
		NewPlayerPawn = GI.Login("", "Name=IsABot", ErrorStr, Class'RuneI.PlayerAlric');
		//NewPlayerPawn = GI.Login("Name=IsABot", "", ErrorStr, Class'RBots.R_RBotsDebug_RunePlayer');
	}	
	
	NewPlayerPawn.SetOwner(NewBot);
	NewBot.PossessedPlayerPawn(NewPlayerPawn);

	if(!bDeferredInitialization)
	{
		NewBot.InitializeBot();
	}

	return NewBot;
}

function RemoveBot(R_Bot Bot)
{
	local PlayerPawn P;
	local PlayerReplicationInfo PRI;

	if(Bot == None)
	{
		return;
	}

	Utilities.Static.RLog("Removing Bot:" @ Bot, LogCategory);
	P = Bot.GetOwnedPlayerPawn();
	PRI = Bot.GetOwnedPRI();

	if(P != None)
	{
		P.Destroy();
	}

	if(PRI != None)
	{
		PRI.Destroy();
	}

	Bot.Destroy();
}

defaultproperties
{
	RemoteRole=ROLE_None
}
