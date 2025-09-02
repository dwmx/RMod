//==============================================================================
//	R_NavObject
//	Abstract base class for all navigation objects
//	(Path, PathFinder, PathFilter)
//	This is primarily here so that these classes can share a similar namespace,
//	structs, consts, etc.
//==============================================================================
class R_NavObject extends Object abstract;

enum R_NavNeighborType
{
	NeighborType_Adjacent,
	NeighborType_Proximal
};

struct R_NavNeighbor
{
	var R_NavNeighborType NeighborType;
	var float Cost;
	var int NodeIndex;
};