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
const NodeClassSubTree	= Class'RBots.R_BTNode_SubTree';

const LogWarn_InvalidTaskInstance = "Invalid TaskInstance reference";
const LogWarn_MissingTaskParamKey = "Ensure TaskParameter key has been added before trying to set it";

var private R_BehaviorTree BehaviorTree; // The BehaviorTree this is building for
var private int CurrentNodeUID;

//------------------------------------------------------------------------------

function R_BTNode GetRoot()
{
	return Nodes[0];
}

function R_BTNode GetCurrent()
{
	return Nodes[NodeIndex];
}

function String GetStackPointerString()
{
	local R_BTNode Node;
	Node = GetCurrent();
	return "{StackIndex:" @ NodeIndex $ ", Node:" @ String(Node) $ "}";
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

function R_VirtualAssetManager InternalTryGetAssetManager(out String OutErrorString)
{
	local R_RBotsServerActor LocalRBots;
	local R_VirtualAssetManager AssMan;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{
		OutErrorString = "Invalid RBotsServerActor reference";
		return None;
	}

	AssMan = LocalRBots.GetAssetManager();
	if(AssMan == None)
	{
		OutErrorString = "Invalid AssetManager reference";
		return None;
	}

	return AssMan;
}

function CreateTask(Class<R_BehaviorTask> TaskClass)
{
	local String LogString;
	local R_VirtualAssetManager AssMan;
	local R_BehaviorTask Task;
	local R_BehaviorTaskInstance TaskInstance;
	local R_BTNode_Task TaskNode;

	AssMan = InternalTryGetAssetManager(LogString);
	if(AssMan == None)
	{	// Need access to the AssMan
		GoTo FailWithLogString;
	}

	Task = R_BehaviorTask(AssMan.LoadAsset(TaskClass));
	if(Task == None)
	{	// Need to get the Task from asset manager
		LogString = "Failed to load Task";
		GoTo FailWithLogString;
	}

	TaskInstance = Task.CreateInstance();
	if(TaskInstance == None)
	{	// Task instance will live on the node
		LogString = "Failed to create TaskInstance";
		GoTo FailWithLogString;
	}

	TaskNode = R_BTNode_Task(CreateChildBTNodeAtStackIndex(NodeClassTask));
	if(TaskNode == None)
	{	// This shouldn't happen, but catch it if it does
		LogString = "Invalid reference to newly created TaskNode, or cast failed";
		GoTo FailWithLogString;
	}

	// Attach the Task to the TaskNode
	TaskNode.SetBehaviorTaskInstance(TaskInstance);
	return;

FailWithLogString:
	LogString = "CreateTask failed for class" @ TaskClass @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function CreateSubTree(Class<R_BehaviorTree> BehaviorTreeClass)
{
	local String LogString;
	local R_VirtualAssetManager AssMan;
	local R_BehaviorTree SubBehaviorTree;
	local R_BTNode_SubTree SubTreeNode;

	if(BehaviorTree == None)
	{	// Shouldn't happen, but have to check
		LogString = "Invalid reference to build-context BehaviorTree";
		GoTo FailWithLogString;
	}

	AssMan = InternalTryGetAssetManager(LogString);
	if(AssMan == None)
	{	// Need access to the AssMan
		GoTo FailWithLogString;
	}

	SubBehaviorTree = R_BehaviorTree(AssMan.LoadAsset(BehaviorTreeClass));
	if(SubBehaviorTree == None)
	{	// Must have access to the asset
		LogString = "Failed to load BehaviorTree";
		GoTo FailWithLogString;
	}

	if(SubBehaviorTree.ContainsSubTree(BehaviorTree.Class))
	{	// Cyclic trees bad
		LogString = "Cyclic SubTree inclusion detected between" @ BehaviorTree.Class @ "and" @ BehaviorTreeClass;
		GoTo FailWithLogString;
	}

	SubTreeNode = R_BTNode_SubTree(CreateChildBTNodeAtStackIndex(NodeClassSubTree));
	if(SubTreeNode == None)
	{	// Shouldn't happen, but catch it if it does
		LogString = "Invalid reference to newly created SubTreeNode, or cast failed";
		GoTo FailWithLogString;
	}

	// Attach the BehaviorTree to the SubTree Node
	SubTreeNode.SetSubTree(SubBehaviorTree);
	return;

FailWithLogString:
	LogString = "CreateSubTree failed for class" @ BehaviorTreeClass @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

//------------------------------------------------------------------------------
//	Task Parameters
//	These calls are only valid in the reference of a Task node

function R_BehaviorTaskInstance GetCurrentTaskInstance()
{
	local R_BTNode_Task TaskNode;
	local R_BehaviorTaskInstance TaskInstance;
	TaskNode = R_BTNode_Task(GetCurrent());
	if(TaskNode != None)
	{
		TaskInstance = TaskNode.GetBehaviorTaskInstance();
		return TaskInstance;
	}
	return None;
}

function SetTaskBool(Name Key, bool Value)
{
	local String LogString;
	local R_BehaviorTaskInstance TaskInstance;
	local byte ByteValue;

	if(Value)	ByteValue = 1;
	else		ByteValue = 0;

	TaskInstance = GetCurrentTaskInstance();
	if(TaskInstance == None)
	{
		LogString = LogWarn_InvalidTaskInstance;
		GoTo FailWithLogString;
	}

	if(!TaskInstance.SetTaskBool(Key, ByteValue))
	{
		LogString = LogWarn_MissingTaskParamKey;
		GoTo FailWithLogString;
	}
	return;
FailWithLogString:
	LogString = "SetTaskBool failed at" @ GetStackPointerString() @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function SetTaskInt(Name Key, int Value)
{
	local String LogString;
	local R_BehaviorTaskInstance TaskInstance;

	TaskInstance = GetCurrentTaskInstance();
	if(TaskInstance == None)
	{
		LogString = LogWarn_InvalidTaskInstance;
		GoTo FailWithLogString;
	}

	if(!TaskInstance.SetTaskInt(Key, Value))
	{
		LogString = LogWarn_MissingTaskParamKey;
		GoTo FailWithLogString;
	}
	return;
FailWithLogString:
	LogString = "SetTaskInt failed at" @ GetStackPointerString() @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function SetTaskFloat(Name Key, float Value)
{
	local String LogString;
	local R_BehaviorTaskInstance TaskInstance;

	TaskInstance = GetCurrentTaskInstance();
	if(TaskInstance == None)
	{
		LogString = LogWarn_InvalidTaskInstance;
		GoTo FailWithLogString;
	}

	if(!TaskInstance.SetTaskFloat(Key, Value))
	{
		LogString = LogWarn_MissingTaskParamKey;
		GoTo FailWithLogString;
	}
	return;
FailWithLogString:
	LogString = "SetTaskFloat failed at" @ GetStackPointerString() @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function SetTaskVector(Name Key, Vector Value)
{
	local String LogString;
	local R_BehaviorTaskInstance TaskInstance;

	TaskInstance = GetCurrentTaskInstance();
	if(TaskInstance == None)
	{
		LogString = LogWarn_InvalidTaskInstance;
		GoTo FailWithLogString;
	}

	if(!TaskInstance.SetTaskVector(Key, Value))
	{
		LogString = LogWarn_MissingTaskParamKey;
		GoTo FailWithLogString;
	}
	return;
FailWithLogString:
	LogString = "SetTaskVector failed at" @ GetStackPointerString() @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function SetTaskActor(Name Key, Actor Value)
{
	local String LogString;
	local R_BehaviorTaskInstance TaskInstance;

	TaskInstance = GetCurrentTaskInstance();
	if(TaskInstance == None)
	{
		LogString = LogWarn_InvalidTaskInstance;
		GoTo FailWithLogString;
	}

	if(!TaskInstance.SetTaskActor(Key, Value))
	{
		LogString = LogWarn_MissingTaskParamKey;
		GoTo FailWithLogString;
	}
	return;
FailWithLogString:
	LogString = "SetTaskActor failed at" @ GetStackPointerString() @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function SetTaskObject(Name Key, Object Value)
{
	local String LogString;
	local R_BehaviorTaskInstance TaskInstance;

	TaskInstance = GetCurrentTaskInstance();
	if(TaskInstance == None)
	{
		LogString = LogWarn_InvalidTaskInstance;
		GoTo FailWithLogString;
	}

	if(!TaskInstance.SetTaskObject(Key, Value))
	{
		LogString = LogWarn_MissingTaskParamKey;
		GoTo FailWithLogString;
	}
	return;
FailWithLogString:
	LogString = "SetTaskObject failed at" @ GetStackPointerString() @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function SetTaskClass(Name Key, Class Value)
{
	local String LogString;
	local R_BehaviorTaskInstance TaskInstance;

	TaskInstance = GetCurrentTaskInstance();
	if(TaskInstance == None)
	{
		LogString = LogWarn_InvalidTaskInstance;
		GoTo FailWithLogString;
	}

	if(!TaskInstance.SetTaskClass(Key, Value))
	{
		LogString = LogWarn_MissingTaskParamKey;
		GoTo FailWithLogString;
	}
	return;
FailWithLogString:
	LogString = "SetTaskClass failed at" @ GetStackPointerString() @ "--" @ LogString;
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