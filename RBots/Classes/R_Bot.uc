//==============================================================================
//	R_Bot
//	The brains and controller for bots
//==============================================================================
class R_Bot extends Actor;

const Utilities = Class'RBots.R_BotUtilities';

const PATH_POINT_ARRAY_SIZE = 32;
var private Vector PathPoints[32];
var private int NumPathPoints;

var R_BotNavMesh CachedNavMesh;

function R_BotNavMesh GetNavMesh()
{
	local R_BotNavMesh LocalNavMesh;

	if(CachedNavMesh == None)
	{
		foreach AllActors(Class'RBots.R_BotNavMesh', LocalNavMesh)
		{
			break;
		}
		CachedNavMesh = LocalNavMesh;
	}
	
	return CachedNavMesh;
}

// Attempts to find a path between Start and End, and if successful, updates the Bot's path vars
// Returns true if path was found and updated
function bool TryUpdatePath(Vector Start, Vector End)
{
	local R_BotNavMesh LocalNavmesh;

	LocalNavMesh = GetNavMesh();
	if(LocalNavMesh != None)
	{
		return LocalNavMesh.FindPath(Start, End, PathPoints, NumPathPoints);
	}

	return false;
}

function bool GetPathPoint(int Index, out Vector PathPoint)
{
	if(Index < 0 || Index >= NumPathPoints || Index >= PATH_POINT_ARRAY_SIZE)
	{
		Index = -1;
		PathPoint = Vect(0,0,0);
		return false;
	}

	PathPoint = PathPoints[Index];
	return true;
}

function int GetNumPathPoints()
{
	return NumPathPoints;
}

defaultproperties
{

}