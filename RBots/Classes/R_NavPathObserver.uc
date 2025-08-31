
//==============================================================================
//	R_NavPathObserver
//	An object which may optionally be provided to R_BotNavMesh.FindPath
//	When provided, NavPathFinder and NavPathFilter may push details about their
//	execution into this object (intermediate data, portals, etc)
//==============================================================================
class R_NavPathObserver extends R_NavPath;

var private Class<R_NavPathFinder> NavPathFinderClass;
var private Class<R_NavPathFilter> NavPathFilterClass;

// Portals used by Funnel
const PORTALS_ARRAY_SIZE = 32;
var private Vector PortalsLeft[32];
var private Vector PortalsRight[32];
var private int PortalsCount;

// Intermediate Boundary Push data
const BOUNDARY_ARRAY_SIZE = 32;
var private Vector BoundaryLeft[32];
var private Vector BoundaryLeftPushDir[32];
var private Vector BoundaryRight[32];
var private Vector BoundaryRightPushDir[32];
var private int BoundaryLeftCount;
var private int BoundaryRightCount;

// Clear all per-execution data, called by R_BotNavMesh.FindPath
function Clear()
{
	Super.Clear();
	NavPathFinderClass = None;
	NavPathFilterClass = None;
	ClearPortals();
	ClearBoundaries();
}

function ClearPortals()
{
	PortalsCount = 0;
}

function ClearBoundaries()
{
	BoundaryLeftCount = 0;
	BoundaryRightCount = 0;
}

// CopyNavPath
// Copy data from the provided NavPath to this NavPathObserver
function CopyNavPath(R_NavPath SourceNavPath)
{
	local int NumPathNodeIndices, NumPathLocations;
	local int PathNodeIndex;
	local Vector PathLocation;
	local int i;

	// Copy node indices
	NumPathNodeIndices = SourceNavPath.GetNumPathNodeIndices();
	for(i = 0; i < NumPathNodeIndices; ++i)
	{
		SourceNavPath.GetPathNodeIndex(i, PathNodeIndex);
		PushPathNodeIndex(PathNodeIndex);
	}

	// Copy locations
	NumPathLocations = SourceNavPath.GetNumPathLocations();
	for(i = 0; i < NumPathLocations; ++i)
	{
		SourceNavPath.GetPathLocation(i, PathLocation);
		PushPathLocation(PathLocation);
	}
}

function Class<R_NavPathFinder> GetNavPathFinderClass() { return NavPathFinderClass; }
function SetNavPathFinderClass(Class<R_NavPathFinder> NewNavPathFinderClass)
{
	NavPathFinderClass = NewNavPathFinderClass;
}

function Class<R_NavPathFilter> GetNavPathFilterClass() { return NavPathFilterClass; }
function SetNavPathFilterClass(Class<R_NavPathFilter> NewNavPathFilterClass)
{
	NavPathFilterClass = NewNavPathFilterClass;
}

/*
function PushPathNode(int PathNode)
{
	if(PathNodesCount >= PATH_NODES_ARRAY_SIZE)
	{
		return;
	}

	PathNodes[PathNodesCount] = PathNode;
	++PathNodesCount;
}

function int GetPathNodesCount()
{
	return PathNodesCount;
}

function bool GetPathNode(int PathNodeIndex, out int OutNavMeshNodeIndex)
{
	if(PathNodeIndex < 0 || PathNodeIndex >= PATH_NODES_ARRAY_SIZE || PathNodeIndex >= PathNodesCount)
	{
		return false;
	}
	OutNavMeshNodeIndex = PathNodes[PathNodeIndex];
	return true;
}
	*/

function PushPortal(out Vector InPortalLeft, out Vector InPortalRight)
{
	if(PortalsCount >= PORTALS_ARRAY_SIZE)
	{
		return;
	}

	PortalsLeft[PortalsCount] = InPortalLeft;
	PortalsRight[PortalsCount] = InPortalRight;
	++PortalsCount;
}

function int GetPortalsCount()
{
	return PortalsCount;
}

function bool GetPortal(int PortalIndex, out Vector OutLeft, out Vector OutRight)
{
	if(PortalIndex < 0 || PortalIndex > PORTALS_ARRAY_SIZE || PortalIndex > PortalsCount)
	{
		OutLeft = Vect(0,0,0);
		OutRight = Vect(0,0,0);
		return false;
	}

	OutLeft = PortalsLeft[PortalIndex];
	OutRight = PortalsRight[PortalIndex];
	return true;
}

function PushBoundaryLeft(out Vector InLeftBoundary, optional out Vector InLeftBoundaryPushDir)
{
	if(BoundaryLeftCount < BOUNDARY_ARRAY_SIZE)
	{
		BoundaryLeft[BoundaryLeftCount] = InLeftBoundary;
		BoundaryLeftPushDir[BoundaryLeftCount] = InLeftBoundaryPushDir;
		++BoundaryLeftCount;
	}
}

function PushBoundaryRight(out Vector InRightBoundary, optional out Vector InRightBoundaryPushDir)
{
	if(BoundaryRightCount < BOUNDARY_ARRAY_SIZE)
	{
		BoundaryRight[BoundaryRightCount] = InRightBoundary;
		BoundaryRightPushDir[BoundaryRightCount] = InRightBoundaryPushDir;
		++BoundaryRightCount;
	}
}

function int GetBoundaryLeftCount()
{
	return BoundaryLeftCount;
}

function int GetBoundaryRightCount()
{
	return BoundaryRightCount;
}

function bool GetBoundaryLeftVector(int Index, out Vector OutBoundaryLeftVector, optional out Vector OutBoundaryLeftPushDir)
{
	if(Index >= 0 && Index < BOUNDARY_ARRAY_SIZE && Index < BoundaryLeftCount)
	{
		OutBoundaryLeftVector = BoundaryLeft[Index];
		OutBoundaryLeftPushDir = BoundaryLeftPushDir[Index];
		return true;
	}
	return false;
}

function bool GetBoundaryRightVector(int Index, out Vector OutBoundaryRightVector, optional out Vector OutBoundaryRightPushDir)
{
	if(Index >= 0 && Index < BOUNDARY_ARRAY_SIZE && Index < BoundaryRightCount)
	{
		OutBoundaryRightVector = BoundaryRight[Index];
		OutBoundaryRightPushDir = BoundaryRightPushDir[Index];
		return true;
	}
	return false;
}