//==============================================================================
//	R_RBotsDebug
//	Mutator which provides debug view information
//==============================================================================
class R_RBotsDebug extends Mutator;

const Utilities = Class'RBots.R_BotUtilities';
var bool bRegisteredHUDMutator;

// Debug views
const MAX_DEBUG_VIEWS = 16;
var R_RBotsDebug_View DebugViews[16]; // Must match MAX_DEBUG_VIEWS

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
	if((Level.NetMode == NM_Client && Owner != None && Owner.Role == ROLE_AutonomousProxy) || Level.NetMode == NM_Standalone)
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

	DebugViews[i] = Spawn(DebugViewClass);
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
	EnableDebugView(Class'RBots.R_RBotsDebug_View_Bots');
}

simulated event Tick(float DeltaSeconds)
{
	RegisterHUDMutator();
}

simulated event PostRender(Canvas C)
{
	local int i;

	for(i = 0; i < MAX_DEBUG_VIEWS; ++i)
	{
		if(DebugViews[i] != None)
		{
			DebugViews[i].PostRender(C);
		}
	}
}