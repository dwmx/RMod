
//==============================================================================
//	R_PathFindData
//	An object which may optionally be provided to R_BotNavMesh.FindPath
//	When provided, PathFinder and PathPostProcessor may push details about their
//	execution into this object (intermediate data, portals, etc)
//==============================================================================
class R_PathFindData extends Object;

var private Class<R_PathFinder> PathFinderClass;
var private Class<R_PathPostProcessor> PathPostProcessorClass;

// Path node indices into NavMesh
const PATH_NODES_ARRAY_SIZE = 32;
var private int PathNodes[32];
var private int PathNodesCount;

// Portals used by Funnel
const PORTALS_ARRAY_SIZE = 32;
var private Vector PortalsLeft[32];
var private Vector PortalsRight[32];
var private int PortalsCount;

// Clear all per-execution data, called by R_BotNavMesh.FindPath
function Clear()
{
	PathFinderClass = None;
	PathPostProcessorClass = None;
	ClearPathNodes();
	ClearPortals();
}

function ClearPathNodes()
{
	PathNodesCount = 0;
}

function ClearPortals()
{
	PortalsCount = 0;
}

function SetPathFinderClass(Class<R_PathFinder> NewPathFinderClass)
{
	PathFinderClass = NewPathFinderClass;
}

function SetPathPostProcessorClass(Class<R_PathPostProcessor> NewPathPostProcessorClass)
{
	PathPostProcessorClass = NewPathPostProcessorClass;
}

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