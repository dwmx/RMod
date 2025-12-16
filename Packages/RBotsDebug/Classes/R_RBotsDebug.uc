//==============================================================================
//	R_RBotsDebug
//	Mutator which provides debug view information
//
//	Use mutate commands for debug testing:
//	"mutate rbots"
//==============================================================================
class R_RBotsDebug extends RDebugTools.R_DBMutator config(RBotsDebug);

const Utilities = Class'RBots.R_BotUtilities';
const DebugLib = Class'RBots.R_RBots_DebugLibrary';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';

const LogCategory = 'Debug';
const DebugRBotsCategory = 'RBots';

// Cached RBot system classes
var R_RBotsServerActor RBots;
var R_BotManager BotManager;
var R_DynamicMapData MapData;
var R_NavMesh NavMesh;

// Command manager
const CommandNameSpace_RBots 			= 'RBots'; // Main debug commands and top level namespace
const CommandManagerClass_RBots			= Class'RBots.R_RBotsDebug_CommandManager_Bot';

const CommandNameSpace_NavMesh 			= 'NavMesh'; // NavMesh commands
const CommandManagerClass_NavMesh		= Class'RBots.R_RBotsDebug_CommandManager_NavMesh';

const CommandNameSpace_NavQuery			= 'NavQuery'; // NavQuery commands
const CommandManagerClass_NavQuery		= Class'RBots.R_RBotsDebug_CommandManager_NavQuery';

const CommandNameSpace_PathFinding 		= 'PathFinding'; // PathFinding commands
const CommandManagerClass_PathFinding	= Class'RBots.R_RBotsDebug_CommandManager_PathFinding';

const CommandNameSpace_Target			= 'Target'; // DebugTarget commands
const CommandManagerClass_Target		= Class'RBots.R_RBotsDebug_CommandManager_Target';

const CommandNameSpace_Player			= 'Player';
const CommandManagerClass_Player		= Class'RBots.R_RBotsDebug_CommandManager_Player';

const CommandNameSpace_BehaviorTree		= 'BehaviorTree';
const CommandManagerClass_BehaviorTree	= Class'RBots.R_RBotsDebug_CommandManager_BehaviorTree';

/*
simulated function R_RBotsDebug_CommandManager CreateCommandManager(Class<R_RBotsDebug_CommandManager> CommandManagerClass, Name NameSpace)
{
	local R_RBotsDebug_CommandManager NewCommandManager;

	if(CommandManagerClass == None)
	{
		Utilities.Static.RLog("CreateCommandManager failed -- CommandManagerClass == None");
		return None;
	}

	if(NameSpace == '')
	{
		Utilities.Static.RLog("CreateCommandManager failed -- NameSpace cannot be empty");
		return None;
	}

	NewCommandManager = new(None) CommandManagerClass;
	if(NewCommandManager == None)
	{
		Utilities.Static.RLog("CreateCommandManager failed -- Instantiation failed");
		return None;
	}

	NewCommandManager.Initialize(NameSpace);
	return NewCommandManager;
}
	*/

simulated function R_DBCommandManager InitializeCommandManagers()
{
	local R_RBotsDebug_CommandManager CommandManager_Main;
	local R_RBotsDebug_CommandManager CommandManager_NavMesh;
	local R_RBotsDebug_CommandManager CommandManager_NavQuery;
	local R_RBotsDebug_CommandManager CommandManager_PathFinding;
	local R_RBotsDebug_CommandManager CommandManager_Target;
	local R_RBotsDebug_CommandManager CommandManager_Player;
	local R_RBotsDebug_CommandManager CommandManager_BehaviorTree;

	CommandManager_Main 		= R_RBotsDebug_CommandManager(CreateCommandManager(CommandManagerClass_RBots, CommandNameSpace_RBots));
	CommandManager_NavMesh 		= R_RBotsDebug_CommandManager(CreateCommandManager(CommandManagerClass_NavMesh, CommandNameSpace_NavMesh));
	CommandManager_NavQuery 	= R_RBotsDebug_CommandManager(CreateCommandManager(CommandManagerClass_NavQuery, CommandNameSpace_NavQuery));
	CommandManager_PathFinding 	= R_RBotsDebug_CommandManager(CreateCommandManager(CommandManagerClass_PathFinding, CommandNameSpace_PathFinding));
	CommandManager_Target 		= R_RBotsDebug_CommandManager(CreateCommandManager(CommandManagerClass_Target, CommandNameSpace_Target));
	CommandManager_Player 		= R_RBotsDebug_CommandManager(CreateCommandManager(CommandManagerClass_Player, CommandNameSpace_Player));
	CommandManager_BehaviorTree = R_RBotsDebug_CommandManager(CreateCommandManager(CommandManagerClass_BehaviorTree, CommandNameSpace_BehaviorTree));

	CommandManager_Main.AddSubCommandManager(CommandManager_NavMesh);
	CommandManager_Main.AddSubCommandManager(CommandManager_NavQuery);
	CommandManager_Main.AddSubCommandManager(CommandManager_PathFinding);
	CommandManager_Main.AddSubCommandManager(CommandManager_Target);
	CommandManager_Main.AddSubCommandManager(CommandManager_Player);
	CommandManager_Main.AddSubCommandManager(CommandManager_BehaviorTree);

	Utilities.Static.RLog("Initialized command manager", LogCategory);

	return CommandManager_Main;
}

final function R_RBotsServerActor GetRBotsServerActor()
{
	local R_RBotsServerActor LocalRBots;

	if(RBots == None)
	{
		foreach AllActors(Class'RBots.R_RBotsServerActor', LocalRBots)
		{
			break;
		}
	}

	if(LocalRBots != None)
	{
		RBots = LocalRBots;
	}

	return RBots;
}

final function R_BotManager GetBotManager()
{
	local R_RBotsServerActor LocalRBots;

	if(BotManager == None)
	{
		LocalRBots = GetRBotsServerActor();
		if(LocalRBots != None)
		{
			BotManager = LocalRBots.GetBotManager();
		}
	}
	return BotManager;
}

final function R_DynamicMapData GetMapData()
{
	local R_RBotsServerActor LocalRBots;

	if(MapData == None)
	{
		LocalRBots = GetRBotsServerActor();
		if(LocalRBots != None)
		{
			MapData = LocalRBots.GetMapData();
		}
	}
	return MapData;
}

simulated function R_NavMesh GetNavMesh()
{
	local R_DynamicMapData LocalMapData;

	if(NavMesh == None)
	{
		LocalMapData = GetMapData();
		if(LocalMapData != None)
		{
			NavMesh = LocalMapData.GetNavMesh();
		}
	}

	return NavMesh;
}

function R_NavMeshActorTracker GetNavMeshActorTracker()
{
	local R_DynamicMapData LocalMapData;

	LocalMapData = GetMapData();
	if(LocalMapData != None)
	{
		return LocalMapData.GetNavMeshActorTracker();
	}
	return None;
}

simulated function PreDrawDebugViews(Canvas C, R_DBStringManager InStringManager)
{
	local R_RBotsServerActor LocalRBots;

	// Add debug strings
	LocalRBots = GetRBotsServerActor();
	if(LocalRBots != None)
	{
		InStringManager.AddClass(DebugRBotsCategory, "LoadedMapDataClass", LocalRBots.LoadedMapDataClass);
	}
	else
	{
		InStringManager.AddWarning(DebugRBotsCategory, "Invalid RBots reference");
	}

	InStringManager.AddActor(DebugRBotsCategory, "DebugTarget", DebugTarget);
}

function R_Bot GetDebugTargetBot()
{
	return R_Bot(DebugTarget);
}

defaultproperties
{
	// Leave all of these here -- default views will fail to load them from config at startup
	// if these are not in defaultproperties
	DefaultViews(0)=Class'RBots.R_RBotsDebug_View_NavMesh'
	DefaultViews(1)=Class'RBots.R_RBotsDebug_View_NavMeshSpatialQuery'
	DefaultViews(2)=Class'RBots.R_RBotsDebug_View_Bots'
	DefaultViews(3)=Class'RBots.R_RBotsDebug_View_PathFinding'
	DefaultViews(4)=Class'RBots.R_RBotsDebug_View_Player'
	DefaultViews(5)=Class'RBots.R_RBotsDebug_View_BehaviorTree'
}