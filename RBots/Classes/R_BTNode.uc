//==============================================================================
//	R_BTNode
//	Abstract base class for all Behavior Tree Node types
//==============================================================================
class R_BTNode extends R_RBotsObject abstract;

const NodeFail = 0;
const NodeSuccess = 1;
const NodeRunning = 2;

var private int NodeUID;

function int GetNodeUID() { return NodeUID; }
function SetNodeUID(int NewNodeUID) { NodeUID = NewNodeUID; }

static function String GetNodeClassString() { return "Node"; }


//------------------------------------------------------------------------------

function BaseNodeActivated(R_BTContext Context)
{
	local R_Bot Bot;
	local R_BlackBoard BlackBoard;

	Context.SetNodeActive(GetNodeUID(), true);

	Bot = Context.GetBot();
	BlackBoard = Context.GetBlackBoard();
	OnActivated(Bot, BlackBoard);
}

function BaseNodeDeactivated(R_BTContext Context)
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
function int Tick(R_BTContext Context, float DeltaSeconds);