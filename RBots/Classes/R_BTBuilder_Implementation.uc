//==============================================================================
//	R_BTBuilder_Implementation
//	Object for building a Behavior Tree
//==============================================================================
class R_BTBuilder_Implementation extends R_BTBuilder;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BehaviorTreeBuilder';

var private R_BTNode Nodes[128];
var private int NodeIndex;

const ClassRootNode = Class'RBots.R_BTNode_Root';
const ClassSequence = Class'RBots.R_BTNode_Sequence';
const ClassSelector = Class'RBots.R_BTNode_Selector';

var private R_Bot BotReference;
var private int CurrentNodeUID;

//------------------------------------------------------------------------------

function R_BTNode GetRoot()
{
	return Nodes[0];
}

//------------------------------------------------------------------------------

function R_BTNode CreateBTNode(Class<R_BTNode> NodeClass)
{
	local String LogWarning;
	local R_BTNode NewNode;

	NewNode = new(None) NodeClass;
	if(NewNode == None)
	{
		LogWarning = "CreateBTNode failed -- Failed to instantiate class" @ NodeClass;
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return None;
	}

	NewNode.Initialize();
	return NewNode;
}

function CreateChildBTNodeAtStackIndex(Class<R_BTNode> NodeClass)
{
	local String LogWarning;
	local R_BTNode_Composite ParentNode;
	local R_BTNode NewNode;

	if(NodeIndex != 0)
	{
		ParentNode = R_BTNode_Composite(Nodes[NodeIndex-1]);
		if(ParentNode == None || ParentNode.IsFull())
		{
			LogWarning = "CreateChildBTAtStackIndex failed -- Parent is not valid";
			Warn(LogWarning);
			Utilities.Static.RLog(LogWarning, LogCategory);
			return;
		}
	}

	NewNode = CreateBTNode(NodeClass);
	if(NewNode == None)
	{
		return;
	}

	NewNode.SetNodeUID(CurrentNodeUID);
	++CurrentNodeUID;

	if(ParentNode != None)
	{
		ParentNode.AddChild(NewNode);
	}
	Nodes[NodeIndex] = NewNode;
}

//------------------------------------------------------------------------------

function CreateSequence()
{
	CreateChildBTNodeAtStackIndex(ClassSequence);
}

function CreateSelector()
{
	CreateChildBTNodeAtStackIndex(ClassSelector);
}

function CreateTask(Class<R_BTTask> TaskClass)
{
	CreateChildBTNodeAtStackIndex(TaskClass);
}

//------------------------------------------------------------------------------

function Map(Name BlackBoardKey, Name TaskParameter)
{
	local R_BTTask Task;
	Task = R_BTTask(Nodes[NodeIndex]);
	if(Task != None)
	{
		Task.MapBlackBoardKey(BlackBoardKey, TaskParameter);
	}
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
	CreateChildBTNodeAtStackIndex(ClassRootNode);
	Push();
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