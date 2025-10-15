//==============================================================================
//	R_BTNode_Sequence
//==============================================================================
class R_BTNode_Sequence extends R_BTNode_CompositeArray;

const LogCategory = 'BehaviorTreeSequence';

var private int ActiveChildIndex;

function OnActivated()
{
	ActiveChildIndex = InvalidIndex;
}

function int Tick(float DeltaSeconds)
{
	local String LogString;
	local int ChildCount;
	local int i;
	local R_BTNode ChildNode;
	local int ChildTickResult;

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
			ChildNode.OnActivated();
			ActiveChildIndex = i;
		}

		ChildTickResult = ChildNode.Tick(DeltaSeconds);
		if(ChildTickResult == NodeFail)
		{
			return NodeFail;
		}
		else if(ChildTickResult == NodeRunning)
		{
			return NodeRunning;
		}
	}
	return NodeSuccess;
}