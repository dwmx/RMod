//==============================================================================
//	R_BTBuilder
//	Object for building a Behavior Tree
//==============================================================================
class R_BTBuilder extends R_RBotsObject abstract;

function SetOwningBehaviorTree(R_BehaviorTree NewBehaviorTree);

function Push();
function Pop();

function CreateSequence();
function CreateSelector();
function CreateParallel();
function CreateTask(Class<R_BehaviorTask> TaskClass);
function CreateSubTree(Class<R_BehaviorTree> BehaviorTreeClass);

function SetTaskFloat(Name Key, float Value);

function R_BTNode GetRoot();