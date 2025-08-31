//==============================================================================
//	R_NavPath
//	Contains and manages the results of a FindPath nav query
//==============================================================================
class R_NavPath extends Object;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavPath';

const NavLib = Class'RBots.R_NavLibrary';

var private int PathNodeIndices[128];
var private int NumPathNodeIndices;

var private Vector PathLocations[128];
var private int NumPathLocations;

function InitNavPath()
{
	Clear();
}

function Clear()
{
	NumPathNodeIndices = 0;
	NumPathLocations = 0;
}

function PushPathNodeIndex(int PathNodeIndex)
{
	if(NumPathNodeIndices < 0 || NumPathNodeIndices >= ArrayCount(PathNodeIndices))
	{
		Utilities.Static.RLog("PushPathNodeIndex failed -- Bad NumPathNodeIndices:" @ NumPathNodeIndices, LogCategory);
		return;
	}
	PathNodeIndices[NumPathNodeIndices] = PathNodeIndex;
	++NumPathNodeIndices;
}

function int GetNumPathNodeIndices()
{
	return NumPathNodeIndices;
}

function bool GetPathNodeIndex(int Index, out int OutPathNodeIndex)
{
	if(Index < 0 || Index >= NumPathNodeIndices)
	{
		OutPathNodeIndex = NavLib.Static.InvalidIndex();
		return false;
	}

	OutPathNodeIndex = PathNodeIndices[Index];
	return true;
}

function PushPathLocation(out Vector InPathLocation)
{
	if(NumPathLocations < 0 || NumPathLocations >= ArrayCount(PathLocations))
	{
		Utilities.Static.RLog("PushPathLocation failed -- Bad NumPathLocations:" @ NumPathLocations, LogCategory);
		return;
	}
	PathLocations[NumPathLocations] = InPathLocation;
	++NumPathLocations;
}

function int GetNumPathLocations()
{
	return NumPathLocations;
}

function bool GetPathLocation(int Index, out Vector OutPathLocation)
{
	if(Index < 0 || Index >= NumPathLocations)
	{
		OutPathLocation = Vect(0,0,0);
		return false;
	}

	OutPathLocation = PathLocations[Index];
	return true;
}

// Returns the index of the path point closest to InLocation
// Projects onto XY plane
function int GetClosestPathLocationIndex2D(out Vector InLocation)
{
	local float ClosestDistance, CurrentDistance;
	local int ClosestIndex;
	local int i;

	if(NumPathLocations <= 0)
	{
		return NavLib.Static.InvalidIndex();
	}

	if(NumPathLocations == 1)
	{
		return 0;
	}

	ClosestDistance = VSize(Vect(1,1,0) * (PathLocations[0] - InLocation));
	ClosestIndex = 0;
	for(i = 1; i < NumPathLocations; ++i)
	{
		CurrentDistance = VSize(Vect(1,1,0) * (PathLocations[i] - InLocation));
		if(CurrentDistance < ClosestDistance)
		{
			ClosestDistance = CurrentDistance;
			ClosestIndex = i;
		}
	}

	return ClosestIndex;
}