//==============================================================================
//	R_BotBehavior_DeathMatchFFA
//	Controls a Bot's behavior during an FFA DeathMatch game mode
//==============================================================================
class R_BotBehavior_DeathMatchFFA extends R_BotBehavior;

const NavLib = Class'RBots.R_NavLibrary';

var private int DestinationPolyGroupIndex;
var private int SourcePolyGroupIndex;

var private int DestinationNodeIndex;
var private int SourceNodeIndex;

//------------------------------------------------------------------------------

function BehaviorActivated()
{
	DestinationNodeIndex = NavLib.Static.InvalidIndex();
	SourceNodeIndex = NavLib.Static.InvalidIndex();

	DestinationPolyGroupIndex = NavLib.Static.InvalidIndex();
	SourcePolyGroupIndex = NavLib.Static.InvalidIndex();
}

//------------------------------------------------------------------------------
//	PolyGroup-Based Movement

function int SelectBestPolyGroupCandidate(
	out int InPolyGroupCandidates[16],
	int NumPolyGroupCandidates,
	R_IndexCache RecentlyVisitedIndices)
{
	local float BestScore, CurrentScore;
	local int BestIndex, CurrentIndex;
	local int NumCachedIndices;
	local int i, j, k;

	if(RecentlyVisitedIndices == None)
	{
		return InPolyGroupCandidates[Rand(NumPolyGroupCandidates)];
	}

	NumCachedIndices = RecentlyVisitedIndices.GetNumIndices();
	BestScore = 0.0;
	BestIndex = NavLib.Static.InvalidIndex();

	for(i = 0; i < NumPolyGroupCandidates; ++i)
	{
		CurrentIndex = InPolyGroupCandidates[i];
		CurrentScore = 100.0;
		for(j = 0; j < NumCachedIndices; ++j)
		{
			if(RecentlyVisitedIndices.Get(j) == CurrentIndex)
			{
				CurrentScore = FMax(0.0, CurrentScore - (NumCachedIndices - j) * 20.0);
				break;
			}
		}
		if(CurrentScore > BestScore)
		{
			BestScore = CurrentScore;
			BestIndex = CurrentIndex;
		}
	}

	return BestIndex;
}

function int SelectNewDestinationPolyGroup()
{
	local R_Bot Bot;
	local R_IndexCache PolyGroupIndexCache;
	local R_NavMesh NavMesh;
	local PlayerPawn PP;
	local int NodeIndex;
	local int PolyGroupIndex, NeighborPolyGroupIndex;
	local R_NavMeshPolyGroup PolyGroup;
	local int NumPortals;
	local int i;
	local int PolyGroupCandidates[16];
	local int NumPolyGroupCandidates;

	NavMesh = GetNavMesh();
	Bot = GetBot();
	if(NavMesh == None || Bot == None)
	{
		return NavLib.Static.InvalidIndex();
	}

	PP = GetPlayerPawn();
	if(PP == None)
	{
		return NavLib.Static.InvalidIndex();
	}

	// Find node and polygroup the bot is standing in
	NodeIndex = NavMesh.FindContainingNodeIndex(PP.Location);
	PolyGroupIndex = NavLib.Static.InvalidIndex();
	if(NodeIndex != NavLib.Static.InvalidIndex())
	{
		NavMesh.GetTrianglePolyGroupIndexUnchecked(NodeIndex, PolyGroupIndex);
	}

	// Find the best neighbor to travel towards
	NumPolyGroupCandidates = 0;
	if(PolyGroupIndex != NavLib.Static.InvalidIndex())
	{
		PolyGroup = NavMesh.GetPolyGroupByIndex(PolyGroupIndex);
		if(PolyGroup != None)
		{
			NumPortals = PolyGroup.GetPortalCount();
			for(i = 0; i < NumPortals; ++i)
			{
				NeighborPolyGroupIndex = PolyGroup.GetNeighborPolyGroupIndexForPortalIndex(i);
				if(NeighborPolyGroupIndex != PolyGroupIndex)
				{
					PolyGroupCandidates[NumPolyGroupCandidates] = NeighborPolyGroupIndex;
					++NumPolyGroupCandidates;
				}
			}
		}
	}

	if(NumPolyGroupCandidates > 0)
	{
		PolyGroupIndexCache = Bot.GetRecentlyVisitedPolyGroups();
		return SelectBestPolyGroupCandidate(PolyGroupCandidates, NumPolyGroupCandidates, PolyGroupIndexCache);
	}

	return NavLib.Static.InvalidIndex();
}

// Returns the move direction towards the current DestinationPolyGroupIndex
// Returns false if this move should be discarded
function bool TryGetMoveDirectionTowardsDestinationPolyGroup(out Vector OutMoveDirection)
{
	return false;
}


//------------------------------------------------------------------------------
//	Node-Based Movement

function int SelectNewDestinationNode()
{
	local R_Bot Bot;
	local R_IndexCache RecentlyVisitedNodes;
	local int NumCachedNodes;
	local R_NavNeighborSet NeighborSet;
	local R_NavContext NavContext;
	local R_NavMesh NavMesh;
	local int CurrentNode;
	local int i, j;
	local float CurrentScore, BestScore;
	local int BestNode;
	
	Bot = GetBot();
	NavContext = GetNavContext();
	NavMesh = GetNavMesh();
	if(Bot == None || NavContext == None || NavMesh == None)
	{
		return NavLib.Static.InvalidIndex();
	}

	CurrentNode = NavContext.GetNavMeshNodeIndex();
	RecentlyVisitedNodes = Bot.GetRecentlyVisitedNodes();
	NumCachedNodes = RecentlyVisitedNodes.GetNumIndices();

	BestScore = 0.0;
	BestNode = NavLib.Static.InvalidIndex();
	NavMesh.GetTriangleNeighborSetUnchecked(CurrentNode, NeighborSet);
	for(i = 0; i < NeighborSet.NumNeighbors; ++i)
	{
		if(NeighborSet.Neighbors[i].NeighborType != NeighborType_Adjacent)
		{
			continue;
		}

		CurrentScore = 100.0;

		for(j = 0; j < NumCachedNodes; ++j)
		{
			if(RecentlyVisitedNodes.Get(j) == NeighborSet.Neighbors[i].NeighborIndex)
			{
				CurrentScore = FMax(0.0, CurrentScore - (NumCachedNodes - j) * 20.0);
				break;
			}
		}

		if(CurrentScore > BestScore)
		{
			BestScore = CurrentScore;
			BestNode = NeighborSet.Neighbors[i].NeighborIndex;
		}
	}

	return BestNode;
}





// Returns the move direction towards the current DestinationNode
// Returns false if this move should be discarded
function bool TryGetMoveDirectionTowardsDestinationNode(out Vector OutMoveDirection)
{
	local PlayerPawn PP;
	local R_NavMesh NavMesh;
	local Vector VLoc[3];
	local Vector Delta;

	OutMoveDirection = Vect(0,0,0);

	PP = GetPlayerPawn();
	NavMesh = GetNavMesh();
	if(PP == None || NavMesh == None)
	{
		return false;
	}

	if(DestinationNodeIndex != NavLib.Static.InvalidIndex())
	{
		NavMesh.GetTriangleVertexLocationsUnchecked(DestinationNodeIndex, VLoc);
		Delta = (VLoc[0] + VLoc[1] + VLoc[2]) * (1.0/3.0) - PP.Location;
		Delta.Z = 0.0;
		OutMoveDirection = Normal(Delta);
		return true;
	}
	
	return false;
}

// Returns the move direction under default conditions
// This is a fall-back for when environmental awareness fails, so there isn't much to work with
// Returns false if this move should be discarded
function bool TryGetMoveDirectionDefault(out Vector OutMoveDirection)
{
	OutMoveDirection = Vect(0,0,0);
	return true;
}


//------------------------------------------------------------------------------

function BehaviorTick(float DeltaSeconds)
{
	local R_NavContext NavContext;
	local int NodeIndex, PolyGroupIndex;
	local Vector MoveDirection;
	local R_BotPawnController Controller;
	
	// Update Node and PolyGroup destinations as the Pawn moves to new Nodes and PolyGroups
	NavContext = GetNavContext();
	if(NavContext != None)
	{
		NavContext.GetNavMeshIndices(NodeIndex, PolyGroupIndex);

		if(NodeIndex != SourceNodeIndex)
		{	// Node index has changed, update is required
			SourceNodeIndex = NodeIndex;
			DestinationNodeIndex = SelectNewDestinationNode();
		}

		if(PolyGroupIndex != SourcePolyGroupIndex)
		{	// PolyGroup index has changed, update is required
			SourcePolyGroupIndex = PolyGroupIndex;
			DestinationPolyGroupIndex = SelectNewDestinationPolyGroup();
		}
	}

	// Next steps are only for movement input
	Controller = GetBotPawnController();
	if(Controller == None)
	{
		return;
	}

	// Try to get a move direction towards another PolyGroup
	if(!TryGetMoveDirectionTowardsDestinationPolyGroup(MoveDirection))
	{	// PolyGroup move failed, try to get a move direction towards another Node
		if(!TryGetMoveDirectionTowardsDestinationNode(MoveDirection))
		{	// Default fall-back
			if(!TryGetMoveDirectionDefault(MoveDirection))
			{	// If all fails, no movement input should be applied
				MoveDirection = Vect(0,0,0);
			}
		}
	}

	// Apply the movement input
	Controller.AddMovementInput_WorldSpace(MoveDirection);
}