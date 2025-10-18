//==============================================================================
//	R_BehaviorTree
//	Base asset class for behavior trees
//==============================================================================
class R_BehaviorTree extends R_VirtualAsset abstract;

const LogCategory = 'BehaviorTree';

const BTBuilderClass = Class'RBots.R_BTBuilder_Implementation';

var private R_BTNode Root;

//------------------------------------------------------------------------------

function Load()
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;
	local R_BTBuilder BT;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{	// Must have reference to RBots
		LogString = "Invalid RBotsServerActor reference";
		GoTo LoadFailedWithLogString;
	}

	// Defer initialization on BTBuilder so that we can set the owning BehaviorTree first
	BT = R_BTBuilder(LocalRBots.CreateRBotsObject(BTBuilderClass, Self, true));
	if(BT == None)
	{	// Can't built without a BTBuilder
		LogString = "Failed to instantiate BTBuilder from class:" @ BTBuilderClass;
		GoTo LoadFailedWithLogString;
	}

	BT.SetOwningBehaviorTree(Self);
	BT.Initialize(); // Resolve deferred initialization

	BuildBehaviorTree(BT);
	Root = BT.GetRoot();
	return;

LoadFailedWithLogString:
	LogString = "Load failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function BuildBehaviorTree(R_BTBuilder BT);
function AddKeySetToBlackBoard(R_BlackBoard BlackBoard);

function R_BTNode GetRoot() { return Root; }

//------------------------------------------------------------------------------

function Tick(R_BTContext Context, float DeltaSeconds)
{
	if(Context == None || Root == None)
	{
		return;
	}

	Root.Tick(Context, DeltaSeconds);
}