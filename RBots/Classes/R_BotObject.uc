//==============================================================================
//	R_BotObject
//	Base class for all sub-objects contained and managed by an R_Bot
//==============================================================================
class R_BotObject extends R_RBotsObject abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BotObject';
var private R_Bot BotOwner;

var private bool bTickBotObject;

// BlackBoard Keys
const BBKey_InventoryTarget 	= 'InventoryTarget';	// Actor
const BBKey_WantWeapon 			= 'WantWeapon';			// Float
const BBKey_WantShield			= 'WantShield';			// Float
const BBKey_WantHealth			= 'WantHealth';			// Float
const BBKey_WantStrength		= 'WantStrength';		// Float
const BBKey_WantRunePower		= 'WantRunePower';		// Float

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

final function AnimationProxy GetAnimProxy()
{
	local PlayerPawn PP;
	if(BotOwner != None)
	{
		PP = BotOwner.GetOwnedPlayerPawn();
		if(PP != None)
		{
			return PP.AnimProxy;
		}
	}
	return None;
}

final function R_BotPerception GetBotPerception()
{
	if(BotOwner != None)
	{
		return R_BotPerception(BotOwner.GetBotObjectByClass(Class'RBots.R_BotPerception'));
	}
	return None;
}

final function R_BotPawnController GetBotPawnController()
{
	if(BotOwner != None)
	{
		return R_BotPawnController(BotOwner.GetBotObjectByClass(Class'RBots.R_BotPawnController'));
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