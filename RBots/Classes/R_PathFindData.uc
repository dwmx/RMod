
//==============================================================================
//	R_PathFindData
//	An object which may optionally be provided to R_BotNavMesh.FindPath
//	When provided, PathFinder and PathPostProcessor may push details about their
//	execution into this object (intermediate data, portals, etc)
//==============================================================================
class R_PathFindData extends Object;

var private Class<R_PathFinder> PathFinderClass;
var private Class<R_PathPostProcessor> PathPostProcessorClass;

// Clear all per-execution data, called by R_BotNavMesh.FindPath
function Clear()
{
	PathFinderClass = None;
	PathPostProcessorClass = None;
}

function SetPathFinderClass(Class<R_PathFinder> NewPathFinderClass)
{
	PathFinderClass = NewPathFinderClass;
}

function SetPathPostProcessorClass(Class<R_PathPostProcessor> NewPathPostProcessorClass)
{
	PathPostProcessorClass = NewPathPostProcessorClass;
}