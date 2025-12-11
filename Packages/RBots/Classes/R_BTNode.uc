//==============================================================================
//	R_BTNode
//	Abstract base class for all Behavior Tree Node types
//==============================================================================
class R_BTNode extends R_RBotsObject abstract;

const NodeFail = 0;
const NodeSuccess = 1;
const NodeRunning = 2;

var private R_BTNode ChildNode;

var private int NodeUID;
var private Name NodeName;

function int GetNodeUID() { return NodeUID; }
function SetNodeUID(int NewNodeUID) { NodeUID = NewNodeUID; }

function Name GetNodeName() { return NodeName; }
function SetNodeName(Name NewNodeName) { NodeName = NewNodeName; }

function String GetNodeDisplayString() { return String(NodeName); }

static function String GetNodeClassString() { return "Node"; }

//------------------------------------------------------------------------------

function BaseNodeActivated(R_BehaviorTreeContext Context)
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;

	Context.SetNodeActive(GetNodeUID(), true);

	Bot = Context.GetBot();
	BlackBoard = Context.GetBlackBoard();
	OnActivated(Bot, BlackBoard);
}

function BaseNodeDeactivated(R_BehaviorTreeContext Context)
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;

	Context.SetNodeActive(GetNodeUID(), false);
	
	Bot = Context.GetBot();
	BlackBoard = Context.GetBlackBoard();
	OnDeactivated(Bot, BlackBoard);
}

//------------------------------------------------------------------------------

function Initialize();
function OnActivated(R_Bot Bot, R_BlackBoard BlackBoard);
function OnDeactivated(R_Bot Bot, R_BlackBoard BlackBoard);
function int Tick(R_BehaviorTreeContext Context, float DeltaSeconds);

//------------------------------------------------------------------------------
// Composite Functions
// By default, all nodes can have one, and only one child
// For nodes that should not contain any children (tasks), these are overridden
// For nodes that should contain main children (composites), these are overridden

function bool CanContainChildren()		{ return true; }
function bool IsFull() 					{ return ChildNode != None; }
function int GetChildCount() 			{ if(ChildNode != None) { return 1; } return 0; }

function int GetChildIndex(R_BTNode TestChildNode)
{
	local R_BTNode CurrentChild;
	local int NumChildren;
	local int i;

	NumChildren = GetChildCount();
	for(i = 0; i < NumChildren; ++i)
	{
		CurrentChild = GetChild(i);
		if(CurrentChild == TestChildNode)
		{
			return i;
		}
	}

	return InvalidIndex;
}

function R_BTNode GetChild(optional int Index)
{
	if(Index == 0 && ChildNode != None)
	{
		return ChildNode;
	}
	return None;
}

function AddChild(R_BTNode NewChildNode)
{
	local String LogString;

	if(NewChildNode == None)
	{
		LogString = "Bad Node argument:" @ NewChildNode;
		GoTo FailWithLogString;
	}

	if(ChildNode != None)
	{
		LogString = "ChildNode already populated";
		GoTo FailWithLogString;
	}

	ChildNode = NewChildNode;
	return;

FailWithLogString:
	LogString = "AddChild failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function bool TryInsertChildBetween(R_BTNode CurrentChild, R_BTNode NewChild)
{
	local R_BTNode TempNode;

	if(CurrentChild == None
	|| NewChild 	== None
	|| CurrentChild == NewChild
	|| CurrentChild != ChildNode
	|| ChildNode 	== None)
	{
		return false;
	}

	TempNode = ChildNode;
	ChildNode = NewChild;
	ChildNode.AddChild(TempNode);
	return true;
}

//------------------------------------------------------------------------------

// Returns true if AncestorNode is an ancestor of TestNode
static function bool IsNodeAncestor(R_BTNode AncestorNode, R_BTNode TestNode)
{
	local R_BTNode NodeStack[128];
	local R_BTNode CurrentNode;
	local int NumNodes;
	local int NumChildren;
	local int i;

	if(AncestorNode == None || TestNode == None)
	{
		return false;
	}

	NodeStack[0] = AncestorNode;
	NumNodes = 1;
	while(NumNodes > 0)
	{
		--NumNodes;
		CurrentNode = NodeStack[NumNodes];
		if(CurrentNode == TestNode)
		{
			return true;
		}
		if(CurrentNode.CanContainChildren())
		{
			NumChildren = CurrentNode.GetChildCount();
			for(i = 0; i < NumChildren; ++i)
			{
				NodeStack[NumNodes] = CurrentNode.GetChild(i);
				++NumNodes;
			}
		}
	}
	return false;
}

//------------------------------------------------------------------------------

defaultproperties
{
	NodeName='Node'
}