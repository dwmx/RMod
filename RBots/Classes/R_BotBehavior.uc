//==============================================================================
//	R_BotBehavior
//	Base class for all Bot behavior
//==============================================================================
class R_BotBehavior extends R_NavObject abstract;

const NavLib = Class'RBots.R_NavLibrary';

var private R_Bot OwnerBot;
var private PlayerPawn OwnerPlayerPawn;

// Return a descriptive name string for this behavior
function String GetDescriptiveString()
{
	return "Behavior Descriptive String";
}

final function InitializeBehavior(R_Bot NewOwnerBot, PlayerPawn NewOwnerPlayerPawn)
{
	OwnerBot = NewOwnerBot;
	OwnerPlayerPawn = NewOwnerPlayerPawn;
}

final function R_Bot GetBot() { return OwnerBot; }
final function PlayerPawn GetPlayerPawn() { return OwnerPlayerPawn; }
final function R_BotPerception GetBotPerception()
{
	local R_Bot Bot;
	Bot = GetBot();
	if(Bot != None)
	{
		return R_BotPerception(Bot.GetBotObjectByClass(Class'RBots.R_BotPerception'));
	}
	return None;
}

// Called when this behavior is activated
function BehaviorActivated()
{}

// Called when this behavior is terminated
function BehaviorTerminated()
{}

// Called by owning bot's Tick
function BehaviorTick(float DeltaSeconds)
{}