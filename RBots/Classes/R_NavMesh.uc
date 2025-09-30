//==============================================================================
//	R_NavMesh
//	Abstract base class for NavMesh structure
//	Provides the interface that a NavMesh must implement
//
//	R_DynamicMapData instantiates and builds NavMeshes in this order:
//	- new R_NavMesh
//	- R_NavMesh.InitializeNavMeshBase() -- (Base class only)
//	- R_NavMesh.InitializeNavMesh() -- (Subclass initialization)
//	- BuildNavMesh -- (calls to Push functions)
//	- R_NavMesh.ValidateNavMesh()
//	- R_NavMesh.PostProcessNavMesh()
//==============================================================================
//class R_NavMesh extends Actor abstract;
class R_NavMesh extends R_NavObject abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavMesh';

const NavLib = Class'RBots.R_NavLibrary';

// Class for accelerated spatial and proximity look-ups
var private Class<R_NavMeshSpatialQuery> NavMeshSpatialQueryClass;
var private R_NavMeshSpatialQuery NavMeshSpatialQuery;

// Class for graph-based pathfinding on navmesh
var private Class<R_NavPathFinder> NavPathFinderClass;
var private R_NavPathFinder NavPathFinder;

// Class for filtering path nodes and outputting world locations
var private Class<R_NavPathFilter> NavPathFilterClass;
var private R_NavPathFilter NavPathFilter;

var private bool bInitialized;

function InitializeNavMesh();
function bool ValidateNavMesh(out String OutFailedLogString);
function PostProcessNavMesh();

// Vertex functions
function PushVertex(Vector Location);
function int GetVertexCount();
function GetVertexUnchecked(int Index, out Vector OutLocation);

// Edge functions
function PushEdge(int V0, int V1);
function int GetEdgeCount();
function GetEdgeVertexLocationsUnchecked(int Index, out Vector VLoc[2]);
function GetEdgeVertexIndicesUnchecked(int Index, out int OutV0, out int OutV1);
function GetEdgeFlagsUnchecked(int Index, out int OutEdgeFlags);
function GetEdgeOrientationUnchecked(int Index, out Vector OutEdgeOrientation);
function int FindSharedEdgeIndex(int T0, int T1);
function SetEdgePassable(int V0, int V1, bool bPassable);

// Triangle functions
function PushTriangleAsVertices(int V0, int V1, int V2, optional Name PolyGroupName);
function int GetTriangleCount();
function GetTriangleVertexLocationsUnchecked(int Index, out Vector VLoc[3]);
function GetTriangleVertexIndicesUnchecked(int Index, out int OutV0, out int OutV1, out int OutV2);
function GetTriangleEdgeIndicesUnchecked(int Index, out int OutE0, out int OutE1, out int OutE2);
function GetTrianglePolyGroupIndexUnchecked(int Index, out int OutPolyGroupIndex);

// Returns the NeighborSet for the given node index
// This includes all adjacent and proximal neighbors	
function GetTriangleNeighborSetUnchecked(int Index, out R_NavNeighborSet OutNodeNeighborSet);

// Returns the normal and center location vectors for the given triangle index
function GetTriangleNormalAndCenterUnchecked(int Index, out Vector OutNormal, out Vector OutCenter);

// Given two Triangle indices (A,B), returns the left and right end points of the shared edge, in reference to the
// direction of travel going from A to B
// If there is no shared edge, function returns false
function bool GetTriangleSharedEdgeLocationsUnchecked(int IndexA, int IndexB, out Vector OutLeftLocation, out Vector OutRightLocation);

// PolyGroups
function CreatePolyGroup(Name PolyGroupName);
function int GetPolyGroupCount();
function R_NavMeshPolyGroup GetPolyGroupByIndex(int PolyGroupIndex);
function R_NavMeshPolyGroup GetPolyGroupByName(Name PolyGroupName);

//------------------------------------------------------------------------------
//	Base NavMesh implementation -- Do not override

// Initialization and construction
final function InitializeNavMeshBase()
{
	if(bInitialized)
	{
		Utilities.Static.RLog("Attempted to re-initialize NavMesh", LogCategory);
		return;
	}
	Utilities.Static.RLog("Initializing NavMesh", LogCategory);
	bInitialized = true;

	// Init subclass
	InitializeNavMesh();
}

final function InitNavMeshSpatialQuery()
{
	local String FailedLogString;

	if(NavMeshSpatialQuery != None)
	{	// Already instantiated
		return;
	}

	NavMeshSpatialQuery = R_NavMeshSpatialQuery(InitNavMeshSubObject(NavMeshSpatialQueryClass, FailedLogString));
	if(NavMeshSpatialQuery == None)
	{
		Utilities.Static.RLog("InitNavMeshSpatialQuery failed --" @ FailedLogString, LogCategory);
		return;
	}

	Utilities.Static.RLog("Initialized NavMeshSpatialQuery:" @ NavMeshSpatialQuery, LogCategory);
}

final function InitNavPathFinder()
{
	local String FailedLogString;

	if(NavPathFinder != None)
	{	// Already instantiated
		return;
	}

	NavPathFinder = R_NavPathFinder(InitNavMeshSubObject(NavPathFinderClass, FailedLogString));
	if(NavPathFinder == None)
	{
		Utilities.Static.RLog("InitNavPathFinder failed --" @ FailedLogString, LogCategory);
		return;
	}

	Utilities.Static.RLog("Initialized NavPathFinder:" @ NavPathFinder, LogCategory);
}

final function InitNavPathFilter()
{
	local String FailedLogString;

	if(NavPathFilter != None)
	{	// Already instantiated
		return;
	}

	NavPathFilter = R_NavPathFilter(InitNavMeshSubObject(NavPathFilterClass, FailedLogString));
	if(NavPathFilter == None)
	{
		Utilities.Static.RLog("InitNavPathFilter failed --" @ FailedLogString, LogCategory);
		return;
	}

	Utilities.Static.RLog("Initialized NavPathFilter:" @ NavPathFilter, LogCategory);
}

final function Object InitNavMeshSubObject(Class ObjectClass, out String OutFailedLogString)
{
	local Object Result;

	if(ObjectClass == None)
	{
		OutFailedLogString = "Bad ObjectClass:" @ ObjectClass;
		return None;
	}

	Result = new(None) ObjectClass;
	if(Result == None)
	{
		OutFailedLogString = "Instantiation failed for ObjectClass:" @ ObjectClass;
		return None;
	}

	return Result;
}

final function PostProcessNavMeshBase()
{
	PostProcessNavMesh();

	// Init necessary SubObjects
	InitNavMeshSpatialQuery();
	InitNavPathFinder();
	InitNavPathFilter();

	if(NavMeshSpatialQuery != None)
	{
		Utilities.Static.RLog("NavMeshSpatialQuery post-processing NavMesh", LogCategory);
		NavMeshSpatialQuery.InitNavMeshSpatialQuery(Self);
	}
	else
	{
		Utilities.Static.RLog("NavMeshSpatialQuery could not post-process NavMesh, look-ups will not work", LogCategory);
	}
}

// Class accessors
final function Class<R_NavMeshSpatialQuery> GetNavMeshSpatialQueryClass() { return NavMeshSpatialQueryClass; }
final function Class<R_NavPathFinder> GetNavPathFinderClass() { return NavPathFinderClass; }
final function Class<R_NavPathFilter> GetNavPathFilterClass() { return NavPathFilterClass; }

final function R_NavMeshSpatialQuery GetNavMeshSpatialQuery()
{
	return NavMeshSpatialQuery;
}

// FindPath -- Main pathfinding function
// Returns path data in NavContext
// If NavPathObserver is provided, intermmediate path finding data can be viewed
function bool FindPath(
	Vector StartLocation, Vector EndLocation,
	R_NavContext NavContext,
	optional R_NavContextObserver OptionalNavPathObserver)
{
	local int StartIndex, EndIndex;
	local String FailedLogString;

	FailedLogString = "FindPath failed -- ";

	if(NavContext == None)
	{	// Must have a NavContext
		Utilities.Static.RLog(FailedLogString $ "Invalid NavContext argument:" @ NavContext, LogCategory);
		return false;
	}
	if(NavMeshSpatialQuery == None)
	{	// Ensure NavMeshSpatialQuery is initialized
		Utilities.Static.RLog(FailedLogString $ "Uninitialized NavMeshSpatialQuery:" @ NavMeshSpatialQuery, LogCategory);
		return false;
	}
	if(NavPathFinder == None)
	{	// Ensure NavPathFinder is initialized
		Utilities.Static.RLog(FailedLogString $ "Uninitialized NavPathFinder:" @ NavPathFinder, LogCategory);
		return false;
	}
	if(NavPathFilter == None)
	{	// Ensure NavPathFilter is initialized
		Utilities.Static.RLog(FailedLogString $ "Uninitialized NavPathFilter:" @ NavPathFilter, LogCategory);
		return false;
	}

	// Get start and end node indices from spatial query
	if(	!NavMeshSpatialQuery.FindContainingNode(Self, StartLocation, StartIndex)
	||	!NavMeshSpatialQuery.FindContainingNode(Self, EndLocation, EndIndex))
	{
		Utilities.Static.RLog(FailedLogString $ "Failed to find StartIndex or EndIndex", LogCategory);
		return false;
	}

	if(OptionalNavPathObserver != None)
	{	// If a NavPathObserver object was provided, initialize it before execution
		OptionalNavPathObserver.ClearPath();
		OptionalNavPathObserver.SetNavPathFinderClass(NavPathFinder.Class);
		OptionalNavPathObserver.SetNavPathFilterClass(NavPathFilter.Class);
	}

	// Initialize NavContext
	NavContext.ClearPath();

	if(!NavPathFinder.FindPath(Self, StartIndex, EndIndex, NavContext, OptionalNavPathObserver))
	{	// Find path nodes
		Utilities.Static.RLog(FailedLogString $ "NavPathFinder failed to find path", LogCategory);
		return false;
	}

	if(!NavPathFilter.PostProcessPath(Self, StartLocation, EndLocation, NavContext, OptionalNavPathObserver))
	{	// Post process path nodes into path points
		Utilities.Static.RLog(FailedLogString $ "NavPathFilter failed to produce path points", LogCategory);
		return false;
	}

	if(OptionalNavPathObserver != None)
	{	// If a NavPathObserver was provided, copy path data over
		OptionalNavPathObserver.CopyNavPath(NavContext);
	}

	return true;
}

// Given a NodeIndex, returns the best node to travel towards to ultimately arrive at the specified PolyGroup
// If no such node exists, returns false and InvalidIndex
function bool FindBestNeighborFromNodeTowardsPolyGroup(int NodeIndex, int PolyGroupIndex, out int OutBestNeighborIndex);

//------------------------------------------------------------------------------
//	Spatial Query Functions
//	All of these functions route calls to the NavMeshSpatialQuery object
//
//	TODO: Consider a function `GetSpatialQueryInterface` which just returns the
//	NavMeshSpatialQuery object

// Returns the index of the node containing the specified location
function int FindContainingNodeIndex(Vector Location)
{
	local int Result;

	if(NavMeshSpatialQuery == None)
	{
		return NavLib.Static.InvalidIndex();
	}

	NavMeshSpatialQuery.FindContainingNode(Self, Location, Result);
	return Result;
}

function FindNodesInRadius(Vector Origin, float Radius, out int OutNodes[32], out int OutNumNodes)
{
	if(NavMeshSpatialQuery == None)
	{
		OutNumNodes = 0;
		return;
	}

	NavMeshSpatialQuery.FindNodesInRadius(Self, Origin, Radius, OutNodes, OutNumNodes);
}

function int FindContainingPolyGroupIndex(Vector Location)
{
	local int NodeIndex;
	local int Result;

	NodeIndex = FindContainingNodeIndex(Location);
	if(NodeIndex != NavLib.Static.InvalidIndex())
	{
		GetTrianglePolyGroupIndexUnchecked(NodeIndex, Result);
		return Result;
	}

	return NavLib.Static.InvalidIndex();
}

function bool FindRelevantBorderEdgesInRadius2D(
	Vector Location,
	float Radius,
	out int OutEdgeIndices[32],
	out float OutEdgeDistances[32],
	out int OutNumEdges)
{
	if(NavMeshSpatialQuery == None)
	{
		OutNumEdges = 0;
		return false;
	}

	return NavMeshSpatialQuery.FindRelevantBorderEdgesInRadius2D(Self, Location, Radius, OutEdgeIndices, OutEdgeDistances, OutNumEdges);
}

defaultproperties
{
	bInitialized=false
	//NavMeshSpatialQueryClass=Class'RBots.R_NavMeshSpatialQuery_Linear'
	NavMeshSpatialQueryClass=Class'RBots.R_NavMeshSpatialQuery_GridCache'
	NavPathFinderClass=Class'RBots.R_NavPathFinder_Dijkstras'
	NavPathFilterClass=Class'RBots.R_NavPathFilter_Funnel'
	//NavPathFilterClass=Class'RBots.R_NavPathFilter_NodeCenter'
}