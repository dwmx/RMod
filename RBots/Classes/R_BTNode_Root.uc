//==============================================================================
//	R_BTNode_Root
//	Top level node in every Behavior Tree
//==============================================================================
class R_BTNode_Root extends R_BTNode;

var private R_BTNode Child;

static function String GetNodeClassString() { return "Root"; }

function Initialize()
{
	Child = None;
}

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

function int GetChildCount()
{
	if(Child == None)
	{
		return 0;
	}
	return 1;
}

function R_BTNode GetChild(int Index)
{
	if(Index == 0)
	{
		return Child;
	}
	return None;
}

function bool CanContainChildren()
{
	return true;
}

function int Tick(R_BehaviorTreeContext Context, float DeltaSeconds)
{
	local bool bActive;
	local int TickResult;

	if(Context == None || Child == None)
	{
		return NodeFail;
	}

	bActive = Context.GetNodeActive(GetNodeUID());
	if(!bActive)
	{
		BaseNodeActivated(Context);
	}

	bActive = Context.GetNodeActive(Child.GetNodeUID());
	if(!bActive)
	{
		Child.BaseNodeActivated(Context);
	}

	TickResult = Child.Tick(Context, DeltaSeconds);
	if(TickResult != NodeRunning)
	{
		Child.BaseNodeDeactivated(Context);
	}

	return NodeRunning;
}

function bool IsChildActive(int Index)
{
	return Index == 0;
}