//==============================================================================
//	R_BotBehavior
//	Base class for all Bot behavior
//==============================================================================
class R_BotBehavior extends R_NavObject abstract;

const NavLib = Class'RBots.R_NavLibrary';

var private R_Bot OwnerBot;
var private PlayerPawn OwnerPlayerPawn;
var private R_BotManager BotManager;

var private R_BotPerception OwnerPerception;
var private R_BotPawnController OwnerController;
var private R_BlackBoard OwnerBlackBoard;
var private R_NavMesh CachedNavMesh;
var private R_NavMeshActorTracker CachedNavMeshActorTracker;

//------------------------------------------------------------------------------
//	Base implementation -- Do not override

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

final function R_BotManager GetBotManager()
{
	local R_Bot Bot;
	if(BotManager == None)
	{
		Bot = GetBot();
		if(Bot != None)
		{
			BotManager = Bot.GetBotManager();
		}
	}
	return BotManager;
}

final function R_BotPerception GetBotPerception()
{
	local R_Bot Bot;
	if(OwnerPerception == None)
	{
		Bot = GetBot();
		if(Bot != None)
		{
			OwnerPerception = R_BotPerception(Bot.GetBotObjectByClass(Class'RBots.R_BotPerception'));
		}
	}
	return OwnerPerception;
}

final function R_BotPawnController GetBotPawnController()
{
	local R_Bot Bot;
	if(OwnerController == None)
	{
		Bot = GetBot();
		if(Bot != None)
		{
			OwnerController = R_BotPawnController(Bot.GetBotObjectByClass(Class'RBots.R_BotPawnController'));
		}
	}
	return OwnerController;
}

final function R_BlackBoard GetBlackBoard()
{
	local R_Bot Bot;
	if(OwnerBlackBoard == None)
	{
		Bot = GetBot();
		if(Bot != None)
		{
			OwnerBlackBoard = R_BlackBoard(Bot.GetBotObjectByClass(Class'RBots.R_BlackBoard'));
		}
	}
	return OwnerBlackBoard;
}

final function R_NavMesh GetNavMesh()
{
	local R_Bot Bot;
	if(CachedNavMesh == None)
	{
		Bot = GetBot();
		if(Bot != None)
		{
			CachedNavMesh = Bot.GetNavMesh();
		}
	}
	return CachedNavMesh;
}

final function R_NavMeshActorTracker GetNavMeshActorTracker()
{
	local R_BotManager LocalBotManager;
	local R_DynamicMapData MapData;
	if(CachedNavMeshActorTracker == None)
	{
		LocalBotManager = GetBotManager();
		if(LocalBotManager != None)
		{
			MapData = LocalBotManager.GetLoadedMapData();
			if(MapData != None)
			{
				CachedNavMeshActorTracker = MapData.GetNavMeshActorTracker();
			}
		}
	}
	return CachedNavMeshActorTracker;
}

//------------------------------------------------------------------------------
//	Overridable utility functions

// To be called in Tick
// If owning Bot has a Path, this will send the necessary movement input to
// PawnController to follow that Path
function FollowCurrentPath()
{
	local R_Bot Bot;
	local R_BotPawnController Controller;
	local Vector PathFollowInput;

	Bot = GetBot();
	Controller = GetBotPawnController();
	if(Bot != None && Controller != None)
	{
		PathFollowInput = Bot.GetPathFollowMovementInputVector();
		Controller.AddMovementInput_WorldSpace(PathFollowInput);
	}
}

//------------------------------------------------------------------------------
//	Your behavior needs to implement these
function BehaviorActivated();				// Called when this behavior is activated
function BehaviorTerminated();				// Called when this behavior is terminated
function BehaviorTick(float DeltaSeconds);	// Called by owning bot's Tick

function OnOwnedPlayerPawnDied();			// Called by Bot at the moment the owned PlayerPawn dies
function OnOwnedPlayerPawnRespawned();		// Called by Bot at the moment the owned PlayerPawn respawns

function OnNavMeshNodeIndexChanged(int OldNavMeshNodeIndex, int NewNavMeshNodeIndex);
function OnNavMeshPolyGroupIndexChanged(int OldNavMeshPolyGroupIndex, int NewNavMeshPolyGroupIndex);