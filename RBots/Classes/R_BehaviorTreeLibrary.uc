//==============================================================================
//	R_BehaviorTreeLibrary
//	Reuseable utility functions for BehaviorTrees
//==============================================================================
class R_BehaviorTreeLibrary extends R_RBotsObject abstract;

// DoesBTContainNodeWithName
// Checks all nodes in the given tree and returns true if any of them have the given name
// If bIncludeSubTrees is false, this function will ignore SubTree nodes
static function bool DoesBTContainNodeWithName(R_BTNode Root, Name NodeName, bool bIncludeSubTrees)
{
	local R_BTNode NodeStack[256];
	local int NumNodes;
	local R_BTNode CurrentNode;
	local int NumChildren;
	local int i;

	if(Root == None)
	{
		return false;
	}

	NodeStack[0] = Root;
	NumNodes = 1;
	while(NumNodes > 0)
	{
		--NumNodes;
		CurrentNode = NodeStack[0];
		if(!bIncludeSubTrees && R_BTNode_SubTree(CurrentNode) != None)
		{
			continue;
		}

		if(CurrentNode.GetNodeName() == NodeName)
		{
			return true;
		}

		if(CurrentNode.CanContainChildren())
		{
			NumChildren = CurrentNode.GetChildCount();
			for(i = 0; i < NumChildren; ++i)
			{
				NodeStack[NumNodes] = CurrentNode.GetChild(i);
				++NumNodes;
			}
		}
	}
	return false;
}