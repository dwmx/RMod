//==============================================================================
//	R_RBotsDebug
//	Mutator which provides debug view information
//
//	Use mutate commands for debug testing:
//	"mutate rbots"
//==============================================================================
class R_RBotsDebug extends Mutator config(RBotsDebug);

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'Debug';
const DebugRBotsCategory = 'RBots';

var bool bDrawDebugVisualization;
var bool bRegisteredHUDMutator;

// Cached RBot system classes
var R_RBotsServerActor RBots;
var R_BotManager BotManager;
var R_DynamicMapData MapData;
var R_NavMesh NavMesh;

// Command manager
var R_RBotsDebug_CommandManager CommandManager;
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

// String manager
const StringManagerClass = Class'RBots.R_RBotsDebug_StringManager';
var R_RBotsDebug_StringManager StringManager;

// Debug views
const MAX_DEBUG_VIEWS = 16;
var R_RBotsDebug_View DebugViews[16]; // Must match MAX_DEBUG_VIEWS
var config Class<R_RBotsDebug_View> DefaultViews[ArrayCount(DebugViews)];

// Debug targeting
//const PathBotClass = Class'RBots.R_RBotsDebug_PathBot';
var R_Bot DebugTarget;

simulated event PreBeginPlay()
{
	InitializeCommandManagers();
	InitializeStringManager();
}

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

simulated function InitializeCommandManagers()
{
	local R_RBotsDebug_CommandManager CommandManager_Main;
	local R_RBotsDebug_CommandManager CommandManager_NavMesh;
	local R_RBotsDebug_CommandManager CommandManager_NavQuery;
	local R_RBotsDebug_CommandManager CommandManager_PathFinding;
	local R_RBotsDebug_CommandManager CommandManager_Target;
	local R_RBotsDebug_CommandManager CommandManager_Player;

	CommandManager_Main = CreateCommandManager(CommandManagerClass_RBots, CommandNameSpace_RBots);
	CommandManager_NavMesh = CreateCommandManager(CommandManagerClass_NavMesh, CommandNameSpace_NavMesh);
	CommandManager_NavQuery = CreateCommandManager(CommandManagerClass_NavQuery, CommandNameSpace_NavQuery);
	CommandManager_PathFinding = CreateCommandManager(CommandManagerClass_PathFinding, CommandNameSpace_PathFinding);
	CommandManager_Target = CreateCommandManager(CommandManagerClass_Target, CommandNameSpace_Target);
	CommandManager_Player = CreateCommandManager(CommandManagerClass_Player, CommandNameSpace_Player);

	CommandManager_Main.AddSubCommandManager(CommandManager_NavMesh);
	CommandManager_Main.AddSubCommandManager(CommandManager_NavQuery);
	CommandManager_Main.AddSubCommandManager(CommandManager_PathFinding);
	CommandManager_Main.AddSubCommandManager(CommandManager_Target);
	CommandManager_Main.AddSubCommandManager(CommandManager_Player);

	CommandManager = CommandManager_Main;

	Utilities.Static.RLog("Initialized command manager", LogCategory);
}

simulated function InitializeStringManager()
{
	if(StringManager != None)
	{
		StringManager = None;
	}

	StringManager = new(None) StringManagerClass;
	if(StringManager != None)
	{
		Utilities.Static.RLog("Initialized debug string manager from class" @ StringManagerClass, LogCategory);
	}
	else
	{
		Utilities.Static.RLog("Failed to initialized debug string manager from class" @ StringManagerClass, LogCategory);
	}
}

simulated event BeginPlay()
{
	Super.BeginPlay();
	bRegisteredHUDMutator = false;

	EnableDefaultViews();

	Utilities.Static.RLog("R_RBotsDebug debug view created and default views enabled", LogCategory);
}

simulated function RegisterHUDMutator()
{
	local HUD MyHUD;
	local Pawn P;
	local PlayerPawn PP;

	if(bRegisteredHUDMutator)
	{
		return;
	}

	// Attach self to the first Pawn with a Viewport
	for(P = Level.PawnList; P != None; P = P.NextPawn)
	{
		PP = PlayerPawn(P);
		if(PP != None && PP.Player != None && Viewport(PP.Player) != None)
		{
			SetOwner(PP);
		}
	}

	if(Owner == None)
	{
		Utilities.Static.RLog("Unable to attach RBotsDebug view, no owner", LogCategory);
		bRegisteredHUDMutator = true;
		return;
	}

	// Register
	if((Level.NetMode == NM_Client && Owner != None && Owner.Role == ROLE_AutonomousProxy)
	|| 	Level.NetMode == NM_Standalone
	||	Level.NetMode == NM_ListenServer)
	{
		if(PlayerPawn(Owner) != None)
        {
            MyHUD = PlayerPawn(Owner).MyHUD;
            if(MyHUD != None)
            {
                NextHUDMutator = MyHUD.HUDMutator;
                MyHUD.HUDMutator = Self;
                bHUDMutator = true;
                bRegisteredHUDMutator = true;
				Utilities.Static.RLog("Registered RBotsDebug hud mutator", LogCategory);
            }
        }
	}
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

simulated function EnableDebugView(Class<R_RBotsDebug_View> DebugViewClass)
{
	local int i;

	if(DebugViewClass == None)
	{
		return;
	}

	// Ensure an instance of this view is not already enabled
	for(i = 0; i < MAX_DEBUG_VIEWS; ++i)
	{
		if(DebugViews[i] != None && DebugViews[i].Class == DebugViewClass)
		{
			return;
		}
	}

	for(i = 0; i < MAX_DEBUG_VIEWS; ++i)
	{
		if(DebugViews[i] == None)
		{
			break;
		}
	}

	if(i == MAX_DEBUG_VIEWS)
	{
		Utilities.Static.RLog("Cannot load DebugView" @ DebugViewClass @ "-- too many enabled", LogCategory);
		return;
	}

	DebugViews[i] = Spawn(DebugViewClass, Self);
	if(DebugViews[i] != None)
	{
		DebugViews[i].DebugTargetChanged(None, DebugTarget);
	}
	Utilities.Static.RLog("Enabled RBots Debug View for class" @ DebugViewClass, LogCategory);

	// Update default views for config
	AddDefaultDebugView(DebugViewClass);
}

simulated event AddDefaultDebugView(Class<R_RBotsDebug_View> DebugViewClass)
{
	local int i;

	for(i = 0; i < ArrayCount(DefaultViews); ++i)
	{ // Make sure this view is not already in default views
		if(DefaultViews[i] == DebugViewClass)
		{
			return;
		}
	}

	for(i = 0; i < ArrayCount(DefaultViews); ++i)
	{
		if(DefaultViews[i] == None)
		{
			break;
		}
	}

	if(i < ArrayCount(DefaultViews))
	{
		DefaultViews[i] = DebugViewClass;
	}

	SaveConfig();
}

simulated event DisableDebugView(Class<R_RBotsDebug_View> DebugViewClass)
{
	local int i;

	if(DebugViewClass == None)
	{
		return;
	}

	for(i = 0; i < MAX_DEBUG_VIEWS; ++i)
	{
		if(DebugViews[i] != None && DebugViews[i].Class == DebugViewClass)
		{
			DebugViews[i].Destroy();
			DebugViews[i] = None;
			Utilities.Static.RLog("Disabled RBots Debug View for class" @ DebugViewClass, LogCategory);

			RemoveDefaultDebugView(DebugViewClass);
		}
	}
}

simulated event RemoveDefaultDebugView(Class<R_RBotsDebug_View> DebugViewClass)
{
	local int i;

	for(i = 0; i < ArrayCount(DefaultViews); ++i)
	{
		if(DefaultViews[i] == DebugViewClass)
		{
			DefaultViews[i] = None;
			SaveConfig();
			return;
		}
	}
}

simulated function R_Bot GetDebugTarget()
{
	return DebugTarget;
}

simulated function R_RBotsDebug_View GetDebugView(Class<R_RBotsDebug_View> DebugViewClass)
{
	local int i;

	if(DebugViewClass == None)
	{
		return None;
	}

	for(i = 0; i < MAX_DEBUG_VIEWS; ++i)
	{
		if(DebugViews[i] != None && DebugViews[i].Class == DebugViewClass)
		{
			return DebugViews[i];
		}
	}

	return None;
}

simulated function EnableDefaultViews()
{
	local int i;

	for(i = 0; i < ArrayCount(DefaultViews); ++i)
	{
		if(DefaultViews[i] != None)
		{
			EnableDebugView(DefaultViews[i]);
		}
	}
}

simulated function bool IsViewEnabled(Class<R_RbotsDebug_View> DebugViewClass)
{
	local int i;

	for(i = 0; i < MAX_DEBUG_VIEWS; ++i)
	{
		if(DebugViews[i] != None && DebugViews[i].Class == DebugViewClass)
		{
			return true;
		}
	}

	return false;
}

simulated function ToggleDebugView(Class<R_RbotsDebug_View> DebugViewClass)
{
	if(IsViewEnabled(DebugViewClass))
	{
		DisableDebugView(DebugViewClass);
	}
	else
	{
		EnableDebugView(DebugViewClass);
	}
}

function SetTopLevelDebugVisualization(bool bNewTopLevelDebugVisualization)
{
	bDrawDebugVisualization = bNewTopLevelDebugVisualization;
}

function ToggleTopLevelDebugVisualization()
{
	SetTopLevelDebugVisualization(!bDrawDebugVisualization);
}

simulated event Tick(float DeltaSeconds)
{
	// Ensure HUD mutator is registered
	RegisterHUDMutator();

	// Validate DebugTarget reference
	if(DebugTarget != None)
	{
		if(!Utilities.Static.IsValidActor(DebugTarget))
		{
			SetDebugTarget(None);
		}
	}	
}

simulated event PostRender(Canvas C)
{
	local int i;
	local R_RBotsServerActor LocalRBots;

	if(!bDrawDebugVisualization)
	{
		return;
	}

	// Setup debug draw managers
	StringManager.Clear();

	// Add debug strings
	LocalRBots = GetRBotsServerActor();
	if(LocalRBots != None)
	{
		StringManager.AddClass(DebugRBotsCategory, "LoadedMapDataClass", LocalRBots.LoadedMapDataClass);
	}
	else
	{
		StringManager.AddWarning(DebugRBotsCategory, "Invalid RBots reference");
	}

	StringManager.AddActor(DebugRBotsCategory, "DebugTarget", DebugTarget);

	for(i = 0; i < MAX_DEBUG_VIEWS; ++i)
	{
		if(DebugViews[i] != None)
		{
			DebugViews[i].DrawDebugView(C, StringManager);
		}
	}

	StringManager.DrawStringManager(C);
}

function Mutate(string MutateString, PlayerPawn Sender)
{
	if(CommandManager != None)
	{
		if(CommandManager.ReceiveCommand(MutateString, Self, Sender))
		{
			return;
		}
	}

	if(NextMutator != None)
	{
		NextMutator.Mutate(MutateString, Sender);
	}
}

function SetDebugTarget(R_Bot NewDebugTarget)
{
	local R_Bot OldDebugTarget;
	local int i;

	if(Utilities.Static.IsValidActor(DebugTarget))
	{
		// Forget about old debug target here
	}

	OldDebugTarget = DebugTarget;
	DebugTarget = NewDebugTarget;

	for(i = 0; i < MAX_DEBUG_VIEWS; ++i)
	{
		if(Utilities.Static.IsValidActor(DebugViews[i]))
		{
			DebugViews[i].DebugTargetChanged(OldDebugTarget, DebugTarget);
		}
	}

	Utilities.Static.RLog("RBotsDebug DebugTarget updated to" @ DebugTarget, LogCategory);
}

defaultproperties
{
	bDrawDebugVisualization=true
	// Leave all of these here -- default views will fail to load them from config at startup
	// if these are not in defaultproperties
	DefaultViews(0)=Class'RBots.R_RBotsDebug_View_NavMesh'
	DefaultViews(1)=Class'RBots.R_RBotsDebug_View_NavMeshSpatialQuery'
	DefaultViews(2)=Class'RBots.R_RBotsDebug_View_Bots'
	DefaultViews(3)=Class'RBots.R_RBotsDebug_View_PathFinding'
	DefaultViews(4)=Class'RBots.R_RBotsDebug_View_Player'
}