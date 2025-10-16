//==============================================================================
//	R_BTNode_CompositeArray
//==============================================================================
class R_BTNode_CompositeArray extends R_BTNode_Composite abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BTNodeCompositeArray';

var private R_BTNode Children[16];
var private int NumChildren;

function BaseNodeActivated(R_BTContext Context)
{
	Context.SetNodeActiveChildIndex(GetNodeUID(), InvalidIndex);
	Super.BaseNodeActivated(Context);
}

function BaseNodeDeactivated(R_BTContext Context)
{
	Context.SetNodeActiveChildIndex(GetNodeUID(), InvalidIndex);
	Super.BaseNodeActivated(Context);
}

function Initialize()
{
	local int i;

	Super.Initialize();
	for(i = 0; i < ArrayCount(Children); ++i)
	{
		Children[i] = None;
	}
	NumChildren = 0;
}

function bool IsFull()
{
	return NumChildren >= ArrayCount(Children);
}

function AddChild(R_BTNode ChildNode)
{
	local String LogWarning;

	if(NumChildren >= ArrayCount(Children))
	{
		LogWarning = "AddChild failed -- Array overflow";
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return;
	}

	Children[NumChildren] = ChildNode;
	++NumChildren;
}

function int GetChildCount()
{
	return NumChildren;
}

function R_BTNode GetChild(int Index)
{
	return Children[Index];
}