//==============================================================================
//	R_NavPathFinder_Dijkstras
//	NavMesh path finding implementation using Dijkstras
//==============================================================================
class R_NavPathFinder_Dijkstras extends R_NavPathFinder;

const Utilities = Class'RBots.R_BotUtilities';
const MAX_NODES = 1024; // Adjust to match maximum number of triangles

const NavLib = Class'RBots.R_NavLibrary';

function bool FindPath(
	R_NavMesh NavMesh,
	int StartIndex, int EndIndex,
	R_NavContext NavContext,
	optional R_NavContextObserver OptionalNavContextObserver)
{
	local int Dist[1024];
    local int Prev[1024];
    local byte Visited[1024];
    local int i, j, k, u, v;
    local int Adjacents[3];
	local float Costs[3];
    local int MinDist, MinNode;
    local int TotalNodes;
	local int PathIndices[128];
	local int PathIndexCount;
	local R_NavNeighborSet NeighborSet;

    // Safety: assume NavMesh knows its triangle count
    TotalNodes = NavMesh.GetTriangleCount();
    if (TotalNodes > MAX_NODES)
        TotalNodes = MAX_NODES;

    // Init arrays
    for (i = 0; i < TotalNodes; i++)
    {
        Dist[i] = 999999;   // infinity
        Prev[i] = -1;
        Visited[i] = 0;
    }

    // Start node
    Dist[StartIndex] = 0;

    // Main Dijkstra loop
    for (i = 0; i < TotalNodes; i++)
    {
        // Find unvisited node with smallest distance
        MinDist = 999999;
        MinNode = -1;
        for (j = 0; j < TotalNodes; j++)
        {
            if (Visited[j] == 0 && Dist[j] < MinDist)
            {
                MinDist = Dist[j];
                MinNode = j;
            }
        }

        if (MinNode == -1)
            break; // no reachable nodes left

        // Mark as visited
        Visited[MinNode] = 1;

        // Early exit if we reached the target
        if (MinNode == EndIndex)
            break;

        // Relax neighbors
		//NavMesh.GetTriangleAdjacentDataUnchecked(MinNode, T, E, C);

		// Get full neighbor set (adjacents + proximals)
		//GetNeighborSet(NavMesh, MinNode, T, C, NumNeighbors);
		NavMesh.GetTriangleNeighborSetUnchecked(MinNode, NeighborSet);

        //for (k = 0; k < NumNeighbors; k++)
		for(k = 0; k < NeighborSet.NumNeighbors; ++k)
        {
            //v = T[k];
			v = NeighborSet.Neighbors[k].NeighborIndex;
            if (v >= 0 && Visited[v] == 0)
            {
				//if(Dist[MinNode] + C[k] < Dist[v])
				if(Dist[MinNode] + NeighborSet.Neighbors[k].NeighborCost < Dist[v])
                {
                    //Dist[v] = Dist[MinNode] + 1;
					//Dist[v] = Dist[MinNode] + C[k];
					Dist[v] = Dist[MinNode] + NeighborSet.Neighbors[k].NeighborCost;
                    Prev[v] = MinNode;
                }
            }
        }
    }

    // If no path found
    if (Prev[EndIndex] == -1 && EndIndex != StartIndex)
    {
        //PathIndexCount = 0;
        return false;
    }

    // Reconstruct path backwards
    PathIndexCount = 0;
    u = EndIndex;
    while (u != -1 && PathIndexCount < 32)
    {
        PathIndices[PathIndexCount] = u;
        PathIndexCount++;
        u = Prev[u];
    }

    // Reverse the path (since we built it backwards)
    for (i = 0; i < PathIndexCount / 2; i++)
    {
        j = PathIndices[i];
        PathIndices[i] = PathIndices[PathIndexCount - 1 - i];
        PathIndices[PathIndexCount - 1 - i] = j;
    }

	// Push all to NavContext
	for(i = 0; i < PathIndexCount; ++i)
	{
		NavContext.PushPathNodeIndex(PathIndices[i]);
	}

	// If a NavContextObserver object was provided, add relevant data
	if(OptionalNavContextObserver != None)
	{
		// Only add data specifically relevant to Dijkstra's
	}

	return true;
}

//------------------------------------------------------------------------------

function bool FindPolyGroupPath(
    R_NavMesh NavMesh,
    int StartPolyGroupIndex, int EndPolyGroupIndex,
    out int OutPolyGroupIndexPath[32],
    out int OutNumPathIndices)
{
    local int i, j;
    local int Current, Next;
    local int PolyGroupNeighbors[32];
    local float PolyGroupCosts[32];
    local int NumPolyGroupNeighbors;

    // bookkeeping
    local float Dist[256];        // tentative costs (size depends on max groups)
    local int Prev[256];          // predecessors
    local byte Visited[256];

    local float BestDist;
    local int BestIndex;
    local int Path[32];
    local int PathLength;

    // quick checks
    if (StartPolyGroupIndex == EndPolyGroupIndex)
    {
        OutNumPathIndices = 0;
        return true;
    }
    if (StartPolyGroupIndex == NavLib.Static.InvalidIndex() || EndPolyGroupIndex == NavLib.Static.InvalidIndex())
    {
        OutNumPathIndices = 0;
        return false;
    }

    // init distances
    for (i = 0; i < ArrayCount(Dist); i++)
    {
        Dist[i] = 9999999.0;
        Prev[i] = NavLib.Static.InvalidIndex();
        Visited[i] = 0;
    }
    Dist[StartPolyGroupIndex] = 0.0;

    // main loop
    while (true)
    {
        // find unvisited node with smallest distance
        BestDist = 9999999.0;
        BestIndex = NavLib.Static.InvalidIndex();
        for (i = 0; i < ArrayCount(Dist); i++)
        {
            if (Visited[i] == 0 && Dist[i] < BestDist)
            {
                BestDist = Dist[i];
                BestIndex = i;
            }
        }

        // nothing left or unreachable
        if (BestIndex == NavLib.Static.InvalidIndex())
        {
            OutNumPathIndices = 0;
            return false;
        }

        Current = BestIndex;
        Visited[Current] = 1;

        // reached goal
        if (Current == EndPolyGroupIndex)
        {
            // reconstruct path
            PathLength = 0;
            Next = EndPolyGroupIndex;
            while (Next != NavLib.Static.InvalidIndex() && Next != StartPolyGroupIndex && PathLength < ArrayCount(Path))
            {
                Path[PathLength] = Next;
                PathLength++;
                Next = Prev[Next];
            }
            // add the start
            if (PathLength < ArrayCount(Path))
            {
                Path[PathLength] = StartPolyGroupIndex;
                PathLength++;
            }

            // reverse into output
            OutNumPathIndices = 0;
            for (i = PathLength - 1; i >= 0; i--)
            {
                OutPolyGroupIndexPath[OutNumPathIndices] = Path[i];
                OutNumPathIndices++;
                if (OutNumPathIndices >= ArrayCount(OutPolyGroupIndexPath))
                    break;
            }
            return true;
        }

        // relax neighbors
        GetPolyGroupNeighbors(NavMesh, Current, PolyGroupNeighbors, PolyGroupCosts, NumPolyGroupNeighbors);
        for (j = 0; j < NumPolyGroupNeighbors; j++)
        {
            if (Visited[PolyGroupNeighbors[j]] == 0 && Dist[Current] + PolyGroupCosts[j] < Dist[PolyGroupNeighbors[j]])
            {
                Dist[PolyGroupNeighbors[j]] = Dist[Current] + PolyGroupCosts[j];
                Prev[PolyGroupNeighbors[j]] = Current;
            }
        }
    }

    return false;
}


function GetPolyGroupNeighbors(
	R_NavMesh NavMesh,
	int PolyGroupIndex,
	out int OutNeighborIndices[32],
	out float OutNeighborCosts[32],
	out int OutNumIndices)
{
	local R_NavMeshPolyGroup PolyGroup;
	local int PortalCount;
	local int i;

	PolyGroup = NavMesh.GetPolyGroupByIndex(PolyGroupIndex);
	if(PolyGroup == None)
	{
		OutNumIndices = 0;
		return;
	}

	PortalCount = PolyGroup.GetPortalCount();
	OutNumIndices = 0;
	for(i = 0; i < PortalCount; ++i)
	{
		if(OutNumIndices >= ArrayCount(OutNeighborIndices))
		{
			break;
		}
		OutNeighborIndices[OutNumIndices] = PolyGroup.GetNeighborPolyGroupIndexForPortalIndex(i);
		OutNeighborCosts[OutNumIndices] = 1.0; // TODO: Calc portal costs here
		++OutNumIndices;
	}
}