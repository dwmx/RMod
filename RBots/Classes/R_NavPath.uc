//==============================================================================
//	R_NavPath
//	Contains and manages the results of a FindPath nav query
//==============================================================================
class R_NavPath extends Object;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavPath';

const NavMeshLib = Class'RBots.R_NavMeshLibrary';

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
		OutPathNodeIndex = NavMeshLib.Static.InvalidIndex();
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