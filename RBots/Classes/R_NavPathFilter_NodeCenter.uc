//==============================================================================
//	R_NavPathFilter_NodeCenter
//	Processes a NavMesh path as a list of points located at the center of each
//	triangle node
//==============================================================================
class R_NavPathFilter_NodeCenter extends R_NavPathFilter;

function bool PostProcessPath(
	R_NavMesh NavMesh,
	Vector StartLocation, Vector EndLocation,
	R_NavPath NavPath,
	optional R_NavPathObserver OptionalNavPathObserver)
{
	local int i;
	local Vector Normal, Center;
	local int PathIndexCount;
	local int Index;

	PathIndexCount = NavPath.GetNumPathNodeIndices();

	for(i = 0; i < PathIndexCount; ++i)
	{
		NavPath.GetPathNodeIndex(i, Index);
		NavMesh.GetTriangleNormalAndCenterUnchecked(Index, Normal, Center);
		NavPath.PushPathLocation(Center);
	}

	return true;
}