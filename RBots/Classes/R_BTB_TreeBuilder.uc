//==============================================================================
//	R_BTB_TreeBuilder
//	Object for building a Behavior Tree
//==============================================================================
class R_BTB_TreeBuilder extends R_RBotsObject abstract;

function SetOwningBehaviorTree(R_BehaviorTree NewBehaviorTree);

function Push();
function Pop();

function CreateSequence();
function CreateSelector();
function CreateParallel();
function CreateSubTree(Class<R_BehaviorTree> BehaviorTreeClass);
function R_BTB_TaskBuilder CreateTask(Class<R_BehaviorTask> TaskClass);

function R_BTNode GetRoot();