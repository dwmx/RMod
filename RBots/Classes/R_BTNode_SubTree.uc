//==============================================================================
//	R_BTNode_SubTree
//	SubTree nodes contain a reference to another BehaviorTree asset, and
//	pass execution on to that Tree's Root node
//==============================================================================
class R_BTNode_SubTree extends R_BTNode_Composite;

var private R_BehaviorTree SubTree;

static function String GetNodeClassString() { return "SubTree"; }

function String GetNodeDisplayString()
{
	local Class<R_BehaviorTree> BehaviorTreeClass;
	if(SubTree == None)
	{
		return "ERR: INVALID";
	}

	BehaviorTreeClass = SubTree.Class;
	if(BehaviorTreeClass != None)
	{
		return String(BehaviorTreeClass);
	}

	return "ERR: INVALID";
}

function SetSubTree(R_BehaviorTree NewSubTree)
{
	SubTree = NewSubTree;
}

function R_BehaviorTree GetSubTree()
{
	return SubTree;
}

function Class<R_BehaviorTree> GetSubTreeClass()
{
	if(SubTree != None)
	{
		return SubTree.Class;
	}
	return None;
}

function AddChild(R_BTNode ChildNode)
{
	local String LogString;

	LogString = "AddChild was called for SubTree node -- This should never be called";
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function bool IsFull()
{
	// SubTree node is considered to always be full
	return true;
}

function int GetChildCount()
{
	local R_BTNode_Root SubTreeRoot;
	if(SubTree != None)
	{
		SubTreeRoot = R_BTNode_Root(SubTree.GetRoot());
		if(SubTreeRoot != None)
		{
			return SubTreeRoot.GetChildCount();
		}
	}
	return 0;
}

function R_BTNode GetChild(int Index)
{
	local R_BTNode_Root SubTreeRoot;
	local R_BTNode SubTreeChild;

	if(SubTree == None)
	{
		return None;
	}

	SubTreeRoot = R_BTNode_Root(SubTree.GetRoot());
	if(SubTreeRoot == None)
	{
		return None;
	}

	return SubTreeRoot.GetChild(Index);
}

function BaseNodeActivated(R_BehaviorTreeContext Context)
{
	local R_BTNode_Root SubTreeRoot;
	local R_BTNode SubTreeChild;

	Super.BaseNodeActivated(Context);

	if(Context == None || SubTree == None)
	{
		return;
	}

	SubTreeRoot = R_BTNode_Root(SubTree.GetRoot());
	if(SubTreeRoot != None)
	{
		SubTreeChild = SubTreeRoot.GetChild(0);
		if(SubTreeChild != None)
		{
			SubTreeChild.BaseNodeActivated(Context);
		}
	}
}

function BaseNodeDeactivated(R_BehaviorTreeContext Context)
{
	local R_BTNode_Root SubTreeRoot;
	local R_BTNode SubTreeChild;

	Super.BaseNodeDeactivated(Context);

	if(Context == None || SubTree == None)
	{
		return;
	}

	SubTreeRoot = R_BTNode_Root(SubTree.GetRoot());
	if(SubTreeRoot != None)
	{
		SubTreeChild = SubTreeRoot.GetChild(0);
		if(SubTreeChild != None)
		{
			SubTreeChild.BaseNodeDeactivated(Context);
		}
	}
}

function int Tick(R_BehaviorTreeContext Context, float DeltaSeconds)
{
	local R_BTNode_Root SubTreeRoot;
	local R_BTNode SubTreeChild;

	if(Context == None || SubTree == None)
	{
		return NodeFail;
	}

	SubTreeRoot = R_BTNode_Root(SubTree.GetRoot());
	if(SubTreeRoot == None)
	{	// Root must be valid or there is no tree
		return NodeFail;
	}

	SubTreeChild = SubTreeRoot.GetChild(0);
	if(SubTreeChild == None)
	{	// SubTree run from the Root's first child, not from the Root itself
		return NodeFail;
	}

	return SubTreeChild.Tick(Context, DeltaSeconds);
}