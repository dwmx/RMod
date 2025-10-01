//==============================================================================
//	R_NavPathFilter_NodeCenter
//	Processes a NavMesh path as a list of points located at the center of each
//	triangle node
//==============================================================================
class R_NavPathFilter_NodeCenter extends R_NavPathFilter;

function bool PostProcessPath(
	R_NavMesh NavMesh,
	Vector StartLocation, Vector EndLocation,
	R_NavContext NavContext,
	optional R_NavContextObserver OptionalNavContextObserver)
{
	local int i;
	local Vector Normal, Center;
	local int PathIndexCount;
	local int Index;

	PathIndexCount = NavContext.GetNumPathNodeIndices();

	for(i = 0; i < PathIndexCount; ++i)
	{
		NavContext.GetPathNodeIndex(i, Index);
		NavMesh.GetTriangleNormalAndCenterUnchecked(Index, Normal, Center);
		NavContext.PushPathLocation(Center);
	}

	return true;
}