//==============================================================================
//	R_NavPathFinder_Dijkstras
//	NavMesh path finding implementation using Dijkstras
//==============================================================================
class R_NavPathFinder_Dijkstras extends R_NavPathFinder;

const Utilities = Class'RBots.R_BotUtilities';
const MAX_NODES = 1024; // Adjust to match maximum number of triangles

const NavLib = Class'RBots.R_NavLibrary';

function bool FindPath(
	R_NavGraphInterface NavGraphInterface,
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
	TotalNodes = NavGraphInterface.GetNodeCount();
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
		// Get full neighbor set (adjacents + proximals)
		NavGraphInterface.GetNeighborSet(MinNode, NeighborSet);

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