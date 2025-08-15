//==============================================================================
//	R_PathFinder
//	Abstract class providing the interface for finding paths within a NavMesh
//	Subclass to implement a pathfinding algorithm and update the PathFinder
//	class in NavMesh
//==============================================================================
class R_PathFinder extends Object abstract;

var R_BotNavMesh NavMesh;

/**
	FindPath
	Finds a path from StartIndex to EndIndex and returns in the out arguments
	Returns whether or not a path was found
*/
function bool FindPath(int StartIndex, int EndIndex, out Vector PathPoints[32], out int NumPathPoints)
{
	// Implement in child class
	return false;
}