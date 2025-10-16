//==============================================================================
//	R_BehaviorTree
//	Base asset class for behavior trees
//==============================================================================
class R_BehaviorTree extends R_VirtualAsset abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BehaviorTree';

const BTBuilderClass = Class'RBots.R_BTBuilder_Implementation';

var private R_BTNode Root;

function Load()
{
	local R_BTBuilder BT;

	BT = new(None) BTBuilderClass;
	BT.Initialize();
	BuildBehaviorTree(BT);
	Root = BT.GetRoot();
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