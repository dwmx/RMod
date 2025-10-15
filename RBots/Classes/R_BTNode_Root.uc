//==============================================================================
//	R_BTNode_Root
//	Top level node in every Behavior Tree
//==============================================================================
class R_BTNode_Root extends R_BTNode_Composite;

var private R_BTNode Child;

function AddChild(R_BTNode ChildNode)
{
	Child = ChildNode;
}

function bool IsFull()
{
	if(Child != None)
	{
		return true;
	}
	return false;
}