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

static function bool FindNodeAndParentByName(Name NodeName, R_BTNode Root, out R_BTNode OutParent, out R_BTNode OutNode)
{
	local R_BTNode CurrentNode, CurrentChild;
	local R_BTNode NodeStack[128];
	local int NumNodes;
	local int NumChildren;
	local int i;

	if(Root == None || NodeName == '')
	{
		return false;
	}
	if(Root.GetNodeName() == NodeName)
	{
		OutParent = None;
		OutNode = Root;
		return true;
	}

	NodeStack[0] = Root;
	NumNodes = 1;
	while(NumNodes > 0)
	{
		--NumNodes;
		CurrentNode = NodeStack[NumNodes];

		if(CurrentNode.CanContainChildren())
		{
			NumChildren = CurrentNode.GetChildCount();
			for(i = 0; i < NumChildren; ++i)
			{
				CurrentChild = CurrentNode.GetChild(i);
				if(CurrentChild != None)
				{
					if(CurrentChild.GetNodeName() == NodeName)
					{
						OutNode = CurrentChild;
						OutParent = CurrentNode;
						return true;
					}
					NodeStack[NumNodes] = CurrentChild;
					++NumNodes;
				}
			}
		}
	}
	return false;
}