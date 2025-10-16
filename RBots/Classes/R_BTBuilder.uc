//==============================================================================
//	R_BTBuilder
//	Object for building a Behavior Tree
//==============================================================================
class R_BTBuilder extends R_RBotsObject abstract;

function Initialize();

function Push();
function Pop();

function CreateSequence();
function CreateSelector();
function CreateTask(Class<R_BTTask> TaskClass);

function Map(Name BlackBoardKey, Name TaskParameter);

function R_BTNode GetRoot();