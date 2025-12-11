//==============================================================================
//	R_DBMutator
//	General purpose mutator for adding debug functionality to any package
//	This mutator is the center point for three main pieces:
//	- StringManager -- For drawing debug text on the screen
//	- CommandManager -- For adding custom debug commands
//	- DebugViews -- For adding debug visualization overlays that can be toggled
//==============================================================================
class R_DBMutator extends Mutator config(RDebugTools);

const Utilities = Class'RBase.R_AUtilityLibrary';

const LogCategory = 'Debug';
const LogSubCategory = 'Mutator';

var private bool bDrawDebugVisualization;
var private bool bRegisteredHUDMutator;

// Command manager
const CommandManagerClass = Class'RDebugTools.R_DBCommandManager';
var private R_DBCommandManager CommandManager;

// String manager
const StringManagerClass = Class'RDebugTools.R_DBStringManager';
var private R_DBStringManager StringManager;

// Debug views
const MaxDebugViews = 16;
var private R_DBView DebugViews[16];
var private config Class<R_DBView> DefaultViews[ArrayCount(DebugViews)];

// Debug target actor
var Actor DebugTarget;

simulated function PreBeginPlay()
{
	BaseInitializeCommandManagers();
	InitializeStringManager();
}

simulated final function BaseInitializeCommandManagers()
{
	CommandManager = InitializeCommandManagers();
}

simulated function R_DBCommandManager InitializeCommandManagers()
{}

simulated function InitializeStringManager()
{
	StringManager = new(None) StringManagerClass;
}

simulated event BeginPlay()
{
	Super.BeginPlay();
	bRegisteredHUDMutator = false;
	EnableDefaultViews();
	Utilities.Static.RLog("DebugMutator created and initialized from class" @ Self.Class, LogCategory, LogSubCategory);
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
		Utilities.Static.RLog("Unable to attach DebugMutator view, no owner", LogCategory, LogSubCategory);
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

simulated function EnableDebugView(Class<R_DBView> DebugViewClass)
{
	local int i;

	if(DebugViewClass == None)
	{
		return;
	}

	// Ensure an instance of this view is not already enabled
	for(i = 0; i < MaxDebugViews; ++i)
	{
		if(DebugViews[i] != None && DebugViews[i].Class == DebugViewClass)
		{
			return;
		}
	}

	for(i = 0; i < MaxDebugViews; ++i)
	{
		if(DebugViews[i] == None)
		{
			break;
		}
	}

	if(i == MaxDebugViews)
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

simulated event AddDefaultDebugView(Class<R_DBView> DebugViewClass)
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

simulated event DisableDebugView(Class<R_DBView> DebugViewClass)
{
	local int i;

	if(DebugViewClass == None)
	{
		return;
	}

	for(i = 0; i < MaxDebugViews; ++i)
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

simulated event RemoveDefaultDebugView(Class<R_DBView> DebugViewClass)
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

simulated function Actor GetDebugTarget()
{
	return DebugTarget;
}

simulated function R_DBView GetDebugView(Class<R_DBView> DebugViewClass)
{
	local int i;

	if(DebugViewClass == None)
	{
		return None;
	}

	for(i = 0; i < MaxDebugViews; ++i)
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

simulated function bool IsViewEnabled(Class<R_DBView> DebugViewClass)
{
	local int i;

	for(i = 0; i < MaxDebugViews; ++i)
	{
		if(DebugViews[i] != None && DebugViews[i].Class == DebugViewClass)
		{
			return true;
		}
	}

	return false;
}

simulated function ToggleDebugView(Class<R_DBView> DebugViewClass)
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

function bool IsDrawingDebugVisualization()
{
	return bDrawDebugVisualization;
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

	if(!bDrawDebugVisualization)
	{
		return;
	}

	// Setup debug draw managers
	StringManager.Clear();

	PreDrawDebugViews(C, StringManager);

	// Draw each view
	for(i = 0; i < MaxDebugViews; ++i)
	{
		if(DebugViews[i] != None)
		{
			DebugViews[i].DrawDebugView(C, StringManager);
		}
	}

	StringManager.DrawStringManager(C);
}

simulated function PreDrawDebugViews(Canvas C, R_DBStringManager InStringManager)
{}

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

function SetDebugTarget(Actor NewDebugTarget)
{
	local Actor OldDebugTarget;
	local int i;

	if(Utilities.Static.IsValidActor(DebugTarget))
	{
		// Forget about old debug target here
	}

	OldDebugTarget = DebugTarget;
	DebugTarget = NewDebugTarget;

	for(i = 0; i < MaxDebugViews; ++i)
	{
		if(Utilities.Static.IsValidActor(DebugViews[i]))
		{
			DebugViews[i].DebugTargetChanged(OldDebugTarget, DebugTarget);
		}
	}

	Utilities.Static.RLog("DBMutator DebugTarget updated to" @ DebugTarget, LogCategory, LogSubCategory);
}

defaultproperties
{
	bDrawDebugVisualization=true
}