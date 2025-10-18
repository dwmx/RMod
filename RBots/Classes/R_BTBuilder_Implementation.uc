//==============================================================================
//	R_BTBuilder_Implementation
//	Object for building a Behavior Tree
//==============================================================================
class R_BTBuilder_Implementation extends R_BTBuilder;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BehaviorTreeBuilder';

var private R_BTNode Nodes[128];
var private int NodeIndex;

const NodeClassRoot 	= Class'RBots.R_BTNode_Root';
const NodeClassSequence = Class'RBots.R_BTNode_Sequence';
const NodeClassSelector = Class'RBots.R_BTNode_Selector';
const NodeClassParallel = Class'RBots.R_BTNode_Parallel';
const NodeClassTask 	= Class'RBots.R_BTNode_Task';

var private R_BehaviorTree BehaviorTree; // The BehaviorTree this is building for
var private int CurrentNodeUID;

//------------------------------------------------------------------------------

function R_BTNode GetRoot()
{
	return Nodes[0];
}

//------------------------------------------------------------------------------

function R_BTNode CreateBTNode(Class<R_BTNode> NodeClass)
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;
	local R_BTNode NewNode;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{
		LogString = "Invalid RBotsServerActor reference";
		GoTo FailWithLogString;
	}

	NewNode = R_BTNode(LocalRBots.CreateRBotsObject(NodeClass, BehaviorTree));
	if(NewNode == None)
	{
		LogString = "Instantiation failed";
		GoTo FailWithLogString;
	}

	return NewNode;

FailWithLogString:
	LogString = "CreateBTNode failed for class" @ NodeClass @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return None;
}

function R_BTNode CreateChildBTNodeAtStackIndex(Class<R_BTNode> NodeClass)
{
	local String LogString;
	local R_BTNode_Composite ParentNode;
	local R_BTNode NewNode;
	local int NewNodeUID;

	if(NodeIndex != 0)
	{
		ParentNode = R_BTNode_Composite(Nodes[NodeIndex-1]);
		if(ParentNode == None || ParentNode.IsFull())
		{
			LogString = "Parent node must be of type R_BTNode_Composite";
			GoTo FailWithLogString;
		}
	}

	NewNode = CreateBTNode(NodeClass);
	if(NewNode == None)
	{
		return None;
	}

	// Set Node UID
	if(BehaviorTree == None)
	{
		LogString = "CreateChildBTNodeAtStackIndex warning -- BehaviorTree == None, Nodes may not have universally unique UIDs";
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
		NewNodeUID = CurrentNodeUID;
	}
	else
	{
		NewNodeUID = BehaviorTree.GetAssetUID();
		NewNodeUID = (NewNodeUID << 20) | CurrentNodeUID;
	}

	NewNode.SetNodeUID(NewNodeUID);
	++CurrentNodeUID;

	// Add child
	if(ParentNode != None)
	{
		ParentNode.AddChild(NewNode);
	}
	Nodes[NodeIndex] = NewNode;
	return NewNode;

FailWithLogString:
	LogString = "CreateChildBTNodeAtStackIndex failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return None;
}

//------------------------------------------------------------------------------

function CreateSequence()
{
	CreateChildBTNodeAtStackIndex(NodeClassSequence);
}

function CreateSelector()
{
	CreateChildBTNodeAtStackIndex(NodeClassSelector);
}

function CreateParallel()
{
	CreateChildBTNodeAtStackIndex(NodeClassParallel);
}

function CreateTask(Class<R_BehaviorTask> TaskClass)
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;
	local R_VirtualAssetManager AssMan;
	local R_BehaviorTask Task;
	local R_BTNode_Task TaskNode;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{	// Need the RBots reference
		LogString = "Invalid RBotsServerActor reference";
		GoTo FailWithLogString;
	}

	AssMan = LocalRBots.GetAssetManager();
	if(AssMan == None)
	{	// Need the asset manager
		LogString = "Failed to get AssetManager";
		GoTo FailWithLogString;
	}

	Task = R_BehaviorTask(AssMan.LoadAsset(TaskClass));
	if(Task == None)
	{	// Need to get the Task from asset manager
		LogString = "Failed to load Task";
		GoTo FailWithLogString;
	}

	TaskNode = R_BTNode_Task(CreateChildBTNodeAtStackIndex(NodeClassTask));
	if(TaskNode == None)
	{	// This shouldn't happen, but catch it if it does
		LogString = "Invalid reference to newly created TaskNode, or cast failed";
		GoTo FailWithLogString;
	}

	// Attach the Task to the TaskNode
	TaskNode.SetBehaviorTask(Task);
	return;

FailWithLogString:
	LogString = "CreateTask failed for class" @ TaskClass @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

//------------------------------------------------------------------------------

function Initialize()
{
	local int i;

	for(i = 0; i < ArrayCount(Nodes); ++i)
	{
		Nodes[i] = None;
	}

	CurrentNodeUID = 0;

	NodeIndex = 0;
	CreateChildBTNodeAtStackIndex(NodeClassRoot);
	Push();
}

function SetOwningBehaviorTree(R_BehaviorTree NewBehaviorTree)
{
	BehaviorTree = NewBehaviorTree;
}

function Push()
{
	local String LogWarning;
	local R_BTNode_Composite ParentNode;

	if(Nodes[NodeIndex] == None)
	{
		LogWarning = "Push failed -- Attempted to Push on a None Node";
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return;
	}

	ParentNode = R_BTNode_Composite(Nodes[NodeIndex]);
	if(ParentNode == None || ParentNode.IsFull())
	{
		LogWarning = "Push failed -- Attempted to push on a non-composite or full parent";
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return;
	}

	if(NodeIndex >= ArrayCount(Nodes) - 1)
	{
		LogWarning = "Push failed -- Stack overflow";
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return;
	}

	++NodeIndex;
}

function Pop()
{
	local String LogWarning;

	if(NodeIndex <= 1)
	{	// Root sits at 0
		LogWarning = "Pop failed -- Already at top level";
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return;
	}

	Nodes[NodeIndex] = None;
	--NodeIndex;
}