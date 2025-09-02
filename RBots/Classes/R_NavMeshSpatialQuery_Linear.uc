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
	local int V[3];
	local Vector VLoc[3];
	local int i, j;

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
		NavMesh.GetTriangleVertexIndicesUnchecked(i, V[0], V[1], V[2]);
		for(j = 0; j < 3; ++j)
		{
			NavMesh.GetVertexUnchecked(V[j], VLoc[j]);
		}

		// Check location in triangle
		if(NavLib.Static.IsLocationWithinTriangle(VLoc, Location))
		{
			OutNode = i;
			return true;
		}
	}

	OutNode = NavLib.Static.InvalidIndex();
	return false;
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

/*
function bool FindNodeSpatialNeighbors2D(
	R_NavMesh NavMesh,
	int NodeIndex,
	float MaxDistance,
	out int OutNeighborIndices[32],
	out int OutNumNeighborIndices)
{
	local Vector VLoc0[3], VLoc1[3];
	local int NumTriangles;
	local float Distance;
	local int i;

	if(MaxDistance < 0.0)
	{	// Negative distance invalid
		OutNumNeighborIndices = 0;
		return false;
	}

	OutNumNeighborIndices = 0;

	NavMesh.GetTriangleVertexLocationsUnchecked(NodeIndex, VLoc0);
	for(i = 0; i < 3; ++i)
	{
		if(OutNumNeighborIndices >= ArrayCount(OutNeighborIndices))
		{
			break;
		}

		if(i == NodeIndex)
		{
			continue;
		}

		NavMesh.GetTriangleVertexLocationsUnchecked(i, VLoc1);
		Distance = NavLib.Static.DistanceTriangleToTriangle2D(VLoc0, VLoc1);
		if(Distance <= MaxDistance)
		{
			OutNeighborIndices[OutNumNeighborIndices] = i;
			++OutNumNeighborIndices;
		}
	}

	return true;
}
	*/

function bool FindNodeNeighbors2D(
	R_NavMesh NavMesh,
	int NodeIndex,
	float MaxProximalRadius,
	out R_NavNeighbor OutNeighbors[32],
	out int OutNumNeighbors)
{
	local Vector VLoc0[3], VLoc1[3];
	local int NumNodes;
	local int i;

	MaxProximalRadius = FMax(0.0, MaxProximalRadius);

	// Get input node
	NavMesh.GetTriangleVertexLocationsUnchecked(NodeIndex, VLoc0);

	OutNumNeighbors = 0;
	NumNodes = NavMesh.GetTriangleCount();
	for(i = 0; i < NumNodes; ++i)
	{
		if(OutNumNeighbors >= ArrayCount(OutNeighbors))
		{
			break;
		}

		if(i == NodeIndex)
		{
			continue;
		}

		NavMesh.GetTriangleVertexLocationsUnchecked(i, VLoc1);
		if(GeomLib.Static.DistanceTriangleToTriangle2D(VLoc0, VLoc1) <= MaxProximalRadius)
		{
			OutNeighbors[OutNumNeighbors].NeighborType = NeighborType_Proximal;
			OutNeighbors[OutNumNeighbors].Cost = 0.0;
			OutNeighbors[OutNumNeighbors].NodeIndex = i;
			++OutNumNeighbors;
		}
	}

	return true;
}