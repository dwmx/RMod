//==============================================================================
//	R_NavPathFinder
//	Abstract class providing the interface for finding paths within a NavMesh
//	Subclass to implement a pathfinding algorithm and update the NavPathFinder
//	class in NavMesh
//==============================================================================
class R_NavPathFinder extends R_NavObject abstract;

const Utilities = Class'RBots.R_BotUtilities';

/**
	FindPath
	Finds a path from StartIndex to EndIndex and returns in the out arguments
	Returns whether or not a path was found
*/
function bool FindPath(
	R_NavGraphInterface NavGraphInterface,
	int StartIndex, int EndIndex,
	R_NavContext NavContext,
	optional R_NavContextObserver OptionalNavContextObserver)
{
	// To be implemented in subclass
	return false;
}

/**
*	FindPolyGroupPath
*	Finds a path of PolyGroups from start to end and returns as an array
*	of PolyGroup indices
*	Returns false if no path could be found
*/
function bool FindPolyGroupPath(
	R_NavMesh NavMesh,
	int StartPolyGroupIndex, int EndPolyGroupIndex,
	out int OutPolyGroupIndexPath[32],
	out int OutNumPathIndices)
{
	return false;
}