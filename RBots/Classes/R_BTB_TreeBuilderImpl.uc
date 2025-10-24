//==============================================================================
//	R_BTB_TreeBuilderImpl
//	Object for building a Behavior Tree
//==============================================================================
class R_BTB_TreeBuilderImpl extends R_BTB_TreeBuilder;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BehaviorTreeBuilder';

const BTLib = Class'RBots.R_BehaviorTreeLibrary';

var private R_BTNode Nodes[128];
var private int NodeIndex;

const NodeClassRoot 		= Class'RBots.R_BTNode_Root';
const NodeClassSequence 	= Class'RBots.R_BTNode_Sequence';
const NodeClassSelector 	= Class'RBots.R_BTNode_Selector';
const NodeClassParallel 	= Class'RBots.R_BTNode_Parallel';
const NodeClassTask 		= Class'RBots.R_BTNode_Task';
const NodeClassSubTree		= Class'RBots.R_BTNode_SubTree';
const NodeClassDecorator 	= Class'RBots.R_BTNode_Decorator';

const LogWarn_InvalidTaskInstance = "Invalid TaskInstance reference";
const LogWarn_MissingTaskParamKey = "Ensure TaskParameter key has been added before trying to set it";

var private R_BehaviorTree BehaviorTree; // The BehaviorTree this is building for
var private int CurrentNodeUID;

//const BehaviorActionBuilderClass = Class'RBots.R_BTB_TaskBuilder';
//var private R_BTB_TaskBuilder BehaviorActionBuilder;

const TaskBuilderClass = Class'RBots.R_BTB_TaskBuilder';
var private R_BTB_TaskBuilder TaskBuilder;

const DecoratorBuilderClass = Class'RBots.R_BTB_DecoratorBuilder';
var private R_BTB_DecoratorBuilder DecoratorBuilder;

var bool bTreeBuilderInitialized;

//------------------------------------------------------------------------------

function Initialize()
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;
	local int i;

	bTreeBuilderInitialized = false;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{
		LogString = CommonError_InvalidRBots;
		GoTo FailWithLogString;
	}

	TaskBuilder = R_BTB_TaskBuilder(LocalRBots.CreateRBotsObject(TaskBuilderClass, Self));
	if(TaskBuilder == None)
	{
		LogString = "Failed to initialize TaskBuilder";
		GoTo FailWithLogString;
	}

	DecoratorBuilder = R_BTB_DecoratorBuilder(LocalRBots.CreateRBotsObject(DecoratorBuilderClass, Self));
	if(DecoratorBuilder == None)
	{
		LogString = "Failed to initialize DecoratorBuilder";
		GoTo FailWithLogString;
	}

	for(i = 0; i < ArrayCount(Nodes); ++i)
	{
		Nodes[i] = None;
	}

	CurrentNodeUID = 0;

	NodeIndex = 0;
	CreateChildBTNodeAtStackIndex(NodeClassRoot);
	Push();
	bTreeBuilderInitialized = true;
	return;

FailWithLogString:
	LogString = "Initialize failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

function bool IsTreeBuilderInitialized()
{
	return bTreeBuilderInitialized;
}

//------------------------------------------------------------------------------

function R_BTNode GetRoot()
{
	return Nodes[0];
}

function R_BTNode GetCurrent()
{
	return Nodes[NodeIndex];
}

function R_BTNode GetCurrentParent()
{
	if(NodeIndex == 0)
	{
		return None;
	}
	return Nodes[NodeIndex-1];
}

function R_BTI_TaskInstance GetCurrentTaskInstance()
{
	local R_BTNode_Task TaskNode;
	local R_BTI_TaskInstance TaskInstance;
	TaskNode = R_BTNode_Task(GetCurrent());
	if(TaskNode != None)
	{
		TaskInstance = TaskNode.GetTaskInstance();
		return TaskInstance;
	}
	return None;
}

function String GetStackPointerString()
{
	local R_BTNode Node;
	Node = GetCurrent();
	return "{StackIndex:" @ NodeIndex $ ", Node:" @ String(Node) $ "}";
}

//------------------------------------------------------------------------------

function R_BTNode CreateBTNode(Class<R_BTNode> NodeClass, optional Name NodeName)
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;
	local R_BTNode NewNode;
	local int NewNodeUID;

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

	if(NodeName != '')
	{
		NewNode.SetNodeName(NodeName);
	}

	// Set Node UID
	if(BehaviorTree == None)
	{
		LogString = "CreateBTNode warning -- BehaviorTree == None, Nodes may not have universally unique UIDs";
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

	return NewNode;

FailWithLogString:
	LogString = "CreateBTNode failed for class" @ NodeClass @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return None;
}

function R_BTNode CreateChildBTNodeAtStackIndex(Class<R_BTNode> NodeClass, optional Name NodeName)
{
	local String LogString;
	local R_BTNode ParentNode;
	local R_BTNode NewNode;

	if(NodeIndex != 0)
	{
		ParentNode = Nodes[NodeIndex-1];
		if(ParentNode == None || !ParentNode.CanContainChildren() || ParentNode.IsFull())
		{
			LogString = "Cannot add child to parent node";
			GoTo FailWithLogString;
		}
	}

	// NodeNames must be unique within any given tree
	if(NodeName != '')
	{
		if(BTLib.Static.DoesBTContainNodeWithName(GetRoot(), NodeName, false))
		{
			LogString = "Duplicate NodeName:" @ NodeName;
			GoTo FailWithLogString;
		}
	}
	
	NewNode = CreateBTNode(NodeClass, NodeName);
	if(NewNode == None)
	{
		return None;
	}

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

function ClearChildBTNodeAtStackIndex()
{
	if(NodeIndex > 0)
	{
		Nodes[NodeIndex] = None;
	}
}

//------------------------------------------------------------------------------

function BeginCompositeNode(Class<R_BTNode_Composite> CompositeNodeClass, optional Name NodeName)
{
	local String LogString;
	if(CreateChildBTNodeAtStackIndex(CompositeNodeClass, NodeName) != None)
	{
		Push();
	}
	else
	{
		LogString = "BeginCompositeNode failed for class" @ CompositeNodeClass;
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
	}
}

function EndCompositeNode(Class<R_BTNode_Composite> CompositeNodeClass)
{
	local String LogString;
	local R_BTNode CurrentParent;
	CurrentParent = GetCurrentParent();
	if(CurrentParent != None && CurrentParent.Class == CompositeNodeClass)
	{
		Pop();
	}
	else
	{
		LogString = "EndCompositeNode failed for class" @ CompositeNodeClass;
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
	}
}

function BeginSequence(optional Name NodeName)	{ BeginCompositeNode(NodeClassSequence, NodeName); }
function EndSequence()							{ EndCompositeNode(NodeClassSequence); }

function BeginSelector(optional Name NodeName)	{ BeginCompositeNode(NodeClassSelector, NodeName); }
function EndSelector()							{ EndCompositeNode(NodeClassSelector); }

function BeginParallel(optional Name NodeName)	{ BeginCompositeNode(NodeClassParallel, NodeName); }
function EndParallel()							{ EndCompositeNode(NodeClassParallel); }

//------------------------------------------------------------------------------

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

function R_BTB_TaskBuilder CreateTask(Class<R_BehaviorTask> TaskClass, optional Name NodeName)
{
	local String LogString;
	local R_VirtualAssetManager AssMan;
	local R_BehaviorTask Task;
	local R_BehaviorActionInstance Instance;
	local R_BTI_TaskInstance TaskInstance;
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

	Instance = Task.CreateInstance();
	if(Instance == None)
	{	// Instance lives on the node
		LogString = "Failed to create TaskInstance";
		GoTo FailWithLogString;
	}

	TaskInstance = R_BTI_TaskInstance(Instance);
	if(TaskInstance == None)
	{	// Tasks have to return instances of type TaskInstance
		LogString = "Task.CreateInstance successfully created an Instance, but it was not a TaskInstance";
		GoTo FailWithLogString;
	}

	TaskNode = R_BTNode_Task(CreateChildBTNodeAtStackIndex(NodeClassTask, NodeName));
	if(TaskNode == None)
	{	// This shouldn't happen, but catch it if it does
		LogString = "Invalid reference to newly created TaskNode, or cast failed";
		GoTo FailWithLogString;
	}

	// Attach the Task to the TaskNode
	TaskNode.SetBehaviorActionInstance(TaskInstance);
	TaskBuilder.SetBehaviorActionInstance(TaskInstance);
	return TaskBuilder;

FailWithLogString:
	LogString = "CreateTask failed for class" @ TaskClass @ "--" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return None;
}

function CreateSubTree(Class<R_BehaviorTree> BehaviorTreeClass, optional Name NodeName)
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

	SubTreeNode = R_BTNode_SubTree(CreateChildBTNodeAtStackIndex(NodeClassSubTree, NodeName));
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

function SetOwningBehaviorTree(R_BehaviorTree NewBehaviorTree)
{
	BehaviorTree = NewBehaviorTree;
}

function Push()
{
	local String LogString;
	local R_BTNode ParentNode;

	if(Nodes[NodeIndex] == None)
	{
		LogString = "Push failed -- Attempted to Push on a None Node";
		GoTo FailWithLogString;
	}

	ParentNode = Nodes[NodeIndex];
	if(ParentNode == None || !ParentNode.CanContainChildren() || ParentNode.IsFull())
	{
		LogString = "Push failed -- Attempted to push on a non-composite or full parent";
		GoTo FailWithLogString;
	}

	if(NodeIndex >= ArrayCount(Nodes) - 1)
	{
		LogString = "Push failed -- Stack overflow";
		GoTo FailWithLogString;
	}

	++NodeIndex;
	return;

FailWithLogString:
	LogString = "Push failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
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

//------------------------------------------------------------------------------

function R_BTB_DecoratorBuilder AddDecorator(Class<R_BehaviorDecorator> DecoratorClass, name NodeName)
{
	local String LogString;
	local R_VirtualAssetManager AssMan;
	local R_BehaviorDecorator Decorator;
	local R_BehaviorActionInstance Instance;
	local R_BTI_DecoratorInstance DecoratorInstance;
	local R_BTNode_Decorator DecoratorNode;
	local R_BTNode Node, Parent;

	if(!BTLib.Static.FindNodeAndParentByName(NodeName, GetRoot(), Parent, Node))
	{
		LogString = "Failed to find node by name:" @ NodeName;
		GoTo FailWithLogString;
	}

	AssMan = InternalTryGetAssetManager(LogString);
	if(AssMan == None)
	{
		GoTo FailWithLogString;
	}

	Decorator = R_BehaviorDecorator(AssMan.LoadAsset(DecoratorClass));
	if(Decorator == None)
	{
		LogString = "Failed to load Decorator";
		GoTo FailWithLogString;
	}

	Instance = Decorator.CreateInstance();
	if(Instance == None)
	{
		LogString = "Failed to create DecoratorInstance";
		GoTo FailWithLogString;
	}

	DecoratorInstance = R_BTI_DecoratorInstance(Instance);
	if(DecoratorInstance == None)
	{
		LogString = "Decorator.CreateInstance successfully created an Instance, but it was not a DecoratorInstance";
		GoTo FailWithLogString;
	}

	DecoratorNode = R_BTNode_Decorator(CreateBTNode(NodeClassDecorator));
	if(DecoratorNode == None)
	{
		LogString = "Invalid reference to newly created DecoratorNode, or cast failed";
		GoTo FailWithLogString;
	}

	if(!Parent.TryInsertChildBetween(Node, DecoratorNode))
	{
		LogString = "Failed to insert Decorator node";
		GoTo FailWithLogString;
	}

	DecoratorNode.SetBehaviorActionInstance(DecoratorInstance);
	DecoratorBuilder.SetBehaviorActionInstance(DecoratorInstance);
	return DecoratorBuilder;

FailWithLogString:
	LogString = "AddDecorator failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return None;
}

defaultproperties
{
	bTreeBuilderInitialized=false
}