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
	BuildBehaviorTree(BT);
	Root = BT.GetRoot();
}

function BuildBehaviorTree(R_BTBuilder BT);