//==============================================================================
//	R_BTB_TreeBuilder
//	Object for building a Behavior Tree
//==============================================================================
class R_BTB_TreeBuilder extends R_RBotsObject abstract;

function SetOwningBehaviorTree(R_BehaviorTree NewBehaviorTree);
function bool IsTreeBuilderInitialized();

// Root
function R_BTNode GetRoot();

// Composites
function BeginSequence(optional Name NodeName);
function EndSequence();

function BeginSelector(optional Name NodeName);
function EndSelector();

function BeginParallel(optional Name NodeName);
function EndParallel();

// Tasks
function R_BTB_TaskBuilder CreateTask(Class<R_BehaviorTask> TaskClass, optional Name NodeName);

// SubTrees
function CreateSubTree(Class<R_BehaviorTree> BehaviorTreeClass, optional Name NodeName);