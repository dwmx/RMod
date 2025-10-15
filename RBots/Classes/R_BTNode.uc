//==============================================================================
//	R_BTNode
//	Abstract base class for all Behavior Tree Node types
//==============================================================================
class R_BTNode extends R_RBotsObject abstract;

const NodeFail = 0;
const NodeSuccess = 1;
const NodeRunning = 2;

function Initialize();
function OnActivated();
function int Tick(float DeltaSeconds);