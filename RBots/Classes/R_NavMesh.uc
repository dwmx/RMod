//==============================================================================
//	R_NavMesh
//	Abstract base class for NavMesh structure
//	Provides the interface that a NavMesh must implement
//
//	R_DynamicMapData instantiates and builds NavMeshes in this order:
//	- new R_NavMesh
//	- R_NavMesh.InitializeNavMesh()
//	- BuildNavMesh -- (calls to Push functions)
//	- R_NavMesh.ValidateNavMesh()
//	- R_NavMesh.PostProcessNavMesh()
//==============================================================================
class R_NavMesh extends Actor abstract;

// Initialization and construction
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

function bool FindContainingTriangle(out Vector InLocation, out int OutT0);

function GetTriangleNormalAndCenterUnchecked(int Index, out Vector OutNormal, out Vector OutCenter);

function GetTriangleAdjacentsUnchecked(int Index, out int T0, out int T1, out int T2);

// Path finding
function Class<R_PathFinder> GetPathFinderClass();
function Class<R_PathPostProcessor> GetPathPostProcessorClass();

function bool FindPath(
	Vector StartLocation, Vector EndLocation,
	out Vector OutPathPoints[32], out int OutPathPointCount,
	optional R_PathFindData OptionalPathFindData);