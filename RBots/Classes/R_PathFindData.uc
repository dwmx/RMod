
//==============================================================================
//	R_PathFindData
//	An object which may optionally be provided to R_BotNavMesh.FindPath
//	When provided, PathFinder and PathPostProcessor may push details about their
//	execution into this object (intermediate data, portals, etc)
//==============================================================================
class R_PathFindData extends Object;

var private Class<R_PathFinder> PathFinderClass;
var private Class<R_PathPostProcessor> PathPostProcessorClass;

const PORTALS_ARRAY_SIZE = 32;
var private Vector PortalsLeft[32];
var private Vector PortalsRight[32];
var private int PortalsCount;

// Clear all per-execution data, called by R_BotNavMesh.FindPath
function Clear()
{
	ClearPortals();
}

function ClearPortals()
{
	local int i;

	PathFinderClass = None;
	PathPostProcessorClass = None;

	for(i = 0; i < PORTALS_ARRAY_SIZE; ++i)
	{
		PortalsLeft[i] = Vect(0,0,0);
		PortalsRight[i] = Vect(0,0,0);
	}
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