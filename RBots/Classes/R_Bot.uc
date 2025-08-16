//==============================================================================
//	R_Bot
//	The brains and controller for bots
//==============================================================================
class R_Bot extends Actor;

const PATH_POINT_ARRAY_SIZE = 32;
var private Vector PathPoints[32];
var private int NumPathPoints;

event BeginPlay()
{
	// Test points
	PathPoints[0] = Vect(0.0, 0.0, 0.0);
	PathPoints[1] = Vect(256.0, 0.0, 32.0);
	PathPoints[2] = Vect(256.0, 256.0, 0.0);
	PathPoints[3] = Vect(0.0, 384.0, 0.0);
	NumPathPoints = 4;
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