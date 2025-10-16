//==============================================================================
//	R_BotBehavior
//	Base class for all Bot behavior
//==============================================================================
class R_BotBehavior extends R_RBotsObject abstract;
//class R_BotBehavior extends R_BotObject abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'Behavior';

const NavLib = Class'RBots.R_NavLibrary';

var private R_Bot OwnerBot;
var private PlayerPawn OwnerPlayerPawn;
var private R_RBotsServerActor RBots;

var private R_BotPerception OwnerPerception;
var private R_BotPawnController OwnerController;
var private R_BlackBoard OwnerBlackBoard;
var private R_NavContext OwnerNavContext;
var private R_NavMesh CachedNavMesh;
var private R_NavMeshActorTracker CachedNavMeshActorTracker;

var private Class<R_BehaviorTree> BehaviorTreeClass;
var private R_BehaviorTree BehaviorTree;

//var private R_BTNode BehaviorTree;
var private R_BTContext BehaviorTreeContext;
var private R_BlackBoard BlackBoard;

//------------------------------------------------------------------------------
//	BlackBoard Keys
const BBKey_InventoryTarget 	= 'InventoryTarget';	// Actor
const BBKey_WantWeapon 			= 'WantWeapon';			// Float
const BBKey_WantShield			= 'WantShield';			// Float
const BBKey_WantHealth			= 'WantHealth';			// Float
const BBKey_WantStrength		= 'WantStrength';		// Float
const BBKey_WantRunePower		= 'WantRunePower';		// Float

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
	InitializeBehaviorTree();
}

final function InitializeBehaviorTree()
{
	local String LogString;
	local R_RBotsServerActor RBots;
	local R_VirtualAssetManager AssMan; // heh

	if(BehaviorTreeClass == None)
	{
		LogString = "No BehaviorTreeClass configured for class" @ Self.Class;
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
	}
	else
	{
		RBots = GetRBotsServerActor();
		if(RBots != None)
		{
			AssMan = RBots.GetAssetManager();
			if(AssMan != None)
			{
				BehaviorTree = R_BehaviorTree(AssMan.LoadAsset(BehaviorTreeClass));
			}
		}
	}
	
	// Create BlackBoard
	BlackBoard = new(None) Class'RBots.R_BlackBoard_Implementation';
	if(BehaviorTree != None)
	{
		BehaviorTree.AddKeySetToBlackBoard(BlackBoard);
	}

	// Create BT Context
	BehaviorTreeContext = new(None) Class'RBots.R_BTContext_Implementation';
	BehaviorTreeContext.Initialize();
	BehaviorTreeContext.SetBot(GetBot());
	BehaviorTreeContext.SetBlackBoard(BlackBoard);
}

final function R_Bot GetBot() { return OwnerBot; }
final function PlayerPawn GetPlayerPawn() { return OwnerPlayerPawn; }

final function Vector GetPlayerPawnLocation()
{
	local PlayerPawn PP;

	PP = GetPlayerPawn();
	if(PP != None)
	{
		return PP.Location;
	}
	return Vect(0,0,0);
}

final function R_RBotsServerActor GetRBotsServerActor()
{
	local R_Bot Bot;
	if(RBots == None)
	{
		Bot = GetBot();
		if(Bot != None)
		{
			RBots = Bot.GetRBotsServerActor();
		}
	}
	return RBots;
}

final function R_NavContext GetNavContext()
{
	local R_Bot Bot;
	if(OwnerNavContext == None)
	{
		Bot = GetBot();
		if(Bot != None)
		{
			OwnerNavContext = Bot.GetNavContext();
		}
	}
	return OwnerNavContext;
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

final function R_BehaviorTree GetBehaviorTree()
{
	return BehaviorTree;
}

final function R_BlackBoard GetBlackBoard()
{
	return BlackBoard;
}

final function R_BTContext GetBehaviorTreeContext()
{
	return BehaviorTreeContext;
}

final function R_NavQueryInterface GetNavQueryInterface()
{
	local R_Bot Bot;

	Bot = GetBot();
	if(Bot != None)
	{
		return Bot.GetNavQueryInterface();
	}
	return None;
}

final function bool GetNavDirectionTowardsNavZone(int NavZoneIndex, out Vector OutDirection)
{
	local R_NavQueryInterface NavQueryInterface;
	local Vector Location;

	NavQueryInterface = GetNavQueryInterface();
	if(NavQueryInterface != None)
	{
		Location = GetPlayerPawnLocation();
		if(NavQueryInterface.FindDirectionTowardsNavZoneByIndex(
			Location,
			NavZoneIndex,
			OutDirection))
		{
			return true;
		}
	}

	OutDirection = Vect(0,0,0);
	return false;
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

final function BaseBehaviorTick(float DeltaSeconds)
{
	local R_BTNode BehaviorTreeRoot;

	if(BehaviorTreeContext != None && BehaviorTree != None)
	{
		BehaviorTreeContext.Tick(DeltaSeconds);
		BehaviorTree.Tick(BehaviorTreeContext, DeltaSeconds);
	}
	
	BehaviorTick(DeltaSeconds);
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