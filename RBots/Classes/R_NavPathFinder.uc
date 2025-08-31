//==============================================================================
//	R_NavPathFinder
//	Abstract class providing the interface for finding paths within a NavMesh
//	Subclass to implement a pathfinding algorithm and update the NavPathFinder
//	class in NavMesh
//==============================================================================
class R_NavPathFinder extends Object abstract;

const Utilities = Class'RBots.R_BotUtilities';

/**
	FindPath
	Finds a path from StartIndex to EndIndex and returns in the out arguments
	Returns whether or not a path was found
*/
function bool FindPath(
	R_NavMesh NavMesh,
	int StartIndex, int EndIndex,
	R_NavPath NavPath,
	optional R_NavPathObserver OptionalNavPathObserver)
{
	// To be implemented in subclass
	return false;
}