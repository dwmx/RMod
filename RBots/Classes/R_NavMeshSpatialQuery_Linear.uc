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