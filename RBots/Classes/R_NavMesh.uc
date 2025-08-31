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
class R_NavMesh extends Actor abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavMesh';

const NavLib = Class'RBots.R_NavLibrary';

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
function GetEdgeVertexIndicesUnchecked(int Index, out int OutV0, out int OutV1);
function GetEdgeFlagsUnchecked(int Index, out int OutEdgeFlags);

// Triangle functions
function PushTriangleAsVertices(int V0, int V1, int V2);
function PushTriangleAsEdges(int E0, int E1, int E2);
function int GetTriangleCount();
function GetTriangleVertexIndicesUnchecked(int Index, out int OutV0, out int OutV1, out int OutV2);
function GetTriangleEdgeIndicesUnchecked(int Index, out int OutE0, out int OutE1, out int OutE2);

// Return up to 3 directly adjacent triangles to the given triangle index
// Out indices will be InvalidIndex if not found
function GetTriangleAdjacentsUnchecked(int Index, out int OutT0, out int OutT1, out int OutT2);

// Get all adjacency information for the given triangle index
// OutT[x]: Adjacent triangle index for adjacent index x
// OutE[x]: Edge shared with triangle OutT[x]
// OutC[x]: Cost of connection between the given triangle and OutT[x]
function GetTriangleAdjacentDataUnchecked(int Index, out int OutT[3], out int OutE[3], out float OutC[3]);

// Returns the normal and center location vectors for the given triangle index
function GetTriangleNormalAndCenterUnchecked(int Index, out Vector OutNormal, out Vector OutCenter);

// Given two Triangle indices (A,B), returns the left and right end points of the shared edge, in reference to the
// direction of travel going from A to B
// If there is no shared edge, function returns false
function bool GetTriangleSharedEdgeLocationsUnchecked(int IndexA, int IndexB, out Vector OutLeftLocation, out Vector OutRightLocation);

// Finds the NavMesh triangle which contains the given world location
// Returns true/false if found, and the triangle index as T0
function bool FindContainingTriangle(out Vector InLocation, out int OutT0);

//------------------------------------------------------------------------------
//	Base NavMesh implementation -- Do not override
event PreBeginPlay()
{
	bInitialized = false;
}

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

	// Init necessary SubObjects
	InitNavPathFinder();
	InitNavPathFilter();

	// Init subclass
	InitializeNavMesh();
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
}

// Class accessors
final function Class<R_NavPathFinder> GetNavPathFinderClass() { return NavPathFinderClass; }
final function Class<R_NavPathFilter> GetNavPathFilterClass() { return NavPathFilterClass; }

// FindPath -- Main pathfinding function
// Returns path data in NavPath
// If NavPathObserver is provided, intermmediate path finding data can be viewed
function bool FindPath(
	Vector StartLocation, Vector EndLocation,
	R_NavPath NavPath,
	optional R_NavPathObserver OptionalNavPathObserver)
{
	local int StartIndex, EndIndex;
	local String FailedLogString;

	FailedLogString = "FindPath failed -- ";

	if(NavPath == None)
	{	// Must have a NavPath
		Utilities.Static.RLog(FailedLogString $ "Invalid NavPath argument:" @ NavPath, LogCategory);
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

	if(!FindContainingTriangle(StartLocation, StartIndex) || !FindContainingTriangle(EndLocation, EndIndex))
	{	// Find start and end nodes
		Utilities.Static.RLog(FailedLogString $ "Failed to find StartIndex or EndIndex", LogCategory);
		return false;
	}

	if(OptionalNavPathObserver != None)
	{	// If a NavPathObserver object was provided, initialize it before execution
		OptionalNavPathObserver.Clear();
		OptionalNavPathObserver.SetNavPathFinderClass(NavPathFinder.Class);
		OptionalNavPathObserver.SetNavPathFilterClass(NavPathFilter.Class);
	}

	// Initialize NavPath
	NavPath.Clear();

	if(!NavPathFinder.FindPath(Self, StartIndex, EndIndex, NavPath, OptionalNavPathObserver))
	{	// Find path nodes
		Utilities.Static.RLog(FailedLogString $ "NavPathFinder failed to find path", LogCategory);
		return false;
	}

	if(!NavPathFilter.PostProcessPath(Self, StartLocation, EndLocation, NavPath, OptionalNavPathObserver))
	{	// Post process path nodes into path points
		Utilities.Static.RLog(FailedLogString $ "NavPathFilter failed to produce path points", LogCategory);
		return false;
	}

	if(OptionalNavPathObserver != None)
	{	// If a NavPathObserver was provided, copy path data over
		OptionalNavPathObserver.CopyNavPath(NavPath);
	}

	return true;
}

defaultproperties
{
	RemoteRole=ROLE_None
	NavPathFinderClass=Class'RBots.R_NavPathFinder_Dijkstras'
	NavPathFilterClass=Class'RBots.R_NavPathFilter_Funnel'
}