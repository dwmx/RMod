//==============================================================================
//	R_BTNode_Selector
//==============================================================================
class R_BTNode_Selector extends R_BTNode_CompositeArray;

const LogCategory = 'BehaviorTreeSelector';

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
		if(ChildTickResult == NodeSuccess)
		{
			return NodeSuccess;
		}
		else if(ChildTickResult == NodeRunning)
		{
			return NodeRunning;
		}
	}
	return NodeFail;
}