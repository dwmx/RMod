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

const NavMeshLib = Class'RBots.R_NavMeshLibrary';

// Class for graph-based pathfinding on navmesh
var private Class<R_PathFinder> PathFinderClass;
var private R_PathFinder PathFinder;

// Class for filtering path nodes and outputting world locations
var private Class<R_PathPostProcessor> PathPostProcessorClass;
var private R_PathPostProcessor PathPostProcessor;

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
	InitPathFinder();
	InitPathPostProcessor();

	// Init subclass
	InitializeNavMesh();
}

final function InitPathFinder()
{
	local String FailedLogString;

	if(PathFinder != None)
	{	// Already instantiated
		return;
	}

	PathFinder = R_PathFinder(InitNavMeshSubObject(PathFinderClass, FailedLogString));
	if(PathFinder == None)
	{
		Utilities.Static.RLog("InitPathFinder failed --" @ FailedLogString, LogCategory);
		return;
	}

	Utilities.Static.RLog("Initialized PathFinder:" @ PathFinder, LogCategory);
}

final function InitPathPostProcessor()
{
	local String FailedLogString;

	if(PathPostProcessor != None)
	{	// Already instantiated
		return;
	}

	PathPostProcessor = R_PathPostProcessor(InitNavMeshSubObject(PathPostProcessorClass, FailedLogString));
	if(PathPostProcessor == None)
	{
		Utilities.Static.RLog("InitPathPostProcessor failed --" @ FailedLogString, LogCategory);
		return;
	}

	Utilities.Static.RLog("Initialized PathPostProcessor:" @ PathPostProcessor, LogCategory);
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
final function Class<R_PathFinder> GetPathFinderClass() { return PathFinderClass; }
final function Class<R_PathPostProcessor> GetPathPostProcessorClass() { return PathPostProcessorClass; }

function bool FindPath(
	Vector StartLocation, Vector EndLocation,
	out Vector OutPathPoints[32], out int OutPathPointCount,
	optional R_PathFindData OptionalPathFindData)
{
	local int StartIndex, EndIndex;
	local String FailedLogString;
	local int PathIndices[32];
	local int PathIndexCount;

	FailedLogString = "FindPath failed -- ";

	if(PathFinder == None)
	{	// Ensure PathFinder is initialized
		Utilities.Static.RLog(FailedLogString $ "Uninitialized PathFinder:" @ PathFinder, LogCategory);
		return false;
	}
	if(PathPostProcessor == None)
	{	// Ensure PathPostProcessor is initialized
		Utilities.Static.RLog(FailedLogString $ "Uninitialized PathPostProcessor:" @ PathPostProcessor, LogCategory);
		return false;
	}

	if(!FindContainingTriangle(StartLocation, StartIndex) || !FindContainingTriangle(EndLocation, EndIndex))
	{	// Find start and end nodes
		Utilities.Static.RLog(FailedLogString $ "Failed to find StartIndex or EndIndex", LogCategory);
		return false;
	}

	if(OptionalPathFindData != None)
	{	// If a PathFindData object was provided, initialize it before execution
		OptionalPathFindData.Clear();
		OptionalPathFindData.SetPathFinderClass(PathFinder.Class);
		OptionalPathFindData.SetPathPostProcessorClass(PathPostProcessor.Class);
	}

	if(!PathFinder.FindPath(Self, StartIndex, EndIndex, PathIndices, PathIndexCount, OptionalPathFindData))
	{	// Find path nodes
		Utilities.Static.RLog(FailedLogString $ "PathFinder failed to find path", LogCategory);
		return false;
	}

	if(!PathPostProcessor.PostProcessPath(Self, StartLocation, EndLocation, PathIndices, PathIndexCount, OutPathPoints, OutPathPointCount, OptionalPathFindData))
	{	// Post process path nodes into path points
		Utilities.Static.RLog(FailedLogString $ "PathPostProcessor failed to produce path points", LogCategory);
		return false;
	}

	return true;
}

defaultproperties
{
	RemoteRole=ROLE_None
	PathFinderClass=Class'RBots.R_PathFinder_Dijkstras'
	PathPostProcessorClass=Class'RBots.R_PathPostProcessor_Funnel'
}