//==============================================================================
//	R_NavMeshSpatialQuery
//	Interface for performing spatial and proximity look-ups on NavMesh
//==============================================================================
class R_NavMeshSpatialQuery extends R_NavObject abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavSpatialQuery';

const NavLib = Class'RBots.R_NavLibrary';
const GeomLib = Class'RBase.R_AGeometryLibrary';

//------------------------------------------------------------------------------
//	SpatialQuery implementations only really need to implement these functions
function InitNavMeshSpatialQuery(R_NavMesh NavMesh);

function bool FindContainingNode(
	R_NavMesh NavMesh,
	Vector Location,
	out int OutNode)
{
	OutNode = NavLib.Static.InvalidIndex();
	return false;
}

function bool FindNodesInRadius(
	R_NavMesh NavMesh,
	Vector Origin,
	float Radius,
	out int OutNodeIndices[32],
	out int OutNumNodeIndices)
{
	OutNumNodeIndices = 0;
	return false;
}

//------------------------------------------------------------------------------

// TODO:
// This still needs to implement the following functions:
//	- FindNodesInRadius

//------------------------------------------------------------------------------

// FindRelevantBorderEdgesInRadius2D
// Given a location, finds all directly connected border edges with orientations
// pointing toward that location
//
// i.e. For a given location within some node in a NavMesh, this gives you the borders
// that are relevant to navigation at that location
function bool FindRelevantBorderEdgesInRadius2D(
	R_NavMesh NavMesh,
	Vector Location,
	float Radius,
	out int OutEdgeIndices[32],
	out float OutEdgeDistances[32],
	out int OutNumEdges)
{
	local R_NavNeighborSet NeighborSet;
	local int NumNeighbors;
	local int ContainingIndex, CurrentIndex;
	local int Queue[128], Visited[1024]; // If Visited is not large enough to hold every node in the NavMesh, this function will infinite loop
	local int NumQueue, NumVisited;
	local int Edges[3];
	local Vector VLocTriangle[3], VLocEdge[2];
	local Vector EdgeOrientation;
	local float Dist;
	local int EdgeFlags;
	local int NeighborIndex;
	local int i, j;
	local bool bSkip;

	if(!FindContainingNode(NavMesh, Location, ContainingIndex))
	{	// This is a DFS from containing node, so cancel if no node found
		OutNumEdges = 0;
		return false;
	}

	Queue[0] = ContainingIndex;
	NumQueue = 1;
	Visited[0] = ContainingIndex;
	NumVisited = 1;

	OutNumEdges = 0;
	while(NumQueue > 0)
	{
		--NumQueue;
		CurrentIndex = Queue[NumQueue];

		// Push adjacent neighbors
		NavMesh.GetTriangleNeighborSetUnchecked(CurrentIndex, NeighborSet);
		NumNeighbors = NeighborSet.NumNeighbors;
		for(i = 0; i < NumNeighbors; ++i)
		{
			NeighborIndex = NeighborSet.Neighbors[i].NeighborIndex;

			// Skip already visited neighbors
			bSkip = false;
			for(j = 0; j < NumVisited; ++j)
			{
				if(Visited[j] == NeighborIndex)
				{
					bSkip = true;
					break;
				}
			}
			if(bSkip)
			{
				continue;
			}

			// Skip non-adjacent neighbors
			if(NeighborSet.Neighbors[i].NeighborType != NeighborType_Adjacent)
			{
				continue;
			}
			
			// Mark this neighbor as a visited node
			Visited[NumVisited] = NeighborIndex;
			++NumVisited;

			// The adjacent triangle needs to have at least one edge in radius
			NavMesh.GetTriangleVertexLocationsUnchecked(NeighborIndex, VLocTriangle);

			bSkip = true;
			for(j = 0; j < 3; ++j)
			{
				VLocEdge[0] = VLocTriangle[j];
				VLocEdge[1] = VLocTriangle[(j+1)%3];
				Dist = GeomLib.Static.DistanceLocationToLineSegment2D(Location, VLocEdge);
				if(Dist <= Radius)
				{
					bSkip = false;
					break;
				}
			}

			if(bSkip)
			{	// No edge in radius in this node
				continue;
			}

			// At least one edge is in radius, add to queue
			Queue[NumQueue] = NeighborIndex;
			++NumQueue;
		}


		// Check and push edges
		NavMesh.GetTriangleEdgeIndicesUnchecked(CurrentIndex, Edges[0], Edges[1], Edges[2]);

		for(i = 0; i < 3; ++i)
		{
			// Make sure it's not already being output
			bSkip = false;
			for(j = 0; j < OutNumEdges; ++j)
			{
				if(OutEdgeIndices[j] == Edges[i])
				{
					bSkip = true;
					break;
				}
			}
			if(bSkip)
			{
				continue;
			}

			// Make sure the edge is a border or an impassable edge
			NavMesh.GetEdgeFlagsUnchecked(Edges[i], EdgeFlags);
			if(	(EdgeFlags & NavLib.Static.EdgeFlag_Border()) == 0
			&&	(EdgeFlags & NavLib.Static.EdgeFlag_Impassable()) == 0)
			{
				continue;
			}

			// Check against edge vertex locations
			NavMesh.GetEdgeVertexLocationsUnchecked(Edges[i], VLocEdge);

			// Check if location is on the correct side of the border edge
			NavMesh.GetEdgeOrientationUnchecked(Edges[i], EdgeOrientation);
			if((((VLocEdge[0] + VLocEdge[1]) * 0.5f) - Location) Dot EdgeOrientation > 0.0f)
			{	// Must be on the 'surface' side of the edge
				continue;
			}

			Dist = GeomLib.Static.DistanceLocationToLineSegment2D(Location, VLocEdge);

			if(Dist <= Radius)
			{	// This edge is in radius, add it to output
				OutEdgeIndices[OutNumEdges] = Edges[i];
				OutEdgeDistances[OutNumEdges] = Dist;
				++OutNumEdges;
			}
		}
	}
}