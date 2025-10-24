//==============================================================================
//	R_BTNode_Root
//	Top level node in every Behavior Tree
//==============================================================================
class R_BTNode_Root extends R_BTNode;

static function String GetNodeClassString() { return "Root"; }

function int Tick(R_BehaviorTreeContext Context, float DeltaSeconds)
{
	local R_BTNode LocalChildNode;
	local bool bActive;
	local int TickResult;

	LocalChildNode = GetChild();

	if(Context == None || LocalChildNode == None)
	{
		return NodeFail;
	}

	bActive = Context.GetNodeActive(GetNodeUID());
	if(!bActive)
	{
		BaseNodeActivated(Context);
	}

	bActive = Context.GetNodeActive(LocalChildNode.GetNodeUID());
	if(!bActive)
	{
		LocalChildNode.BaseNodeActivated(Context);
	}

	TickResult = LocalChildNode.Tick(Context, DeltaSeconds);
	if(TickResult != NodeRunning)
	{
		LocalChildNode.BaseNodeDeactivated(Context);
	}

	return NodeRunning;
}

function bool IsChildActive(int Index)
{
	return Index == 0;
}