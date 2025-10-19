//==============================================================================
//	R_BTNode_Sequence
//==============================================================================
class R_BTNode_Sequence extends R_BTNode_CompositeArray;

const LogCategory = 'BehaviorTreeSequence';

static function String GetNodeClassString() { return "Sequence"; }

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
			ActiveChildIndex = i;
			Context.SetNodeActiveChildIndex(GetNodeUID(), ActiveChildIndex);
		}

		ChildTickResult = ChildNode.Tick(Context, DeltaSeconds);
		if(ChildTickResult == NodeRunning)
		{
			return NodeRunning;
		}
		else
		{
			ChildNode.BaseNodeDeactivated(Context);
			if(ChildTickResult == NodeFail)
			{
				return NodeFail;
			}
		}
	}
	return NodeSuccess;
}