//==============================================================================
//	R_PathPostProcessor
//	Abstract class providing the interface for processing a series of NavMesh
//	path indices into world locations
//==============================================================================
class R_PathPostProcessor extends Object abstract;

/**
	PostProcessPath
	Given a Start, End, and a path of NavMesh indices, returns a filtered
	array of world-space locations to follow that path
*/
function bool PostProcessPath(
	R_BotNavMesh NavMesh,
	Vector StartLocation, Vector EndLocation,
	out int InPathIndices[32], int PathIndexCount,
	out Vector OutPathPoints[32], out int OutPathPointCount)
{
	// To be implemented in subclass
	return false;
}