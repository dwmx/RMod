//==============================================================================
//	R_BotManager
//	Top level Bot manager class for RBots
//	Spawned and managed by RBotsServerActor
//==============================================================================
class R_BotManager extends R_RBotsObject;

const LogCategory = 'BotManager';

/**
	SpawnBot
	Main function for adding bots to the game
	
	bDeferredInitialization is provided as a means for callers to perform additional bot
	configuration before they begin playing
	NOTE: If caller provides bDeferredInitialization = true, they are responsible for calling
	R_Bot.InitializeBot
*/
function R_Bot SpawnBot(optional bool bDeferredInitialization)
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;
	local R_Bot NewBot;
	local PlayerPawn NewPlayerPawn;
	local NavigationPoint StartPoint;
	local GameInfo GI;
	local String ErrorStr;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{	// Invalid RBotsServerActor check
		LogString = "SpawnBot failed -- Invalid RBotsServerActor reference";
		GoTo SpawnBotFailedWithLogString;
	}

	NewBot = LocalRBots.Spawn(Class'RBots.R_Bot');
	if(NewBot == None)
	{
		LogString = "SpawnBot failed -- Failed to instantiate Bot";
		GoTo SpawnBotFailedWithLogString;
	}
	
	StartPoint = LocalRBots.Level.Game.FindPlayerStart(None);

	GI = LocalRBots.Level.Game;
	if(GI == None)
	{
		LogString = "SpawnBot failed -- Failed to get GameInfo reference from RBotsServerActor";
		GoTo SpawnBotFailedWithLogString;
	}

	if(bDeferredInitialization)
	{	// Spawn bot with deferred initialization
		Utilities.Static.RLog("Spawning Bot with deferred initialization", LogCategory);
	}
	else
	{	// Spawn bot normally
		Utilities.Static.RLog("Spawning Bot", LogCategory);
	}

	NewPlayerPawn = GI.Login("", "Name=IsABot", ErrorStr, Class'RuneI.PlayerAlric');
	NewPlayerPawn.SetOwner(NewBot);
	NewBot.PossessedPlayerPawn(NewPlayerPawn);

	if(!bDeferredInitialization)
	{
		NewBot.InitializeBot();
	}

	return NewBot;

SpawnBotFailedWithLogString:
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return None;
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
	bLogCreation=true
}