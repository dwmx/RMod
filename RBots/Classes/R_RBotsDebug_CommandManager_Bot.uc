//==============================================================================
//	R_RBotsDebug_CommandManager_Bot
//	Debug commands for Bots
//==============================================================================
class R_RBotsDebug_CommandManager_Bot extends R_RBotsDebug_CommandManager;

//------------------------------------------------------------------------------
// Inventories to grant to debug target via GrantInventory command
var private String InventoriesToGrant[16];

//------------------------------------------------------------------------------

const Command_SpawnBot 			= "SpawnBot";
const Command_SpawnDebugBot		= "SpawnDebugBot";
const Command_RemoveAllBots 	= "RemoveAllBots";
const Command_SetPathStart		= "SetPathStart";
const Command_SetPathEnd		= "SetPathEnd";
const Command_GrantInventory	= "GrantInventory";

// The bot class to spawn for SpawnDebugBot command
const DebugBotClass = Class'RBots.R_RBotsDebug_DebugBot';

function RegisterCommandList()
{
	RegisterCommand(Command_SpawnBot);
	RegisterCommand(Command_SpawnDebugBot);
	RegisterCommand(Command_RemoveAllBots);
	RegisterCommand(Command_SetPathStart);
	RegisterCommand(Command_SetPathEnd);
	RegisterCommand(Command_GrantInventory);
}

function bool TryHandleCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_SpawnBot:			HandleCommand_SpawnBot(DebugMutator, Sender);		return true;
		case Command_SpawnDebugBot:		HandleCommand_SpawnDebugBot(DebugMutator, Sender);	return true;
		case Command_RemoveAllBots:		HandleCommand_RemoveAllBots(DebugMutator, Sender);	return true;
		case Command_SetPathStart:		HandleCommand_SetPathStart(DebugMutator, Sender);	return true;
		case Command_SetPathEnd:		HandleCommand_SetPathEnd(DebugMutator, Sender);		return true;
		case Command_GrantInventory:	HandleCommand_GrantInventory(DebugMutator, Sender);	return true;
	}

	return false;
}

function HandleCommand_SpawnBot(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_BotManager BotManager;
	local R_Bot NewBot;

	BotManager = None;
	if(DebugMutator != None)
	{
		BotManager = DebugMutator.GetBotManager();
	}
	if(BotManager == None)
	{
		return;
	}
	
	// Spawn with deferred initialization so that debug views can set
	// things up before the bot starts doing stuff
	NewBot = BotManager.SpawnBot(true);
	if(NewBot != None)
	{
		DebugMutator.SetDebugTarget(NewBot);
	}
	NewBot.InitializeBot();
}

function HandleCommand_SpawnDebugBot(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	// Bypasses the normal bot manager bot spawn setup and spawns only a debug bot actor
	// Debug bots don't update behaviors on their own, they only respond to commands
	local R_Bot NewBot;

	if(DebugMutator == None)
	{
		return;
	}

	NewBot = DebugMutator.Spawn(DebugBotClass);
	if(NewBot != None)
	{
		NewBot.InitializeBot();
		DebugMutator.SetDebugTarget(NewBot);
	}
}

function HandleCommand_RemoveAllBots(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_BotManager BotManager;
	local R_Bot Bot;

	BotManager = None;
	if(DebugMutator != None)
	{
		BotManager = DebugMutator.GetBotManager();
	}
	if(BotManager == None)
	{
		return;
	}

	foreach BotManager.AllActors(Class'RBots.R_Bot', Bot)
	{
		BotManager.RemoveBot(Bot);
	}
}

function HandleCommand_SetPathStart(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_DebugBot DebugBot;
	local Vector StartLocation;

	if(DebugMutator == None)
	{
		return;
	}

	DebugBot = R_RBotsDebug_DebugBot(DebugMutator.GetDebugTarget());
	if(DebugBot != None)
	{
		if(Sender != None)
		{
			StartLocation = Sender.Location;
		}
		else
		{
			StartLocation = Vect(0,0,0);
		}
		DebugBot.SetStartLocation(StartLocation);
	}
	else
	{
		CommandResponse(DebugMutator, Sender, "Current DebugTarget must be of type R_RBotsDebug_DebugBot -- Use command" @ Command_SpawnDebugBot);
	}
}

function HandleCommand_SetPathEnd(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_DebugBot DebugBot;
	local Vector EndLocation;

	if(DebugMutator == None)
	{
		return;
	}

	DebugBot = R_RBotsDebug_DebugBot(DebugMutator.GetDebugTarget());
	if(DebugBot != None)
	{
		if(Sender != None)
		{
			EndLocation = Sender.Location;
		}
		else
		{
			EndLocation = Vect(0,0,0);
		}
		DebugBot.SetEndLocation(EndLocation);
	}
	else
	{
		CommandResponse(DebugMutator, Sender, "Current DebugTarget must be of type R_RBotsDebug_DebugBot -- Use command" @ Command_SpawnDebugBot);
	}
}

function HandleCommand_GrantInventory(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_Bot Bot;
	local PlayerPawn PP;
	local Class<Inventory> InvClass;
	local Inventory Inv;
	local int i;

	if(DebugMutator == None)
	{
		return;
	}

	Bot = DebugMutator.GetDebugTarget();
	if(Bot != None)
	{
		PP = Bot.GetOwnedPlayerPawn();
	}
	if(PP == None)
	{
		return;
	}

	for(i = 0; i < ArrayCount(InventoriesToGrant); ++i)
	{
		if(InventoriesToGrant[i] == "")
		{
			continue;
		}

		InvClass = Class<Inventory>(DynamicLoadObject(InventoriesToGrant[i], Class'Class'));
		Inv = None;
		if(InvClass != None)
		{
			Inv = PP.Spawn(InvClass);
		}

		if(Inv != None)
		{
			PP.AcquireInventory(Inv);
			PP.AddInventory(Inv);
		}
	}
}

defaultproperties
{
	InventoriesToGrant(0)="RMod.R_Weapon_DwarfBattleAxe"
	InventoriesToGrant(1)="RMod.R_Weapon_DwarfBattleHammer"
	InventoriesToGrant(2)="RMod.R_Weapon_DwarfWorkSword"
	InventoriesToGrant(3)="RMod.R_Weapon_VikingBroadSword"
}