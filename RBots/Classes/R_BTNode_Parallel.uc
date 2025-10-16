//==============================================================================
//	R_BTNode_Parallel
//==============================================================================
class R_BTNode_Parallel extends R_BTNode_CompositeArray;

const LogCategory = 'BehaviorTreeParallel';

static function String GetNodeClassString() { return "Parallel"; }

function BaseNodeActivated(R_BTContext Context)
{
	local String LogString;
	local int ChildCount;
	local R_BTNode ChildNode;
	local int i;

	ChildCount = GetChildCount();
	for(i = 0; i < ChildCount; ++i)
	{
		ChildNode = GetChild(i);
		if(ChildNode == None)
		{
			LogString = "Tick warning --" @ Self @ "contained a None child";
			Warn(LogString);
			Utilities.Static.RLog(LogString, LogCategory);
			continue;
		}

		ChildNode.BaseNodeActivated(Context);
	}
	Super.BaseNodeActivated(Context);
}

function int Tick(R_BTContext Context, float DeltaSeconds)
{
	local String LogString;
	local int ChildCount;
	local R_BTNode ChildNode;
	local int ChildTickResult;
	local int i;
	local int NumRunningChildren;

	if(Context == None)
	{
		return NodeFail;
	}

	NumRunningChildren = 0;
	ChildCount = GetChildCount();
	for(i = 0; i < ChildCount; ++i)
	{
		ChildNode = GetChild(i);
		if(ChildNode == None)
		{
			LogString = "Tick warning --" @ Self @ "contained a None child";
			Warn(LogString);
			Utilities.Static.RLog(LogString, LogCategory);
			continue;
		}

		if(Context.GetNodeActive(ChildNode.GetNodeUID()))
		{
			ChildTickResult = ChildNode.Tick(Context, DeltaSeconds);
			if(ChildTickResult == NodeRunning)
			{
				++NumRunningChildren;
			}
			else
			{
				ChildNode.BaseNodeDeactivated(Context);
			}
		}
	}

	if(NumRunningChildren == 0)
	{
		return NodeSuccess;
	}
	else
	{
		return NodeRunning;
	}
}