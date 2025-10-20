//==============================================================================
//	R_BehaviorTreeBuilder
//	Object for building a Behavior Tree
//==============================================================================
class R_BehaviorTreeBuilder extends R_RBotsObject abstract;

function SetOwningBehaviorTree(R_BehaviorTree NewBehaviorTree);

function Push();
function Pop();

function CreateSequence();
function CreateSelector();
function CreateParallel();
function CreateTask(Class<R_BehaviorTask> TaskClass);
function CreateSubTree(Class<R_BehaviorTree> BehaviorTreeClass);

//------------------------------------------------------------------------------
// Map a TaskParamter name to a BlackBoard key
function MapKeySelector(Name TaskParameter, Name BlackBoardKey);

//------------------------------------------------------------------------------
// Configures task parameters on a per-node basis
function SetTaskBool(Name TaskParameter, bool Value);
function SetTaskInt(Name TaskParameter, int Value);
function SetTaskFloat(Name TaskParameter, float Value);
function SetTaskVector(Name TaskParameter, Vector Value);
function SetTaskActor(Name TaskParameter, Actor Value);
function SetTaskObject(Name TaskParameter, Object Value);
function SetTaskClass(Name TaskParameter, Class Value);

function MapTaskFloat(Name TaskParameter, Name BlackBoardKey);

function R_BTNode GetRoot();