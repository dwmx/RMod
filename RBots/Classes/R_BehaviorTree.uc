//==============================================================================
//	R_BehaviorTree
//	Base asset class for behavior trees
//==============================================================================
class R_BehaviorTree extends R_VirtualAsset abstract;

const LogCategory = 'BehaviorTree';

const BTBuilderClass = Class'RBots.R_BTB_TreeBuilderImpl';

var private R_BTNode Root;

//------------------------------------------------------------------------------

function Load()
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;
	local R_BTB_TreeBuilder BT;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{	// Must have reference to RBots
		LogString = "Invalid RBotsServerActor reference";
		GoTo LoadFailedWithLogString;
	}

	// Defer initialization on BTBuilder so that we can set the owning BehaviorTree first
	BT = R_BTB_TreeBuilder(LocalRBots.CreateRBotsObject(BTBuilderClass, Self, true));
	if(BT == None)
	{	// Can't built without a BTBuilder
		LogString = "Failed to instantiate BTBuilder from class:" @ BTBuilderClass;
		GoTo LoadFailedWithLogString;
	}

	BT.SetOwningBehaviorTree(Self);
	BT.Initialize(); // Resolve deferred initialization
	if(!BT.IsTreeBuilderInitialized())
	{
		LogString = "TreeBuilder failed to initialize";
		GoTo LoadFailedWithLogString;
	}

	BuildBehaviorTree(BT);
	Root = BT.GetRoot();
	return;

LoadFailedWithLogString:
	LogString = "Load failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function BuildBehaviorTree(R_BTB_TreeBuilder TB);
function AddKeySetToBlackBoard(R_BlackBoard BlackBoard);

function R_BTNode GetRoot() { return Root; }

// Return true if this BehaviorTree contains the given Tree in a SubTreeNode
// Necessary for avoiding cyclic trees
function bool ContainsSubTree(Class<R_BehaviorTree> BehaviorTreeClass)
{
	local R_BTNode NodeStack[256];
	local int NumNodes;
	local R_BTNode Node, ChildNode;
	local R_BTNode_SubTree SubTreeNode;
	local R_BTNode_Composite CompositeNode;
	local int ChildCount;
	local int i;

	NumNodes = 0;
	Node = GetRoot();
	if(Node != None)
	{
		NodeStack[0] = Node;
		NumNodes = 1;
	}

	while(NumNodes > 0)
	{
		--NumNodes;
		Node = NodeStack[NumNodes];

		SubTreeNode = R_BTNode_SubTree(Node);
		if(SubTreeNode != None)
		{
			if(SubTreeNode.GetSubTreeClass() == BehaviorTreeClass)
			{
				return true;
			}
		}

		CompositeNode = R_BTNode_Composite(Node);
		if(CompositeNode != None)
		{
			ChildCount = CompositeNode.GetChildCount();
			for(i = 0; i < ChildCount; ++i)
			{
				ChildNode = CompositeNode.GetChild(i);
				if(ChildNode != None)
				{
					NodeStack[NumNodes] = ChildNode;
					++NumNodes;
				}
			}
		}
	}
	return false;
}

//------------------------------------------------------------------------------

function Tick(R_BehaviorTreeContext Context, float DeltaSeconds)
{
	if(Context == None || Root == None)
	{
		return;
	}

	Root.Tick(Context, DeltaSeconds);
}