//==============================================================================
//	R_BTNode_Selector
//==============================================================================
class R_BTNode_Selector extends R_BTNode_Composite;

const LogCategory = 'BehaviorTreeSelector';

static function String GetNodeClassString() { return "Selector"; }

function int Tick(R_BehaviorTreeContext Context, float DeltaSeconds)
{
	local String LogString;
	local int ChildCount;
	local int i;
	local R_BTNode ChildNode;
	local int ChildTickResult;
	local int ActiveChildIndex;

	if(Context == None)
	{
		return NodeFail;
	}

	ActiveChildIndex = Context.GetNodeActiveChildIndex(GetNodeUID());

	if(ActiveChildIndex == InvalidIndex)
	{
		i = 0;
	}
	else
	{
		i = ActiveChildIndex;
	}

	ChildCount = GetChildCount();
	for(i = i; i < ChildCount; ++i)
	{
		ChildNode = GetChild(i);
		if(ChildNode == None)
		{
			LogString = "Tick warning --" @ Self @ "contained a None child";
			Warn(LogString);
			Utilities.Static.RLog(LogString, LogCategory);
			continue;
		}

		if(i != ActiveChildIndex)
		{
			ChildNode.BaseNodeActivated(Context);
			Context.SetNodeActiveChildIndex(GetNodeUID(), i);
		}

		ChildTickResult = ChildNode.Tick(Context, DeltaSeconds);
		if(ChildTickResult == NodeRunning)
		{
			return NodeRunning;
		}
		else
		{
			ChildNode.BaseNodeDeactivated(Context);
			if(ChildTickResult == NodeSuccess)
			{
				return NodeSuccess;
			}
		}
	}
	return NodeFail;
}