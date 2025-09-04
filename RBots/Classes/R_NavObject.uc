//==============================================================================
//	R_NavObject
//	Abstract base class for all navigation objects
//	(Path, PathFinder, PathFilter)
//	This is primarily here so that these classes can share a similar namespace,
//	structs, consts, etc.
//==============================================================================
class R_NavObject extends Object abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavObject';

const NavObjectClass = Class'RBots.R_NavObject';

enum R_NavNeighborType
{
	NeighborType_Adjacent,	// Neighbors are directly connected, sharing an edge
	NeighborType_Proximal	// Neighbors are near each other
};

struct R_NavNeighbor
{
	var R_NavNeighborType NeighborType;
	var float NeighborCost;
	var int NeighborIndex;
};

struct R_NavNeighborSet
{
	var R_NavNeighbor Neighbors[32];
	var int NumNeighbors;
};

static function NavNeighborSet_Copy(out R_NavNeighborSet InSource, out R_NavNeighborSet OutDest)
{
	local int i;

	for(i = 0; i < InSource.NumNeighbors; ++i)
	{
		OutDest.Neighbors[i].NeighborType = InSource.Neighbors[i].NeighborType;
		OutDest.Neighbors[i].NeighborCost = InSource.Neighbors[i].NeighborCost;
		OutDest.Neighbors[i].NeighborIndex = InSource.Neighbors[i].NeighborIndex;
	}
	OutDest.NumNeighbors = InSource.NumNeighbors;
}

static function bool NavNeighborSet_AtMaxCapacity(out R_NavNeighborSet InNavNeighborSet)
{
	if(InNavNeighborSet.NumNeighbors >= ArrayCount(InNavNeighborSet.Neighbors))
	{
		return true;
	}
	return false;
}

// Adds the given neighbor index to the given neighbor set
static function bool NavNeighborSet_AddNeighbor(out R_NavNeighborSet InNavNeighborSet, R_NavNeighborType NeighborType, float NeighborCost, int NeighborIndex)
{
	if(NavNeighborSet_AtMaxCapacity(InNavNeighborSet))
	{
		Utilities.Static.RLog("NavNeighborSet_AddNeighbor failed -- Array overflow", LogCategory);
		return false;
	}

	InNavNeighborSet.Neighbors[InNavNeighborSet.NumNeighbors].NeighborType = NeighborType;
	InNavNeighborSet.Neighbors[InNavNeighborSet.NumNeighbors].NeighborCost = NeighborCost;
	InNavNeighborSet.Neighbors[InNavNeighborSet.NumNeighbors].NeighborIndex = NeighborIndex;
	++InNavNeighborSet.NumNeighbors;
	return true;
}

// Returns true if InNavNeighborSet contains the given index as a neighbor
static function bool NavNeighborSet_ContainsNeighbor(out R_NavNeighborSet InNavNeighborSet, int NeighborIndex)
{
	local int i;

	for(i = 0; i < InNavNeighborSet.NumNeighbors; ++i)
	{
		if(InNavNeighborSet.Neighbors[i].NeighborIndex == NeighborIndex)
		{
			return true;
		}
	}
	return false;
}