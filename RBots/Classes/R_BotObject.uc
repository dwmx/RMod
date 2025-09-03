//==============================================================================
//	R_BotObject
//	Base class for all sub-objects contained and managed by an R_Bot
//==============================================================================
class R_BotObject extends Object abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BotObject';
var private R_Bot BotOwner;

var private bool bTickBotObject;

final function BaseInitBotObject(R_Bot NewBotOwner)
{
	BotOwner = NewBotOwner;
	InitBotObject();
}

final function BaseTickBotObject(float DeltaSeconds)
{
	if(bTickBotObject)
	{
		TickBotObject(DeltaSeconds);
	}
}

final function SetTickBotObjectEnabled(bool bNewTickBotObject)
{
	bTickBotObject = bNewTickBotObject;
}

final function R_Bot GetBot() { return BotOwner; }

final function PlayerPawn GetPlayerPawn()
{
	if(BotOwner != None)
	{
		return BotOwner.GetOwnedPlayerPawn();
	}

	return None;
}

//------------------------------------------------------------------------------
//	Sub-class extension interface
function InitBotObject();
function TickBotObject(float DeltaSeconds);

defaultproperties
{
	bTickBotObject=true;
}