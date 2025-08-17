//==============================================================================
//	R_PathFinder_Dijkstras
//	NavMesh path finding implementation using Dijkstras
//==============================================================================
class R_PathFinder_Dijkstras extends R_PathFinder;

const Utilities = Class'RBots.R_BotUtilities';
const MAX_NODES = 1024; // Adjust to match maximum number of triangles

function bool FindPath(
	R_BotNavMesh NavMesh,
	int StartIndex, int EndIndex,
	out int OutPathIndices[32], out int OutPathIndexCount)
{
	local int Dist[1024];
    local int Prev[1024];
    local byte Visited[1024];
    local int i, j, k, u, v;
    local int Adjacents[3];
    local int MinDist, MinNode;
    local int TotalNodes;
	//local int PathPoints[32];
	//local Vector TriangleCenter, TriangleNormal;

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
        NavMesh.GetTriangleAdjacentsUnchecked(MinNode, Adjacents[0], Adjacents[1], Adjacents[2]);
        for (k = 0; k < 3; k++)
        {
            v = Adjacents[k];
            if (v >= 0 && Visited[v] == 0)
            {
                if (Dist[MinNode] + 1 < Dist[v]) // uniform cost (1 per edge)
                {
                    Dist[v] = Dist[MinNode] + 1;
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

	return true;
}