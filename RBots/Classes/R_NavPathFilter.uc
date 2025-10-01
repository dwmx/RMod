//==============================================================================
//	R_NavPathFilter
//	Abstract class providing the interface for processing a series of NavMesh
//	path indices into world locations
//==============================================================================
class R_NavPathFilter extends R_NavObject abstract;

/**
	PostProcessPath
	Given a Start, End, and a path of NavMesh indices, returns a filtered
	array of world-space locations to follow that path
*/
function bool PostProcessPath(
	R_NavMesh NavMesh,
	Vector StartLocation, Vector EndLocation,
	R_NavContext NavContext,
	optional R_NavContextObserver OptionalNavContextObserver)
{
	// To be implemented in subclass
	return false;
}