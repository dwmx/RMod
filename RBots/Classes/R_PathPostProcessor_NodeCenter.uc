//==============================================================================
//	R_PathPostProcessor_NodeCenter
//	Processes a NavMesh path as a list of points located at the center of each
//	triangle node
//==============================================================================
class R_PathPostProcessor_NodeCenter extends R_PathPostProcessor;

function bool PostProcessPath(
	R_BotNavMesh NavMesh,
	Vector StartLocation, Vector EndLocation,
	out int InPathIndices[32], int PathIndexCount,
	out Vector OutPathPoints[32], out int OutPathPointCount)
{
	local int i;
	local Vector Normal, Center;

	for(i = 0; i < PathIndexCount; ++i)
	{
		NavMesh.GetTriangleNormalAndCenterUnchecked(InPathIndices[i], Normal, Center);
		OutPathPoints[i] = Center;
	}

	OutPathPointCount = i;
	return true;
}