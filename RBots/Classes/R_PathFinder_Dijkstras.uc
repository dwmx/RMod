//==============================================================================
//	R_PathFinder_Dijkstras
//	NavMesh path finding implementation using Dijkstras
//==============================================================================
class R_PathFinder_Dijkstras extends R_PathFinder;

const Utilities = Class'RBots.R_BotUtilities';
const MAX_NODES = 1024; // Adjust to match maximum number of triangles

function bool FindPath(
	R_NavMesh NavMesh,
	int StartIndex, int EndIndex,
	out int OutPathIndices[32], out int OutPathIndexCount,
    optional R_PathFindData OptionalPathFindData)
{
	local int Dist[1024];
    local int Prev[1024];
    local byte Visited[1024];
    local int i, j, k, u, v;
    local int Adjacents[3];
	local float Costs[3];
    local int MinDist, MinNode;
    local int TotalNodes;
	local int T[3];		// Adjacent triangle indices
	local int E[3];		// Adjacent triangle shared edges
	local float C[3];	// Cost for adjacent connections

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
		NavMesh.GetTriangleAdjacentDataUnchecked(MinNode, T, E, C);
        for (k = 0; k < 3; k++)
        {
            v = T[k];
            if (v >= 0 && Visited[v] == 0)
            {
				if(Dist[MinNode] + C[k] < Dist[v])
                {
                    //Dist[v] = Dist[MinNode] + 1;
					Dist[v] = Dist[MinNode] + C[k];
                    Prev[v] = MinNode;
                }
            }
        }
    }

    // If no path found
    if (Prev[EndIndex] == -1 && EndIndex != StartIndex)
    {
        OutPathIndexCount = 0;
        return false;
    }

    // Reconstruct path backwards
    OutPathIndexCount = 0;
    u = EndIndex;
    while (u != -1 && OutPathIndexCount < 32)
    {
        OutPathIndices[OutPathIndexCount] = u;
        OutPathIndexCount++;
        u = Prev[u];
    }

    // Reverse the path (since we built it backwards)
    for (i = 0; i < OutPathIndexCount / 2; i++)
    {
        j = OutPathIndices[i];
        OutPathIndices[i] = OutPathIndices[OutPathIndexCount - 1 - i];
        OutPathIndices[OutPathIndexCount - 1 - i] = j;
    }

	// If a PathFindData object was provided, add relevant data
	if(OptionalPathFindData != None)
	{
		OptionalPathFindData.ClearPathNodes();
		for(i = 0; i < OutPathIndexCount; ++i)
		{
			OptionalPathFindData.PushPathNode(OutPathIndices[i]);
		}
	}

	return true;
}