//==============================================================================
//	R_NavMesh
//==============================================================================
class R_NavMesh_New extends R_NavMesh;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavMesh';

const NavMeshLib = Class'RBots.R_NavMeshLibrary';

// NavMesh vertex structure
struct NavMeshVertex
{
	var Vector Location;
};
var private NavMeshVertex VertexArray[10000];
var private int NumVertices;

// NavMesh edge structure
struct NavMeshEdge
{
	var int V[2];	// Indices into VertexArray
	var int Flags;	// Flags associated with this edge
};
var private NavMeshEdge EdgeArray[10000];
var private int NumEdges;

// NavMesh triangle structure
struct NavMeshTriangle
{
	var int V[3];	// Indices into VertexArray
	var int E[3];	// Indices into EdgeArray
};
var private NavMeshTriangle TriangleArray[10000];
var private int NumTriangles;

// Adjacencies
struct NavMeshAdjacency
{
	var int T[3];	// Indices into TriangleArray
	var int E[3];	// Indices into EdgeArray
	var int C[3];	// Cost for each connection
};
var private NavMeshAdjacency AdjacencyArray[ArrayCount(TriangleArray)];

function InitializeNavMesh()
{
	Clear();
}

function Clear()
{
	NumVertices = 0;
	NumEdges = 0;
	NumTriangles = 0;
}

function PushVertex(Vector VertexLocation)
{
	if(NumVertices < 0)
	{
		Utilities.Static.RLog("PushVertex failed -- bad index:" @ NumVertices, LogCategory);
		return;
	}
	if(NumVertices >= ArrayCount(VertexArray))
	{
		Utilities.Static.RLog("PushVertex failed -- array overflow", LogCategory);
		return;
	}

	VertexArray[NumVertices].Location = VertexLocation;
	++NumVertices;
}

function PushEdge(int VertexIndex0, int VertexIndex1)
{
	if(NumEdges < 0)
	{
		Utilities.Static.RLog("PushEdge failed -- bad index:" @ NumEdges, LogCategory);
		return;
	}
	if(NumEdges >= ArrayCount(EdgeArray))
	{
		Utilities.Static.RLog("PushEdge failed -- array overflow", LogCategory);
		return;
	}

	EdgeArray[NumEdges].V[0] = Min(VertexIndex0, VertexIndex1);
	EdgeArray[NumEdges].V[1] = Max(VertexIndex0, VertexIndex1);
	EdgeArray[NumEdges].Flags = 0x00;
	++NumEdges;
}

// Attempts to find a previously added edge, or adds a new one if there is not already an entry
// Returns the index of the found or newly created edge
function int FindOrPushEdge(int V0, int V1)
{
	local int MinIndex, MaxIndex;
	local int i;

	MinIndex = Min(V0, V1);
	MaxIndex = Max(V0, V1);

	for(i = 0; i < NumEdges; ++i)
	{
		if(EdgeArray[i].V[0] == MinIndex && EdgeArray[i].V[1] == MaxIndex)
		{
			return i;
		}
	}

	PushEdge(MinIndex, MaxIndex);
	return NumEdges - 1;
}

// Given three vertices in clockwise winding order, adds them as a triangle
function PushTriangleAsVertices(int V0, int V1, int V2)
{
	local int E0, E1, E2;

	if(NumTriangles < 0)
	{
		Utilities.Static.RLog("PushTriangleAsVertices failed -- bad index:" @ NumTriangles, LogCategory);
		return;
	}
	if(NumTriangles >= ArrayCount(TriangleArray))
	{
		Utilities.Static.RLog("PushTriangleAsVertices failed -- array overflow", LogCategory);
		return;
	}

	E0 = FindOrPushEdge(V0, V1);
	E1 = FindOrPushEdge(V1, V2);
	E2 = FindOrPushEdge(V2, V0);

	TriangleArray[NumTriangles].V[0] = V0;
	TriangleArray[NumTriangles].V[1] = V1;
	TriangleArray[NumTriangles].V[2] = V2;
	TriangleArray[NumTriangles].E[0] = E0;
	TriangleArray[NumTriangles].E[1] = E1;
	TriangleArray[NumTriangles].E[2] = E2;
	++NumTriangles;
}

// Validate the NavMesh
function bool ValidateNavMesh(out String OutFailedLogString)
{
	OutFailedLogString = "";

	if(!ValidateNavMeshVertices(OutFailedLogString))
	{
		return false;
	}
	if(!ValidateNavMeshEdges(OutFailedLogString))
	{
		return false;
	}
	if(!ValidateNavMeshTriangles(OutFailedLogString))
	{
		return false;
	}

	return true;
}

//	Validate vertex data in the NavMesh
function bool ValidateNavMeshVertices(out String OutFailedLogString)
{
	if(NumVertices < 0 || NumVertices > ArrayCount(VertexArray))
	{
		OutFailedLogString = "Bad NumVertices:" @ NumVertices;
		return false;
	}

	return true;
}

//	Validate edge data in the NavMesh
//	Assumes that Vertex data has already been validated
function bool ValidateNavMeshEdges(out String OutFailedLogString)
{
	local int i, j;

	if(NumEdges < 0 || NumEdges > ArrayCount(EdgeArray))
	{
		OutFailedLogString = "Bad NumEdges:" @ NumEdges;
		return false;
	}

	for(i = 0; i < NumEdges; ++i)
	{
		for(j = 0; j < 2; ++j)
		{
			if(EdgeArray[i].V[j] < 0 || EdgeArray[i].V[j] >= NumVertices)
			{
				OutFailedLogString = "Edge index" @ i @ "has bad V[" $ j $ "] index:" @ EdgeArray[i].V[j];
				return false;
			}
		}
	}

	return true;
}

//	Validate NavMesh Triangle data
//	Assumes that Edge and Vertex data have both been validated
function bool ValidateNavMeshTriangles(out String OutFailedLogString)
{
	local int i, j;

	if(NumTriangles < 0 || NumTriangles > ArrayCount(TriangleArray))
	{
		OutFailedLogString = "Bad NumTriangles:" @ NumTriangles;
		return false;
	}

	for(i = 0; i < NumTriangles; ++i)
	{
		for(j = 0; j < 3; ++j)
		{
			if(TriangleArray[i].E[j] < 0 || TriangleArray[i].E[j] >= NumEdges)
			{
				OutFailedLogString = "Triangle index" @ i @ "has bad E[" $ j $ "] index:" @ TriangleArray[i].E[j];
				return false;
			}
		}
	}

	return true;
}

// Perform post-build and post-validation processing
function PostProcessNavMesh()
{
	BuildAdjacencies();
	PostProcessEdges();
}

// Generates all data in the AdjacencyArray, identifying which nodes are connected, which
// edges are shared, and the costs between connections
function BuildAdjacencies()
{
	local int EdgeIndex;
	local int i, j;

	Utilities.Static.RLog("Building adjacencies", LogCategory);

	for(i = 0; i < NumTriangles; ++i)
	{
		for(j = 0; j < 3; ++j)
		{
			AdjacencyArray[i].T[j] = NavMeshLib.Static.InvalidIndex();
			AdjacencyArray[i].E[j] = NavMeshLib.Static.InvalidIndex();
			AdjacencyArray[i].C[j] = 0;
		}
	}

	for(i = 0; i < NumTriangles - 1; ++i)
	{
		for(j = i + 1; j < NumTriangles; ++j)
		{
			EdgeIndex = FindSharedEdgeIndex(i, j);
			if(EdgeIndex != NavMeshLib.Static.InvalidIndex())
			{
				MarkTrianglesAdjacent(i, j, EdgeIndex);
			}
		}
	}
}

// If an edge is shared between the two triangles, returns the index of that edge
// Returns InvalidIndex otherwise
function int FindSharedEdgeIndex(int T0, int T1)
{
	local int i;

	for(i = 0; i < 3; ++i)
	{
		if(TriangleArray[T0].E[0] == TriangleArray[T1].E[i])
		{
			return TriangleArray[T0].E[0];
		}
		if(TriangleArray[T0].E[1] == TriangleArray[T1].E[i])
		{
			return TriangleArray[T0].E[1];
		}
		if(TriangleArray[T0].E[2] == TriangleArray[T1].E[i])
		{
			return TriangleArray[T0].E[2];
		}
	}

	return NavMeshLib.Static.InvalidIndex();
}

// Marks the triangles as adjacents, sharing the edge specified by index E
function MarkTrianglesAdjacent(int T0, int T1, int E)
{
	local int Cost;
	local int i, j;

	for(i = 0; i < 3; ++i)
	{
		if(AdjacencyArray[T0].T[i] == NavMeshLib.Static.InvalidIndex())
		{
			break;
		}
	}

	for(j = 0; j < 3; ++j)
	{
		if(AdjacencyArray[T1].T[j] == NavMeshLib.Static.InvalidIndex())
		{
			break;
		}
	}

	if(i == 3 || j == 3)
	{
		Utilities.Static.RLog("MarkTrianglesAdjacent failed for indices [" $ T0 $ "," $ T1 $ "] -- One triangle has too many adjacents", LogCategory);
		return;
	}

	Cost = 0;
	// TODO:
	//Cost = CalculateCost(T0, T1);

	AdjacencyArray[T0].T[i] = T1;
	AdjacencyArray[T0].E[i] = E;
	AdjacencyArray[T0].C[i] = Cost;

	AdjacencyArray[T1].T[j] = T0;
	AdjacencyArray[T1].E[j] = E;
	AdjacencyArray[T1].C[j] = Cost;
}

// Post process edge information
// This identifies border edges and applies the border flag
// Note that this function relies on adjacency information, so it must be run after BuildAdjacencies
function PostProcessEdges()
{
	local int i, j;

	Utilities.Static.RLog("Post processing edge data", LogCategory);

	// It's easiest to mark all edges as border edges and then remove them when they're discovered
	// in the adjacency array
	for(i = 0; i < NumEdges; ++i)
	{
		EdgeArray[i].Flags = EdgeArray[i].Flags | NavMeshLib.Static.EdgeFlag_Border();
	}

	for(i = 0; i < NumTriangles; ++i)
	{
		for(j = 0; j < 3; ++j)
		{
			if(AdjacencyArray[i].E[j] != NavMeshLib.Static.InvalidIndex())
			{
				EdgeArray[AdjacencyArray[i].E[j]].Flags = EdgeArray[AdjacencyArray[i].E[j]].Flags & ~NavMeshLib.Static.EdgeFlag_Border();
			}
		}
	}
}

function int GetVertexCount() { return NumVertices; }
function int GetEdgeCount() { return NumEdges; }
function int GetTriangleCount() { return NumTriangles; }

function GetVertexUnchecked(int Index, out Vector OutLocation)
{
	OutLocation = VertexArray[Index].Location;
}

function GetEdgeVertexIndicesUnchecked(int Index, out int OutV0, out int OutV1)
{
	OutV0 = EdgeArray[Index].V[0];
	OutV1 = EdgeArray[Index].V[1];
}

function GetEdgeFlagsUnchecked(int Index, out int OutEdgeFlags)
{
	OutEdgeFlags = EdgeArray[Index].Flags;
}

function GetTriangleVertexIndicesUnchecked(int Index, out int OutV0, out int OutV1, out int OutV2)
{
	OutV0 = TriangleArray[Index].V[0];
	OutV1 = TriangleArray[Index].V[1];
	OutV2 = TriangleArray[Index].V[2];
}

function GetTriangleEdgeIndicesUnchecked(int Index, out int OutE0, out int OutE1, out int OutE2)
{
	OutE0 = TriangleArray[Index].E[0];
	OutE1 = TriangleArray[Index].E[1];
	OutE2 = TriangleArray[Index].E[2];
}