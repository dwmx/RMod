//==============================================================================
//	R_BTNode_Composite
//==============================================================================
class R_BTNode_Composite extends R_BTNode abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BTNodeCompositeArray';

var private R_BTNode Children[16];
var private int NumChildren;

function BaseNodeActivated(R_BehaviorTreeContext Context)
{
	Context.SetNodeActiveChildIndex(GetNodeUID(), InvalidIndex);
	Super.BaseNodeActivated(Context);
}

function BaseNodeDeactivated(R_BehaviorTreeContext Context)
{
	Context.SetNodeActiveChildIndex(GetNodeUID(), InvalidIndex);
	Super.BaseNodeDeactivated(Context);
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

function R_BTNode GetChild(optional int Index)
{
	return Children[Index];
}

function bool CanContainChildren()
{
	return true;
}

function bool TryInsertChildBetween(R_BTNode CurrentChild, R_BTNode NewChild)
{
	local R_BTNode TempNode;
	local int InsertIndex;
	local int i;

	if(CurrentChild == None || NewChild == None || CurrentChild == NewChild)
	{
		return false;
	}

	if(IsNodeAncestor(CurrentChild, NewChild) || IsNodeAncestor(NewChild, CurrentChild))
	{
		return false;
	}

	InsertIndex = InvalidIndex;
	for(i = 0; i < NumChildren; ++i)
	{
		if(Children[i] == CurrentChild)
		{
			InsertIndex = i;
			break;
		}
	}

	if(InsertIndex == InvalidIndex)
	{
		return false;
	}

	TempNode = Children[InsertIndex];
	Children[InsertIndex] = NewChild;
	NewChild.AddChild(TempNode);
	return true;
}