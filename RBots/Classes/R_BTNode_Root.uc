//==============================================================================
//	R_BTNode_Root
//	Top level node in every Behavior Tree
//==============================================================================
class R_BTNode_Root extends R_BTNode_Composite;

var private R_BTNode Child;
var private bool bActive;

static function String GetNodeClassString() { return "Root"; }

function Initialize()
{
	Child = None;
	bActive = false;
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

function int Tick(float DeltaSeconds)
{
	if(Child != None)
	{
		if(!bActive)
		{
			Child.OnActivated();
			bActive = true;
		}
		if(Child.Tick(DeltaSeconds) != NodeRunning)
		{
			bActive = false;
		}
	}
	else
	{
		bActive = false;
	}
	return NodeRunning;
}

function bool IsChildActive(int Index)
{
	return Index == 0;
}

defaultproperties
{
	bActive=false
}