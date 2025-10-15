//==============================================================================
//	R_BTContext
//	Contains instancing state associated with a Behavior Tree
//==============================================================================
class R_BTContext extends R_RBotsObject abstract;

function Initialize();

function SetBot(R_Bot NewBot);
function R_Bot GetBot();

function SetBlackBoard(R_BlackBoard NewBlackBoard);
function R_BlackBoard GetBlackBoard();

function SetNodeActive(int NodeUID, bool bActive);
function bool GetNodeActive(int NodeUID);

function int GetNodeActiveChildIndex(int NodeUID);
function SetNodeActiveChildIndex(int NodeUID, int ActiveChildIndex);

function float GetNodeActiveTime(int NodeUID);

function Tick(float DeltaSeconds);