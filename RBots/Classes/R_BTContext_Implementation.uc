//==============================================================================
//	R_BTContext_Implementation
//==============================================================================
class R_BTContext_Implementation extends R_BTContext;

var private R_Bot Bot;
var private R_BlackBoard BlackBoard;

struct R_BTNodeState
{
	var bool bActive;
	var int NodeUID;
	var int ActiveChildIndex;
	var float ActiveTime;
};
var private R_BTNodeState NodeStates[128];

//------------------------------------------------------------------------------

function Initialize()
{
	local int i;

	for(i = 0; i < ArrayCount(NodeStates); ++i)
	{
		NodeStates[i].bActive = false;
		NodeStates[i].ActiveChildIndex = InvalidIndex;
		NodeStates[i].ActiveTime = 0.0;
	}
}

//------------------------------------------------------------------------------

function SetBot(R_Bot NewBot)
{
	Bot = NewBot;
}

function R_Bot GetBot()
{
	return Bot;
}

function SetBlackBoard(R_BlackBoard NewBlackBoard)
{
	BlackBoard = NewBlackBoard;
}

function R_BlackBoard GetBlackBoard()
{
	return BlackBoard;
}

//------------------------------------------------------------------------------

function int GetNodeStateIndexFromUID(int NodeUID)
{
	local int i;

	for(i = 0; i < ArrayCount(NodeStates); ++i)
	{
		if(NodeStates[i].NodeUID == NodeUID)
		{
			return i;
		}
	}

	for(i = 0; i < ArrayCount(NodeStates); ++i)
	{
		if(!NodeStates[i].bActive)
		{
			NodeStates[i].NodeUID = NodeUID;
			return i;
		}
	}
	
	return InvalidIndex;
}

function bool GetNodeActive(int NodeUID)
{
	local int Index;

	Index = GetNodeStateIndexFromUID(NodeUID);
	if(Index != InvalidIndex)
	{
		return NodeStates[Index].bActive;
	}
}

function SetNodeActive(int NodeUID, bool bActive)
{
	local int Index;

	Index = GetNodeStateIndexFromUID(NodeUID);
	if(Index != InvalidIndex)
	{
		if(NodeStates[Index].bActive != bActive)
		{
			NodeStates[Index].bActive = bActive;
			NodeStates[Index].ActiveTime = 0.0;
		}
	}
}

function int GetNodeActiveChildIndex(int NodeUID)
{
	local int Index;

	Index = GetNodeStateIndexFromUID(NodeUID);
	if(Index != InvalidIndex)
	{
		return NodeStates[Index].ActiveChildIndex;
	}
}

function SetNodeActiveChildIndex(int NodeUID, int ActiveChildIndex)
{
	local int Index;

	Index = GetNodeStateIndexFromUID(NodeUID);
	if(Index != InvalidIndex)
	{
		NodeStates[Index].ActiveChildIndex = ActiveChildIndex;
	}
}

function float GetNodeActiveTime(int NodeUID)
{
	local int Index;

	Index = GetNodeStateIndexFromUID(NodeUID);
	if(Index != InvalidIndex)
	{
		return NodeStates[Index].ActiveTime;
	}
	return 0.0;
}

function Tick(float DeltaSeconds)
{
	local int i;

	for(i = 0; i < ArrayCount(NodeStates); ++i)
	{
		if(NodeStates[i].bActive)
		{
			NodeStates[i].ActiveTime += DeltaSeconds;
		}
	}
}