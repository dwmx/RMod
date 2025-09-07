//==============================================================================
//	R_NavMeshSpatialQuery_Linear
//	NavMesh linear search spatial query
//	Very slow, but very simple
//==============================================================================
class R_NavMeshSpatialQuery_Linear extends R_NavMeshSpatialQuery;

function InitNavMeshSpatialQuery(R_NavMesh NavMesh)
{
	// Linear look-up doesn't really need to cache anything
}

function bool FindContainingNode(R_NavMesh NavMesh, Vector Location, out int OutNode)
{
	local int NumNodes;
	local Vector Normal, Center;
	local Vector VLoc[3];
	local Vector LocationProjected;
	local int BestNode;
	local float BestDist, CurrentDist;
	local int i;

	BestNode = NavLib.Static.InvalidIndex();
	BestDist = 0.0;

	NumNodes = NavMesh.GetTriangleCount();
	for(i = 0; i < NumNodes; ++i)
	{
		// Location must be on the positive side of triangle
		NavMesh.GetTriangleNormalAndCenterUnchecked(i, Normal, Center);
		if((Location - Center) Dot Normal < 0.0)
		{
			continue;
		}

		// Get the triangle
		NavMesh.GetTriangleVertexLocationsUnchecked(i, VLoc);

		// Check location in triangle
		GeomLib.Static.ProjectLocationZOnPlane(Location, Center, Normal, LocationProjected);
		if(GeomLib.Static.IsLocationWithinTriangle2D(LocationProjected, VLoc))
		{
			CurrentDist = VSize(LocationProjected - Location);
			if(CurrentDist < BestDist || BestNode == NavLib.Static.InvalidIndex())
			{
				BestDist = CurrentDist;
				BestNode = i;
			}
		}
	}

	OutNode = BestNode;
	if(OutNode == NavLib.Static.InvalidIndex())
	{
		return false;
	}
	return true;
}

function bool FindNodesInRadius(R_NavMesh NavMesh, Vector Origin, float Radius, out int OutNodes[32], out int OutNumNodes)
{
	local int NumNodes;
	local int V[3];
	local Vector VLoc[3];
	local float Distance;
	local int i, j;

	if(Radius < 0.0)
	{	// Negative radius is invalid arg
		OutNumNodes = 0;
		return false;
	}

	if(Radius == 0.0)
	{	// 0.0 radius is a simple containment check
		if(FindContainingNode(NavMesh, Origin, OutNodes[0]))
		{
			OutNumNodes = 1;
			return true;
		}
		else
		{
			OutNumNodes = 0;
			return false;
		}
	}

	// Distance check all nodes in the navmesh
	OutNumNodes = 0;

	NumNodes = NavMesh.GetTriangleCount();
	for(i = 0; i < NumNodes; ++i)
	{
		if(OutNumNodes >= ArrayCount(OutNodes))
		{
			break;
		}

		// Get vertex locations
		NavMesh.GetTriangleVertexIndicesUnchecked(i, V[0], V[1], V[2]);
		for(j = 0; j < 3; ++j)
		{
			NavMesh.GetVertexUnchecked(V[j], VLoc[j]);
		}

		Distance = NavLib.Static.DistanceLocationToTriangle2D(Origin, VLoc);
		if(Distance <= Radius)
		{
			OutNodes[OutNumNodes] = i;
			++OutNumNodes;
		}
	}

	if(OutNumNodes == 0)
	{
		return false;
	}

	return true;
}

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