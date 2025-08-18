//==============================================================================
//	R_RBotsDebug
//	Mutator which provides debug view information
//
//	Use mutate commands for debug testing:
//
//	mutate rbots.debug.pathbot
//		- Summons and auto-targets a bot to test path finding
//
//	Toggle the visibility of debug views with the following:
//	mutate rbots.debug.view.navmesh
//	mutate rbots.debug.view.pathfinding
//==============================================================================
class R_RBotsDebug extends Mutator;

const Utilities = Class'RBots.R_BotUtilities';
const DebugRBotsCategory = 'RBots';

var bool bDrawDebugVisualization;
var bool bRegisteredHUDMutator;

// Cached RBot system classes
var R_BotManager BotManager;
var R_BotNavMesh NavMesh;

// String manager
const StringManagerClass = Class'RBots.R_RBotsDebug_StringManager';
var R_RBotsDebug_StringManager StringManager;

// Debug views
const MAX_DEBUG_VIEWS = 16;
var R_RBotsDebug_View DebugViews[16]; // Must match MAX_DEBUG_VIEWS

// Debug targeting
const PathBotClass = Class'RBots.R_RBotsDebug_PathBot';
var R_Bot DebugTarget;

simulated event PreBeginPlay()
{
	InitializeStringManager();
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
		Utilities.Static.RLog("Initialized debug string manager from class" @ StringManagerClass);
	}
	else
	{
		Utilities.Static.RLog("Failed to initialized debug string manager from class" @ StringManagerClass);
	}
}

simulated event BeginPlay()
{
	Super.BeginPlay();
	bRegisteredHUDMutator = false;

	EnableDefaultViews();

	Utilities.Static.RLog("R_RBotsDebug debug view created and default views enabled");
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
		Utilities.Static.RLog("Unable to attach RBotsDebug view, no owner");
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
				Utilities.Static.RLog("Registered RBotsDebug hud mutator");
            }
        }
	}
}

simulated function R_BotManager GetBotManager()
{
	local R_BotManager LocalBotManager;

	if(BotManager == None)
	{
		foreach AllActors(Class'RBots.R_BotManager', LocalBotManager)
		{
			break;
		}
	}

	if(LocalBotManager != None)
	{
		BotManager = LocalBotManager;
	}

	return BotManager;
}

simulated function R_BotNavMesh GetNavMesh()
{
	local R_BotNavMesh LocalNavMesh;

	if(NavMesh == None)
	{
		foreach AllActors(Class'RBots.R_BotNavMesh', LocalNavMesh)
		{
			break;
		}
	}

	if(LocalNavMesh != None)
	{
		NavMesh = LocalNavMesh;
	}

	return NavMesh;
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
		Utilities.Static.RLog("Cannot load DebugView" @ DebugViewClass @ "-- too many enabled");
		return;
	}

	DebugViews[i] = Spawn(DebugViewClass, Self);
	Utilities.Static.RLog("Enabled RBots Debug View for class" @ DebugViewClass);
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
			Utilities.Static.RLog("Disabled RBots Debug View for class" @ DebugViewClass);
		}
	}
}

simulated function EnableDefaultViews()
{
	EnableDebugView(Class'RBots.R_RBotsDebug_View_NavMesh');
	EnableDebugView(Class'RBots.R_RbotsDebug_View_PathFinding');
	EnableDebugView(Class'RBots.R_RBotsDebug_View_Bots');
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
	RegisterHUDMutator();
}

simulated event PostRender(Canvas C)
{
	local int i;
	local R_BotManager LocalBotManager;

	if(!bDrawDebugVisualization)
	{
		return;
	}

	// Setup string manager
	StringManager.Clear();

	// Add debug strings
	LocalBotManager = GetBotManager();
	if(LocalBotManager != None)
	{
		StringManager.AddClass(DebugRBotsCategory, "LoadedMapDataClass", LocalBotManager.LoadedMapDataClass);
	}
	else
	{
		StringManager.AddWarning(DebugRBotsCategory, "Invalid BotManager reference");
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
	local R_Bot NewBot;
	local R_RBotsDebug_PathBot PathBot;



	// Welcome string
	if(Caps(MutateString) == "RBOTS")
	{
		Sender.ClientMessage("RBots Debug Mutator -- Type 'mutate rbots.debug' for a list of available commands");
		return;
	}

	// Debug commands
	if(Caps(MutateString) == "RBOTS.DEBUG")
	{
		SendCommandList(Sender);
		return;
	}

	PathBot = R_RBotsDebug_PathBot(DebugTarget);

	// Command handling
	if(Caps(MutateString) == "RBOTS.DEBUG.PATHBOT")
	{
		Utilities.Static.RLog("Spawning a test pathing bot");
		NewBot = Spawn(PathBotClass);
		SetDebugTarget(NewBot);
	}
	else if(Caps(MutateString) == "RBOTS.DEBUG.PATHBOT.SETSTART")
	{
		if(PathBot == None)
		{
			Sender.ClientMessage("DebugTarget must be a PathBot");
			return;
		}
		PathBot.SetStartLocation(Sender.Location);
	}
	else if(Caps(MutateString) == "RBOTS.DEBUG.PATHBOT.SETEND")
	{
		if(PathBot == None)
		{
			Sender.ClientMessage("DebugTarget must be a PathBot");
			return;
		}
		PathBot.SetEndLocation(Sender.Location);
	}
	else if(Caps(MutateString) == "RBOTS.DEBUG.VIEW")
	{
		ToggleTopLevelDebugVisualization();
	}
	else if(Caps(MutateString) == "RBOTS.DEBUG.VIEW.NAVMESH")
	{
		ToggleDebugView(Class'RBots.R_RBotsDebug_View_NavMesh');
	}
	else if(Caps(MutateString) == "RBOTS.DEBUG.VIEW.PATHFINDING")
	{
		ToggleDebugView(Class'RBots.R_RBotsDebug_View_PathFinding');
	}
	else
	{
		Super.Mutate(MutateString, Sender);
	}
}

function SendCommandList(PlayerPawn Sender)
{
	Sender.ClientMessage("mutate rbots.debug.pathbot -- Summons and auto-targets a bot to test path finding");
	Sender.ClientMessage("mutate rbots.debug.pathbot.setstart -- Sets the start location for PathBot to Caller's current location");
	Sender.ClientMessage("mutate rbots.debug.pathbot.setend -- Sets the end location for PathBot to Caller's current location");
	Sender.ClientMessage("mutate rbots.debug.view -- Toggle all debug visualization");
	Sender.ClientMessage("mutate rbots.debug.view.navmesh -- Toggle nav mesh debug view");
	Sender.ClientMessage("mutate rbots.debug.view.pathfinding -- Toggle path finding debug view");
}

function SetDebugTarget(R_Bot NewDebugTarget)
{
	if(DebugTarget != None)
	{
		// Forget about old debug target here
	}

	DebugTarget = NewDebugTarget;
	Utilities.Static.RLog("RBotsDebug DebugTarget updated to" @ DebugTarget);
}

defaultproperties
{
	bDrawDebugVisualization=true
}