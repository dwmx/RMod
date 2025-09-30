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